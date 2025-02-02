local Wake = Material("effects/splashwake1")

function EFFECT:Init(data)
	self.Scl = data:GetScale()
	self.Pos = data:GetOrigin()
	self.Dir = data:GetStart()
	---
	local emitter = ParticleEmitter(self.Pos)

	for i = 1, 20 * self.Scl do
		local Sprite = table.Random({"effects/jmod/splash2"})

		local particle = emitter:Add(Sprite, self.Pos)
		particle:SetVelocity(self.Dir * math.random(400, 500) + VectorRand() * math.random(0, 10))
		particle:SetCollide(true)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetAirResistance(math.random(0, 50))
		particle:SetDieTime(math.Rand(.5, 1.2) * self.Scl)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(1)
		particle:SetEndSize(math.random(1, 30))
		particle:SetRoll(math.Rand(180, 480))
		--particle:SetRollDelta(math.Rand(-1, 1) * 6)
		if (math.random(1, 2) == 1) then
			particle:SetColor(180, 200, 210)
		else
			particle:SetColor(220, 220, 220)
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return
end
