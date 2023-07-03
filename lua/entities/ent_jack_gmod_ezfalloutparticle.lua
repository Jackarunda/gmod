-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Nuclear Fallout"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZfalloutParticle = true
ENT.JModDontIrradiate = true
ENT.AffectRange = 2500
ENT.ThinkRate = 2
--

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableCollisions(false)
			phys:EnableGravity(false)
		end
		self.LifeTime = self.LifeTime or math.random(100, 200) * JMod.Config.Particles.NuclearRadiationMult
		self.DieTime = Time + self.LifeTime
		self.NextDmg = Time + math.random(1, 10)
	end

	function ENT:ShouldDamage(ent)
		if not IsValid(ent) then return end
		return JMod.ShouldDamageBiologically(obj) and (math.random(1, 5) == 1)
	end

	function ENT:DamageObj(obj)
		JMod.FalloutIrradiate(self, obj)
	end
	--
elseif CLIENT then
	function ENT:Initialize()
		self.DebugShow = LocalPlayer().EZshowGasParticles or false

		if self.DebugShow then
			self:SetModelScale(10)
		end
	end

	function ENT:DrawTranslucent()
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		if self.DebugShow then
			self:DrawModel()
		end
	end
end
