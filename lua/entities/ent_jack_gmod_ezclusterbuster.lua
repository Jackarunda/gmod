-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "AdventureBoots, Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "A bomb that deploys seeking anti-tank skeets"
ENT.PrintName = "EZ Cluster Buster" -- this is effectively a miniature CBU-97
ENT.Spawnable = true
ENT.AdminOnly = false
---
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.EZrackOffset = Vector(0, 0, 10)
ENT.EZrackAngles = Angle(0, 0, 90)
ENT.EZbombBaySize = 33
---
ENT.EZclusterBusterMunition = true
---
ENT.EZguidable = false
ENT.Model = "models/jmod/explosives/bombs/bomb_cbu.mdl"
ENT.Skin = 1
ENT.Mass = 200
ENT.DetSpeed = 700
ENT.DetType = "airburst"
ENT.Durability = 150

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

---
if SERVER then

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local Att = JMod.GetEZowner(self)
		local Vel, Pos, Ang = self:GetVelocity(), self:LocalToWorld(self:OBBCenter()), self:GetAngles()
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		self:Remove()
		JMod.Sploom(Att, Pos, 50)

		timer.Simple(0, function()
			local SpawnDirs = {Vector(-1, 0, 0), Vector(1, 0, 0), Vector(0, -1, 0), Vector(0, 1, 0)}

			for i = 1, 4 do
				local Bomblet = ents.Create("ent_jack_gmod_ezclusterbuster_sub")
				JMod.SetEZowner(Bomblet, Att)
				Bomblet:SetPos(Pos + SpawnDirs[i] * 30)
				Bomblet:SetAngles(VectorRand():Angle())
				Bomblet:Spawn()
				Bomblet:Activate()
				Bomblet:GetPhysicsObject():SetVelocity(Vel + SpawnDirs[i] * 700 + Vector(0, 0, math.random(100, 200)))
			end
		end)
	end

	function ENT:AeroDragThink()

		local Phys = self:GetPhysicsObject()
		if (self:GetState() == STATE_ARMED) and (Phys:GetVelocity():Length() > 400) and not self:IsPlayerHolding() and not constraint.HasConstraints(self) then
			self.FreefallTicks = self.FreefallTicks + 1

			if self.FreefallTicks >= 5 then
				local Tr = util.QuickTrace(self:GetPos(), Phys:GetVelocity():GetNormalized() * 4000, self)

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

	language.Add("ent_jack_gmod_ezblubomb", "EZ Cluster Buster")
end
