-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Incendiary Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZrackOffset = Vector(0, 0, 10)
ENT.EZrackAngles = Angle(0, 0, 0)
ENT.EZbombBaySize = 5
---
ENT.EZguidable = false
ENT.Model = "models/props_phx/ww2bomb.mdl"
ENT.Material = "models/entities/mat_jack_firebomb"
ENT.Mass = 100
ENT.DetSpeed = 1000
ENT.DetType = "airburst"

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

---
if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 100)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 1000)
		---
		local Dir = self:GetPhysicsObject():GetVelocity():GetNormalized()
		local Speed = math.Clamp(self:GetPhysicsObject():GetVelocity():Length(), 0, self.DetSpeed * .5)
		---
		local Sploom = EffectData()
		Sploom:SetOrigin(SelfPos)
		Sploom:SetScale(.6)
		Sploom:SetNormal(Dir)
		util.Effect("eff_jack_firebomb", Sploom, true, true)

		JMod.FireSplosion(SelfPos, Dir * Speed, 100, 2, 1, false, self)

		---
		timer.Simple(0, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end

	function ENT:AeroDragThink()

		local Phys = self:GetPhysicsObject()

		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not(self:IsPlayerHolding() or constraint.HasConstraints(self)) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 10 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 800, self)

				if Tr.Hit and not Tr.HitSky then
					self:Detonate()
				end
			end
		else
			self.FreefallTicks = 0
		end

		JMod.AeroDrag(self, self:GetForward())
		self:NextThink(CurTime() + .1)

		return true
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

	language.Add("ent_jack_gmod_ezincendiarybomb", "EZ Incendiary Bomb")
end
