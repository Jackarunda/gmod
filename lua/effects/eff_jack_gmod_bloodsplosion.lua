function EFFECT:Init(data)
    self.Origin = data:GetOrigin()
    local emitter = ParticleEmitter(self.Origin)
    local Pos = self.Origin

    for i = 0, 10 do
        local particle = emitter:Add("sprites/flamelet1", Pos + VectorRand() * math.Rand(1, 50))

        if particle then
            particle:SetVelocity(VectorRand() * math.Rand(250, 1000))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(.05, .15))
            particle:SetColor(255, 255, 255)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(255)
            local Size = math.Rand(200, 600)
            particle:SetStartSize(Size)
            particle:SetEndSize(Size)
            particle:SetRoll(math.Rand(-360, 360))
            particle:SetRollDelta(math.Rand(-0.21, 0.21))
            particle:SetAirResistance(500)
            particle:SetGravity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(0, -1000)))
            particle:SetCollide(true)
            particle:SetBounce(0.45)
            particle:SetLighting(1)
        end
    end

    for i = 0, 25 do
        local particle = emitter:Add("particle/smokestack", Pos + VectorRand() * math.Rand(1, 50))

        if particle then
            particle:SetVelocity(VectorRand() * math.Rand(250, 1000))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 3))
            particle:SetColor(math.Rand(75, 150), 0, 0)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            local Size = math.Rand(10, 75)
            particle:SetStartSize(Size)
            particle:SetEndSize(Size * 2)
            particle:SetRoll(math.Rand(-360, 360))
            particle:SetRollDelta(math.Rand(-0.21, 0.21))
            particle:SetAirResistance(500)
            particle:SetGravity(Vector(math.Rand(-1000, 1000), math.Rand(-1000, 1000), math.Rand(0, -1000)))
            particle:SetCollide(true)
            particle:SetBounce(0.45)
            particle:SetLighting(1)
        end
    end

    for i = 0, 1000 do
        local particle = emitter:Add("sprites/mat_jack_crapfleck", Pos)

        if particle then
            particle:SetVelocity(VectorRand() * math.Rand(200, 600) + Vector(0, 0, 200))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(7, 10))
            particle:SetColor(100, 20, 20)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(255)
            local derpikins = math.random(1, 15)
            particle:SetStartSize(derpikins)
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(-360, 360))
            particle:SetRollDelta(math.Rand(-0.21, 0.21))
            particle:SetAirResistance(1)
            particle:SetGravity(Vector(0, 0, math.Rand(-600, -1400)))
            particle:SetCollide(true)
            particle:SetBounce(0)
            particle:SetLighting(1)
        end
    end

    emitter:Finish()
    DLight = DynamicLight(0)

    if DLight then
        DLight.Brightness = 7
        DLight.Decay = 750 * 10
        DLight.DieTime = CurTime() + .1
        DLight.Pos = self:GetPos() + Vector(1, 1, -20)
        DLight.Size = 1000
        DLight.r = 255
        DLight.g = 255
        DLight.b = 255
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
