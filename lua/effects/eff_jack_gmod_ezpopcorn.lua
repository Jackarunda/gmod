-- AdventureBoots 2023
local Sprites = {"sprites/jmod_popcorn1"}
function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Emitter = ParticleEmitter(Pos)
	local Sprite = table.Random(Sprites)
	for i = 1, 10 do
		local Particle = Emitter:Add(Sprite, Pos)
		if Particle then
			Particle:SetVelocity(VectorRand() * math.random(100, 200))
			Particle:SetAirResistance(100)
			Particle:SetDieTime(math.random(50, 60))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(2, 3)
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size)
			Particle:SetRoll(math.Rand(-3, 3))
			--Particle:SetRollDelta(math.Rand(-2, 2))
			--local Vec = JMod.Wind * math.random(500, 1000) + Vector(0, 0, math.random(-300, -600))
			local Grav = Vector(0, 0, -1000)
			Particle:SetGravity(Grav)
			Particle:SetLighting(false)
			local Brightness = 1 -- * math.Rand(.5, 1)
			Particle:SetColor(255 * Brightness, 255 * Brightness, 255 * Brightness)
			Particle:SetCollide(true)
			Particle:SetBounce(.5)
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
