--turret
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
--[[ Hull Size Order
HULL_TINY	 3	
HULL_TINY_CENTERED	 6	
HULL_SMALL_CENTERED	 1	
HULL_HUMAN	 0	
HULL_WIDE_SHORT	 4	
HULL_WIDE_HUMAN	 2	
HULL_MEDIUM	 5	 
HULL_MEDIUM_TALL	 9
HULL_LARGE	 7 
HULL_LARGE_CENTERED	 8	
muzzleflash_g3
muzzleflash_m14
muzzleflash_ak47
muzzleflash_ak74
muzzleflash_6
muzzleflash_pistol_rbull
muzzleflash_pistol
muzzleflash_suppressed
muzzleflash_pistol_deagle
muzzleflash_OTS
muzzleflash_M3
muzzleflash_smg
muzzleflash_SR25
muzzleflash_shotgun
muzzle_center_M82
muzzleflash_m79
--]]
local HULL_TARGETING={
	[0]=0,
	[HULL_TINY]=-5,
	[HULL_TINY_CENTERED]=0,	
	[HULL_SMALL_CENTERED]=-5,
	[HULL_HUMAN]=10,
	[HULL_WIDE_SHORT]=20,
	[HULL_WIDE_HUMAN]=15,
	[HULL_MEDIUM]=0,
	[HULL_MEDIUM_TALL]=35,
	[HULL_LARGE]=30,
	[HULL_LARGE_CENTERED]=30
}
local HULL_SIZE_TABLE={
	[HULL_TINY]={0,1000},
	[HULL_TINY_CENTERED]={1000,7000},	
	[HULL_SMALL_CENTERED]={7000,15000},
	[HULL_HUMAN]={15000,50000},
	[HULL_WIDE_SHORT]={50000,70000},
	[HULL_WIDE_HUMAN]={70000,200000},
	[HULL_MEDIUM]={200000,700000},
	[HULL_MEDIUM_TALL]={700000,1000000},
	[HULL_LARGE]={1000000,1500000},
	[HULL_LARGE_CENTERED]={1500000,2000000}
}
local SYNTHETIC_TABLE={MAT_CONCRETE,MAT_GRATE,MAT_CLIP,MAT_PLASTIC,MAT_METAL,MAT_COMPUTER,MAT_TILE,MAT_WOOD,MAT_VENT,MAT_GLASS,MAT_DIRT,MAT_SAND}
local ORGANIC_TABLE={MAT_FLESH,MAT_ANTLION,MAT_BLOODYFLESH,MAT_FOLIAGE,MAT_SLOSH}
local TARGET_TABLE={["npc_helicopter"]=700000,["npc_strider"]=800000,["npc_combinegunship"]=900000}
local NO_TARGET_TABLE={}
local TS_NOTHING=0
local TS_IDLING=1
local TS_WATCHING=2
local TS_CONCENTRATING=3
local TS_AWAKENING=4
local TS_TRACKING=5
local TS_ASLEEPING=6
local TS_WHINING=7
local BOXES={["9x19mm"]="ent_jack_turretammobox_9mm",["12GAshotshell"]="ent_jack_turretammobox_shot",["7.62x51mm"]="ent_jack_turretammobox_762",["5.56x45mm"]="ent_jack_turretammobox_556",[".338 Lapua Magnum"]="ent_jack_turretammobox_338",[".22 Long Rifle"]="ent_jack_turretammobox_22",["40x53mm Grenade"]="ent_jack_turretammobox_40mm",["AAmissile"]="ent_jack_turretmissilepod",["ATrocket"]="ent_jack_turretrocketpod"}
ENT.CurrentTarget=nil
ENT.HasAmmoBox=false
ENT.HasBattery=false
ENT.BatteryCharge=0
ENT.GoalSweep=0
ENT.GoalSwing=0
ENT.CurrentSweep=0
ENT.CurrentSwing=0
ENT.NextScanTime=0
ENT.NextShotTime=0
ENT.NextWhineTime=0
ENT.NextWatchTime=0
ENT.NextGoSilentTime=0
ENT.WeaponOut=false
ENT.NextBatteryAlertTime=0
ENT.MenuOpen=false
ENT.NextFriendlyTime=0
ENT.NextWarnTime=0
ENT.NextAlrightFuckYouTime=0
ENT.WillWarn=false
ENT.WillLight=false
ENT.StructuralIntegrity=400
ENT.Broken=false
ENT.FiredAtCurrentTarget=false
ENT.NextClearCheckTime=0
ENT.NextOverHeatWhineTime=0
ENT.Heat=0
ENT.IsLocked=false
ENT.LockPass=""
ENT.MaxCharge=3000
ENT.PlugPosition=Vector(0,0,20)
local function GetCenterMass(ent)
	local Pos=ent:LocalToWorld(ent:OBBCenter())
	local Hull=0
	if(ent.GetHullType)then
		Hull=ent:GetHullType()
	end
	local Add=Vector(0,0,0)
	if((ent:IsNPC())or(ent:IsPlayer()))then
		Add=Vector(0,0,HULL_TARGETING[Hull])
	end
	Pos=Pos+Add
	if((ent:IsPlayer())and(ent:Crouching()))then
		Pos=Pos-Vector(0,0,20)
	end
	return Pos
end
local function GetVolyum(ent)
	local Phys=ent:GetPhysicsObject()
	local Class=ent:GetClass()
	if(ent:IsPlayer())then return 45000 end
	if(IsValid(Phys))then
		local Vol=Phys:GetVolume()
		if(Vol)then
			local Mod=ent:GetModel()
			if((Mod)and(string.find(Mod,"/gibs/")))then return 0 end
			return Vol
		else
			return 0
		end
	elseif(not(TARGET_TABLE[Class]==nil))then
		return TARGET_TABLE[Class]
	end
	return 0
end
local function IsSynthetic(ent)
	local Tr=util.QuickTrace(ent:GetPos(),Vector(0,0,500),nil)
	if(Tr.Hit)then
		if(table.HasValue(ORGANIC_TABLE,Tr.MatType))then
			return false
		elseif(table.HasValue(SYNTHETIC_TABLE,Tr.MatType))then
			return true
		else
			return false
		end
	else
		return true
	end
end
function ENT:ExternalCharge(amt)
	self.BatteryCharge=self.BatteryCharge+amt
	if(self.BatteryCharge>self.MaxCharge)then self.BatteryCharge=self.MaxCharge end
	self:SetDTInt(2,math.Round((self.BatteryCharge/self.MaxCharge)*100))
