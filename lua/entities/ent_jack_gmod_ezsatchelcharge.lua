-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Satchel Charge"
ENT.Spawnable = true
ENT.Model = "models/jmodels/explosives/grenades/satchelcharge/satchel_charge.mdl"
ENT.SpoonEnt = nil
--ENT.ModelScale=2.5
ENT.Mass = 20
ENT.HardThrowStr = 250
ENT.SoftThrowStr = 125

ENT.Hints = {"arm"}

DEFINE_BASECLASS(ENT.Base)

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)
        local plunger = ents.Create("ent_jack_gmod_ezblastingmachine")
        plunger:SetPos(self:GetPos() + self:GetForward() * 5)
        plunger:SetAngles(self:GetAngles())
        plunger:Spawn()
        plunger.Satchel = self
        plunger.Owner = self.Owner
        self.Plunger = plunger

        timer.Simple(0, function()
            plunger:SetParent(self)
        end)

        if istable(WireLib) then
            self.Inputs = WireLib.CreateInputs(self, {"Detonate"}, {"This will directly detonate the bomb"})

            self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"Off \n Primed \n Armed"})
        end
    end

    function ENT:TriggerInput(iname, value)
        if iname == "Detonate" and value > 0 then
            self:Detonate()
        elseif iname == "Prime" and value > 0 then
            self:SetState(JMod.EZ_STATE_PRIMED)
        end
    end

    function ENT:Prime()
        self:EmitSound("weapons/c4/c4_plant.wav", 60, 80)
        self:SetState(JMod.EZ_STATE_PRIMED)
        self.Plunger:SetParent(nil)
        constraint.NoCollide(self, self.Plunger, 0, 0)
        constraint.Rope(self, self.Plunger, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 2000, 0, 0, .5, "cable/cable", false)

        timer.Simple(0, function()
            self.Plunger:SetPos(self:GetPos() + Vector(0, 0, 20))
        end)
    end

    function ENT:Arm()
        --self:EmitSound("buttons/button5.wav",60,150)
        self:SetState(JMod.EZ_STATE_ARMED)
    end

    function ENT:Use(activator, activatorAgain, onOff)
        local Dude = activator or activatorAgain
        JMod.Owner(self, Dude)
        local Time = CurTime()

        if tobool(onOff) then
            local State = self:GetState()
            if State < 0 then return end
            local Alt = Dude:KeyDown(JMod.Config.AltFunctionKey)

            if State == JMod.EZ_STATE_OFF and Alt then
                self:Prime()
                activator:PickupObject(self.Plunger)
                JMod.Hint(Dude, "arm satchelcharge", self.Plunger)
            else
                activator:PickupObject(self)
                JMod.Hint(Dude, "arm")
            end
        end
    end

    function ENT:Detonate()
        if self.Exploded then return end
        self.Exploded = true

        if IsValid(self.Plunger) then
            JMod.Owner(self, self.Plunger.Owner)
        end

        timer.Simple(0, function()
            if IsValid(self) then
                local SelfPos, PowerMult = self:GetPos(), 5
                --
                local Blam = EffectData()
                Blam:SetOrigin(SelfPos)
                Blam:SetScale(PowerMult / 1.5)
                util.Effect("eff_jack_plastisplosion", Blam, true, true)
                util.ScreenShake(SelfPos, 99999, 99999, 1, 750 * PowerMult)

                for i = 1, 2 do
                    sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 140, math.random(80, 110))
                end

                for i = 1, PowerMult do
                    sound.Play("BaseExplosionEffect.Sound", SelfPos, 120, math.random(90, 110))
                end

                self:EmitSound("snd_jack_fragsplodeclose.wav", 90, 100)

                timer.Simple(.1, function()
                    for i = 1, 5 do
                        local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

                        if Tr.Hit then
                            util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
                        end
                    end
                end)

                JMod.WreckBuildings(self, SelfPos, PowerMult)
                JMod.BlastDoors(self, SelfPos, PowerMult)

                timer.Simple(0, function()
                    local ZaWarudo = game.GetWorld()
                    local Infl, Att = (IsValid(self) and self) or ZaWarudo, (IsValid(self) and IsValid(self.Owner) and self.Owner) or (IsValid(self) and self) or ZaWarudo
                    util.BlastDamage(Infl, Att, SelfPos, 100 * PowerMult, 160 * PowerMult)
                    self:Remove()
                end)
            end
        end)
    end

    function ENT:OnRemove()
        if IsValid(self.Plunger) then
            SafeRemoveEntityDelayed(self.Plunger, 3)
        end
    end
elseif CLIENT then
    local GlowSprite = Material("sprites/mat_jack_basicglow")

    function ENT:Draw()
        self:DrawModel()
        local State = self:GetState()
        local pos = self:GetPos() + self:GetUp() * 2.8 + self:GetRight() * -2.6 + self:GetForward() * -3

        if State == JMod.EZ_STATE_ARMING then
            render.SetMaterial(GlowSprite)
            render.DrawSprite(pos, 10, 10, Color(255, 0, 0))
            render.DrawSprite(pos, 5, 5, Color(255, 255, 255))
        elseif State == JMod.EZ_STATE_ARMED then
            render.SetMaterial(GlowSprite)
            render.DrawSprite(pos, 5, 5, Color(255, 100, 0))
            render.DrawSprite(pos, 2, 2, Color(255, 255, 255))
        end
    end

    language.Add("ent_jack_gmod_ezsatchelcharge", "EZ Satchel Charge")
end
