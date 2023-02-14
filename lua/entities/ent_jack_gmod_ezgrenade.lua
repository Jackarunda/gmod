﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Grenade Base"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.Model = "models/weapons/w_grenade.mdl"
ENT.Material = nil
ENT.ModelScale = nil
ENT.HardThrowStr = 500
ENT.SoftThrowStr = 250
ENT.Mass = 10
ENT.ImpactSound = "Grenade.ImpactHard"
ENT.SpoonEnt = "ent_jack_spoon"
ENT.SpoonModel = nil
ENT.SpoonScale = nil
ENT.SpoonSound = nil
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.JModEZstorable = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetOwner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel(self.Model)

		if self.Material then
			self:SetMaterial(self.Material)
		end

		if self.ModelScale then
			self:SetModelScale(self.ModelScale, 0)
		end

		if self.Color then
			self:SetColor(self.Color)
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)

		---
		timer.Simple(.01, function()
			if IsValid(self) then
				self:GetPhysicsObject():SetMass(self.Mass)
				self:GetPhysicsObject():Wake()
			end
		end)

		---
		self:SetState(JMod.EZ_STATE_OFF)
		self.NextDet = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed \n 0 is not \n -1 is broken"})
		end
		if self.CustomInit then
			self:CustomInit()
		end
	end

	function ENT:TriggerInput(iname, value)
		if (iname == "Detonate") and (value ~= 0) then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 30 then
			self:EmitSound(self.ImpactSound)
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.Exploded then return end
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if Dmg >= 4 then
			local Pos, State, DetChance = self:GetPos(), self:GetState(), 0

			if dmginfo:IsDamageType(DMG_BLAST) then
				DetChance = DetChance + Dmg / 150
			end

			if math.Rand(0, 1) < DetChance then
				self:Detonate()
			end

			if (math.random(1, 10) == 3) and not (State == JMod.EZ_STATE_BROKEN) then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		if self.Exploded then return end
		local Dude = activator or activatorAgain
		JMod.SetOwner(self, Dude)
		JMod.Hint(Dude, self.ClassName)
		local Time = CurTime()
		if self.ShiftAltUse and Dude:KeyDown(JMod.Config.AltFunctionKey) and Dude:KeyDown(IN_SPEED) then return self:ShiftAltUse(Dude, tobool(onOff)) end

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = Dude:KeyDown(JMod.Config.AltFunctionKey)

			if State == JMod.EZ_STATE_OFF and Alt then
				self:Prime()
				JMod.Hint(Dude, "grenade")
			else
				JMod.Hint(Dude, "prime")
			end

			if self.Hints then
				for k, v in pairs(self.Hints) do
					timer.Simple(k, function()
						if IsValid(Dude) then
							JMod.Hint(Dude, v)
						end
					end)
				end
			end

			JMod.ThrowablePickup(Dude, self, self.HardThrowStr, self.SoftThrowStr)
		end
	end

	function ENT:SpoonEffect()
		if self.SpoonEnt then
			local Spewn = ents.Create(self.SpoonEnt)

			if self.SpoonModel then
				Spewn.Model = self.SpoonModel
			end

			if self.SpoonScale then
				Spewn.ModelScale = self.SpoonScale
			end

			if self.SpoonSound then
				Spewn.Sound = self.SpoonSound
			end

			Spewn:SetPos(self:GetPos())
			Spewn:Spawn()
			Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity() + VectorRand() * 250)
			self:EmitSound("snd_jack_spoonfling.wav", 60, math.random(90, 110))
		end
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end

		local State, Time = self:GetState(), CurTime()

		if self.CustomThink then
			self:CustomThink(State, Time)
		end

		if self.Exploded then return end

		if IsValid(self) then
			if State == JMod.EZ_STATE_PRIMED and not self:IsPlayerHolding() then
				self:Arm()
			end
		end

		if State == JMod.EZ_STATE_ARMED then
			JMod.EmitAIsound(self:GetPos(), 500, .5, 8)
			self:NextThink(Time + .5)

			return true
		end
	end

	function ENT:Prime()
		self:SetState(JMod.EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav", 60, 100)
		self:SetBodygroup(1, 1)
	end

	function ENT:Arm()
		self:SetBodygroup(2, 1)
		self:SetState(JMod.EZ_STATE_ARMED)
		self:SpoonEffect()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		self:Remove()
	end
end
