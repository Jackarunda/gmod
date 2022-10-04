local ShockWave = Material("sprites/mat_jack_shockwave_white")
local Refract = Material("sprites/mat_jack_shockwave")

function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Scayul = data:GetScale()
	local SelfNorm = data:GetNormal()
	local BasePower = data:GetRadius()
	self.Pos = SelfPos
	self.Scayul = Scayul
	self.Normal = SelfNorm
	self.Siyuz = 1
	self.DieTime = CurTime() + .25
	self.Opacity = 1
	local Dec = "FadingScorch"

	if BasePower > 13 then
		Dec = "Scorch"
	end

	util.Decal(Dec, SelfPos + SelfNorm, SelfPos - SelfNorm)

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(SelfPos)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(5)
		util.Effect("WaterSplash", Splach)

		return
	end

	if false then
		local effectdata = EffectData()
		effectdata:SetOrigin(SelfPos)
		effectdata:SetNormal(SelfNorm)
		effectdata:SetMagnitude(60 * Scayul) --amount and shoot hardness
		effectdata:SetScale(5 * Scayul) --length of strands
		effectdata:SetRadius(20 * Scayul) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
	end

	local Emitter = ParticleEmitter(SelfPos)

	for i = 0, 20 do
		local Particle = Emitter:Add("sprites/mat_jack_nicespark", SelfPos + VectorRand() * math.Rand(0, 3))

		if Particle then
			Particle:SetVelocity(SelfNorm * math.Rand(10, 4000) * Scayul + VectorRand() * math.Rand(0, 4000) * Scayul)
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.05, .1))
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(200, 225, 255)
			Particle:SetStartAlpha(math.Rand(200, 255))
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.Rand(5, 10) * Scayul)
			Particle:SetEndSize(250 * Scayul)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(0)
			Particle:SetAirResistance(500)
			Particle:SetGravity(Vector(0, 0, 0))
			Particle:SetCollide(true)
			Particle:SetLighting(false)
		end
	end

	for i = 0, 8 do
		local Particle = Emitter:Add("sprites/heatwave", SelfPos + VectorRand() * math.Rand(0, 1))

		if Particle then
			Particle:SetVelocity(VectorRand() * math.Rand(0, 100))
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.5, 1.5) * Scayul ^ .3)
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(1)
			Particle:SetEndSize(math.Rand(50, 250) * Scayul)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(0)
			Particle:SetAirResistance(100)
			Particle:SetGravity(Vector(0, 0, 75))
			Particle:SetCollide(true)
			Particle:SetLighting(false)
			Particle:SetBounce(.8)
		end
	end

	for i = 0, 10 do
		local Particle = Emitter:Add("sprites/mat_jack_smoke" .. tostring(math.random(1, 3)), SelfPos + VectorRand() * math.Rand(0, 1))

		if Particle then
			Particle:SetVelocity(VectorRand() * math.Rand(0, 100))
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.5, 1.5))
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
			Particle:SetStartAlpha(math.random(100, 200))
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(1)
			Particle:SetEndSize(math.Rand(50, 250) * Scayul)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(0)
			Particle:SetAirResistance(100)
			Particle:SetGravity(Vector(0, 0, 75))
			Particle:SetCollide(true)
			Particle:SetLighting(true)
			Particle:SetBounce(.8)
		end
	end

	local dlightend = DynamicLight(self:EntIndex())
	dlightend.Pos = SelfPos
	dlightend.Size = 8000 * Scayul
	dlightend.Decay = 6000
	dlightend.R = 120
	dlightend.G = 150
	dlightend.B = 255
	dlightend.Brightness = 20 * Scayul
	dlightend.DieTime = CurTime() + .1
	Emitter:Finish()
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Siyuz = self.Siyuz + 650
		self:NextThink(CurTime() + .01)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / .25
	local Opacity = math.Clamp(TimeLeftFraction * 100 * self.Scayul, 0, 255)
	render.SetMaterial(ShockWave)
	render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	render.DrawSprite(self.Pos, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
end
