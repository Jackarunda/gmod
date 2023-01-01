function EFFECT:Init(data)
	local Pos, Norm, Scl = data:GetOrigin(), data:GetNormal(), data:GetScale()
	local Emitter = ParticleEmitter(Pos)

	if (math.random(1, 30) == 5) then
		for i = 1, 10 * Scl ^ .5 do
			local FireParticle = Emitter:Add("mats_jack_gmod_sprites/flamelet" .. math.random(1, 5), Pos + VectorRand() * 1)

			if FireParticle then
				FireParticle:SetVelocity(Norm * math.random(5, 20) * Scl + VectorRand() * 1 * Scl)
				FireParticle:SetAirResistance(math.random(50, 200))
				FireParticle:SetDieTime(math.Rand(.1, .5) * Scl ^ .5)
				FireParticle:SetStartAlpha(255)
				FireParticle:SetEndAlpha(0)
				local Size = math.Rand(.5, 1) * Scl
				FireParticle:SetStartSize(Size / 8)
				FireParticle:SetEndSize(Size * 8)
				FireParticle:SetRoll(math.Rand(-5, 5))
				FireParticle:SetRollDelta(math.Rand(-1, 1))
				local Vec = VectorRand() * 100 + Vector(0, 0, 300) + JMod.Wind * 100 * Scl
				FireParticle:SetGravity(Vec)
				FireParticle:SetLighting(false)
				local Brightness = math.Rand(.5, 1)
				FireParticle:SetColor(255 * Brightness, 100 * Brightness, 1 * Brightness)
				FireParticle:SetCollide(true)
			end
		end
	end

	for i = 1, 2 do
		local DistFactor = math.Rand(.5, 1)

		local Sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local SmokeParticle = Emitter:Add(Sprite, Pos + Norm * DistFactor * 1 * Scl + VectorRand() * DistFactor * 1 * Scl)

		if SmokeParticle then
			SmokeParticle:SetVelocity(Norm * math.random(30, 60) * Scl + VectorRand() * 10)
			SmokeParticle:SetAirResistance(100)
			SmokeParticle:SetDieTime(math.Rand(1, 2) * Scl ^ .75)
			SmokeParticle:SetStartAlpha(100)
			SmokeParticle:SetEndAlpha(0)
			local Size = math.Rand(1, 5) * Scl
			SmokeParticle:SetStartSize(Size / 20)
			SmokeParticle:SetEndSize(Size * 10)
			--SmokeParticle:SetRoll(math.Rand(-5, 5))
			--SmokeParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = VectorRand() * 20 + Vector(0, 0, 50) + JMod.Wind * 50 * Scl
			SmokeParticle:SetGravity(Vec)
			SmokeParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			SmokeParticle:SetColor(50, 50, 50)
			SmokeParticle:SetCollide(true)
			SmokeParticle:SetBounce(1)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
-- no u
