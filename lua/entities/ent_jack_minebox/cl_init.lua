
include('shared.lua')

function ENT:Initialize()
	local Pos=self:GetPos()
	local Up=self:GetUp()
	local Right=self:GetRight()
	local Forward=self:GetForward()

	self.Junk=ClientsideModel("models/props/CS_militia/food_stack.mdl")
	self.Junk:SetPos(Pos+Up*-5+Right*15)
	self.Junk:SetAngles(Right:Angle())
	self.Junk:SetParent(self)
	self.Junk:SetNoDraw(true)
	
	self.MineTable={}
	for i=1,35 do
		self.MineTable[i]=ClientsideModel("models/props_pipes/pipe02_connector01.mdl")
		self.MineTable[i]:SetMaterial("models/jacky_camouflage/Digi")
		self.MineTable[i]:SetPos(Pos+Up*i*.4-Up*8+Right*math.Rand(-18,18)+Forward*math.Rand(-6,6))
		self.MineTable[i]:SetAngles(Up:Angle())
		self.MineTable[i]:SetParent(self)
		self.MineTable[i]:SetNoDraw(true)
	end
end

function ENT:Draw()
	local Matricks=Matrix()
	Matricks:Scale(Vector(.15,.37,.2))
	self.Junk:EnableMatrix("RenderMultiply",Matricks)
	render.SetColorModulation(.4,.4,.4)
	self.Junk:DrawModel()
	
	render.SetColorModulation(.7,.7,.7)
	for key,disc in pairs(self.MineTable)do disc:DrawModel() end
	
	render.SetColorModulation(1,1,1)
	self.Entity:DrawModel()
end

function ENT:OnRemove()

end

language.Add("ent_jack_minebox","Box of Landmines")
//killicon.Add("ent_jack_c4block","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))
