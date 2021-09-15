local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local MenuOpen = false
local YesMat = Material("icon16/accept.png")
local NoMat = Material("icon16/cancel.png")
local function BlurBackground(panel)
	if not((IsValid(panel))and(panel:IsVisible()))then return end
	local layers,density,alpha=1,1,255
	local x,y=panel:LocalToScreen(0,0)
	surface.SetDrawColor(255,255,255,alpha)
	surface.SetMaterial(blurMat)
	local FrameRate,Num,Dark=1/FrameTime(),5,150
	for i=1,Num do
		blurMat:SetFloat("$blur",(i/layers)*density*Dynamic)
		blurMat:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x,-y,ScrW(),ScrH())
	end
	surface.SetDrawColor(0,0,0,Dark*Dynamic)
	surface.DrawRect(0,0,panel:GetWide(),panel:GetTall())
	Dynamic=math.Clamp(Dynamic+(1/FrameRate)*7,0,1)
end

local function PopulateList(parent,friendList,myself,W,H)
	parent:Clear()
	local Y=0
	for k,playa in pairs(player.GetAll())do
		if(playa~=myself)then
			local Panel=parent:Add("DPanel")
			Panel:SetSize(W-35,20)
			Panel:SetPos(0,Y)
			function Panel:Paint(w,h)
				surface.SetDrawColor(0,0,0,100)
				surface.DrawRect(0,0,w,h)
				draw.SimpleText(playa:Nick(),"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
			end
			local Buttaloney=vgui.Create("DButton",Panel)
			Buttaloney:SetPos(Panel:GetWide()-25,0)
			Buttaloney:SetSize(20,20)
			Buttaloney:SetText("")
			local InLikeFlynn=table.HasValue(friendList,playa)
			function Buttaloney:Paint(w,h)
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial((InLikeFlynn and YesMat)or NoMat)
				surface.DrawTexturedRect(2,2,16,16)
			end
			
			function Buttaloney:DoClick()
				surface.PlaySound("garrysmod/ui_click.wav")
				if(InLikeFlynn)then
					table.RemoveByValue(friendList,playa)
				else
					table.insert(friendList,playa)
				end
				PopulateList(parent,friendList,myself,W,H)
			end
			Y=Y+25
		end
	end
end
local SpecialIcons={
	["geothermal"]=Material("ez_resource_icons/geothermal.png")
}
function JMod.StandardResourceDisplay(typ,amt,maximum,x,y,siz,vertical,font,opacity,rateDisplay)
	font=font or "JMod-Stencil"
	opacity=opacity or 150
	local Col=Color(200,200,200,opacity)
	surface.SetDrawColor(255,255,255,opacity)
	surface.SetMaterial(JMod.EZ_RESOURCE_TYPE_ICONS[typ] or SpecialIcons[typ])
	surface.DrawTexturedRect(x-siz/2,y-siz/2,siz,siz)
	local UnitText=tostring(amt).." UNITS"
	if(rateDisplay)then UnitText=tostring(amt).." PER SECOND" end
	if(vertical)then
		draw.SimpleText(typ,font,x,y-siz/2-10,Col,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
		draw.SimpleText(UnitText,font,x,y+siz/2+10,Col,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
	else
		draw.SimpleText(typ,font,x-siz/2-10,y,Col,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
		draw.SimpleText(UnitText,font,x+siz/2+10,y,Col,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
	end
end

function JMod.HoloGraphicDisplay(ent,relPos,relAng,scale,renderDist,renderFunc)
	local Ang,Pos=Angle(0,0,0),Vector(0,0,0)
	if(IsValid(ent) and ent.GetAngles)then
		Ang=ent:GetAngles()
		Pos=ent:GetPos()
	else -- we're using world coordinates
		Pos=relPos
		Ang=relAng
	end
	local Right,Up,Forward=Ang:Right(),Ang:Up(),Ang:Forward()
	if(EyePos():Distance(Pos)<renderDist)then
		if(ent)then
			Ang:RotateAroundAxis(Right,relAng.p)
			Ang:RotateAroundAxis(Up,relAng.y)
			Ang:RotateAroundAxis(Forward,relAng.r)
		end
		local RenderPos=Pos+relPos.x*Right+relPos.y*Forward+relPos.z*Up
		if not(ent)then -- world coords
			RenderPos=Pos+Vector(0,0,50)
		end
		cam.Start3D2D(RenderPos,Ang,scale)
		renderFunc()
		cam.End3D2D()
	end
end

net.Receive("JMod_Friends",function()
	local Updating=tobool(net.ReadBit())
	if(Updating)then
		local Playa=net.ReadEntity()
		local FriendList=net.ReadTable()
		Playa.JModFriends=FriendList
		return
	end
	if(MenuOpen)then return end
	MenuOpen=true
	local Frame,W,H,Myself,FriendList=vgui.Create("DFrame"),300,400,LocalPlayer(),net.ReadTable()
	Frame:SetPos(40,80)
	Frame:SetSize(W,H)
	Frame:SetTitle("Select Allies")
	Frame:SetVisible(true)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:MakePopup()
	Frame:Center()
	Frame.OnClose=function()
		MenuOpen=false
		net.Start("JMod_Friends")
		net.WriteTable(FriendList)
		net.SendToServer()
	end
	function Frame:OnKeyCodePressed(key)
		if((key==KEY_Q)or(key==KEY_ESCAPE))then self:Close() end
	end
	function Frame:Paint()
		BlurBackground(self)
	end
	local Scroll=vgui.Create("DScrollPanel",Frame)
	Scroll:SetSize(W-15,H)
	Scroll:SetPos(10,30)
	PopulateList(Scroll,FriendList,Myself,W,H)
end)

net.Receive("JMod_MineColor",function()
	local Ent,NextColorCheck=net.ReadEntity(),0
	if not(IsValid(Ent))then return end
	local Frame=vgui.Create("DFrame")
	Frame:SetSize(200,200)
	Frame:SetPos(ScrW()*.4-200,ScrH()*.5)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:SetTitle("EZ Landmine")
	Frame:MakePopup()
	local Picker
	function Frame:Paint()
		BlurBackground(self)
		local Time=CurTime()
		if(NextColorCheck<Time)then
			if not(IsValid(Ent))then Frame:Close();return end
			NextColorCheck=Time+.25
			local Col=Picker:GetColor()
			net.Start("JMod_MineColor")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r,Col.g,Col.b))
			net.WriteBit(false)
			net.SendToServer()
		end
	end
	Picker=vgui.Create("DColorMixer",Frame)
	Picker:SetPos(5,25)
	Picker:SetSize(190,115)
	Picker:SetAlphaBar(false)
	Picker:SetPalette(false)
	Picker:SetWangs(false)
	Picker:SetColor(Ent:GetColor())
	local Butt=vgui.Create("DButton",Frame)
	Butt:SetPos(5,145)
	Butt:SetSize(190,50)
	Butt:SetText("ARM")
	function Butt:DoClick()
		local Col=Picker:GetColor()
		net.Start("JMod_MineColor")
		net.WriteEntity(Ent)
		net.WriteColor(Color(Col.r,Col.g,Col.b))
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end
end)

net.Receive("JMod_ArmorColor",function()
	local Ent,NextColorCheck=net.ReadEntity(),0
	if not(IsValid(Ent))then return end
	local Frame=vgui.Create("DFrame")
	Frame:SetSize(200,300)
	Frame:SetPos(ScrW()*.4-200,ScrH()*.5)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:SetTitle("EZ Armor")
	Frame:MakePopup()
	local Picker
	function Frame:Paint()
		BlurBackground(self)
		local Time=CurTime()
		if(NextColorCheck<Time)then
			if not(IsValid(Ent))then Frame:Close();return end
			NextColorCheck=Time+.25
			local Col=Picker:GetColor()
			Col.r=math.max(Col.r,50)
			Col.g=math.max(Col.g,50)
			Col.b=math.max(Col.b,50)
			net.Start("JMod_ArmorColor")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r,Col.g,Col.b))
			net.WriteBit(false)
			net.SendToServer()
		end
	end
	Picker=vgui.Create("DColorMixer",Frame)
	Picker:SetPos(5,25)
	Picker:SetSize(190,215)
	Picker:SetAlphaBar(false)
	Picker:SetPalette(false)
	Picker:SetWangs(false)
	Picker:SetPalette(true)
	Picker:SetColor(Ent:GetColor())
	local Butt=vgui.Create("DButton",Frame)
	Butt:SetPos(5,245)
	Butt:SetSize(190,50)
	Butt:SetText("EQUIP")
	function Butt:DoClick()
		local Col=Picker:GetColor()
		Col.r=math.max(Col.r,50)
		Col.g=math.max(Col.g,50)
		Col.b=math.max(Col.b,50)
		net.Start("JMod_ArmorColor")
		net.WriteEntity(Ent)
		net.WriteColor(Color(Col.r,Col.g,Col.b))
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end
end)

net.Receive("JMod_SignalNade",function()
	local Ent,NextColorCheck=net.ReadEntity(),0
	if not(IsValid(Ent))then return end
	local Frame=vgui.Create("DFrame")
	Frame:SetSize(200,300)
	Frame:SetPos(ScrW()*.4-200,ScrH()*.5)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:SetTitle("EZ Signal Grenade")
	Frame:MakePopup()
	local Picker
	function Frame:Paint()
		BlurBackground(self)
		local Time=CurTime()
		if(NextColorCheck<Time)then
			if not(IsValid(Ent))then Frame:Close();return end
			NextColorCheck=Time+.25
			local Col=Picker:GetColor()
			net.Start("JMod_SignalNade")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r,Col.g,Col.b))
			net.WriteBit(false)
			net.SendToServer()
		end
	end
	Picker=vgui.Create("DColorMixer",Frame)
	Picker:SetPos(5,25)
	Picker:SetSize(190,215)
	Picker:SetAlphaBar(false)
	Picker:SetPalette(false)
	Picker:SetWangs(false)
	Picker:SetPalette(true)
	Picker:SetColor(Ent:GetColor())
	local Butt=vgui.Create("DButton",Frame)
	Butt:SetPos(5,245)
	Butt:SetSize(190,50)
	Butt:SetText("ARM")
	function Butt:DoClick()
		local Col=Picker:GetColor()
		net.Start("JMod_SignalNade")
		net.WriteEntity(Ent)
		net.WriteColor(Color(Col.r,Col.g,Col.b))
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end
end)
local function PopulateRecipes(parent,recipes,builder,motherFrame,typ)
	parent:Clear()
	local W,H=parent:GetWide(),parent:GetTall()
	local Scroll=vgui.Create("DScrollPanel",parent)
	Scroll:SetSize(W-15,H-10)
	Scroll:SetPos(10,10)
	---
	local Y=0
	for k,itemInfo in pairs(recipes)do
		local Butt=Scroll:Add("DButton")
		Butt:SetSize(W-35,25)
		Butt:SetPos(0,Y)
		Butt:SetText("")
		local reqs=itemInfo[2]
		if(type(reqs)=="string")then reqs=itemInfo[3] end
		local canMake=JMod.HaveResourcesToPerformTask(nil,nil,reqs,builder)
		local desc = itemInfo[5] or ""
			if typ == "workbench" then
				desc = itemInfo[4] 
			elseif typ == "buildkit" then 
				desc = itemInfo[6]
			end
		Butt:SetToolTip(desc) --pooooshhh
		function Butt:Paint(w,h)
			surface.SetDrawColor(50,50,50,100)
			surface.DrawRect(0,0,w,h)
			local msg=k..": " 			
			if(tonumber(k))then msg=itemInfo[1]..": " end
			for nam,amt in pairs(reqs)do
				msg=msg..amt.." "..nam..", "
			end
			draw.SimpleText(msg,"DermaDefault",5,3,Color(255,255,255,(canMake and 255)or 100),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
			
		end
		function Butt:DoClick()
			if(typ=="workbench")then
				net.Start("JMod_EZworkbench")
				net.WriteEntity(builder)
				net.WriteString(k)
				net.SendToServer()
			elseif(typ=="buildkit")then
				net.Start("JMod_EZbuildKit")
				net.WriteInt(k,8)
				net.SendToServer()
			end
			motherFrame:Close()
		end
		Y=Y+30
	end
end
net.Receive("JMod_EZbuildKit",function()
	local Buildables=net.ReadTable()
	local Kit=net.ReadEntity()
	
	local resTbl = JMod.CountResourcesInRange(nil,nil,Kit)
	
	local motherFrame = vgui.Create("DFrame")
	motherFrame:SetSize(620, 310)
	motherFrame:SetVisible(true)
	motherFrame:SetDraggable(true)
	motherFrame:ShowCloseButton(true)
	motherFrame:SetTitle("Build Kit")
	function motherFrame:Paint()
		BlurBackground(self)
	end
	motherFrame:MakePopup()
	motherFrame:Center()
	function motherFrame:OnKeyCodePressed(key)
		if key==KEY_Q or key==KEY_ESCAPE or key == KEY_E then self:Close() end
	end
	
	local Frame,W,H,Myself=vgui.Create("DPanel", motherFrame),500,300,LocalPlayer()
	Frame:SetPos(110,30)
	Frame:SetSize(W,H-30)
	Frame.OnClose=function()
		if resFrame then resFrame:Close() end
		if motherFrame then motherFrame:Close() end
	end
	function Frame:Paint(w,h)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
	end
	local Categories={}
	for k,v in pairs(Buildables)do
		local Category=v[5] or "Other"
		Categories[Category]=Categories[Category] or {}
		Categories[Category][k]=v
	end
	local X,ActiveTab=10,table.GetKeys(Categories)[1]
	local TabPanel=vgui.Create("DPanel",Frame)
	TabPanel:SetPos(10,30)
	TabPanel:SetSize(W-20,H-70)
	function TabPanel:Paint(w,h)
		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,0,w,h)
	end
	PopulateRecipes(TabPanel,Categories[ActiveTab],Kit,motherFrame,"buildkit")
	for k,cat in pairs(Categories)do
		local TabBtn=vgui.Create("DButton",Frame)
		TabBtn:SetPos(X,10)
		TabBtn:SetSize(70,20)
		TabBtn:SetText("")
		TabBtn.Category=k
		function TabBtn:Paint(x,y)
			surface.SetDrawColor(0,0,0,(ActiveTab==self.Category and 100)or 50)
			surface.DrawRect(0,0,x,y)
			draw.SimpleText(self.Category,"DermaDefault",35,10,Color(255,255,255,(ActiveTab==self.Category and 255)or 50),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		function TabBtn:DoClick()
			ActiveTab=self.Category
			PopulateRecipes(TabPanel,Categories[ActiveTab],Kit,motherFrame,"buildkit")
		end
		X=X+75
	end
	-- Resource display
	local resFrame = vgui.Create("DPanel", motherFrame)
	resFrame:SetSize(95, 270)
	resFrame:SetPos(10,30)
	function resFrame:Paint(w,h)
		draw.SimpleText("Resources:","DermaDefault",7,7,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
		
	end
	local resLayout = vgui.Create("DListLayout", resFrame)
	resLayout:SetPos(5, 25)
	resLayout:SetSize(90, 270)
	
	for typ, amt in pairs(resTbl) do
		local label = vgui.Create("DLabel")
		label:SetText( string.upper(string.Left(typ, 1)) .. string.lower(string.sub(typ, 2)) .. ": " .. amt)
		label:SetContentAlignment(4)
		resLayout:Add(label)
	end
end)
net.Receive("JMod_EZworkbench",function()
	local Bench=net.ReadEntity()
	local Buildables=net.ReadTable()
	local resTbl = JMod.CountResourcesInRange(nil,nil,Bench)
	local motherFrame = vgui.Create("DFrame")
	motherFrame:SetSize(620, 310)
	motherFrame:SetVisible(true)
	motherFrame:SetDraggable(true)
	motherFrame:ShowCloseButton(true)
	motherFrame:SetTitle("Workbench")
	function motherFrame:Paint()
		BlurBackground(self)
	end
	motherFrame:MakePopup()
	motherFrame:Center()
	function motherFrame:OnKeyCodePressed(key)
		if key==KEY_Q or key==KEY_ESCAPE or key == KEY_E then self:Close() end
	end
	
	local Frame,W,H,Myself=vgui.Create("DPanel", motherFrame),500,300,LocalPlayer()
	Frame:SetPos(110,30)
	Frame:SetSize(W,H-30)
	Frame.OnClose=function()
		if resFrame then resFrame:Close() end
		if motherFrame then motherFrame:Close() end
	end
	function Frame:Paint(w,h)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
	end
	local Categories={}
	for k,v in pairs(Buildables)do
		local Category=v[3] or "Other"
		Categories[Category]=Categories[Category] or {}
		Categories[Category][k]=v
	end
	
	local X,ActiveTab=10,table.GetKeys(Categories)[1]
	local TabPanel=vgui.Create("DPanel",Frame)
	TabPanel:SetPos(10,30)
	TabPanel:SetSize(W-20,H-70)
	function TabPanel:Paint(w,h)
		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,0,w,h)
	end
	PopulateRecipes(TabPanel,Categories[ActiveTab],Bench,motherFrame,"workbench")
	for k, cat in pairs (Categories) do
		local TabBtn=vgui.Create("DButton",Frame)
		TabBtn:SetPos(X,10)
		TabBtn:SetSize(70,20)
		TabBtn:SetText("")
		TabBtn.Category=k
		function TabBtn:Paint(x,y)
			surface.SetDrawColor(0,0,0,(ActiveTab==self.Category and 100)or 50)
			surface.DrawRect(0,0,x,y)			
			draw.SimpleText(self.Category,"DermaDefault",35,10,Color(255,255,255,(ActiveTab==self.Category and 255)or 50),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		function TabBtn:DoClick()
			ActiveTab=self.Category
			PopulateRecipes(TabPanel,Categories[ActiveTab],Bench,motherFrame,"workbench")
		end
		X=X+75
	end
	
	-- Resource display
	local resFrame = vgui.Create("DPanel", motherFrame)
	resFrame:SetSize(95, 270)
	resFrame:SetPos(10,30)
	function resFrame:Paint(w,h)
		draw.SimpleText("Resources:","DermaDefault",7,7,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
	end
	local resLayout = vgui.Create("DListLayout", resFrame)
	resLayout:SetPos(5, 25)
	resLayout:SetSize(90, 270)
	
	for typ, amt in pairs(resTbl) do
		local label = vgui.Create("DLabel")
		label:SetText( string.upper(string.Left(typ, 1)) .. string.lower(string.sub(typ, 2)) .. ": " .. amt)
		label:SetContentAlignment(4)
		resLayout:Add(label)
	end
end)
net.Receive("JMod_UniCrate",function()
	local box=net.ReadEntity()
	local items=net.ReadTable()
	local frame=vgui.Create("DFrame")
	frame:SetSize(200, 300)
	frame:SetTitle("Storage Crate")
	frame:Center()
	frame:MakePopup()
	frame.OnClose=function() frame=nil end
	frame.Paint=function(self, w, h) BlurBackground(self) end
	local scrollPanel=vgui.Create("DScrollPanel", frame)
	scrollPanel:SetSize(190, 270)
	scrollPanel:SetPos(5, 30)
	local layout=vgui.Create("DIconLayout", scrollPanel)
	layout:SetSize(190, 270)
	layout:SetPos(0, 0)
	layout:SetSpaceY(5)
	for class, tbl in pairs(items) do
		local sent=scripted_ents.Get(class)
		local button=vgui.Create("DButton", layout)
		button:SetSize(190, 25)
		button:SetText("")
		function button:Paint(w,h)
			surface.SetDrawColor(50,50,50,100)
			surface.DrawRect(0,0,w,h)
			local msg=sent.PrintName .. " x" .. tbl[1] .. " (" .. (tbl[2] * tbl[1]) .. " volume)"
			draw.SimpleText(msg,"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		end
		button.DoClick=function()
			net.Start("JMod_UniCrate")
				net.WriteEntity(box)
				net.WriteString(class)
			net.SendToServer()
			frame:Close()
		end
	end
end)
net.Receive("JMod_EZtimeBomb",function()
	local ent=net.ReadEntity()
	local frame=vgui.Create("DFrame")
	frame:SetSize(300,120)
	frame:SetTitle("Time Bomb")
	frame:SetDraggable(true)
	frame:Center()
	frame:MakePopup()
	function frame:Paint()
		BlurBackground(self)
	end
	local bg=vgui.Create("DPanel",frame)
	bg:SetPos(90,30)
	bg:SetSize(200,25)
	function bg:Paint(w,h)
		surface.SetDrawColor(Color(255,255,255,100))
		surface.DrawRect(0,0,w,h)
	end
	local tim=vgui.Create("DNumSlider",frame)
	tim:SetText("Set Time")
	tim:SetSize(280,20)
	tim:SetPos(10,30)
	tim:SetMin(10)
	tim:SetMax(600)
	tim:SetValue(10)
	tim:SetDecimals(0)
	local apply=vgui.Create("DButton",frame)
	apply:SetSize(100, 30)
	apply:SetPos(100, 75)
	apply:SetText("ARM")
	apply.DoClick=function()
		net.Start("JMod_EZtimeBomb")
		net.WriteEntity(ent)
		net.WriteInt(tim:GetValue(),16)
		net.SendToServer()
		frame:Close()
	end
end)
local function GetAvailPts(specs)
	local Pts=0
	for k,v in pairs(specs)do
		Pts=Pts-v
	end
	return Pts
end
net.Receive("JMod_ModifyMachine",function()
	local Ent=net.ReadEntity()
	local Specs=net.ReadTable()
	local AmmoTypes,AmmoType,AvailPts=nil,nil,GetAvailPts(Specs)
	local ErrorTime=0
	if(tobool(net.ReadBit()))then
		AmmoTypes=net.ReadTable()
		AmmoType=net.ReadString()
	end
	---
	local frame=vgui.Create("DFrame")
	frame:SetSize(600,400)
	frame:SetTitle("Modify Machine")
	frame:SetDraggable(true)
	frame:Center()
	frame:MakePopup()
	function frame:Paint()
		BlurBackground(self)
	end
	local bg=vgui.Create("DPanel",frame)
	bg:SetPos(10,30)
	bg:SetSize(580,360)
	function bg:Paint(w,h)
		surface.SetDrawColor(Color(0,0,0,100))
		surface.DrawRect(0,0,w,h)
	end
	local X,Y=10,10
	for attrib,value in pairs(Specs)do
		local Panel=vgui.Create("DPanel",bg)
		Panel:SetPos(X,Y)
		Panel:SetSize(275,40)
		function Panel:Paint(w,h)
			surface.SetDrawColor(0,0,0,100)
			surface.DrawRect(0,0,w,h)
			draw.SimpleText(attrib..": "..Specs[attrib],"DermaDefault",137,10,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
		end
		local MinButt=vgui.Create("DButton",Panel)
		MinButt:SetPos(10,10)
		MinButt:SetSize(20,20)
		MinButt:SetText("-")
		function MinButt:DoClick()
			Specs[attrib]=math.Clamp(Specs[attrib]-1,-10,10)
			AvailPts=GetAvailPts(Specs)
		end
		local MaxButt=vgui.Create("DButton",Panel)
		MaxButt:SetPos(245,10)
		MaxButt:SetSize(20,20)
		MaxButt:SetText("+")
		function MaxButt:DoClick()
			if(AvailPts>0)then
				Specs[attrib]=math.Clamp(Specs[attrib]+1,-10,10)
				AvailPts=GetAvailPts(Specs)
			end
		end
		Y=Y+50
		if(Y>=300)then X=X+285;Y=10 end
	end
	local Display=vgui.Create("DPanel",bg)
	Display:SetSize(600,40)
	Display:SetPos(100,315)
	function Display:Paint()
		local Col=(ErrorTime>CurTime() and Color(255,0,0,255))or Color(255,255,255,255)
		draw.SimpleText("Available spec points: "..AvailPts,"DermaDefault",250,0,Col,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("Trade traits to achieve desired performance","DermaDefault",250,20,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	end
	local Apply=vgui.Create("DButton",bg)
	Apply:SetSize(100,40)
	Apply:SetPos(240,310)
	Apply:SetText("Accept")
	function Apply:DoClick()
		if(AvailPts>0)then
			ErrorTime=CurTime()+1
			return
		end
		net.Start("JMod_ModifyMachine")
		net.WriteEntity(Ent)
		net.WriteTable(Specs)
		if(AmmoTypes)then
			net.WriteBit(true)
			net.WriteString(AmmoType)
		else
			net.WriteBit(false)
		end
		net.SendToServer()
		frame:Close()
	end
	if(AmmoTypes)then
		local DComboBox=vgui.Create("DComboBox",bg)
		DComboBox:SetPos(10,320)
		DComboBox:SetSize(150,20)
		DComboBox:SetValue(AmmoType)
		for k,v in pairs(AmmoTypes)do DComboBox:AddChoice(k) end
		function DComboBox:OnSelect(index,value)
			AmmoType=value
		end
	end
end)
net.Receive("JMod_EZradio",function()
	local isMessage = net.ReadBool()	
	if isMessage then
		local parrot = net.ReadBool()
		local msg = net.ReadString()
		local radio = net.ReadEntity()
		local tbl = {radio:GetColor(), "Aid Radio", Color(255,255,255), ": ", msg}
		if parrot then tbl = {Color(200,200,200), "(HIDDEN) ", LocalPlayer(), Color(255,255,255), ": ", Color(200,200,200), msg} end
		chat.AddText(unpack(tbl))

		if LocalPlayer():GetPos():DistToSqr(radio:GetPos()) > 200 * 200 then
			local radiovoices = file.Find("sound/npc/combine_soldier/vo/*.wav","GAME")
			for i=1, math.Round(string.len(msg)/15) do
				timer.Simple(i*.75,function()
					if((IsValid(radio))and(radio:GetState()>0))then
						LocalPlayer():EmitSound("/npc/combine_soldier/vo/" .. radiovoices[math.random(1,#radiovoices)],65,120,0.25)
					end
				end)
			end
		end

		return
	end

	local Packages={}
	local count = net.ReadUInt(8)
	for i = 1, count do
		table.insert(Packages, {net.ReadString(),net.ReadString()})
	end

	local Radio=net.ReadEntity()
	local StatusText = net.ReadString()
	
	local motherFrame = vgui.Create("DFrame")
	motherFrame:SetSize(320, 310)
	motherFrame:SetVisible(true)
	motherFrame:SetDraggable(true)
	motherFrame:ShowCloseButton(true)
	motherFrame:SetTitle("Aid Radio")
	function motherFrame:Paint()
		BlurBackground(self)
	end
	motherFrame:MakePopup()
	motherFrame:Center()
	function motherFrame:OnKeyCodePressed(key)
		if key==KEY_Q or key==KEY_ESCAPE or key == KEY_E then self:Close() end
	end
	
	local Frame,W,H,Myself=vgui.Create("DPanel", motherFrame),200,300,LocalPlayer()
	Frame:SetPos(110,30)
	Frame:SetSize(W,H-30)
	Frame.OnClose=function()
		if resFrame then resFrame:Close() end
		if motherFrame then motherFrame:Close() end
	end
	function Frame:Paint(w,h)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
	end
	
	local StatusButton=vgui.Create("DButton", motherFrame)
	StatusButton:SetSize(90,30)
	StatusButton:SetPos(10,40)
	StatusButton:SetText("")
	function StatusButton:Paint(w,h)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText("Status","DermaDefault",45,15,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function StatusButton:DoClick()
		LocalPlayer():ConCommand("say supply radio: status")
		motherFrame:Close()
	end

	local Scroll=vgui.Create("DScrollPanel",Frame)
	Scroll:SetSize(W-15,H-10)
	Scroll:SetPos(10,10)
	---
	for _, k in pairs(Packages) do
		local Butt = Scroll:Add("DButton")
		local desc=k[2] or "N/A"
		Butt:SetSize(W-35,25)
		Butt:Dock(TOP)
		Butt:DockMargin( 0, 0, 0, 5 )
		Butt:SetText("")
		Butt:SetToolTip(desc)	
		function Butt:Paint(w,h)
			surface.SetDrawColor(50,50,50,100)
			surface.DrawRect(0,0,w,h)
			local msg=k[1]		
			draw.SimpleText(msg,"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		end
		function Butt:DoClick()
			LocalPlayer():ConCommand("say supply radio: " .. k[1] .. "")
			motherFrame:Close()
		end
	end
	-- The last one always gets cut off so instead of finding the reason let's just slap a filler on
	local Butt = Scroll:Add("DButton")
	Butt:SetSize(W-35,25)
	Butt:Dock(TOP)
	Butt:DockMargin( 0, 0, 0, 5 )
	Butt:SetText("")
end)
local function GetItemInSlot(armorTable,slot)
	if not(armorTable and armorTable.items)then return nil end
	for id,armorData in pairs(armorTable.items)do
		local ArmorInfo=JMod.ArmorTable[armorData.name]
		if(ArmorInfo.slots[slot])then
			return id,armorData,ArmorInfo
		end
	end
	return nil
end
local ArmorSlotButtons={
	{
		title="Drop",
		actionFunc=function(slot,itemID,itemData,itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(1,8) -- drop
			net.WriteString(itemID)
			net.SendToServer()
		end
	},
	{
		title="Toggle",
		visTestFunc=function(slot,itemID,itemData,itemInfo)
			return itemInfo.tgl
		end,
		actionFunc=function(slot,itemID,itemData,itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(2,8) -- toggle
			net.WriteString(itemID)
			net.SendToServer()
		end
	},
	{
		title="Repair",
		visTestFunc=function(slot,itemID,itemData,itemInfo)
			return itemData.dur<itemInfo.dur*.9
		end,
		actionFunc=function(slot,itemID,itemData,itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(3,8) -- repair
			net.WriteString(itemID)
			net.SendToServer()
		end
	},
	{
		title="Recharge",
		visTestFunc=function(slot,itemID,itemData,itemInfo)
			if(itemInfo.chrg)then
				for resource,maxAmt in pairs(itemInfo.chrg)do
					if(itemData.chrg[resource]<maxAmt)then return true end
				end
			end
			return false
		end,
		actionFunc=function(slot,itemID,itemData,itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(4,8) -- recharge
			net.WriteString(itemID)
			net.SendToServer()
		end
	}
}
local ArmorResourceNiceNames={
	chemicals="Chemicals",
	power="Electricity"
}
local OpenDropdown=nil
local function CreateArmorSlotButton(parent,slot,x,y)
	local Buttalony,Ply=vgui.Create("DButton",parent),LocalPlayer()
	Buttalony:SetSize(180,40)
	Buttalony:SetPos(x,y)
	Buttalony:SetText("")
	Buttalony:SetCursor("hand")
	local ItemID,ItemData,ItemInfo=GetItemInSlot(Ply.EZarmor,slot)
	function Buttalony:Paint(w,h)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText(JMod.ArmorSlotNiceNames[slot],"DermaDefault",Buttalony:GetWide()/2,10,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		if(ItemID)then
			local Str=ItemData.name--..": "..math.Round(ItemData.dur/ItemInfo.dur*100).."%"
			if(ItemData.tgl and ItemInfo.tgl.slots[slot]==0)then Str="DISENGAGED" end
			draw.SimpleText(Str,"DermaDefault",Buttalony:GetWide()/2,25,Color(200,200,200,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
	if(ItemID)then
		local str="Durability: "..math.Round(ItemData.dur,1).."/"..ItemInfo.dur
		if(ItemInfo.chrg)then
			for resource,maxAmt in pairs(ItemInfo.chrg)do
				str=str.."\n"..ArmorResourceNiceNames[resource]..": "..math.Round(ItemData.chrg[resource],1).."/"..maxAmt
			end
		end
		Buttalony:SetTooltip(str)
	else
		Buttalony:SetTooltip("slot is empty")
	end
	function Buttalony:DoClick()
		if(OpenDropdown)then OpenDropdown:Remove() end
		if not(ItemID)then return end
		local Options={}
		for k,option in pairs(ArmorSlotButtons)do
			if(not(option.visTestFunc)or(option.visTestFunc(slot,ItemID,ItemData,ItemInfo)))then
				table.insert(Options,option)
			end
		end
		local Dropdown=vgui.Create("DPanel",parent)
		Dropdown:SetSize(Buttalony:GetWide(),#Options*40)
		local ecks,why=gui.MousePos()
		local harp,darp=parent:GetPos()
		local fack,fock=parent:GetSize()
		local floop,florp=Dropdown:GetSize()
		Dropdown:SetPos(math.Clamp(ecks-harp,0,fack-floop),math.Clamp(why-darp,0,fock-florp))
		function Dropdown:Paint(w,h)
			surface.SetDrawColor(70,70,70,220)
			surface.DrawRect(0,0,w,h)
		end
		for k,option in pairs(Options)do
			local Butt=vgui.Create("DButton",Dropdown)
			Butt:SetPos(5,k*40-35)
			Butt:SetSize(floop-10,30)
			Butt:SetText(option.title)
			function Butt:DoClick()
				option.actionFunc(slot,ItemID,ItemData,ItemInfo)
				parent:Close()
			end
		end
		OpenDropdown=Dropdown
	end
end
net.Receive("JMod_Inventory",function()
	local Ply=LocalPlayer()
	local motherFrame=vgui.Create("DFrame")
	motherFrame:SetSize(600,400)
	motherFrame:SetVisible(true)
	motherFrame:SetDraggable(true)
	motherFrame:ShowCloseButton(true)
	motherFrame:SetTitle("Inventory")
	function motherFrame:Paint()
		BlurBackground(self)
	end
	motherFrame:MakePopup()
	motherFrame:Center()
	function motherFrame:OnKeyCodePressed(key)
		if key==KEY_Q or key==KEY_ESCAPE or key == KEY_E then self:Close() end
	end
	function motherFrame:OnClose()
		if(OpenDropdown)then OpenDropdown:Remove() end
	end
	local PDispBG=vgui.Create("DPanel",motherFrame)
	PDispBG:SetPos(200,30)
	PDispBG:SetSize(200,360)
	function PDispBG:Paint(w,h)
		surface.SetDrawColor(50,50,50,100)
		surface.DrawRect(0,0,w,h)
	end
	local PlayerDisplay=vgui.Create("DModelPanel",PDispBG)
	PlayerDisplay:SetPos(0,0)
	PlayerDisplay:SetSize(PDispBG:GetWide(),PDispBG:GetTall())
	PlayerDisplay:SetModel(Ply:GetModel())
	PlayerDisplay:SetFOV(35)
	PlayerDisplay:SetCursor("arrow")
	local Ent=PlayerDisplay:GetEntity()
	if(Ply.EZarmor.suited and Ply.EZarmor.bodygroups)then
		PlayerDisplay:SetColor(Ply:GetColor())
		for k,v in pairs(Ply.EZarmor.bodygroups)do
			Ent:SetBodygroup(k,v)
		end
	end
	function PlayerDisplay:PostDrawModel(ent)
		ent.EZarmor=Ply.EZarmor
		JMod.ArmorPlayerModelDraw(ent)
	end
	function PlayerDisplay:DoClick()
		if(OpenDropdown)then OpenDropdown:Remove() end
	end
	---
	CreateArmorSlotButton(motherFrame,"head",10,30)
	CreateArmorSlotButton(motherFrame,"eyes",10,75)
	CreateArmorSlotButton(motherFrame,"mouthnose",10,120)
	CreateArmorSlotButton(motherFrame,"ears",10,165)
	CreateArmorSlotButton(motherFrame,"leftshoulder",10,210)
	CreateArmorSlotButton(motherFrame,"leftforearm",10,255)
	CreateArmorSlotButton(motherFrame,"leftthigh",10,300)
	CreateArmorSlotButton(motherFrame,"leftcalf",10,345)
	---
	CreateArmorSlotButton(motherFrame,"rightshoulder",410,30)
	CreateArmorSlotButton(motherFrame,"rightforearm",410,75)
	CreateArmorSlotButton(motherFrame,"chest",410,120)
	CreateArmorSlotButton(motherFrame,"back",410,165)
	CreateArmorSlotButton(motherFrame,"pelvis",410,210)
	CreateArmorSlotButton(motherFrame,"rightthigh",410,255)
	CreateArmorSlotButton(motherFrame,"rightcalf",410,300)
end)