-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Fumigator"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZscannerDanger = true
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, 270, 0)
---
local STATE_SEALED, STATE_TICKING, STATE_VENTING = 0, 1, 2

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 5
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		JMod.Hint(ply, self.ClassName)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/props/fumigator.mdl")
		self:SetMaterial("models/props_explosive/poison")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(20)
			self:GetPhysicsObject():Wake()
		end)

		---
		self:SetState(STATE_SEALED)
		self.ContainedGas = 100 * JMod.Config.Particles.FumigatorGasAmount

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Activate"}, {"This will activate the fumigator"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"0 is sealed \n 1 is ticking \n 2 is venting"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Activate" and value > 0 then
			self:SetState(STATE_TICKING)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self:EmitSound("Canister.ImpactHard")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			local Att = dmginfo:GetAttacker()

			if IsValid(Att) and Att:IsPlayer() then
				JMod.SetEZowner(self, Att)
			end

			self:Burst()
		end
	end

	function ENT:Fume(activator) 
		self:EmitSound("snd_jack_pinpull.ogg", 60, 100)
		self:EmitSound("snd_jack_spoonfling.ogg", 60, 100)
		self:SetState(STATE_TICKING)
		self.VentTime = CurTime() + 5
	end

	function ENT:Use(activator)
		local State, Alt = self:GetState(), JMod.IsAltUsing(activator)

		if State == STATE_SEALED then
			if Alt then
				JMod.SetEZowner(self, activator)
				self:Fume(activator)
				JMod.Hint(activator, "gas spread")
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		else
			activator:PickupObject(self)
		end
	end

	function ENT:EZdetonateOverride(detonator)
		self:EmitSound("snd_jack_sminepop.ogg", 70, 120)
		self:SetState(STATE_VENTING)
	end

	function ENT:Burst()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Owner, SelfVel = self:LocalToWorld(self:OBBCenter()), self.EZowner or self, self:GetPhysicsObject():GetVelocity()
		JMod.Sploom(Owner, SelfPos, 100)

		for i = 1, self.ContainedGas do
			timer.Simple(i / 200, function()
				local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
				Gas:SetPos(SelfPos)
				JMod.SetEZowner(Gas, Owner)
				Gas:Spawn()
				Gas:Activate()
				Gas.Canister = self
				Gas.CurVel = SelfVel + VectorRand() * math.random(10, 100)
			end)
		end

		self:Remove()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end

		local State, Time = self:GetState(), CurTime()

		if State == STATE_TICKING then
			self:EmitSound("snd_jack_metallicclick.ogg", 50, 100)
			self.VentTime = (self.VentTime or Time + 5)

			if self.VentTime < Time then
				self:EmitSound("snd_jack_sminepop.ogg", 70, 120)
				self:SetState(STATE_VENTING)
			end
			self:NextThink(Time + 1)

			return true
		elseif State == STATE_VENTING then
			local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
			Gas:SetPos(self:LocalToWorld(self:OBBCenter()) + self:GetUp() * 20)
			JMod.SetEZowner(Gas, self.EZowner or self)
			Gas:Spawn()
			Gas:Activate()
			Gas.Canister = self
			Gas.CurVel = self:GetPhysicsObject():GetVelocity() + self:GetUp() * math.random(10, 100)
			self.ContainedGas = self.ContainedGas - 1
			self:NextThink(Time + .2)
			self:EmitSound("snds_jack_gmod/hiss.ogg", 65, math.random(90, 110))

			if self.ContainedGas <= 0 then
				self:Remove()
			end

			return true
		end
	end

	function ENT:OnRemove()
	end
	--aw fuck you
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezfumigator", "EZ Fumigator")
end
