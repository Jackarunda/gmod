AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Solar Generator"
ENT.Author = "Jackarunda, TheOnly8Z, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
--
ENT.Durability = 30
ENT.MaxPower = 100
ENT.SkyModifiers = {"clouds_", "_clouds", "cloudy_", "_cloudy", "night_", "_night", "stormy_", "storm_", "_storm"}

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Float",0,"Power")
end

local STATE_BROKEN, STATE_OFF,  STATE_ON = -1, 0, 1

if(SERVER)then
    function ENT:SpawnFunction(ply,tr,ClassName)
        local ent=ents.Create(ClassName)
        ent:SetPos(tr.HitPos + tr.HitNormal*25)
        ent:SetAngles(Angle(90, 90, 0))
        JMod.Owner(ent,ply)
        ent:Spawn()
        ent:Activate()
        local effectdata=EffectData()
        effectdata:SetEntity(ent)
        util.Effect("propspawn",effectdata)
        return ent
    end

    function ENT:Initialize()
        self:SetModel("models/props_rooftop/scaffolding01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)	
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(500)
            self:SetModelScale(0.5, 0)
        end
        self:SetUseType(SIMPLE_USE)
        
        self:SetPower(0)
        self:SetState(STATE_OFF)
        self.NextUse = 0
        local mapName = game.GetMap()
        if(string.find(mapName, "_night") or string.find(mapName, "night_"))then self.NightMap=true end
    end
    

   function ENT:Use(activator)
		local State=self:GetState()
		local OldOwner=self.Owner
		JMod.Owner(self,activator)
		JMod.Colorify(self)
		if(IsValid(self.Owner))then
			if(OldOwner~=self.Owner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end
        local canPlace = self:ProducePower()
        if(canPlace)then return end
		if(State==STATE_BROKEN)then
			JMod.Hint(activator,"destroyed",self)
			return
		elseif(State==STATE_OFF)then
			self:TurnOn()
		elseif(State==STATE_ON)then
			self:TurnOff()
		end
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
        local SelfPos,Up,Forward,Right = self:GetPos(),self:GetUp(),self:GetForward(),self:GetRight()
        local amt = math.min(math.floor(self:GetPower()), 100)

        if amt <= 99 then return false end
        
        local pos = SelfPos - Forward*15 - Up*50
        for _, ent in pairs(ents.FindInSphere(pos, 100)) do
            --print(ent, ent.GetResourceType and ent:GetResourceType())
            if ((ent:GetClass() == "ent_jack_gmod_ezcrate") and (ent:GetResourceType() == "generic" 
            or ent:GetResourceType() == "power") and (ent:GetResource() + amt <= ent.MaxResource)) then
                    
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
        
        local battery = ents.Create("ent_jack_gmod_ezbattery")
        battery:SetPos(pos)
        battery:SetAngles(self:GetAngles() + Angle(90, -90, 0))
        battery:Spawn()
        battery:Activate()
        battery:SetResource(amt)
        
        local effectdata=EffectData()
        effectdata:SetEntity(battery)
        util.Effect("propspawn",effectdata)
        
        self:SpawnEffect(pos)
        
        return true
    end

    function ENT:CheckSky()
        local HitAmount = 0
        for i = 1, 10 do
            for j = 1, 10 do
                local StartPos = self:LocalToWorld(Vector(-5 + j*1, -100 + i*25, 10 + j*7.5))
                local Dir = self:LocalToWorldAngles(Angle(260 - j*8, 0, 0)):Forward()
                local HitSky = util.TraceLine({start = StartPos, endpos = StartPos + Dir * 9e9, filter = {self}, mask = MASK_SOLID}).HitSky
                if (HitSky) then HitAmount = HitAmount + 1 end
                --if(i > 0)then
                    --JMod.Sploom(game.GetWorld(), StartPos + Dir * 1000, 0.5)
                --end
            end
        end
        print(HitAmount)
        return HitAmount
    end
    
    function ENT:TurnOn()
        if (self:CheckSky() > 0) then
            self:EmitSound("buttons/button1.wav", 60, 80)
            self:SetState(STATE_ON)
            self.NextUse = CurTime() + 1
        else
            self:EmitSound("buttons/button2.wav", 60, 100)
        end
    end

    function ENT:TurnOff()
        self:EmitSound("buttons/button18.wav", 60, 80)
        self:SetState(STATE_OFF)
        self:SetPower(0)
        self.NextUse = CurTime() + 1
    end
    
    function ENT:Think()
        local State = self:GetState()
        if(State == STATE_ON)then
            --stormfox support
            if(StormFox)then 
                if StormFox.GetWeather() ~= "Clear" or StormFox.IsNight() then self:NextThink(CurTime() + 30) return end
            end
            if(self.NightMap)then return end

            local visibility = self:CheckSky()
            if visibility <= 0 or self:WaterLevel() >= 2 then
                self:TurnOff()
                return
            elseif self:GetPower() < self.MaxPower then
                local rate = 0.1 * visibility
                self:SetPower(math.min(self:GetPower() + rate, self.MaxPower))
                if self:GetPower() >= 100 then
                    local canplace = self:ProducePower()
                    if (not(canplace) and (self.NextWhine or 0 < CurTime())) then
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
elseif(CLIENT)then
    function ENT:Initialize()
		self.SolarCellModel = JMod.MakeModel(self,"models/hunter/plates/plate3x5.mdl","models/props_combine/combine_monitorbay_disp",.5)
	end
    function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		---
		local BasePos=SelfPos
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
        local PanelDraw = true
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false PanelDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false PanelDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		--local Matricks=Matrix()
		--Matricks:Scale(Vector(1,1,.5))
		--self:EnableMatrix("RenderMultiply",Matricks)
		self:DrawModel()
		---
        if(PanelDraw)then
            local PanelAng=SelfAng:GetCopy()
            PanelAng:RotateAroundAxis(Right, 60)
            JMod.RenderModel(self.SolarCellModel,BasePos-Forward,PanelAng,nil,Vector(1,1,1))
        end
    end
end