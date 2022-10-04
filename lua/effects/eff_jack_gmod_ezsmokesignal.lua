-- Jackarunda 2021
--,"particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1","sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
local Sprites = {"particle/smokestack"}

function EFFECT:Init(data)
	local Pos, Norm, Vel, Life, ColAng = data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetScale(), data:GetAngles()
	local R, G, B = ColAng.p, ColAng.y, ColAng.r
	local Emitter = ParticleEmitter(Pos)
	local Sprite = Sprites[math.random(1, #Sprites)]

	for i = 1, 2 do
		local RollParticle = Emitter:Add(Sprite, Pos)

		if RollParticle then
			RollParticle:SetVelocity(Vel + Norm * math.random(50, 100) + VectorRand() * 10)
			RollParticle:SetAirResistance(100)
			RollParticle:SetDieTime(math.Rand(5, 15))
			RollParticle:SetStartAlpha(255)
			RollParticle:SetEndAlpha(0)
			local Size = math.Rand(30, 60)
			RollParticle:SetStartSize(Size / 20)
			RollParticle:SetEndSize(Size * 4)
			RollParticle:SetRoll(math.Rand(-3, 3))
			RollParticle:SetRollDelta(math.Rand(-2, 2))
			local Vec = VectorRand() * 10 + Vector(0, 0, 200) + JMod.Wind * 150
			RollParticle:SetGravity(Vec)
			RollParticle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
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
