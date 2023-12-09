function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	local Scayul = data:GetScale()
	local Dir = data:GetNormal()
	local Vel = data:GetStart()
	local Scl = Scayul
	local Pos = vOffset
	local UnderWater = self:WaterLevel() == 3
	local emitter = ParticleEmitter(vOffset)

	if emitter then
		if not UnderWater then
			for i = 0, 30 * Scayul ^ 0.5 do
				local Pos = data:GetOrigin()
				local particle = emitter:Add("sprites/mat_jack_nicespark", Pos)

				if particle then
					particle:SetVelocity((Dir + VectorRand() * .2) * math.random(10, 500) * Scayul + Vel)
					particle:SetLifeTime(0)
					particle:SetDieTime(math.Rand(0.1, 1.5))
					local herpdemutterfickendenderp = math.Rand(200, 255)
					particle:SetColor(255, herpdemutterfickendenderp - 10, herpdemutterfickendenderp - 20)
					particle:SetStartAlpha(255)
					particle:SetEndAlpha(0)
					particle:SetStartSize(1)
					particle:SetEndSize(0)
					particle:SetRoll(math.Rand(-360, 360))
					particle:SetRollDelta(math.Rand(-0.21, 0.21))
					particle:SetAirResistance(200)
					particle:SetGravity(Vector(0, 0, -600))
					particle:SetLighting(false)
					particle:SetCollide(true)
					particle:SetBounce(0.95)
				end
			end

			for i = 1, 4 * Scl do
				local ParticlePos = Pos + Dir
				local particle = emitter:Add("particle/smokestack", ParticlePos)
				particle:SetVelocity(Dir * math.random(50, 100) + VectorRand() * 10 + Vel)
				particle:SetAirResistance(100)
				particle:SetGravity(Vector(0, 0, 100))
				particle:SetDieTime(math.Rand(.1, 1))
				particle:SetStartAlpha(math.random(50, 255))
				particle:SetEndAlpha(0)
				local Size = math.Rand(1, 10) * Scl
				particle:SetStartSize(Size / 2)
				particle:SetEndSize(Size)
				particle:SetRoll(math.Rand(-2, 2))
				particle:SetRollDelta(math.Rand(-2, 2))
				local Col = math.random(200, 255)
				particle:SetColor(Col, Col, Col)
				particle:SetLighting(math.random(1, 2) == 1)
				particle:SetCollide(false)
			end
		else
			for i = 0, 5 do
				local Bubble = emitter:Add("effects/bubble", Pos)

				if Bubble then
					Bubble:SetVelocity(VectorRand() * math.Rand(0, 150) + Dir)
					Bubble:SetLifeTime(0)
					Bubble:SetDieTime(math.Rand(.5, 1))
					local shadevariation = math.Rand(-10, 10)
					Bubble:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
					Bubble:SetStartAlpha(math.Rand(150, 255))
					Bubble:SetEndAlpha(0)
					Bubble:SetStartSize(math.Rand(1, 3))
					Bubble:SetEndSize(math.Rand(3, 6))
					Bubble:SetRoll(math.Rand(-360, 360))
					Bubble:SetRollDelta(math.Rand(-5, 5))
					Bubble:SetAirResistance(200)
					Bubble:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20), math.Rand(20, 600)))
					Bubble:SetCollide(false)
					Bubble:SetLighting(false)
				end
			end
		end

		emitter:Finish()
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