end
function ENT:WillTargetThisSize(siz)
	for key,grp in pairs(self.TargetingGroup)do
		if((siz>HULL_SIZE_TABLE[grp][1])and(siz<=HULL_SIZE_TABLE[grp][2]))then
			return true
		end
	end
	return false
end
function ENT:Initialize()
	self:SetAngles(Angle(0,0,0))
	self.Entity:SetModel("models/combine_turrets/floor_turret.mdl")
	--self.Entity:SetMaterial(self.TurretSkin)
	self.Entity:SetMaterial("models/mat_jack_turret")
	self.Entity:SetColor(Color(50,50,50))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(200)
	end
	self:SetDTInt(0,TS_NOTHING)
	self:ResetSequence(0)
	self:ManipulateBoneScale(0,Vector(1.5,1.1,1))
	self:ManipulateBoneScale(3,self.BarrelSizeMod)
	self:ManipulateBoneScale(1,Vector(self.MechanicsSizeMod,1,1))
	if((self.AmmoType=="AAmissile")or(self.AmmoType=="ATrocket"))then self:ManipulateBoneScale(4,Vector(.01,.01,.01)) end
	self:SetNetworkedInt("JackIndex",self:EntIndex())
	self:SetDTBool(0,self.HasAmmoBox)
	self:SetDTInt(3,0)
	self.IFFTags={}
	PrecacheParticleSystem(self.MuzzEff)
end
function ENT:GetShootPos()
	return self:GetPos()+self:GetUp()*55+self:GetForward()*5
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		if(IsValid(self.Entity))then self.Entity:EmitSound("Canister.ImpactHard") end
	end
	if(data.Speed>750)then
		self.StructuralIntegrity=self.StructuralIntegrity-data.Speed/10
		if(self.StructuralIntegrity<=0)then
			self:Break()
		end
	end
	if(data.Speed<20)then
		if(self:GetDTInt(0)==TS_IDLING)then self:Notice() end
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
	if((dmginfo:IsDamageType(DMG_BUCKSHOT))or(dmginfo:IsDamageType(DMG_BULLET))or(dmginfo:IsDamageType(DMG_BLAST))or(dmginfo:IsDamageType(DMG_CLUB)))then
		self.StructuralIntegrity=self.StructuralIntegrity-dmginfo:GetDamage()
		if(self.StructuralIntegrity<=0)then
			self:Break()
		else
			if(self:GetDTInt(0)==TS_IDLING)then self:Notice() end
		end
	end
end
function ENT:Use(activator,caller)
	if(self.StructuralIntegrity<=0)then
		local Kit=self:FindRepairKit()
		if(IsValid(Kit))then self:Fix(Kit);JackaGenericUseEffect(activator) end
	end
	if(self.Broken)then return end
	if(activator==self.CurrentTarget)then self:EmitSound("snd_jack_denied.wav",75,100) return end -- lol dude
	if(self.IsLocked)then self:EmitSound("snd_jack_denied.wav",75,100) return end
	if not(self.MenuOpen)then
		self:SetOwner(activator)
		local Tag=activator:GetNetworkedInt("JackyIFFTag")
		self:EmitSound("snd_jack_uisuccess.wav",65,100)
		self.MenuOpen=true
		umsg.Start("JackaTurretOpenMenu",activator)
		umsg.Entity(self)
		self.TargetingGroup=self.TargetingGroup or {4}
		umsg.Short(self.BatteryCharge)
		umsg.Short(self.RoundsOnBelt)
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_TINY))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_TINY_CENTERED))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_SMALL_CENTERED))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_HUMAN))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_WIDE_SHORT))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_WIDE_HUMAN))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_MEDIUM))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_MEDIUM_TALL))	 
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_LARGE))
		umsg.Bool(table.HasValue(self.TargetingGroup,HULL_LARGE_CENTERED))
		umsg.Bool(self.TargetSynthetics)
		//umsg.Bool(((Tag)and(Tag!=0)))
		umsg.Bool(table.HasValue(self.IFFTags,Tag))
		umsg.Bool(self.WillWarn)
		umsg.Bool(self.TargetOrganics)
		umsg.Bool(self.WillLight)
		umsg.End()
	end
end
function ENT:TakeNegativeInputs(key)
	if(self.Broken)then return end
	if(self:GetDTInt(0)==TS_NOTHING)then return end
	local Time=CurTime()
	if(key==IN_ATTACK2)then
		self.ControllingPly:SetFOV(90,.1)
		for i=0,10 do self:EmitSound("snd_jack_turretservo.wav",70,70+i) end
	end
end
function ENT:TakeInputs(key)
	if(self.Broken)then return end
	local Time=CurTime()
	if(key==IN_JUMP)then
		JackaSentryControlWipe(self.ControllingPly,self.ControllingTerminal,self)
		return
	end
	if(self:GetDTInt(0)==TS_NOTHING)then return end
	if(key==IN_RELOAD)then
		self.NextGunChangeTime=Time+.5
		if(self.WeaponOut)then
			self:StandBy()
		else
			self:Alert()
		end
	elseif(key==IN_ATTACK)then
		if(self.WeaponOut)then
			if(self.NextShotTime<Time)then
				self:FireShot()
				self.NextShotTime=Time+(1/self.FireRate)
			end
		else
			if(self.NextWarnTime<Time)then
				self:HostileAlert()
				self.NextWarnTime=Time+1
			end
		end
	elseif(key==IN_ATTACK2)then
		self.ControllingPly:SetFOV(4,.1)
		for i=0,10 do self:EmitSound("snd_jack_turretservo.wav",70,70+i) end
	elseif(key==IN_USE)then
		local Mode=self:GetDTInt(3)
		if(Mode==2)then Mode=-1 end
		self:SetDTInt(3,Mode+1)
		if(Mode+1==0)then
			self:EmitSound("snd_jack_displaysoff.wav",70,100)
		else
			self:EmitSound("snd_jack_displayson.wav",70,100)
		end
	end
