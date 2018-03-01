include('shared.lua')
function ENT:Initialize()
	--herp
end
function ENT:Draw()
	self:DrawModel()
end
function ENT:OnRemove()
	-- we all have struggles
end
language.Add("ent_jack_slam","M2 SLAM")