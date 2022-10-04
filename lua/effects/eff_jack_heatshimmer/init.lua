function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local SelfVel = data:GetStart()
	local Emitter = ParticleEmitter(SelfPos)

	if self:WaterLevel() == 3 then
		for i = 0, 2 do
			local Particle = Emitter:Add("effects/bubble", SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 100) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.2, 1))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(255)
				Particle:SetEndAlpha(255)
				Particle:SetStartSize(math.Rand(1, 3))
				Particle:SetEndSize(math.Rand(3, 6))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-.1, .1))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(100, 400)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end

		for i = 0, 2 do
			local Particle = Emitter:Add("sprites/mat_jack_smoke" .. tostring(math.random(1, 3)), SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 100) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.2, 1))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(math.Rand(10, 100))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(1, 3))
				Particle:SetEndSize(math.Rand(3, 20))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-.1, .1))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(30, 120)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end
	else
		for i = 0, 2 do
			local Particle = Emitter:Add("sprites/heatwave", SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 20) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.1, .5))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(1)
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(1)
				Particle:SetEndSize(math.Rand(3, 10))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-.1, .1))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-60, 60), math.Rand(-60, 60), math.Rand(80, 300)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end

		for i = 0, 1 do
			local Particle = Emitter:Add("sprites/mat_jack_smoke" .. tostring(math.random(1, 3)), SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(1, 5) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.2, 2))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(math.Rand(15, 100))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(1, 3))
				Particle:SetEndSize(math.Rand(5, 20))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(500)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(10, 200)))
				Particle:SetCollide(false)
				Particle:SetLighting(true)
			end
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
