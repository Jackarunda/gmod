function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Scayul = data:GetScale()
	local Nerml = data:GetNormal()
	util.Decal("impact.glass", SelfPos + Nerml, SelfPos - Nerml)

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(SelfPos)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(5)
		util.Effect("WaterSplash", Splach)

		return
	end

	local Emitter = ParticleEmitter(SelfPos)

	for i = 0, 300 do
		local Particle = Emitter:Add("effects/fleck_glass" .. math.random(1, 3), SelfPos + VectorRand() * math.Rand(0, 3))

		if Particle then
			Particle:SetVelocity(VectorRand() * math.Rand(0, 500) + Nerml * math.Rand(0, 500))
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.3, 3))
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
			Particle:SetStartAlpha(math.Rand(200, 255))
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.Clamp(math.Rand(.001, 1.5) * Scayul / 20, 1, 100))
			Particle:SetEndSize(0)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(math.Rand(-5, 5))
			Particle:SetAirResistance(20)
			Particle:SetGravity(Vector(0, 0, -600))
			Particle:SetCollide(true)
			Particle:SetLighting(false)
			Particle:SetBounce(.3)
		end
	end

	for i = 0, 20 do
		local Particle = Emitter:Add("sprites/mat_jack_coolness", SelfPos + VectorRand() * math.Rand(0, 3))

		if Particle then
			Particle:SetVelocity(VectorRand() * math.Rand(0, 100))
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.5, 2))
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
			Particle:SetStartAlpha(math.Rand(50, 200))
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.Rand(0, 1) * Scayul / 10)
			Particle:SetEndSize(math.Rand(10, 30) * Scayul / 10)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(math.Rand(-5, 5))
			Particle:SetAirResistance(500)
			Particle:SetGravity(Vector(0, 0, math.Rand(-400, -10)))
			Particle:SetCollide(false)
			Particle:SetLighting(true)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
