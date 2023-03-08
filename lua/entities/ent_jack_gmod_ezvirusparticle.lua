-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Virus Particle"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.EZvirusParticle = true

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self.LifeTime = math.random(50, 100)
		self.DieTime = Time + self.LifeTime
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:RebuildPhysics()
		self:DrawShadow(false)
	end

	function ENT:Think()
		if CLIENT then return end
		local Time, SelfPos = CurTime(), self:GetPos()

		if self.DieTime < Time then
			self:Remove()

			return
		end

		local Force = VectorRand() * 40 - Vector(0, 0, 10)
		JMod.TryVirusInfectInRange(self, self.EZowner, 0, 0)
		self:Extinguish()
		local Phys = self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity() * .1)
		Phys:ApplyForceCenter(Force)
		self:NextThink(Time + math.Rand(4, 8))

		return true
	end

	function ENT:RebuildPhysics()
		local size = 1
		self:PhysicsInitSphere(size, "gmod_silent")
		self:SetCollisionBounds(Vector(-.1, -.1, -.1), Vector(.1, .1, .1))
		self:PhysWake()
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		local Phys = self:GetPhysicsObject()
		Phys:SetMass(1)
		Phys:EnableGravity(false)
		Phys:SetMaterial("gmod_silent")
	end

	function ENT:PhysicsCollide(data, physobj)
		self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal * 10)
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
	end

	function ENT:Use(activator, caller)
	end
	--
elseif CLIENT then
	function ENT:Initialize()
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
	end

	function ENT:DrawTranslucent()
		if self.DebugShow then
			self:DrawModel()
		end
	end
end
