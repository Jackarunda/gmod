-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ HE Rocket"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZrackOffset = Vector(0, -1.5, -2.5)
ENT.EZrackAngles = Angle(0, 0, 0)
ENT.EZrocket = true
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2
local VECTOR_DOWN = Vector(0, 0, -1)
---
-- Physics / motion config (overridable by inheriting rockets)
ENT.Model = "models/hunter/plates/plate150.mdl"
ENT.Mass = 40
ENT.PhysMaterial = nil
ENT.ThrustForce = 200000
ENT.ThrustJitter = 500
ENT.UpLiftMult = .5
ENT.FuelMax = 100
ENT.FuelBurn = 15
ENT.DetonationSpeed = 600
ENT.CollideDetState = STATE_ARMED
ENT.BreakOdds = 3
ENT.AeroDragMult = .1
ENT.TurnStrength = 3000
-- Effects
ENT.ThrustEffect = "eff_jack_gmod_rocketthrust"
ENT.TrailEffect = "eff_jack_gmod_rockettrail"
ENT.TrailEffectScale = 1
ENT.LaunchEffectScale = 4
ENT.LaunchSoundVol = 80
ENT.LaunchSoundPitchMin = 95
ENT.LaunchSoundPitchMax = 105
-- Client visual model
ENT.ClientModel = "models/jmod/explosives/missile/missile_patriot.mdl"
ENT.ClientModelSkin = 1
ENT.ClientModelScale = .45
ENT.UseClientModel = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(180, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			if not IsValid(self) then return end
			local Phys = self:GetPhysicsObject()
			if IsValid(Phys) then
				if self.PhysMaterial then
					Phys:SetMaterial(self.PhysMaterial)
				end
				Phys:SetMass(self.Mass)
				Phys:Wake()
				Phys:EnableDrag(false)
			end
		end)

		---
		self:SetState(STATE_OFF)
		self.NextDet = 0
		self.FuelLeft = self.FuelMax

		-- The motion controller is always running so aerodrag works even when
		-- the rocket is unlaunched (dropped/thrown). PhysicsSimulate handles thrust.
		if IsValid(self:GetPhysicsObject()) then
			self:StartMotionController()
		end

		self:SetupWire()
	end

	function ENT:SetupWire()
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Launch"}, {"Directly detonates rocket", "Arms rocket", "Launches rocket"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Fuel"}, {"-1 broken \n 0 off \n 1 armed \n 2 launched", "Fuel left in the tank"})
		end
	end

	-- World-space direction the rocket points/thrusts along. Override per model.
	function ENT:GetNoseDir()
		return -self:GetRight()
	end

	-- Entity-method aerodrag. Ported from JMod.AeroDrag, but is meant to be
	-- called from PhysicsSimulate so the velocity-proportional forces integrate
	-- over deltatime (tickrate independent). The direct angular-velocity damping
	-- is scaled by deltatime to match.
	function ENT:AeroDrag(forward, mult, spdReq, deltatime)
		if constraint.FindConstraint(self, "Weld") then return end
		if self:IsPlayerHolding() then return end

		local Phys = self:GetPhysicsObject()
		if not IsValid(Phys) then return end
		local Vel = Phys:GetVelocity()
		local Spd = Vel:Length()

		spdReq = spdReq or 300
		if Spd < spdReq then return end
		mult = mult or 1
		deltatime = deltatime or FrameTime()

		self.JMod_PhysMassCenter = self.JMod_PhysMassCenter or Phys:GetMassCenter()
		local Pos, Mass = Phys:LocalToWorld(self.JMod_PhysMassCenter), Phys:GetMass()
		Phys:ApplyForceOffset(Vel * Mass / 6 * mult, Pos + forward)
		Phys:ApplyForceOffset(-Vel * Mass / 6 * mult, Pos - forward)
		local AngVel = Phys:GetAngleVelocity()
		Phys:AddAngleVelocity(-AngVel * (Mass / 1000) * (deltatime / 0.05))
		self.LastAreoDragAmount = mult
	end

	function ENT:PhysicsSimulate(phys, deltatime)
		local Nose = self:GetNoseDir()
		self:AeroDrag(Nose, self.AeroDragMult, nil, deltatime)

		if (self:GetState() ~= STATE_LAUNCHED) or (self.FuelLeft <= 0) then
			return SIM_NOTHING
		end

		-- Lift only when the rocket isn't pointing down (flying sideways/up).
		if self.UpLift and (Nose:Dot(VECTOR_DOWN) < 0.1) then
			phys:ApplyForceCenter(self.UpLift)
		end

		-- Optional guidance: steer the nose toward a world point.
		if self.TargetPosition then
			local Mass = phys:GetMass()
			local Center = phys:LocalToWorld(phys:GetMassCenter())
			local DesiredDir = (self.TargetPosition - self:GetPos()):GetNormalized()
			local Turn = Mass * self.TurnStrength
			phys:ApplyForceOffset(DesiredDir * Turn, Center + Nose)
			phys:ApplyForceOffset(-DesiredDir * Turn, Center - Nose)
			phys:AddAngleVelocity(-phys:GetAngleVelocity() * (deltatime / 0.05) * 0.5)
		end

		-- Thrust as a local acceleration so it's mass/tickrate independent.
		local Linear = phys:WorldToLocalVector(Nose) * (self.ThrustForce / phys:GetMass())
		if self.ThrustJitter and (self.ThrustJitter > 0) then
			Linear = Linear + VectorRand() * self.ThrustJitter
		end

		return vector_origin, Linear, SIM_LOCAL_ACCELERATION
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		elseif iname == "Arm" and value == 0 then
			self:SetState(STATE_OFF)
		elseif iname == "Launch" and value > 0 then
			self:SetState(STATE_ARMED)
			self:Launch()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			if (data.Speed > self.DetonationSpeed) and (self:GetState() >= self.CollideDetState) then
				self:Detonate()

				return
			end

			if (data.Speed > 2000) and not(self:IsPlayerHolding()) then
				self:Break()
			end
		end
	end

	function ENT:Break()
		if self:GetState() == STATE_BROKEN then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end

		SafeRemoveEntityDelayed(self, 10)
	end

	function ENT:OnTakeDamage(dmginfo)
		if IsValid(self.DropOwner) then
			local Att = dmginfo:GetAttacker()
			if IsValid(Att) and (self.DropOwner == Att) then return end
		end

		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 60, 120) then
			if math.random(1, self.BreakOdds) == 1 then
				self:Break()
			else
				JMod.SetEZowner(self, dmginfo:GetAttacker())
				self:Detonate()
			end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		local Alt = JMod.IsAltUsing(activator)

		if State == STATE_OFF then
			if Alt then
				JMod.SetEZowner(self, activator)
				self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 60, 120)
				self:SetState(STATE_ARMED)
				self.EZlaunchableWeaponArmedTime = CurTime()
				JMod.Hint(activator, "launch")
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		elseif State == STATE_ARMED then
			self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 60, 120)
			self:SetState(STATE_OFF)
			JMod.SetEZowner(self, activator)
			self.EZlaunchableWeaponArmedTime = nil
		end
	end

	function ENT:Detonate()
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att, Dir = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self), -self:GetRight()
		JMod.Sploom(Att, SelfPos, 150)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 1500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		---
		local BlastDmg = DamageInfo()
		BlastDmg:SetDamage(300)
		BlastDmg:SetDamageType(DMG_BLAST)
		BlastDmg:SetDamageForce(self:GetRight() * 100)
		BlastDmg:SetDamagePosition(self:GetPos())
		BlastDmg:SetAttacker(self)
		BlastDmg:SetInflictor(self)
		util.BlastDamageInfo(BlastDmg, self:GetPos(), 300)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 3)
		JMod.BlastDoors(self, SelfPos, 3)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos - Dir * 100, Dir * 300)

			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		self:Remove()
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(), -90)

		timer.Simple(.1, function()
			ParticleEffect("50lb_air", SelfPos - Dir * 20, Ang)
			ParticleEffect("50lb_air", SelfPos - Dir * 50, Ang)
			ParticleEffect("50lb_air", SelfPos - Dir * 80, Ang)
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:Launch()
		if self:GetState() ~= STATE_ARMED then return end
		self:SetState(STATE_LAUNCHED)
		self.UpLift = physenv.GetGravity() * -self.UpLiftMult
		local Phys = self:GetPhysicsObject()
		constraint.RemoveAll(self)
		Phys:EnableMotion(true)
		Phys:Wake()
		local Nose = self:GetNoseDir()
		--Phys:ApplyForceCenter(Nose * (self.ThrustForce * 1) + self.UpLift)
		---
		self:EmitSound("snds_jack_gmod/rocket_launch.ogg", self.LaunchSoundVol, math.random(self.LaunchSoundPitchMin, self.LaunchSoundPitchMax))
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(-Nose)
		Eff:SetScale(self.LaunchEffectScale)
		util.Effect(self.ThrustEffect, Eff, true, true)

		---
		self:Backblast()

		util.ScreenShake(self:GetPos(), 20, 255, .5, 300)
		---
		self.NextDet = CurTime() + .25

		---
		timer.Simple(30, function()
			if IsValid(self) then
				self:Detonate()
			end
		end)

		JMod.Hint(JMod.GetEZowner(self), "backblast", self:GetPos())

		---
		self:OnLaunch()
	end

	-- Backblast damage cone behind the rocket. Override for custom behavior.
	function ENT:Backblast()
		local Owner, Behind = JMod.GetEZowner(self), -self:GetNoseDir()
		for i = 1, 4 do
			util.BlastDamage(self, Owner, self:GetPos() + Behind * i * 40, 50, 50)
		end
	end

	-- Hook for child-specific launch behavior (spin, fins, guidance, etc.)
	function ENT:OnLaunch()
	end

	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		self:NextThink(CurTime() + 0.1)
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
		end

		if self:GetState() == STATE_LAUNCHED then
			if self.GuidanceThink then
				self:GuidanceThink()
			end

			if self.FuelLeft > 0 then
				self.FuelLeft = self.FuelLeft - self.FuelBurn
				---
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(-self:GetNoseDir())
				Eff:SetScale(self.TrailEffectScale)
				util.Effect(self.TrailEffect, Eff, true, true)
				print(self:GetVelocity():Length())
			end
		end

		return true
	end
elseif CLIENT then
	local function MakeModel(self)
		self.Mdl = ClientsideModel(self.ClientModel)
		self.Mdl:SetSkin(self.ClientModelSkin)
		self.Mdl:SetModelScale(self.ClientModelScale, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	function ENT:Initialize()
		MakeModel(self)
	end

	function ENT:Think()
		local Pos, Dir = self:GetPos(), self:GetRight()
		local Time = CurTime()
		if self:GetState() == STATE_LAUNCHED then
			self.BurnoutTime = self.BurnoutTime or Time + 1

			if self.BurnoutTime > Time then
				local dlight = DynamicLight(self:EntIndex())

				if dlight then
					dlight.pos = Pos + Dir * 45
					dlight.r = 255
					dlight.g = 175
					dlight.b = 100
					dlight.brightness = 2
					dlight.Decay = 200
					dlight.Size = 400
					dlight.DieTime = Time + .5
				end
			end
		end
	end

	--
	local GlowSprite = Material("mat_jack_gmod_glowsprite")

	function ENT:Draw()
		local Pos, Ang, Dir = self:GetPos(), self:GetAngles(), self:GetRight()
		local Time = CurTime()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		if not IsValid(self.Mdl) then 
			MakeModel(self) 
		else
			self.Mdl:SetRenderOrigin(Pos + Ang:Up() * 1.5 - Ang:Right() * 0 - Ang:Forward() * 1)
			self.Mdl:SetRenderAngles(Ang)
			self.Mdl:DrawModel()
		end

		if self:GetState() == STATE_LAUNCHED then
			self.BurnoutTime = self.BurnoutTime or Time + 1

			if self.BurnoutTime > Time then
				render.SetMaterial(GlowSprite)

				for i = 1, 10 do
					local Inv = 10 - i
					render.DrawSprite(Pos + Dir * (i * 10 + math.random(30, 40)), 5 * Inv, 5 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
				end
			end
		end
	end

	function ENT:OnRemove()
		if IsValid(self.Mdl) then
			SafeRemoveEntity(self.Mdl)
		end
	end

	language.Add("ent_jack_gmod_ezherocket", "EZ HE Rocket")
end
