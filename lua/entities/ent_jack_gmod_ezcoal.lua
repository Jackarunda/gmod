-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Coal"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/coal.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.COAL
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/jmod/resources/resourcecube.mdl"
ENT.Material = "models/mat_jack_gmod_coal"
ENT.Color = Color(150, 150, 150)
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Rock.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Boulder.ImpactHard"
ENT.Flammable = 2

ENT.PropModels = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"}

---
if SERVER then
	function ENT:CustomThink()
		if self:IsOnFire() and JMod.Config.QoL.NiceFire then
			local Eff = EffectData()
			local Up = self:GetUp()
			Eff:SetOrigin(self:GetPos() + Up * 10)
			Eff:SetNormal(Up)
			Eff:SetScale(.05)
			util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)
		end
	end
elseif CLIENT then
    local drawvec, drawang = Vector(0, -12, 1), Angle(90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.COAL, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
