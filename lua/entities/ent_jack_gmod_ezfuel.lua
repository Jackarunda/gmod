-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Fuel Can"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/fuel.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.FUEL
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.Model = "models/props_junk/gascan001a.mdl"
ENT.Material = nil
ENT.ModelScale = 1
ENT.Mass = 50
ENT.ImpactNoise1 = "Weapon.ImpactSoft"
ENT.ImpactNoise2 = "Metal_Box.ImpactHard"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Box.Break"
ENT.Hint = nil

---
if SERVER then
	function ENT:UseEffect(pos, ent, destructive)
		if destructive and vFireInstalled then
			CreateVFireBall(math.random(5, 15), math.random(5, 15), pos, VectorRand() * math.random(100, 200))
		end

		for i = 1, 1 do
			local Eff = EffectData()
			Eff:SetOrigin(pos + VectorRand() * 10)
			util.Effect("StriderBlood", Eff, true, true)

			if destructive and not vFireInstalled then
				local Tr = util.QuickTrace(pos, Vector(math.random(-200, 200), math.random(-200, 200), math.random(0, -200)), {self})

				if Tr.Hit then
					local Fiah = ents.Create("env_fire")
					Fiah:SetPos(Tr.HitPos + Tr.HitNormal)
					Fiah:SetKeyValue("health", 30)
					Fiah:SetKeyValue("fireattack", 1)
					Fiah:SetKeyValue("firesize", math.random(20, 200))
					Fiah:SetOwner(self.Owner or game.GetWorld())
					Fiah:Spawn()
					Fiah:Activate()
					Fiah:Fire("StartFire", "", 0)
					Fiah:Fire("kill", "", math.random(1, 5))
				end
			end
		end
	end

	function ENT:AltUse(ply)
	end

	--
	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play(self.BreakNoise, Pos)

			for i = 1, self:GetResource() / 2 do
				self:UseEffect(Pos, game.GetWorld(), true)
			end

			self:Remove()
		elseif (dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT)) and math.random() <= 0.1 * math.Clamp(dmginfo:GetDamage() / 10, 1, 5) then
			local Pos = self:GetPos()
			sound.Play("ambient/fire/gascan_ignite1.wav", Pos, 70, 90)

			for i = 1, self:GetResource() / 2 do
				self:UseEffect(Pos, game.GetWorld(), true)
			end

			self:Remove()
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(0, 3.9, -1.5), Angle(-90, 0, 90), .05, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.FUEL, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
