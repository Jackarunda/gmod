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
language.Add("ent_jack_ballistic_shield","Ballistic Shield")