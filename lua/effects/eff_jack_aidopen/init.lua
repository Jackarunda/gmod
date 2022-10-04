function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Scale = Scayul
	self.Position = vOffset
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Vector(0, 0, 1)
	local Emitter = ParticleEmitter(vOffset)

	for i = 0, 7 * Scayul do
		local sprite
		local chance = math.random(1, 6)

		if chance == 1 then
			sprite = "particle/smokestack"
		elseif chance == 2 then
			sprite = "particles/smokey"
		elseif chance == 3 then
			sprite = "particle/particle_smokegrenade"
		elseif chance == 4 then
			sprite = "sprites/mat_jack_smoke1"
		elseif chance == 5 then
			sprite = "sprites/mat_jack_smoke2"
		elseif chance == 6 then
			sprite = "sprites/mat_jack_smoke3"
		end

		local particle = Emitter:Add(sprite, vOffset)

		if particle then
			particle:SetVelocity(math.Rand(8, 16) * VectorRand() * Scayul * i ^ 1.2)
			particle:SetAirResistance(1000)
			particle:SetDieTime(math.Rand(1, 3))
			particle:SetStartAlpha(math.Rand(10, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(1, 15) * Scayul)
			particle:SetEndSize(math.Rand(1, 75) * Scayul)
			particle:SetRoll(math.Rand(-3, 3))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetGravity(Vector(0, 0, math.random(-10, -100)))
			particle:SetLighting(false)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(false)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--no
