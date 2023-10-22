-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Type = "anim"
ENT.PrintName = "EZ Primitive Workbench"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = "glhfggwpezpznore"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = "models/jmod/machines/primitive_bench.mdl"
ENT.Mass = 250
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.WOOD,
	JMod.EZ_RESOURCE_TYPES.COAL
}
ENT.FlexFuels = {JMod.EZ_RESOURCE_TYPES.WOOD, JMod.EZ_RESOURCE_TYPES.COAL}
ENT.EZcolorable = false
---
ENT.StaticPerfSpecs={
	MaxDurability = 100,
	Armor = .7
}
local STATE_BROKEN, STATE_FINE = -1, 0
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Wood")
end
if(SERVER)then
	function ENT:CustomInit()
		local phys = self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:SetBuoyancyRatio(.3)
		end
		if not(self.EZowner)then self:SetColor(Color(255, 255, 255)) end
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
	function ENT:SetupWire()
		if not(istable(WireLib)) then return end
		---
		local WireOutputs = {"State [NORMAL]"}
		local WireOutputDesc = {"The state of the machine \n-1 is broken \n0 is fine"}
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then typ = "Durability" end
			local ResourceName = string.Replace(typ, " ", "")
			local ResourceDesc = "Amount of "..ResourceName.." left"
			--
			local OutResourceName = string.gsub(ResourceName, "^%l", string.upper).." [NORMAL]"
			table.insert(WireOutputs, OutResourceName)
			table.insert(WireOutputDesc, ResourceDesc)
		end
		self.Outputs = WireLib.CreateOutputs(self, WireOutputs, WireOutputDesc)
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
		if(self:GetState() == STATE_FINE)then
			if(self:GetElectricity() > 0)then
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
									JMod.BuildRecipe(ItemInfo.results, ply, Pos, Ang, ItemInfo.skin)
									self:BuildEffect(Pos)
									self:ConsumeElectricity(8)
									self:UpdateWireOutputs()
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
	end

	function ENT:DrawTranslucent()
		local SelfPos,SelfAng,FT=self:GetPos(),self:GetAngles(),FrameTime()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		---
		local BasePos = SelfPos + Up*30
		local Obscured = false--util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(self:GetState()<0)then DetailDraw = false end
		---
		self:DrawModel()
		---
		if(DetailDraw)then
			if(self:GetElectricity() > 0)then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Forward, 90)
				DisplayAng:RotateAroundAxis(Up, 90)
				local Opacity = math.random(50, 200)
				cam.Start3D2D(BasePos - Up * 40 + Right * 50 + Forward * 1.5, DisplayAng, .04)
				draw.SimpleTextOutlined("JMOD","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac = self:GetElectricity()/self.MaxElectricity
				local R,G,B = JMod.GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined("FUEL "..math.Round(ElecFrac*100).."%","JMod-Display",0,60,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezprimitivebench","EZ Primitive Workbench")
end
