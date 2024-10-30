-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Organics"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/organics.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.ORGANICS
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/resources/plastic_crate25a.mdl"
ENT.Material = nil

ENT.RandomSkins = {0, 1, 2, 3, 4}

--ENT.ModelScale=1.25
ENT.Mass = 50
ENT.ImpactNoise1 = "Plastic_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Plastic_Box.Break"
ENT.Hint = nil
ENT.Flammable = .5
ENT.PhysBox = {
	Mins = Vector(-11, -16, -9.3),
	Maxs = Vector(11, 16, 9.2)
}

---
if SERVER then
	function ENT:UseEffect(pos, ent, destructive)
		for i = 1, 3 do
			if math.random(1, 30) == 2 then
				local Eff = EffectData()
				Eff:SetOrigin(pos + VectorRand() * 10)
				util.Effect("StriderBlood", Eff, true, true)
			end
		end
	end

	function ENT:AltUse(ply)
	end
	--
elseif CLIENT then
	local TxtCol = Color(10, 10, 10, 250)

	local Mats = {"models/mat_jack_gmod_grainblock", "models/mat_jack_gmod_beanblock"}

	function ENT:Initialize()
		self.Stuff = JMod.MakeModel(self, "models/props_junk/cardboard_box003a.mdl", table.Random(Mats), .97)
	end
    local drawvec, drawang = Vector(-1, 11, 0), Angle(-90, 0, 90)
	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		self:DrawModel()
		local BasePos = Pos + Up * 2
		local JugAng = Ang:GetCopy()
		JMod.RenderModel(self.Stuff, BasePos - Forward * 5 + Right * 1.5, Ang)

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.ORGANICS, self:GetResource(), nil, 0, 0, 200, false, nil, 220)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
