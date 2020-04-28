if SERVER then
	AddCSLuaFile()

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	
else
	SWEP.PrintName			= "Jmod Hands"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false

	SWEP.ViewModelFOV		= 45
	--SWEP.WepSelectIcon=surface.GetTextureID("vgui/wep_jack_gmod_hands")
	SWEP.BounceWeaponIcon=false

	local HandTex,ClosedTex=surface.GetTextureID("vgui/hud/gmod_hand"),surface.GetTextureID("vgui/hud/gmod_closedhand")
	function SWEP:DrawHUD()
		if not(GetViewEntity()==LocalPlayer())then return end
		if not(self:GetFists())then
			local Tr=util.QuickTrace(self.Owner:GetShootPos(),self.Owner:GetAimVector()*self.ReachDistance,{self.Owner})
			if(Tr.Hit)then
				if(self:CanPickup(Tr.Entity))then
					local Size=math.Clamp((1-((Tr.HitPos-self.Owner:GetShootPos()):Length()/self.ReachDistance)^2),.2,1)
					if(self.Owner:KeyDown(IN_ATTACK2))then
						surface.SetTexture(ClosedTex)
					else
						surface.SetTexture(HandTex)
					end
					surface.SetDrawColor(Color(255,255,255,255*Size))
					surface.DrawTexturedRect(ScrW()/2-(64*Size),ScrH()/2-(64*Size),128*Size,128*Size)
				end
			end
		end
	end
end

SWEP.SwayScale=3
SWEP.BobScale=3

SWEP.InstantPickup=true -- FF compat

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "you suck"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.HoldType="normal"

SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= "models/props_junk/cardboard_box004a.mdl"

SWEP.UseHands=true

SWEP.AttackSlowDown=.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ReachDistance=60
SWEP.HomicideSWEP=true

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextIdle")
	self:NetworkVar("Bool",2,"Fists")
	self:NetworkVar("Float",1,"NextDown")
	self:NetworkVar("Bool",3,"Blocking")
	self:NetworkVar("Bool",4,"IsCarrying")
end

function SWEP:PreDrawViewModel(vm,wep,ply)
	vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime()+5)
	self:SetNextDown(CurTime()+5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)
end

function SWEP:Deploy()
	if not(IsFirstTimePredicted())then
		self:DoBFSAnimation("fists_draw")
		self.Owner:GetViewModel():SetPlaybackRate(.1)
		return
	end
	self:SetNextPrimaryFire(CurTime()+.1)
	self:SetFists(false)
	self:SetNextDown(CurTime())
	self:DoBFSAnimation("fists_draw")
	return true
end

function SWEP:Holster()
	self:OnRemove()
	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

local pickupWhiteList={
	["prop_ragdoll"]=true,
	["prop_physics"]=true,
	["prop_physics_multiplayer"]=true
}
function SWEP:CanPickup(ent)
	if ent:IsNPC()then return false end
	if ent:IsPlayer()then return false end
	if(ent:IsWorld())then return false end
	local class=ent:GetClass()
	if pickupWhiteList[class] then return true end
	if(CLIENT)then return true end
	if(IsValid(ent:GetPhysicsObject()))then return true end
	return false
end

function SWEP:SecondaryAttack()
	if not(IsFirstTimePredicted())then return end
	if(self:GetFists())then return end
	JMod_Hint(self.Owner,"jmod hands grab","jmod hands drag")
	if SERVER then
		self:SetCarrying()
		local tr=self.Owner:GetEyeTraceNoCursor()
		if((IsValid(tr.Entity))and(self:CanPickup(tr.Entity))and not(tr.Entity:IsPlayer()))then
			local Dist=(self.Owner:GetShootPos()-tr.HitPos):Length()
			if(Dist<self.ReachDistance)then
				sound.Play("Flesh.ImpactSoft",self.Owner:GetShootPos(),65,math.random(90,110))
				self:SetCarrying(tr.Entity,tr.PhysicsBone,tr.HitPos,Dist)
				tr.Entity.Touched=true
				self:ApplyForce()
			end
		elseif((IsValid(tr.Entity))and(tr.Entity:IsPlayer()))then
			local Dist=(self.Owner:GetShootPos()-tr.HitPos):Length()
			if(Dist<self.ReachDistance)then
				sound.Play("Flesh.ImpactSoft",self.Owner:GetShootPos(),65,math.random(90,110))
				self.Owner:SetVelocity(self.Owner:GetAimVector()*20)
				tr.Entity:SetVelocity(-self.Owner:GetAimVector()*50)
				self:SetNextSecondaryFire(CurTime()+.25)
			end
		end
	end
