-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Bioweapon Canister"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminOnly=true
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(0,270,0)
---
local STATE_SEALED,STATE_TICKING,STATE_VENTING=0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*5
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/jmodels/explosives/props_explosive/explosive_butane_can02.mdl")
		--self.Entity:SetModelScale(.5,0)
		self.Entity:SetMaterial("models/props_explosive/virus")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(20)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_SEALED)
		self.ContainedGas=20
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates the bomb", "Arms bomb when > 0"})
			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"0 sealed \n 1 ticking \n 2 venting"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if(iname == "Detonate" and value > 0) then
			self:SetState(STATE_VENTING)
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_TICKING)
		end
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("Canister.ImpactHard")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(JMod.LinCh(dmginfo:GetDamage(),40,100))then
			local Att=dmginfo:GetAttacker()
			if((IsValid(Att))and(Att:IsPlayer()))then JMod.Owner(self,Att) end
			self:Burst()
		end
	end
	function ENT:Use(activator)
		local State,Alt=self:GetState(),activator:KeyDown(JMod.Config.AltFunctionKey)
		
		if(State==STATE_SEALED)then
			if(Alt)then
				JMod.Owner(self,activator)
				self:EmitSound("snd_jack_pinpull.wav",55,100)
				self:EmitSound("snd_jack_spoonfling.wav",55,100)
				self:SetState(STATE_TICKING)
				JMod.Hint(activator, "gas spread")
				timer.Simple(10,function()
					if(IsValid(self))then
						self:EmitSound("snd_jack_sminepop.wav",55,120)
						self:SetState(STATE_VENTING)
					end
				end)
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		else
			activator:PickupObject(self)
		end
	end
	function ENT:EZdetonateOverride(detonator)
		self:EmitSound("snd_jack_sminepop.wav",55,130)
		self:SetState(STATE_VENTING)
	end
	function ENT:Burst()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Owner,SelfVel=self:LocalToWorld(self:OBBCenter()),self.Owner or self,self:GetPhysicsObject():GetVelocity()
		JMod.Sploom(Owner,SelfPos,100)
		for i=1,self.ContainedGas do
			timer.Simple(i/200,function()
				local Gas=ents.Create("ent_jack_gmod_ezvirusparticle")
				Gas:SetPos(SelfPos)
				JMod.Owner(Gas,Owner)
				Gas:Spawn()
				Gas:Activate()
				Gas:GetPhysicsObject():SetVelocity(SelfVel+VectorRand()*math.random(1,500))
			end)
		end
		self:Remove()
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(State==STATE_TICKING)then
			self:EmitSound("snd_jack_metallicclick.wav",55,100)
			self:NextThink(Time+1)
			return true
		elseif(State==STATE_VENTING)then
			local Gas=ents.Create("ent_jack_gmod_ezvirusparticle")
			Gas:SetPos(self:LocalToWorld(self:OBBCenter()))
			JMod.Owner(Gas,self.Owner or self)
			Gas:Spawn()
			Gas:Activate()
			Gas:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+self:GetUp()*500)
			self.ContainedGas=self.ContainedGas-1
			self:NextThink(Time+.2)
			self:EmitSound("snds_jack_gmod/hiss.wav",55,math.random(90,110))
			if(self.ContainedGas<=0)then self:Remove() end
			return true
		end
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_evirusbomb","EZ Virus Canister")
end