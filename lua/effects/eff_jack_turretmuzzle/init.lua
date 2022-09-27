function EFFECT:Init(data)
	local dirkshun = data:GetNormal()
	local pozishun = data:GetStart()
	local skayul = data:GetScale()
	local NumParticles = 5 * skayul
	local emitter = ParticleEmitter(data:GetOrigin())

	for i = 0, NumParticles do
		local rollparticle = emitter:Add("particles/flamelet" .. math.random(1, 3), pozishun + VectorRand() * math.Rand(0, 10) * skayul)

		if rollparticle then
			rollparticle:SetVelocity((Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-30, 30)) + dirkshun * math.Rand(150, 450)) * skayul)
			rollparticle:SetLifeTime(0)
			local life = math.Rand(0.00825, 0.0475) * skayul ^ 0.25
			local begin = CurTime()
			rollparticle:SetDieTime(life)
			rollparticle:SetColor(255, 255, 255)
			rollparticle:SetStartAlpha(255)
			rollparticle:SetEndAlpha(0)
			rollparticle:SetStartSize(12 * skayul)
			rollparticle:SetEndSize(12 * skayul)
			rollparticle:SetRoll(math.Rand(-360, 360))
			rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
			rollparticle:SetAirResistance(1000)
			rollparticle:SetGravity(Vector(0, 0, 0))
			rollparticle:SetCollide(false)
			rollparticle:SetLighting(false)
		end

		local rollparticle = emitter:Add("particles/flamelet" .. math.random(1, 3), pozishun)

		if rollparticle then
			rollparticle:SetVelocity((Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-5, 5)) + dirkshun * math.Rand(450, 1500)) * skayul)
			rollparticle:SetLifeTime(0)
			local life = math.Rand(0.00825, 0.0475) * skayul ^ 0.5
			local begin = CurTime()
			rollparticle:SetDieTime(life)
			rollparticle:SetColor(255, 255, 255)
			rollparticle:SetStartAlpha(255)
			rollparticle:SetEndAlpha(0)
			rollparticle:SetStartSize(2 * skayul)
			rollparticle:SetEndSize(4 * skayul)
			rollparticle:SetRoll(math.Rand(-360, 360))
			rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
			rollparticle:SetAirResistance(1000)
			rollparticle:SetGravity(Vector(0, 0, 0))
			rollparticle:SetCollide(false)
			rollparticle:SetLighting(false)
		end

		local rollparticle = emitter:Add("particle/smokestack", pozishun + VectorRand() * math.Rand(0, 10) * skayul)

		if rollparticle then
			rollparticle:SetVelocity((VectorRand() * math.Rand(0, 1000) + dirkshun * math.Rand(250, 550)) * skayul)
			rollparticle:SetLifeTime(0)
			local life = math.Rand(0.025, 0.115) * skayul ^ 0.25
			local begin = CurTime()
			rollparticle:SetDieTime(life)
			rollparticle:SetColor(255, 255, 255)
			rollparticle:SetStartAlpha(math.Rand(5, 40))
			rollparticle:SetEndAlpha(0)
			rollparticle:SetStartSize(12 * skayul)
			rollparticle:SetEndSize(12 * skayul)
			rollparticle:SetRoll(math.Rand(-360, 360))
			rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
			rollparticle:SetAirResistance(2000)
			rollparticle:SetGravity(Vector(0, 0, 0))
			rollparticle:SetCollide(false)
			rollparticle:SetLighting(false)
		end

		for i = 0, math.ceil(skayul) * 2 do
			local rollparticle = emitter:Add("sprites/heatwave", pozishun + VectorRand() * math.Rand(0, 10) * skayul)

			if rollparticle then
				rollparticle:SetVelocity((VectorRand() * math.Rand(0, 1000) + dirkshun * math.Rand(250, 550)) * skayul)
				rollparticle:SetLifeTime(0)
				local life = math.Rand(0.025, 0.05) * skayul
				local begin = CurTime()
				rollparticle:SetDieTime(life)
				rollparticle:SetColor(255, 255, 255)
				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
				rollparticle:SetStartSize(12 * skayul)
				rollparticle:SetEndSize(12 * skayul)
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
				rollparticle:SetAirResistance(2000)
				rollparticle:SetGravity(Vector(0, 0, 0))
				rollparticle:SetCollide(false)
				rollparticle:SetLighting(false)
			end
		end
	end

	emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = pozishun
		dlight.r = 190
		dlight.g = 225
		dlight.b = 255
		dlight.Brightness = .8 * skayul
		dlight.Size = 150 * skayul
		dlight.Decay = 1200 * skayul
		dlight.DieTime = CurTime() + 0.03 * skayul ^ 0.25
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
