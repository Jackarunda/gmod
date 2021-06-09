-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Workbench"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.JModPreferredCarryAngles=Angle(0,180,0)
ENT.EZconsumes={"power","gas"}
ENT.Base="ent_jack_gmod_ezmachine_base"
---
function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"Electricity")
	self:NetworkVar("Float",1,"Gas")
end
if(SERVER)then
	function ENT:Initialize()
		self.Entity:SetModel("models/mosi/fallout4/furniture/workstations/weaponworkbench01.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:Wake()
			phys:SetMass(500)
			phys:SetBuoyancyRatio(.3)
		end
		---
		if(IsValid(self.Owner))then
			local Tem=self.Owner:Team()
			if(Tem)then
				local Col=team.GetColor(Tem)
				--if(Col)then self:SetColor(Col) end
			end
		end
		---
		self.MaxElectricity=100
		self.MaxGas=100
		self.EZbuildCost=JMOD_CONFIG.Blueprints["EZ Workbench"][2]
		---
		self:SetElectricity(self.MaxElectricity)
		self:SetGas(self.MaxGas)
	end
	function ENT:BuildEffect(pos)
		if(CLIENT)then return end
		local Scale=.5
		local effectdata=EffectData()
		effectdata:SetOrigin(pos+VectorRand())
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(1,2)*Scale) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)*Scale) --length of strands
		effectdata:SetRadius(math.Rand(2,4)*Scale) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		sound.Play("snds_jack_gmod/ez_tools/hit.wav",pos+VectorRand(),60,math.random(80,120))
		sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",pos,60,math.random(80,120))
		local eff=EffectData()
		eff:SetOrigin(pos+VectorRand())
		eff:SetScale(Scale)
		util.Effect("eff_jack_gmod_ezbuildsmoke",eff,true,true)
	end
	function ENT:Use(activator)
		if((self:GetGas()>0)and(self:GetElectricity()>0))then
			net.Start("JMod_EZworkbench")
			net.WriteEntity(self)
			net.WriteTable(JMOD_CONFIG.Recipes)
			net.Send(activator)
			JMod_Hint(activator, "craft")
		else
			JMod_Hint(activator, "refill", self)
		end
	end
	function ENT:Think()
		--
	end
	function ENT:OnRemove()
		--
	end
	function ENT:ConsumeResourcesInRange(requirements)
		local AllDone,Attempts,RequirementsRemaining=false,0,table.FullCopy(requirements)
		while not((AllDone)or(Attempts>1000))do
			local TypesNeeded=table.GetKeys(RequirementsRemaining)
			if((TypesNeeded)and(#TypesNeeded>0))then
				local ResourceTypeToLookFor=TypesNeeded[1]
				local AmountWeNeed=RequirementsRemaining[ResourceTypeToLookFor]
				local Donor=JMod_FindResourceContainer(ResourceTypeToLookFor,1,nil,nil,self) -- every little bit helps
				if(Donor)then
					local AmountWeCanTake=Donor:GetResource()
					if(AmountWeNeed>=AmountWeCanTake)then
						Donor:SetResource(0)
						if Donor:GetClass() == "ent_jack_gmod_ezcrate" then
							Donor:ApplySupplyType("generic")
						else
							Donor:Remove()
						end
						RequirementsRemaining[ResourceTypeToLookFor]=RequirementsRemaining[ResourceTypeToLookFor]-AmountWeCanTake
					else
						Donor:SetResource(AmountWeCanTake-AmountWeNeed)
						RequirementsRemaining[ResourceTypeToLookFor]=RequirementsRemaining[ResourceTypeToLookFor]-AmountWeNeed
					end
					if(RequirementsRemaining[ResourceTypeToLookFor]<=0)then RequirementsRemaining[ResourceTypeToLookFor]=nil end
				end
			else
				AllDone=true
			end
			Attempts=Attempts+1
		end
	end
	function ENT:TryBuild(itemName,ply)
		local Gas,Elec=self:GetGas(),self:GetElectricity()
		if((Gas<=0)or(Elec<=0))then return end
		local ItemInfo=JMOD_CONFIG.Recipes[itemName]
		local ItemClass,BuildReqs=ItemInfo[1],ItemInfo[2]
		
		if(JMod_HaveResourcesToPerformTask(nil,nil,BuildReqs,self))then
		
			local override, msg = hook.Run("JMod_CanWorkbenchBuild", ply, workbench, itemName)
			if override == false then
				ply:PrintMessage(HUD_PRINTCENTER,msg or "cannot build")
				return
			end
		
			JMod_ConsumeResourcesInRange(BuildReqs,nil,nil,self)
			local Pos,Ang,BuildSteps=self:GetPos()+self:GetUp()*55-self:GetForward()*30-self:GetRight()*5,self:GetAngles(),10
			for i=1,BuildSteps do
				timer.Simple(i/100,function()
					if(IsValid(self))then
						if(i<BuildSteps)then
							sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",Pos,60,math.random(80,120))
						else
							local StringParts=string.Explode(" ",ItemClass)
							if((StringParts[1])and(StringParts[1]=="FUNC"))then
								local FuncName=StringParts[2]
								if((JMOD_LUA_CONFIG)and(JMOD_LUA_CONFIG.BuildFuncs)and(JMOD_LUA_CONFIG.BuildFuncs[FuncName]))then
									local Ent=JMOD_LUA_CONFIG.BuildFuncs[FuncName](ply,Pos,Ang)
									if(Ent)then
										if(Ent:GetPhysicsObject():GetMass()<=15)then ply:PickupObject(Ent) end
									end
								else
									print("JMOD WORKBENCH ERROR: garrysmod/lua/autorun/jmod_lua_config.lua is missing, corrupt, or doesn't have an entry for that build function")
								end
							else
								local Ent=ents.Create(ItemClass)
								Ent:SetPos(Pos)
								Ent:SetAngles(Ang)
								JMod_Owner(Ent,ply)
								Ent:Spawn()
								Ent:Activate()
								if(Ent:GetPhysicsObject():GetMass()<=15)then ply:PickupObject(Ent) end
							end
							self:SetGas(math.Clamp(Gas-5*math.Rand(0,1)^2,0,self.MaxGas))
							self:SetElectricity(math.Clamp(Elec-5*math.Rand(0,1)^2,0,self.MaxElectricity))
							self:BuildEffect(Pos)
						end
					end
				end)
			end
		else
			ply:PrintMessage(HUD_PRINTCENTER,"missing supplies for build")
		end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--self.Camera=JMod_MakeModel(self,"models/props_combine/combinecamera001.mdl")
		self.Glassware1=JMod_MakeModel(self,"models/props_junk/glassjug01.mdl","models/props_combine/health_charger_glass")
		self.Glassware2=JMod_MakeModel(self,"models/props_junk/glassjug01.mdl","models/props_combine/health_charger_glass")
		self.Screen=JMod_MakeModel(self,"models/props_lab/monitor01b.mdl")
		self.Panel=JMod_MakeModel(self,"models/props_lab/reciever01b.mdl")
		self.MaxElectricity=100
		self.MaxGas=100
	end
	local function ColorToVector(col)
		return Vector(col.r/255,col.g/255,col.b/255)
	end
	local DarkSprite=Material("white_square")
	function ENT:DrawTranslucent()
		local SelfPos,SelfAng,FT=self:GetPos(),self:GetAngles(),FrameTime()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		---
		local BasePos=SelfPos+Up*60
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		---
		self:DrawModel()
		---
		if(DetailDraw)then
			local GlasswareAng=SelfAng:GetCopy()
			JMod_RenderModel(self.Glassware1,BasePos-Up*12.5-Forward*47,GlasswareAng)
			JMod_RenderModel(self.Glassware2,BasePos-Up*12.5-Forward*47-Right*9,GlasswareAng)
			---
			local ScreenAng=SelfAng:GetCopy()
			JMod_RenderModel(self.Screen,BasePos-Up*5-Forward*60-Right*25,ScreenAng)
			---
			local PanelAng=SelfAng:GetCopy()
			PanelAng:RotateAroundAxis(Forward,-90)
			JMod_RenderModel(self.Panel,BasePos-Up*34-Forward*22+Right*28,PanelAng)
			---
			if(self:GetElectricity()>0)then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Forward,90)
				DisplayAng:RotateAroundAxis(Up,90)
				local Opacity=math.random(50,200)
				cam.Start3D2D(BasePos-Right*24-Forward*53.5-Up,DisplayAng,.04)
				draw.SimpleTextOutlined("Jackarunda","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				draw.SimpleTextOutlined("Industries","JMod-Display",0,30,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac=self:GetElectricity()/self.MaxElectricity
				local R,G,B=JMod_GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined("POWER "..math.Round(ElecFrac*100).."%","JMod-Display",0,60,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local GasFrac=self:GetGas()/self.MaxGas
				local R,G,B=JMod_GoodBadColor(GasFrac)
				draw.SimpleTextOutlined("GAS "..math.Round(GasFrac*100).."%","JMod-Display",0,90,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
		--[[ -- todo: use this in the prop conversion machines
		local Col=Color(0,0,0,50)
		render.SetMaterial(DarkSprite)
		for i=1,30 do
			render.DrawQuadEasy(BasePos+Up*(i*1.3-5),Up,38,38,Col)
		end
		--]]
		--[[
		local CamAng=SelfAng:GetCopy()
		--CamAng:RotateAroundAxis(Up,-90)
		--CamAng:RotateAroundAxis(Right,180)
		--JMod_RenderModel(self.Camera,BasePos+Up*10+Forward*25,CamAng,nil,GradeColors[Grade],GradeMats[Grade])
		
		local Matricks=Matrix()
		Matricks:Scale(Vector(.4,1.45,.5))
		self.BottomCanopy:EnableMatrix("RenderMultiply",Matricks)
		local BottomCanopyAng=SelfAng:GetCopy()
		BottomCanopyAng:RotateAroundAxis(Right,180)
		JMod_RenderModel(self.BottomCanopy,BasePos-Up*17+Right*2,BottomCanopyAng)
		--]]
	end
	language.Add("ent_jack_gmod_ezworkbench","EZ Workbench")
end