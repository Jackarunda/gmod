function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local SelfDir = data:GetStart()

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(SelfPos + SelfDir * math.random(1, 50))
		Splach:SetNormal(SelfDir)
		Splach:SetScale(5)
		util.Effect("WaterSplash", Splach)
	end

	local Emitter = ParticleEmitter(SelfPos)

	for i = 0, 2 do
		local Particle = Emitter:Add("effects/bubble", SelfPos + VectorRand() * math.Rand(0, 10))

		if Particle then
			Particle:SetVelocity(SelfDir * 1000 * math.Rand(.5, 2) + VectorRand() * 200)
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.5, 2))
			Particle:SetColor(255, 255, 255)
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(255)
			local Lol = math.Rand(2, 4)
			Particle:SetStartSize(Lol)
			Particle:SetEndSize(Lol)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(math.Rand(-5, 5))
			Particle:SetAirResistance(800)
			Particle:SetGravity(Vector(0, 0, math.Rand(600, 700)))
			Particle:SetCollide(true)
			Particle:SetLighting(false)
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
