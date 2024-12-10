-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Powder Keg"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.JModEZstorable = true
ENT.JModHighlyFlammableFunc = "Detonate"

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 15
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/explosives/powderkeg.mdl")
		--self:SetMaterial("models/entities/mat_jack_powderkeg")
		self:SetBodygroup(0, 0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.Powder = 200
		self.Pouring = false

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate"}, {"This will directly detonate the bomb"})

			self.Outputs = WireLib.CreateOutputs(self, {"State[BOOL]", "Powder"}, {"Weather it's pouring or not", "The amount of powder left"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if (iname == "Detonate") and (value > 0 or true) then
			self:Detonate()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 25 then
			self:EmitSound("DryWall.ImpactHard")
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.Exploded then return end
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if Dmg >= 4 then
			local Pos, DetChance = self:GetPos(), 0

			if dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT) then
				DetChance = DetChance + Dmg / 150
			end

			if math.Rand(0, 1) < DetChance then
				self:Detonate()
			end
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)

		if JMod.IsAltUsing(Dude) then
			self.Pouring = not self.Pouring

			if self.Pouring then
				Dude:PickupObject(self)
			end

			self:EmitSound("items/ammocrate_open.wav", 70, self.Pouring and 130 or 100)

			return
		end

		Dude:PickupObject(self)
		JMod.Hint(Dude, "arm powderkeg")
	end

	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:GetPos()
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 80)
		local Blam = EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(.75)
		Blam:SetStart(self:GetPhysicsObject():GetVelocity())
		util.Effect("eff_jack_powdersplode", Blam, true, true)
		util.ScreenShake(SelfPos, 20, 20, 1, 700)
		-- black powder is not HE and its explosion lacks brisance, more of a push than a shock
		JMod.Sploom(JMod.GetEZowner(self), SelfPos, 150)
		local Dmg = DamageInfo()
		Dmg:SetDamage(70)
		Dmg:SetAttacker(JMod.GetEZowner(self))
		Dmg:SetInflictor(self)
		Dmg:SetDamageType(DMG_BURN)
		util.BlastDamageInfo(Dmg, SelfPos, 750)

		for i = 1, 5 do
			timer.Simple(i / 10, function()
				JMod.SimpleForceExplosion(SelfPos, 400000, 600, selfg)
			end)
		end

		if vFireInstalled then
			for i = 1, math.random(6, 9) do
				CreateVFireBall(math.random(3, 5), math.random(3, 5), self:GetPos(), VectorRand() * math.random(400, 600), self:GetOwner())
			end
		end

		self:Remove()
	end

	function ENT:Think()
		local Time = CurTime()

		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self.Pouring)
			WireLib.TriggerOutput(self, "Powder", self.Powder)
		end

		if self:IsOnFire() then
			if math.random(1, 50) == 2 then
				self:Detonate()

				return
			end
		end

		if self.Pouring then
			local Eff = EffectData()
			Eff:SetOrigin(self:GetPos())
			Eff:SetStart(self:GetVelocity())
			util.Effect("eff_jack_gmod_blackpowderpour", Eff, true, true)

			local Tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -200), {self})

			if Tr.Hit then
				local Powder = ents.Create("ent_jack_gmod_ezblackpowderpile")
				Powder:SetPos(Tr.HitPos + Tr.HitNormal * .1)
				JMod.SetEZowner(Powder, self.EZowner)
				Powder:Spawn()
				Powder:Activate()
				constraint.Weld(Powder, Tr.Entity, 0, 0, 0, true)
				JMod.Hint(JMod.GetEZowner(self), "powder", Powder)
			end

			self.Powder = self.Powder - 1

			if self.Powder <= 0 then
				self:Remove()

				return
			end

			self:NextThink(Time + .1)

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
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezpowderkeg", "EZ Powder Keg")
end
