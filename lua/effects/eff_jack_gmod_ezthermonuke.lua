-- Jackarunda 2021
function EFFECT:Init(data)
	local Pos, Scale = data:GetOrigin(), data:GetScale()
	local Emitter = ParticleEmitter(Pos)
	local Sprite = "particle/smokestack"
	local Spd = 5000

	for i = 1, 30 do
		local Particle = Emitter:Add(Sprite, Pos)

		if Particle then
			local Vel = Vector(math.Rand(-Spd, Spd), math.Rand(-Spd, Spd), math.Rand(-Spd / 6, Spd / 6))
			Particle:SetVelocity(Vel)
			Particle:SetAirResistance(0)
			Particle:SetDieTime(math.Rand(5, 20))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(500, 5000)
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			Particle:SetLighting(false)
			local darg = math.Rand(10, 100)
			Particle:SetColor(darg, darg, darg)
			Particle:SetCollide(false)
		end
	end

	for i = 1, 3 do
		local Particle = Emitter:Add(Sprite, Pos)

		if Particle then
			Particle:SetVelocity(VectorRand() * math.Rand(0, 500) + Vector(0, 0, math.Rand(100, 8000)))
			Particle:SetAirResistance(0)
			Particle:SetDieTime(math.Rand(10, 30))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(500, 5000)
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			Particle:SetLighting(false)
			local darg = math.Rand(10, 100)
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
