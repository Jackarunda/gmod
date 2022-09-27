-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Oil Fire"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
---
ENT.EZscannerDanger = true
ENT.DepositKey = 0

if SERVER then
    --[[function ENT:SpawnFunction(ply,tr) -- todo: remove this when we're done
		local SpawnPos=tr.HitPos-tr.HitNormal*2
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(180, 0, 90))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end]]
    -- (I don't know if you want to get rid of it RN)
    function ENT:Initialize()
        self.Entity:SetModel("models/props_wasteland/prison_pipefaucet001a.mdl")
        self.Entity:PhysicsInit(SOLID_NONE)
        self.Entity:SetMoveType(MOVETYPE_NONE)
        self.Entity:SetSolid(SOLID_NONE)
        self.Entity:DrawShadow(true)

        ---
        timer.Simple(0.1, function()
            local Tr = util.QuickTrace(self:GetPos() + Vector(2, 0, 10), Vector(0, 0, -40))

            if Tr.Hit then
                util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
            end

            self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
            self.SoundLoop:SetSoundLevel(80)
            self.SoundLoop:Play()
        end)

        --self.SoundLoop:SetSoundLevel(80)
        ---
        SafeRemoveEntityDelayed(self, 300)
    end

    function ENT:CanSee(ent)
        if not IsValid(ent) then return false end
        local TargPos, SelfPos = ent:LocalToWorld(ent:OBBCenter()), self:LocalToWorld(self:OBBCenter()) + vector_up * 5

        local Tr = util.TraceLine({
            start = SelfPos,
            endpos = TargPos,
            filter = {self, ent},
            mask = MASK_SHOT + MASK_WATER
        })

        return not Tr.Hit
    end

    function ENT:BurnStuff()
        local Up, Forward, Right, Range = self:GetUp(), self:GetForward(), self:GetRight(), 300
        local Pos = self:GetPos() + Right * 150

        for i, ent in pairs(ents.FindInSphere(Pos + Right * 150, Range)) do
            if ent ~= self then
                local DDistance = Pos:Distance(ent:GetPos())
                local DistanceFactor = (1 - DDistance / Range) ^ 2

                if self:CanSee(ent) then
                    local Dmg = DamageInfo()
                    Dmg:SetDamage(100 * DistanceFactor) -- wanna scale this with distance
                    Dmg:SetDamageType(DMG_BURN)
                    Dmg:SetDamageForce(Vector(0, 0, 50000) * DistanceFactor) -- some random upward force
                    Dmg:SetAttacker(game.GetWorld()) -- the earth is mad at you
                    Dmg:SetInflictor(game.GetWorld())
                    Dmg:SetDamagePosition(ent:GetPos())

                    if ent.TakeDamageInfo then
                        ent:TakeDamageInfo(Dmg)
                    end
                end
            end
        end
    end

    function ENT:Think()
        local Time = CurTime()
        local SelfPos = self:LocalToWorld(self:OBBCenter())
        local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()

        if self:WaterLevel() >= 3 then
            self:Remove()

            return
        end

        local Eff = EffectData()
        Eff:SetOrigin(self:GetPos() + self:GetRight() * 10)
        Eff:SetNormal(self:GetRight())
        util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)

        if math.random(1, 4) == 2 then
            local FireVec = VectorRand() + Vector(0, 0, 2)
            local Flame = ents.Create("ent_jack_gmod_eznapalm")
            Flame:SetPos(SelfPos + Vector(0, 0, 10))
            Flame:SetAngles(FireVec:Angle())
            Flame:SetOwner(self.Owner or game.GetWorld())
            JMod.Owner(Flame, self.Owner or self)
            Flame.SpeedMul = 1
            Flame.Creator = self
            Flame.HighVisuals = true
            Flame:Spawn()
            Flame:Activate()
        end

        if self.DepositKey and JMod.NaturalResourceTable[self.DepositKey] then
            if JMod.DepleteNaturalResource(self.DepositKey, .1) then
                self:Remove()
            end
        else
            self:Remove()
        end

        self:BurnStuff()
        self:NextThink(Time + .1)

        return true
    end

    function ENT:OnRemove()
        if self.SoundLoop then
            self.SoundLoop:Stop()
        end
    end
elseif CLIENT then
    local GlowSprite = Material("sprites/mat_jack_basicglow")
    local HeatWaveMat = Material("sprites/heatwave")

    function ENT:Initialize()
    end

    ---
    function ENT:Draw()
        self:DrawModel()
        local Pos, Dir = self:GetPos(), self:GetRight()
        render.SetMaterial(GlowSprite)

        for i = 1, 10 do
            render.DrawSprite(Pos + Dir * (i * math.random(30, 60)), 150, 150, Color(255, 255 - i * 10, 255 - i * 20, 255))
        end

        render.SetMaterial(HeatWaveMat)

        for i = 1, 3 do
            render.DrawSprite(Pos + Dir * (i * math.random(50, 80)), 250, 200, Color(255, 255 - i * 10, 255 - i * 20, 255))
        end

        local dlight = DynamicLight(self:EntIndex())

        if dlight then
            dlight.pos = Pos + Dir * 200
            dlight.r = 255
            dlight.g = 60
            dlight.b = 10
            dlight.brightness = 8
            dlight.Decay = 200
            dlight.Size = 1000
            dlight.DieTime = CurTime() + .5
        end
    end

    language.Add("ent_jack_gmod_ezoilfire", "EZ Oil Fire")
end
