-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Workbench"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Machines"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
ENT.Model="models/mosi/fallout4/furniture/workstations/weaponworkbench01.mdl"
ENT.Mass=500
ENT.JModPreferredCarryAngles=Angle(0,180,0)
ENT.EZconsumes={
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.POWER,
	JMod.EZ_RESOURCE_TYPES.GAS
}
ENT.Base="ent_jack_gmod_ezmachine_base"
---
ENT.StaticPerfSpecs={
	MaxDurability=100,
	Armor=.8,
	MaxGas=100,
	MaxElectricity=100
}
local STATE_BROKEN,STATE_FINE=-1,0
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float",1,"Gas")
end
if(SERVER)then
	function ENT:CustomInit()
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:SetBuoyancyRatio(.3)
		end
		---
		--self:SetGas(self.MaxGas)
		if not(self.Owner)then self:SetColor(Color(153, 47, 45, 255)) end
		self:UpdateConfig()
	end
	function ENT:UpdateConfig()
		self.Craftables={}
		for name,info in pairs(JMod.Config.Craftables)do
			if(info.craftingType=="workbench")then
				-- we store this here for client transmission later
				-- because we can't rely on the client having the config
				local infoCopy=table.FullCopy(info)
				infoCopy.name=name
				self.Craftables[name]=info
			end
		end
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
		-- todo: useEffects
	end
	function ENT:Use(activator)
		if(self:GetState()==STATE_FINE)then
			if(self:GetElectricity()>0 and self:GetGas()>0)then
				net.Start("JMod_EZworkbench")
				net.WriteEntity(self)
				net.WriteTable(self.Craftables)
				net.Send(activator)
				JMod.Hint(activator, "craft")
			else
				JMod.Hint(activator, "refill")
			end
		else
			JMod.Hint(activator, "destroyed")
		end
	end
	function ENT:TryBuild(itemName,ply)
		local ItemInfo=self.Craftables[itemName]

		if(JMod.HaveResourcesToPerformTask(nil,nil,ItemInfo.craftingReqs,self))then
			local override, msg=hook.Run("JMod_CanWorkbenchBuild", ply, workbench, itemName)
			if override == false then
				ply:PrintMessage(HUD_PRINTCENTER,msg or "cannot build")
				return
			end
			local Pos,Ang,BuildSteps=self:GetPos()+self:GetUp()*55+self:GetForward()*0-self:GetRight()*5,self:GetAngles(),10
			JMod.ConsumeResourcesInRange(ItemInfo.craftingReqs,Pos,nil,self,true)
			timer.Simple(1,function()
				if(IsValid(self))then
					for i=1,BuildSteps do
						timer.Simple(i/100,function()
							if(IsValid(self))then
								if(i<BuildSteps)then
									sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",Pos,60,math.random(80,120))
								else
									local StringParts=string.Explode(" ",ItemInfo.results)
									if((StringParts[1])and(StringParts[1]=="FUNC"))then
										local FuncName=StringParts[2]
										if((JMod.LuaConfig)and(JMod.LuaConfig.BuildFuncs)and(JMod.LuaConfig.BuildFuncs[FuncName]))then
											local Ent=JMod.LuaConfig.BuildFuncs[FuncName](ply,Pos,Ang)
											if(Ent)then
												if(Ent:GetPhysicsObject():GetMass()<=15)then ply:PickupObject(Ent) end
											end
										else
											print("JMOD WORKBENCH ERROR: garrysmod/lua/autorun/JMod.LuaConfig.lua is missing, corrupt, or doesn't have an entry for that build function")
										end
									else
										local Ent=ents.Create(ItemInfo.results)
										Ent:SetPos(Pos)
										Ent:SetAngles(Ang)
										JMod.SetOwner(Ent,ply)
										Ent:Spawn()
										Ent:Activate()
										if(Ent:GetPhysicsObject():GetMass()<=15)then ply:PickupObject(Ent) end
									end
									self:BuildEffect(Pos)
									self:ConsumeElectricity(8)
									self:SetGas(math.Clamp(self:GetGas()-6,0,self.MaxGas))
								end
							end
						end)
					end
				end
			end)
		else
			JMod.Hint(ply,"missing supplies")
		end
	end
elseif(CLIENT)then
	function ENT:CustomInit()
		--self.Camera=JMod.MakeModel(self,"models/props_combine/combinecamera001.mdl")
		self.Glassware1=JMod.MakeModel(self,"models/props_junk/glassjug01.mdl","models/props_combine/health_charger_glass")
		self.Glassware2=JMod.MakeModel(self,"models/props_junk/glassjug01.mdl","models/props_combine/health_charger_glass")
		self.Screen=JMod.MakeModel(self,"models/props_lab/monitor01b.mdl")
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
		if(self:GetState()<0)then DetailDraw=false end
		---
		self:DrawModel()
		---
		if(DetailDraw)then
			local GlasswareAng=SelfAng:GetCopy()
			JMod.RenderModel(self.Glassware1,BasePos-Up*12.5-Forward*47,GlasswareAng)
			JMod.RenderModel(self.Glassware2,BasePos-Up*12.5-Forward*47-Right*9,GlasswareAng)
			local ScreenAng=SelfAng:GetCopy()
			JMod.RenderModel(self.Screen,BasePos-Up*5-Forward*60-Right*25,ScreenAng)
			if(self:GetElectricity()>0)then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Forward,90)
				DisplayAng:RotateAroundAxis(Up,90)
				local Opacity=math.random(50,200)
				cam.Start3D2D(BasePos-Right*24-Forward*53.5-Up,DisplayAng,.04)
				draw.SimpleTextOutlined("JMOD","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac=self:GetElectricity()/self.MaxElectricity
				local R,G,B=JMod.GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined("POWER "..math.Round(ElecFrac*100).."%","JMod-Display",0,60,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local GasFrac=self:GetGas()/self.MaxGas
				local R,G,B=JMod.GoodBadColor(GasFrac)
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
		--JMod.RenderModel(self.Camera,BasePos+Up*10+Forward*25,CamAng,nil,GradeColors[Grade],GradeMats[Grade])
		
		local Matricks=Matrix()
		Matricks:Scale(Vector(.4,1.45,.5))
		self.BottomCanopy:EnableMatrix("RenderMultiply",Matricks)
		local BottomCanopyAng=SelfAng:GetCopy()
		BottomCanopyAng:RotateAroundAxis(Right,180)
		JMod.RenderModel(self.BottomCanopy,BasePos-Up*17+Right*2,BottomCanopyAng)
		--]]
	end
	language.Add("ent_jack_gmod_ezworkbench","EZ Workbench")
end