end
function ENT:Think()
	self.Heat=self.Heat-.04
	if(self.Heat<0)then
		self.Heat=0
	elseif(self.Heat>=50)then
		local PosAng=self:GetAttachment(1)
		local Sss=EffectData()
		Sss:SetOrigin(PosAng.Pos+PosAng.Ang:Forward()*math.random(-7,7))
		Sss:SetScale(self.Heat/50)
		util.Effect("eff_jack_gunoverheat",Sss,true,true)
	end
	if(self.Broken)then
		self.BatteryCharge=0
		self:SetDTInt(2,0)
		if(math.random(1,2)==1)then
			local effectdata=EffectData()
			effectdata:SetOrigin(self:GetPos()+self:GetUp()*math.random(30,55))
			effectdata:SetNormal(VectorRand())
			effectdata:SetMagnitude(3) --amount and shoot hardness
			effectdata:SetScale(1) --length of strands
			effectdata:SetRadius(3) --thickness of strands
			util.Effect("Sparks",effectdata,true,true)
			self:EmitSound("snd_jack_turretfizzle.wav",70,100)
		else
			local effectdata=EffectData()
			effectdata:SetOrigin(self:GetShootPos())
			effectdata:SetScale(1)
			util.Effect("eff_jack_tinyturretburn",effectdata,true,true)
		end
		return
	end
	local State=self:GetDTInt(0)
	if(State==TS_NOTHING)then return end
	if(self.MenuOpen)then return end
	local SelfPos=self:GetShootPos()
	local Time=CurTime()
	local Angs=self:GetAngles()
	local WeAreClear=self:ClearHead()
	self:SetDTInt(4,self.RoundsOnBelt)
	if(self.BatteryCharge<=0)then
		self:HardShutDown()
		return
	elseif(self.BatteryCharge<self.MaxCharge*.2)then
		if(self.NextBatteryAlertTime<Time)then
			self:Whine()
			self.NextBatteryAlertTime=Time+4.75
		end
	end
	if((self.ControllingPly)and(IsValid(self.ControllingPly)))then
		self:SetDTInt(0,TS_IDLING)
		self.BatteryCharge=self.BatteryCharge-.02
		self:SetDTInt(2,math.Round((self.BatteryCharge/self.MaxCharge)*100))
		local Fast=self.ControllingPly:KeyDown(IN_SPEED)
		local Slow=self.ControllingPly:KeyDown(IN_ATTACK2)
		if(self.ControllingPly:KeyDown(IN_MOVERIGHT))then
			self:TraverseManually(2,0,Fast,Slow)
		elseif(self.ControllingPly:KeyDown(IN_MOVELEFT))then
			self:TraverseManually(-2,0,Fast,Slow)
		end
		if(self.ControllingPly:KeyDown(IN_FORWARD))then
			self:TraverseManually(0,2,Fast,Slow)
		elseif(self.ControllingPly:KeyDown(IN_BACK))then
			self:TraverseManually(0,-2,Fast,Slow)
		end
		if not(WeAreClear)then
			JackaSentryControlWipe(self.ControllingPly,self.ControllingTerminal,self)
		end
		if((self.NextShotTime<Time)and(self.WeaponOut))then
			if((self.Automatic)and(self.ControllingPly:KeyDown(IN_ATTACK)))then
				self:FireShot()
				self.NextShotTime=Time+(1/self.FireRate)*math.Rand(.9,1.1)
			end
		end
		self:NextThink(CurTime()+.05)
		return true
	end
	if not(State==TS_WHINING)then
		if not(WeAreClear)then
			self:SetDTInt(0,TS_WHINING)
			State=TS_WHINING
		end
	end
	if(State==TS_IDLING)then
		if(self.NextWatchTime<Time)then
			for key,potential in pairs(ents.FindInSphere(SelfPos,self.MaxTrackRange))do
				if(GetVolyum(potential)>0)then
					if(self:MotionCheck(potential))then
						if(self:CanSee(potential))then
							local TrueVec=(SelfPos-potential:GetPos()):GetNormalized()
							local LookVec=self:GetForward()
							local DotProduct=LookVec:DotProduct(TrueVec)
							local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
							if(ApproachAngle>90)then
								self:Notice()
							end
						end
					end
				end
			end
			self.BatteryCharge=self.BatteryCharge-.01
			self.NextWatchTime=self.NextWatchTime+.2
		end
	elseif(State==TS_WATCHING)then
		if(self.NextScanTime<Time)then
			self.CurrentTarget=self:ScanForTarget()
			self.NextScanTime=Time+(1/self.ScanRate)
			if(IsValid(self.CurrentTarget))then
				self:Alert(self.CurrentTarget)
			end
		elseif(self.NextGoSilentTime<Time)then
			self:StandDown()
		end
		self.BatteryCharge=self.BatteryCharge-.2
	elseif(State==TS_CONCENTRATING)then
		if(self.NextScanTime<Time)then
			self.CurrentTarget=self:ScanForTarget()
			self.NextScanTime=Time+(1/self.ScanRate)
			if(IsValid(self.CurrentTarget))then
				self:Alert(self.CurrentTarget)
			end
		elseif(self.NextGoSilentTime<Time)then
			self:StandDown()
		end
		self.BatteryCharge=self.BatteryCharge-.1
	elseif(State==TS_TRACKING)then
		if not(IsValid(self.CurrentTarget))then
			self:SetDTInt(0,TS_CONCENTRATING)
			self.NextGoSilentTime=Time+2
		else
			if(self:CanSee(self.CurrentTarget))then
				local TargPos=GetCenterMass(self.CurrentTarget)
				local Ang=(TargPos-SelfPos):GetNormalized():Angle()
				local TargAng=self:WorldToLocalAngles(Ang)
				local ProperSweep=TargAng.y
				local ProperSwing=TargAng.p
				if(((TargAng.y>-90)and(TargAng.y<90))and((TargAng.p>-90)and(TargAng.p<90)))then
					self.GoalSweep=ProperSweep
					self.GoalSwing=ProperSwing
				else
					self.CurrentTarget=self:ScanForTarget()
				end
				if(self.NextScanTime<Time)then
					local OldTarget=self.CurrentTarget
					self.CurrentTarget=self:ScanForTarget()
					if(not(IsValid(self.CurrentTarget)))then
						self:StandDown()
					end
					--[[
					if(OldTarget==self.CurrentTarget)then
						local TargVel=self.CurrentTarget:GetPhysicsObject():GetVelocity()
						local MyVel=self:GetPhysicsObject():GetVelocity()
						if((TargVel-MyVel):Length()<30)then
							self:HoldFire()
						end
					end
					--]]
					self.NextScanTime=Time+(1/self.ScanRate)*2
				end
				if((self.CurrentSweep<(self.GoalSweep+4))and(self.CurrentSweep>(self.GoalSweep-4))and(self.CurrentSwing<(self.GoalSwing+4))and(self.CurrentSwing>(self.GoalSwing-4)))then
					if(self.NextShotTime<Time)then
						self:FireShot()
						self.NextShotTime=Time+(1/self.FireRate)*math.Rand(.9,1.1)
					end
				end
			else
				self:HoldFire()
			end
		end
	elseif(State==TS_WHINING)then
		if(WeAreClear)then
			self:SetDTInt(0,TS_IDLING)
			self.GoalSweep=0
			self.GoalSwing=0
		else
			if(self.NextWhineTime<Time)then
				self:Whine()
				self.NextWhineTime=Time+.85
				if(math.random(1,5)==4)then self:HardShutDown() end
			end
		end
	elseif(State==TS_ASLEEPING)then
		if((self.CurrentSweep<=2)and(self.CurrentSwing<=2))then
			self:StandBy()
		else
			if(self.NextScanTime<Time)then
				self:SetDTInt(0,TS_WATCHING)
				self.NextScanTime=Time+(1/self.TrackRate)*1.5
			end
		end
	end
	self:SetDTInt(2,math.Round((self.BatteryCharge/self.MaxCharge)*100))
	self:Traverse()
	self:NextThink(CurTime()+.1)
	return true
