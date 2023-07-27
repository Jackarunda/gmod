-- Jackarunda 2023
local Sprites = { "models/jmod/props/leaf1", "models/jmod/props/leaf2" }
function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Emitter = ParticleEmitter(Pos)
	local Sprite = table.Random(Sprites)
	for i = 1, 3 do
		local Particle = Emitter:Add(Sprite, Pos + VectorRand() * 30)
		if Particle then
			Particle:SetVelocity(Vector(0, 0, 0))
			Particle:SetAirResistance(1000)
			Particle:SetLifeTime(20)
			Particle:SetDieTime(21)
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(4, 6)
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(math.Rand(-2, 2))
			local Vec = JMod.Wind * math.random(800, 1000) + Vector(0, 0, math.random(-300, -600))
			Particle:SetGravity(Vec)
			Particle:SetLighting(false)
			local Brightness = math.Rand(.5, 1)
			Particle:SetColor(255 * Brightness, 255 * Brightness, 255 * Brightness)
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
