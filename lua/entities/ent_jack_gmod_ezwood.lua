-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Wood"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/wood.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.WOOD
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/hunter/blocks/cube05x05x05.mdl"
ENT.Material = "phoenix_storms/wood_dome"
ENT.Color = Color(100, 100, 100)
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Wood.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Wood.Break"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 1 * JMod.Config.SupplyEffectMult do
			local Eff = EffectData()
			Eff:SetOrigin(pos)
			Eff:SetEntity(ent)
			Eff:SetStart(Vector(0, 0, 0))
			util.Effect("eff_jack_gmod_woodsplode", Eff, true, true)
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -12, 1), Angle(90, 0, 90), .05, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.WOOD, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
