local ShockWave = Material("sprites/mat_jack_shockwave_white")
local Refract = Material("sprites/mat_jack_shockwave")
local Shit = Material("sprites/mat_jack_ignorezsprite")

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Scale = Scayul
	self.Position = vOffset
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = Vector(0, 0, 1)
	self.Siyuz = 1
	self.DieTime = CurTime() + .3
	self.Opacity = 1
	self.TimeToDie = CurTime() + 0.03 * self.Scale
	local Spl = EffectData()
	Spl:SetOrigin(vOffset)
	Spl:SetScale(1)
	util.Effect("Explosion", Spl, true, true)

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
	particle:SetDieTime(0.04 * Scayul)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(10 * Scayul)
	particle:SetEndSize(300 * Scayul)
	particle:SetRoll(math.Rand(180, 480))
	particle:SetRollDelta(math.Rand(-1, 1) * 6)
	particle:SetColor(255, 255, 255)

	for i = 0, 500 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		particle:SetVelocity(math.Rand(30000, 32000) * VectorRand() * Scayul)
		particle:SetAirResistance(3000)
		particle:SetGravity(Vector(0, 0, math.Rand(40000, 60000)))
		particle:SetDieTime(math.Rand(.1, .3))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(5)
		particle:SetStartSize(math.Rand(60, 90) * Scayul)
		particle:SetEndSize(math.Rand(90, 100) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	for i = 0, 200 * Scayul do
		local sprite = "sprites/flamelet" .. math.random(1, 3)
		local particle = emitter:Add(sprite, vOffset)
		local Dir = VectorRand()
		particle:SetVelocity(math.Rand(30000, 32000) * Dir * Scayul)
		particle:SetAirResistance(3000)
		particle:SetGravity(-Vector(Dir.x, Dir.y, 0) * 70000)
		particle:SetDieTime(math.Rand(.1, .3))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(5)
		particle:SetStartSize(math.Rand(60, 90) * Scayul)
		particle:SetEndSize(math.Rand(90, 100) * Scayul)
		particle:SetRoll(0)
		particle:SetRollDelta(math.Rand(-6, 6))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg, darg - 30, darg - 30)
		particle:SetCollide(true)
	end

	for i = 0, 50 * Scayul do
		local Pos = data:GetOrigin() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))
		local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

		if particle then
			particle:SetVelocity(VectorRand() * math.Rand(10, 4000) * Scayul)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.3, 1))
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

	for i = 0, 10 * Scayul do
		local particle = emitter:Add("sprites/heatwave", vOffset)
		particle:SetVelocity(VectorRand() * math.Rand(0, 2000))
		particle:SetAirResistance(200)
		particle:SetGravity(VectorRand() * math.Rand(0, 200))
		particle:SetDieTime(math.Rand(.2, .6) * Scayul)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1000 * Scayul)
		particle:SetEndSize(1500 * Scayul)
		particle:SetRoll(math.Rand(0, 10))
		particle:SetRollDelta(6000)
	end

	emitter:Finish()

	timer.Simple(0.2, function()
		local Emitter = ParticleEmitter(vOffset)

		for i = 0, 200 * Scayul do
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
			particle:SetVelocity(math.Rand(30000, 50000) * VectorRand() * Scayul)
			particle:SetAirResistance(4000)
			particle:SetGravity(Vector(0, 0, math.Rand(200, 4000)))
			particle:SetDieTime(math.Rand(4, 7))
			particle:SetStartAlpha(math.Rand(50, 200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(70, 120) * Scayul)
			particle:SetEndSize(math.Rand(100, 190) * Scayul)
			particle:SetRoll(math.Rand(-3, 3))
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
		dlight.Brightness = 7 * Scayul ^ 0.5
		dlight.Size = 3000 * Scayul ^ 0.5
		dlight.Decay = 8000
		dlight.DieTime = CurTime() + 0.3
		dlight.Style = 0
	end
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self.Siyuz = self.Siyuz + 700
		self:NextThink(CurTime() + .01)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / .25
	local Opacity = math.Clamp(TimeLeftFraction * 150 * self.Scayul, 0, 255)
	render.SetMaterial(ShockWave)
	render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
	render.DrawSprite(self.Pos, self.Siyuz, self.Siyuz, Color(255, 255, 255, Opacity))
end
