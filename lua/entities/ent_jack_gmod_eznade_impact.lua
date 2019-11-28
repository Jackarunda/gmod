-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZminiNade-Impact"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,-140,0)
ENT.JModEZstorable=true
---
local STATE_BROKEN,STATE_OFF,STATE_PRIMED,STATE_ARMING,STATE_ARMED=-1,0,1,2,3
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		ent.Owner=ply
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/weapons/w_fragjade.mdl")
		self.Entity:SetMaterial("models/mats_jack_nades/gnd_blk")
		self.Entity:SetModelScale(1.25,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
		self.LastVel=Vector(0,0,0)
		self.NextDet=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if((not(IsValid(self.AttachedBomb)))and(self:IsPlayerHolding())and(data.HitEntity.EZdetonateOverride))then
			self.Entity:EmitSound("Grenade.ImpactHard")
			self:SetPos(data.HitPos-data.HitNormal)
			self.AttachedBomb=data.HitEntity
			self.LastVel=data.HitEntity:GetVelocity()
			timer.Simple(0,function() self:SetParent(data.HitEntity) end)
			return
		end
		if(data.DeltaTime>0.2 and data.Speed>30)then
			self.Entity:EmitSound("Grenade.ImpactHard")
			if((self:GetState()==STATE_ARMED)and(data.Speed>200))then
				self:Detonate()
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(dmginfo:IsDamageType(DMG_BLAST))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
			if((math.random(1,10)==3)and not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		self.Owner=Dude
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(IN_WALK)
			if(State==STATE_OFF and Alt)then
				self:SetState(STATE_PRIMED)
				self:EmitSound("weapons/pinpull.wav",60,100)
				self:SetBodygroup(1,1)
			end
			JMod_Hint(activator,"grenade","mininade")
			JMod_ThrowablePickup(Dude,self)
		end
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(State==STATE_PRIMED)then
			if not(self:IsPlayerHolding())then
				self:SetState(STATE_ARMING)
				local Spewn=ents.Create("ent_jack_spoon")
				Spewn:SetPos(self:GetPos())
				Spewn:Spawn()
				Spewn:Activate()
				Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*750)
				self.Entity:EmitSound("snd_jack_spoonfling.wav",60,math.random(90,110))
				self:SetBodygroup(2,1)
				timer.Simple(.5,function()
					if(IsValid(self))then self:SetState(STATE_ARMED) end
				end)
			end
			self:NextThink(Time+.1)
			return true
		elseif(State==STATE_ARMED)then
			if(IsValid(self.AttachedBomb))then
				if(self.AttachedBomb:IsPlayerHolding())then self.NextDet=Time+.5 end
				local CurVel=self.AttachedBomb:GetPhysicsObject():GetVelocity()
				local Change=CurVel:Distance(self.LastVel)
				self.LastVel=CurVel
				if(Change>300)then
					if(self.NextDet<Time)then self:Detonate() end
					return
				end
				self:NextThink(Time+.1)
				return true
			end
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		if(IsValid(self.AttachedBomb))then
			self.AttachedBomb:EZdetonateOverride(self)
			JMod_Sploom(self.Owner,SelfPos,3)
			self:Remove()
			return
		end
		JMod_Sploom(self.Owner,SelfPos,math.random(70,100))
		util.ScreenShake(SelfPos,20,20,1,500)
		self:Remove()
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_eznade_impact","EZminiNade-Impact")
end