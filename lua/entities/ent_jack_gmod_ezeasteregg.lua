-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ Egg"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = true

---
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/jmod/ez_egg01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		--
		self.Clr = Color(math.random(75, 255), math.random(75, 255), math.random(75, 255))
		self:SetColor(self.Clr)
		--
		self:PrecacheGibs()
		--
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(5)
				Phys:Wake()
			end
		end)
		timer.Simple(5, function()
			if (IsValid(self)) then Phys:Sleep() end
		end)
		SafeRemoveEntityDelayed(self, 100)
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed > 100) then self:Break() end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		self:Break()
	end

	function ENT:Use(activator)
		if (self.Opened) then return end
		if not IsValid(activator) then return end
		self:Break()
		timer.Simple(.5, function()
			if (IsValid(activator) and activator:Alive()) then
				if JMod.ConsumeNutrients(activator, math.random(1, 15)) then
					activator:EmitSound("snds_jack_gmod/nom" .. math.random(1, 5) .. ".wav", 60, math.random(90, 110))
				end
				local Wep = activator:GetActiveWeapon()
				if Wep then
					local PrimType, SecType, PrimSize, SecSize = Wep:GetPrimaryAmmoType(), Wep:GetSecondaryAmmoType(), Wep:GetMaxClip1(), Wep:GetMaxClip2()
					local PrimName, SecName = game.GetAmmoName(PrimType), game.GetAmmoName(SecType)
					if PrimName then activator:GiveAmmo(math.max(math.ceil(PrimSize / 3), 1), PrimName, math.random(1, 2) == 1) end
					if SecName then activator:GiveAmmo(math.max(math.ceil(SecSize / 3), 1), SecName, math.random(1, 2) == 1) end
				end
			end
		end)
	end

	function ENT:Break()
		if (self.Opened) then return end
		self.Opened = true
		sound.Play("snds_jack_gmod/easter_egg_break.wav", self:GetPos() + Vector(0, 0, 40), 60, math.random(80, 120))
		self:SetBodygroup(1, 1)
		self:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, 1000))
		self:GetPhysicsObject():AddAngleVelocity(VectorRand() * 100)
		local Eff = EffectData()
		Eff:SetOrigin(self:LocalToWorld(self:OBBCenter()) + Vector(0, 0, 1))
		util.Effect("eff_jack_gmod_eastereggpop", Eff, true, true)
		timer.Simple(0, function()
			SafeRemoveEntityDelayed(self, 7)
		end)
	end

	function ENT:Think()
		--
	end

	function ENT:OnRemove()
		--
	end
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezeasteregg", "EZ Easter Egg")
end
