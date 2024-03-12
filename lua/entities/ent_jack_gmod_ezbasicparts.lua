-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Basic Parts Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/basic parts.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.BASICPARTS
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/resources/jack_crate.mdl"
ENT.Material = "models/mat_jack_gmod_ezparts"
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Wood_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Wood_Box.Break"

---
if SERVER then
	--[[function ENT:UseEffect(pos, ent)
		local effectdata = EffectData()
		effectdata:SetOrigin(pos + VectorRand())
		effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(1, 2)) --length of strands
		effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
	end]]--

	function ENT:AltUse(ply)
		local Wep = ply:GetActiveWeapon()

		if Wep and Wep.EZaccepts and (table.HasValue(Wep.EZaccepts, self.EZsupplies)) then
			local ExistingAmt = Wep:GetBasicParts()
			local Missing = Wep.EZmaxBasicParts - ExistingAmt

			if Missing > 0 then
				local AmtToGive = math.min(Missing, self:GetResource())
				Wep:SetBasicParts(ExistingAmt + AmtToGive)
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
    local drawvec, drawang = Vector(0.5, 13, 10), Angle(-90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .043, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.BASICPARTS, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
