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
	
	function ENT:Detonate()
		if IsValid(self) then
			timer.Simple(math.Rand(0,1), function()
				JMod.Sploom(self.EZowner, self:GetPos() + VectorRand() * math.random(0, 300), math.random(50, 130))
			end)
		end
	end
	
	function ENT:Initialize()
		self.CanSploom = true
	end
	
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)

		if (JMod.LinCh(dmginfo:GetDamage(), 80, 200) and math.random(1, 3) == 2 and self.CanSploom) then
			self.CanSploom = false
			JMod.SetEZowner(self, dmginfo:GetAttacker())
			self:Detonate()
		end
	end
	
	function ENT:UseEffect(pos, ent, bad)
		if bad and (math.random(1, 3) == 2) and self.CanSploom then
			self.Entity:TakePhysicsDamage(dmginfo)
			self.CanSploom = false
			JMod.SetEZowner(self, dmginfo:GetAttacker())
			self:Detonate()
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
