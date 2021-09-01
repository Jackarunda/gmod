local Sprite = "particle/smokestack"

function EFFECT:Init(data)
	local Pos, Norm, Vel, Clr = data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetAngles()
	local R, G, B = Clr.pitch, Clr.yaw, Clr.roll
	local Emitter = ParticleEmitter(Pos)
	for i = 1, 2 do
		local RollParticle = Emitter:Add(Sprite, Pos)
		if RollParticle then
			RollParticle:SetVelocity(Vel + Norm * math.random(50, 100) + VectorRand() * 10)
			RollParticle:SetAirResistance(100)
			RollParticle:SetDieTime(4)
			RollParticle:SetStartAlpha(255)
			RollParticle:SetEndAlpha(0)

			local Size = math.Rand(30, 60)
			RollParticle:SetStartSize(Size / 8)
			RollParticle:SetEndSize(Size * 2)
			RollParticle:SetRoll(math.Rand(-3, 3))
			RollParticle:SetRollDelta(math.Rand(-2, 2))

			local Vec = VectorRand() * 10 + Vector(0, 0, 200) + JMod.Wind * 150
			RollParticle:SetGravity(Vec)
			RollParticle:SetLighting(false)
			
			local Brightness = math.Rand(.5, 1)
			RollParticle:SetColor(R * Brightness, G * Brightness, B * Brightness)
			RollParticle:SetCollide(true)
			RollParticle:SetBounce(1)
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	-- no u
end