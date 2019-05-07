
include('shared.lua')

function ENT:Initialize()
	self.Junk=ClientsideModel("models/props/CS_militia/food_stack.mdl")
	self.Junk:SetPos(self:GetPos()+self:GetUp()*-3+self:GetRight()*-1.5)
	self.Junk:SetAngles(self:GetRight():Angle())
	self.Junk:SetParent(self)
	self.Junk:SetNoDraw(true)
end

function ENT:Draw()
	local Matricks=Matrix()
	Matricks:Scale(Vector(.45,.37,.2))
	self.Junk:EnableMatrix("RenderMultiply",Matricks)
	render.SetColorModulation(.4,.4,.4)
	self.Junk:DrawModel()
	render.SetColorModulation(1,1,1)
	self.Junk:SetRenderOrigin(self:GetPos()+self:GetUp()*-3+self:GetRight()*-1.5)
	self.Junk:SetRenderAngles(self:GetRight():Angle())
	self.Entity:DrawModel()
end

function ENT:OnRemove()

end

language.Add("ent_jack_detgear","Box of Fuzing Equipment")
//killicon.Add("ent_jack_c4block","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))
