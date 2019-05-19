
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
		local X,Y,Z=math.Rand(-18,18),math.Rand(-6,6),i*.4
		self.MineTable[i]=ClientsideModel("models/props_pipes/pipe02_connector01.mdl")
		self.MineTable[i]:SetMaterial("models/jacky_camouflage/Digi")
		self.MineTable[i]:SetPos(Pos+Up*Z-Up*8+Right*X+Forward*Y)
		self.MineTable[i]:SetAngles(Up:Angle())
		self.MineTable[i]:SetParent(self)
		self.MineTable[i]:SetNoDraw(true)
		self.MineTable[i].DrawX=X
		self.MineTable[i].DrawY=Y
		self.MineTable[i].DrawZ=Z
		--self.MineTable[i] -- TODO: the mines lose their connection to the box if ever un-rendered, fix this somehow
	end
end

function ENT:Draw()
	local Pos=self:GetPos()
	local Up=self:GetUp()
	local Right=self:GetRight()
	local Forward=self:GetForward()
	local Matricks=Matrix()
	Matricks:Scale(Vector(.15,.37,.2))
	self.Junk:EnableMatrix("RenderMultiply",Matricks)
	render.SetColorModulation(.4,.4,.4)
	self.Junk:SetRenderOrigin(Pos+Up*-5+Right*15)
	self.Junk:SetRenderAngles(Right:Angle())
	self.Junk:DrawModel()
	
	render.SetColorModulation(.7,.7,.7)
	for key,disc in pairs(self.MineTable)do
		disc:SetRenderOrigin(Pos+Up*disc.DrawZ-Up*8+Right*disc.DrawX+Forward*disc.DrawY)
		disc:SetRenderAngles(Up:Angle())
		disc:DrawModel()
	end
	
	render.SetColorModulation(1,1,1)
	self.Entity:DrawModel()
end

function ENT:OnRemove()

end

language.Add("ent_jack_minebox","Box of Landmines")
//killicon.Add("ent_jack_c4block","vgui/killicons/ent_jack_plastisplosion_KI",Color(255,255,255,255))
