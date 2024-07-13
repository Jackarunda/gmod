-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ White Phosphorus Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZRackOffset = Vector(0, 0, 10)
ENT.EZRackAngles = Angle(0, 0, 0)
ENT.EZbombBaySize = 5
---
ENT.EZguidable = false
ENT.Model = "models/props_phx/ww2bomb.mdl"
ENT.Material = "models/entities/mat_jack_wpinbomb"
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

		---
		local Owner = JMod.GetEZowner(self)
		for i = 1, 25 do
			timer.Simple(i / 50, function()
				local FireAng = (Dir + VectorRand() * .35 + Vector(0, 0, math.Rand(.01, .7))):Angle()
				local Flame = ents.Create("ent_jack_gmod_eznapalm")
				Flame.Creator = self
				Flame:SetPos(SelfPos)
				Flame:SetAngles(FireAng)
				Flame:SetOwner(self)
				JMod.SetEZowner(Flame, Owner)
				Flame.InitialVel = Dir * Speed
				Flame.HighVisuals = math.random(1, 5) == 1
				Flame:Spawn()
				Flame:Activate()
			end)
		end
		for i = 1, 20 do
			timer.Simple(i / 10, function()
				local FireDir = (Dir + VectorRand() * .35 + Vector(0, 0, math.Rand(.01, .7)))
				local Gas = ents.Create("ent_jack_gmod_ezwpincendiaryparticle")
				Gas.Creator = self
				Gas:SetPos(SelfPos)
				Gas:SetOwner(self)
				JMod.SetEZowner(Gas, Owner)
				Gas.CurVel = FireDir * Speed
				Gas.Canister = self
				Gas:Spawn()
				Gas:Activate()
				Gas.AffectRange = 500
				Gas.MaxLife = math.random(50, Gas.MaxLife)
			end)
		end

		---
		timer.Simple(0, function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end

	function ENT:AeroDragThink()

		local Phys = self:GetPhysicsObject()

		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 10 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 1000, self)

				if Tr.Hit then
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
