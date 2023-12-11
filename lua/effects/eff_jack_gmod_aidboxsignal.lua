-- Jackarunda 2021
--,"particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1","sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
local Sprites = {"particle/smokestack"}

function EFFECT:Init(data)
	local Pos, Norm, Vel, Life, ColAng = data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetScale(), data:GetAngles()
	local R, G, B = ColAng.p, ColAng.y, ColAng.r
	local Emitter = ParticleEmitter(Pos)
	local Sprite = Sprites[math.random(1, #Sprites)]
	local RollParticle = Emitter:Add(Sprite, Pos)

	if RollParticle then
		RollParticle:SetVelocity(Vel + Norm * math.random(50, 100) + VectorRand() * 10)
		RollParticle:SetAirResistance(100)
		RollParticle:SetDieTime(math.Rand(2, 15))
		RollParticle:SetStartAlpha(255)
		RollParticle:SetEndAlpha(0)
		local Size = math.Rand(20, 40)
		RollParticle:SetStartSize(Size / 40)
		RollParticle:SetEndSize(Size * 4)
		RollParticle:SetRoll(math.Rand(-3, 3))
		RollParticle:SetRollDelta(math.Rand(-2, 2))
		local Vec = VectorRand() * 10 + Vector(0, 0, 200) + JMod.Wind * 150
		RollParticle:SetGravity(Vec)
		RollParticle:SetLighting(true)
		local Brightness = math.Rand(.5, 1)
		RollParticle:SetColor(R * Brightness, G * Brightness, B * Brightness)
		RollParticle:SetCollide(true)
		RollParticle:SetBounce(1)
	end

	--[[
	for i = 0, 50 do
		local particle = Emitter:Add("sprites/mat_jack_nicespark", Pos)
		if particle then
			particle:SetVelocity(Vel + Norm * math.random(200, 600) + VectorRand() * 50)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(.5, 1))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp - 10, herpdemutterfickendenderp - 20)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Siz = math.Rand(.1, 1)
			particle:SetStartSize(Siz * 5)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(20)
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetLighting(false)
			particle:SetCollide(true)
			particle:SetBounce(0.95)
		end
	end
	--]]

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
-- no u
