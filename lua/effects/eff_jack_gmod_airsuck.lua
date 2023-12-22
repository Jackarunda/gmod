function EFFECT:Init(data)
	local NumParticles = 5
	local emitter = ParticleEmitter(data:GetOrigin())
	local Pos = data:GetOrigin()
	local Scl = data:GetScale()
	local bubel = self:WaterLevel() > 0

	for i = 0, NumParticles do
		local Offset = VectorRand() * 100 * Scl
		if emitter then
			local rollparticle
			if (bubel) then
				rollparticle = emitter:Add("effects/bubble", Pos + Offset)
			else
				rollparticle = emitter:Add("particle/smokestack", Pos + Offset)
			end

			if rollparticle then
				rollparticle:SetVelocity(Vector(0, 0, 0))
				rollparticle:SetLifeTime(0)
				rollparticle:SetDieTime(1)
				local Rando = math.random(180, 255)
				rollparticle:SetColor(Rando, Rando, Rando)
				rollparticle:SetStartAlpha(0)
				rollparticle:SetEndAlpha((bubel and 255) or math.random(100, 255))
				rollparticle:SetStartSize(100 * Scl)
				rollparticle:SetEndSize(0)
				if not bubel then
					rollparticle:SetRoll(math.Rand(-360, 360))
					rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
				end
				rollparticle:SetAirResistance(0)
				rollparticle:SetGravity(-Offset * 1.5)
				rollparticle:SetCollide(false)
				rollparticle:SetLighting(false)
			end
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
