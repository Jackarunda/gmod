﻿-- Jackarunda 2021
--,"particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1","sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
local Sprites = {"particle/smokestack"}

function EFFECT:Init(data)
	local Pos, Norm, Vel, Scl = data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetScale()
	local R, G, B = 255, 250, 250
	local Emitter = ParticleEmitter(Pos)
	local Sprite = Sprites[math.random(1, #Sprites)]

	for i = 1, 2 * Scl do
		local RollParticle = Emitter:Add(Sprite, Pos)

		if RollParticle then
			RollParticle:SetVelocity(Vel + Norm * math.random(50, 100) + VectorRand() * 10 * (Scl ^.8))
			RollParticle:SetAirResistance(100)
			RollParticle:SetDieTime(math.Rand(2, 12))
			RollParticle:SetStartAlpha(math.random(150, 200))
			RollParticle:SetEndAlpha(0)
			local Size = math.Rand(20, 40)
			RollParticle:SetStartSize(Size / 20)
			RollParticle:SetEndSize(Size * 4)
			RollParticle:SetRoll(math.Rand(-3, 3))
			RollParticle:SetRollDelta(math.Rand(-2, 2))
			local Vec = VectorRand() * 10 + Vector(0, 0, 200) + JMod.Wind * 150
			RollParticle:SetGravity(Vec)
			RollParticle:SetLighting(false)
			local Brightness = math.Rand(.8, 1)
			RollParticle:SetColor(R * Brightness, G * Brightness, B * Brightness)
			RollParticle:SetCollide(true)
			RollParticle:SetBounce(1)
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
