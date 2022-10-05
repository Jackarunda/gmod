-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Paper Roll"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/paper.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.PAPER
ENT.JModPreferredCarryAngles = Angle(0, -90, 100)
ENT.Model = "models/jmodels/resources/cylinderx15.mdl"
ENT.Material = "models/mat_jack_gmod_paperroll"
ENT.Color = Color(200, 200, 200)
--ENT.ModelScale=1.5
ENT.Mass = 30
ENT.ImpactNoise1 = "Flesh.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Flesh.ImpactSoft"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- todo: find a particle effect for this
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -.5, 9), Angle(0, 0, 0), .025, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.PAPER, self:GetResource(), nil, 0, 0, 200, false, nil, 200, nil, 0)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
