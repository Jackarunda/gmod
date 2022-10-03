-- Jackarunda 2021
local Sprites = {"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"}

function EFFECT:Init(data)
	local Pos, Scale, Norm = data:GetOrigin(), data:GetScale(), data:GetNormal()
	local Emitter = ParticleEmitter(Pos)

	for i = 0, 100 do
		local Sprite = table.Random(Sprites)
		local Particle = Emitter:Add(Sprite, Pos)

		if Particle then
			local Dir = VectorRand()
			Dir.z = -math.abs(Dir.z)
			Particle:SetVelocity(100000 * Dir * Scale + Norm * 50000)
			Particle:SetAirResistance(1000)
			Particle:SetDieTime(math.Rand(1, 2.5) * Scale)
			Particle:SetStartAlpha(math.random(50, 150))
			Particle:SetEndAlpha(0)
			local Size = math.Rand(10, 20) * Scale
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			Particle:SetGravity(Vector(0, 0, math.random(-10, -100)))
			Particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			Particle:SetColor(darg, darg, darg)
			Particle:SetCollide(true)
			Particle:SetBounce(math.Rand(0, .005))
			--[[
			Particle:SetCollideCallback( function( part, hitpos, hitnormal )
				if(Emitter)then
					
				end
			end )
			--]]
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
