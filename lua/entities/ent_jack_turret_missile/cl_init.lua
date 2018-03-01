//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
ENT.Base="ent_jack_turret_base"
language.Add("ent_jack_turret_missile","Missile Sentry")
ENT.AmmoPic="sprites/mat_jack_ammosprite_aim9x"
ENT.LabelText='AIM-9x Sidewinder-m "Missile Launcher"'
ENT.MechanicsSizeMod=2.2
local Burnt=Material("models/weapons/w_Rocket_jauncher/w_rpg_sheet_burnt")
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
	self.AmmoBox=ClientsideModel("models/weapons/w_rocket_jauncher.mdl")
	self.AmmoBox:SetMaterial("models/weapons/w_Rocket_jauncher/w_rpg_sheet_missile")
	self.AmmoBox:SetPos(self:GetPos())
	self.AmmoBox:SetParent(self)
	self.AmmoBox:SetNoDraw(true)
	self.Battery=ClientsideModel("models/Items/car_battery01.mdl")
	self.Battery:SetMaterial("models/mat_jack_turretbattery")
	self.Battery:SetPos(self:GetPos())
	self.Battery:SetParent(self)
	self.Battery:SetNoDraw(true)
	self.AmmoPicID=surface.GetTextureID(self.AmmoPic)
end
function ENT:Draw()
	local OrigR,OrigG,OrigB=render.GetColorModulation()
	local SelfPos=self:GetPos()
	local Up=self:GetUp()
	local Right=self:GetRight()
	local Forward=self:GetForward()
	self.Camera:SetRenderOrigin(SelfPos+Up*60.5-Right)
	self.CameraPost:SetRenderOrigin(SelfPos+Up*55-Right)
	self.Battery:SetRenderOrigin(SelfPos+Up*20+Right*4.5-Forward)
	local Ang=self:GetAngles()
	local AngTwo=Angle(Ang.p,Ang.y,Ang.r)
	local AngFour=Angle(Ang.p,Ang.y,Ang.r)
	local AngWholes=Angle(Ang.p,Ang.y,Ang.r)
	AngTwo:RotateAroundAxis(AngTwo:Forward(),90)
	self.CameraPost:SetRenderAngles(AngTwo)
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
	render.SetColorModulation(OrigR,OrigG,OrigB)
	local Pos,Ang=self:GetBonePosition(2)
	Ang:RotateAroundAxis(Ang:Up(),90)
	Ang:RotateAroundAxis(Ang:Right(),250)
	Ang:RotateAroundAxis(Ang:Forward(),90)
	Pos=Pos-Ang:Forward()*12
	Pos=Pos-Ang:Right()
	Pos=Pos-Ang:Up()*.2
	self.AmmoBox:SetRenderOrigin(Pos)
	self.AmmoBox:SetRenderAngles(Ang)
	if(self:GetDTBool(0))then
		render.SetColorModulation(1,1,1)
		if not(self:GetDTBool(2))then
			render.MaterialOverride(Burnt)
			self.AmmoBox:DrawModel()
			render.MaterialOverride(nil)
		else
			self.AmmoBox:DrawModel()
		end
		render.SetColorModulation(OrigR,OrigG,OrigB)
	end
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