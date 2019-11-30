//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
local HULL_TINY=3
local HULL_TINY_CENTERED=6
local HULL_SMALL_CENTERED=1
local HULL_HUMAN=0
local HULL_WIDE_SHORT=4
local HULL_WIDE_HUMAN=2
local HULL_MEDIUM=5
local HULL_MEDIUM_TALL=9
local HULL_LARGE=7
local HULL_LARGE_CENTERED=8
local matLight=Material("sprites/mat_jack_basicglow")
function ENT:Initialize()
	self.Camera=ClientsideModel("models/props_junk/PopCan01a.mdl")
	self.Camera:SetMaterial("models/mat_jack_turretcamera")
	self.Camera:SetPos(self:GetPos())
	self.Camera:SetParent(self)
	self.Camera:SetNoDraw(true)
	self.CameraPost=ClientsideModel("models/props_c17/TrapPropeller_Lever.mdl")
	self.CameraPost:SetPos(self:GetPos())
	self.CameraPost:SetParent(self)
	self.CameraPost:SetNoDraw(true)
	self.AmmoBox=ClientsideModel("models/Items/BoxSRounds.mdl")
	self.AmmoBox:SetMaterial(self.AmmoBoxSkin)
	self.AmmoBox:SetPos(self:GetPos())
	self.AmmoBox:SetParent(self)
	self.AmmoBox:SetNoDraw(true)
	self.Battery=ClientsideModel("models/Items/car_battery01.mdl")
	self.Battery:SetMaterial("models/mat_jack_turretbattery")
	self.Battery:SetPos(self:GetPos())
	self.Battery:SetParent(self)
	self.Battery:SetNoDraw(true)
	self.AmmoPicID=surface.GetTextureID(self.AmmoPic)
	self.IFFTags={}
end
local function Receive(data)
	local self=data:ReadEntity()
	self.IFFTags={}
	local str=data:ReadString()
	for key,tag in pairs(string.Split(str," "))do
		table.ForceInsert(self.IFFTags,tonumber(tag))
	end