end

function SWEP:ApplyForce()
	local target=self.Owner:GetAimVector()*self.CarryDist+self.Owner:GetShootPos()
	local phys=self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)
	if IsValid(phys)then
		local TargetPos=phys:GetPos()
		if(self.CarryPos)then TargetPos=self.CarryEnt:LocalToWorld(self.CarryPos) end
		local vec=target - TargetPos
		local len,mul=vec:Length(),self.CarryEnt:GetPhysicsObject():GetMass()
		if(len>self.ReachDistance)then
			self:SetCarrying()
			return
		end
		if(self.CarryEnt:GetClass()=="prop_ragdoll")then mul=mul*2 end
		vec:Normalize()
		local avec,velo=vec*len,phys:GetVelocity()-self.Owner:GetVelocity()
		local Force=(avec-velo/2)*mul
		local ForceMagnitude=Force:Length()
		if(ForceMagnitude>4000*JMOD_CONFIG.HandGrabStrength)then
			self:SetCarrying()
			return
		end
		local CounterDir,CounterAmt=velo:GetNormalized(),velo:Length()
		if(self.CarryPos)then
			phys:ApplyForceOffset(Force,self.CarryEnt:LocalToWorld(self.CarryPos))
		else
			phys:ApplyForceCenter(Force)
		end
		phys:ApplyForceCenter(Vector(0,0,mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity()/10)
	end
end

function SWEP:OnRemove()
	if(IsValid(self.Owner) && CLIENT && self.Owner:IsPlayer())then
		local vm=self.Owner:GetViewModel()
		if(IsValid(vm))then vm:SetMaterial("") end
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent,bone,pos,dist)
	if IsValid(ent)then
		self.CarryEnt=ent
		self.CarryBone=bone
		self.CarryDist=dist
		if not(ent:GetClass()=="prop_ragdoll")then
			self.CarryPos=ent:WorldToLocal(pos)
		else
			self.CarryPos=nil
		end
	else
		self.CarryEnt=nil
		self.CarryBone=nil
		self.CarryPos=nil
		self.CarryDist=nil
	end
end

