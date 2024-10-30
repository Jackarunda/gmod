-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Chemicals"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/chemicals.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.CHEMICALS
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/resources/plastic_crate25a.mdl"
ENT.Material = nil

ENT.RandomSkins = {0, 1, 2, 3, 4}

ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Plastic_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Plastic_Box.Break"
ENT.Hint = nil
ENT.Flammable = 2
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

			if destructive then
				for i = 1, 1 do
					local Blob = ents.Create("grenade_spit")
					Blob:SetPos(pos)
					Blob:SetAngles(VectorRand():Angle())
					Blob:SetVelocity((VectorRand() + vector_up) * math.Rand(0, 500))
					Blob:SetOwner(game.GetWorld())
					Blob:Spawn()
					Blob:Activate()
				end
			end
		end
	end

	function ENT:AltUse(ply)
	end
	--
elseif CLIENT then
	local TxtCol = Color(10, 10, 10, 250)

	function ENT:Initialize()
		self.Jug1 = JMod.MakeModel(self, "models/props_junk/garbage_plasticbottle001a.mdl", "models/debug/debugwhite")
		self.Jug2 = JMod.MakeModel(self, "models/props_junk/garbage_plasticbottle002a.mdl", "models/debug/debugwhite")
		self.Jug3 = JMod.MakeModel(self, "models/props_junk/garbage_milkcarton001a.mdl", "models/debug/debugwhite")
		self.Jug4 = JMod.MakeModel(self, "models/props_junk/garbage_plasticbottle003a.mdl", "models/debug/debugwhite")
		self.Jug5 = JMod.MakeModel(self, "models/props_junk/garbage_plasticbottle003a.mdl", "models/debug/debugwhite")
		self.Jug6 = JMod.MakeModel(self, "models/props_junk/metal_paintcan001a.mdl", "phoenix_storms/gear_top")
		self.Jug7 = JMod.MakeModel(self, "models/props_junk/garbage_glassbottle001a.mdl", "models/props_combine/health_charger_glass")
		self.Jug8 = JMod.MakeModel(self, "models/props_junk/glassjug01.mdl", "models/props_combine/health_charger_glass", 1.5)
	end
    local drawvec, drawang = Vector(-1, 11, 0), Angle(-90, 0, 90)
	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
		self:DrawModel()
		local BasePos = Pos + Up * 2
		local JugAng = Ang:GetCopy()
		JMod.RenderModel(self.Jug1, BasePos + Forward * 5.5 + Right * 10, Ang)
		JMod.RenderModel(self.Jug2, BasePos + Forward * 7, Ang)
		JMod.RenderModel(self.Jug3, BasePos - Forward * 4 - Up * 2 - Right * 9, Ang)
		JMod.RenderModel(self.Jug4, BasePos - Forward * 6, Ang)
		JMod.RenderModel(self.Jug5, BasePos + Forward * 1 + Right * 1, Ang)
		JMod.RenderModel(self.Jug6, BasePos - Forward * 4.5 + Right * 9 - Up * 3, Ang)
		JMod.RenderModel(self.Jug7, BasePos + Forward * 3 - Right * 4 - Up * 2, Ang)
		JMod.RenderModel(self.Jug8, BasePos + Forward * 6 - Right * 10 - Up * 10, Ang)

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.CHEMICALS, self:GetResource(), nil, 0, 0, 200, false, nil, 220)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
