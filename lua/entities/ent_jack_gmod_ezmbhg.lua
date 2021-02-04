-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Micro Black Hole Generator"
ENT.Spawnable=true
ENT.AdminOnly=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
---
local STATE_BROKEN,STATE_OFF,STATE_CHARGING=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
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
		self.Entity:SetModel("models/props_wasteland/laundry_washer001a.mdl")
		self.Entity:SetMaterial("models/mat_jack_gmod_ezmbhg")
		--self.Entity:SetModelScale(.75,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(500)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
		self.LastUse=0
		self.Charge=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>50)then
				self.Entity:EmitSound("Canister.ImpactHard")
			end
			if(data.Speed>1000)then self:Break() end
		end
	end
	function ENT:Break()
		if(self:GetState()==STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do
			self:DamageSpark()
		end
		if(self.Hum)then self.Hum:Stop() end
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
			if(math.random(1,5)==1)then
				self:Break()
			end
		end
	end
	function ENT:Use(activator)
		local State,Time=self:GetState(),CurTime()
		if(State<0)then return end
		if(State==STATE_OFF)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_CHARGING)
				self:EmitSound("ambient/machines/thumper_startup1.wav")
				self.Hum=CreateSound(self,"snds_jack_gmod/ezbhg_hum.wav")
				self.Hum:Play()
				self.Hum:SetSoundLevel(100)
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to arm")
			end
			self.LastUse=Time
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		if(self.Hum)then self.Hum:Stop() end
		local SelfPos=self:LocalToWorld(self:OBBCenter())+Vector(0,0,80)
		local plooie=EffectData()
		plooie:SetOrigin(SelfPos)
		util.Effect("eff_jack_gmod_ezbhg",plooie,true,true)
		for i=1,50 do
			timer.Simple(i/150,function()
				sound.Play("ambient/machines/thumper_hit.wav",SelfPos+VectorRand()*math.random(1,1000),140,math.random(120,130))
			end)
		end
		for i=1,3 do sound.Play("snds_jack_gmod/ezbhg_splode.wav",SelfPos+VectorRand(),140,100) end
		util.ScreenShake(SelfPos,99999,99999,3,3000)
		util.BlastDamage(self,self.Owner or self or game.GetWorld(),SelfPos,200,200)
		local Own=self.Owner
		timer.Simple(2,function()
			local Bam=ents.Create("ent_jack_gmod_ezblackhole")
			Bam:SetPos(SelfPos)
			JMod_Owner(Bam,Own)
			Bam:Spawn()
			Bam:Activate()
		end)
		self:Remove()
	end
	function ENT:OnRemove()
		if(self.Hum)then self.Hum:Stop() end
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(State==STATE_CHARGING)then
			self.Charge=self.Charge+.1*JMOD_CONFIG.MicroBlackHoleGeneratorChargeSpeed
			if(self.Hum)then
				self.Hum:ChangePitch(1+self.Charge*2.53)
			end
			self:GetPhysicsObject():ApplyForceCenter(Vector(math.sin(Time*self.Charge/2),math.cos(Time*self.Charge/2),0)*self.Charge*200)
			if(self.Charge>=100)then
				self:Detonate()
				return
			end
			self:NextThink(Time+.1)
			return true
		end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
		--
	end
	language.Add("ent_jack_gmod_ezmbhg","EZ Micro Black Hole Generator")
end