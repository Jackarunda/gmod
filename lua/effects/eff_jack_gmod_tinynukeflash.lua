local Glow = Material("sprites/mat_jack_basicglow")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.LifeTime = 6
	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	local Frac = (self.DieTime - CurTime()) / self.LifeTime
	local Pos = self.Position + Vector(0, 0, 3000 - 3000 * Frac)
	local Vec = EyePos() - Pos
	local SpritePos = Pos + Vec / 2
	render.SetMaterial(Glow)
	render.DrawSprite(SpritePos, 20000 * Frac, 20000 * Frac, Color(255, 175, 150, 255))
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = Pos
		dlight.r = 255
		dlight.g = 240
		dlight.b = 230
		dlight.Brightness = 12 * Frac
		dlight.Size = 10000
		dlight.Decay = 3000
		dlight.DieTime = CurTime() + self.LifeTime
		dlight.Style = 0
	end
end