end
function ENT:OnRemove()
	if(self.ControllingPly)then
		JackaSentryControlWipe(self.ControllingPly,self.ControllingTerminal,self)
	end
	SafeRemoveEntity(self.flashlight)
	self:SetDTBool(3,false)
end
function ENT:ClearHead()
	if(math.random(1,10)==5)then
		local Hits=0
		for i=0,20 do
			local Tr=util.QuickTrace(self:GetShootPos(),VectorRand()*20,{self})
			if((Tr.Hit)and not((Tr.Entity:IsPlayer())or(Tr.Entity:IsNPC())))then
				Hits=Hits+1
			end
		end
		return (Hits<7)
	else
		return true
	end
end
function ENT:ScanForTarget()
	local SelfPos=self:GetShootPos()
	local Closest=self.MaxTrackRange
	local Owner=self:GetOwner() or self
	local BestCandidate=nil
	for key,potential in pairs(ents.FindInSphere(SelfPos,self.MaxTrackRange))do
		local Size=GetVolyum(potential)
		if((Size>0)and(self:WillTargetThisSize(Size)))then
			if((not(potential==self))and(not(potential:IsWorld()))and(self:CanSee(potential)))then
				local Synth=IsSynthetic(potential)
				if(((Synth)and(self.TargetSynthetics))or((!Synth)and(self.TargetOrganics)))then
					local TargPos=potential:GetPos()
					local Ang=(TargPos-SelfPos):GetNormalized():Angle()
					local TargAng=self:WorldToLocalAngles(Ang)
					if(((TargAng.y>-90)and(TargAng.y<90))and((TargAng.p>-90)and(TargAng.p<90)))then
						local Dist=(TargPos-SelfPos):Length()
						if((Dist<Closest)and not(potential==Owner))then
							if(Synth)then
								if(self:MotionCheck(potential))then
									BestCandidate=potential
									Closest=Dist
								end
							elseif(string.find(potential:GetClass(),"ragdoll"))then
								if(self:MotionCheck(potential))then
									BestCandidate=potential
									Closest=Dist
								end
							elseif(potential:IsPlayer())then
								local Tag=potential:GetNetworkedInt("JackyIFFTag")
								if((Tag)and(Tag!=0))then
									if(table.HasValue(self.IFFTags,Tag))then
										if(math.random(1,3)==2)then self:FriendlyAlert() end
									else
										BestCandidate=potential
										Closest=Dist
									end
								else
									BestCandidate=potential
									Closest=Dist
								end
							else
								BestCandidate=potential
								Closest=Dist
							end
						end
					end
				end
			end
		end
	end
	self.BatteryCharge=self.BatteryCharge-(self.MaxTrackRange/2000)
	if(BestCandidate)then
		if((BestCandidate==self.CurrentTarget)and(self.FiredAtCurrentTarget)and not(self:MotionCheck(BestCandidate)))then
			return nil
		elseif(BestCandidate!=self.CurrentTarget)then
			self.FiredAtCurrentTarget=false
		end
		if(BestCandidate:IsPlayer())then
			local Tag=BestCandidate:GetNetworkedInt("JackyIFFTag")
			if((Tag)and(Tag!=0))then
				if(table.HasValue(self.IFFTags,Tag))then self:FriendlyAlert() return nil end
			end
		end
	end
	return BestCandidate
end
function ENT:MotionCheck(ent)
	local OtherVel
	local Phes=ent:GetPhysicsObject()
	if(IsValid(Phes))then
		OtherVel=Phes:GetVelocity()
	else
		OtherVel=ent:GetVelocity()
	end
	local Phys=self:GetPhysicsObject()
	local RelSpeed=(Phys:GetVelocity()-OtherVel):Length()
	return (RelSpeed>20)
end
function ENT:FriendlyAlert()
	if not(self.NextFriendlyTime<CurTime())then return end
	self.NextFriendlyTime=CurTime()+1
	local Flash=EffectData()
	Flash:SetOrigin(self:GetShootPos())
	Flash:SetScale(.7)
	util.Effect("eff_jack_cyanflash",Flash,true,true)
	self:EmitSound("snd_jack_turrethi.wav",80,100)
	self.BatteryCharge=self.BatteryCharge-.5
end
function ENT:HostileAlert()
	local Flash=EffectData()
	Flash:SetOrigin(self:GetShootPos())
	Flash:SetScale(1.3)
	util.Effect("eff_jack_redflash",Flash,true,true)
	self:EmitSound("snd_jack_turretwarn.wav",80,100)
	sound.Play("snd_jack_turretwarn.wav",self:GetPos(),80,100)
	self.BatteryCharge=self.BatteryCharge-.5
end
function ENT:HoldFire()
	self:SetDTInt(0,TS_CONCENTRATING)
	self.NextGoSilentTime=CurTime()+10
	self.CurrentTarget=nil
end
function ENT:StandDown()
	self.GoalSweep=0
	self.GoalSwing=0
	self.CurrentTarget=nil
	self:SetDTInt(0,TS_ASLEEPING)
