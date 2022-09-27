local Wake = Material("effects/splashwake1")

function EFFECT:Init(data)
    self.Scale = data:GetScale()
    self.Pos = data:GetOrigin()
    self.Mine = data:GetEntity()
    self.DieTime = CurTime() + math.Rand(.5, 1)
    self.Size = 5
    self.Normal = Vector(0, 0, 1)
    ---
    local emitter = ParticleEmitter(self.Pos)

    for i = 1, 2 do
        local Sprite = table.Random({"effects/splash1", "effects/splash2", "effects/splash4"})

        local particle = emitter:Add(Sprite, self.Pos)
        particle:SetVelocity(VectorRand() * math.Rand(0, 50) * self.Scale + Vector(0, 0, math.Rand(50, 100) * self.Scale))
        particle:SetCollide(false)
        particle:SetLighting(false)
        particle:SetBounce(.01)
        particle:SetGravity(Vector(0, 0, -600))
        particle:SetAirResistance(10)
        particle:SetDieTime(math.Rand(.2, .4) * self.Scale)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(10)
        particle:SetEndSize(10)
        particle:SetRoll(math.Rand(180, 480))
        particle:SetRollDelta(math.Rand(-1, 1) * 6)
        particle:SetColor(255, 255, 255)
    end

    emitter:Finish()
end

function EFFECT:Think()
    if self.DieTime > CurTime() then
        self.Size = self.Size + .3
        self:NextThink(CurTime() + .1)

        return true
    else
        return false
    end
end

function EFFECT:Render()
    local TimeLeftFraction = self.DieTime - CurTime()
    local Opacity = math.Clamp(TimeLeftFraction * 255, 0, 255)
    print(Opacity)
    ---
    render.SetMaterial(Wake)
    render.DrawQuadEasy(self.Pos + self.Normal * 5, self.Normal, self.Size, self.Size, Color(255, 255, 255, Opacity))
    render.DrawQuadEasy(self.Pos + self.Normal * 5, self.Normal, self.Size, self.Size, Color(255, 255, 255, Opacity))

    return
end
