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
ENT.Model = "models/kali/props/cases/hard case b.mdl"
ENT.Material = nil
ENT.ModelScale = 1
ENT.Mass = 30
ENT.ImpactNoise1 = "drywall.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"

ENT.PropModels = {"models/props_lab/reciever01d.mdl", "models/props/cs_office/computer_caseb_p2a.mdl", "models/props/cs_office/computer_caseb_p3a.mdl", "models/props/cs_office/computer_caseb_p4a.mdl", "models/props/cs_office/computer_caseb_p5a.mdl", "models/props/cs_office/computer_caseb_p5b.mdl", "models/props/cs_office/computer_caseb_p6a.mdl", "models/props/cs_office/computer_caseb_p6b.mdl", "models/props/cs_office/computer_caseb_p7a.mdl", "models/props/cs_office/computer_caseb_p8a.mdl", "models/props/cs_office/computer_caseb_p9a.mdl"}

---
if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 1 * JMod.Config.SupplyEffectMult do
			self:FlingProp(table.Random(self.PropModels))
		end

		local effectdata = EffectData()
		effectdata:SetOrigin(pos + VectorRand())
		effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(1, 2)) --length of strands
		effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 3.5, 10), Angle(-90, 0, 90), .035, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
