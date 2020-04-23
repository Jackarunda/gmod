include('shared.lua')
ENT.AutomaticFrameAdvance=true 
local PVS_NOTHING=0
local PVS_UNFOLDING=1
local PVS_HOVERING=2
local PVS_FOLDING=3
local PVS_RECHARGING=4
local PVS_SWIMMING=5
function ENT:Initialize()
	self.RotorGuard=ClientsideModel("models/holograms/hq_torus_thin.mdl")
	self.RotorGuard:SetAngles(self:GetAngles())
	self.RotorGuard:SetModelScale(4,0)
	self.RotorGuard:SetParent(self)
	self.RotorGuard:SetNoDraw(true)
	self.Camera=ClientsideModel("models/beer/wiremod/hydraulic_nano.mdl")
	self.Camera:SetAngles(self:GetUp():Angle())
	self.Camera:SetParent(self)
	self.Camera:SetNoDraw(true)
	self.Camera2=ClientsideModel("models/beer/wiremod/hydraulic_nano.mdl")
	self.Camera2:SetAngles(-self:GetUp():Angle())
	self.Camera2:SetParent(self)
	self.Camera2:SetNoDraw(true)
	self.Pistol=ClientsideModel("models/weapons/w_pist_fiveseven.mdl")
	self.Pistol:SetParent(self)
	self.Pistol:SetNoDraw(true)
	self.Pistol:SetModelScale(1.25,0)
	self.CameraRot=0
	-- why do I have to do this? Fix your broken-ass shit Garry
	local Dude=self
	local TName="JackieManualDraw"..tostring(Dude:EntIndex())
	timer.Create(TName,1,0,function()
		if(IsValid(Dude))then
			Dude:Draw()
		else
			timer.Destroy(TName)
		end
	end)
end
function ENT:Draw()
	local Up=self:GetUp()
	local Pos=self:GetPos()
	local Forward=self:GetForward()
	self.RotorGuard:SetRenderOrigin(Pos-Up*1.05)
	self.Camera:SetRenderOrigin(Pos+Up*6)
	self.Camera2:SetRenderOrigin(Pos+Up*6)
	self.Pistol:SetRenderOrigin(Pos+Up-Forward*2)
	local Ang=self:GetAngles()
	local Ang3=self:GetAngles()
	self.RotorGuard:SetRenderAngles(Ang)
	Ang:RotateAroundAxis(Ang:Right(),90)
	Ang:RotateAroundAxis(Ang:Forward(),self.CameraRot)
	self.Camera:SetRenderAngles(Ang)
	Ang:RotateAroundAxis(Ang:Forward(),180)
	self.Camera2:SetRenderAngles(Ang)
	Ang3:RotateAroundAxis(Ang3:Forward(),180)
	Ang3:RotateAroundAxis(Ang3:Right(),self:GetDTInt(1))
	self.Pistol:SetRenderAngles(Ang3)
	self.Camera:DrawModel()
	self.Camera2:DrawModel()
	self.Pistol:DrawModel()
	self:DrawModel()
	self.RotorGuard:DrawModel()
	local St=self:GetDTInt(0)
	if((St==PVS_HOVERING)or(St==PVS_SWIMMING))then
		self.CameraRot=self.CameraRot+2
		if(self.CameraRot>360)then self.CameraRot=0 end
	end
end
function ENT:OnRemove()
	self.RotorGuard:Remove()
end