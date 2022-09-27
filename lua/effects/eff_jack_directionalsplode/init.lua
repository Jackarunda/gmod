function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	local Nermul = data:GetNormal()
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Vector(0, 0, 1)
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1

	--local Spl=EffectData()
	--Spl:SetOrigin(vOffset)
	--Spl:SetScale(1)
	--util.Effect("Explosion",Spl,true,true)
	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	local emitter = ParticleEmitter(vOffset)

	for i = 0, 75 * Scayul do
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

		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity((math.Rand(0, 3000) * VectorRand() * Scayul + Nermul * math.Rand(-400, 9000) * Scayul) * 10)
		particle:SetAirResistance(7000)
		particle:SetGravity(VectorRand() * math.Rand(0, 10))
		particle:SetDieTime(math.Rand(.1, 1))
		particle:SetStartAlpha(math.Rand(100, 200))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(10, 40) * Scayul)
		particle:SetEndSize(math.Rand(40, 60) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(200, 255)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	for i = 0, 10 * Scayul ^ 2 do
		local Debris = emitter:Add("effects/fleck_cement" .. math.random(1, 2), vOffset)

		if Debris then
			Debris:SetVelocity(VectorRand() * math.Rand(75, 500) * Scayul ^ 0.5 + Nermul * math.Rand(100, 1500) * Scayul ^ 0.5)
			Debris:SetDieTime(3 * math.random(0.6, 1))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(math.random(1, 5) * Scayul ^ 0.5)
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

	for i = 0, 20 * Scayul ^ 2 do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(100, 1000) * Scayul + Nermul * math.Rand(500, 3000) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.3, 0.6))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(2, 5) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(math.Rand(-1000, 500), math.Rand(-1000, 1000), math.Rand(0, 1000)))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
	end

	for i = 0, 10 * Scayul ^ 2 do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(Nermul * math.Rand(20, 3000) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.2, 0.4))
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(2, 5) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(math.Rand(-1000, 500), math.Rand(-1000, 1000), math.Rand(0, 1000)))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--no