end
function ENT:Notice()
	if(self:GetDTInt(0)==TS_WHINING)then return end
	self:SetDTInt(0,TS_WATCHING)
	self.NextGoSilentTime=CurTime()+5
	self.NextScanTime=CurTime()+(1/self.ScanRate)
	self:EmitSound("snd_jack_turretdetect.wav",90,100)
	self.BatteryCharge=self.BatteryCharge-.25
end
function ENT:Alert(targ)
	if not(self.WeaponOut)then
		self:SetDTInt(0,TS_AWAKENING)
		self:ResetSequence(4)
		self.WeaponOut=true
		if not((self.AmmoType=="AAmissile")or(self.AmmoType=="ATrocket"))then
			self:EmitSound("snd_jack_turretawaken.wav",70,100)
		end
		timer.Simple(.4/self.TrackRate,function()
			if((IsValid(self))and(IsValid(self.CurrentTarget)))then
				self:SetDTInt(0,TS_TRACKING)
				--self.NextScanTime=CurTime()+(1/self.ScanRate)*2
			elseif((IsValid(self))and not(self.ControllingPly))then
				self:StandBy()
			end
		end)
		self.NextAlrightFuckYouTime=CurTime()+5
		self.BatteryCharge=self.BatteryCharge-.5*self.MechanicsSizeMod
		if(self.WillLight)then
			self.flashlight=ents.Create("env_projectedtexture")
			self.flashlight:SetParent(self.Entity)
			-- The local positions are the offsets from parent..
			self.flashlight:SetLocalPos(Vector(0,0,50))
			self.flashlight:SetLocalAngles(Angle(0,0,0))
			-- Looks like only one flashlight can have shadows enabled!
			self.flashlight:SetKeyValue("enableshadows",1)
			self.flashlight:SetKeyValue("farz",1500)
			self.flashlight:SetKeyValue("nearz",30)
			self.flashlight:SetKeyValue("lightfov",30)
			self.flashlight:SetKeyValue("lightcolor","4080 4080 4080 255")
			self.flashlight:Spawn()
			self.flashlight:Input("SpotlightTexture",NULL,NULL,"effects/flashlight001")
			self:SetDTBool(3,true)
		end
	else
		self.BatteryCharge=self.BatteryCharge-.1
		self:SetDTInt(0,TS_TRACKING)
		if(targ)then self.CurrentTarget=targ end
	end
end
function ENT:Traverse()
	local PowerDrain=.2*self.TrackRate*self.MechanicsSizeMod^1.5
	local SweepDiff=self.GoalSweep-self.CurrentSweep
	if(SweepDiff~=0)then
		self.CurrentSweep=self.CurrentSweep+math.Clamp(SweepDiff,-self.TrackRate*4,self.TrackRate*4)
		self:EmitSound("snd_jack_turretservo.wav",66,90)
		self.BatteryCharge=self.BatteryCharge-PowerDrain
	end
	local SwingDiff=self.GoalSwing-self.CurrentSwing
	if(SwingDiff~=0)then
		self.CurrentSwing=self.CurrentSwing+math.Clamp(SwingDiff,-self.TrackRate*4,self.TrackRate*4)
		self:EmitSound("snd_jack_turretservo.wav",66,90)
		self.BatteryCharge=self.BatteryCharge-PowerDrain
	end
	self:SetDTInt(1,self.CurrentSweep)
	self:ManipulateBoneAngles(1,Angle(self.CurrentSweep,0,0))
	self:ManipulateBoneAngles(2,Angle(0,0,self.CurrentSwing))
	if(IsValid(self.flashlight))then
		self.flashlight:SetLocalAngles(self:WorldToLocalAngles(self:GetAttachment(1).Ang))
	end
end
function ENT:TraverseManually(horiz,vert,fast,slow)
	local PowerDrain=.2*self.TrackRate*self.MechanicsSizeMod^1.5
	local Mul=.5
	if(fast)then Mul=Mul*2 end
	if(slow)then Mul=Mul*.125 end
	if((horiz>0)and(self.CurrentSweep>-90))then
		self.CurrentSweep=self.CurrentSweep-self.TrackRate*Mul
		self:EmitSound("snd_jack_turretservo.wav",66,90+10*Mul)
		self.BatteryCharge=self.BatteryCharge-PowerDrain
	elseif((horiz<0)and(self.CurrentSweep<90))then
		self.CurrentSweep=self.CurrentSweep+self.TrackRate*Mul
		self:EmitSound("snd_jack_turretservo.wav",66,90+10*Mul)
		self.BatteryCharge=self.BatteryCharge-PowerDrain
	end
	if((vert>0)and(self.CurrentSwing>-90))then
		self.CurrentSwing=self.CurrentSwing-(self.TrackRate*.6667)*Mul
		self:EmitSound("snd_jack_turretservo.wav",66,100+10*Mul)
		self.BatteryCharge=self.BatteryCharge-PowerDrain
	elseif((vert<0)and(self.CurrentSwing<90))then
		self.CurrentSwing=self.CurrentSwing+(self.TrackRate*.6667)*Mul
		self:EmitSound("snd_jack_turretservo.wav",66,100+10*Mul)
		self.BatteryCharge=self.BatteryCharge-PowerDrain
	end
	self:SetDTInt(1,self.CurrentSweep)
	self:SetNetworkedFloat("CurrentSweep",self.CurrentSweep)
	self:SetNetworkedFloat("CurrentSwing",self.CurrentSwing)
	self:ManipulateBoneAngles(1,Angle(self.CurrentSweep,0,0))
	self:ManipulateBoneAngles(2,Angle(0,0,self.CurrentSwing))
	if(IsValid(self.flashlight))then
		self.flashlight:SetLocalAngles(self:WorldToLocalAngles(self:GetAttachment(1).Ang))
	end
