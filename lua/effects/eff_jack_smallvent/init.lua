function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local SelfVel = data:GetStart()
	local Emitter = ParticleEmitter(SelfPos)

	if self:WaterLevel() == 3 then
		for i = 0, 5 do
			local Particle = Emitter:Add("effects/bubble", SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 100) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 3))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(math.Rand(150, 255))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(1, 5))
				Particle:SetEndSize(math.Rand(5, 10))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(20, 600)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end

		for i = 0, 2 do
			local Particle = Emitter:Add("sprites/mat_jack_smoke" .. tostring(math.random(1, 3)), SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(0, 100) + SelfVel)
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 3))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(math.Rand(10, 50))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(1, 5))
				Particle:SetEndSize(math.Rand(10, 50))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(20, 300)))
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end
	else
		for i = 0, 18 do
			local Particle = Emitter:Add("sprites/mat_jack_glowything", SelfPos)

			if Particle then
				Particle:SetVelocity(VectorRand() * math.Rand(1, 5) + SelfVel * math.Rand(.5, 1.5))
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 3))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(math.Rand(5, 40))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(0, 5))
				Particle:SetEndSize(math.Rand(5, 30))
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(300)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(10, 300)))
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
