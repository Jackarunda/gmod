local function ColorRand()
	local Chance = math.random(1, 3)

	if Chance == 1 then
		return 255, 150, 0
	elseif Chance == 2 then
		return 0, 175, 255
	elseif Chance == 3 then
		return 255, 0, 255
	end
end

function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local SelfVel = data:GetStart()
	local Scayul = data:GetScale()
	local Nerml = data:GetNormal()
	local Emitter = ParticleEmitter(SelfPos)

	if true then
		for i = 1, 100 * Scayul do
			local Inv = 100 - i
			local Sprite = "sprites/mat_jack_coolness"
			local Particle = Emitter:Add(Sprite, SelfPos)

			if Particle then
				Particle:SetVelocity((Nerml * i * 20 + VectorRand() * Inv * 1 + SelfVel) * math.Rand(.8, 1.2))
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.05, .2))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(ColorRand())
				Particle:SetStartAlpha(math.Rand(5, 200))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(0, 2) * Scayul)
				Particle:SetEndSize(math.Rand(2, 10) * Scayul * Inv / 15)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(100)
				Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(200, 400)) * Scayul)
				Particle:SetCollide(false)
				Particle:SetLighting(false)
			end
		end
	end

	for i = 1, 300 * Scayul do
		local Sprite = "sprites/mat_jack_coolness"
		local Particle = Emitter:Add(Sprite, SelfPos)

		if Particle then
			Particle:SetVelocity(Nerml * math.Rand(30, 3000) + VectorRand() * math.Rand(10, 1000) + SelfVel)
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.02, .1))
			local shadevariation = math.Rand(-10, 10)
			Particle:SetColor(ColorRand())
			Particle:SetStartAlpha(math.Rand(50, 255))
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.Rand(0, 4) * Scayul)
			Particle:SetEndSize(math.Rand(5, 20) * Scayul)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(math.Rand(-5, 5))
			Particle:SetAirResistance(1000)
			Particle:SetGravity(Vector(math.Rand(-30, 30), math.Rand(-30, 30), math.Rand(-10, -300)) * Scayul)
			Particle:SetCollide(false)
			Particle:SetLighting(false)
		end
	end

	Emitter:Finish()
	local dlightend = DynamicLight(0)
	dlightend.Pos = SelfPos
	dlightend.Size = 1000 * Scayul
	dlightend.Decay = 2000
	dlightend.R = 100
	dlightend.G = 150
	dlightend.B = 255
	dlightend.Brightness = 4 * Scayul
	dlightend.DieTime = CurTime() + .1
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