end
usermessage.Hook("JackyIFFList",Receive)
function ENT:Draw()
	local OrigR,OrigG,OrigB=render.GetColorModulation()
	local SelfPos=self:GetPos()
	local Up=self:GetUp()
	local Right=self:GetRight()
	local Forward=self:GetForward()
	self.Camera:SetRenderOrigin(SelfPos+Up*60.5-Right)
	self.CameraPost:SetRenderOrigin(SelfPos+Up*55-Right)
	self.AmmoBox:SetRenderOrigin(SelfPos+Up*24-Right*10.75-Forward)
	self.Battery:SetRenderOrigin(SelfPos+Up*20+Right*4.5-Forward)
	local Ang=self:GetAngles()
	local AngTwo=Angle(Ang.p,Ang.y,Ang.r)
	local AngThree=Angle(Ang.p,Ang.y,Ang.r)
	local AngFour=Angle(Ang.p,Ang.y,Ang.r)
	local AngWholes=Angle(Ang.p,Ang.y,Ang.r)
	AngTwo:RotateAroundAxis(AngTwo:Forward(),90)
	self.CameraPost:SetRenderAngles(AngTwo)
	AngThree:RotateAroundAxis(AngThree:Up(),180)
	AngThree:RotateAroundAxis(AngThree:Forward(),-10)
	self.AmmoBox:SetRenderAngles(AngThree)
	AngFour:RotateAroundAxis(AngFour:Forward(),90)
	AngFour:RotateAroundAxis(AngFour:Right(),180)
	self.Battery:SetRenderAngles(AngFour)
	Ang:RotateAroundAxis(Ang:Right(),-90)
	local State=self:GetDTInt(0)
	if((State==2)or(State==3)or(State==4))then
		Ang:RotateAroundAxis(Ang:Forward(),math.sin(CurTime()*7)*90)
	else
		Ang:RotateAroundAxis(Ang:Forward(),-self:GetDTInt(1))
	end
	self.Camera:SetRenderAngles(Ang)
	render.SetColorModulation(0,0,0)
	self.CameraPost:DrawModel()
	render.SetColorModulation(1,1,1)
	if(self:GetDTBool(0))then self.AmmoBox:DrawModel() end
	render.SetColorModulation(OrigR,OrigG,OrigB)
	self.Camera:DrawModel()
	if(self:GetDTBool(1))then
		self.Battery:DrawModel()
		local Frac=1-(self:GetDTInt(2)/100)
		if(Frac<=.995)then
			AngWholes:RotateAroundAxis(AngWholes:Right(),-90)
			local Colr=Color((4*Frac-1)*255,(-2*Frac+2)*255,(-4*Frac+1)*255,50)
			cam.Start3D2D(SelfPos-Forward*6.15+Up*22.75+Right*5,AngWholes,.01)
			draw.RoundedBox(8,0,0,500,50,Colr)
			cam.End3D2D()
		end
	end
	self.Entity:DrawModel()
	local Pos,Ang=self:GetBonePosition(1)
	Ang:RotateAroundAxis(Ang:Up(),90)
	Ang:RotateAroundAxis(Ang:Forward(),90)
	Pos=Pos-Ang:Right()*11+Ang:Up()*1.75*self.MechanicsSizeMod
	cam.Start3D2D(Pos,Ang,.05)
	local Ambient=render.GetLightColor(Pos)
	draw.TexturedQuad({
		texture=self.AmmoPicID,
		x=100,
		y=100,
		w=100,
		h=100,
		color=Color(Ambient.x*255,Ambient.y*255,Ambient.z*255)
	})
	draw.SimpleText(self.LabelText,"HudHintTextLarge",170,182,Color(Ambient.x*255,Ambient.y*255,Ambient.z*255),1,1)
	draw.SimpleText("Sentry Turret","HudHintTextLarge",170,198,Color(Ambient.x*255,Ambient.y*255,Ambient.z*255),1,1)
	cam.End3D2D()
	if(self:GetDTBool(3))then
		render.SetMaterial(matLight)
		local PosAng=self:GetAttachment(1)
		render.DrawSprite(PosAng.Pos+PosAng.Ang:Up()*5-PosAng.Ang:Forward()*8+PosAng.Ang:Right()*5,50,50,Color(255,255,255,255),100)
	end
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_turret_base","LAWL")
--[[--------------------------------------------------------------
	I hate desiging UIs so damn much
---------------------------------------------------------------]]--
local function OpenMenu(data)
	local Tab={}
	Tab.Self=data:ReadEntity()
	Tab.Batt=data:ReadShort()
	Tab.Ammo=data:ReadShort()
	Tab.TGBird=data:ReadBool()
	Tab.TGCat=data:ReadBool()
	Tab.TGDog=data:ReadBool()
	Tab.TGHuman=data:ReadBool()
	Tab.TGGorilla=data:ReadBool()
	Tab.TGBear=data:ReadBool()
	Tab.TGHorse=data:ReadBool()
	Tab.TGMoose=data:ReadBool()
	Tab.TGShark=data:ReadBool()
	Tab.TGElephant=data:ReadBool()
	Tab.TGSyn=data:ReadBool()
	Tab.IFFUser=data:ReadBool()
	Tab.Warn=data:ReadBool()
	Tab.TGOrg=data:ReadBool()
	Tab.Light=data:ReadBool()
	Tab.Self:OpenTheMenu(Tab)
