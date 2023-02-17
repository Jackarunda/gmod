function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Size = data:GetScale()
	local emitter = ParticleEmitter(self.Position)

	for i = 0, 25 do
		local particle = emitter:Add("sprites/mat_jack_gravipinch", self.Position)
		particle:SetVelocity(Vector(0, 0, 0))
		particle:SetDieTime(.76)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(0)
		particle:SetEndSize(self.Size or 150)
		particle:SetRoll(0)
		particle:SetRollDelta(0)
		particle:SetColor(0, 0, 0)
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
