
include('shared.lua')

function ENT:Initialize()
	self.Nice=ClientsideModel("models/props_phx/ww2bomb.mdl")
	self.Nice:SetMaterial("models/entities/mat_jack_heatbomb")
	self.Nice:SetPos(self:GetPos()-self:GetUp()*6)
	self.Nice:SetAngles(self:GetAngles())
	self.Nice:SetParent(self)
	self.Nice:SetNoDraw(true)
end

function ENT:Draw()
	local Matricks=Matrix()
	Matricks:Scale(Vector(.45,1,1))
	self.Nice:EnableMatrix("RenderMultiply",Matricks)
	self.Nice:SetRenderOrigin(self:GetPos()-self:GetUp()*6)
	self.Nice:SetRenderAngles(self:GetAngles())
	self.Nice:DrawModel()
	--self.Entity:DrawModel()
end

function ENT:OnRemove()
end
language.Add("ent_jack_heatbomb","H.E.A.T. Bomb")
killicon.Add("ent_jack_heatbomb","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))



