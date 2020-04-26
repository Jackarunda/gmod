AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= "Aid Package"
ENT.Author			= "Jackarunda"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

if SERVER then
    function ENT:Initialize()
        self.Entity:SetModel("models/props_junk/wood_crate001a.mdl")
        self.Entity:SetMaterial("models/mat_jack_aidbox")
        self.Entity:PhysicsInit(SOLID_VPHYSICS)
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        self.Entity:DrawShadow(true)
        
        local Phys=self.Entity:GetPhysicsObject()
        if(IsValid(Phys))then
            Phys:Wake()
            Phys:SetMass(200)
            Phys:EnableDrag(false)
            Phys:SetMaterial("metal")
        end
        timer.Simple(.1,function()
            if(IsValid(self))then
                self:GetPhysicsObject():SetVelocity(self.InitialVel+VectorRand()*math.Rand(0,200))
                self:GetPhysicsObject():AddAngleVelocity(VectorRand()*math.Rand(0,3000))
            end
        end)
        self.Opacity= self.NoFadeIn and 1 or 0
        self:SetDTFloat(0,self.Opacity)
        self.Parachuted=self:GetDTBool(0)
        if(self.Parachuted)then
            self:GetPhysicsObject():SetDragCoefficient(40*JMOD_CONFIG.RadioSpecs.ParachuteDragMult)
            self:GetPhysicsObject():SetAngleDragCoefficient(40)
        end
    end

    function ENT:PhysicsCollide(data,physobj)
        if((data.Speed>2000)and(data.DeltaTime>.2))then
            self.Entity:EmitSound("Boulder.ImpactHard")
            self.Entity:EmitSound("Canister.ImpactHard")
            self.Entity:EmitSound("Boulder.ImpactHard")
            self.Entity:EmitSound("Canister.ImpactHard")
            self.Entity:EmitSound("Boulder.ImpactHard")
            util.ScreenShake(data.HitPos,99999,99999,.5,500)
            local Poof=EffectData()
            Poof:SetOrigin(data.HitPos)
            Poof:SetScale(5)
            Poof:SetNormal(data.HitNormal)
            util.Effect("eff_jack_aidimpact",Poof,true,true)
            local Tr=util.QuickTrace(data.HitPos-data.OurOldVelocity,data.OurOldVelocity*50,{self})
            if(Tr.Hit)then
                util.Decal("Rollermine.Crater",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
            end
        elseif((data.Speed>80)and(data.DeltaTime>.2))then
            self.Entity:EmitSound("Canister.ImpactHard")
        end
        if(data.DeltaTime>.1)then
            local Phys=self:GetPhysicsObject()
            Phys:SetVelocity(Phys:GetVelocity()/1.5)
            Phys:AddAngleVelocity(-Phys:GetAngleVelocity()/1.30)
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self.Entity:TakePhysicsDamage(dmginfo)
    end

    function ENT:Use(activator,caller)
        local Pos=self:LocalToWorld(self:OBBCenter())
        local Up=self:GetUp()
        local Right=self:GetRight()
        local Forward=self:GetForward()
        local Ang=self:GetAngles()
        local AngLat=self:GetAngles()
        AngLat:RotateAroundAxis(AngLat:Forward(),90)
        local AngLin=self:GetAngles()
        AngLin:RotateAroundAxis(AngLin:Right(),90)
        self:MakeSide(Pos+Up*15,Ang,Up)
        self:MakeSide(Pos-Up*15,Ang,-Up)
        self:MakeSide(Pos+Right*15,AngLat,Right)
        self:MakeSide(Pos-Right*15,AngLat,-Right)
        self:MakeSide(Pos+Forward*15,AngLin,Forward)
        self:MakeSide(Pos-Forward*15,AngLin,-Forward)
        local Poof=EffectData()
        Poof:SetOrigin(Pos)
        Poof:SetScale(2)
        util.Effect("eff_jack_aidopen",Poof,true,true)
        self:EmitSound("snd_jack_aidboxopen.wav",75,100)
        self:EmitSound("snd_jack_aidboxopen.wav",75,100)
        self:EmitSound("snd_jack_aidboxopen.wav",75,100)
        self:EmitSound("snd_jack_aidboxopen.wav",75,100)
        for key,item in pairs(self.Contents)do
            local ClassName,Num=item,1
            if(type(item)~="string")then ClassName=item[1];Num=item[2] end
            local StringParts=string.Explode(" ",ClassName)
            for i=1,Num do
                local Ent=nil
                if((StringParts[1])and(StringParts[1]=="FUNC"))then
                    local FuncName=StringParts[2]
                    if((JMOD_LUA_CONFIG)and(JMOD_LUA_CONFIG.BuildFuncs)and(JMOD_LUA_CONFIG.BuildFuncs[FuncName]))then
                        Ent=JMOD_LUA_CONFIG.BuildFuncs[FuncName](activator,Pos+VectorRand()*math.Rand(0,30),VectorRand():Angle())
                    else
                        activator:PrintMessage(HUD_PRINTTALK,"JMOD RADIO BOX ERROR: garrysmod/lua/autorun/jmod_lua_config.lua is missing, corrupt, or doesn't have an entry for that build function")
                    end
                else
                    local Yay=ents.Create(ClassName)
                    Yay:SetPos(Pos+VectorRand()*math.Rand(0,30))
                    Yay:SetAngles(VectorRand():Angle())
                    Yay:Spawn()
                    Yay:Activate()
                    Ent=Yay
                end
                if(Ent)then
                    JMod_Owner(Ent,activator)
                end
            end
        end
        --JackaGenericUseEffect(activator)
        if(activator:IsPlayer())then
            local Wep=activator:GetActiveWeapon()
            if(IsValid(Wep))then Wep:SendWeaponAnim(ACT_VM_DRAW) end
            activator:ViewPunch(Angle(1,0,0))
            activator:SetAnimation(PLAYER_ATTACK1)
        end
        timer.Simple(2,function()
            sound.Play("snd_jack_itemsget.wav",Pos,75,100)
        end)
        self:Remove()
    end

    function ENT:MakeSide(pos,ang,dir)
        local Side=ents.Create("prop_physics")
        Side:SetModel("models/hunter/plates/plate1x1.mdl")
        Side:SetMaterial("models/mat_jack_aidboxside")
        Side:SetColor(Color(200,200,200,255))
        Side:SetPos(pos)
        Side:SetAngles(ang)
        Side:Spawn()
        Side:Activate()
        Side:GetPhysicsObject():SetMaterial("gmod_silent")
        Side:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity())
        Side:GetPhysicsObject():ApplyForceCenter(dir*2000)
        Side:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        SafeRemoveEntityDelayed(Side,math.random(8,16))
    end

    function ENT:Think()
        if not(self.DoneDropping)then
            if(self:GetVelocity():Length()<200)then
                self.DoneDropping=true
                self:GetPhysicsObject():SetDragCoefficient(1)
                self:GetPhysicsObject():SetAngleDragCoefficient(1)
                self:SetDTBool(0,false)
                self:NextThink(CurTime()+.015)
                return true
            end
        end
        if not(self.NoFadeIn)then
            self.Opacity=(self.Opacity or 0)+.01
            if(self.Opacity>1)then self.Opacity=1 end
            self:SetDTFloat(0,self.Opacity)
            self:NextThink(CurTime()+.01)
            return true
        end
    end
end
if CLIENT then
    
    function ENT:Initialize()
        if(self:GetDTBool(0))then
            self.Parachute=ClientsideModel("models/jessev92/rnl/items/parachute_deployed.mdl")
            self.Parachute:SetNoDraw(true)
            self.Parachute:SetParent(self)
        end
        self.InitTime=CurTime()
    end
    
    function ENT:Draw()
        if(CurTime()-self.InitTime<.15)then return end
        render.SetBlend(self:GetDTFloat(0))
        if(self:GetDTBool(0))then
            local Vel=self:GetVelocity()
            if(Vel:Length()>0)then
                local Pos=self:GetPos()
                local Dir=Vel:GetNormalized()
                Dir=Dir+Vector(.01,0,0) -- stop the turn spasming
                local Ang=Dir:Angle()
                Ang:RotateAroundAxis(Ang:Right(),90)
                self.Parachute:SetRenderOrigin(Pos+Dir*50)
                self.Parachute:SetRenderAngles(Ang)
                self.Parachute:DrawModel()
            end
        end
        self.Entity:DrawModel()
        render.SetBlend(1)
    end

    language.Add("ent_jack_aidbox","Aid Package")
end