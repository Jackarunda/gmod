//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
function ENT:Initialize()
	self.Inside=ClientsideModel("models/props/cs_office/Cardboard_box03.mdl")
	self.Inside:SetPos(self:GetPos())
	self.Inside:SetParent(self)
	self.Inside:SetNoDraw(true)
	self.Inside:SetModelScale(.8,0)
end
function ENT:Draw()
	self.Inside:SetRenderOrigin(self:GetPos()+self:GetUp()*11)
	local Ang=self:GetAngles()
	Ang:RotateAroundAxis(Ang:Right(),180)
	self.Inside:SetRenderAngles(Ang)
	render.SetColorModulation(.5,.5,.5)
	self.Inside:DrawModel()
	render.SetColorModulation(1,1,1)
	self.Entity:DrawModel()
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_aidfood","J.I. Food Box")