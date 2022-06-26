-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, AdventureBoots"
ENT.Category="JMod - EZ Explosives"
ENT.Information="The base for all of the other ez bombs"
ENT.PrintName="EZ Base Bomb"
ENT.Spawnable=false
ENT.AdminSpawnable=true
---
ENT.Model="models/hunter/blocks/cube025x2x025.mdl"
ENT.Material=nil
ENT.ModelScale=0.9
ENT.Mass=150
---
ENT.ClientMdl="models/jmod/mk82_gbu.mdl"
---
ENT.JModPreferredCarryAngles=Angle(0, -90, 0)
ENT.EZguidable=true
ENT.DetType="impact"
ENT.DetDistance=0
ENT.FreefallTicks=0
ENT.ExplosionPower=150
ENT.DragMultiplier=4
ENT.DroppableImmuneTime=0
ENT.ExplProof=false
---
hook.Add("EntityTakeDamage", "DroppedBombImunnity", function(target, dmginfo)
	if (IsValid(target) and target.ExplProof == true and dmginfo:GetAttacker() == target.Owner) then
		dmginfo:SetDamage(0)
		dmginfo:SetDamageForce(Vector(0, 0, 0))
	end
end)
concommand.Add("jbomb_nam_style",function(ply, cmd, args)
	local Drop=function(targetPos, flyVector, caller)
		local BombVel=flyVector*1000
		for i=-4,4 do
			timer.Simple(i/2+5, function()
				local Time=CurTime()
				local DropPos=targetPos+flyVector*i*400-flyVector*3000
				local Bom=ents.Create("ent_jack_gmod_base_ezbomb")
				--local Bom=ents.Create("ent_jack_gmod_ezsmallbomb")
				JMod.Owner(Bom, caller)
				Bom.DroppableImmuneTime=Time+1000
				Bom:SetPos(DropPos)
				Bom:Spawn()
				Bom:Activate()
				Bom:SetState(1)
				Bom:GetPhysicsObject():SetVelocity(BombVel)
			end)
		end
	end
	---- haaaaaaaaaaaaaaaaaaaaaaaaa -----
	local FlyVec=VectorRand()
	FlyVec.z=0
	FlyVec:Normalize()
	Drop(ply:GetPos()+Vector(0,0,3000),FlyVec, ply)
end)

