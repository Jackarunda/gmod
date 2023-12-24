local Config = {
	[JMod.EZ_RESOURCE_TYPES.POWER] = {
		sprite = "mat_jack_smallarmstracer_front",
		trail = "mat_jack_smallarmstracer_main",
		siz = 1,
		trailLength = 1,
		col = Color(255, 200, 120, 255)
	},
	[JMod.EZ_RESOURCE_TYPES.ANTIMATTER] = {
		sprite = "mat_jack_smallarmstracer_front",
		trail = "mat_jack_smallarmstracer_main",
		siz = 2,
		trailLength = 1,
		cols = {Color(200, 200, 200, 255), Color(100, 200, 255, 255)}
	},
	[JMod.EZ_RESOURCE_TYPES.PAPER] = {
		sprite = "sprites/mat_aboot_college_paper",
		siz = 1.5,
		cols = {Color(200, 200, 200, 255), Color(188, 180, 180, 255)},
		use3D = true
	},
	[JMod.EZ_RESOURCE_TYPES.CLOTH] = {
		sprite = "sprites/mat_aboot_shirt",
		siz = 1.5,
		cols = {Color(62, 105, 56), Color(70, 108, 122), Color(126, 54, 49)},
		use3D = true
	},
	[JMod.EZ_RESOURCE_TYPES.GAS] = {
		sprite = "particle/smokestack",
		siz = 5,
		cols = {Color(100, 100, 100, 20), Color(200, 200, 200, 60)}
	},
	[JMod.EZ_RESOURCE_TYPES.SAND] = {
		sprite = "particle/smokestack",
		siz = 3,
		cols = {Color(199, 190, 70, 50), Color(173, 159, 76, 50)}
	},
	[JMod.EZ_RESOURCE_TYPES.PROPELLANT] = {
		sprites = {"effects/fleck_cement1", "effects/fleck_cement2"},
		siz = 1,
		cols = {Color(10, 10, 10, 255), Color(40, 40, 40, 255)}
	}
}

function EFFECT:Init(data)
	self.ResourceType = JMod.IndexToResource[data:GetFlags()]
	self.Origin = data:GetOrigin()
	self.Scale = data:GetScale()
	local SurfaceProp = data:GetSurfaceProp()
	self.Speed = math.Rand(.9, 1.1)

	if SurfaceProp == 0 then
		self.Target = nil -- directionless explosion
	elseif SurfaceProp == 1 then
		self.Target = data:GetStart() -- we have a destination
		local Dist = self.Target:Distance(self.Origin)
		self.Speed = self.Speed * Dist / 50
	end

	self.Data = Config[self.ResourceType]
	if not self.Data then return end

	local MyMdl = "models/hunter/misc/sphere025x025.mdl"
	self.Sprite = self.Data.sprite or table.Random(self.Data.sprites)
	local What, Why = Material(self.Sprite)
	self.Sprite = What -- garry you idiot
	self.Color = self.Data.col or table.Random(self.Data.cols)
	self.TrailColor = Color(self.Color.r - 20, self.Color.g - 20, self.Color.b - 20)
	self:SetPos(self.Origin + VectorRand() * math.random(1, 5))
	self:SetAngles(AngleRand())
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
		phys:SetMaterial("Default_silent")
		phys:SetVelocity(MyFlightVec * VectorRand() * math.Rand(2, 3))
		phys:AddAngleVelocity(VectorRand() * math.random(1, 100))

		if self.Target then
			phys:EnableGravity(false)
		end
	end

	self.DieTime = CurTime() + math.Rand(1.2, 1.5)
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
			Phys:ApplyForceCenter(Vec:GetNormalized() * Dist * 1 * self.Speed - Phys:GetVelocity() / 4)
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
		local myPos = self:GetPos()
		if (self.Data.use3D) then
			local myAng = self:GetAngles()
			local forward = myAng:Forward()
			render.SetMaterial(self.Sprite)
			render.DrawQuadEasy(myPos, forward, 15 * self.Data.siz, 10 * self.Data.siz, self.Color, myAng.r)
			render.DrawQuadEasy(myPos, -forward, 15 * self.Data.siz, 10 * self.Data.siz, self.Color, myAng.r)
		else
			render.SetMaterial(self.Sprite)
			render.DrawSprite(myPos, 10 * self.Data.siz, 10 * self.Data.siz, self.Color)
			if (self.Data.trail) then
				local What, Why = Material(self.Data.trail)
				if (self.Target) then
					local vel = self:GetVelocity()
					local srcDist, destDist = myPos:Distance(self.Origin), self.Target:Distance(myPos)
					local length = math.min(srcDist, destDist) / 2 * (self.Data.trailLength or 1)
					local dir = vel:GetNormalized()
					local startPos = myPos - dir * length
					render.SetMaterial(What)
					render.DrawBeam(startPos, myPos, 5, 0, 1, self.TrailColor)
				else
					local vel = self:GetVelocity()
					render.SetMaterial(What)
					render.DrawBeam(myPos - vel / 10 * self.Data.trailLength, myPos, 5, 0, 1, self.TrailColor)
				end
			end
		end
	end
end
