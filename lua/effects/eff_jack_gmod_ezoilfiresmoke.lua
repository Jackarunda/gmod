function EFFECT:Init(data)
	local Pos, Norm, Scl = data:GetOrigin(), data:GetNormal(), data:GetScale()
	local Emitter = ParticleEmitter(Pos)

	for i = 1, 20 * Scl ^ .5 do
		local FireParticle = Emitter:Add("mats_jack_gmod_sprites/flamelet" .. math.random(1, 5), Pos + VectorRand() * 2)

		if FireParticle then
			FireParticle:SetVelocity(Norm * math.random(500, 2000) * Scl + VectorRand() * 10 * Scl)
			FireParticle:SetAirResistance(math.random(50, 200))
			FireParticle:SetDieTime(math.Rand(.5, 2) * Scl ^ .5)
			FireParticle:SetStartAlpha(255)
			FireParticle:SetEndAlpha(0)
			local Size = math.Rand(20, 40) * Scl
			FireParticle:SetStartSize(Size / 8)
			FireParticle:SetEndSize(Size * 8)
			FireParticle:SetRoll(math.Rand(-5, 5))
			FireParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = VectorRand() * 100 + Vector(0, 0, 600) + JMod.Wind * 1000 * Scl
			FireParticle:SetGravity(Vec)
			FireParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			FireParticle:SetColor(255 * Brightness, 100 * Brightness, 1 * Brightness)
			FireParticle:SetCollide(true)
		end
	end

	for i = 1, 2 do
		local DistFactor = math.Rand(.5, 1)

		local Sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local SmokeParticle = Emitter:Add(Sprite, Pos + Norm * DistFactor * 250 * Scl + VectorRand() * DistFactor * 100 * Scl + JMod.Wind * 100 * Scl)

		if SmokeParticle then
			SmokeParticle:SetVelocity(Norm * math.random(600, 1000) * Scl + VectorRand() * 10)
			SmokeParticle:SetAirResistance(100)
			SmokeParticle:SetDieTime(math.Rand(1, 20) * Scl ^ .75)
			SmokeParticle:SetStartAlpha(200)
			SmokeParticle:SetEndAlpha(0)
			local Size = math.Rand(40, 100) * Scl
			SmokeParticle:SetStartSize(Size / 20)
			SmokeParticle:SetEndSize(Size * 10)
			--SmokeParticle:SetRoll(math.Rand(-5, 5))
			--SmokeParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = VectorRand() * 50 + Vector(0, 0, 350) + JMod.Wind * 300 * Scl
			SmokeParticle:SetGravity(Vec)
			SmokeParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			SmokeParticle:SetColor(50, 50, 50)
			SmokeParticle:SetCollide(true)
			SmokeParticle:SetBounce(1)
		end
	end

	for i = 1, 3 do
		local DistFactor = math.Rand(.5, 1)

		local Sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local ShortSmokeParticle = Emitter:Add(Sprite, Pos + Norm * DistFactor * 250 * Scl + VectorRand() * DistFactor * 100 * Scl + JMod.Wind * 100 * Scl)

		if ShortSmokeParticle then
			ShortSmokeParticle:SetVelocity(Norm * math.random(800, 1200) * Scl + VectorRand() * 10 * Scl)
			ShortSmokeParticle:SetAirResistance(100)
			ShortSmokeParticle:SetDieTime(math.Rand(.5, 3) * Scl ^ .75)
			ShortSmokeParticle:SetStartAlpha(200)
			ShortSmokeParticle:SetEndAlpha(0)
			local Size = math.Rand(30, 50) * Scl
			ShortSmokeParticle:SetStartSize(Size / 20)
			ShortSmokeParticle:SetEndSize(Size * 10)
			--SmokeParticle:SetRoll(math.Rand(-5, 5))
			--SmokeParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = VectorRand() * 50 + Vector(0, 0, 350) + JMod.Wind * 300 * Scl
			ShortSmokeParticle:SetGravity(Vec)
			ShortSmokeParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			ShortSmokeParticle:SetColor(50, 50, 50)
			ShortSmokeParticle:SetCollide(true)
			ShortSmokeParticle:SetBounce(1)
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
