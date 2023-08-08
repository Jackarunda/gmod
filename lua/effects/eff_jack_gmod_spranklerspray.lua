local Wake = Material("effects/splashwake1")

function EFFECT:Init(data)
	self.Scale = data:GetScale()
	self.Pos = data:GetOrigin()
	self.Dir = data:GetStart()
	self.DieTime = CurTime() + math.Rand(0.5, 1) * self.Scale
	--self.Size = 5
	---
	local emitter = ParticleEmitter(self.Pos)

	for i = 1, 20 * self.Scale do
		local Sprite = table.Random({"effects/splash1", "effects/splash2", "effects/splash4"})
		local SpraySize = math.random(1, 15) * self.Scale

		local particle = emitter:Add(Sprite, self.Pos)
		particle:SetVelocity(self.Dir * 40 * SpraySize)
		particle:SetCollide(true)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0, 0, -50)*SpraySize)
		particle:SetAirResistance(10/SpraySize)
		particle:SetDieTime(SpraySize * 0.05)
		particle:SetStartAlpha(250-SpraySize*5)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(5 * SpraySize)
		particle:SetRoll(math.Rand(180, 480))
		--particle:SetRollDelta(math.Rand(-1, 1) * 6)
		particle:SetColor(255, 255, 255)
	end

	emitter:Finish()
end

function EFFECT:Think()
	if self.DieTime > CurTime() then
		--self.Size = self.Size + .3
		self:NextThink(CurTime() + .1)

		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeftFraction = self.DieTime - CurTime()
	local Opacity = math.Clamp(TimeLeftFraction * 255, 0, 255)
	--print(Opacity)
	---
	--render.SetMaterial(Wake)
	--render.DrawQuadEasy(self.Pos + self.Normal * 5, self.Normal, self.Size, self.Size, Color(255, 255, 255, Opacity))
	--render.DrawQuadEasy(self.Pos + self.Normal * 5, self.Normal, self.Size, self.Size, Color(255, 255, 255, Opacity))

	return
end
