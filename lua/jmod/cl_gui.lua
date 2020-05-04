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
        local canMake=builder:HaveResourcesToPerformTask(reqs)
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
            print(typ,"a")
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
    
    local resTbl = Kit:CountResourcesInRange()
    
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
    
    local resTbl = Bench:CountResourcesInRange()
    
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
        return
    end
    
    local Packages=net.ReadTable()
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
        local msg=k
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
    local Y=0
    for k,itemInfo in SortedPairs(Packages)do
        local Butt=Scroll:Add("DButton")
        Butt:SetSize(W-35,25)
        Butt:SetPos(0,Y)
        Butt:SetText("")

        function Butt:Paint(w,h)
            surface.SetDrawColor(50,50,50,100)
            surface.DrawRect(0,0,w,h)
            local msg=k
            draw.SimpleText(msg,"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
        end
        function Butt:DoClick()
            LocalPlayer():ConCommand("say supply radio: " .. k .. "")
            motherFrame:Close()
        end
        Y=Y+30
    end
    
end)