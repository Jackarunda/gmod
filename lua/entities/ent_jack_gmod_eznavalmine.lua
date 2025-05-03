-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Mini Naval Mine"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZscannerDanger = true
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZbombBaySize = 25
ENT.EZbuoyancy = .4
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
		self:SetModel("models/jmod/explosives/mines/submine.mdl")
		--self:SetMaterial("models/mat_jack_dullscratchedmetal")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(120)
			self:GetPhysicsObject():Wake()
		end)

		---
		self:SetState(STATE_OFF)
		self.LastUse = 0
		self.MoorMode = "subsurface"
		self.Moored = false
		self.MoorRope = nil
		self.NextDet = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Moored"}, {"-1 broken \n 0 off \n 1 armed", "True when moored"})
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
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			if (data.Speed > 20) and (self:GetState() == STATE_ARMED) and (self:WaterLevel() > 0) and (self.NextDet < CurTime()) then
				self:Detonate()

				return
			end

			if data.Speed > 2000 then
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
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 100, 200) then
			if self:WaterLevel() > 0 then
				JMod.SetEZowner(self, dmginfo:GetAttacker())
				self:Detonate()
			else
				self:Break()
			end
		end
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 70, 110)
				self.NextDet = CurTime() + 3

				-- if we're already underwater when we arm, the user probably wants to moor us mid-water
				if self:WaterLevel() > 0 then
					self.MoorMode = "midwater"
				else
					self.MoorMode = "subsurface"
				end

				JMod.Hint(activator, "navalmine")
			else
				JMod.Hint(activator, "double tap to arm")
				JMod.Hint(activator, "arm navalmine")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 70, 110)
				self.Moored = false
				if IsValid(self.MoorRope) then self.MoorRope:Remove() end
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		sound.Play("snds_jack_gmod/mine_warn.ogg", self:GetPos() + Vector(0, 0, 30), 60, 100)

		timer.Simple(math.Rand(.15, .4) * JMod.Config.Explosives.Mine.Delay, function()
			if IsValid(self) then
				local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), JMod.GetEZowner(self)
				---
				local splad = EffectData()
				splad:SetOrigin(SelfPos)
				splad:SetScale(3)
				splad:SetEntity(self)
				util.Effect("eff_jack_gmod_watersplode", splad, true, true)
				---
				util.ScreenShake(SelfPos, 1000, 3, 3, 2000)

				---
				for i = 1, 3 do
					sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", SelfPos, 80, 100)
					sound.Play("ambient/water/water_splash" .. math.random(1, 3) .. ".wav", SelfPos, 160, 50)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos, 70, math.random(80, 110))
				end

				---
				timer.Simple(.1, function()
					util.BlastDamage(game.GetWorld(), Att, SelfPos, 800, 200)
					util.BlastDamage(game.GetWorld(), Att, SelfPos - Vector(0, 0, 120), 800, 200)
				end)

				---
				JMod.WreckBuildings(self, SelfPos, 8)
				---
				self:Remove()
			end
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:EZdetonateOverride(detonator)
		if self:WaterLevel() > 0 then
			self:Detonate()
		end
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Moored", self.Moored)
		end

		if (self:GetState() == STATE_ARMED) and (self:WaterLevel() > 0) then
			if not self.Moored then
				self:GetPhysicsObject():SetDamping(1, 1)
				local SelfPos = self:LocalToWorld(self:OBBCenter())

				if self.MoorMode == "midwater" then
					local Tr = util.QuickTrace(SelfPos, Vector(0, 0, -30000), self)

					if Tr.Hit then
						local Length = Tr.HitPos:Distance(SelfPos)
						self.MoorRope = constraint.Rope(self, Tr.Entity, 0, 0, Vector(0, 0, -18), Tr.Entity:WorldToLocal(Tr.HitPos), Length, math.random(-20, 20), 0, 2, "cable/mat_jack_gmod_chain", false)
					end
				elseif self.MoorMode == "subsurface" then
					local WaterLevel = nil

					local SurfaceTr = util.TraceLine({
						start = SelfPos + Vector(0, 0, 300),
						endpos = SelfPos - Vector(0, 0, 600),
						filter = self,
						mask = -1
					})

					if SurfaceTr.Hit then
						WaterLevel = SurfaceTr.HitPos
						local GroundTr = util.QuickTrace(SelfPos, Vector(0, 0, -30000), self)

						if GroundTr.Hit then
							local SeaFloorLevel = GroundTr.HitPos
							local WaterDepth = WaterLevel:Distance(SeaFloorLevel)
							self.MoorRope = constraint.Rope(self, GroundTr.Entity, 0, 0, Vector(0, 0, -18), GroundTr.Entity:WorldToLocal(SeaFloorLevel), WaterDepth, math.random(-45, -38), 0, 2, "cable/mat_jack_gmod_chain", false)
						end
					end
				end

				self.NextDet = CurTime() + 3
				self.Moored = true
			else
				if self.NextDet < CurTime() then
					self:GetPhysicsObject():SetBuoyancyRatio(self.EZbuoyancy)

					if JMod.EnemiesNearPoint(self, self:GetPos(), 300, true) then
						self:Detonate()

						return
					end

					self:NextThink(CurTime() + .5)

					return true
				end
			end
		end
	end

	function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
		local Time = CurTime()
		self.NextDet = Time + 3
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	function ENT:Think()
	end

	--
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_eznavalmine", "EZ Mini Naval Mine")
end
