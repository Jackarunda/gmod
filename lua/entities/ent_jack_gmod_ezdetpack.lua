-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Detpack"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
--- func_breakable
ENT.JModPreferredCarryAngles = Angle(0, -90, 90)
ENT.JModEZdetPack = true
ENT.JModEZstorable = true
ENT.JModRemoteTrigger = true
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

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

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/detpack.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)

		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end

		---
		self:SetState(STATE_OFF)
		self.NextStick = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"-1 broken \n 0 off \n 1 armed"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 25 then
			self:EmitSound("snd_jack_claythunk.ogg", 55, math.random(80, 120))
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if Dmg >= 4 then
			local Pos, State, DetChance = self:GetPos(), self:GetState(), 0

			if State == STATE_ARMED then
				DetChance = DetChance + .3
			end

			if dmginfo:IsDamageType(DMG_BLAST) then
				DetChance = DetChance + Dmg / 150
			end

			if math.Rand(0, 1) < DetChance then
				self:Detonate()

				return
			end

			if (math.random(1, 10) == 3) and not (State == STATE_BROKEN) then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = JMod.IsAltUsing(Dude)

			if State == STATE_OFF then
				if Alt then
					self:SetState(STATE_ARMED)
					self:EmitSound("snd_jack_minearm.ogg", 60, 100)
					JMod.Hint(Dude, "trigger")
				else
					constraint.RemoveAll(self)
					self.StuckStick = nil
					self.StuckTo = nil
					Dude:PickupObject(self)
					self.NextStick = Time + .5
					JMod.Hint(Dude, "sticky")
				end
			else
				self:EmitSound("snd_jack_minearm.ogg", 60, 70)
				self:SetState(STATE_OFF)
			end
		else
			if self:IsPlayerHolding() and (self.NextStick < Time) then
				local Tr = util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector() * 80, {self, Dude})

				if Tr.Hit and IsValid(Tr.Entity:GetPhysicsObject()) and not Tr.Entity:IsNPC() and not Tr.Entity:IsPlayer() then
					self.NextStick = Time + .5
					local Ang = Tr.HitNormal:Angle()
					Ang:RotateAroundAxis(Ang:Right(), -90)
					Ang:RotateAroundAxis(Ang:Up(), 90)
					self:SetAngles(Ang)
					self:SetPos(Tr.HitPos)

					-- crash prevention
					if Tr.Entity:GetClass() == "func_breakable" then
						timer.Simple(0, function()
							self:GetPhysicsObject():Sleep()
						end)
					else
						local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 3000, false, false)
						self.StuckTo = Tr.Entity
						self.StuckStick = Weld
					end

					self:EmitSound("snd_jack_claythunk.ogg", 65, math.random(80, 120))
					Dude:DropObject()
					JMod.Hint(Dude, "arm")
				end
			end
		end
	end

	function ENT:IncludeSympatheticDetpacks(origin)
		local Powa, FilterEnts, Points = 1, ents.FindByClass("ent_jack_gmod_ezdetpack"), {origin}

		for k, pack in pairs(ents.FindInSphere(origin, 100)) do
			if (pack ~= self) and pack.JModEZdetPack then
				local PackPos = pack:LocalToWorld(pack:OBBCenter())

				if not util.TraceLine({
					start = origin,
					endpos = PackPos,
					filter = FilterEnts
				}).Hit then
					Powa = Powa + 1
					table.insert(Points, PackPos)
					pack.SympatheticDetonated = true
					pack:Remove()
				end
			end
		end

		local Cumulative = Vector(0, 0, 0)

		for k, point in pairs(Points) do
			Cumulative = Cumulative + point
		end

		return Cumulative / Powa, Powa
	end

	function ENT:JModEZremoteTriggerFunc(ply)
		if not (IsValid(ply) and ply:Alive() and (ply == self.EZowner)) then return end
		if self:GetState() ~= STATE_ARMED then return end
		JMod.Hint(ply, "detpack combo", self:GetPos())
		self:Detonate()
	end

	function ENT:Detonate()
		if self.SympatheticDetonated then return end
		if self.Exploded then return end
		self.Exploded = true

		timer.Simple(math.Rand(0, .1), function()
			if IsValid(self) then
				if self.SympatheticDetonated then return end
				local SelfPos, PowerMult = self:IncludeSympatheticDetpacks(self:LocalToWorld(self:OBBCenter()))
				PowerMult = (PowerMult ^ .75) * JMod.Config.Explosives.Detpack.PowerMult
				--
				local Blam = EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult)
				util.Effect("eff_jack_plastisplosion", Blam, true, true)
				JMod.Sploom(self.EZowner or self or game.GetWorld(), SelfPos, 20)
				util.ScreenShake(SelfPos, 99999, 99999, 1, 750 * PowerMult)

				for i = 1, PowerMult do
					sound.Play("BaseExplosionEffect.Sound", SelfPos, 120, math.random(90, 110))
				end

				if PowerMult > 1 then
					for i = 1, PowerMult do
						sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 140, math.random(90, 110))
					end
				end

				self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)

				timer.Simple(.1, function()
					for i = 1, 5 do
						local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

						if Tr.Hit then
							util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
						end
					end
				end)

				JMod.WreckBuildings(self, SelfPos, PowerMult)
				JMod.BlastDoors(self, SelfPos, PowerMult)
				local RangeMult = 1

				if IsValid(self.StuckTo) and JMod.IsDoor(self.StuckTo) then
					RangeMult = .3
				end

				timer.Simple(0, function()
					local ZaWarudo = game.GetWorld()
					local Infl, Att = (IsValid(self) and self) or ZaWarudo, (IsValid(self) and IsValid(self.EZowner) and self.EZowner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl, Att, SelfPos, 300 * PowerMult * RangeMult, 200 * PowerMult)
					-- do a lot of damage point blank, mostly for breaching
					util.BlastDamage(Infl, Att, SelfPos, 20 * PowerMult * RangeMult, 1000 * PowerMult)
					self:Remove()
				end)
			end
		end)
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
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
		local State, Vary = self:GetState(), math.sin(CurTime() * 50) / 2 + .5

		if State == STATE_ARMING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 20, 20, Color(255, 0, 0))
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 10, 10, Color(255, 255, 255))
		elseif State == STATE_WARNING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 30 * Vary, 30 * Vary, Color(255, 0, 0))
			render.DrawSprite(self:GetPos() + Vector(0, 0, 4), 15 * Vary, 15 * Vary, Color(255, 255, 255))
		end
	end

	language.Add("ent_jack_gmod_ezdetpack", "EZ Detpack")
end
