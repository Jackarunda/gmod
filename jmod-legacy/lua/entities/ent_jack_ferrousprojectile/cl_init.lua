include('shared.lua')

language.Add("ent_jack_ferrousprojectile", "Iron Projectile")

killicon.Add("ent_jack_ferrousprojectile","vgui/mat_jack_ferrousprojectile_ki",Color(255,255,255,255))

function ENT:Initialize()
	if(self:GetDTBool(0))then
		self.Heat=1
		self.Hot=true
	end
end

function ENT:Draw()
	//apparently, gmod13 did away with SetModelScale()...
	local Scale=Vector(.1,.1,.1)
	if not(self.Hot)then Scale=Vector(1.5,1.5,1.5) end
	local Mat=Matrix()
	Mat:Scale(Scale)
	self.Entity:EnableMatrix("RenderMultiply",Mat)

	if(self.Hot)then
		local Heat=self.Heat
		local Red=math.Clamp(Heat*463-69,0,255)
		local Green=math.Clamp(Heat*1275-1020,0,255)
		local Blue=math.Clamp(Heat*2550-2295,0,255)
		self:SetColor(Color(Red,Green,Blue))
		
		local dlightend=DynamicLight(0)
		dlightend.Pos=self:GetPos()
		dlightend.Size=500
		dlightend.Decay=1000
		dlightend.R=Red
		dlightend.G=Green
		dlightend.B=Blue
		dlightend.Brightness=math.Rand(.9,1.2)
		dlightend.DieTime=CurTime()+.01
		
		render.SuppressEngineLighting(true)
		self.Entity:DrawModel()
		render.SuppressEngineLighting(false)
	end
end

function ENT:Think()
	if(self.Hot)then
		self.Heat=self.Heat-.005
		self:NextThink(CurTime()+.01)
		return true
	end
end