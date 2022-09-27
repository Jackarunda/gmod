function EFFECT:Init(data)
	local SelfPos = data:GetOrigin()
	local Scayul = data:GetScale()
	local SelfNorm = data:GetNormal()
	local Emitter = ParticleEmitter(SelfPos)
	if not Emitter then return end

	for i = 1, 6 do
		local RandAng = SelfNorm:Angle() --ingenious
		RandAng:RotateAroundAxis(SelfNorm, math.Rand(0, 360))
		RandAng:RotateAroundAxis(RandAng:Up(), 90)
		local RandVec = RandAng:Forward()
		local Particle = Emitter:Add("particles/flamelet" .. tostring(math.random(1, 5)), SelfPos + RandVec * math.Rand(1, 150 * Scayul))

		if Particle then
			Particle:SetVelocity(VectorRand() * math.Rand(0, 100))
			Particle:SetLifeTime(0)
			Particle:SetDieTime(math.Rand(.3, 1))
			local shadevariation = math.Rand(-20, 20)
			Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Size = math.Rand(50, 100) * Scayul
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size / 2)
			Particle:SetRoll(math.Rand(-360, 360))
			Particle:SetRollDelta(math.Rand(-5, 5))
			Particle:SetAirResistance(10)
			Particle:SetGravity(Vector(0, 0, 800))
			Particle:SetCollide(true)
			Particle:SetLighting(false)
		end

		if false then
			local Particle = Emitter:Add("sprites/mat_jack_smoke" .. tostring(math.random(1, 3)), SelfPos + RandVec * math.Rand(1, 200 * Scayul))

			if Particle then
				Particle:SetVelocity(Vector(0, 0, 0))
				Particle:SetLifeTime(0)
				Particle:SetDieTime(math.Rand(.5, 3))
				local shadevariation = math.Rand(-10, 10)
				Particle:SetColor(math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255), math.Clamp(255 + shadevariation + math.Rand(-5, 5), 0, 255))
				Particle:SetStartAlpha(math.Rand(50, 100))
				Particle:SetEndAlpha(0)
				Particle:SetStartSize(math.Rand(0, 10) * Scayul)
				Particle:SetEndSize(math.Rand(100, 400) * Scayul)
				Particle:SetRoll(math.Rand(-360, 360))
				Particle:SetRollDelta(math.Rand(-5, 5))
				Particle:SetAirResistance(500)
				Particle:SetGravity(Vector(0, 0, 3000) + VectorRand() * math.Rand(0, 1000))
				Particle:SetCollide(false)
				Particle:SetLighting(true)
			end
		end

		if math.random(1, 20) == 2 then
			local particle = Emitter:Add("sprites/heatwave", SelfPos + RandVec * math.Rand(1, 200 * Scayul))

			if particle then
				particle:SetVelocity(Vector(0, 0, 0))
				particle:SetAirResistance(200)
				particle:SetGravity(VectorRand() * math.Rand(500, 2500))
				particle:SetDieTime(math.Rand(.75, 1.25) * Scayul)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(250 * Scayul)
				particle:SetEndSize(150 * Scayul)
				particle:SetRoll(math.Rand(0, 10))
				particle:SetRollDelta(3)
				particle:SetCollide(true)
				particle:SetLighting(false)
			end
		end
	end

	Emitter:Finish()
	--[[local dlight=DynamicLight(self:EntIndex())
	if(dlight)then
		dlight.Pos=self:GetPos()
		dlight.r=255
		dlight.g=175
		dlight.b=150
		dlight.Brightness=2
		dlight.Size=1000
		dlight.Decay=10
		dlight.DieTime=CurTime()+2
		dlight.Style=0
	end--]]
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
