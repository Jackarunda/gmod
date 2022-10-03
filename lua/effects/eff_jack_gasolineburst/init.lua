local ShockWave = Material("sprites/mat_jack_shockwave_white")
local Refract = Material("sprites/mat_jack_shockwave")
local Wake = Material("effects/splashwake1")
local Shit = Material("sprites/mat_jack_ignorezsprite")

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Scale = Scayul
	self.Position = vOffset
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Vector(0, 0, 1)
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1
	self.TimeToDie = CurTime() + 0.015 * self.Scale
	local emitter = ParticleEmitter(vOffset)

	for i = 0, 15 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(math.Rand(30, 50) * VectorRand() * Scayul * i ^ 1.2)
		particle:SetAirResistance(2000)
		particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.01, 0.75))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(5, 20) * Scayul)
		particle:SetEndSize(math.Rand(7, 30) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg, darg - 10, darg - 20)
	end

	for i = 0, 100 * Scayul do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(1, 2) * Scayul * i ^ 1.2)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.3, 2))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(2, 5) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(math.Rand(0, 0), math.Rand(0, 0), math.Rand(0, -1000)))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
	end

	for i = 0, 10 * Scayul do
		local particle = emitter:Add("sprites/heatwave", vOffset)
		particle:SetVelocity(VectorRand() * math.Rand(0, 500))
		particle:SetAirResistance(200)
		particle:SetGravity(VectorRand() * math.Rand(0, 200))
		particle:SetDieTime(math.Rand(0.4, 0.6) * Scayul)
		particle:SetStartAlpha(40)
		particle:SetEndAlpha(0)
		particle:SetStartSize(150 * Scayul)
		particle:SetEndSize(0 * Scayul)
		particle:SetRoll(math.Rand(0, 10))
		particle:SetRollDelta(6000)
	end

	emitter:Finish()

	timer.Simple(0.025, function()
		local Emitter = ParticleEmitter(vOffset)

		for i = 0, 50 * Scayul do
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

			local particle = Emitter:Add(sprite, vOffset)

			if particle then
				particle:SetVelocity(math.Rand(2, 3) * VectorRand() * Scayul * i ^ 1.2)
				particle:SetAirResistance(1000)
				particle:SetGravity(VectorRand() * math.Rand(0, 2000))
				particle:SetDieTime(math.Rand(2, 15))
				particle:SetStartAlpha(math.Rand(50, 200))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(5, 15) * Scayul)
				particle:SetEndSize(math.Rand(10, 60) * Scayul)
				particle:SetRoll(math.Rand(-3, 3))
				particle:SetRollDelta(math.Rand(-2, 2))
				particle:SetLighting(true)
				local darg = math.Rand(200, 255)
				particle:SetColor(darg, darg, darg)
				particle:SetCollide(false)
			end
		end

		Emitter:Finish()
	end)

	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = 4 * Scayul ^ 0.5
		dlight.Size = 250 * Scayul ^ 0.5
		dlight.Decay = 15
		dlight.DieTime = CurTime() + 13 * Scayul
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--fuck you kid you're a dick
