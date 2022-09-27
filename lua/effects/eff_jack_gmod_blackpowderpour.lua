function EFFECT:Init(data)
    local Origin = data:GetOrigin()
    local Vel = data:GetStart()
    local Emitter = ParticleEmitter(Origin)

    for i = 1, 20 do
        local Particle = Emitter:Add("sprites/spark", Origin)

        if Particle then
            Particle:SetVelocity(Vel + VectorRand() * 5)
            Particle:SetAirResistance(10)
            Particle:SetDieTime(math.random(5, 10))
            Particle:SetStartAlpha(255)
            Particle:SetEndAlpha(0)
            Particle:SetStartSize(math.random(1, 2))
            Particle:SetEndSize(0)
            Particle:SetRoll(math.Rand(-3, 3))
            Particle:SetRollDelta(math.Rand(-2, 2))
            Particle:SetGravity(Vector(0, 0, math.random(-300, -600)))
            Particle:SetLighting(true)
            Particle:SetColor(50, 50, 50)
            Particle:SetCollide(true)
            Particle:SetBounce(0)
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
