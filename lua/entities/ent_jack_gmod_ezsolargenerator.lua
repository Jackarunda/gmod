AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Solar Generator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
--
ENT.MaxDurability = 50
--ENT.Durability = 50
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.MaxPower = 100
ENT.SkyModifiers = {"clouds_", "_clouds", "cloudy_", "_cloudy", "stormy_", "storm_", "_storm"}

function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Float",0,"Progress")
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
        self:SetModel("models/jmodels/props/Scaffolding_smol.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)	
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(200)
        end
        self:SetUseType(SIMPLE_USE)
        
        self:SetProgress(0)
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
		if(State==STATE_BROKEN)then
			JMod.Hint(activator,"destroyed",self)
			return
		elseif(State==STATE_OFF)then
			self:TurnOn()
		elseif(State==STATE_ON)then
            self:ProducePower()
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
        local amt = math.min(math.floor(self:GetProgress()), self.MaxPower)

        if amt <= 0 then return end
        
        local pos = SelfPos + Forward*15 - Up*25 - Right*2
        for _, ent in pairs(ents.FindInSphere(pos, 100)) do
            --print(ent, ent.GetResourceType and ent:GetResourceType())
            if ((ent:GetClass() == "ent_jack_gmod_ezcrate") and (ent:GetResourceType() == "generic" 
            or ent:GetResourceType() == "power") and (ent:GetResource() + amt <= ent.MaxResource)) then
                    
                if ent:GetResourceType() == "generic" then
                    ent:ApplySupplyType("power")
                end
                    
                ent:SetResource(math.min(ent:GetResource() + amt, ent.MaxResource))
                self:SetProgress(self:GetProgress() - amt)
                self:SpawnEffect(pos)
                return
            end
        end
        JMod.MachineSpawnResource(self, "power", amt, self:WorldToLocal(pos), Angle(-90, 0, 0), Up*-300)
        self:SetProgress(self:GetProgress() - amt)
        self:SpawnEffect(pos)
    end

    function ENT:CheckSky()
        local HitAmount = 0
        for i = 1, 10 do
            for j = 1, 10 do
                local StartPos = self:LocalToWorld(Vector(-5 + j*1, -100 + i*25, 10 + j*7.5))
                local Dir = self:LocalToWorldAngles(Angle(260 - j*8, -10 + i*2, 0)):Forward()
                local HitSky = util.TraceLine({start = StartPos, endpos = StartPos + Dir * 9e9, filter = {self}, mask = MASK_SOLID}).HitSky
                if (HitSky) then HitAmount = HitAmount + 1 end
                --JMod.Sploom(game.GetWorld(), StartPos + Dir * 1000, 0.5)
            end
        end
        --print(HitAmount)
        return HitAmount*0.01
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
        self:SetProgress(0)
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
            local grade = self:GetGrade() + 1
            if visibility <= 0 or self:WaterLevel() >= 2 then
                self:TurnOff()
                return
            elseif self:GetProgress() < self.MaxPower then
                local rate = math.Round(((3.34 * grade) * visibility), 2)
                self:SetProgress(self:GetProgress() + rate)
                if self:GetProgress() >= 100 then
                    self:ProducePower()
                end
            end
            --print("Progress: "..self:GetProgress())
            self:NextThink(CurTime() + 10)
            return true
            
        end
        
    end
elseif(CLIENT)then
    function ENT:Initialize()
		self.SolarCellModel = JMod.MakeModel(self,"models/hunter/plates/plate3x5.mdl","models/mat_jack_gmod_solarcells",.5)
        self.PanelBackModel = JMod.MakeModel(self,"models/hunter/plates/plate3x5.mdl","models/props_pipes/pipeset_metal02",.5)
        self.ChargerModel = JMod.MakeModel(self,"models/props_lab/powerbox01a.mdl", nil,.5)
	end
    function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		---
		local BasePos=SelfPos
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<120000 -- cutoff point is 400 units when the fov is 90 degrees
        local PanelDraw = true
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false PanelDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false PanelDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		--local Matricks=Matrix()
		--Matricks:Scale(Vector(1,1,.5))
		--self:EnableMatrix("RenderMultiply",Matricks)
		self:DrawModel()
        --self:DrawShadow(true)
		---
        local PanelAng=SelfAng:GetCopy()
        PanelAng:RotateAroundAxis(Right, 60)
        if(PanelDraw)then
            JMod.RenderModel(self.SolarCellModel,BasePos-Forward+Right*.5,PanelAng,nil,Vector(1,1,1))
        end
        if(DetailDraw)then
            local BoxAng=SelfAng:GetCopy()
            JMod.RenderModel(self.PanelBackModel,BasePos-Forward*0.6+Right*.5,PanelAng,Vector(1.01,1.01,1))
            BoxAng:RotateAroundAxis(Right, 90)
            BoxAng:RotateAroundAxis(Forward, 180)
            JMod.RenderModel(self.ChargerModel,BasePos-Up*25+Forward*6-Right*6,BoxAng,Vector(1.8,1.8,1.2),Vector(1,1,1))
        end
        
    end
end