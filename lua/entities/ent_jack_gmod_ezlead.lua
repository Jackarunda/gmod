-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Lead Ingot"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/lead.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.LEAD
ENT.JModPreferredCarryAngles = Angle(180, 90, -90)
ENT.Model = "models/props_mining/ingot001.mdl"
ENT.Material = "models/props_mining/ingot_jack_lead"
ENT.Color = Color(50, 50, 60)
ENT.ModelScale = 1
ENT.Mass = 80
ENT.ImpactNoise1 = "SolidMetal.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "SolidMetal.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- it's metal
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -3, 4.9), Angle(0, 0, 0), .025, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.LEAD, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
