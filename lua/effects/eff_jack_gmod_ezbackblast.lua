local Refract = Material("sprites/mat_jack_shockwave")

function EFFECT:Init(data)
	local Pos, Scale, Norm = data:GetOrigin(), data:GetScale(), data:GetNormal()
	self.DieTime = CurTime() + .15
	local Emitter = ParticleEmitter(Pos)

	for i = 0, 100 do
		local particle = Emitter:Add("sprites/flamelet" .. math.random(1, 3), Pos + Norm * 50)
		particle:SetVelocity(VectorRand() * 500 * Scale + Norm * math.Rand(0, 2000))
		particle:SetAirResistance(1000)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetDieTime(math.Rand(.05, .15))
		particle:SetStartAlpha(math.Rand(100, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(20, 40) * Scale)
		particle:SetRoll(math.Rand(-3, 3))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	for i = 0, 10 do
		local particle = Emitter:Add("sprites/flamelet" .. math.random(1, 3), Pos - Norm * 50)
		particle:SetVelocity(VectorRand() * 500 * Scale - Norm * math.Rand(0, 2000))
		particle:SetAirResistance(1000)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetDieTime(math.Rand(.05, .15))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(20, 40) * Scale)
		particle:SetRoll(math.Rand(-3, 3))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetLighting(false)
		local darg = 255
		particle:SetColor(darg, darg, darg)
		particle:SetCollide(true)
	end

	Emitter:Finish()

	timer.Simple(.2, function()
		local Emitter = ParticleEmitter(Pos)

		for i = 0, 10 do
			local particle = Emitter:Add("particle/smokestack", Pos + Norm * 50)
			particle:SetVelocity(VectorRand() * 500 * Scale + Norm * math.Rand(0, 2000))
			particle:SetAirResistance(1000)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetDieTime(math.Rand(1, 2))
			particle:SetStartAlpha(math.Rand(100, 255))
			particle:SetEndAlpha(0)
			local Siz = math.Rand(20, 60) * Scale
			particle:SetStartSize(Siz)
			particle:SetEndSize(Siz)
			particle:SetRoll(math.Rand(-3, 3))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetLighting(false)
			local darg = math.random(10, 50)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(true)
		end

		Emitter:Finish()
	end)

	self.Pos = Pos
end

function EFFECT:Think()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	local Frac = 1 - (self.DieTime - CurTime()) / .3
	local DLight = DynamicLight(self:EntIndex())

	if DLight then
		DLight.Pos = self.Pos
		DLight.r = 255
		DLight.g = 150
		DLight.b = 100
		DLight.Brightness = 3 * Frac ^ .2
		DLight.Size = 1000
		DLight.Decay = 30000
		DLight.DieTime = CurTime() + .1
		DLight.Style = 0
	end
	--[[
	render.SetMaterial(Refract)
	render.DrawSprite(self.Pos,8000*Frac,8000*Frac,Color(255,255,255,255))
	render.DrawSprite(self.Pos,7000*Frac,7000*Frac,Color(255,255,255,255))
	--]]
end
