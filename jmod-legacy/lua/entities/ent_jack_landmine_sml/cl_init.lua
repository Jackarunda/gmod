include('shared.lua')
function ENT:Initialize()
	self.Pin=ClientsideModel("models/props_trainstation/mount_connection001a.mdl")
	self.Pin:SetPos(self:GetPos())
	self.Pin:SetParent(self)
	self.Pin:SetModelScale(.1,0)
	self.Pin:SetNoDraw(true)
end
function ENT:Draw()
	--local Matricks=Matrix()
	--Matricks:Scale(Vector(.85,.85,.85))
	--self:EnableMatrix("RenderMultiply",Matricks)
	self.Entity:DrawModel()
	self.Pin:SetRenderOrigin(self:GetPos()+self:GetRight()*4-self:GetForward()*1)
	local Ang=self:GetAngles()
	Ang:RotateAroundAxis(Ang:Right(),90)
	Ang:RotateAroundAxis(Ang:Up(),90)
	Ang:RotateAroundAxis(Ang:Forward(),180)
	self.Pin:SetRenderAngles(Ang)
	render.SetColorModulation(.2,.2,.2)
	if not(self:GetDTBool(0))then
		self.Pin:DrawModel()
	end
end
function ENT:OnRemove()
	-- slimy homosexual
end
language.Add("ent_jack_landmine_sml","Landmine")




