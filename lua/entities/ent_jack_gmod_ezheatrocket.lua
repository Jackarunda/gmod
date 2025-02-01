-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ HEAT Rocket"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZrackOffset = Vector(0, -1.5, 0)
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
		self:SetModel("models/hunter/plates/plate150.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		local Phys = self:GetPhysicsObject()
		---
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMaterial("metal")
				Phys:SetMass(40)
				Phys:Wake()
				Phys:EnableDrag(false)
			end
		end)

		---
		self:SetState(STATE_OFF)
		self.NextDet = 0
		self.FuelLeft = 100

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Launch"}, {"Directly detonates rocket", "Arms rocket", "Launches rocket"})

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
			if math.random(1, 3) == 1 then
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
		local Dir = -self:GetRight()
		local SelfPos, Att = self:GetPos(), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 10)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 1500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)

		---
		local BlastDmg = DamageInfo()
		BlastDmg:SetDamageType(DMG_BLAST)
		BlastDmg:SetDamage(100)
		BlastDmg:SetAttacker(Att)
		BlastDmg:SetInflictor(self)
		BlastDmg:SetDamageForce(Dir * 100)
		util.BlastDamageInfo(BlastDmg, SelfPos + Dir * 30, 200)

		local BlastTr = util.QuickTrace(SelfPos + Dir * 20, Dir * 100, self)
		--debugoverlay.Line(SelfPos, BlastTr.HitPos, 3, Color(255, 0, 0), true)

		if BlastTr.Hit and (BlastTr.HitWorld or IsValid(BlastTr.Entity)) then
			--debugoverlay.Cross(BlastTr.HitPos, 5, 5, Color(251, 255, 0), true)
			--[[local PeirceDmg = DamageInfo()
			PeirceDmg:SetAttacker(Att)
			PeirceDmg:SetInflictor(self)
			PeirceDmg:SetDamageType(DMG_SNIPER)
			PeirceDmg:SetDamage(5000 * math.Rand(.8, 1.2))
			PeirceDmg:SetReportedPosition(SelfPos)
			PeirceDmg:SetDamagePosition(BlastTr.HitPos)
			PeirceDmg:SetDamageForce(Dir * 20000 * math.Rand(.8, 1.2))
			BlastTr.Entity:TakeDamageInfo(PeirceDmg)--]]
			JMod.RicPenBullet(self, SelfPos, Dir, 8000, true, false, 1, .5)
		end

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 2)
		JMod.BlastDoors(self, SelfPos, 2)

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
			ParticleEffect("50lb_air", SelfPos + Dir * 130, Ang)
			ParticleEffect("50lb_air", SelfPos, Ang)
			ParticleEffect("50lb_air", SelfPos - Dir * 50, Ang)
		end)
	end

	function ENT:OnRemove()
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
		Phys:ApplyForceCenter(-self:GetRight() * 20000 + self.UpLift)
		---
		self:EmitSound("snds_jack_gmod/rocket_launch.ogg", 80, math.random(95, 105))
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(self:GetRight())
		Eff:SetScale(4)
		util.Effect("eff_jack_gmod_rocketthrust", Eff, true, true)

		---
		for i = 1, 4 do
			local Tr = util.QuickTrace(self:GetPos(), self:GetRight() * i * 40, {self, self.DropOwner})
			if Tr.Hit then
				util.BlastDamage(self, JMod.GetEZowner(self), Tr.HitPos, 50, 50)
			end
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
	end

	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
		end

		local Phys = self:GetPhysicsObject()
		JMod.AeroDrag(self, -self:GetRight(), .75)

		if self:GetState() == STATE_LAUNCHED then
			if self.FuelLeft > 0 then
				Phys:ApplyForceCenter(-self:GetRight() * 20000 + self.UpLift)
				self.FuelLeft = self.FuelLeft - 5
				---
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(self:GetRight())
				Eff:SetScale(1)
				util.Effect("eff_jack_gmod_rockettrail", Eff, true, true)
			end
		end

		self:NextThink(CurTime() + .05)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/jmod/explosives/missile/missile_patriot.mdl")
		self.Mdl:SetSkin(2)
		self.Mdl:SetModelScale(.45, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
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
		self.Mdl:SetRenderOrigin(Pos + Ang:Up() * 1.5 - Ang:Right() * 0 - Ang:Forward() * 1)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()

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
		if self.Mdl then
			self.Mdl:Remove()
		end
	end

	language.Add("ent_jack_gmod_ezheatrocket", "EZ HEAT Rocket")
end
