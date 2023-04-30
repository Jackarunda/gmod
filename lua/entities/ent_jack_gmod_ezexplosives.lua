-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Explosives Box"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/explosives.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.EXPLOSIVES
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/jmod/resources/jack_crate.mdl"
ENT.Material = "models/mat_jack_gmod_ezexplosives"
--ENT.ModelScale=.8
ENT.Mass = 50
ENT.ImpactNoise1 = "Wood_Box.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Wood_Box.Break"

---
if SERVER then

	function ENT:CustomInit()
		self.BlownUp = false
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)

		if (math.random(1, 6) == 3)then
			JMod.SetEZowner(self, dmginfo:GetAttacker() or game:GetWorld())
			self:Detonate()
		end
	end

	function ENT:Detonate()
		if IsValid(self) then

			if self.BlownUp then
				return
			end

			self.BlownUp = not self.BlownUp

			self:GetPhysicsObject():EnableMotion(false)

			local plooie = EffectData()
			plooie:SetOrigin(self:GetPos())
			plooie:SetScale(math.Rand(0.125,0.5))

			util.Effect("eff_jack_plastisplosion", plooie)

			if (math.random(1, 3) == 2) then
				JMod.Sploom(self.EZowner, self:GetPos(), 150, 96)
			else
				JMod.FragSplosion(self, self:GetPos() + Vector(0, 16, 0), 600, 15, 1024, self.EZowner or game.GetWorld() or self)
			end

			JMod.BlastDoors(self.EZowner or self, self:GetPos(), 150, 96, false)
			self:EmitSound("snd_jack_fragsplodeclose.wav", 100, 100)
			util.ScreenShake(self:GetPos(), 55, 55, .5, 512)

			timer.Simple(0.05, function()
				SafeRemoveEntity(self)
			end)
		end
	end
	
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()

		JMod.HoloGraphicDisplay(self, Vector(1, -11.3, 10), Angle(90, 0, 90), .04, 300, function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.EXPLOSIVES, self:GetResource(), nil, 0, 0, 200, true)
		end)
	end

	language.Add(ENT.ClassName, ENT.PrintName)
end
