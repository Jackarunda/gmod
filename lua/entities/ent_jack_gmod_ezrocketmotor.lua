-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Rocket Motor"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.ThrustPower = 20000
ENT.JModHighlyFlammableFunc = "Launch"
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
		self:SetModel("models/jmod/explosives/ez_rocket_engine01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)
		--self:SetUseType(SIMPLE_USE)

		local Phys = self:GetPhysicsObject()
		---
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMaterial("plastic")
				Phys:SetMass(20)
				Phys:SetDragCoefficient(0)
				Phys:Wake()
				Phys:EnableDrag(false)
			end
		end)

		---
		self:SetState(STATE_OFF)
		self.FuelLeft = 100
		self.NextStick = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Arm", "Launch"}, {"Arms rocket", "Launches rocket"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Fuel"}, {"-1 broken \n 0 off \n 1 armed \n 2 launched", "Fuel left in the tank"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		--elseif iname == "Arm" and value == 0 then
		--	self:SetState(STATE_OFF)
		elseif iname == "Launch" and value > 0 then
			self:Launch()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end
		end
	end

	function ENT:Break()
		if self:GetState() == STATE_BROKEN then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))

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
		if dmginfo:IsDamageType(DMG_BURN) and JMod.LinCh(math.random(1, 1000), 900, 1000) then
		    self:Launch()
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = Dude:KeyDown(JMod.Config.General.AltFunctionKey)

			if State == STATE_OFF then
				if Alt then
					self:SetState(STATE_ARMED)
					self.EZlaunchableWeaponArmedTime = CurTime()
					self:EmitSound("snds_jack_gmod/bomb_arm.wav", 60, 120)
					JMod.Hint(activator, "launch")
				else
					constraint.RemoveAll(self)
					self.StuckStick = nil
					self.StuckTo = nil
					self:SetParent(nil)
					self:SetPos(activator:EyePos() + activator:GetAimVector() * 5)
					Dude:PickupObject(self)
					self.NextStick = Time + .5
					JMod.Hint(Dude, "sticky")
				end
			else
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav", 60, 120)
				self:SetState(STATE_OFF)
				self.EZlaunchableWeaponArmedTime = CurTime()
			end
		else
			if self:IsPlayerHolding() and (self.NextStick < Time) then
				local Tr = util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector() * 80, {self, Dude})

				if Tr.Hit and IsValid(Tr.Entity) and IsValid(Tr.Entity:GetPhysicsObject()) and not Tr.Entity:IsNPC() and not Tr.Entity:IsPlayer() then
					self.NextStick = Time + .5
					local Ang = Tr.HitNormal:Angle()
					Ang:RotateAroundAxis(Ang:Right(), 90)
					self:SetAngles(Ang)
					self:SetPos(Tr.HitPos + Tr.HitNormal * 5)

					-- crash prevention
					if Tr.Entity:GetClass() == "func_breakable" then
						timer.Simple(0, function()
							self:GetPhysicsObject():Sleep()
						end)
					else
						--local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 10000, false, false)
						self.StuckTo = Tr.Entity
						--self.StuckStick = Weld
						self:SetParent(Tr.Entity)
					end

					self:EmitSound("snd_jack_claythunk.wav", 65, math.random(80, 120))
					Dude:DropObject()
					JMod.Hint(Dude, "arm")
				end
			end
		end
	end

	function ENT:CutBurn()
		self:SetState(STATE_ARMED)
	end

	function ENT:Launch()
		local State = self:GetState()
		if (State == STATE_LAUNCHED) or (State == STATE_BROKEN) then return end
		self:SetState(STATE_LAUNCHED)
		local Phys = self:GetPhysicsObject()

		if IsValid(self.StuckTo) then
			if IsValid(self.StuckTo:GetPhysicsObject()) then
				Phys = self.StuckTo:GetPhysicsObject()
				Phys:EnableMotion(true)
				Phys:Wake()
				local CenterOfMass = self.StuckTo:LocalToWorld(Phys:GetMassCenter())
				if self:GetPos():Distance(CenterOfMass) < 50 then
					self.ThrustStuckTo = true
				end
			end
		end
		---
		self:EmitSound("snds_jack_gmod/rocket_launch.wav", 80, math.random(95, 105))
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetNormal(-self:GetUp())
		Eff:SetScale(2)
		util.Effect("eff_jack_gmod_rocketthrust", Eff, true, true)

		---
		for i = 1, 4 do
			util.BlastDamage(self, JMod.GetEZowner(self), self:GetPos() + self:GetUp() * i * -40, 50, 50)
		end

		util.ScreenShake(self:GetPos(), 20, 255, .5, 300)
		---

		JMod.Hint(JMod.GetEZowner(self), "backblast", self:GetPos())
		timer.Simple(.3, function()
			if IsValid(self) then
				self:SetSkin(1)
			end
		end)
	end

	function ENT:Think()
		local State = self:GetState()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", State)
			WireLib.TriggerOutput(self, "Fuel", self.FuelLeft)
		end

		--if IsValid(self.StuckTo) and not table.HasValue(constraint.GetAllConstrainedEntities(self), self.StuckTo) then
		--	self.StuckTo = nil
		--	self:CutBurn()
		--end

		if State == STATE_LAUNCHED then
			local Phys = self:GetPhysicsObject()
			if IsValid(self.StuckTo) and IsValid(self.StuckTo:GetPhysicsObject()) then
				Phys = self.StuckTo:GetPhysicsObject()
			end

			if self.FuelLeft > 0 then
				Phys:ApplyForceCenter(self:GetUp() * self.ThrustPower)
				self.FuelLeft = self.FuelLeft - 1.75
				--jprint(1 / self.FuelLeft)
				---
				local Eff = EffectData()
				Eff:SetOrigin(self:GetPos())
				Eff:SetNormal(-self:GetUp())
				Eff:SetScale(0.5)
				util.Effect("eff_jack_gmod_rockettrail", Eff, true, true)
			elseif not self.Spent then
				self.Spent = true
				for k, v in pairs(ents.FindInSphere(self:GetPos(), 30)) do
					if v.JModHighlyFlammableFunc then
						JMod.SetEZowner(v, self.EZowner)
						local Func = v[v.JModHighlyFlammableFunc]
						Func(v)
					end
				end
				timer.Simple(1, function()
					if IsValid(self) then
						--JMod.Sploom(JMod.GetEZowner(self), self:GetPos(), 0, 0)
						SafeRemoveEntity(self)
					end
				end)
			end
		end

		self:NextThink(CurTime() + .05)

		return true
	end
elseif CLIENT then
	local GlowSprite = Material("mat_jack_gmod_glowsprite")

	function ENT:Draw()
		local Pos, Ang, Dir = self:GetPos(), self:GetAngles(), -self:GetUp()
		self:DrawModel()

		if self:GetState() == STATE_LAUNCHED then
			self.BurnoutTime = self.BurnoutTime or CurTime() + 1.5

			if self.BurnoutTime > CurTime() then
				render.SetMaterial(GlowSprite)

				for i = 1, 10 do
					local Inv = 10 - i
					render.DrawSprite(Pos + Dir * (i * 10 + math.random(30, 40)), 5 * Inv, 5 * Inv, Color(255, 255 - i * 10, 255 - i * 20, 255))
				end

				local dlight = DynamicLight(self:EntIndex())

				if dlight then
					dlight.pos = Pos + Dir * 45
					dlight.r = 255
					dlight.g = 175
					dlight.b = 100
					dlight.brightness = 2
					dlight.Decay = 200
					dlight.Size = 400
					dlight.DieTime = CurTime() + .5
				end
			end
		end
	end

	language.Add("ent_jack_gmod_ezrocketmotor", "EZ Rocket Motor")
end
