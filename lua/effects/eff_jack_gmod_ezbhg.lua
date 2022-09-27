local GlowSprite = Material("sprites/mat_jack_basicglow")

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	self.Pos = vOffset
	self.DedTiem = CurTime() + 2
	local Spl = EffectData()
	Spl:SetOrigin(vOffset)
	Spl:SetScale(1)
	util.Effect("Explosion", Spl, true, true)
	local Emitter = ParticleEmitter(vOffset)

	for i = 1, 300 do
		local particle = Emitter:Add("particle/smokestack", vOffset + VectorRand() * 0)

		if particle then
			local Dir = VectorRand() * math.random(1, 3000)
			particle:SetVelocity(Dir)
			particle:SetAirResistance(0)
			particle:SetDieTime(2)
			particle:SetStartAlpha(10)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.random(30, 300))
			particle:SetEndSize(10)
			particle:SetRoll(math.Rand(-3, 3))
			particle:SetRollDelta(math.Rand(-2, 2))
			particle:SetGravity(-Dir)
			particle:SetLighting(false)
			local darg = math.Rand(50, 150)
			particle:SetColor(darg, darg, darg)
			particle:SetCollide(false)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return self.DedTiem > CurTime()
end

function EFFECT:Render()
	local TimeLeft = (self.DedTiem - CurTime()) / 2
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.pos = self.Pos
		dlight.r = 255 * TimeLeft
		dlight.g = 255 * TimeLeft
		dlight.b = 255 * TimeLeft
		dlight.brightness = 10
		dlight.Decay = 12000
		dlight.Size = 5000
		dlight.DieTime = CurTime() + 1
	end

	render.SetMaterial(GlowSprite)

	for i = 0, 10 do
		render.DrawSprite(self.Pos + VectorRand() * 200 * TimeLeft, 800 * TimeLeft, 800 * TimeLeft, Color(255, 255, 255, 255))
	end
end
