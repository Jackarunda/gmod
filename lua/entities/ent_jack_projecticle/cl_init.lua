include('shared.lua')

language.Add("ent_jack_projecticle", "Ice Projectile")

killicon.Add("ent_jack_projecticle","vgui/mat_jack_projecticle_ki",Color(255,255,255,255))

function ENT:Initialize()
	self.GotStuckInSomethin=false
end

function ENT:Draw()
	local Size=self:GetDTFloat(0)/90
	
	//apparently, gmod13 did away with SetModelScale()...
	local Mat=Matrix()
	Mat:Scale(Vector(Size*1.25,Size/2,Size/2))
	self.Entity:EnableMatrix("RenderMultiply",Mat)
	
	self.Entity:DrawModel()
end

function ENT:Think()
	//do nothing
end