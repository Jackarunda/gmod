-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Paper Ream"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/paper.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.PAPER
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.Model = "models/jmod/resources/ez_paper.mdl"
--ENT.Material = "models/mat_jack_gmod_paperroll"
ENT.PhysMat = "paper"
ENT.Color = Color(200, 200, 200)
--ENT.ModelScale=1.5
ENT.Mass = 30
ENT.ImpactNoise1 = "Flesh.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Flesh.ImpactSoft"
ENT.Flammable = 2

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end
	-- todo: find a particle effect for this
elseif CLIENT then
    local drawvec, drawang = Vector(6.4, -.5, 0), Angle(0, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .025, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.PAPER, self:GetResource(), nil, 0, 0, 200, false, nil, 200, nil, 0)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
