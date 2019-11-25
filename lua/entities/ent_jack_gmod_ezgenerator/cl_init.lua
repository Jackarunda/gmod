include('shared.lua')

function ENT:Initialize()
	self.RotateAngle=0
	self.RotSpeed=0
	self.Blowing=false
	self.Engine1=ClientsideModel("models/props_silo/fanoff.mdl")
	self.Engine1:SetPos(self:GetPos())
	self.Engine1:SetParent(self)
	self.Engine1:SetNoDraw(true)
	self.Engine1:SetModelScale(.75,0)
	self.Engine2=ClientsideModel("models/props_silo/fanoff.mdl")
	self.Engine2:SetPos(self:GetPos())
	self.Engine2:SetParent(self)
	self.Engine2:SetNoDraw(true)
	self.Engine2:SetModelScale(.75,0)
	self.Engine3=ClientsideModel("models/props_silo/fanoff.mdl")
	self.Engine3:SetPos(self:GetPos())
	self.Engine3:SetParent(self)
	self.Engine3:SetNoDraw(true)
	self.Engine3:SetModelScale(.75,0)
	self.Engine4=ClientsideModel("models/props_silo/fanoff.mdl")
	self.Engine4:SetPos(self:GetPos())
	self.Engine4:SetParent(self)
	self.Engine4:SetNoDraw(true)
	self.Engine4:SetModelScale(.75,0)
	self.Turbine=ClientsideModel("models/props_silo/fanhousing.mdl")
	self.Turbine:SetPos(self:GetPos())
	self.Turbine:SetParent(self)
	self.Turbine:SetNoDraw(true)
	self.Turbine:SetModelScale(.75,0)
	self.Turbine:SetMaterial("models/props_silo/jan")
end

function ENT:Draw()
	local Ang=self:GetAngles()
	local Pos=self:GetPos()
	local Up=self:GetUp()
	local Right=self:GetRight()
	local Forward=self:GetForward()
	local Ang2=self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(),self.RotateAngle)
	self.RotateAngle=self.RotateAngle+self.RotSpeed
	if(self.RotateAngle>360)then self.RotateAngle=0 end
	if(self:GetState() != 0)then
		self.RotSpeed=self.RotSpeed+.035
	else
		self.RotSpeed=self.RotSpeed-.035
	end
	if(self.RotSpeed>42)then self.RotSpeed=42 end
	if(self.RotSpeed<0)then self.RotSpeed=0 end
	if(self.RotSpeed>30)then
		if not(self.Blowing)then
			self.Blowing=true
			self.Engine1:SetModel("models/props_silo/fan.mdl")
			self.Engine2:SetModel("models/props_silo/fan.mdl")
			self.Engine3:SetModel("models/props_silo/fan.mdl")
			self.Engine4:SetModel("models/props_silo/fan.mdl")
		end
	else
		if(self.Blowing)then
			self.Blowing=false
			self.Engine1:SetModel("models/props_silo/fanoff.mdl")
			self.Engine2:SetModel("models/props_silo/fanoff.mdl")
			self.Engine3:SetModel("models/props_silo/fanoff.mdl")
			self.Engine4:SetModel("models/props_silo/fanoff.mdl")
		end
	end
	self.Engine1:SetRenderOrigin(Pos+Forward*70+Up*55)
	Ang:RotateAroundAxis(Ang:Right(),90)
	self.Engine1:SetRenderAngles(Ang)
	self.Engine1:DrawModel()
	self.Engine2:SetRenderOrigin(Pos+Forward*70+Up*55)
	Ang:RotateAroundAxis(Ang:Up(),15)
	self.Engine2:SetRenderAngles(Ang)
	self.Engine3:SetRenderOrigin(Pos+Forward*70+Up*55)
	Ang:RotateAroundAxis(Ang:Up(),15)
	self.Engine3:SetRenderAngles(Ang)
	self.Engine4:SetRenderOrigin(Pos+Forward*70+Up*55)
	Ang:RotateAroundAxis(Ang:Up(),15)
	self.Engine4:SetRenderAngles(Ang)
	local R,G,B=render.GetColorModulation()
	render.SetColorModulation(.2,.2,.2)
	self.Engine1:DrawModel()
	self.Engine2:DrawModel()
	self.Engine3:DrawModel()
	self.Engine4:DrawModel()
	render.SetColorModulation(R,G,B)
	self.Turbine:SetRenderOrigin(Pos+Forward*65+Up*55)
	Ang2:RotateAroundAxis(Ang2:Right(),-90)
	self.Turbine:SetRenderAngles(Ang2)
	self.Turbine:DrawModel()
	self.Entity:DrawModel()

	local SelfPos,SelfAng = self:GetPos(), self:GetAngles()
	local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
	local distsqr = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
	
	if distsqr < 20000 then
		local DisplayAng=SelfAng:GetCopy()
		DisplayAng:RotateAroundAxis(DisplayAng:Forward(),90)
		--DisplayAng:RotateAroundAxis(DisplayAng:Up(),-90)
		local Opacity=math.random(50,150)
		cam.Start3D2D(SelfPos+Up*45-Right*(-20)-Forward*(-20),DisplayAng,.1)
		
			local stateStr, R, G, B = "OFF", 255, 0, 0
			if self:GetState() == 1 then 
				stateStr, R, G, B = "ON", 0, 255, 0
			elseif self:GetState() == -1 then 
				stateStr, R, G, B = "STARTING", 150, 150, 0 
			end
			draw.SimpleTextOutlined("STATUS","JMod-Display",100,-150,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			draw.SimpleTextOutlined(stateStr,"JMod-Display",100,-115,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			
			draw.SimpleTextOutlined("POWER","JMod-Display",200,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			local R,G,B=JMod_GoodBadColor(self:GetPower()/self.MaxPower)
			draw.SimpleTextOutlined(tostring(self:GetPower()),"JMod-Display",200,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			
			local R,G,B=JMod_GoodBadColor(self:GetFuel()/self.MaxFuel)
			draw.SimpleTextOutlined("FUEL","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
			draw.SimpleTextOutlined(tostring(self:GetFuel()),"JMod-Display",0,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
		cam.End3D2D()
	end
end

language.Add("ent_jack_gmod_ezgenerator","EZ Generator")