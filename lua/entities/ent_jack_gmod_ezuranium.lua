-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Uranium Ingot"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/uranium.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.URANIUM
ENT.JModPreferredCarryAngles = Angle(180, 90, -90)
ENT.Model = "models/jmod/resources/ingot001.mdl"
ENT.Material = "models/props_mining/ingot_jack_uranium"
ENT.Color = Color(50, 55, 50)
ENT.ModelScale = 1
ENT.Mass = 100
ENT.ImpactNoise1 = "SolidMetal.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "SolidMetal.ImpactHard"

---
if SERVER then
	function ENT:UseEffect(pos, ent)
	end

	-- it's metal
	function ENT:CustomThink()
		if math.random(1, 200) <= self:GetResource() then
			local Ent = ents.Create("ent_jack_gmod_ezfalloutparticle")
			Ent:SetPos(self:GetPos() + Vector(0, 0, 10))
			Ent.EZowner = self.EZowner
			Ent.MaxLife = 15
			Ent.AffectRange = 250
			Ent:Spawn()
			Ent:Activate()
			Ent.CurVel = self:GetVelocity()
		end

		self:NextThink(CurTime() + math.Rand(10, 20))

		return true
	end
elseif CLIENT then
    local drawvec, drawang = Vector(0, -3, 4.9), Angle(0, 0, 0)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .025, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.URANIUM, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
