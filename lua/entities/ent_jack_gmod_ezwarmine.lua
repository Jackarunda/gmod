-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ War Mine"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModGUIcolorable = false
ENT.JModEZstorable = false
ENT.EZscannerDanger = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)

ENT.BlacklistedNPCs = {"bullseye_strider_focus", "npc_turret_floor", "npc_turret_ceiling", "npc_turret_ground"}

ENT.WhitelistedNPCs = {"npc_rollermine"}

---
local STATE_OFF, STATE_ARMING, STATE_ARMED, STATE_WARNING = 0, 1, 2, 3

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		JMod.Colorify(ent)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/warmine.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(240)
		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(240)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed \n 0 is not \n -1 is broken \n 2 is arming"})
		end

		---
		self.Anger = 0
		self.FlaresLeft = 20
		self.FiredFlareForThisThreatCycle = false
		self.NextFlareFire = 0

		self.SoundLoop = CreateSound(self, "snds_jack_gmod/warmine_mk2.ogg")
		self.SoundLoop2 = CreateSound(self, "snds_jack_gmod/warmine_mk2.ogg")
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
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
		if JMod.LinCh(dmginfo:GetDamage(), 1000, 2000) then
			self:Detonate()
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

		if State == STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator)
				JMod.Colorify(self)
				self:Arm(activator)
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		elseif not (activator.KeyDown and activator:KeyDown(IN_SPEED)) then
			if (JMod.ShouldAllowControl(self, activator)) then
				self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 60, 90)
				timer.Simple(.5, function()
					if (IsValid(self)) then
						self:EmitSound("snds_jack_gmod/simple_drill.ogg", 60, 100)
					end
				end)
				if (self.SoundLoop) then self.SoundLoop:Stop() end
				if (self.SoundLoop2) then self.SoundLoop2:Stop() end
				self.Anger = 0
				self:SetState(STATE_OFF)
				if (IsValid(self.Weld)) then self.Weld:Remove() end
			else
				self:Detonate()
			end
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true

		local SelfPos, Att = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self)
		-- when we detonate, we don't want other mines to detonate too. Waste of mines
		-- remove some Anger from the others so that they can evaluate the battlefield again after we're gone
		for k, v in pairs(ents.FindInSphere(SelfPos, 1000)) do
			if (v:GetClass() == self.ClassName and v ~= self) then v.Anger = math.Clamp(v.Anger - 50, 0, 100) end
		end
		---
		JMod.Sploom(Att, SelfPos, 100)
		---
		util.ScreenShake(SelfPos, 2000, 3, 2, 2000)
		local Eff = "100lb_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "100lb_air"
		end

		for i = 1, 2 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
		end

		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 300), 300, 120)

		timer.Simple(.25, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 600, 120)
		end)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 4)
		JMod.BlastDoors(self, SelfPos, 4)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)
		local Up = self:GetUp()
		JMod.FragSplosion(self, SelfPos + Up * 5, 10000, 200, 1500, JMod.GetEZowner(self), Up, 1.2)
		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:Arm(armer)
		local State = self:GetState()
		if State ~= STATE_OFF then return end
		JMod.Hint(armer, "mine friends")
		JMod.SetEZowner(self, armer)
		JMod.Colorify(self)
		self:SetState(STATE_ARMING)
		self:EmitSound("snds_jack_gmod/simple_drill.ogg", 60, 100)
		timer.Simple(.5, function()
			if (IsValid(self)) then
				self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 60, 90)
			end
		end)

		timer.Simple(5, function()
			if IsValid(self) then
				if self:GetState() == STATE_ARMING then
					self:SetState(STATE_ARMED)
					local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 20), Vector(0, 0, -40), self)

					if Tr.Hit then
						self.Weld = constraint.Weld(Tr.Entity, self, 0, 0, 50000, false, false)
					end
				end
			end
		end)
	end

	function ENT:RileUp()
		if (self.SoundLoop) then self.SoundLoop:PlayEx(1, 80) end
		if (self.SoundLoop2) then self.SoundLoop2:PlayEx(1, 80) end
		self:SetState(STATE_WARNING)
	end

	function ENT:CalmDown()
		if (self.SoundLoop) then self.SoundLoop:Stop() end
		if (self.SoundLoop2) then self.SoundLoop2:Stop() end
		self:SetState(STATE_ARMED)
	end

	function ENT:GetCurrentThreatSummary()
		local Pos, Threat, DangerClose = self:GetPos() + Vector(0, 0, 20), 0, false
		for k, ent in pairs(ents.FindInSphere(Pos, 1000)) do
			if (ent ~= self) then
				local Phys = ent:GetPhysicsObject()
				if (IsValid(Phys)) then
					local IsPlaya, IsNPC, Mass, Speed, IsVehicular = ent:IsPlayer(), ent:IsNPC(), Phys:GetMass(), Phys:GetVelocity():Length(), ent:IsVehicle()
					if (IsPlaya and ent:Alive() and JMod.ShouldAllowControl(self, ent) and JMod.ClearLoS(self, ent, true, 20, true)) then
						DangerClose = true
					elseif (JMod.ShouldAttack(self, ent) and JMod.ClearLoS(self, ent, true, 20, true)) then
						if (Speed < 1) then Speed = 10 end
						local Dist = Pos:Distance(ent:GetPos())
						local ThreatAddition = 0
						if (IsPlaya) then
							local SpeedFactor = Speed
							local DistFactor = (Dist < 150 and 8) or 1
							ThreatAddition = SpeedFactor * DistFactor / 50
						elseif (IsNPC) then
							local SpeedFactor = Speed
							local HealthFactor = ((ent.Health and ent:Health()) or 100) ^ .6
							ThreatAddition = SpeedFactor * HealthFactor / 1200
						elseif (IsVehicular) then
							local SpeedFactor = Speed
							local MassFactor = Mass ^ .5
							ThreatAddition = SpeedFactor * MassFactor / 1200
						end
						-- jprint(ent, ThreatAddition, math.Round(self.Anger))
						Threat = Threat + ThreatAddition * math.Rand(.8, 1.2)
					end
				end
			end
		end
		return Threat, DangerClose
	end

	function ENT:FireFlare()
		self.FlaresLeft = self.FlaresLeft - 1
		self.FiredFlareForThisThreatCycle = true
		self.NextFlareFire = CurTime() + 10
		local Flare = ents.Create("ent_jack_gmod_ezflareprojectile")
		Flare:SetPos(self:GetPos() + Vector(0, 0, 15))
		Flare:Spawn()
		Flare:Activate()
		Flare:GetPhysicsObject():SetVelocity(Vector(0, 0, 1500) + VectorRand() * math.random(0, 100))
		self:EmitSound("snds_jack_gmod/flaregun_fire.ogg", 75, math.random(90, 110))
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end

		local State, Time = self:GetState(), CurTime()

		if (State == STATE_OFF) then return end

		local Threat, DangerClose = self:GetCurrentThreatSummary()

		-- jprint(self.Anger.." "..tostring(DangerClose))

		if State == STATE_ARMED then
			if not(IsValid(self.Weld))then self:Detonate() return end
			if (Threat > 0) then self:RileUp() return end
			self.Anger = math.Clamp(self.Anger - .2, 0, 100)
			if (self.Anger <= 0) then self.FiredFlareForThisThreatCycle = false end
		elseif State == STATE_WARNING then
			if (Threat <= 0) then self:CalmDown() return end
			self.Anger = math.Clamp(self.Anger + Threat, 0, 100)
			if (self.Anger >= 25 and self.FlaresLeft > 0 and not self.FiredFlareForThisThreatCycle and self.NextFlareFire < Time) then
				self:FireFlare()
			end
			if (self.Anger >= 100 and not DangerClose) then self:Detonate() return end
		end
		self:NextThink(Time + .3)
		return true
	end

	function ENT:OnRemove()
		if (self.SoundLoop) then self.SoundLoop:Stop() end
		if (self.SoundLoop2) then self.SoundLoop2:Stop() end
	end
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	--
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		local State, Vary = self:GetState(), math.sin(CurTime() * 50) / 2 + .5

		if State == STATE_ARMING or State == STATE_WARNING then
			local GlowPos = self:GetPos() + Vector(0, 0, 10)
			local Vec = (GlowPos - EyePos()):GetNormalized()
			GlowPos = GlowPos - Vec * 20

			render.SetMaterial(GlowSprite)
			render.DrawSprite(GlowPos, 300 * Vary, 300 * Vary, Color(255, 0, 0))
			render.DrawSprite(GlowPos, 150 * Vary, 150 * Vary, Color(255, 255, 255))
			local DLight = DynamicLight(self:EntIndex())
			if DLight then
				DLight.Brightness = 6 * Vary
				DLight.Decay = 7500
				DLight.DieTime = CurTime() + .1
				DLight.Pos = self:GetPos() + Vector(0, 0, 20)
				DLight.Size = 500
				DLight.r = 255
				DLight.g = 0
				DLight.b = 0
			end
		end
	end

	language.Add("ent_jack_gmod_ezwarmine", "EZ War Mine")
end
