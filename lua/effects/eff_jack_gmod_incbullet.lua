-- copied from Slayer
function EFFECT:Init(data)
    local Pos = data:GetOrigin()
    self.Emitter = ParticleEmitter(Pos)
    local Scayul = data:GetScale()
    self.Scayul = Scayul
    local Norm = data:GetNormal()
    local Vel = Vector(0, 0, 0)
    local R, G, B = 255, 175, 160
    -- flash --
    local particle = self.Emitter:Add("sprites/mat_jack_basicglow", Pos + Norm)
    particle:SetVelocity(Vel + Norm * math.Rand(0, 1))
    particle:SetAirResistance(50)
    particle:SetGravity(Vector(0, 0, -600))
    particle:SetDieTime(.05)
    particle:SetStartAlpha(255)
    particle:SetEndAlpha(0)
    local Size = math.random(.1, 2) * Scayul
    particle:SetStartSize(Size)
    particle:SetEndSize(Size * 10)
    particle:SetRoll(0)

    if math.random(1, 2) == 1 then
        particle:SetRollDelta(0)
    else
        particle:SetRollDelta(math.Rand(-.5, .5))
    end

    particle:SetColor(R, G, B)
    particle:SetLighting(false)
    particle:SetCollide(false)

    -- sparks --
    for i = 1, 30 do
        local particle = self.Emitter:Add("sprites/mat_jack_basicglow", Pos + Norm)
        particle:SetVelocity(Vel + Norm * math.Rand(100, 1000) + VectorRand() * math.Rand(50, 500))
        particle:SetAirResistance(500)
        particle:SetGravity(Vector(0, 0, -600))
        particle:SetDieTime(math.Rand(.1, .5))
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        local Size = 2
        particle:SetStartSize(Size)
        particle:SetEndSize(0)
        particle:SetRoll(0)

        if math.random(1, 2) == 1 then
            particle:SetRollDelta(0)
        else
            particle:SetRollDelta(math.Rand(-.5, .5))
        end

        particle:SetColor(255, 150, 100)
        particle:SetLighting(false)
        particle:SetCollide(true)
    end

    -- smoke --
    local particle = self.Emitter:Add("particle/smokestack", Pos + Norm)
    particle:SetVelocity(Vel + Norm * math.Rand(0, 50) * Scayul + VectorRand() * math.Rand(0, 50) * Scayul)
    particle:SetAirResistance(50)
    particle:SetGravity(Vector(0, 0, math.Rand(1, 30)))
    particle:SetDieTime(math.Rand(.5, 1) * Scayul)
    particle:SetStartAlpha(255)
    particle:SetEndAlpha(0)
    local Size = math.random(1, 3) * Scayul
    particle:SetStartSize(Size)
    particle:SetEndSize(Size * 5)
    particle:SetRoll(0)

    if math.random(1, 2) == 1 then
        particle:SetRollDelta(0)
    else
        particle:SetRollDelta(math.Rand(-.5, .5))
    end

    particle:SetColor(10, 10, 10)
    particle:SetLighting(false)
    particle:SetCollide(false)
    self.Emitter:Finish()
    ---
    util.Decal("FadingScorch", Pos + Norm, Pos - Norm)
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
--
