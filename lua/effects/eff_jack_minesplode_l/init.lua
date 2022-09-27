local ShockWave = Material("sprites/mat_jack_shockwave_white")
local Refract = Material("sprites/mat_jack_shockwave")

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Vector(0, 0, 1)
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1
	local Spl = EffectData()
	Spl:SetOrigin(vOffset)
	Spl:SetScale(1)
	util.Effect("Explosion", Spl, true, true)
	local Direc = data:GetNormal()
	local Radyuss = math.Round(data:GetRadius())
	local Dirt = Radyuss == 1
	local Concrete = Radyuss == 2
	local Metal = Radyuss == 3
	local Wood = Radyuss == 4
	local Air = Radyuss == 5
	local Spl = EffectData()
	Spl:SetOrigin(vOffset)
	Spl:SetScale(1)
	util.Effect("Explosion", Spl, true, true)

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Direc)
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	local emitter = ParticleEmitter(vOffset)
	local particle = emitter:Add("effects/fire_cloud1", vOffset)
	particle:SetVelocity(math.Rand(40, 60) * VectorRand() * Scayul)
	particle:SetAirResistance(20)
	particle:SetDieTime(0.05)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(0)
	particle:SetStartSize(20 * Scayul)
	particle:SetEndSize(600 * Scayul)
	particle:SetRoll(math.Rand(180, 480))
	particle:SetRollDelta(math.Rand(-1, 1))
	particle:SetColor(255, 255, 255)

	if Dirt then
		for i = 0, 5 * Scayul do
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

			local particle = emitter:Add(sprite, vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(100, 150))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		for i = 0, 5 * Scayul do
			local particle = emitter:Add("particles/smokey", vOffset + Direc * 20)
			particle:SetVelocity(Vector(math.Rand(-1000, 1000) * Scayul, math.Rand(-1000, 1000) * Scayul, 0))
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
		end

		for i = 0, 5 * Scayul do
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

			local particle = emitter:Add(sprite, vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(100, 150))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -500))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
		end

		for i = 0, 10 * Scayul do
			local particle = emitter:Add("particle/particle_composite", vOffset)
			particle:SetVelocity(VectorRand() * math.Rand(0, 50) * Scayul + Direc * math.Rand(0, 1000) * Scayul)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(20, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 100) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 200) + Vector(0, 0, -600))
			particle:SetLighting(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		for i = 0, 30 * Scayul do
			local particle = emitter:Add("effects/fleck_cement" .. math.random(1, 2), vOffset)
			particle:SetVelocity(VectorRand() * math.Rand(0, 300) * Scayul + Direc * math.Rand(0, 1500) * Scayul)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 13))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size = math.Rand(2, 15) * Scayul
			particle:SetStartSize(Size)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 200) + Vector(0, 0, -700))
			particle:SetLighting(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
			particle:SetBounce(0.1)
		end
	elseif Concrete then
		for i = 0, 3 * Scayul do
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

			local particle = emitter:Add(sprite, vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(100, 150))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		for i = 0, 3 * Scayul do
			local particle = emitter:Add("particles/smokey", vOffset + Direc * 20)
			particle:SetVelocity(Vector(math.Rand(-1000, 1000) * Scayul, math.Rand(-1000, 1000) * Scayul, 0))
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
		end

		for i = 0, 3 * Scayul do
			local particle = emitter:Add("particle/smokestack", vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -500))
			particle:SetLighting(true)
			particle:SetCollide(true)
			particle:SetColor(255, 255, 255)
		end

		for i = 0, 2 * Scayul do
			local particle = emitter:Add("particle/particle_composite", vOffset)
			particle:SetVelocity(VectorRand() * math.Rand(0, 50) * Scayul + Direc * math.Rand(0, 1000) * Scayul)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(20, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 100) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 200) + Vector(0, 0, -600))
			particle:SetLighting(true)
			particle:SetColor(255, 255, 255)
			particle:SetCollide(true)
		end

		for i = 0, 20 * Scayul do
			local particle = emitter:Add("effects/fleck_cement" .. math.random(1, 2), vOffset)
			particle:SetVelocity(VectorRand() * math.Rand(0, 300) * Scayul + Direc * math.Rand(0, 1500) * Scayul)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size = math.Rand(2, 10) * Scayul
			particle:SetStartSize(Size)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 200) + Vector(0, 0, -700))
			particle:SetLighting(true)
			particle:SetColor(255, 255, 255)
			particle:SetCollide(true)
			particle:SetBounce(0.5)
		end
	elseif Wood then
		for i = 0, 5 * Scayul do
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

			local particle = emitter:Add(sprite, vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(100, 150))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		for i = 0, 3 * Scayul do
			local particle = emitter:Add("particles/smokey", vOffset + Direc * 20)
			particle:SetVelocity(Vector(math.Rand(-1000, 1000) * Scayul, math.Rand(-1000, 1000) * Scayul, 0))
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
		end

		for i = 0, 2 * Scayul do
			local particle = emitter:Add("particle/smokestack", vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -500))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
		end

		for i = 0, 70 * Scayul do
			local particle = emitter:Add("effects/fleck_wood" .. math.random(1, 2), vOffset)
			particle:SetVelocity(VectorRand() * math.Rand(0, 300) * Scayul + Direc * math.Rand(0, 1500) * Scayul)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size = math.Rand(2, 10) * Scayul
			particle:SetStartSize(Size)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 200) + Vector(0, 0, -700))
			particle:SetLighting(true)
			local darg = math.Rand(175, 255)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
			particle:SetBounce(0.25)
		end
	elseif Metal then
		for i = 0, 3 * Scayul do
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

			local particle = emitter:Add(sprite, vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 1000) * Scayul + Direc * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(100, 150))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -500))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
		end

		for i = 0, 2 * Scayul do
			local particle = emitter:Add("particles/smokey", vOffset + Direc * 20)
			particle:SetVelocity(Vector(math.Rand(-1000, 1000) * Scayul, math.Rand(-1000, 1000) * Scayul, 0))
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
		end
	elseif Air then
		for i = 0, 2 * Scayul do
			local particle = emitter:Add("particle/smokestack", vOffset + Direc * 5)
			particle:SetVelocity(VectorRand() * math.Rand(0, 5000) * Scayul)
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -500))
			particle:SetLighting(true)
			particle:SetCollide(true)
			particle:SetColor(255, 255, 255)
		end

		for i = 0, 1 * Scayul do
			local particle = emitter:Add("particles/smokey", vOffset + Direc * 20)
			particle:SetVelocity(Vector(math.Rand(-1000, 1000) * Scayul, math.Rand(-1000, 1000) * Scayul, math.Rand(-1000, 1000) * Scayul))
			particle:SetAirResistance(400)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(3, 5))
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(30, 70) * Scayul)
			particle:SetEndSize(math.Rand(70, 150) * Scayul)
			particle:SetRoll(math.Rand(0, 6))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetGravity(VectorRand() * math.Rand(0, 1000) + Vector(0, 0, -200))
			particle:SetLighting(true)
			particle:SetCollide(true)
			local darg = math.Rand(200, 255)
			particle:SetColor(darg, darg, darg)
		end
	end

	for i = 0, 20 do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(2000, 3000) * Scayul + Vector(0, 0, math.Rand(1000, 2500)) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.4, 0.7) * Scayul)
			local herpdemutterfickendenderp = math.Rand(200, 255)
			particle:SetColor(255, herpdemutterfickendenderp, herpdemutterfickendenderp - 50)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(5, 8) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(math.Rand(-1000, 500), math.Rand(-1000, 1000), math.Rand(0, 1000)))
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
	end

	local particle = emitter:Add("sprites/heatwave", vOffset)
	particle:SetVelocity(Vector(0, 0, 0))
	particle:SetAirResistance(200)
	particle:SetGravity(VectorRand() * math.Rand(0, 200))
	particle:SetDieTime(math.Rand(0.1, 0.2) * Scayul)
	particle:SetStartAlpha(75)
	particle:SetEndAlpha(0)
	particle:SetStartSize(250 * Scayul)
	particle:SetEndSize(150 * Scayul)
	particle:SetRoll(math.Rand(0, 10))
	particle:SetRollDelta(6000)
	emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 200
		dlight.b = 175
		dlight.Brightness = 2 * Scayul ^ 0.5
		dlight.Size = 250 * Scayul ^ 0.5
		dlight.Decay = 1000
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 0
	end
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Siyuz = self.Siyuz + 150
		self:NextThink(CurTime() + .01)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / .25
	local Opacity = math.Clamp(TimeLeftFraction * 80 * self.Scayul, 0, 255)
	render.SetMaterial(ShockWave)
	render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	render.DrawSprite(self.Pos, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
end
