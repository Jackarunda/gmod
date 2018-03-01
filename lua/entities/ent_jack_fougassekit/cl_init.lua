include('shared.lua')
function ENT:Initialize()
	self:SetModelScale(.7,0)
end
function ENT:Draw()
	self.Entity:DrawModel()
end
function ENT:OnRemove()
	--carpetlicker
end
language.Add("ent_jack_fougassekit","Flame Fougasse Kit")