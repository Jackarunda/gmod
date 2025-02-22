function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Scayul = data:GetScale()
	local Typ = data:GetColor()
	local Emitter = ParticleEmitter(SelfPos)

	if self:WaterLevel() == 3 then
		for i = 0, 20 * Scayul do
			local Particle = Emitter:Add("effects/bubble", SelfPos + VectorRand() * 15)
			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 20) * Scayul)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.2, 1))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(255)
				Particle:SetEndAlpha(255)
				Particle:SetStartSize(math.Rand(1, 3) * Scayul)
				Particle:SetEndSize(math.Rand(3, 6) * Scayul)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-.1, .1))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(100, 400)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end
	else
		for i = 0, 30 * Scayul do
			local Particle = Emitter:Add("sprites/heatwave", SelfPos + VectorRand() * 15)
			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 20))
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 1))
				Particle:SetColor(255, 255, 255)
				Particle:SetStartAlpha(1)
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(1)
				Particle:SetEndSize(math.Rand(30, 60) * Scayul)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-.1, .1))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-60, 60), math.Rand(-60, 60), math.Rand(150, 300)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end
		for i = 0, 15 * Scayul do
			local Col, Sprt = 20, "sprites/mat_jack_smoke"..tostring(math.random(1, 3))
			if (Typ == 1) then
				Col = 200
				Sprt = "particle/smokestack"
			end
			local Particle = Emitter:Add(Sprt, SelfPos + VectorRand() * 15)
			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(1, 5))
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(1, 2))
				Particle:SetColor(Col, Col, Col)
				Particle:SetStartAlpha(math.Rand(100, 200) * Scayul)
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(1, 3))
				Particle:SetEndSize(math.Rand(30, 60) * Scayul)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-2, 2))
				Particle:SetAirResistance(500)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(300, 600)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
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
