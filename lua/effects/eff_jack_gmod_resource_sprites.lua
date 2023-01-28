local MaterialMain = Material("mat_jack_smallarmstracer_main")
local MaterialFront = Material("mat_jack_smallarmstracer_front")

function EFFECT:Init(data)
	self.Origin = data:GetOrigin()
	self.Scale = data:GetScale()
	local SurfaceProp = data:GetSurfaceProp()
	self.Speed = math.Rand(.75, 1.5)
	self.LifeTime = self.Scale * math.Rand(1, 2)
	self.Bright = math.Rand(.9, 1.25)

	if SurfaceProp == 0 then
		self.Target = nil -- directionless explosion
	elseif SurfaceProp == 1 then
		self.Target = data:GetStart() -- we have a destination
		local Dist = self.Target:Distance(self.Origin)
		self.Speed = self.Speed * Dist / 50
	end

	local MyMdl = "models/hunter/misc/sphere025x025.mdl"
	self:SetPos(self.Origin + VectorRand() * math.random(1, 5))
	self:SetModel(MyMdl)
	self:SetModelScale(.5, 0)
	self:DrawShadow(false)
	local pb_vert = 2 * self.Scale
	local pb_hor = 2 * self.Scale
	self:PhysicsInitBox(Vector(-pb_vert, -pb_hor, -pb_hor), Vector(pb_vert, pb_hor, pb_hor))
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	local MyFlightDir = VectorRand()
	local MyFlightSpeed = math.random(1, 400)
	local MyFlightVec = MyFlightDir * MyFlightSpeed

	if IsValid(phys) then
		phys:Wake()
		phys:SetDamping(0, 0)
		phys:SetMass(10)
		phys:SetMaterial("gmod_silent")
		phys:SetVelocity(MyFlightVec * VectorRand() * math.Rand(2, 3))

		if self.Target then
			phys:EnableGravity(false)
		end
	end

	self.DieTime = CurTime() + 5
end

function EFFECT:PhysicsCollide()
	-- haha bepis
end

-- stub
-- sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 65, self.HitPitch, 1)
function EFFECT:Think()
	if not self.DieTime then return false end
	local Vec = (self.Target or self:GetPos() + Vector(0, 0, 1)) - self:GetPos()
	local Phys = self:GetPhysicsObject()
	local Dist = Vec:Length()
	if self.DieTime < CurTime() then return false end

	if self.Target then
		if Dist < 5 then
			Phys:EnableMotion(false)

			return false
		end

		if IsValid(Phys) then
			Phys:ApplyForceCenter(Vec:GetNormalized() * 30 * self.Speed - Phys:GetVelocity() / 4)
		end
	end

	return true
end

function EFFECT:Render()
	if not self.DieTime then return end
	if not IsValid(self) then return end
	local Phys = self:GetPhysicsObject()
	if not IsValid(Phys) then return end

	if Phys:IsMotionEnabled() then
		-- let's make a spark
		local endPos = self:GetPos()
		local vel = self:GetVelocity()
		local srcDist, destDist = endPos:Distance(self.Origin), self.Target:Distance(endPos)
		local length = math.min(srcDist, destDist) / 2
		local dir = vel:GetNormalized()
		local startPos = endPos - dir * length
		render.SetMaterial(MaterialFront)
		render.DrawSprite(endPos, 10, 10, Color(255, 200 * self.Bright, 120 * self.Bright, 255))
		render.SetMaterial(MaterialMain)
		render.DrawBeam(startPos, endPos, 5, 0, 1, Color(255, 200 * self.Bright, 100 * self.Bright, 255))
	end
end
