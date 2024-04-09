-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Ammo Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/ammo.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.AMMO
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/jmod/items/BoxJRounds.mdl"
ENT.Material = "models/mat_jack_gmod_ezammobox"
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Metal_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"
ENT.Hint = "ammobox"

---
local ShellEffects = {"RifleShellEject", "PistolShellEject", "ShotgunShellEject"}

if SERVER then
	function ENT:UseEffect(pos, ent, destructive)
		for i = 1, 30 * JMod.Config.Machines.SupplyEffectMult do
			timer.Simple(i / 200, function()
				local Eff = EffectData()
				Eff:SetOrigin(pos)
				Eff:SetAngles((VectorRand() + Vector(0, 0, 1)):GetNormalized():Angle())
				Eff:SetEntity(ent)
				util.Effect(table.Random(ShellEffects), Eff, true, true)
			end)
		end
	end

	function ENT:AltUse(ply)
		JMod.GiveAmmo(ply, self)
	end
elseif CLIENT then
    local drawvec, drawang = Vector(1, 5, 9), Angle(-90, 0, 90)
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, drawvec, drawang, .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.AMMO, self:GetResource(), nil, 0, 0, 200, false)
		end)
	end

	--language.Add(ENT.ClassName, ENT.PrintName)
end
