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
ENT.Model = "models/jmod/resources/ez_wood.mdl"
--ENT.Material = "phoenix_storms/wood_dome"
ENT.Color = Color(100, 100, 100)
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Wood.ImpactHard"
ENT.DamageThreshold = 90
ENT.BreakNoise = "Wood.Break"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
		for i = 1, 1 * JMod.Config.Machines.SupplyEffectMult do
			local Eff = EffectData()
			Eff:SetOrigin(pos)
			Eff:SetEntity(ent)
			Eff:SetStart(Vector(0, 0, 0))
			--util.Effect("eff_jack_gmod_woodsplode", Eff, true, true)
		end
	end
	function ENT:CustomThink()
		if self:IsOnFire() then
			local WoodLeft = self:GetResource()
			if WoodLeft <= 2 then
				JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, self:GetResource() / self.MaxResource, 1, 1)
				self:Remove()
			else
				self:SetEZsupplies(self.EZsupplies, WoodLeft - math.random(0, 2), self)
			end
		end
	end
elseif CLIENT then
    local drawvec, drawang = Vector(0, -12.5, 1), Angle(90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .05, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.WOOD, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
