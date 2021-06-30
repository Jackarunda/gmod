-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Ground Scanner"
ENT.Category="JMod - EZ Misc."
ENT.Spawnable=true
ENT.AdminOnly=false
ENT.Base="ent_jack_gmod_ezmachine_base"
ENT.JModPreferredCarryAngles=Angle(-90,180,0)
ENT.EZconsumes={JMod.EZ_RESOURCE_TYPES.POWER,JMod.EZ_RESOURCE_TYPES.BASICPARTS}
ENT.EZupgradeRate=1
ENT.StaticPerfSpecs={
	MaxElectricity=100,
	Durability=100
}
ENT.DynamicPerfSpecs={
	ScanSpeed=5,
	ScanRange=20
}
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Int",2,"Progress")
	self:NetworkVar("Float",1,"Electricity")
end
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/props_c17/substation_transformer01b.mdl")
		self:SetModelScale(.5,0)
		self:SetMaterial("models/mat_jack_gmod_groundscanner")
		--self:SetColor(Color(math.random(190,210),math.random(140,160),0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:SetAngles(Angle(-90,0,0))
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(200)
			self:GetPhysicsObject():Wake()
			self:SetPos(self:GetPos()+Vector(0,0,20))
		end)
		self:SetGrade(1)
		self:SetProgress(0)
		self:SetElectricity(100)
		self:SetState(JMod.EZ_STATE_OFF)
		print("settin to off 3")
		self.Snd1=CreateSound(self,"snds_jack_gmod/40Hz_sine1.wav")
		self.Snd2=CreateSound(self,"snds_jack_gmod/40Hz_sine2.wav")
		self.Snd3=CreateSound(self,"snds_jack_gmod/40Hz_sine3.wav")
		self.Snd1:SetSoundLevel(150)
		self.Snd2:SetSoundLevel(150)
		self.Snd3:SetSoundLevel(150)
		self:InitPerfSpecs()
	end
	function ENT:TurnOn(activator)
		if(self:GetElectricity()>0)then
			self:SetState(JMod.EZ_STATE_ON)
			print("settin to on")
			self:EmitSound("snd_jack_metallicclick.wav",60,100)
			self.Snd1:PlayEx(1,80)
			self.Snd2:PlayEx(1,80)
			self.Snd3:PlayEx(1,80)
		else
			JMod.Hint(activator,"nopower")
		end
	end
	function ENT:TurnOff()
		self:SetState(JMod.EZ_STATE_OFF)
		print("settin to off 2")
		self:EmitSound("snd_jack_metallicclick.wav",60,100)
		self.Snd1:Stop()
		self.Snd2:Stop()
		self.Snd3:Stop()
	end
	function ENT:Use(activator)
		local State=self:GetState()
		JMod.Hint(activator,"ground scanner")
		local OldOwner=self.Owner
		JMod.Owner(self,activator)
		local Alt=activator:KeyDown(JMod.Config.AltFunctionKey)
		if(Alt)then
			if(IsValid(self.Owner))then
				if(OldOwner~=self.Owner)then -- if owner changed then reset team color
					JMod.Colorify(self)
				end
			end
			if(State==JMod.EZ_STATE_BROKEN)then
				JMod.Hint(activator,"destroyed",self)
				return
			elseif(State==JMod.EZ_STATE_OFF)then
				self:TurnOn(activator)
			elseif(State==JMod.EZ_STATE_ON)then
				jprint("wat")
				self:TurnOff()
			end
		else
			activator:PickupObject(self)
		end
	end
	local function FindNaturalResourcesInRange(pos,rng,tbl,typ)
		rng=rng*52 -- meters to source units
		local Res={}
		for k,v in pairs(tbl)do
			if((v.pos:Distance(pos)-v.siz)<rng)then
				table.insert(Res,{
					pos=v.pos,
					amt=v.amt,
					siz=v.siz,
					typ=typ
				})
			end
		end
		jprint(#Res)
		return Res
	end
	function ENT:Think()
		local State=self:GetState()
		if(State==JMod.EZ_STATE_BROKEN)then
			if(self:GetElectricity()>0)then
				if(math.random(1,4)==2)then self:DamageSpark() end
			end
			return
		elseif(State==JMod.EZ_STATE_ON)then
			if(self:GetElectricity()<=0)then self:TurnOff() return end
			self:SetProgress(math.Clamp(self:GetProgress()+self.ScanSpeed,0,100))
			if(self:GetProgress()>=100)then
				self:FinishScan()
				self:SetProgress(0)
			end
		end
		self:NextThink(CurTime()+.5)
		--PrintTable(FindNaturalResourcesInRange(self:GetPos(),self.ScanRange,JMod.OilReserves,"oil"))
		return true
	end
	function ENT:FinishScan()
		local Pos,Results=self:GetPos(),{}
		table.Add(Results,FindNaturalResourcesInRange(Pos,self.ScanRange,JMod.OilReserves,"oil"))
		table.Add(Results,FindNaturalResourcesInRange(Pos,self.ScanRange,JMod.OreDeposits,"ore"))
		table.Add(Results,FindNaturalResourcesInRange(Pos,self.ScanRange,JMod.GeoThermalReservoirs,"geo"))
		table.Add(Results,FindNaturalResourcesInRange(Pos,self.ScanRange,JMod.WaterReservoirs,"water"))
		PrintTable(Results)
		net.Start("JMod_ResourceScanner")
		net.WriteEntity(self)
		net.WriteTable(Results)
		net.Broadcast()
	end
	function ENT:OnRemove()
		self.Snd1:Stop()
		self.Snd2:Stop()
		self.Snd3:Stop()
	end
elseif(CLIENT)then
	net.Receive("JMod_ResourceScanner",function()
		local Ent=net.ReadEntity()
		if(IsValid(Ent))then Ent.ScanResults=net.ReadTable() end
		print("A")
		PrintTable(Ent.ScanResults)
	end)
	function ENT:Initialize()
		self.Tank=ClientsideModel("models/props_wasteland/horizontalcoolingtank04.mdl")
		self.Tank:SetParent(self)
		self.Tank:SetPos(self:GetPos())
		self.Tank:SetModelScale(.12,0)
		self.Tank:SetNoDraw(true)
		self.ScanResults={}
	end
	local GradeColors={Vector(.3,.3,.3),Vector(.2,.2,.2),Vector(.2,.2,.2),Vector(.2,.2,.2),Vector(.2,.2,.2)}
	local GradeMats={Material("phoenix_storms/metal"),Material("models/mat_jack_gmod_copper"),Material("models/mat_jack_gmod_silver"),Material("models/mat_jack_gmod_gold"),Material("models/mat_jack_gmod_platinum")}
	local WorldToDisplayFactor=41.6
	function ENT:Draw()
		local Time,SelfPos,SelfAng,State,Grade=CurTime(),self:GetPos(),self:GetAngles(),self:GetState(),self:GetGrade()
		local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
		local TankAng=SelfAng:GetCopy()
		TankAng:RotateAroundAxis(Right,-90)
		JMod.RenderModel(self.Tank,SelfPos+Forward*2,TankAng,nil,GradeColors[Grade],GradeMats[Grade])
		self:DrawModel()
		--
		local BasePos=SelfPos+Up*32
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==JMod.EZ_STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		if(DetailDraw)then
			if((Closeness<20000)and(State==JMod.EZ_STATE_ON))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),180)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),-90)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*50,DisplayAng,.024)
				draw.SimpleTextOutlined("POWER","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac=self:GetElectricity()/200
				local R,G,B=JMod.GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",0,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				--local CoolFrac=self:GetCoolant()/100
				--draw.SimpleTextOutlined("COOLANT","JMod-Display",90,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				--local R,G,B=JMod.GoodBadColor(CoolFrac)
				--draw.SimpleTextOutlined(tostring(math.Round(CoolFrac*100)).."%","JMod-Display",90,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezgroundscanner","EZ Ground Scanner")
end