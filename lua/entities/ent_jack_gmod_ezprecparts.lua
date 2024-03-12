-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Precision Parts Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/precision parts.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/resources/hard_case_b.mdl"
ENT.Material = nil
ENT.ModelScale = 1
ENT.Mass = 30
ENT.ImpactNoise1 = "drywall.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"

if CLIENT then
    local drawvec, drawang = Vector(0, 3.5, 1), Angle(-90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .035, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
