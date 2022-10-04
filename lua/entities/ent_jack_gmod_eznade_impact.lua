-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZminiNade-Impact"
ENT.Category = "JMod - EZ Explosives"
ENT.Spawnable = true
ENT.Material = "models/mats_jack_nades/gnd_blk"
ENT.MiniNadeDamage = 100

ENT.Hints = {"mininade"}

local BaseClass = baseclass.Get(ENT.Base)

if SERVER then
	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 200 and self:GetState() == JMod.EZ_STATE_ARMED then
			self:Detonate()
		else
			BaseClass.PhysicsCollide(self, data, physobj)
		end
	end

	function ENT:Arm()
		self:SetState(JMod.EZ_STATE_ARMING)
		self:SetBodygroup(2, 1)

		timer.Simple(.3, function()
			if IsValid(self) then
				self:SetState(JMod.EZ_STATE_ARMED)
			end
		end)

		self:SpoonEffect()
	end

	function ENT:CustomThink(state, tim)
		if state == JMod.EZ_STATE_ARMED then
			if IsValid(self.AttachedBomb) then
				if self.AttachedBomb:IsPlayerHolding() then
					self.NextDet = tim + .5
				end

				local CurVel = self.AttachedBomb:GetPhysicsObject():GetVelocity()
				local Change = CurVel:Distance(self.LastVel)
				self.LastVel = CurVel

				if Change > 300 then
					if self.NextDet < tim then
						self:Detonate()
					end

					return
				end

				self:NextThink(tim + .1)

				return true
			end
		end
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_eznade_impact", "EZminiNade-Impact")
end