end
function ENT:FireShot()
	if((not(IsValid(self.CurrentTarget)))and(not(self.ControllingPly)))then self:StandBy() return end
	local Time=CurTime()
	self.BatteryCharge=self.BatteryCharge-.1
	if((self.WillWarn)and not(self.ControllingPly))then
		if not(self.NextAlrightFuckYouTime<Time)then
			if(self.NextWarnTime<Time)then
				self:HostileAlert()
				self.NextWarnTime=Time+1
			end
			return
		end
	end
	if(self.RoundInChamber)then
		if(self.Heat>=95)then
			if(self.NextOverHeatWhineTime<Time)then
				self.NextOverHeatWhineTime=Time+.5
				self:Whine()
			end
			return
		end
		--self.Entity:ResetSequence(3) --prollem with this is the flash
		self:ManipulateBoneScale(3,Vector(self.BarrelSizeMod.x,self.BarrelSizeMod.y,self.BarrelSizeMod.z*.75))
		timer.Simple(.1,function()
			if(IsValid(self))then
				self:ManipulateBoneScale(3,self.BarrelSizeMod)
			end
		end)
		local SelfPos=self:GetShootPos()
		local TargPos
		if(self.ControllingPly)then
			local PosAng=self:GetAttachment(1)
			TargPos=SelfPos+PosAng.Ang:Forward()
		else
			TargPos=GetCenterMass(self.CurrentTarget)
		end
		local Dir=(TargPos-SelfPos):GetNormalized()
		local Spred=self.ShotSpread
		if not(self.ControllingPly)then
			local Phys=self.CurrentTarget:GetPhysicsObject()
			if(IsValid(Phys))then
				local RelSpeed=(Phys:GetVelocity()-self:GetPhysicsObject():GetVelocity()):Length()
				if not(self:GetClass()=="ent_jack_turret_shotty")then
					Spred=Spred+(RelSpeed/100000)
				end
			end
		else
			Spred=Spred*.4
		end
		local Bellit={
			Attacker=self:GetOwner() or self,
			Damage=self.ShotPower,
			Force=self.ShotPower/60,
			Num=self.ProjectilesPerShot,
			Tracer=0,
			Dir=Dir,
			Spread=Vector(Spred,Spred,Spred),
			Src=SelfPos
		}
		self:FireBullets(Bellit)
		self.FiredAtCurrentTarget=true
		self.RoundInChamber=false
		self.Heat=self.Heat+((self.ShotPower*self.ProjectilesPerShot)/150)
		local Scayul=1
		for i=0,1 do
			self:EmitSound(self.NearShotNoise,75,self.ShotPitch)
			self:EmitSound(self.FarShotNoise,90,self.ShotPitch-10)
			sound.Play(self.NearShotNoise,SelfPos,75,self.ShotPitch)
			sound.Play(self.FarShotNoise,SelfPos+Vector(0,0,1),90,self.ShotPitch-10)
			if not(self:GetClass()=="ent_jack_turret_plinker")then
				sound.Play(self.NearShotNoise,SelfPos,75,self.ShotPitch)
				sound.Play(self.FarShotNoise,SelfPos+Vector(0,0,1),110,self.ShotPitch-10)
			else
				Scayul=.5
			end
			if((self.AmmoType=="7.62x51mm")or(self.AmmoType==".338 Lapua Magnum"))then
				sound.Play(self.NearShotNoise,SelfPos+Vector(0,0,1),75,self.ShotPitch+10)
				if not(self:GetClass()=="ent_jack_turret_mg")then sound.Play(self.FarShotNoise,SelfPos+Vector(0,0,2),100,self.ShotPitch) end
				Scayul=1.5
			end
			if(self.AmmoType==".338 Lapua Magnum")then
				sound.Play(self.NearShotNoise,SelfPos+Vector(0,0,3),75,self.ShotPitch+10)
				sound.Play(self.FarShotNoise,SelfPos+Vector(0,0,4),100,self.ShotPitch+5)
				Scayul=2.5
			end
		end
		local PosAng=self:GetAttachment(1)
		local ThePos=PosAng.Pos+PosAng.Ang:Forward()*self.BarrelSizeMod.z*4
		if(math.random(1,2)==1)then
			ParticleEffect("muzzleflash_suppressed",ThePos,PosAng.Ang,self)
		else
			ParticleEffect(self.MuzzEff,ThePos,PosAng.Ang,self)
			local effectd=EffectData()
			effectd:SetStart(ThePos)
			effectd:SetNormal(PosAng.Ang:Forward())
			effectd:SetScale(1)
			util.Effect("eff_jack_turretmuzzlelight",effectd,true,true)
		end
		if(self.RoundsOnBelt>0)then
			if(self.Autoloading)then
				self.RoundsOnBelt=self.RoundsOnBelt-1
				self.RoundInChamber=true
				local effectdata=EffectData()
				effectdata:SetOrigin(SelfPos)
				effectdata:SetAngles(Dir:Angle():Right():Angle())
				effectdata:SetEntity(self)
				util.Effect(self.ShellEffect,effectdata,true,true)
			else
				timer.Simple((1/self.FireRate)*.25,function()
					if(IsValid(self))then
						self:EmitSound(self.CycleSound,68,100)
					end
				end)
				timer.Simple((1/self.FireRate)*.35,function()
					if(IsValid(self))then
						self.RoundsOnBelt=self.RoundsOnBelt-1
						self.RoundInChamber=true
						local effectdata=EffectData()
						effectdata:SetOrigin(SelfPos)
						effectdata:SetAngles(Dir:Angle():Right():Angle())
						effectdata:SetEntity(self)
						util.Effect(self.ShellEffect,effectdata,true,true)
					end
				end)
			end
		end
		self:GetPhysicsObject():ApplyForceOffset(-Dir*self.ShotPower*6*self.ProjectilesPerShot,SelfPos+self:GetUp()*30)
	else
		self:EmitSound("snd_jack_turretclick.wav",70,110)
		if(self.NextWhineTime<CurTime())then
			self:Whine()
			self.NextWhineTime=CurTime()+2.25
		end
	end
end
function ENT:Whine()
	self:EmitSound("snd_jack_turretwhine.wav",80,100)
	self.BatteryCharge=self.BatteryCharge-.05
end
function ENT:StandBy()
	self:SetDTInt(0,TS_IDLING)
	if(self.WeaponOut)then
		self:ResetSequence(0)
		if not((self.AmmoType=="AAmissile")or(self.AmmoType=="ATrocket"))then
			self:EmitSound("snd_jack_turretasleep.wav",70,100)
		end
		self.WeaponOut=false
		self.BatteryCharge=self.BatteryCharge-.5*self.MechanicsSizeMod
		SafeRemoveEntity(self.flashlight)
		self:SetDTBool(3,false)
	end
end
function ENT:CanSee(ent)
	local TrDat={}
	TrDat.start=self:GetShootPos()
	TrDat.endpos=ent:LocalToWorld(ent:OBBCenter())+Vector(0,0,5)
	TrDat.filter={self,ent}
	TrDat.mask=MASK_SHOT
	local Tr=util.TraceLine(TrDat)
	return !Tr.Hit
