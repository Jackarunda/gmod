function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local SelfVel = data:GetStart()
	local Scayul = data:GetScale()
	local Nerml = data:GetNormal()
	local Emitter = ParticleEmitter(SelfPos)

	if true then
		for i = 1, 50 * Scayul do
			local Inv = 50 - i
			local Particle = Emitter:Add("sprites/mat_jack_coolness", SelfPos)

			if Particle then
				Particle:SetVelocity(Nerml * i * 20 + VectorRand() * Inv * 1 + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 3))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Rand(200, 225), math.Rand(225, 250), 255)
				Particle:SetStartAlpha(math.Rand(5, 50))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(0, 4) * Scayul)
				Particle:SetEndSize(math.Rand(5, 20) * Scayul * Inv / 10)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(500)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-200, -300)) * Scayul)
				Particle:SetCollide(true)
				Particle:SetLighting(true)
			end
		end
	end

	for i = 1, 300 * Scayul do
		local Particle = Emitter:Add("sprites/mat_jack_coolness", SelfPos)

		if Particle then
			Particle:SetVelocity(Nerml * math.Rand(30, 3000) + VectorRand() * math.Rand(10, 1000) + SelfVel)
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.02, .1))
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(math.Rand(200, 225), math.Rand(225, 250), 255)
			Particle:SetStartAlpha(math.Rand(100, 255))
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.Rand(0, 4) * Scayul)
			Particle:SetEndSize(math.Rand(5, 20) * Scayul)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(math.Rand(-5, 5))
			Particle:SetAirResistance(1000)
			Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-10, -300)) * Scayul)
			Particle:SetCollide(true)
			Particle:SetLighting(true)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
