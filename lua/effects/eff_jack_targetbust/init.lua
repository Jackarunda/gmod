function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	local PoofDir = data:GetNormal()

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	local emitter = ParticleEmitter(vOffset)
	local particle = emitter:Add("effects/fire_cloud1", vOffset)
	particle:SetVelocity(math.Rand(40, 60) * VectorRand() * Scayul)
	particle:SetAirResistance(20)
	particle:SetDieTime(0.09 * Scayul)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(0)
	particle:SetStartSize(5 * Scayul)
	particle:SetEndSize(75 * Scayul)
	particle:SetRoll(math.Rand(180, 480))
	particle:SetRollDelta(math.Rand(-1, 1) * 6)
	particle:SetColor(255, 255, 255)

	for i = 0, 50 * Scayul ^ 2 do
		local Debris = emitter:Add("effects/fleck_cement" .. math.random(1, 2), vOffset)

		if Debris then
			Debris:SetVelocity(VectorRand() * math.Rand(5, 500) * Scayul ^ 0.5)
			Debris:SetDieTime(3 * math.Rand(0.6, 1))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(math.random(.1, 2) * Scayul ^ 0.5)
			Debris:SetRoll(math.Rand(0, 360))
			Debris:SetRollDelta(math.Rand(-5, 5))
			Debris:SetAirResistance(1)
			Debris:SetColor(105, 100, 90)
			Debris:SetGravity(Vector(0, 0, -700))
			Debris:SetCollide(true)
			Debris:SetBounce(1)
			Debris:SetLighting(true)
		end
	end

	for i = 0, 300 * Scayul do
		local Pos = data:GetOrigin()
		local particle = emitter:Add("sprites/mat_jack_irregularcircle", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(3, 400) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.5, 5))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(herpdemutterfickendenderp, herpdemutterfickendenderp, herpdemutterfickendenderp)

			if math.random(1, 4) == 1 then
				particle:SetColor(255, 0, 0)
			end

			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(.1, 4) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(00)
			particle:SetGravity(VectorRand() * math.Rand(1, 20) + Vector(0, 0, -600))
			particle:SetCollide(true)
			particle:SetBounce(0.75)
		end
	end

	local particle = emitter:Add("sprites/heatwave", vOffset)
	particle:SetVelocity(Vector(0, 0, 0))
	particle:SetAirResistance(200)
	particle:SetGravity(VectorRand() * math.Rand(0, 200))
	particle:SetDieTime(math.Rand(0.03, 0.06) * Scayul)
	particle:SetStartAlpha(40)
	particle:SetEndAlpha(0)
	particle:SetStartSize(150 * Scayul)
	particle:SetEndSize(150 * Scayul)
	particle:SetRoll(math.Rand(0, 10))
	particle:SetRollDelta(6000)
	emitter:Finish()

	timer.Simple(0.05, function()
		local Emitter = ParticleEmitter(vOffset)

		for i = 0, 10 * Scayul do
			local sprite
			local chance = math.random(1, 6)

			if chance == 1 then
				sprite = "particle/smokestack"
			elseif chance == 2 then
				sprite = "particles/smokey"
			elseif chance == 3 then
				sprite = "particle/particle_smokegrenade"
			elseif chance == 4 then
				sprite = "sprites/mat_jack_smoke1"
			elseif chance == 5 then
				sprite = "sprites/mat_jack_smoke2"
			elseif chance == 6 then
				sprite = "sprites/mat_jack_smoke3"
			end

			local particle = Emitter:Add(sprite, vOffset)
			particle:SetVelocity(math.Rand(200, 750) * VectorRand() * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(1, 4))
			particle:SetStartAlpha(math.Rand(50, 100))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(15, 20) * Scayul)
			particle:SetEndSize(math.Rand(20, 30) * Scayul)
			particle:SetRoll(0)
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		Emitter:Finish()
	end)

	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = 3 * Scayul ^ 0.5
		dlight.Size = 150 * Scayul ^ 0.5
		dlight.Decay = 1200
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
