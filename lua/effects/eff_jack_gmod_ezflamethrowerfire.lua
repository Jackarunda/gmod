function EFFECT:Init(data)
	local Pos, Norm, Scl = data:GetOrigin(), data:GetNormal(), data:GetScale()
	local Start = data:GetStart()
	local Ent = data:GetEntity()
	if IsValid(Ent) then
		Pos = self:GetTracerShootPos(Pos, Ent, data:GetAttachment())
	end
	
	local Emitter = ParticleEmitter(Pos)

	for i = 1, 5 * Scl ^ .5 do
		local FireParticle = Emitter:Add("mats_jack_gmod_sprites/flamelet" .. math.random(1, 5), Pos + Norm * i * 10 * Scl)

		if FireParticle then
			local Vel = Norm * Scl + VectorRand() * 15 * Scl
			FireParticle:SetVelocity(Vel + Start * math.Rand(.5, 1.5))
			FireParticle:SetAirResistance(math.random(10, 100) * i)
			FireParticle:SetDieTime(math.Rand(.5, 1) * Scl ^ .5)
			FireParticle:SetStartAlpha(255)
			FireParticle:SetEndAlpha(0)
			local Size = math.Rand(2, 5) * Scl
			FireParticle:SetStartSize(Size / 1)
			FireParticle:SetEndSize(Size * 8)
			FireParticle:SetRoll(math.Rand(-5, 5))
			FireParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = Vector(0, 0, math.random(-120, 0)) * Scl
			FireParticle:SetGravity(Vec)
			FireParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			FireParticle:SetColor(255 * Brightness, 100 * Brightness, 1 * Brightness)
			FireParticle:SetCollide(true)
		end
	end

	for i = 1, 5 * Scl ^ .5 do
		local FireParticle = Emitter:Add("mats_jack_gmod_sprites/flamelet" .. math.random(1, 5), Pos + Norm * i * 10 * Scl)

		if FireParticle then
			FireParticle:SetVelocity(Norm * Scl + VectorRand() * 10 * Scl + Start * math.Rand(.5, 1.5))
			FireParticle:SetAirResistance(math.random(10, 100) * i)
			FireParticle:SetDieTime(math.Rand(.1, .5) * Scl ^ .5)
			FireParticle:SetStartAlpha(255)
			FireParticle:SetEndAlpha(0)
			local Size = math.Rand(1, 3) * Scl
			FireParticle:SetStartSize(Size / 1)
			FireParticle:SetEndSize(Size * 8)
			FireParticle:SetRoll(math.Rand(-5, 5))
			FireParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = Vector(0, 0, math.random(-120, 0)) * Scl
			FireParticle:SetGravity(Vec)
			FireParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			FireParticle:SetColor(255, 220, 200)
			FireParticle:SetCollide(true)
		end
	end

	for i = 1, 2 do
		local DistFactor = math.Rand(.8, 1)

		local Sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local SmokeParticle = Emitter:Add(Sprite, Pos + Norm * (DistFactor * 100) * Scl)

		if SmokeParticle then
			SmokeParticle:SetVelocity(Norm * Scl + VectorRand() * 10 * Scl + Start)
			SmokeParticle:SetAirResistance(100)
			SmokeParticle:SetDieTime(math.Rand(1, 2) * Scl ^ .75)
			SmokeParticle:SetStartAlpha(200)
			SmokeParticle:SetEndAlpha(0)
			local Size = math.Rand(10, 30) * Scl
			SmokeParticle:SetStartSize(0)
			SmokeParticle:SetEndSize(Size * 10)
			SmokeParticle:SetRoll(math.Rand(-5, 5))
			SmokeParticle:SetRollDelta(math.Rand(-1, 1))
			local Vec = VectorRand() * 50 + Vector(0, 0, 350) + JMod.Wind * 300 * Scl
			SmokeParticle:SetGravity(Vec)
			SmokeParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			SmokeParticle:SetColor(50, 50, 50)
			SmokeParticle:SetCollide(true)
			SmokeParticle:SetBounce(.1)
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
