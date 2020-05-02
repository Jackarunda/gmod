-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Thermobaric Bomb"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_phx/ww2bomb.mdl")
		self.Entity:SetMaterial("models/entities/mat_jack_faebomb")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
			self:GetPhysicsObject():SetDamping(0,0)
		end)
		---
		self:SetState(STATE_OFF)
		self.LastUse=0
		self.FreefallTicks=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.DeltaTime>0.2)then
			if(data.Speed>50)then
				self:EmitSound("Canister.ImpactHard")
			end
			local DetSpd=500
			if((data.Speed>DetSpd)and(self:GetState()==STATE_ARMED))then
				self:Detonate()
				return
			end
			if(data.Speed>2000)then
				self:Break()
			end
		end
	end
	function ENT:Break()
		if(self:GetState()==STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do
			self:DamageSpark()
		end
		SafeRemoveEntityDelayed(self,10)
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*10+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=100)then
			if(math.random(1,20)==1)then
				self:Break()
			elseif(dmginfo:IsDamageType(DMG_BLAST))then
				JMod_Owner(self,dmginfo:GetAttacker())
				self:Detonate()
			end
		end
	end
	function ENT:Use(activator)
		local State,Time=self:GetState(),CurTime()
		if(State<0)then return end
		
		if(State==STATE_OFF)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav",70,120)
				self.EZdroppableBombArmedTime=CurTime()
                JMod_Hint(activator, "impactdet", self)
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to arm")
			end
			self.LastUse=Time
		elseif(State==STATE_ARMED)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav",70,120)
				self.EZdroppableBombArmedTime=nil
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to disarm")
			end
			self.LastUse=Time
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Att=self:GetPos()+Vector(0,0,60),self.Owner or game.GetWorld()
		JMod_Sploom(Att,SelfPos,100)
		---
		if(self:WaterLevel()>=3)then self:Remove();return end
		---
		local Sploom=EffectData()
		Sploom:SetOrigin(SelfPos)
		util.Effect("eff_jack_gmod_faebomb_predet",Sploom,true,true)
		---
		local Oof=.25
		for i=1,500 do
			local Tr=util.QuickTrace(SelfPos,VectorRand()*1000,self)
			if(Tr.Hit)then Oof=Oof*1.005 end
		end
		---
		timer.Simple(.3,function()
			util.ScreenShake(SelfPos,1000,3,2,2000*Oof)
			---
			util.BlastDamage(game.GetWorld(),Att,SelfPos,2000*Oof,200*Oof)
			---
			for i=1,2*Oof do
				sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,160,math.random(80,110))
			end
			---
			JMod_WreckBuildings(self,SelfPos,10*Oof)
			JMod_BlastDoors(self,SelfPos,10*Oof)
			---
			timer.Simple(.2,function()
				JMod_WreckBuildings(self,SelfPos,10*Oof)
				JMod_BlastDoors(self,SelfPos,10*Oof)
			end)
			timer.Simple(.4,function()
				JMod_WreckBuildings(self,SelfPos,10*Oof)
				JMod_BlastDoors(self,SelfPos,10*Oof)
			end)
			---
			timer.Simple(.1,function()
				local Tr=util.QuickTrace(SelfPos+Vector(0,0,100),Vector(0,0,-400))
				if(Tr.Hit)then util.Decal("BigScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
			end)
			---
			local Sploom=EffectData()
			Sploom:SetOrigin(SelfPos)
			Sploom:SetScale(Oof)
			util.Effect("eff_jack_gmod_faebomb_main",Sploom,true,true)
		end)
		self:Remove()
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
		JMod_AeroDrag(self,self:GetForward())
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Think()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezthermobaric","EZ Thermobaric Bomb")
end