function EFFECT:Init(data)
	local pozishun = data:GetOrigin()
	local skayul = data:GetScale()
	local NumParticles = 5 * skayul
	self.Nermal = data:GetNormal()
	local emitter = ParticleEmitter(data:GetOrigin())

	for i = 0, NumParticles do
		if true then
			local rollparticle = emitter:Add("sprites/heatwave", pozishun + VectorRand() * math.Rand(0, 3) * skayul)

			if rollparticle then
				rollparticle:SetVelocity(self.Nermal * math.Rand(100, 500) * skayul)
				rollparticle:SetLifeTime(0)
				local life = math.Rand(.05, .2) * skayul
				local begin = CurTime()
				rollparticle:SetDieTime(life)
				rollparticle:SetColor(255, 255, 255)
				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
				rollparticle:SetStartSize(math.Rand(15, 25) * skayul)
				rollparticle:SetEndSize(0)
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
				rollparticle:SetAirResistance(0)
				rollparticle:SetGravity(Vector(0, 0, 500))
				rollparticle:SetCollide(false)
				rollparticle:SetLighting(false)
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
