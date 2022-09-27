-- copied from Slayer
EFFECT.Mat = Material("mat_jack_gmod_shinesprite")

function EFFECT:Init(data)
	self.StartPos = data:GetOrigin()
	self.Dir = data:GetNormal()
	self.Vel = data:GetStart()
	self.TracerTime = .05
	self.DieTime = CurTime() + self.TracerTime
	local Scayul = 1
	self.Emitter = ParticleEmitter(self.StartPos)

	for i = 1, 30 * Scayul do
		local particle = self.Emitter:Add("mat_jack_gmod_glowsprite", self.StartPos + self.Dir)
		particle:SetVelocity(self.Vel + self.Dir * math.Rand(0, 1000) * Scayul + VectorRand() * math.Rand(0, 250) * Scayul)
		particle:SetAirResistance(250)
		particle:SetGravity(Vector(0, 0, -100))
		particle:SetDieTime(math.Rand(.01, .2) * Scayul)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		local Size = 1
		particle:SetStartSize(Size)
		particle:SetEndSize(0)
		particle:SetRoll(0)

		if math.random(1, 2) == 1 then
			particle:SetRollDelta(0)
		else
			particle:SetRollDelta(math.Rand(-.5, .5))
		end

		particle:SetColor(255, 255, 255)
		particle:SetLighting(false)
		particle:SetCollide(true)
	end

	self.Emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.pos = self.StartPos + self.Dir * 10
		dlight.r = 255
		dlight.g = 0
		dlight.b = 0
		dlight.brightness = 1
		dlight.Decay = 600
		dlight.Size = 200
		dlight.DieTime = CurTime() + .1
	end
end

function EFFECT:Think()
	if CurTime() > self.DieTime then return false end
	self.StartPos = self.StartPos + self.Vel * FrameTime()

	return true
end

function EFFECT:Render()
	local fDelta = (self.DieTime - CurTime()) / self.TracerTime
	fDelta = math.Clamp(fDelta, 0, 1)
	render.SetMaterial(self.Mat)
	render.DrawSprite(self.StartPos, 60 - fDelta * 60, 60 - fDelta * 60, Color(255, 0, 0, 255 * fDelta ^ .5))
	render.DrawSprite(self.StartPos, 28 - fDelta * 28, 28 - fDelta * 28, Color(255, 0, 0, 255 * fDelta ^ .5))
	render.DrawSprite(self.StartPos, 20 - fDelta * 20, 20 - fDelta * 20, Color(255, 255, 255, 255 * fDelta ^ .5))
end