end
function ENT:HardShutDown()
	self:EmitSound("snd_jack_turretshutdown.wav",80,100)
	self:SetDTInt(0,TS_NOTHING)
	self:GetPhysicsObject():SetDamping(0,0)
	self.CurrentTarget=nil
	if(self.ControllingPly)then
		JackaSentryControlWipe(self.ControllingPly,self.ControllingTerminal,self)
	end
	SafeRemoveEntity(self.flashlight)
	self:SetDTBool(3,false)
end
function ENT:StartUp()
	if not(self.HasBattery)then return end
	if(self.BatteryCharge<=0)then return end
	self:EmitSound("snd_jack_turretstartup.wav",80,100)
	self:GetPhysicsObject():SetDamping(0,10)
	if(self.AmmoType=="AAmissile")then self.MissileLocked=false end
	self:Notice()
end
function ENT:FindAmmo()
	for key,potential in pairs(ents.FindInSphere(self:GetPos(),40))do
		if(potential:GetClass()==BOXES[self.AmmoType])then
			if not(potential.Empty)then
				return potential
			end
		end
	end
	return nil
end
function ENT:DetachAmmoBox()
	self.RoundsOnBelt=0
	self.HasAmmoBox=false
	self:SetDTBool(0,self.HasAmmoBox)
	local Box=ents.Create(BOXES[self.AmmoType])
	Box.AmmoType=self.AmmoType
	Box.Empty=true
	Box:SetPos(self:GetPos()-self:GetRight()*10+self:GetUp()*30)
	Box:SetAngles(self:GetRight():Angle())
	Box:Spawn()
	Box:Activate()
	self:EmitSound("snd_jack_turretammounload.wav")
	SafeRemoveEntityDelayed(Box,30)
end
function ENT:RefillAmmo(box)
	self.HasAmmoBox=true
	self:SetDTBool(0,self.HasAmmoBox)
	if(self.RoundInChamber)then
		self.RoundsOnBelt=box.NumberOfRounds
	else
		self.RoundInChamber=true
		self.RoundsOnBelt=box.NumberOfRounds-1
	end
	self:EmitSound("snd_jack_turretammoload.wav")
	SafeRemoveEntity(box)
end
function ENT:RefillPower(box)
	self.HasBattery=true
	self:SetDTBool(1,self.HasBattery)
	self.BatteryCharge=self.MaxCharge
	self:SetDTInt(2,math.Round((self.BatteryCharge/self.MaxCharge)*100))
	SafeRemoveEntity(box)
	self:SetDTBool(3,false)
	self:EmitSound("snd_jack_turretbatteryload.wav")
end
function ENT:DetachBattery()
	self.BatteryCharge=0
	self.HasBattery=false
	self:SetDTBool(1,self.HasBattery)
	local Box=ents.Create("ent_jack_turretbattery")
	Box.Dead=true
	Box:SetPos(self:GetPos()+self:GetRight()*10+self:GetUp()*10)
	Box:SetAngles(self:GetForward():Angle())
	Box:Spawn()
	Box:Activate()
	self:EmitSound("snd_jack_turretbatteryunload.wav")
end
function ENT:FindBattery()
	for key,potential in pairs(ents.FindInSphere(self:GetPos(),40))do
		if(potential:GetClass()=="ent_jack_turretbattery")then
			if not(potential.Dead)then
				return potential
			end
		end
	end
	return nil
end
function ENT:Break()
	if not(self.Broken)then
		self:EmitSound("snd_jack_turretbreak.wav")
		self.Broken=true
		self:SetDTInt(0,TS_NOTHING)
		self.IsLocked=false
		self.LockPass=""
		self.CurrentTarget=nil
		if(self.ControllingPly)then JackaSentryControlWipe(self.ControllingPly,self.ControllingTerminal,self) end
		SafeRemoveEntity(self.flashlight)
		self:SetDTBool(3,false)
	end
end
function ENT:Fix(kit)
	self.StructuralIntegrity=400
	self:EmitSound("snd_jack_turretrepair.wav",70,100)
	timer.Simple(3.25,function()
		if(IsValid(self))then
			self.Broken=false
			self:RemoveAllDecals()
		end
	end)
	local Empty=ents.Create("prop_ragdoll")
	Empty:SetModel("models/props_junk/cardboard_box003a_gib01.mdl")
	Empty:SetMaterial("models/mat_jack_turretrepairkit")
	Empty:SetPos(kit:GetPos())
	Empty:SetAngles(kit:GetAngles())
	Empty:Spawn()
	Empty:Activate()
	Empty:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	Empty:GetPhysicsObject():ApplyForceCenter(Vector(0,0,1000))
	Empty:GetPhysicsObject():AddAngleVelocity(VectorRand()*1000)
	SafeRemoveEntityDelayed(Empty,20)
	SafeRemoveEntity(kit)
end
function ENT:FindRepairKit()
	for key,potential in pairs(ents.FindInSphere(self:GetPos(),40))do 
		if(potential:GetClass()=="ent_jack_turretrepairkit")then
			return potential
		end
	end
	return nil
end
--[[--------------------------------------------------------------
--					Chat mothafucka						   --
--------------------------------------------------------------]]--
local function SentryChat(ply,txt)
	local Found=false
	if(string.sub(txt,1,12)=="sentry lock ")then
		for key,sent in pairs(ents.FindInSphere(ply:GetPos(),150))do
			if(string.find(sent:GetClass(),"ent_jack_turret_"))then
				local Pass=string.Split(txt," ")[3]
				if((Pass)and(not(sent.IsLocked))and(sent.BatteryCharge>0))then
					Found=true
					sent.IsLocked=true
					sent.LockPass=Pass
					ply:PrintMessage(HUD_PRINTTALK,"Sentry "..tostring(sent:EntIndex()).." locked with password "..Pass)
				end
			end
		end
	elseif(string.sub(txt,1,14)=="sentry unlock ")then
		for key,sent in pairs(ents.FindInSphere(ply:GetPos(),150))do
			if(string.find(sent:GetClass(),"ent_jack_turret_"))then
				local Pass=string.Split(txt," ")[3]
				if((Pass)and(sent.IsLocked)and(Pass==sent.LockPass)and(sent.BatteryCharge>0))then
					Found=true
					sent.IsLocked=false
					sent.LockPass=""
					ply:PrintMessage(HUD_PRINTTALK,"Sentry "..tostring(sent:EntIndex()).." unlocked")
					sent:EmitSound("snd_jack_granted.wav",75,100)
				end
			end
		end
	end
	if(Found)then return "" end
