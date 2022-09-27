function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	local Scayul = data:GetScale()
	local Nermul = data:GetNormal()

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(Pos)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	local emitter = ParticleEmitter(Pos)
	-- smoke ring
	local Dir = Nermul:Angle()
	Dir:RotateAroundAxis(Dir:Right(), 90)

	for i = 1, 50 * Scayul do
		local sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local particle = emitter:Add(sprite, Pos)
		particle:SetVelocity(Dir:Forward() * math.random(3000, 5000) * Scayul)
		particle:SetAirResistance(2000)
		particle:SetGravity(JMod.Wind * 4000 + VectorRand() * 500)
		particle:SetDieTime(math.Rand(1, 4))
		particle:SetStartAlpha(math.Rand(100, 200))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(20, 40) * Scayul)
		particle:SetEndSize(math.Rand(40, 60) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(200, 255)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
		Dir:RotateAroundAxis(Nermul, math.random(10, 20))
	end

	-- backward
	for i = 1, 10 * Scayul do
		local sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local particle = emitter:Add(sprite, Pos)
		particle:SetVelocity(-Nermul * i * 1000 * Scayul)
		particle:SetAirResistance(2000)
		particle:SetGravity(JMod.Wind * 4000 + VectorRand() * 500)
		particle:SetDieTime(math.Rand(1, 4))
		particle:SetStartAlpha(math.Rand(100, 200))
		particle:SetEndAlpha(0)
		local Siyuz = math.Rand(4, 5) * Scayul * (10 - i)
		particle:SetStartSize(Siyuz)
		particle:SetEndSize(Siyuz * 2)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(200, 255)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	-- forward
	for i = 1, 20 * Scayul do
		local sprite = table.Random({"particle/smokestack", "particles/smokey", "particle/particle_smokegrenade", "sprites/mat_jack_smoke1", "sprites/mat_jack_smoke2", "sprites/mat_jack_smoke3"})

		local particle = emitter:Add(sprite, Pos)
		particle:SetVelocity(Nermul * i * 1000)
		particle:SetAirResistance(2000)
		particle:SetGravity(JMod.Wind * 4000 + VectorRand() * 500)
		particle:SetDieTime(math.Rand(1, 4))
		particle:SetStartAlpha(math.Rand(100, 200))
		particle:SetEndAlpha(0)
		local Siyuz = math.Rand(2, 3) * Scayul * (20 - i)
		particle:SetStartSize(Siyuz)
		particle:SetEndSize(Siyuz * 2)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(true)
		local darg = math.Rand(200, 255)
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	for i = 0, 200 * Scayul do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(10, 1000) * Scayul + Nermul * math.Rand(50, 3000) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(.1, 1))
			local fuf = math.Rand(200, 255)
			particle:SetColor(255, fuf, fuf - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(1, 10) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(math.Rand(-1000, 500), math.Rand(-1000, 1000), math.Rand(0, 1000)))
			particle:SetCollide(true)
			particle:SetBounce(.9)
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
