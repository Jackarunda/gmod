local Glow = Material("sprites/mat_jack_basicglow")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Scale = data:GetScale()
	self.LifeTime = .2
	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:Think()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	local Frac = (self.DieTime - CurTime()) / self.LifeTime
	render.SetMaterial(Glow)
	render.DrawSprite(self.Position, 6000 * Frac ^ 2, 6000 * Frac ^ 2, Color(255, 255, 255, 255))
	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = self.Position
		dlight.r = 255
		dlight.g = 240
		dlight.b = 230
		dlight.Brightness = 12 * Frac
		dlight.Size = 3000
		dlight.Decay = 3000
		dlight.DieTime = CurTime() + 1
		dlight.Style = 0
	end

	if Frac < .8 then
		local Pos, ply = EyePos(), LocalPlayer()

		if (Pos:Distance(self.Position) < 2000) then
			if not util.TraceLine({
				start = Pos,
				endpos = self.Position,
				filter = {self, ply}
			}).Hit and not(JMod.PlyHasArmorEff(ply, "flashresistant")) then
				JMod.AddFlashbangEffect(ply, self.Position, (self.Scale and self.Scale or 1) * (1 - Pos:Distance(self.Position) / 2000))
			end
		end
	end
end
