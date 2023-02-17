local Flash = Material("sprites/light_glow02")
Flash:SetInt("$spriterendermode", 9)
Flash:SetInt("$ignorez", 0)
Flash:SetInt("$illumfactor", 8)

function EFFECT:Init(data)
	self.DieTime = CurTime() + 1
	self.Position = data:GetOrigin()
	self.Size = data:GetScale()
	local emitter = ParticleEmitter(self.Position)

	for i = 0, 25 do
		local particle = emitter:Add("sprites/mat_jack_gravipinch", self.Position)
		particle:SetVelocity(Vector(0, 0, 0))
		particle:SetDieTime(.75)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(self.Size or 150)
		particle:SetEndSize(0)
		particle:SetRoll(0)
		particle:SetRollDelta(0)
		particle:SetColor(0, 0, 0)
	end

	emitter:Finish()
	--[[local DLight=DynamicLight(0)
	if(DLight)then
		DLight.Brightness=5
		DLight.Decay=750*10
		DLight.DieTime=CurTime()+.05
		DLight.Pos=self:GetPos()+Vector(1,1,-20)
		DLight.Size=750
		DLight.r=255
		DLight.g=255
		DLight.b=255
	end--]]
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
