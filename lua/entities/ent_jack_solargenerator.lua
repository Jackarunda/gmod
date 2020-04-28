AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= "EZ Solar Generator"
ENT.Author			= "Jackarunda, TheOnly8Z"
ENT.Category			= "JMod - EZ Misc."
ENT.Information         = ""
ENT.Spawnable			= true

ENT.MaxPower = 400

ENT.BatteryEnt = "ent_jack_gmod_ezbattery"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Power")
end

if SERVER then

    function ENT:SpawnFunction(ply,tr,ClassName)
        local ent=ents.Create(ClassName)
        ent:SetPos(tr.HitPos + tr.HitNormal*16)
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
    end
end