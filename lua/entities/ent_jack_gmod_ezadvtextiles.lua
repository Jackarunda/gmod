-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Advanced Textile Roll"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/advanced textiles.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES
ENT.JModPreferredCarryAngles = Angle(0, -90, 100)
ENT.Model = "models/XQM/cylinderx1.mdl"
ENT.Material = "models/mat_jack_gmod_advtextileroll"
ENT.Color = Color(200, 200, 200)
ENT.ModelScale = 1.5
ENT.Mass = 60
ENT.ImpactNoise1 = "Flesh.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Flesh.ImpactSoft"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end

	-- todo: find a particle effect for this
	function ENT:CustomThink()
		self:SetMaterial(self.Material)
		local Col = self:GetColor()
		local R = math.Clamp(Col.r + math.random(-10, 10), 0, 255)
		local G = math.Clamp(Col.g + math.random(-10, 10), 0, 255)
		local B = math.Clamp(Col.b + math.random(-10, 10), 0, 255)
		self:SetColor(Color(R, G, B))
		self:NextThink(CurTime() + math.Rand(.5, 1.5))

		return true
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 2.5, 9), Angle(0, 0, 0), .017, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES, self:GetResource(), nil, 0, 0, 200, false, nil, 200)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
