local Glow = Material("sprites/mat_jack_basicglow")

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Scale = data:GetScale() or 1
	self.LifeTime = .2
	self.DieTime = CurTime() + self.LifeTime

	-- Some smoke effect
	local emitter = ParticleEmitter(self.Position)

	if emitter then
		for i = 1, math.ceil(15 * self.Scale) do
			local particle = emitter:Add("particles/smokey", self.Position)

			if particle then
				particle:SetVelocity(Vector(math.Rand(-.2, .2), math.Rand(-.2, .2), math.Rand(-1, 1)) * math.random(200, 500) * self.Scale)
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(2, 6) * self.Scale)
				particle:SetStartAlpha(math.Rand(150, 200))
				particle:SetEndAlpha(0)
				particle:SetStartSize(10)
				particle:SetEndSize(120 * self.Scale)
				particle:SetRoll(math.rad(math.Rand(0, 360)))
				particle:SetRollDelta(math.Rand(-1, 1))
				particle:SetLighting(false)
				particle:SetAirResistance(75)
				particle:SetGravity(Vector(0, 0, 20))
				local Brightness = math.Rand(.75, 1)
				particle:SetColor(255 * Brightness, 255 * Brightness, 255 * Brightness)
				particle:SetCollide(true)
			end
		end

		emitter:Finish()
	end
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

		if (Pos:Distance(self.Position) < 1500) then
			if not util.TraceLine({
				start = Pos,
				endpos = self.Position,
				filter = {self, ply}
			}).Hit and not(JMod.PlyHasArmorEff(ply, "flashresistant")) then
				JMod.AddFlashbangEffect(ply, self.Position, self.Scale * (1 - Pos:Distance(self.Position) / 1500) ^ 2)
			end
		end
	end
end
