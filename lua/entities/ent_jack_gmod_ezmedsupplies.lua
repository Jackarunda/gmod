﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Medical Supplies Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/medical supplies.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES
ENT.JModPreferredCarryAngles = Angle(0, 180, 180)
ENT.SpawnAngle = Angle(0, 0, 180)
ENT.Model = "models/jmod/resources/hard_case_b.mdl"
ENT.Material = "models/kali/props/cases/hardcase/jardcase_b"
ENT.ModelScale = 1
ENT.Mass = 30
ENT.ImpactNoise1 = "drywall.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"

ENT.PropModels = {"models/jmod/items/healthkit.mdl", "models/healthvial.mdl", "models/jmod/items/medjit_medium.mdl", "models/jmod/items/medjit_small.mdl", "models/weapons/w_models/w_bonesaw.mdl", "models/bandages.mdl"}

-- todo: missing texture
---
if SERVER then
	function ENT:AltUse(ply)
		local Wep = ply:GetActiveWeapon()

		if Wep and Wep.EZaccepts and (table.HasValue(Wep.EZaccepts, self.EZsupplies)) then
			local ExistingAmt = Wep:GetSupplies()
			local Missing = Wep.EZmaxSupplies - ExistingAmt

			if Missing > 0 then
				local AmtToGive = math.min(Missing, self:GetResource())
				Wep:SetSupplies(ExistingAmt + AmtToGive)
				sound.Play("items/ammo_pickup.wav", self:GetPos(), 65, math.random(90, 110))
				self:SetResource(self:GetResource() - AmtToGive)

				if self:GetResource() <= 0 then
					self:Remove()

					return
				end
			end
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 3.4, 0), Angle(-90, 0, -90), .045, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES, self:GetResource(), nil, 0, 0, 200, true, "JMod-Stencil-MS")
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
