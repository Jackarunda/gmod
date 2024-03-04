local Cols = {
	Color(100, 100, 255),
	Color(255, 100, 100),
	Color(100, 255, 100),
	Color(255, 150, 200),
	Color(255, 255, 0),
	Color(0, 255, 255)
}

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Emitter = ParticleEmitter(self.Position)

	for k = 0, 100 do
		local particle = self.Emitter:Add("sprites/mat_jack_jackconfetti", self.Position + VectorRand())

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(10, 200) + Vector(0, 0, math.Rand(10, 200)))
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(4, 6))
			local Col = table.Random(Cols)
			particle:SetColor(Col.r, Col.g, Col.b)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetAirResistance(100)
			particle:SetGravity(VectorRand() * 100 + Vector(0, 0, -100) + JMod.Wind * 100)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
			particle:SetLighting(false)
		end
	end
end

function EFFECT:Think()
	--
end

function EFFECT:Render()
	--
end
