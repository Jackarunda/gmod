
include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()

	self.Entity:DrawModel()

end

function ENT:OnRemove()

end

language.Add("ent_jack_c4block","M112 Demolition Block")
killicon.Add("ent_jack_c4block","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))
