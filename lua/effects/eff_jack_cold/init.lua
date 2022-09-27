function EFFECT:Init(data)
	if self:WaterLevel() > 0 then return end
	local SelfPos = data:GetOrigin()
	local SelfVel = data:GetStart()
	local Scayul = data:GetScale()
	local Emitter = ParticleEmitter(SelfPos)

	do
		for i = 1, 1 do
			local Particle = Emitter:Add("sprites/mat_jack_coolness", SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(1, 3) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 3))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Rand(200, 225), math.Rand(225, 250), 255)
				Particle:SetStartAlpha(math.Rand(5, 100))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(0, 4) * Scayul)
				Particle:SetEndSize(math.Rand(5, 20) * Scayul)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(500)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-10, -300)) * Scayul)
				Particle:SetCollide(true)
				Particle:SetLighting(true)
			end
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