end
usermessage.Hook("JackaTurretOpenMenu",OpenMenu)
function ENT:OpenTheMenu(tab)
	local DermaPanel=vgui.Create("DFrame")
	DermaPanel:SetPos(50,50)
	DermaPanel:SetSize(200,395)
	DermaPanel:SetTitle("Jackarunda Industries")
	DermaPanel:SetVisible(true)
	DermaPanel:SetDraggable(true)
	DermaPanel:ShowCloseButton(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()

	local MainPanel=vgui.Create("DPanel",DermaPanel)
	MainPanel:SetPos(5,25)
	MainPanel:SetSize(190,365)
	MainPanel.Paint=function()
		surface.SetDrawColor(0,20,40,255)
		surface.DrawRect(0,0,MainPanel:GetWide(),MainPanel:GetTall())
	end
	
	local ammolabel=vgui.Create("DLabel",MainPanel)
	ammolabel:SetPos(15,5)
	ammolabel:SetSize(150,20)
	ammolabel:SetText("Ammo: "..tostring(tab.Ammo).." rds")
	
	local battlabel=vgui.Create("DLabel",MainPanel)
	battlabel:SetPos(110,5)
	battlabel:SetSize(150,20)
	battlabel:SetText("Power: "..tostring(math.Round((tab.Batt/3000)*100)).."%")
	--[[
	local detselect=vgui.Create("DMultiChoice",MainPanel)
	detselect:SetPos(100,10)
	detselect:SetSize(90,20)
	detselect:SetEditable(false)
	detselect:AddChoice("Autonomous")
	detselect:AddChoice("Remote")
	detselect:AddChoice("Timed")
	detselect:AddChoice("Shock-Sensitive")
	detselect:SetText(self.DetonatorType)
	detselect.OnSelect=function(panel,index,value)
		if(!value)then return end
		self.DetonatorType=value
		RunConsoleCommand("JIDIYEXKIT_setdettype",value)
	end
	--]]
	local BaseY=30
	local AddY=18
	local tg1box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg1box:SetPos(7,BaseY)
	tg1box:SetSize(200,15)
	tg1box:SetText("Target SizeClass 1 (e.g. bird)")
	tg1box:SetChecked(tab.TGBird)
	tg1box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_TINY),tostring(check))
	end
	
	local tg2box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg2box:SetPos(7,BaseY+AddY)
	tg2box:SetSize(200,15)
	tg2box:SetText("Size Class 2 (e.g. cat)")
	tg2box:SetChecked(tab.TGCat)
	tg2box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_TINY_CENTERED),tostring(check))
	end
	
	local tg3box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg3box:SetPos(7,BaseY+AddY*2)
	tg3box:SetSize(200,15)
	tg3box:SetText("Size Class 3 (e.g. dog)")
	tg3box:SetChecked(tab.TGDog)
	tg3box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_SMALL_CENTERED),tostring(check))
	end
	
	local tg4box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg4box:SetPos(7,BaseY+AddY*3)
	tg4box:SetSize(200,15)
	tg4box:SetText("Size Class 4 (e.g. human)")
	tg4box:SetChecked(tab.TGHuman)
	tg4box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_HUMAN),tostring(check))
	end
	
	local tg5box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg5box:SetPos(7,BaseY+AddY*4)
	tg5box:SetSize(200,15)
	tg5box:SetText("Size Class 5 (e.g. gorilla)")
	tg5box:SetChecked(tab.TGGorilla)
	tg5box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_WIDE_SHORT),tostring(check))
	end
	
	local tg6box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg6box:SetPos(7,BaseY+AddY*5)
	tg6box:SetSize(200,15)
	tg6box:SetText("Size Class 6 (e.g. bear)")
	tg6box:SetChecked(tab.TGBear)
	tg6box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_WIDE_HUMAN),tostring(check))
	end
	
	local tg7box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg7box:SetPos(7,BaseY+AddY*6)
	tg7box:SetSize(200,15)
	tg7box:SetText("Size Class 7 (e.g. horse)")
	tg7box:SetChecked(tab.TGHorse)
	tg7box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_MEDIUM),tostring(check))
	end
	
	local tg8box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg8box:SetPos(7,BaseY+AddY*7)
	tg8box:SetSize(200,15)
	tg8box:SetText("Size Class 8 (e.g. moose)")
	tg8box:SetChecked(tab.TGMoose)
	tg8box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_MEDIUM_TALL),tostring(check))
	end
	
	local tg9box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg9box:SetPos(7,BaseY+AddY*8)
	tg9box:SetSize(200,15)
	tg9box:SetText("Size Class 9 (e.g. shark)")
	tg9box:SetChecked(tab.TGShark)
	tg9box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_LARGE),tostring(check))
	end
	
	local tg10box=vgui.Create("DCheckBoxLabel",MainPanel)
	tg10box:SetPos(7,BaseY+AddY*9)
	tg10box:SetSize(200,15)
	tg10box:SetText("Size Class 10 (e.g. elephant)")
	tg10box:SetChecked(tab.TGElephant)
	tg10box.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingChange",tostring(self:GetNetworkedInt("JackIndex")),tostring(HULL_LARGE_CENTERED),tostring(check))
	end
	
	local tgsynbox=vgui.Create("DCheckBoxLabel",MainPanel)
	tgsynbox:SetPos(15,BaseY+AddY*10+4)
	tgsynbox:SetSize(200,15)
	tgsynbox:SetText("Synthetics")
	tgsynbox:SetChecked(tab.TGSyn)
	tgsynbox.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingTypeChange",tostring(self:GetNetworkedInt("JackIndex")),"TargetSynthetics",tostring(check))
	end
	
	local tgorgbox=vgui.Create("DCheckBoxLabel",MainPanel)
	tgorgbox:SetPos(98,BaseY+AddY*10+4)
	tgorgbox:SetSize(200,15)
	tgorgbox:SetText("Organics")
	tgorgbox:SetChecked(tab.TGOrg)
	tgorgbox.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretTargetingTypeChange",tostring(self:GetNetworkedInt("JackIndex")),"TargetOrganics",tostring(check))
	end
	--[[
	local chanselect=vgui.Create("DNumSlider",MainPanel)
	chanselect:SetPos(10,40)
	chanselect:SetWide(260)
	chanselect:SetText("Remote: Listen Frequency Channel Preset")
	chanselect:SetMin(1)
	chanselect:SetMax(10)
	chanselect:SetDecimals(0)
	chanselect:SetValue(self.RemoteChannel)
	local chanselectarea=chanselect:GetTextArea()
	chanselectarea.OnTextChanged=function()
		local chanselectvalue=chanselectarea:GetValue()
		self.RemoteChannel=chanselectvalue
		RunConsoleCommand("JIDIYEXKIT_setremotechan",chanselectvalue)
	end
	
	local alabel=vgui.Create("DLabel",MainPanel)
	alabel:SetPos(20,83)
	alabel:SetSize(150,20)
	alabel:SetText("Wait for Remote Signal to Arm:")
	
	local timearmbox=vgui.Create("DCheckBoxLabel",MainPanel)
	timearmbox:SetPos(20,103)
	timearmbox:SetSize(150,20)
	timearmbox:SetText("Timed")
	timearmbox:SetValue(self.TimedRemoteArm)
	timearmbox.OnChange=function()
		if not(self.TimedRemoteArm==timearmbox:GetChecked())then
			self.TimedRemoteArm=timearmbox:GetChecked()
			RunConsoleCommand("JIDIYEXKIT_toggletimeremotearm")
		end
	end
	
	local autoarmbox=vgui.Create("DCheckBoxLabel",MainPanel)
	autoarmbox:SetPos(80,103)
	autoarmbox:SetSize(150,20)
	autoarmbox:SetText("Autonomous")
	autoarmbox:SetValue(self.AutonomousRemoteArm)
	autoarmbox.OnChange=function()
		if not(self.AutonomousRemoteArm==autoarmbox:GetChecked())then
			self.AutonomousRemoteArm=autoarmbox:GetChecked()
			RunConsoleCommand("JIDIYEXKIT_toggleautoremotearm")
		end
	end
	
	local accelarmbox=vgui.Create("DCheckBoxLabel",MainPanel)
	accelarmbox:SetPos(170,103)
	accelarmbox:SetSize(150,20)
	accelarmbox:SetText("Shock-Sensitive")
	accelarmbox:SetValue(self.AcceleratoryRemoteArm)
	accelarmbox.OnChange=function()
		if not(self.AcceleratoryRemoteArm==accelarmbox:GetChecked())then
			self.AcceleratoryRemoteArm=accelarmbox:GetChecked()
			RunConsoleCommand("JIDIYEXKIT_toggleaccelremotearm")
		end
	end
	
	local distselect=vgui.Create("DNumSlider",MainPanel)
	distselect:SetPos(10,125)
	distselect:SetWide(260)
	distselect:SetText("Autonomous: Maximum Detection Distance")
	distselect:SetMin(0.1)
	distselect:SetMax(20)
	distselect:SetDecimals(1)
	distselect:SetValue(math.Round(self.AutonomousDistance/52.49,1))
	local distselectarea=distselect:GetTextArea()
	distselectarea.OnTextChanged=function()
		local distselectvalue=distselectarea:GetValue()*52.49
		self.AutonomousDistance=distselectvalue
		RunConsoleCommand("JIDIYEXKIT_setautondist",distselectvalue)
	end
	
	local spdselect=vgui.Create("DNumSlider",MainPanel)
	spdselect:SetPos(10,165)
	spdselect:SetWide(260)
	spdselect:SetText("Autonomous: Minimum Triggering Speed")
	spdselect:SetMin(0.1)
	spdselect:SetMax(35)
	spdselect:SetDecimals(1)
	spdselect:SetValue(math.Round(self.AutonomousSpeed/52.49,1))
	local spdselectarea=spdselect:GetTextArea()
	spdselectarea.OnTextChanged=function()
		local spdselectvalue=spdselectarea:GetValue()*52.49
		self.AutonomousSpeed=spdselectvalue
		RunConsoleCommand("JIDIYEXKIT_setautonspd",spdselectvalue)
	end
	
	local delayselect=vgui.Create("DNumSlider",MainPanel)
	delayselect:SetPos(10,205)
	delayselect:SetWide(260)
	delayselect:SetText("Autonomous: Automatic Arming Delay")
	delayselect:SetMin(1)
	delayselect:SetMax(60)
	delayselect:SetDecimals(0)
	delayselect:SetValue(self.AutonomousArmDelay)
	local delayselectarea=delayselect:GetTextArea()
	delayselectarea.OnTextChanged=function()
		local delayselectvalue=delayselectarea:GetValue()
		self.AutonomousArmDelay=delayselectvalue
		RunConsoleCommand("JIDIYEXKIT_setautonspd",delayselectvalue)
	end
	
	local timeselectmins=vgui.Create("DNumSlider",MainPanel)
	timeselectmins:SetPos(10,245)
	timeselectmins:SetWide(125)
	timeselectmins:SetText("Timed: Minutes")
	timeselectmins:SetMin(0)
	timeselectmins:SetMax(10)
	timeselectmins:SetDecimals(0)
	timeselectmins:SetValue(self.TimedTimeMinutes)
	local timeminsselectarea=timeselectmins:GetTextArea()
	timeminsselectarea.OnTextChanged=function()
		local timeminsselectvalue=timeminsselectarea:GetValue()
		self.TimedTimeMinutes=timeminsselectvalue
		RunConsoleCommand("JIDIYEXKIT_settimedtimemins",timeminsselectvalue)
	end
	
	local timeselectsecs=vgui.Create("DNumSlider",MainPanel)
	timeselectsecs:SetPos(145,245)
	timeselectsecs:SetWide(125)
	timeselectsecs:SetText("Timed: Seconds")
	timeselectsecs:SetMin(0)
	timeselectsecs:SetMax(59)
	timeselectsecs:SetDecimals(0)
	timeselectsecs:SetValue(self.TimedTimeSeconds)
	local timesecsselectarea=timeselectsecs:GetTextArea()
	timesecsselectarea.OnTextChanged=function()
		local timesecsselectvalue=timesecsselectarea:GetValue()
		self.TimedTimeSeconds=timesecsselectvalue
		RunConsoleCommand("JIDIYEXKIT_settimedtimesecs",timesecsselectvalue)
	end
	
	local accelselect=vgui.Create("DNumSlider",MainPanel)
	accelselect:SetPos(10,285)
	accelselect:SetWide(260)
	accelselect:SetText("Shock-Sensitive: Minimum Collision Speed")
	accelselect:SetMin(1)
	accelselect:SetMax(50)
	accelselect:SetDecimals(0)
	accelselect:SetValue(self.AcceleratoryAcceleration)
	local accelselectarea=accelselect:GetTextArea()
	accelselectarea.OnTextChanged=function()
		local accelselectvalue=accelselectarea:GetValue()
		self.AcceleratoryAcceleration=accelselectvalue
		RunConsoleCommand("JIDIYEXKIT_setaccelaccel",accelselectvalue)
	end
	
	local beepbox=vgui.Create("DCheckBoxLabel",MainPanel)
	beepbox:SetPos(20,345)
	beepbox:SetSize(150,20)
	beepbox:SetText("Beep")
	beepbox:SetValue(self.Beep)
	beepbox.OnChange=function()
		if not(self.Beep==beepbox:GetChecked())then
			self.Beep=beepbox:GetChecked()
			RunConsoleCommand("JIDIYEXKIT_togglebeep")
		end
	end
	
	local rateselect=vgui.Create("DNumSlider",MainPanel)
	rateselect:SetPos(95,330)
	rateselect:SetWide(100)
	rateselect:SetText("Rate")
	rateselect:SetMin(0.1)
	rateselect:SetMax(4)
	rateselect:SetDecimals(1)
	rateselect:SetValue(self.BleepRate)
	local rateselectarea=rateselect:GetTextArea()
	rateselectarea.OnTextChanged=function()
		local rateselectvalue=rateselectarea:GetValue()
		self.BleepRate=rateselectvalue
		RunConsoleCommand("JIDIYEXKIT_setbleeprate",rateselectvalue)
	end
	
	local blinkbox=vgui.Create("DCheckBoxLabel",MainPanel)
	blinkbox:SetPos(220,345)
	blinkbox:SetSize(150,30)
	blinkbox:SetText("Blink")
	blinkbox:SetValue(self.Blink)
	beepbox.OnChange=function()
		if not(self.Blink==blinkbox:GetChecked())then
			self.Blink=blinkbox:GetChecked()
			RunConsoleCommand("JIDIYEXKIT_toggleblink")
		end
	end
	--]]
	
	local ammobutton=vgui.Create("Button",MainPanel)
	ammobutton:SetSize(80,25)
	ammobutton:SetPos(10,237)
	ammobutton:SetText("Ammunition")
	ammobutton:SetVisible(true)
	ammobutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaTurretAmmo",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local battbutton=vgui.Create("Button",MainPanel)
	battbutton:SetSize(80,25)
	battbutton:SetPos(100,237)
	battbutton:SetText("Electricity")
	battbutton:SetVisible(true)
	battbutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaTurretBattery",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local exitbutton=vgui.Create("Button",MainPanel)
	exitbutton:SetSize(80,25)
	exitbutton:SetPos(10,270)
	exitbutton:SetText("Exit")
	exitbutton:SetVisible(true)
	exitbutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaTurretCloseMenu_Cancel",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local On=(self:GetDTInt(0)!=0)
	
	local PowerPanel=vgui.Create("DPanel",MainPanel)
	PowerPanel:SetPos(98,268)
	PowerPanel:SetSize(84,29)
	PowerPanel.Paint=function()
		if(On)then
			surface.SetDrawColor(200,0,0,255)
		else
			surface.SetDrawColor(0,150,150,255)
		end
		surface.DrawRect(0,0,PowerPanel:GetWide(),PowerPanel:GetTall())
	end
	
	local powerbutton=vgui.Create("Button",MainPanel)
	powerbutton:SetSize(80,25)
	powerbutton:SetPos(100,270)
	if(On)then
		powerbutton:SetText("Deactivate")
	else
		powerbutton:SetText("Activate")
	end
	powerbutton:SetVisible(true)
	powerbutton.DoClick=function()
		DermaPanel:Close()
		if(On)then
			RunConsoleCommand("JackaTurretCloseMenu_Off",tostring(self:GetNetworkedInt("JackIndex")))
		else
			RunConsoleCommand("JackaTurretCloseMenu_On",tostring(self:GetNetworkedInt("JackIndex")))
		end
	end
	
	local syncbutton=vgui.Create("Button",MainPanel)
	syncbutton:SetSize(80,25)
	syncbutton:SetPos(10,303)
	if not(tab.IFFUser)then
		syncbutton:SetText("Sync IFF")
	else
		syncbutton:SetText("DeSync IFF")
	end
	syncbutton:SetVisible(true)
	syncbutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaTurretIFF",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local buttbutton=vgui.Create("Button",MainPanel)
	buttbutton:SetSize(170,25)
	buttbutton:SetPos(10,333)
	buttbutton:SetText("Set Upright")
	buttbutton:SetVisible(true)
	buttbutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaTurretUpright",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local warnbox=vgui.Create("DCheckBoxLabel",MainPanel)
	warnbox:SetPos(110,302)
	warnbox:SetSize(200,15)
	warnbox:SetText("Warn")
	warnbox:SetChecked(tab.Warn)
	warnbox.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretWarn",tostring(self:GetNetworkedInt("JackIndex")),tostring(check))
	end
	
	local litbox=vgui.Create("DCheckBoxLabel",MainPanel)
	litbox:SetPos(110,314)
	litbox:SetSize(200,15)
	litbox:SetText("Illuminate")
	litbox:SetChecked(tab.Light)
	litbox.OnChange=function(wat,check)
		RunConsoleCommand("JackaTurretLight",tostring(self:GetNetworkedInt("JackIndex")),tostring(check))
	end
end