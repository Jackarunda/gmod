-- copied from Slayer
function EFFECT:Init(data)
	local Ent, Force = data:GetEntity(), data:GetStart()
	local Vel, CenterPos, Eang = Vector(0, 0, 0), data:GetOrigin(), Angle(0, 0, 0)
	local Mins, Maxs = Vector(-30, 30, 30), Vector(30, 30, 30)
	local Epos = CenterPos

	if IsValid(Ent) then
		Vel, Epos, Eang = Ent:GetVelocity(), Ent:GetPos(), Ent:GetAngles()
		Mins, Maxs = Ent:GetModelBounds()
	end

	self.Emitter = ParticleEmitter(Epos)

	-- sparks --
	for i = 1, 50 do
		local AddVec = Vector(math.Rand(Mins.x, Maxs.x), math.Rand(Mins.y, Maxs.y), math.Rand(Mins.z, Maxs.z))
		local Vec, Ang = LocalToWorld(AddVec, Angle(0, 0, 0), Epos, Eang)
		local Pvel = Vel + Force * math.Rand(.02, .2)
		local particle = self.Emitter:Add("effects/fleck_wood" .. math.random(1, 2), Vec)
		particle:SetVelocity(Pvel + VectorRand() * math.Rand(0, 200) + Vector(0, 0, 100))
		particle:SetAirResistance(10)
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetDieTime(math.Rand(1, 5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		local Size = math.random(10, 20)
		particle:SetStartSize(Size)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 3))

		if math.random(1, 2) == 1 then
			particle:SetRollDelta(0)
		else
			particle:SetRollDelta(math.Rand(-5, 5))
		end

		particle:SetColor(150, 150, 150)
		particle:SetLighting(true)
		particle:SetCollide(true)
		particle:SetBounce(math.Rand(0, .5))
	end

	-- smoke --
	local particle = self.Emitter:Add("particle/smokestack", CenterPos)
	particle:SetVelocity(Vel)
	particle:SetAirResistance(50)
	particle:SetGravity(Vector(0, 0, math.Rand(-1, -30)))
	particle:SetDieTime(math.Rand(.5, 1))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	local Size = math.random(10, 40)
	particle:SetStartSize(Size)
	particle:SetEndSize(Size * 5)
	particle:SetRoll(0)

	if math.random(1, 2) == 1 then
		particle:SetRollDelta(0)
	else
		particle:SetRollDelta(math.Rand(-.5, .5))
	end

	particle:SetColor(255, 220, 180)
	particle:SetLighting(true)
	particle:SetCollide(false)
	self.Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--
