
include('shared.lua')

function ENT:Initialize()
	self.Nice=ClientsideModel("models/props_trainyard/distillery_barrel001.mdl")
	self.Nice:SetMaterial("models/entities/mat_jack_powderkeg")
	self.Nice:SetPos(self:GetPos())
	self.Nice:SetAngles(self:GetAngles())
	self.Nice:SetParent(self)
	self.Nice:SetNoDraw(true)
end

function ENT:Draw()
	local Matricks=Matrix()
	Matricks:Scale(Vector(.21,.21,.225))
	self.Nice:EnableMatrix("RenderMultiply",Matricks)
	self.Nice:DrawModel()
	--self.Entity:DrawModel()
end

function ENT:OnRemove()

end

language.Add("ent_jack_powderkeg","Black Powder Keg")
killicon.Add("ent_jack_powderkeg","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))
