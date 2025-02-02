local Wake = Material("effects/splashwake1")

function EFFECT:Init(data)
	self.Scale = data:GetScale()
	self.Pos = data:GetOrigin()
	self.Mine = data:GetEntity()
	self.DieTime = CurTime() + 5
	self.Size = 150
	self.Normal = Vector(0, 0, 1)

	local Tr = util.TraceLine({
		start = self.Pos + Vector(0, 0, 1000),
		endpos = self.Pos,
		filter = {self.Mine},
		mask = MASK_WATER
	})

	if Tr.Hit then
		self.Pos = Tr.HitPos
	end

	---
	local Splach = EffectData()
	Splach:SetOrigin(self.Pos)
	Splach:SetNormal(Vector(0, 0, 1))
	Splach:SetScale(100)
	util.Effect("WaterSplash", Splach)
	---
	sound.Play("snds_jack_gmod/watersplode_with_rain.ogg", self.Pos + Vector(0, 0, 100), 80, math.random(95, 105), 1)
	sound.Play("snds_jack_gmod/watersplode_with_rain.ogg", self.Pos + Vector(0, 0, 110), 80, math.random(95, 105), 1)
	---
	local emitter = ParticleEmitter(self.Pos)

	for i = 0, 200 do
		local Sprite = "effects/jmod/splash2"

		local Vec = Vector(math.Rand(-80, 80), math.Rand(-80, 80), 0) * self.Scale
		local Dist = Vec:Length()
		local particle = emitter:Add(Sprite, self.Pos + Vec)
		particle:SetVelocity(VectorRand() * math.Rand(.5, 2) * Dist ^ .5 * self.Scale + Vector(0, 0, math.Rand(1500, 15000)) * self.Scale / Dist ^ .5)
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0, 0, -1200))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.3, 1.3) * self.Scale)
		particle:SetStartAlpha(math.Rand(150, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(.1, 60) * self.Scale)
		particle:SetEndSize(math.Rand(.1, 40) * self.Scale)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1) * 6)
		particle:SetColor(255, 255, 255)
	end

	for i = 0, 150 do
		local Sprite = "effects/jmod/splash2"
		local Rand = math.random(1, 3)

		local Vec = Vector(math.Rand(-80, 80), math.Rand(-80, 80), 0) * self.Scale
		local Dist = Vec:Length()
		local particle = emitter:Add(Sprite, self.Pos + Vec)
		particle:SetVelocity((VectorRand() * math.Rand(.5, 2) * Dist ^ .5 * self.Scale + Vector(0, 0, math.Rand(1000, 10000)) * self.Scale / Dist ^ .5) * 2)
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0, 0, -1200))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.3, 1.3) * self.Scale)
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1) * 6)
		particle:SetColor(255, 255, 255)
	end

	for i = 0, 100 do
		local Sprite = "effects/jmod/splash2"
		local Rand = math.random(1, 3)

		local Vec = Vector(math.Rand(-80, 80), math.Rand(-80, 80), 0) * self.Scale
		local Dist = Vec:Length()
		local particle = emitter:Add(Sprite, self.Pos + Vec)
		particle:SetVelocity((VectorRand() * math.Rand(.5, 2) * Dist ^ .5 * self.Scale + Vector(0, 0, -math.Rand(500, 5000)) * self.Scale / Dist ^ .5) * 2)
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0, 0, 600))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.3, 1) * self.Scale)
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(100)
		particle:SetEndSize(100)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1) * 6)
		particle:SetColor(255, 255, 255)
	end

	emitter:Finish()
	local Pos, Scale = self.Pos, self.Scale

	timer.Simple(.1, function()
		local emitter = ParticleEmitter(Pos)

		for i = 0, 500 do
			local Sprite = "effects/jmod/splash2"

			local particle = emitter:Add(Sprite, Pos)
			particle:SetVelocity(VectorRand() * math.Rand(0, 200) * Scale + Vector(0, 0, math.Rand(200, 1000) * Scale))
			particle:SetCollide(false)
			particle:SetLighting(false)
			particle:SetBounce(.01)
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetAirResistance(10)
			particle:SetDieTime(math.Rand(1, 3) * Scale)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(5)
			particle:SetEndSize(5)
			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1) * 6)
			particle:SetColor(255, 255, 255)
		end

		emitter:Finish()
	end)

	for i = 1, 1000 do
		local StartPos = Pos + Vector(math.random(-1000, 1000), math.random(-1000, 1000), 1000)

		timer.Simple(i / 200 + 1.5, function()
			local Tr = util.TraceLine({
				start = StartPos,
				endpos = StartPos + Vector(0, 0, -2000),
				mask = -1
			})

			if Tr.Hit then
				local Splach = EffectData()
				Splach:SetOrigin(Tr.HitPos)
				Splach:SetNormal(Vector(0, 0, 1))
				Splach:SetScale(1)
				util.Effect("eff_jack_gmod_tinysplash", Splach)
			end
		end)
	end
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Size = self.Size + 10
		self:NextThink(CurTime() + .1)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / 4
	local Opacity = math.Clamp(TimeLeftFraction * 200, 0, 255)
	---
	render.SetMaterial(Wake)
	render.DrawQuadEasy(self.Pos + self.Normal * 5, self.Normal, self.Size, self.Size, Color(255, 255, 255, Opacity))
	render.DrawQuadEasy(self.Pos + self.Normal * 5, self.Normal, self.Size, self.Size, Color(255, 255, 255, Opacity))

	return
end
