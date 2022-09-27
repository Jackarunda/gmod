-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Titanium Ore"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/titanium ore.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.TITANIUMORE
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/hunter/blocks/cube05x05x05.mdl"
ENT.Material = "models/mat_jack_gmod_titaniumore"
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Rock.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Boulder.ImpactHard"

ENT.PropModels = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"}

---
if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 1 * JMod.Config.SupplyEffectMult do
			self:FlingProp(table.Random(self.PropModels))
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, -12, 1), Angle(90, 0, 90), .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.TITANIUMORE, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
