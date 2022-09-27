-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezresource"
ENT.PrintName = "EZ Oil Drum"
ENT.Category = "JMod - EZ Resources"
ENT.IconOverride = "materials/ez_resource_icons/oil.png"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.OIL
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.Model = "models/props_c17/oildrum001.mdl"
ENT.Material = "phoenix_storms/black_chrome"
--ENT.Color=Color(100,100,100)
ENT.SpawnHeight = 30
ENT.ModelScale = .75
ENT.Mass = 50
ENT.ImpactNoise1 = "Metal_Barrel.ImpactHard"
ENT.ImpactNoise2 = "Weapon.ImpactSoft"
ENT.DamageThreshold = 120
ENT.BreakNoise = "Metal_Barrel.Break"

--ENT.Hint="coolant"
---
if SERVER then
    function ENT:UseEffect(pos, ent, destructive)
        for i = 1, 2 do
            local Eff = EffectData()
            Eff:SetOrigin(pos + VectorRand() * 10)
            util.Effect("StriderBlood", Eff, true, true)
        end

        if destructive then
            local Tr = util.QuickTrace(pos, Vector(math.random(-200, 200), math.random(-200, 200), math.random(0, -200)), {self})

            if Tr.Hit then
                local Fiah = ents.Create("env_fire")
                Fiah:SetPos(Tr.HitPos + Tr.HitNormal)
                Fiah:SetKeyValue("health", 30)
                Fiah:SetKeyValue("fireattack", 1)
                Fiah:SetKeyValue("firesize", math.random(20, 200))
                Fiah:SetOwner(self.Owner or game.GetWorld())
                Fiah:Spawn()
                Fiah:Activate()
                Fiah:Fire("StartFire", "", 0)
                Fiah:Fire("kill", "", math.random(3, 10))
            end
        end
    end
elseif CLIENT then
    local TxtCol = Color(255, 255, 255, 80)

    function ENT:Draw()
        self:DrawModel()

        JMod.HoloGraphicDisplay(self, Vector(0, -10.6, 17), Angle(90, 0, 90), .04, 300, function()
            JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.OIL, self:GetResource(), nil, 0, 0, 200, true)
        end)
    end

    language.Add(ENT.ClassName, ENT.PrintName)
end
