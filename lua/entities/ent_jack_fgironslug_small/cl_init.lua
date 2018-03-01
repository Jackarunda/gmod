include('shared.lua')

language.Add("ent_jack_fgironslug_small","Small Iron Slug")

function ENT:Initialize()
	self:SetModel("models/Items/AR2_Grenade.mdl")
end

function ENT:Draw()
	local Mat=Matrix()
	Mat:Scale(Vector(.15,.15,.15))
	self:EnableMatrix("RenderMultiply",Mat)
	self.Entity:DrawModel()
end

function ENT:Think()
	//nothin
end