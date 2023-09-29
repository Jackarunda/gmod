-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Nutrient Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/nutrients.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.NUTRIENTS
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/props_junk/cardboard_box003a.mdl"
ENT.Material = "models/mat_jack_gmod_ezammobox"
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Cardboard.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Cardboard_Box.Break"
ENT.Hint = "eat"

---

if SERVER then

	function ENT:AltUse(ply)
		ply.EZnutrition = ply.EZnutrition or {
			NextEat = 0,
			Nutrients = 0
		}

		local Time = CurTime()

		if ply.EZnutrition.NextEat < Time then
			if ply.EZnutrition.Nutrients < 100 then
				for i = 0, 3 do
					timer.Simple(i / 4, function()
						if IsValid(ply) then
							if math.random(1, 2) == 1 then
								ply:EmitSound("snd_jack_eat" .. tostring(math.random(1, 9)) .. ".wav", 75, math.Rand(90, 110))
							else
								ply:EmitSound("snd_jack_drink" .. tostring(math.random(1, 2)) .. ".wav", 75, math.Rand(90, 110))
							end
						end
					end)
				end

				JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, 1, self:GetResource() / 100, 1)
				local AmtToRemove = math.min(10, self:GetResource())
				self:SetResource(self:GetResource() - AmtToRemove)

				JMod.ConsumeNutrients(ply, AmtToRemove * 2)

				if self:GetResource() <= 0 then
					self:Remove()
				end

				if ply.EZvirus and ply.EZvirus.Severity > 1 then
					if ply.EZvirus.InfectionWarned then
						ply:PrintMessage(HUD_PRINTCENTER, "immune system boosted")
					end

					ply.EZvirus.Severity = math.Clamp(ply.EZvirus.Severity - 10, 1, 9e9)
				end
			else
				JMod.Hint(activator, "nutrition filled")
			end
		else
			JMod.Hint(activator, "can not eat")
		end
	end
elseif CLIENT then
	local TxtCol = Color(255, 255, 255, 80)

	function ENT:Initialize()
		self.FoodBox = ClientsideModel("models/props/cs_office/cardboard_box03.mdl")
		self.FoodBox:SetMaterial("models/mat_jack_aidfood")
		self.FoodBox:SetParent(self)
		self.FoodBox:SetNoDraw(true)
		self.WaterBox = ClientsideModel("models/props/cs_office/cardboard_box03.mdl")
		self.WaterBox:SetMaterial("models/mat_jack_aidwater")
		self.WaterBox:SetParent(self)
		self.WaterBox:SetNoDraw(true)
	end

	function ENT:Draw()
		local Ang, Pos, Up, Right, Forward = self:GetAngles(), self:GetPos(), self:GetUp(), self:GetRight(), self:GetForward()
		self.FoodBox:SetRenderOrigin(Pos - Right * 9 - Up * 9 + Forward * 5)
		self.WaterBox:SetRenderOrigin(Pos + Right * 4 - Up * 9 + Forward * 5)
		local BoxAng = Ang:GetCopy()
		BoxAng:RotateAroundAxis(Up, 90)
		self.FoodBox:SetRenderAngles(BoxAng)
		self.WaterBox:SetRenderAngles(BoxAng)
		self.FoodBox:DrawModel()
		self.WaterBox:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(-3, 18, -2.8), Angle(-90, 0, 90), .033, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.NUTRIENTS, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
