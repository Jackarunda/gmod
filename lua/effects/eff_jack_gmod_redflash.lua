local Flash = Material("sprites/mat_jack_basicglow")
function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	self.LifeTime = .1
	self.DieTime = CurTime() + self.LifeTime
end
function EFFECT:Think()
	return self.DieTime > CurTime()
end
function EFFECT:Render()
	local Time = CurTime()
	local TimeLeft = self.DieTime - Time
	local Frac = (TimeLeft / self.LifeTime)
	render.SetMaterial(Flash)
	render.DrawSprite(self.Pos, 200 * Frac, 200 * Frac, Color(255, 0, 0, 255))
	render.DrawSprite(self.Pos, 60 * Frac, 60 * Frac, Color(255, 255, 255, 255))
	local DLight = DynamicLight(0)
	if DLight then
		DLight.Brightness = 7
		DLight.Decay = 2000
		DLight.DieTime = CurTime() + .1
		DLight.Pos = self.Pos
		DLight.Size = 300 * Frac
		DLight.r = 255
		DLight.g = 0
		DLight.b = 0
	end
end
