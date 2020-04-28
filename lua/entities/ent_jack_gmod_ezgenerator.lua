AddCSLuaFile()

ENT.Type 			= "anim"
ENT.PrintName		= "EZ Generator"
ENT.Author			= "Jackarunda, TheOnly8Z"
ENT.Category			= "JMod - EZ Misc."
ENT.Information         = ""
ENT.Spawnable			= true

-- TODO Make these configurable (and maybe upgradable?)
ENT.MaxFuel = 1000
ENT.MaxPower = 1000

ENT.EZconsumes = {"fuel"}
ENT.BatteryEnt = "ent_jack_gmod_ezbattery"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Fuel")
	self:NetworkVar("Int", 1, "Power")
	self:NetworkVar("Int", 2, "State")
end

local STATE_OFF, STATE_BROKEN, STATE_STARTING, STATE_ON = 0, -1, 1, 2

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
        self.Entity:SetModel("models/props_outland/generator_static01a.mdl")
        self.Entity:SetMaterial("models/props_silo/generator_jtatic01.mdl")
        self.Entity:PhysicsInit(SOLID_VPHYSICS)
        self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
        self.Entity:SetSolid(SOLID_VPHYSICS)
        self.Entity:DrawShadow(true)
        local phys = self.Entity:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(750)
        end
        self.Entity:SetUseType(SIMPLE_USE)

        self.NextLoad = 0
        self.NextUse = 0
        self.NextSound = 0
        self.NextWork = 0
        
        self:SetState(STATE_OFF)
        self:SetFuel(0)
        self:SetPower(0)
        --self.Entity:SetColor(Color(150,150,150))
    end

    function ENT:PhysicsCollide(data,physobj)
        if((data.Speed>80)and(data.DeltaTime>0.2))then
            self.Entity:EmitSound("SolidMetal.ImpactHard")
        end
        -- TODO Accept fuel
    end

    function ENT:OnTakeDamage(dmginfo)
        self.Entity:TakePhysicsDamage(dmginfo)
    end

    function ENT:Use(activator,caller)

        if(activator:IsPlayer())then
        
            local alt = activator:KeyDown(IN_WALK)
            
            if (self.NextUse>CurTime()) then return end
            self.NextUse = CurTime() + 1
            
            if (self:GetState() == STATE_OFF and alt) then
                self:Start()
            elseif (self:GetState() == STATE_ON and alt) then
                self:ShutOff()
            elseif (!alt) then
                self:ProducePower(activator)
            end
            -- JMod_Hint(activator, "generator")
        end
        
    end

    function ENT:ProducePower(ply)

        local amt = math.min(self:GetPower(), JMod_EZbatterySize)
        if amt <= 0 then return end
        
        local battery = ents.Create(self.BatteryEnt)
        battery:SetPos(self:GetPos()+self:GetUp()*100)
        battery:SetAngles(self:GetAngles())
        battery:Spawn()
        battery:Activate()
        battery:SetResource(amt)
        battery.NextLoad=CurTime()+2
        
        ply:PickupObject(battery)
        self:SetPower(self:GetPower() - amt)
        self:EmitSound("Ammo_Crate.Close")
        
    end

    function ENT:TryLoadResource(typ,amt)

        if self.NextLoad > CurTime() then return 0 end
        if amt <= 0 or self:GetFuel() >= self.MaxPower then return 0 end
        
        local takeAmt = math.min(amt, self.MaxFuel - self:GetFuel())
        self:SetFuel(self:GetFuel() + takeAmt)
        self.NextLoad = CurTime() + 1
        return takeAmt

    end

    function ENT:Start()
        if self:GetFuel() > 0 then
            self:EmitSound("snd_jack_genstart.mp3")
            self:SetState(STATE_STARTING)
            self.NextSound=CurTime()+8
            self.NextUse=CurTime()+10
            self.NextWork=CurTime()+10
        else
            self:EmitSound("buttons/button8.wav")
        end
    end

    function ENT:ShutOff()
        self:EmitSound("snd_jack_genstop.mp3")
        self:SetState(STATE_OFF)
        self.NextUse=CurTime()+5
        self.NextWork=CurTime()+5
    end

    function ENT:Think()
        
        if self:GetState() == STATE_ON then

            if(self:GetFuel() <= 0)then
                self:ShutOff()
                return
            else
                local drain = math.min(self:GetFuel(), 1) -- TODO make this configurable?
                self:SetFuel(self:GetFuel() - drain)
                self:SetPower(math.min(self:GetPower() + drain, self.MaxPower))
            end
            
            if(self.NextSound <= CurTime() )then
                self.NextSound = CurTime() + 3.5
                self:EmitSound("snd_jack_genrun.mp3")
            end
            
            if(self:WaterLevel()>0)then self:ShutOff() end
            
            self:GetPhysicsObject():ApplyForceCenter(VectorRand()*1500)
            
            --local Poof=EffectData()
            --Poof:SetOrigin(self:GetPos()+self:GetUp()*50+self:GetForward()*10-self:GetRight()*25)
            --Poof:SetNormal(self:GetUp())
            --Poof:SetScale(1)
            --util.Effect("eff_jack_genrun",Poof,true,true)
            
            self:NextThink(CurTime()+0.5)
            return true
            
        elseif self:GetState() == STATE_STARTING then
            
            if self.NextWork < CurTime() then self:SetState(STATE_ON) end
            self:NextThink(CurTime()+0.5)
            return true
            
        end
        
    end
    