function SWEP:Think()
	if((IsValid(self.Owner))and(self.Owner:KeyDown(IN_ATTACK2))and not(self:GetFists()))then
		if IsValid(self.CarryEnt)then
			self:ApplyForce()
		end
	elseif self.CarryEnt then
		self:SetCarrying()
	end
	if((self:GetFists())and(self.Owner:KeyDown(IN_ATTACK2)))then
		self:SetNextPrimaryFire(CurTime()+.5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
	end
	local HoldType="fist"
	if(self:GetFists())then
		HoldType="fist"
		local Time=CurTime()
		if(self:GetNextIdle()<Time)then
			self:DoBFSAnimation("fists_idle_0"..math.random(1,2))
			self:UpdateNextIdle()
		end
		if(self:GetBlocking())then
			self:SetNextDown(Time+1)
			HoldType="normal"
		end
		if((self:GetNextDown()<Time)or(self.Owner:KeyDown(IN_SPEED)))then
			self:SetNextDown(Time+1)
			self:SetFists(false)
			self:SetBlocking(false)
		end
	else
		HoldType="normal"
		self:DoBFSAnimation("fists_draw")
	end
	if((IsValid(self.CarryEnt))or(self.CarryEnt))then
		HoldType="magic"
	end
	if(self.Owner:KeyDown(IN_SPEED))then HoldType="normal" end
	if(SERVER)then self:SetHoldType(HoldType) end
end

function SWEP:PrimaryAttack()
	JMod_Hint(self.Owner,"jmod hands","jmod hands move")
	local side="fists_left"
	if(math.random(1,2)==1)then side="fists_right" end
	self:SetNextDown(CurTime()+7)
	if not(self:GetFists())then
		self:SetFists(true)
		self:DoBFSAnimation("fists_draw")
		self:SetNextPrimaryFire(CurTime()+.35)
		return
	end
	if(self:GetBlocking())then return end
	if(self.Owner:KeyDown(IN_SPEED))then return end
	if not(IsFirstTimePredicted())then
		self:DoBFSAnimation(side)
		self.Owner:GetViewModel():SetPlaybackRate(1.25)
		return
	end
	self.Owner:ViewPunch(Angle(0,0,math.random(-2,2)))
	self:DoBFSAnimation(side)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:GetViewModel():SetPlaybackRate(1.25)
	self:UpdateNextIdle()
	if(SERVER)then
		sound.Play("weapons/slam/throw.wav",self:GetPos(),65,math.random(90,110))
		self.Owner:ViewPunch(Angle(0,0,math.random(-2,2)))
		timer.Simple(.075,function()
			if(IsValid(self))then
				self:AttackFront()
			end
		end)
	end
	self:SetNextPrimaryFire(CurTime()+.35)
	self:SetNextSecondaryFire(CurTime()+.35)
end

function SWEP:AttackFront()
	if(CLIENT)then return end
	self.Owner:LagCompensation(true)
	local Ent,HitPos=JMOD_WhomILookinAt(self.Owner,.3,55)
	local AimVec=self.Owner:GetAimVector()
	if((IsValid(Ent))or((Ent)and(Ent.IsWorld)and(Ent:IsWorld())))then
		local SelfForce,Mul=125,1
		if(self:IsEntSoft(Ent))then
			SelfForce=25
			if((Ent:IsPlayer())and(IsValid(Ent:GetActiveWeapon()))and(Ent:GetActiveWeapon().GetBlocking)and(Ent:GetActiveWeapon():GetBlocking()))then
				sound.Play("Flesh.ImpactSoft",HitPos,65,math.random(90,110))
			else
				sound.Play("Flesh.ImpactHard",HitPos,65,math.random(90,110))
			end
		else
			sound.Play("Flesh.ImpactSoft",HitPos,65,math.random(90,110))
		end
		local DamageAmt=math.random(2,4)
		local Dam=DamageInfo()
		Dam:SetAttacker(self.Owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt*Mul)
		Dam:SetDamageForce(AimVec*Mul^3)
		Dam:SetDamageType(DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys=Ent:GetPhysicsObject()
		if(IsValid(Phys))then
			if(Ent:IsPlayer())then Ent:SetVelocity(AimVec*SelfForce*1.5) end
			Phys:ApplyForceOffset(AimVec*5000*Mul,HitPos)
			self.Owner:SetVelocity(-AimVec*SelfForce*.8)
		end
		if(Ent:GetClass()=="func_breakable_surf")then
			if(math.random(1,20)==10)then Ent:Fire("break","",0) end
		end
	end
	self.Owner:LagCompensation(false)
end

function SWEP:Reload()
	if not(IsFirstTimePredicted())then return end
	self:SetFists(false)
	self:SetBlocking(false)
	self:SetCarrying()
end

function SWEP:DrawWorldModel()
	-- no, do nothing
end

function SWEP:DoBFSAnimation(anim)
	local vm=self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:UpdateNextIdle()
	local vm=self.Owner:GetViewModel()
	self:SetNextIdle(CurTime()+vm:SequenceDuration())
end

function SWEP:IsEntSoft(ent)
	return ((ent:IsNPC())or(ent:IsPlayer()))
end

if(CLIENT)then
	local BlockAmt=0
	function SWEP:GetViewModelPosition(pos,ang)
		if(self:GetBlocking())then
			BlockAmt=math.Clamp(BlockAmt+FrameTime()*1.5,0,1)
		else
			BlockAmt=math.Clamp(BlockAmt-FrameTime()*1.5,0,1)
		end
		pos=pos-ang:Up()*15*BlockAmt
		ang:RotateAroundAxis(ang:Right(),BlockAmt*60)
		return pos,ang
	end
end