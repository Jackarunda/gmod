﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Thermobaric Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZRackOffset = Vector(0, 0, 10)
ENT.EZRackAngles = Angle(0, 0, 90)
ENT.EZbombBaySize = 5
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
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/props_phx/ww2bomb.mdl")
		self.Entity:SetMaterial("models/entities/mat_jack_faebomb")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
			self:GetPhysicsObject():SetDamping(0, 0)
		end)

		---
		self:SetState(STATE_OFF)
		self.LastUse = 0
		self.FreefallTicks = 0

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
		if not IsValid(self) then return end

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			local DetSpd = 500

			if (data.Speed > DetSpd) and (self:GetState() == STATE_ARMED) then
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

		self.Entity:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 60, 120) then
			local Pos, State = self:GetPos(), self:GetState()

			if State == STATE_ARMED then
				self:Detonate()
			elseif not (State == STATE_BROKEN) then
				self:Break()
			end
		end
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.Owner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav", 70, 120)
				self.EZdroppableBombArmedTime = CurTime()
				JMod.Hint(activator, "impactdet")
			else
				JMod.Hint(activator, "double tap to arm")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.Owner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav", 70, 120)
				self.EZdroppableBombArmedTime = nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), self.Owner or game.GetWorld()
		JMod.Sploom(Att, SelfPos, 100)

		---
		if self:WaterLevel() >= 3 then
			self:Remove()

			return
		end

		---
		local Sploom = EffectData()
		Sploom:SetOrigin(SelfPos)
		util.Effect("eff_jack_gmod_faebomb_predet", Sploom, true, true)
		---
		local Oof = .25

		for i = 1, 500 do
			local Tr = util.QuickTrace(SelfPos, VectorRand() * 1000, self)

			if Tr.Hit then
				Oof = Oof * 1.005
			end
		end

		---
		timer.Simple(.3, function()
			util.ScreenShake(SelfPos, 1000, 3, 2, 2000 * Oof)
			---
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 2000 * Oof, 200 * Oof)

			---
			for i = 1, 2 * Oof do
				sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
			end

			---
			JMod.WreckBuildings(self, SelfPos, 10 * Oof)
			JMod.BlastDoors(self, SelfPos, 10 * Oof)

			---
			timer.Simple(.2, function()
				JMod.WreckBuildings(self, SelfPos, 10 * Oof)
				JMod.BlastDoors(self, SelfPos, 10 * Oof)
			end)

			timer.Simple(.4, function()
				JMod.WreckBuildings(self, SelfPos, 10 * Oof)
				JMod.BlastDoors(self, SelfPos, 10 * Oof)
			end)

			---
			timer.Simple(.1, function()
				local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

				if Tr.Hit then
					util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
				end
			end)

			---
			local Sploom = EffectData()
			Sploom:SetOrigin(SelfPos)
			Sploom:SetScale(Oof)
			util.Effect("eff_jack_gmod_faebomb_main", Sploom, true, true)
		end)

		self:Remove()
	end

	function ENT:OnRemove()
	end

	--
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			--WireLib.TriggerOutput(self, "Guided", self:GetGuided())
		end

		JMod.AeroDrag(self, self:GetForward())
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

	language.Add("ent_jack_gmod_ezthermobaric", "EZ Thermobaric Bomb")
end
