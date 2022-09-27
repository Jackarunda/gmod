-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Rubber Puck"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/rubber.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.RUBBER
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/xqm/airplanewheel1medium.mdl"
ENT.Material = "phoenix_storms/road"
ENT.Color = Color(200, 200, 200)
ENT.ModelScale = 1
ENT.Mass = 30
ENT.ImpactNoise1 = "Rubber_Tire.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Rubber_Tire.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- it's rubber
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -9.5, 0), Angle(90, 0, 90), .05, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.RUBBER, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
