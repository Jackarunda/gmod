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

	for k = 0, 200 do
		local particle = self.Emitter:Add("sprites/mat_jack_jackconfetti", self.Position + VectorRand())

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(10, 1000) + Vector(0, 0, math.Rand(10, 1000)))
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(4, 10))
			local Col = table.Random(Cols)
			particle:SetColor(Col.r, Col.g, Col.b)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetAirResistance(500)
			particle:SetGravity(VectorRand() * 300 + Vector(0, 0, -300) + JMod.Wind * 300)
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
