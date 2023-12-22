﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Fissile Material"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/fissile material.png"
ENT.Spawnable = true
ENT.AdminOnly = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/kali/props/cases/hard case c.mdl"
ENT.ModelScale = 1
ENT.Skin = 2
ENT.Mass = 150
ENT.ImpactNoise1 = "Canister.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 1500
ENT.BreakNoise = "Metal_Box.Break"

---
if SERVER then
	function ENT:UseEffect(pos, ent, destructive)
		if destructive and not self.Sploomd then
			self.Sploomd = true
			local Owner, Count = self.EZowner, self:GetResource() / 10

			timer.Simple(.5, function()
				for i = 1, JMod.Config.Particles.NuclearRadiationMult * Count * 10 do
					timer.Simple(i * .05, function()
						local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
						Gas.Range = 500
						Gas:SetPos(pos)
						JMod.SetEZowner(Gas, Owner or game.GetWorld())
						Gas:Spawn()
						Gas:Activate()
						Gas.CurVel = (VectorRand() * math.random(1, 1000) + Vector(0, 0, 100 * JMod.Config.Particles.NuclearRadiationMult))
					end)
				end
			end)
		end
	end

	function ENT:AltUse(ply)
	end
	--
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 0, 21.75), Angle(0, 90, 0), .06, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
