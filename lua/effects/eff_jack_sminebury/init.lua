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

	local Tr = util.TraceLine({
		start = vOffset,
		endpos = vOffset - self.Normal * 10
	})
	local MatColor = Color(105, 100, 90)
	if Tr.HitWorld and Tr.MatType and JMod.HitMatColors[Tr.MatType] then
		MatColor = JMod.HitMatColors[Tr.MatType][1]
	end

	for i = 0, 100 * Scayul do
		local sprite = "effects/fleck_cement" .. math.random(1, 2)
		local Debris = emitter:Add(sprite, vOffset + VectorRand() * 5 * Scayul + self.Normal)

		if Debris then
			Debris:SetVelocity(VectorRand() * math.Rand(50, 75) * Scayul ^ 0.5 + self.Normal * math.Rand(50, 75))
			Debris:SetDieTime(3 * math.random(1, 2))
			Debris:SetStartAlpha(255)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(math.random(1, 5) * Scayul ^ 0.5)
			Debris:SetRoll(math.Rand(0, 3))
			Debris:SetRollDelta(math.Rand(-2, 2))
			Debris:SetAirResistance(.8)
			Debris:SetColor(MatColor.r, MatColor.g, MatColor.b)
			Debris:SetGravity(Vector(0, 0, -600))
			Debris:SetCollide(true)
			Debris:SetBounce(0)
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
