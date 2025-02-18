local Flash = Material("sprites/mat_jack_basicglow")
function EFFECT:Init(data)
	local Pos, Siz = data:GetOrigin() - Vector(0, 0, 30), data:GetScale()
	local Scl = Siz / 240
	local Time = CurTime()
	local Emitter = ParticleEmitter(Pos)
	local Particles = {}
	for i = 1, 4000 do
		timer.Simple(i / 12000, function()
			local MyPos = Pos + VectorRand():GetNormalized() * Siz * 1.02
			local particle = Emitter:Add("sprites/mat_jack_basicglow", MyPos)
			if (particle) then
				particle:SetVelocity(Vector(0, 0, 0))
				particle:SetAirResistance(500)
				particle:SetGravity(Vector(0, 0, 0))
				particle:SetDieTime(math.Rand(1, 2))
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(5, 20) * Scl)
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(-3, 3))
				particle:SetRollDelta(math.Rand(-3, 3))
				particle:SetLighting(false)
				particle:SetColor(255, 255, 255)
				particle:SetCollide(true)
				table.insert(Particles, particle)
			end
			if (i == 4000) then
				for k, v in pairs(Particles) do
					v:SetStartSize(math.Rand(2, 10) * Scl)
					v:SetVelocity(VectorRand() * math.Rand(0, 1000))
					v:SetGravity(VectorRand() * math.Rand(0, 1000))
				end
				Emitter:Finish()
			end
		end)
	end
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
	return false
end
