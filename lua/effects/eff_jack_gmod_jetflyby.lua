function EFFECT:Init(data)
	self.LifeTime=2 -- debug
	self.DieTime=CurTime()+self.LifeTime
	self.Plane=ClientsideModel("models/xqm/jetbody3_s2.mdl")
	self.Plane:SetNoDraw(true)
	self.Velocity=data:GetStart()
	self.Pos=data:GetOrigin()
end
function EFFECT:Think( )
	local TimeLeft=self.DieTime-CurTime()
	if(TimeLeft>0)then return true end
	return false
end
function EFFECT:Render()
	local Frac=((self.DieTime-CurTime())/self.LifeTime)-.5
	local Pos=self.Pos+self.Velocity*Frac
	self.Plane:SetRenderOrigin(Pos)
	local Ang=self.Velocity:Angle()
	Ang:RotateAroundAxis(Ang:Up(),-90)
	self.Plane:SetRenderAngles(Ang)
	self.Plane:DrawModel()
end