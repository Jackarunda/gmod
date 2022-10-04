-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Plastic Block"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/plastic.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.PLASTIC
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/hunter/blocks/cube05x05x05.mdl"
ENT.Material = ""
ENT.Color = Color(200, 200, 200)
ENT.ModelScale = 1
ENT.Mass = 20
ENT.ImpactNoise1 = "Plastic_Box.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Plastic_Box.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- it's plastic
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -11.9, 5), Angle(90, 0, 90), .033, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.PLASTIC, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
