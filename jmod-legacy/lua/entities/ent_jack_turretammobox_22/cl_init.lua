//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
ENT.Base="ent_jack_turretammobox_base"
function ENT:Initialize()
	--wat
end
function ENT:Draw()
	self.Entity:DrawModel()
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_ammobox_22",".22LR AmmoBox")