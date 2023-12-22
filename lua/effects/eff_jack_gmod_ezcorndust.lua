-- Jackarunda 2023
local Sprites = { "effects/fleck_cement1", "effects/fleck_cement2" }
function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Emitter = ParticleEmitter(Pos)
	for i = 1, 3 do
		local Sprite = table.Random(Sprites)
		local Particle = Emitter:Add(Sprite, Pos + VectorRand() * 10)
		if Particle then
			Particle:SetVelocity(JMod.Wind)
			Particle:SetAirResistance(1000)
			Particle:SetDieTime(math.random(25, 30))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(1, 2)
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			local Vec = JMod.Wind * math.random(500, 1500) + Vector(0, 0, math.random(-200, -400))
			Particle:SetGravity(Vec)
			Particle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			--local Col = Color(255, 235, 85)
			Particle:SetColor(255 * Brightness, 235 * Brightness, 85 * Brightness)
			Particle:SetCollide(true)
			Particle:SetBounce(0)
		end
	end
	Emitter:Finish()
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
	--
end
-- no u
