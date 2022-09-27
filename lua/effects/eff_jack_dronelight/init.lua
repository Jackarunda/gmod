function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	self.Position = vOffset
	self.TimeToDie = CurTime() + .5
	self.Scayul = data:GetScale()
	local emitter = ParticleEmitter(vOffset)
	local rollparticle = emitter:Add("sprites/mat_jack_basicglow", vOffset)

	if rollparticle then
		rollparticle:SetVelocity(Vector(0, 0, 0))
		rollparticle:SetLifeTime(0)
		local life = .05
		local begin = CurTime()
		rollparticle:SetDieTime(life)
		rollparticle:SetColor(255, 255, 255)
		rollparticle:SetStartAlpha(255)
		rollparticle:SetEndAlpha(0)
		rollparticle:SetStartSize(20 * self.Scayul)
		rollparticle:SetEndSize(20)
		rollparticle:SetRoll(math.Rand(-360, 360))
		rollparticle:SetRollDelta(math.Rand(-0.61, 0.61) * 5)
		rollparticle:SetAirResistance(0)
		rollparticle:SetGravity(Vector(0, 0, 0))
		rollparticle:SetCollide(false)
		rollparticle:SetLighting(false)
	end

	emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = vOffset
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 1.6 * self.Scayul
		dlight.Size = 800 * self.Scayul
		dlight.Decay = 500 * self.Scayul
		dlight.DieTime = CurTime() + .03
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
--damn
