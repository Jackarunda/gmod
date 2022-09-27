local Mat = Material("sprites/mat_jack_nicespark")

function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Scayul = data:GetScale()
	local SelfNorm = data:GetNormal()
	self.Pos = SelfPos
	self.Scayul = Scayul
	self.Normal = SelfNorm
	self.Siyuz = Scayul * 300
	self.DieTime = CurTime() + 40 * Scayul
	self.Opacity = 1
	self.Mat = Mat
	util.Decal("FadingScorch", SelfPos + SelfNorm, SelfPos - SelfNorm)
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		self:NextThink(CurTime() + .01)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = (self.DieTime - CurTime()) / (40 * self.Scayul)
	local Opacity = TimeLeftFraction * 255
	local Heat = TimeLeftFraction
	local Red = math.Clamp(Heat * 463 - 69, 0, 255)
	local Green = math.Clamp(Heat * 1000 - 800, 0, 255)
	local Blue = math.Clamp(Heat * 2550 - 2295, 0, 255)
	render.SetMaterial(self.Mat)
	render.DrawQuadEasy(self.Pos, self.Normal, self.Siyuz, self.Siyuz, Color(Red, Green, Blue, Opacity))
end
