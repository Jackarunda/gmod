﻿function EFFECT:Init(data)
	local Pos, Scl, Normal, Spread = data:GetOrigin(), data:GetScale(), data:GetNormal(), data:GetMagnitude()

	if Normal == Vector(0, 0, 0) then
		Normal = nil
	end

	if Spread == 0 then
		Spread = nil
	end

	local Disperse = 3
	for j = 1, Disperse do
		timer.Simple(j * .05, function()
			local Emitter = ParticleEmitter(Pos)

			for i = 0, Scl / Disperse do
				local Dir

				if Normal and Spread then
					Dir = Vector(Normal.x, Normal.y, Normal.z)
					Dir = Dir + VectorRand() * math.Rand(0, Spread)
					Dir:Normalize()
				else
					Dir = VectorRand()
				end

				local particle = Emitter:Add("particle/smokestack", Pos)
				particle:SetVelocity(Dir * 1000000)
				particle:SetAirResistance(10)
				particle:SetGravity(Vector(0, 0, 0))
				particle:SetDieTime(math.Rand(.1, .5))
				particle:SetStartAlpha(math.Rand(200, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(0)
				particle:SetEndSize(math.Rand(15, 30))
				particle:SetRoll(math.Rand(-3, 3))
				particle:SetRollDelta(math.Rand(-3, 3))
				particle:SetLighting(true)
				local darg = math.Rand(10, 150)
				particle:SetColor(darg, darg, darg)
				particle:SetCollide(true)
			end

			Emitter:Finish()
		end)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end