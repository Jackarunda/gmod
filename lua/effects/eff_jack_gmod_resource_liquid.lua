local LiquidConfig = {
	[JMod.EZ_RESOURCE_TYPES.WATER] = {
		mat = "models/mat_jack_refract_liquid_blue"
	},
	[JMod.EZ_RESOURCE_TYPES.OIL] = {
		mat = "phoenix_storms/black_chrome"
	},
	[JMod.EZ_RESOURCE_TYPES.FUEL] = {
		mat = "models/mat_jack_refract_liquid_red"
	},
	[JMod.EZ_RESOURCE_TYPES.COOLANT] = {
		mat = "models/mat_jack_refract_liquid_brightblue"
	},
	[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = {
		mat = "models/mat_jack_refract_liquid_yellowgreen"
	}
}

local TotalParticleCount = 0
timer.Create("JMod_ResourceLiquidParticleClear", 60, 0, function()
	TotalParticleCount = 0 // we should reset this periodically in case some gmod nonsense causes it to get out of sync
end)

function EFFECT:Init(data)
	if TotalParticleCount >= 800 then
		self:Remove()

		return
	end

	TotalParticleCount = math.Clamp(TotalParticleCount + 1, 0, 9e9)

	timer.Simple(3, function()
		TotalParticleCount = math.Clamp(TotalParticleCount - 1, 0, 9e9)
	end)

	self.ResourceType = JMod.IndexToResource[data:GetFlags()]
	self.Origin = data:GetOrigin()
	self.Spread = data:GetMagnitude()
	self.Scale = data:GetScale()
	self.Radius = data:GetRadius()
	local SurfaceProp = data:GetSurfaceProp()
	self.Speed = math.Rand(.75, 1.5)

	if SurfaceProp == 0 then
		self.Target = nil -- directionless explosion
	elseif SurfaceProp == 1 then
		self.Target = data:GetStart() -- we have a destination
		local Dist = self.Target:Distance(self.Origin)
		self.Speed = self.Speed * Dist / 100
	end

	self.Data = LiquidConfig[self.ResourceType]
	if not self.Data then return end
	self:SetPos(self.Origin + VectorRand() * math.random(1, 5 * self.Spread))
	self:SetModel("models/hunter/misc/sphere025x025.mdl")

	if self.Data.mat then
		self:SetMaterial(self.Data.mat)
	end

	self:SetModelScale(self.Scale * math.Rand(.25, 0.5) * (self.Data.scl or 1), 0)
	local Col = self.Data.col or Color(255, 255, 255)
	local ColFrac = math.Rand(1.1, .9)
	if (self.Data.highlyRandomColor)then ColFrac = math.Rand(.5, 1.5) end
	self:SetColor(Color(math.Clamp(Col.r * ColFrac, 0, 255), math.Clamp(Col.g * ColFrac, 0, 255), math.Clamp(Col.b * ColFrac, 0, 255)))
	self:DrawShadow(true)
	self:SetAngles(AngleRand())
	local pb_vert = 2 * self.Scale
	local pb_hor = 2 * self.Scale
	self:PhysicsInitBox(Vector(-pb_vert, -pb_hor, -pb_hor), Vector(pb_vert, pb_hor, pb_hor))
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	local MyFlightDir = VectorRand()
	local MyFlightSpeed = math.random(1, 400)
	local MyFlightVec = MyFlightDir * MyFlightSpeed * self.Spread

	if IsValid(phys) then
		phys:Wake()
		phys:SetDamping(0, 0)
		phys:SetMass(10)
		phys:SetMaterial("gmod_silent")
		phys:SetVelocity(MyFlightVec * self.Spread + Vector(0, 0, self.Radius))

		if self.Target then
			phys:EnableGravity(false)
		end

		phys:AddAngleVelocity(VectorRand() * math.random(1, 600))
	end

	self.DieTime = CurTime() + 5
end

function EFFECT:PhysicsCollide()
end

-- stub
-- sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 65, self.HitPitch, 1)
function EFFECT:Think()
	if not self.DieTime then return false end
	local Vec = (self.Target or self:GetPos() + Vector(0, 0, 1)) - self:GetPos()
	local Phys = self:GetPhysicsObject()
	local Dist = Vec:Length()
	if self.DieTime < CurTime() then return false end

	if Dist < 5 then
		Phys:EnableMotion(false)

		return false
	end

	if IsValid(Phys) then
		Phys:ApplyForceCenter(Vec:GetNormalized() * 30 * self.Speed - Phys:GetVelocity() / 4)
	end

	return true
end

function EFFECT:Render()
	if not self.DieTime then return end
	if not IsValid(self) then return end
	local Phys = self:GetPhysicsObject()
	if not IsValid(Phys) then return end

	if Phys:IsMotionEnabled() then
		self:DrawModel()
	end
end