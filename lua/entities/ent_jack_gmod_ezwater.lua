﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Water Drum"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/water.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.WATER
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/jmod/resources/water_barrel.mdl"
--ENT.Material="models/shiny"
--ENT.Color=Color(50,120,180)
ENT.SpawnHeight = 30
ENT.ModelScale = 1
ENT.Mass = 40
ENT.MinimumMass = 10
ENT.ImpactNoise1 = "Plastic_Barrel.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Plastic_Barrel.Break"

--ENT.Hint="coolant"
---
if SERVER then
	function ENT:UseEffect(pos, ent)
		local FX = EffectData()
		FX:SetOrigin(pos)
		FX:SetScale(2)
		util.Effect("WaterSplash", FX, true, true)
	end
	function ENT:CustomImpact(data, physobj)
		if data.HitEntity:IsOnFire() and (self:GetResource() > 1) then
			local WatLeftOver = self:GetResource() - 2
			self:SetEZsupplies(self.EZsupplies, WatLeftOver)
			JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.WATER, data.HitPos, nil, 10, 1, 1)
			data.HitEntity:Extinguish()
			self:Extinguish()
		end
	end
	local EntsToRemove = {["ent_jack_gmod_eznapalm"] = true, ["ent_jack_gmod_ezfirehazard"] = true}
	function ENT:AltUse(ply)
		local UsedWater = 0
		for k, v in ipairs(ents.FindInSphere(self:GetPos(), 100)) do
			if IsValid(v) and JMod.ClearLoS(self, v, false, 35) then
				if v:IsOnFire() then 
					v:Extinguish()
					UsedWater = UsedWater + math.random(1, 3)
				end
				if EntsToRemove[v:GetClass()] and math.random(1, 3) >= 2 then
					SafeRemoveEntity(v)
					UsedWater = UsedWater + math.random(1, 3)
				end
				v:RemoveAllDecals()
			end
		end
		if UsedWater > 0 then
			local FX = EffectData()
			FX:SetOrigin(self:GetPos() + self:GetUp() * 20)
			FX:SetScale(2)
			util.Effect("WaterSplash", FX, true, true)
			self:SetEZsupplies(JMod.EZ_RESOURCE_TYPES.WATER, self:GetResource() - UsedWater)
		end
	end
elseif CLIENT then
	local TxtCol = Color(255, 255, 255, 80)
    local drawvec, drawang = Vector(0, -10.8, 0), Angle(90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.WATER, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
