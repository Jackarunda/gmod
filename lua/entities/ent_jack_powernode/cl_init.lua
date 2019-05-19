//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
function ENT:Initialize()
	--
end
function ENT:Draw()
	self.Entity:DrawModel()
end
function ENT:OnRemove()
	--
end
language.Add("ent_jack_powernode","Electrical Power Hub")