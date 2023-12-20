-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Aluminum Ingot"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/aluminum.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.ALUMINUM
ENT.JModPreferredCarryAngles = Angle(180, 90, -90)
ENT.Model = "models/jmod/resources/ingot001.mdl"
ENT.Material = "models/props_mining/ingot_jack_aluminum"
ENT.Color = Color(180, 180, 180)
ENT.ModelScale = 1
ENT.Mass = 20
ENT.ImpactNoise1 = "SolidMetal.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "SolidMetal.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- it's metal
elseif CLIENT then
    local drawvec, drawang = Vector(0, -3, 4.9), Angle(0, 0, 0)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .025, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.ALUMINUM, self:GetResource(), nil, 0, 0, 200, false, nil, nil, nil, 0)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
