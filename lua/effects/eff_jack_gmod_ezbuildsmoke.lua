-- Jackarunda 2021
local Sprites = {"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"}

function EFFECT:Init(data)
	local Pos, Scale = data:GetOrigin(), data:GetScale()
	local Emitter = ParticleEmitter(Pos)

	for i = 0, 100 do
		local Sprite = table.Random(Sprites)
		local Particle = Emitter:Add(Sprite, Pos)

		if Particle then
			Particle:SetVelocity(1000 * VectorRand() * Scale)
			Particle:SetAirResistance(1000)
			Particle:SetDieTime(math.Rand(1, 2) * Scale)
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(30, 60) * Scale
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			Particle:SetGravity(Vector(0, 0, math.random(-10, -100)))
			Particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			Particle:SetColor(darg, darg, darg)
			Particle:SetCollide(false)
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
