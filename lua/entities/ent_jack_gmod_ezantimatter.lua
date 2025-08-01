-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Antimatter"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/antimatter.png"
ENT.Spawnable = true
ENT.AdminOnly = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.ANTIMATTER
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/thedoctor/darkmatter.mdl"
ENT.ModelScale = 1
-- 10 micrograms
ENT.Mass = 100
ENT.ImpactNoise1 = "Canister.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.ImpactSensitivity = 800
ENT.DamageThreshold = 50
ENT.BreakNoise = "Metal_Box.Break"
ENT.Hint = "antimatter"

---
if SERVER then
	function ENT:UseEffect(pos, ent, destructive)
		if destructive and not self.Sploomd then
			local Resources = self:GetResource()
			self.Sploomd = true
			JMod.AntimatterExplosion(pos, attacker, (Resources / 100))

			JMod.WreckBuildings(self, pos, 15 * (Resources / 100), 1, false)
		end
	end

	function ENT:AltUse(ply)
	end
	--
elseif CLIENT then
    local drawvec, drawang = Vector(1, -6.2, 8), Angle(90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .02, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.ANTIMATTER, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