local STATE_BROKEN, STATE_OFF, STATE_ARMED=-1, 0, 1
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	if (self.EZguidable) then
		self:NetworkVar("Bool", 0, "Guided")
	end
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(180, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel(self.Model)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(self.Mass)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		self:SetState(STATE_OFF)
		self.LastUse=0
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates the bomb", "Arms bomb when > 0"})
			self.Outputs=WireLib.CreateOutputs(self, {"State", "Guided"}, {"-1 broken \n 0 off \n 1 armed", "True when guided"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if(iname == "Detonate" and value > 0) then
			self:Detonate()
		elseif (iname == "Arm" and value > 0) then
			self:SetState(STATE_ARMED)
		elseif (iname == "Arm" and value == 0) then
			self:SetState(STATE_OFF)
		end
	end
	function ENT:PhysicsCollide(data, physobj)
		if not(IsValid(self))then return end
		if(data.DeltaTime > 0.2)then
			if(data.Speed > 50)then
				self:EmitSound("Canister.ImpactHard")
			end
			if((self.DetType == "impact") and (data.Speed > 700) and (self:GetState() == STATE_ARMED))then
				self:Detonate()
				return
			end
			if(data.Speed > 2000)then
				self:Break()
			end
		end
	end
	function ENT:Break()
		if(self:GetState() == STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))
		for i= 1, 20 do
			self:DamageSpark()
		end
		SafeRemoveEntityDelayed(self, 10)
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*10+VectorRand()*math.random(0, 10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5, 1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
		self:EmitSound("snd_jack_turretfizzle.wav", 70, 100)
	end
	function ENT:OnTakeDamage(dmginfo)
		if (self.Exploded) then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		if(JMod.LinCh(dmginfo:GetDamage(), 70, 150))then
			JMod.Owner(self, dmginfo:GetAttacker())
			self:Detonate()
		end
	end
	function ENT:Use(activator)
		local State, Time=self:GetState(), CurTime()
		if(State < 0)then return end
		
		if(State == STATE_OFF)then
			JMod.Owner(self, activator)
			if(Time-self.LastUse < 0.2)then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav", 70, 110)
				self.EZdroppableBombArmedTime=CurTime()
				if (self.DetType == "impact") then
					JMod.Hint(activator, "impactdet")
				elseif (self.DetType == "airburst") then
					JMod.Hint(activator, "airburst")
				end
			else
				JMod.Hint(activator,"double tap to arm")
			end
			self.LastUse=Time
		elseif(State == STATE_ARMED)then
			JMod.Owner(self,activator)
			if(Time-self.LastUse < .2)then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav", 70, 110)
				self.EZdroppableBombArmedTime=nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end
			self.LastUse=Time
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos, Att, Mag=self:GetPos()+Vector(0,0,60),self.Owner or game.GetWorld(), self.ExplosionPower
		--JMod.Sploom(Att, SelfPos, Mag)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 4000)
		local Eff="500lb_ground"
		if not(util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld)then Eff="500lb_air" end
		for i=1,3 do
			sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,160,math.random(80,110))
		end
		---
		for k,ply in pairs(player.GetAll())do
			local Dist=ply:GetPos():Distance(SelfPos)
			if((Dist>250)and(Dist<4000))then
				timer.Simple(Dist/6000,function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.wav",55,110)
					sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",ply:GetPos(),60,70)
					util.ScreenShake(ply:GetPos(),1000,3,1,100)
				end)
			end
		end
		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos+Vector(0,0,300), 1125, 120)
		timer.Simple(.25,function() util.BlastDamage(game.GetWorld(), Att, SelfPos, 2250, 120) end)
		for k,ent in pairs(ents.FindInSphere(SelfPos, 500))do
			if(ent:GetClass() == "npc_helicopter")then ent:Fire("selfdestruct", "", math.Rand(0,2)) end
		end
		---
		JMod.WreckBuildings(self, SelfPos, 7)
		JMod.BlastDoors(self, SelfPos, 7)
		---
		timer.Simple(.2,function()
			local Tr=util.QuickTrace(SelfPos+Vector(0, 0, 100), Vector(0, 0, -400))
			if(Tr.Hit)then util.Decal("BigScorch", Tr.HitPos+Tr.HitNormal, Tr.HitPos-Tr.HitNormal) end
		end)
		---
		JMod.FragSplosion(self, SelfPos, 15000, 300, 8000, self.Owner or game.GetWorld())
		---
		self:Remove()
		timer.Simple(.1,function() ParticleEffect(Eff, SelfPos, Angle(0,0,0)) end)
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
		if (self.DroppableImmuneTime > CurTime()) then
			self.ExplProof=true
		else
			self.ExplProof=false
		end
		if (istable(WireLib)) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			if (self.EZguidable) then
				WireLib.TriggerOutput(self, "Guided", self:GetGuided())
			end
		end
		local Phys,UseAeroDrag=self:GetPhysicsObject(),true
		if (self.DetType == "airburst") then
			if((self:GetState()==STATE_ARMED)and(Phys:GetVelocity():Length()>self.DetDistance)and not(self:IsPlayerHolding())and not(constraint.HasConstraints(self)))then
				self.FreefallTicks=self.FreefallTicks+1
				if(self.FreefallTicks >= 10)then
					local Tr=util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized()*1500, self)
					if(Tr.Hit)then self:Detonate() end
				end
			else
				self.FreefallTicks=0
			end
		end
		--if((self:GetState()==STATE_ARMED)and(self:GetGuided())and not(constraint.HasConstraints(self)))then
			--for k,designator in pairs(ents.FindByClass("wep_jack_gmod_ezdesignator"))do
				--if((designator:GetLasing())and(designator.Owner)and(JMod.ShouldAllowControl(self,designator.Owner)))then
					--[[
					local TargPos,SelfPos=ents.FindByClass("npc_*")[1]:GetPos(),self:GetPos()--designator.Owner:GetEyeTrace().HitPos
					local TargVec=TargPos-SelfPos
					local Dist,Dir,Vel=TargVec:Length(),TargVec:GetNormalized(),Phys:GetVelocity()
					local Speed=Vel:Length()
					if(Speed<=0)then return end
					local ETA=Dist/Speed
					jprint(ETA)
					TargPos=TargPos--Vel*ETA/2
					JMod.Sploom(self,TargPos,1)
					JMod.AeroGuide(self,-self:GetRight(),TargPos,1,1,.2,10)
					--]]
				--end
			--end
		--end
		JMod.AeroDrag(self, -self:GetRight(), self.DragMultiplier)
		self:NextThink(CurTime()+.1)
		if (self:CustomThink() == true) then self:CustomThink() end
		return true
	end
	function ENT:CustomThink() 
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		if (self.ClientMdl) then
			self.Mdl=ClientsideModel(self.ClientMdl)
			self.Mdl:SetModelScale(self.ModelScale, 0)
			self.Mdl:SetPos(self:GetPos())
			self.Mdl:SetParent(self)
			self.Mdl:SetNoDraw(true)
			self.Guided=false
		end
	end
	function ENT:Think()
		if (self.EZguidable) then
			if((not(self.Guided))and(self:GetGuided()))then
				self.Guided=true
				self.ClientMdl:SetBodygroup(0, 1)
			end
		end
	end
	function ENT:Draw()
		if (self.ClientMdl) then
			local Pos, Ang=self:GetPos(), self:GetAngles()
			Ang:RotateAroundAxis(Ang:Up(), 90)
			--self:DrawModel()
			self.Mdl:SetRenderOrigin(Pos-Ang:Up()*3-Ang:Right()*6)
			self.Mdl:SetRenderAngles(Ang)
			self.Mdl:DrawModel()
		else return end
	end
	language.Add("ent_jack_gmod_base_ezbomb","EZ Bomb Base")
end