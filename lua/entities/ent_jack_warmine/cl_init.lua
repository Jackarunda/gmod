include('shared.lua')
function ENT:Initialize()
	self.Warhead=ClientsideModel("models/props_wasteland/light_spotlight01_lamp.mdl")
	self.Warhead:SetPos(self:GetPos())
	self.Warhead:SetParent(self)
	self.Warhead:SetNoDraw(true)
	self.Warhead:SetMaterial("models/mat_jack_scratchedmetal")
end
function ENT:Draw()
	--local Matricks=Matrix()
	--Matricks:Scale(Vector(.85,.85,.85))
	--self:EnableMatrix("RenderMultiply",Matricks)
	local Ang=self:GetAngles()
	Ang:RotateAroundAxis(Ang:Right(),-90)
	self.Warhead:SetRenderOrigin(self:GetPos()+self:GetUp()*8-self:GetForward()*3.75+self:GetRight()*.25)
	self.Warhead:SetRenderAngles(Ang)
	self.Entity:DrawModel()
	self.Warhead:DrawModel()
end
function ENT:OnRemove()
	--wat
end
language.Add("ent_jack_landmine","Landmine")
--[[--------------------------------------------------------------
	I hate desiging UIs so damn much
---------------------------------------------------------------]]--
local function OpenMenu(data)
	local Tab={}
	Tab.Self=data:ReadEntity()
	Tab.Already=data:ReadBool()
	Tab.Self:OpenTheMenu(Tab)
end
usermessage.Hook("JackaWarMineOpenMenu",OpenMenu)
function ENT:OpenTheMenu(tab)
	local DermaPanel=vgui.Create("DFrame")
	DermaPanel:SetPos(40,80)
	DermaPanel:SetSize(125,185)
	DermaPanel:SetTitle("J.I. WarMine")
	DermaPanel:SetVisible(true)
	DermaPanel:SetDraggable(true)
	DermaPanel:ShowCloseButton(false)
	DermaPanel:MakePopup()
	DermaPanel:Center()

	local MainPanel=vgui.Create("DPanel",DermaPanel)
	MainPanel:SetPos(5,25)
	MainPanel:SetSize(112,152)
	MainPanel.Paint=function()
		surface.SetDrawColor(0,20,40,255)
		surface.DrawRect(0,0,MainPanel:GetWide(),MainPanel:GetTall()+3)
	end
	
	local exitbutton=vgui.Create("Button",MainPanel)
	exitbutton:SetSize(90,40)
	exitbutton:SetPos(10,15)
	exitbutton:SetText("Arm")
	exitbutton:SetVisible(true)
	exitbutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaWarMineArm",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local gobutton=vgui.Create("Button",MainPanel)
	gobutton:SetSize(90,40)
	gobutton:SetPos(10,60)
	if(tab.Already)then
		gobutton:SetText("DeSync IFF Tag")
	else
		gobutton:SetText("Sync IFF Tag")
	end
	gobutton:SetVisible(true)
	gobutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaWarMineSync",tostring(self:GetNetworkedInt("JackIndex")))
	end
	
	local nobutton=vgui.Create("Button",MainPanel)
	nobutton:SetSize(90,40)
	nobutton:SetPos(10,105)
	nobutton:SetText("Exit")
	nobutton:SetVisible(true)
	nobutton.DoClick=function()
		DermaPanel:Close()
		RunConsoleCommand("JackaWarMineExit",tostring(self:GetNetworkedInt("JackIndex")))
	end
end