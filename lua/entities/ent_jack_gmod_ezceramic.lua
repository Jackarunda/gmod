-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Ceramic Block"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/ceramic.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.CERAMIC
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/hunter/blocks/cube05x05x05.mdl"
ENT.Material = "models/props_building_details/courtyard_template001c_bars"
ENT.Color = Color(200, 177, 120)
ENT.ModelScale = 1
ENT.Mass = 80
ENT.ImpactNoise1 = "Concrete_Block.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Concrete_Block.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- it's ceramic
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -12, 0), Angle(90, 0, 90), .06, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.CERAMIC, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
