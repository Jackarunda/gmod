AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= "EZ Solar Generator"
ENT.Author			= "Jackarunda, TheOnly8Z"
ENT.Category			= "JMod - EZ Misc."
ENT.Information         = ""
ENT.Spawnable			= true

ENT.MaxPower = 100

ENT.BatteryEnt = "ent_jack_gmod_ezbattery"

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Power") -- Fractal power is necessary because solar produces very slowly
	self:NetworkVar("Int", 0, "State")
end

local STATE_OFF, STATE_BROKEN, STATE_ON = 0, -1, 1

if SERVER then

    function ENT:SpawnFunction(ply,tr,ClassName)
        local ent=ents.Create(ClassName)
        ent:SetPos(tr.HitPos + tr.HitNormal*4)
        ent:SetAngles(ply:GetAngles())
        ent:Spawn()
        ent:Activate()
        local effectdata=EffectData()
        effectdata:SetEntity(ent)
        util.Effect("propspawn",effectdata)
        return ent
    end

    function ENT:Initialize()
        self:SetModel("models/jmod/solar_generator.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)	
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(500)
        end
        self:SetUseType(SIMPLE_USE)
        
        self:SetPower(0)
        self:SetState(STATE_OFF)
        self.NextUse = 0
    end
    

    function ENT:Use(activator,caller)

        if(activator:IsPlayer())then
            
            if self.NextUse > CurTime() then return end
            self.NextUse = CurTime() + 0.5
            
            if (self:GetState() == STATE_OFF) then
                if self:GetPower() >= JMod_EZbatterySize then
                    local canplace = self:ProducePower()
                    if not canplace and (self.NextWhine or 0) < CurTime() then
                        self:EmitSound("items/suitchargeno1.wav",70,100)
                        self.NextWhine = CurTime() + 5
                    end
                else
                    self:Start()
                end
            elseif (self:GetState() == STATE_ON) then
                self:ShutOff()
            end
        end
        
    end
    
    function ENT:CheckSky()
    
        local tr = util.TraceLine({
            start = self:GetPos() + self:GetUp() * 64,
            endpos = self:GetPos() + Vector(0,0,999999),
            filter = self
        })
        if not tr.HitSky then return 0 end
        
        -- TODO fancy sky magic math
        return 1
    end
    
    function ENT:SpawnEffect(pos)
        local effectdata=EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
        effectdata:SetMagnitude(math.Rand(5,10))
        effectdata:SetScale(math.Rand(.5,1.5))
        effectdata:SetRadius(math.Rand(2,4))
        util.Effect("Sparks", effectdata)
        self:EmitSound("items/suitchargeok1.wav", 80, 120)
    end
    
    function ENT:ProducePower()

        local amt = math.min(math.floor(self:GetPower()), JMod_EZbatterySize)
        if amt <= 0 then return end
        
        local pos = self:GetPos() + self:GetForward() * -48 + self:GetUp() * 24
        
        for _, ent in pairs(ents.FindInSphere(pos, 100)) do
            print(ent, ent.GetResourceType and ent:GetResourceType())
            if ent:GetClass() == "ent_jack_gmod_ezcrate" and (ent:GetResourceType() == "generic"
                    or (ent:GetResourceType() == "power" and ent:GetResource() + amt <= ent.MaxResource)) then
                    
                if ent:GetResourceType() == "generic" then
                    ent:ApplySupplyType("power")
                end
                    
                ent:SetResource(math.min(ent:GetResource() + amt, ent.MaxResource))
                self:SetPower(self:GetPower() - amt)
                
                self:SpawnEffect(pos)
                
                return true
            end
        end
        
        -- Ensure the battery isn't spawning in other stuff
        local tr = util.TraceHull({
            start = pos,
            entpos = pos,
            filter = self,
            mins = Vector(-16, -16, -16),
            maxs = Vector(16, 16, 16)
        })
        if tr.Hit then return false end
        
        self:SetPower(self:GetPower() - amt)
        
        local battery = ents.Create(self.BatteryEnt)
        battery:SetPos(pos)
        battery:SetAngles(self:GetAngles() + Angle(0, -90, 90))
        battery:Spawn()
        battery:Activate()
        battery:SetResource(amt)
        battery.NextLoad=CurTime()+1
        
        local effectdata=EffectData()
        effectdata:SetEntity(battery)
        util.Effect("propspawn",effectdata)
        
        self:SpawnEffect(pos)
        
        return true
    end
    
    function ENT:Start()
        if self:CheckSky() > 0 then
            self:EmitSound("buttons/button1.wav", 60, 80)
            self:SetState(STATE_ON)
            self.NextUse = CurTime() + 1
        else
            self:EmitSound("buttons/button2.wav", 60, 100)
        end
    end

    function ENT:ShutOff()
        self:EmitSound("buttons/button18.wav", 60, 80)
        self:SetState(STATE_OFF)
        self.NextUse = CurTime() + 1
    end
    
    function ENT:Think()
        
        if self:GetState() == STATE_ON then
            --stormfox support
            if StormFox ~= nil then 
                if StormFox.GetWeather() ~= "Clear" or StormFox.IsNight() then self:NextThink(CurTime() + 30) return end
            end

            local eff = self:CheckSky()
            if eff <= 0 or self:WaterLevel() >= 2 then
                self:ShutOff()
                return
            elseif self:GetPower() < self.MaxPower then
                local rate = 0.1 * eff
                self:SetPower(math.min(self:GetPower() + rate, self.MaxPower))
                if self:GetPower() >= JMod_EZbatterySize then
                    local canplace = self:ProducePower()
                    if not canplace and (self.NextWhine or 0) < CurTime() then
                        -- Blocked, let's make some noise to complain
                        self:EmitSound("items/suitchargeno1.wav",70,100)
                        self.NextWhine = CurTime() + 10
                    end
                end
            end

            self:NextThink(CurTime() + 1)
            return true
            
        end
        
    end
end