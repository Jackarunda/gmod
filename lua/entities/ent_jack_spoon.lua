AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Spoon"
ENT.Author			= "Jackarunda"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Model = "models/shells/shell_gndspoon.mdl"
ENT.ModelScale = 1.5
ENT.Sound = "snd_jack_spoonbounce.wav"

if SERVER then
    function ENT:Initialize()

        self:SetModel(self.Model)
        self:SetModelScale(self.ModelScale,0)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        
        if SERVER then self:SetUseType(SIMPLE_USE) end
        
        local phys = self:GetPhysicsObject()
        if(phys:IsValid())then
            phys:Wake()
            phys:SetMass(1)
        end
        
        SafeRemoveEntityDelayed(self.Entity,20)
    end


    function ENT:PhysicsCollide(data, physobj)
        
        -- play sound
        if(data.Speed>2 and data.DeltaTime>0.1)then
            local loudness=data.Speed*0.4
            if(loudness>70)then loudness=70 end
            if(loudness<10)then loudness=10 end
            self:EmitSound(self.Sound,loudness,100+math.random(-20,20))
        end
        
        -- bounce
        local impulse = -data.Speed*data.HitNormal*0.3+(data.OurOldVelocity*-0.3)
        self:GetPhysicsObject():ApplyForceCenter(impulse)
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
    end
end
if CLIENT then
    language.Add("ent_jack_spoon", "Spoon")
end