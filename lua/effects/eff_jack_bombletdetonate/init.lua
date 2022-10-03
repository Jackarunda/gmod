local ShockWave = Material("sprites/mat_jack_shockwave_white")
local Refract = Material("sprites/mat_jack_shockwave")
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

	if math.random(1, 2) == 1 then
		self.WillDrawShockwave = true
	else
		self.WillDrawFlash = true
	end

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	local emitter = ParticleEmitter(vOffset)
	local particle = emitter:Add("effects/fire_cloud1", vOffset)
	particle:SetVelocity(math.Rand(40, 60) * VectorRand() * Scayul)
	particle:SetAirResistance(20)
	particle:SetDieTime(0.04 * Scayul)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(10 * Scayul)
	particle:SetEndSize(300 * Scayul)
	particle:SetRoll(math.Rand(180, 480))
	particle:SetRollDelta(math.Rand(-1, 1) * 6)
	particle:SetColor(255, 255, 255)

	for i = 0, 5 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(math.Rand(900, 1300) * VectorRand() * Scayul)
		particle:SetAirResistance(2000)
		particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
		particle:SetLifeTime(0)
		particle:SetDieTime(math.Rand(0.01, 0.2))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 20) * Scayul)
		particle:SetEndSize(math.Rand(70, 80) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg - 20, darg, darg)
	end

	for i = 0, 40 * Scayul do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(10, 8000) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.3, 1))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(2, 8) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(0, 0, -2000))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
			particle:SetLighting(false)
		end
	end

	emitter:Finish()

	timer.Simple(0.05, function()
		local Emitter = ParticleEmitter(vOffset)

		for i = 0, 8 * Scayul do
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
			particle:SetVelocity(math.Rand(900, 1300) * VectorRand() * Scayul)
			particle:SetAirResistance(1000)
			particle:SetGravity(VectorRand() * math.Rand(0, 2000))
			particle:SetDieTime(math.Rand(1, 4))
			particle:SetStartAlpha(math.Rand(50, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(50, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 100) * Scayul)
			particle:SetRoll(math.Rand(-3, 3))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		Emitter:Finish()
	end)
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Siyuz = self.Siyuz + 500
		self:NextThink(CurTime() + .01)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	if self.WillDrawShockwave then
		local TimeLeftFraction = (self.DieTime - CurTime()) / .25
		local Opacity = math.Clamp(TimeLeftFraction * 100 * self.Scayul, 0, 255)
		render.SetMaterial(ShockWave)
		render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
		render.DrawSprite(self.Pos, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	elseif self.WillDrawFlash then
		local TimeLeft = self.TimeToDie - CurTime()
		local TimeFraction = math.Clamp(TimeLeft / (0.015 * self.Scale), 0, 1)
		local ReverseFraction = 1 - TimeFraction
		render.SetMaterial(Shit)
		render.DrawSprite(self.Position, 1000 * TimeFraction * self.Scale, 1000 * TimeFraction * self.Scale, Color(255, 255, 255, 120 * TimeFraction))
	end
end
