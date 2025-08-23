-- Jackarunda 2021
--,"particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1","sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
local Sprites = {"particle/smokestack"}

function EFFECT:Init(data)
	local Pos, Norm, Vel, Life = data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetScale()
	local Emitter = ParticleEmitter(Pos)
	local Sprite = table.Random(Sprites)

	if Life < .9 then
		for i = 1, 2 do
			local Particle = Emitter:Add(Sprite, Pos)

			if Particle then
				Particle:SetVelocity(Vel + VectorRand() * 1000 + Vector(0, 0, 1000))
				Particle:SetAirResistance(1000)
				Particle:SetDieTime(math.random(7, 10))
				Particle:SetStartAlpha(255)
				Particle.OriginalStartAlpha = 255
				Particle:SetEndAlpha(0)
				local Size = math.Rand(30, 60)
				Particle:SetStartSize(Size / 50)
				Particle:SetEndSize(Size * 10)
				Particle:SetRoll(math.Rand(-3, 3))
				Particle:SetRollDelta(math.Rand(-2, 2))
				local Vec = VectorRand() * 1500 + JMod.Wind * 150
				Vec.z = Vec.z / 4
				Particle:SetGravity(Vec)
				Particle:SetLighting(false)
				local darg = math.Rand(10, 100)
				Particle:SetColor(darg, darg, darg)
				Particle:SetCollide(true)
				Particle:SetBounce(1)
				---
				Particle:SetNextThink(CurTime())

				Particle:SetThinkFunction(function(pa)
					if JMod.PlyHasArmorEff(LocalPlayer(), "thermalVision") then
						pa:SetStartAlpha(20)
					else
						pa:SetStartAlpha(pa.OriginalStartAlpha)
					end

					pa:SetNextThink(CurTime() + 1)
				end)
			end
		end
	end

	if Life > .8 then
		for i = 1, 2 do
			local RollParticle = Emitter:Add(Sprite, Pos)

			if RollParticle then
				RollParticle:SetVelocity(Vel + Norm * math.random(50, 100) + VectorRand() * 0)
				RollParticle:SetAirResistance(1)
				RollParticle:SetDieTime(math.Rand(.5, 2))
				RollParticle:SetStartAlpha(255)
				RollParticle:SetEndAlpha(0)
				local Size = math.Rand(30, 60)
				RollParticle:SetStartSize(Size / 20)
				RollParticle:SetEndSize(Size * 1)
				RollParticle:SetRoll(math.Rand(-3, 3))
				RollParticle:SetRollDelta(math.Rand(-2, 2))
				local Vec = VectorRand() * 10
				RollParticle:SetGravity(Vec)
				RollParticle:SetLighting(false)
				local darg = math.Rand(10, 100)
				RollParticle:SetColor(darg, darg, darg)
				RollParticle:SetCollide(true)
				RollParticle:SetBounce(1)
			end
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
-- no u
