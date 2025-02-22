-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Heavy Rocket"
ENT.Spawnable = true
ENT.AdminOnly = false
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZrackOffset = Vector(0, 0, 0)
ENT.EZrackAngles = Angle(0, 0, 0)
ENT.EZrocket = true
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2

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
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/explosives/ez_hrocket.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)

		---
		self:SetState(STATE_OFF)
		self.NextDet = 0
		self.FuelLeft = 100

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates rocket", "Arms rocket"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Fuel"}, {"-1 broken \n 0 off \n 1 armed \n 2 launched", "Fuel left in the tank"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		elseif iname == "Arm" and value == 0 then
			self:SetState(STATE_OFF)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			local DetSpd = 300

			if (data.Speed > DetSpd) and (self:GetState() == STATE_LAUNCHED) then
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
			if math.random(1, 5) == 1 then
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
				--JMod.Hint(activator, "remote guidance")
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

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
		end

		local Phys = self:GetPhysicsObject()
		JMod.AeroDrag(self, self:GetForward(), 1)

		if self:GetState() == STATE_LAUNCHED then
			local SelfPos = self:WorldSpaceCenter()
			local FlightDir = self:GetForward()
			if IsValid(self.Target) then
				local DiffToTarget = (self.Target:WorldSpaceCenter()) - SelfPos
				local Dist = DiffToTarget:Length()
				local OurVel = self:GetVelocity()
				local TheirVel = self.Target:GetVelocity()
				local LeadDir = TheirVel:GetNormalized()
				local AimVector = self.Target:WorldSpaceCenter() + LeadDir * (((Dist * 12) / (OurVel:Length() * 12)) * TheirVel:Length()) --* .5
				local AimDir = (AimVector - SelfPos):GetNormalized()
				local CurForward = self:GetForward()
				FlightDir = LerpVector(.5, CurForward, AimDir)
				if Dist < 400 then
					self:Detonate()
				end
			end

			if self.FuelLeft > 0 then
				Phys:ApplyForceCenter(FlightDir * 20000 + self.UpLift)
				Phys:ApplyTorqueCenter(self:GetForward() * 20)
				self.FuelLeft = self.FuelLeft - 1
				---
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(-self:GetForward())
				Eff:SetScale(4)
				util.Effect("eff_jack_gmod_ezexhaust", Eff, true, true)
				--util.Effect("eff_jack_gmod_rockettrail", Eff, true, true)
			end
		end

		self:NextThink(CurTime() + .05)

		return true
	end

	--
	function ENT:Launch()
		if self:GetState() ~= STATE_ARMED then return end
		self:SetState(STATE_LAUNCHED)
		self.UpLift = Vector(0, 0, GetConVar("sv_gravity"):GetFloat() * 2)
		local Phys = self:GetPhysicsObject()
		constraint.RemoveAll(self)
		Phys:EnableMotion(true)
		Phys:Wake()
		Phys:ApplyForceCenter(-self:GetForward() * 20000 + self.UpLift * .5)
		---
		self:EmitSound("snds_jack_gmod/rocket_launch.ogg", 90, math.random(85, 95))
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(-self:GetForward())
		Eff:SetScale(1)
		util.Effect("eff_jack_gmod_rocketthrust", Eff, true, true)

		---
		for i = 1, 4 do
			util.BlastDamage(self, JMod.GetEZowner(self), self:GetPos() + -self:GetForward() * i * 40, 50, 50)
		end

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
		timer.Simple(.5, function()
			if IsValid(self) then
				self:GetPhysicsObject():ApplyTorqueCenter(self:GetForward() * 2500)
				self:SetBodygroup(1, 1)
			end
		end)

		for k, v in pairs(ents.FindInCone(self:GetPos(), self:GetForward(), 50000, 0.707)) do
			if JMod.ShouldAttack(self, v, true, false) then
				self.Target = v

				break
			end
		end
	end

	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Detonate()
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att, Dir = self:GetPos() + self:GetForward() * 50, JMod.GetEZowner(self), self:GetForward()
		JMod.Sploom(Att, SelfPos, 300)
		JMod.FragSplosion(self, SelfPos, 50, 35, 1000, Att, Dir, .45, nil, false)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 1500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 50), 250, 200)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 400)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 4)
		JMod.BlastDoors(self, SelfPos, 4)

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
		Ang:RotateAroundAxis(Ang:Right(), -90)

		timer.Simple(.1, function()
			ParticleEffect("100lb_air", SelfPos - Dir * 20, Ang)
			ParticleEffect("100lb_air", SelfPos - Dir * 50, Ang)
			ParticleEffect("100lb_air", SelfPos - Dir * 80, Ang)
		end)
	end

	function ENT:OnRemove()
	end

elseif CLIENT then
	function ENT:Initialize()
		self:SetModel("models/jmod/explosives/ez_hrocket.mdl")
	end

	function ENT:Think()
		local Pos, Dir = self:GetPos(), -self:GetForward()
		local Time = CurTime()

		if self:GetState() == STATE_LAUNCHED then
			self.BurnoutTime = self.BurnoutTime or Time + 2
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
		local Pos, Ang, Dir = self:GetPos(), self:GetAngles(), -self:GetForward()
		local Time = CurTime()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		self:DrawModel()

		if self:GetState() == STATE_LAUNCHED then
			if self.BurnoutTime > Time then
				render.SetMaterial(GlowSprite)

				for i = 1, 10 do
					local Inv = 10 - i
					render.DrawSprite(Pos + Dir * (i * 10 + math.random(30, 40)), 5 * Inv, 5 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
				end
			end
		end
	end

	language.Add("ent_jack_gmod_ezherocket", "EZ Heavy Rocket")
end
