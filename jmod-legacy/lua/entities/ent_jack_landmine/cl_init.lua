
include('shared.lua')

function ENT:Initialize()

end

function ENT:Draw()
	--local Matricks=Matrix()
	--Matricks:Scale(Vector(.85,.85,.85))
	--self:EnableMatrix("RenderMultiply",Matricks)
	self.Entity:DrawModel()
end

function ENT:OnRemove()

end

killicon.Add("ent_jack_landmine","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))

language.Add("ent_jack_landmine","Landmine")




