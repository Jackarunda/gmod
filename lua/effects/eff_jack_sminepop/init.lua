function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = data:GetNormal()
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	local emitter = ParticleEmitter(vOffset)

	for i = 0, 1 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(math.Rand(900, 1300) * VectorRand() * Scayul)
		particle:SetAirResistance(800)
		particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
		particle:SetDieTime(math.Rand(0.01, 0.05))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(25, 35) * Scayul)
		particle:SetEndSize(math.Rand(35, 50) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg - 20, darg, darg)
	end

	for i = 0, 100 * Scayul ^ 2 do
		local sprite = "effects/fleck_cement" .. math.random(1, 2)
		local Debris = emitter:Add(sprite, vOffset)

		if Debris then
			Debris:SetVelocity(VectorRand() * math.Rand(25, 150) * Scayul ^ 0.5 + Vector(0, 0, math.Rand(10, 250)))
			Debris:SetDieTime(3 * math.random(0.6, 1))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(math.random(1, 5) * Scayul ^ 0.5)
			Debris:SetRoll(math.Rand(0, 360))
			Debris:SetRollDelta(math.Rand(-5, 5))
			Debris:SetAirResistance(1)
			Debris:SetColor(105, 100, 90)
			Debris:SetGravity(Vector(0, 0, -800))
			Debris:SetCollide(true)
			Debris:SetBounce(.2)
			Debris:SetLighting(true)
		end
	end

	for i = 0, 10 * Scayul do
		local sprite
		local chance = math.random(1, 6)

		if chance == 1 then
			sprite = "particle/smokestack"
		elseif chance == 2 then
			sprite = "particles/smokey"
		elseif chance == 3 then
			sprite = "particle/particle_smokegrenade"
		elseif chance == 4 then
			sprite = "sprites/mat_jack_smoke1"
		elseif chance == 5 then
			sprite = "sprites/mat_jack_smoke2"
		elseif chance == 6 then
			sprite = "sprites/mat_jack_smoke3"
		end

		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(VectorRand() * math.Rand(0, 2000) * Scayul)
		particle:SetAirResistance(4000)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetDieTime(math.Rand(4, 7))
		particle:SetStartAlpha(math.Rand(50, 150))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 20) * Scayul)
		particle:SetEndSize(math.Rand(15, 25) * Scayul)
		particle:SetRoll(math.Rand(-3, 3))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(150, 200)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = .5 * Scayul ^ 0.5
		dlight.Size = 150 * Scayul ^ 0.5
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
-- dicks
