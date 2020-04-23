
include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	local Matricks=Matrix()
	Matricks:Scale(Vector(.8,1.2,1.2))
	self:EnableMatrix("RenderMultiply",Matricks)
	self.Entity:DrawModel()
end

function ENT:OnRemove()
end

language.Add("ent_jack_bomblet","Bomblet")
killicon.Add("ent_jack_bomblet","vgui/killicons/ent_jack_plastisplosion_ki",Color(255,255,255))



