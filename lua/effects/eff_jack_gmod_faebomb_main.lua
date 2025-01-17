DEFINE_BASECLASS( "eff_jack_gmod_explosion_base" )

local Refract = Material("sprites/mat_jack_shockwave")

function EFFECT:Init(data)
	--print("welp",self.Del_Bepis)
	local Pos, Scale = data:GetOrigin(), data:GetScale()
	self.DieTime = CurTime() + .3
	local Emitter = ParticleEmitter(Pos)

	for i = 0, 300 do
		local particle = Emitter:Add("sprites/flamelet" .. math.random(1, 3), Pos)
		particle:SetVelocity(VectorRand() * 15000 * Scale)
		particle:SetAirResistance(1000)
		particle:SetGravity(Vector(0, 0, 0))
		particle:SetDieTime(math.Rand(.1, .3))
		particle:SetStartAlpha(math.Rand(200, 255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(200, 600) * Scale)
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

		for i = 0, 50 do
			local particle = Emitter:Add("particle/smokestack", Pos)
			particle:SetVelocity(VectorRand() * 15000 * Scale)
			particle:SetAirResistance(1000)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetDieTime(math.Rand(2, 6))
			particle:SetStartAlpha(math.Rand(100, 255))
			particle:SetEndAlpha(0)
			local Siz = math.Rand(200, 600) * Scale
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
	self.Scale = Scale
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
		DLight.Brightness = 10 * Frac ^ .2
		DLight.Size = 3000
		DLight.Decay = 15000
		DLight.DieTime = CurTime() + .3
		DLight.Style = 0
	end

	local SpriteSize = 8000 * Frac * self.Scale
	local SpriteSize2 = 7000 * Frac * self.Scale

	render.SetMaterial(Refract)
	render.DrawSprite(self.Pos, SpriteSize, SpriteSize, Color(255, 255, 255, 255))
	render.DrawSprite(self.Pos, SpriteSize2, SpriteSize2, Color(255, 255, 255, 255))
end
