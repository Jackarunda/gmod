function EFFECT:Init(data)
	local pozishun = data:GetOrigin()
	local skayul = data:GetScale()
	local NumParticles = 5 * skayul
	local emitter = ParticleEmitter(data:GetOrigin())

	for i = 0, NumParticles do
		if math.random(1, 2) == 2 then
			local rollparticle = emitter:Add("sprites/heatwave", pozishun + VectorRand() * math.Rand(0, 3) * skayul)

			if rollparticle then
				rollparticle:SetVelocity((VectorRand() * math.Rand(0, 100)) * skayul)
				rollparticle:SetLifeTime(0)
				local life = math.Rand(0.2, 0.4) * skayul
				local begin = CurTime()
				rollparticle:SetDieTime(life)
				rollparticle:SetColor(255, 255, 255)
				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
				rollparticle:SetStartSize(1 * skayul)
				rollparticle:SetEndSize(3 * skayul)
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
				rollparticle:SetAirResistance(2000)
				rollparticle:SetGravity(Vector(0, 0, 500))
				rollparticle:SetCollide(false)
				rollparticle:SetLighting(false)
			end
		else
			local rollparticle = emitter:Add("particle/smokestack", pozishun + VectorRand() * math.Rand(0, 1) * skayul)

			if rollparticle then
				rollparticle:SetVelocity((VectorRand() * math.Rand(0, 10)) * skayul)
				rollparticle:SetLifeTime(0)
				local life = math.Rand(0.125, 1) * skayul ^ 0.25
				local begin = CurTime()
				rollparticle:SetDieTime(life)
				rollparticle:SetColor(0, 0, 0)
				rollparticle:SetStartAlpha(math.Rand(1, 20))
				rollparticle:SetEndAlpha(0)
				rollparticle:SetStartSize(1 * skayul)
				rollparticle:SetEndSize(5 * skayul)
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
				rollparticle:SetAirResistance(2000)
				rollparticle:SetGravity(Vector(0, 0, 2000))
				rollparticle:SetCollide(false)
				rollparticle:SetLighting(true)
			end
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--haha