elseif CLIENT then

    function ENT:Initialize()
        self.RotateAngle=0
        self.RotSpeed=0
        self.Blowing=false
        self.Engine1=ClientsideModel("models/props_silo/fanoff.mdl")
        self.Engine1:SetPos(self:GetPos())
        self.Engine1:SetParent(self)
        self.Engine1:SetNoDraw(true)
        self.Engine1:SetModelScale(.75,0)
        self.Engine2=ClientsideModel("models/props_silo/fanoff.mdl")
        self.Engine2:SetPos(self:GetPos())
        self.Engine2:SetParent(self)
        self.Engine2:SetNoDraw(true)
        self.Engine2:SetModelScale(.75,0)
        self.Engine3=ClientsideModel("models/props_silo/fanoff.mdl")
        self.Engine3:SetPos(self:GetPos())
        self.Engine3:SetParent(self)
        self.Engine3:SetNoDraw(true)
        self.Engine3:SetModelScale(.75,0)
        self.Engine4=ClientsideModel("models/props_silo/fanoff.mdl")
        self.Engine4:SetPos(self:GetPos())
        self.Engine4:SetParent(self)
        self.Engine4:SetNoDraw(true)
        self.Engine4:SetModelScale(.75,0)
        self.Turbine=ClientsideModel("models/props_silo/fanhousing.mdl")
        self.Turbine:SetPos(self:GetPos())
        self.Turbine:SetParent(self)
        self.Turbine:SetNoDraw(true)
        self.Turbine:SetModelScale(.75,0)
        self.Turbine:SetMaterial("models/props_silo/jan")
    end

    function ENT:Draw()
        local Ang=self:GetAngles()
        local Pos=self:GetPos()
        local Up=self:GetUp()
        local Right=self:GetRight()
        local Forward=self:GetForward()
        local Ang2=self:GetAngles()
        Ang:RotateAroundAxis(Ang:Forward(),self.RotateAngle)
        self.RotateAngle=self.RotateAngle+self.RotSpeed
        if(self.RotateAngle>360)then self.RotateAngle=0 end
        if(self:GetState() != 0)then
            self.RotSpeed=self.RotSpeed+.035
        else
            self.RotSpeed=self.RotSpeed-.035
        end
        if(self.RotSpeed>42)then self.RotSpeed=42 end
        if(self.RotSpeed<0)then self.RotSpeed=0 end
        if(self.RotSpeed>30)then
            if not(self.Blowing)then
                self.Blowing=true
                self.Engine1:SetModel("models/props_silo/fan.mdl")
                self.Engine2:SetModel("models/props_silo/fan.mdl")
                self.Engine3:SetModel("models/props_silo/fan.mdl")
                self.Engine4:SetModel("models/props_silo/fan.mdl")
            end
        else
            if(self.Blowing)then
                self.Blowing=false
                self.Engine1:SetModel("models/props_silo/fanoff.mdl")
                self.Engine2:SetModel("models/props_silo/fanoff.mdl")
                self.Engine3:SetModel("models/props_silo/fanoff.mdl")
                self.Engine4:SetModel("models/props_silo/fanoff.mdl")
            end
        end
        self.Engine1:SetRenderOrigin(Pos+Forward*70+Up*55)
        Ang:RotateAroundAxis(Ang:Right(),90)
        self.Engine1:SetRenderAngles(Ang)
        self.Engine1:DrawModel()
        self.Engine2:SetRenderOrigin(Pos+Forward*70+Up*55)
        Ang:RotateAroundAxis(Ang:Up(),15)
        self.Engine2:SetRenderAngles(Ang)
        self.Engine3:SetRenderOrigin(Pos+Forward*70+Up*55)
        Ang:RotateAroundAxis(Ang:Up(),15)
        self.Engine3:SetRenderAngles(Ang)
        self.Engine4:SetRenderOrigin(Pos+Forward*70+Up*55)
        Ang:RotateAroundAxis(Ang:Up(),15)
        self.Engine4:SetRenderAngles(Ang)
        local R,G,B=render.GetColorModulation()
        render.SetColorModulation(.2,.2,.2)
        self.Engine1:DrawModel()
        self.Engine2:DrawModel()
        self.Engine3:DrawModel()
        self.Engine4:DrawModel()
        render.SetColorModulation(R,G,B)
        self.Turbine:SetRenderOrigin(Pos+Forward*65+Up*55)
        Ang2:RotateAroundAxis(Ang2:Right(),-90)
        self.Turbine:SetRenderAngles(Ang2)
        self.Turbine:DrawModel()
        self.Entity:DrawModel()

        local SelfPos,SelfAng = self:GetPos(), self:GetAngles()
        local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
        local distsqr = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
        
        if distsqr < 20000 and self:GetState() ~= STATE_BROKEN then
            local DisplayAng=SelfAng:GetCopy()
            DisplayAng:RotateAroundAxis(DisplayAng:Forward(),90)
            --DisplayAng:RotateAroundAxis(DisplayAng:Up(),-90)
            local Opacity=math.random(50,150)
            cam.Start3D2D(SelfPos+Up*45-Right*(-20)-Forward*(-20),DisplayAng,.1)
            
                local stateStr, R, G, B = "OFF", 255, 0, 0
                if self:GetState() == STATE_ON then 
                    stateStr, R, G, B = "ON", 0, 255, 0
                elseif self:GetState() == STATE_STARTING then 
                    stateStr, R, G, B = "STARTING", 150, 150, 0 
                end
                draw.SimpleTextOutlined("STATUS","JMod-Display",100,-150,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                draw.SimpleTextOutlined(stateStr,"JMod-Display",100,-115,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                
                draw.SimpleTextOutlined("POWER","JMod-Display",200,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                local R,G,B=JMod_GoodBadColor(self:GetPower()/self.MaxPower)
                draw.SimpleTextOutlined(tostring(self:GetPower()),"JMod-Display",200,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                
                local R,G,B=JMod_GoodBadColor(self:GetFuel()/self.MaxFuel)
                draw.SimpleTextOutlined("FUEL","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
                draw.SimpleTextOutlined(tostring(self:GetFuel()),"JMod-Display",0,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
            cam.End3D2D()
        end
    end

    language.Add("ent_jack_gmod_ezgenerator","EZ Generator")
    
end