include('shared.lua')

language.Add("ent_jack_fgcartridge_energy", "Energy Cartridge")

function ENT:Initialize()
	if(self:GetDTBool(0))then
		self.AllUsedUp=true
		self.Light=DynamicLight(self:EntIndex())
		self.Heat=1
	end
end

function ENT:Draw()
	if(self.AllUsedUp)then
		render.SuppressEngineLighting(true)
		self.Entity:DrawModel()
		render.SuppressEngineLighting(false)
	else
		self.Entity:DrawModel()
	end
end

function ENT:Think()
	if not(self.AllUsedUp)then return end
	if(self.Light)then
		self.Light.MinLight=0
		self.Light.Pos=self:GetPos()
		self.Light.r=math.Clamp(self.Heat*463-69,0,255)
		self.Light.g=math.Clamp(self.Heat*1275-1020,0,255)
		self.Light.b=math.Clamp(self.Heat*2550-2295,0,255)
		self.Light.Brightness=2
		self.Light.Size=math.Clamp(self.Heat*300-150,0,150)
		self.Light.Decay=1000
		self.Light.DieTime=CurTime()+.2
		self.Light.Style=0
	end
	self.Heat=self.Heat-.001
	
	self:NextThink(CurTime()+.01)
	return true
end