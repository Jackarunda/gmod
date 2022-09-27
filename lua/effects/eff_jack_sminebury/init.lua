function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	self.Pos = vOffset
	self.Scayul = Scayul
	self.Normal = data:GetNormal()
	self.Siyuz = 1
	self.DieTime = CurTime() + .1
	self.Opacity = 1
	local emitter = ParticleEmitter(vOffset)

	for i = 0, 100 * Scayul ^ 2 do
		local sprite = "effects/fleck_cement" .. math.random(1, 2)
		local Debris = emitter:Add(sprite, vOffset)

		if Debris then
			Debris:SetVelocity(VectorRand() * math.Rand(50, 75) * Scayul ^ 0.5 + Vector(0, 0, math.Rand(50, 75)))
			Debris:SetDieTime(3 * math.random(1, 2))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(math.random(1, 5) * Scayul ^ 0.5)
			Debris:SetRoll(math.Rand(0, 360))
			Debris:SetRollDelta(math.Rand(-5, 5))
			Debris:SetAirResistance(1)
			Debris:SetColor(105, 100, 90)
			Debris:SetGravity(Vector(0, 0, -800))
			Debris:SetCollide(true)
			Debris:SetBounce(.2)
			Debris:SetLighting(true)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
