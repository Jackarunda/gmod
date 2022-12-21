local ParticleColors = {Color(255, 255, 255), Color(0, 0, 0)}

function EFFECT:Init(data)
	local Origin = data:GetOrigin()
	local Norm = data:GetNormal()
	local Emitter = ParticleEmitter(Origin)

	for i = 1, 20 do
		local Particle = Emitter:Add("sprites/spark", Origin)

		if Particle then
			Particle:SetVelocity(Norm * 100 + VectorRand() * 50)
			Particle:SetAirResistance(10)
			Particle:SetDieTime(math.random(5, 10))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.random(1, 2))
			Particle:SetEndSize(0)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(0)
			Particle:SetGravity(Vector(0, 0, -600))
			Particle:SetLighting(true)
			local Col=table.Random(ParticleColors)
			Particle:SetColor(Col.r, Col.g, Col.b)
			Particle:SetCollide(true)
			Particle:SetBounce(math.Rand(0, .3))
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	-- haha no u
end
