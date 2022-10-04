function EFFECT:Init(data)
	local dirkshun = data:GetNormal()
	local pozishun = data:GetStart()
	local skayul = data:GetScale()
	local dlight = DynamicLight(0)

	if dlight then
		dlight.Pos = pozishun
		dlight.r = 190
		dlight.g = 225
		dlight.b = 255
		dlight.Brightness = .8 * skayul
		dlight.Size = 150 * skayul
		dlight.Decay = 1200 * skayul
		dlight.DieTime = CurTime() + 0.03 * skayul ^ 0.25
		dlight.Style = 0
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
