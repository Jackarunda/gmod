-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Nuclear Fallout"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.EZfalloutParticle = true
ENT.JModDontIrradiate = true

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self.LifeTime = self.LifeTime or math.random(100, 200) * JMod.Config.Particles.NuclearRadiationMult
		self.DieTime = Time + self.LifeTime
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:RebuildPhysics()
		self:DrawShadow(false)
		self.NextDmg = Time + math.random(1, 10)
	end

	function ENT:CanSee(ent)
		local Tr = util.TraceLine({
			start = self:GetPos(),
			endpos = ent:GetPos(),
			filter = {self, ent},
			mask = MASK_SHOT
		})

		return not Tr.Hit
	end

	function ENT:Think()
		if CLIENT then return end
		local Time, SelfPos = CurTime(), self:GetPos()

		if self.DieTime < Time then
			self:Remove()

			return
		end

		local Force = VectorRand() * 10 - Vector(0, 0, 50)

		for key, obj in pairs(ents.FindInSphere(SelfPos, self.Range or 2500)) do
			if not (obj == self) and self:CanSee(obj) then
				if obj.EZfalloutParticle then
					local Vec = (obj:GetPos() - SelfPos):GetNormalized()
					Force = Force - Vec * 7
				elseif JMod.ShouldDamageBiologically(obj) and (math.random(1, 5) == 1) and (self.NextDmg < Time) then
					JMod.FalloutIrradiate(self, obj)
				end
			end
		end

		self:Extinguish()
		local Phys = self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity() * (self.DragMult or .7))
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
		self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal * 100)
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

		if self.DebugShow then
			self:SetModelScale(10)
		end
	end

	function ENT:DrawTranslucent()
		if self.DebugShow then
			self:DrawModel()
		end
	end
end
