-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "A N O M A L O U S  R E S O U R C E"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/anomaly resource.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true
---
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/resources/hard_case_b.mdl"
ENT.Material = nil
ENT.Color = Color(100, 100, 100)
ENT.ModelScale = 1
ENT.Mass = 50000
ENT.ImpactNoise1 = "drywall.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"

function ENT:GetEZsupplies(typ)
	if typ then
		return 9e9
	else
		local AllResTable = {}
		for _, res in pairs(JMod.EZ_RESOURCE_TYPES) do
			AllResTable[res] = 9e9
		end
		return AllResTable
	end
end

function ENT:SetEZsupplies(typ, amt, setter)
	if not SERVER then return end -- Important because this is shared as well
end

---
if SERVER then
	function ENT:CustomInit()
		self:SetResource(9e9)
	end

	function ENT:CustomThink()
		local Phys = self:GetPhysicsObject()
		Phys:ApplyForceCenter(VectorRand() * math.random(1, 1000 * (Phys:GetMass() / self.Mass)))
		self:NextThink(CurTime() + math.Rand(2, 4))

		return true
	end

	function ENT:Use(activator)
		local AltPressed, Count = JMod.IsAltUsing(activator), self:GetResource()

		if AltPressed then
			local Wep = activator:GetActiveWeapon()
			if IsValid(Wep) and Wep.TryLoadResource then
				local Used = {}
				for _, res in pairs(JMod.EZ_RESOURCE_TYPES) do
					local Consumed = Wep:TryLoadResource(res, Count)
					if Consumed > 0 then
						Used[res] = (Used[res] or 0) + Consumed
					end
				end

				for res, used in pairs(Used) do
					JMod.ResourceEffect(res, self:LocalToWorld(self:OBBCenter()), activator:LocalToWorld(activator:OBBCenter()), used / self.MaxResource, 1, 1)
				end
			end
		else
			JMod.Hint(activator, "resource manage")
			activator:PickupObject(self)

			if JMod.Hints[self:GetClass() .. " use"] then
				JMod.Hint(activator, self:GetClass() .. " use")
			end
		end
	end
elseif CLIENT then
    local drawvec, drawang = Vector(0, 3.5, 1), Angle(-90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .035, 300, function()
			JMod.StandardResourceDisplay("anomalous resource", nil, nil, 0, 0, 200, true)
			--draw.DrawText("T H E  R E S O U R C E", "JMod-Display", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
