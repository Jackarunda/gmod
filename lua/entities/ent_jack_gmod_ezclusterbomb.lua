-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Cluster Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZrackOffset = Vector(0, -5, 6)
ENT.EZrackAngles = Angle(0, 90, 0)
ENT.EZbombBaySize = 5
ENT.EZguidable = false
---
ENT.Model = "models/props_phx/ww2bomb.mdl"
ENT.Material = "models/entities/mat_jack_clusterbomb"
ENT.Mass = 100
ENT.DetSpeed = 1000
ENT.DetType = "airburst"

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 30), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 100)
		---
		local Vel, Pos = self:GetPhysicsObject():GetVelocity(), self:LocalToWorld(self:OBBCenter())

		---
		timer.Simple(0, function()
			for i = 1, 50 do
				local Bomblet = ents.Create("ent_jack_gmod_ezbomblet")
				JMod.SetEZowner(Bomblet, Att)
				Bomblet:SetPos(Pos + VectorRand() * math.Rand(1, 50))
				Bomblet:Spawn()
				Bomblet:Activate()
				Bomblet:GetPhysicsObject():SetVelocity(Vel + VectorRand() * math.Rand(10, 1500) + Vector(0, 0, math.random(1, 100)))
			end
		end)

		---
		self:Remove()
	end
	--
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:AeroDragThink()
		local Phys = self:GetPhysicsObject()

		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 10 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 1500, self)

				if Tr.Hit and not(Tr.HitSky) then
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

	language.Add("ent_jack_gmod_ezclusterbomb", "EZ Cluster Bomb")
end
