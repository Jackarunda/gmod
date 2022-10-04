-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Glass Block"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/glass.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.GLASS
ENT.JModPreferredCarryAngles = Angle(-90, 0, 0)
ENT.Model = "models/hunter/blocks/cube05x05x025.mdl"
ENT.Material = "models/mat_jack_gmod_generic_glass"
ENT.Color = Color(200, 200, 200)
ENT.ModelScale = 1
ENT.Mass = 30
ENT.ImpactNoise1 = "Glass.ImpactHard"
ENT.DamageThreshold = 40
ENT.BreakNoise = "Glass.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 10 do
			local Eff = EffectData()
			Eff:SetOrigin(pos)
			Eff:SetEntity(ent)
			Eff:SetMagnitude(1)
			Eff:SetScale(1)
			Eff:SetNormal(VectorRand())
			util.Effect("GlassImpact", Eff, true, true)
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(-1, 0, 6), Angle(0, -90, 0), .035, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.GLASS, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
