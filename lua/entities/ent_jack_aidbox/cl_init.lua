//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
function ENT:Initialize()
	--herp
end
function ENT:Draw()
	render.SetBlend(self:GetDTFloat(0))
	self.Entity:DrawModel()
	render.SetBlend(1)
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_aidbox","J.I. Aid Package")