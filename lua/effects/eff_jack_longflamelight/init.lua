function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 150
		dlight.b = 120
		dlight.Brightness = 7
		dlight.Size = 1700
		dlight.Decay = 41 / JackieSplosivesFireMult
		dlight.DieTime = CurTime() + 30 * JackieSplosivesFireMult
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