end
hook.Add("PlayerSay","JackaSentryChat",SentryChat)
--[[--------------------------------------------------------------
	UI hooks for controlling
--------------------------------------------------------------]]--
local function CloseOn(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	self:EmitSound("snd_jack_uiselect.wav",65,100)
	self.MenuOpen=false
	if(self:GetDTInt(0)==TS_NOTHING)then
		if(self.StartUp)then
			self:StartUp()
			JackaGenericUseEffect(args[1])
		end
	end
end
concommand.Add("JackaTurretCloseMenu_On",CloseOn)
local function CloseOff(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	self:EmitSound("snd_jack_uiselect.wav",65,100)
	self.MenuOpen=false
	if not(self:GetDTInt(0)==TS_NOTHING)then
		self:HardShutDown()
		JackaGenericUseEffect(args[1])
	end
end
concommand.Add("JackaTurretCloseMenu_Off",CloseOff)
local function CloseCancel(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	self:EmitSound("snd_jack_uiselect.wav",65,100)
	self.MenuOpen=false
end
concommand.Add("JackaTurretCloseMenu_Cancel",CloseCancel)
local function Ammo(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	if((self.AmmoType=="AAmissile")or(self.AmmoType=="ATrocket"))then
		if not(self.RoundInChamber)then
			if not(self.HasAmmoBox)then
				local Tube=self:FindAmmo()
				if(IsValid(Tube))then
					self:RefillAmmo(Tube)
				else
					args[1]:PrintMessage(HUD_PRINTCENTER,"No munition present.")
				end
			else
				self:DetachAmmoBox()
				JackaGenericUseEffect(args[1])
			end
		else
			args[1]:PrintMessage(HUD_PRINTCENTER,"Current tube not empty.")
		end
	else
		if not(self.RoundsOnBelt)then self.RoundsOnBelt=0 end
		if(self.RoundsOnBelt<=0)then
			if not(self.HasAmmoBox)then
				local Box=self:FindAmmo()
				if(IsValid(Box))then
					self:RefillAmmo(Box)
					JackaGenericUseEffect(args[1])
				else
					args[1]:PrintMessage(HUD_PRINTCENTER,"No ammunition present.")
				end
			else
				self:DetachAmmoBox()
				JackaGenericUseEffect(args[1])
			end
		else
			args[1]:PrintMessage(HUD_PRINTCENTER,"Current box not empty.")
		end
	end
	self.MenuOpen=false
end
concommand.Add("JackaTurretAmmo",Ammo)
local function TargetingGroup(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	local Check=tobool(args[3][3])
	local Num=tonumber(args[3][2])
	if(Check)then
		table.ForceInsert(self.TargetingGroup,Num)
	else
		table.remove(self.TargetingGroup,table.KeyFromValue(self.TargetingGroup,Num))
	end
	self:EmitSound("snd_jack_uiselect.wav",65,100)
end
concommand.Add("JackaTurretTargetingChange",TargetingGroup)
local function TargetingGroupType(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	local Check=tobool(args[3][3])
	local Type=args[3][2]
	self[Type]=Check
	self:EmitSound("snd_jack_uiselect.wav",65,100)
end
concommand.Add("JackaTurretTargetingTypeChange",TargetingGroupType)
local function IFFTag(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	local ply=args[1]
	self:EmitSound("snd_jack_uiselect.wav",65,100)
	self.MenuOpen=false
	local Tag=ply:GetNetworkedInt("JackyIFFTag")
	if((Tag)and(Tag!=0))then
		if not(table.HasValue(self.IFFTags,Tag))then
			if not(Tag==0)then table.ForceInsert(self.IFFTags,Tag) end
			ply:PrintMessage(HUD_PRINTTALK,"Personal IFF tag ID recorded.")
		else
			table.remove(self.IFFTags,table.KeyFromValue(self.IFFTags,Tag))
			ply:PrintMessage(HUD_PRINTTALK,"Personal IFF tag ID forgotten.")
		end
	else
		ply:PrintMessage(HUD_PRINTCENTER,"You don't have an IFF tag equipped.")
	end
	umsg.Start("JackyIFFList")
	umsg.Entity(self)
	local lisd=""
	for key,tag in pairs(self.IFFTags)do
		lisd=lisd.." "..tostring(tag)
	end
	umsg.String(lisd)
	umsg.End()
end
concommand.Add("JackaTurretIFF",IFFTag)
local function Warn(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	local Check=tobool(args[3][2])
	self.WillWarn=Check
	self:EmitSound("snd_jack_uiselect.wav",65,100)
end
concommand.Add("JackaTurretWarn",Warn)
local function Light(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	local Check=tobool(args[3][2])
	self.WillLight=Check
	self:EmitSound("snd_jack_uiselect.wav",65,100)
end
concommand.Add("JackaTurretLight",Light)
local function Battery(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	if not(self.BatteryCharge)then self.BatteryCharge=0 end
	if(self.BatteryCharge<=0)then
		if not(self.HasBattery)then
			local Box=self:FindBattery()
			if(IsValid(Box))then
				self:RefillPower(Box)
				JackaGenericUseEffect(args[1])
			else
				args[1]:PrintMessage(HUD_PRINTCENTER,"No battery present.")
			end
		else
			self:DetachBattery()
			JackaGenericUseEffect(args[1])
		end
	else
		args[1]:PrintMessage(HUD_PRINTCENTER,"Current battery not dead.")
	end
	self.MenuOpen=false
end
concommand.Add("JackaTurretBattery",Battery)
local function Upright(...)
	local args={...}
	local ply=args[1]
	local self=Entity(tonumber(args[3][1]))
	local AimVec=ply:GetAimVector()
	local Trace=util.QuickTrace(ply:GetShootPos(),AimVec*150,{self,ply})
	if(Trace.Hit)then
		self:SetPos(Trace.HitPos+Trace.HitNormal*3)
		local Ang=AimVec:Angle()
		local AngDiff=AimVec:AngleEx(Trace.HitNormal)
		Ang:RotateAroundAxis(Ang:Right(),AngDiff.p)
		self:SetAngles(Ang)
		self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav",70,80)
		JackaGenericUseEffect(ply)
		self:GetPhysicsObject():ApplyForceCenter(VectorRand())
	end
	self.MenuOpen=false
end
concommand.Add("JackaTurretUpright",Upright)
