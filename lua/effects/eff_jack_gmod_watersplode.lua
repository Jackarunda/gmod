local Wake=Material("effects/splashwake1")
function EFFECT:Init(data)
	self.Scale=data:GetScale()
	self.Pos=data:GetOrigin()
	self.Mine=data:GetEntity()
	self.DieTime=CurTime()+5
	self.Size=150
	self.Normal=Vector(0,0,1)
	local Tr=util.TraceLine({
		start=self.Pos+Vector(0,0,200),
		endpos=self.Pos-Vector(0,0,200),
		filter={self.Mine},
		mask=-1 -- hit water
	})
	if(Tr.Hit)then self.Pos=Tr.HitPos end
	---
	local Splach=EffectData()
	Splach:SetOrigin(self.Pos)
	Splach:SetNormal(Vector(0,0,1))
	Splach:SetScale(100)
	util.Effect("WaterSplash",Splach)
	---
	local emitter=ParticleEmitter(self.Pos)
	for i=0,200 do
		local Sprite
		local Rand=math.random(1,3)
		if(Rand==1)then Sprite="effects/splash1" elseif(Rand==2)then Sprite="effects/splash2" elseif(Rand==3)then Sprite="effects/splash4" end
		local Vec=Vector(math.Rand(-80,80),math.Rand(-80,80),0)*self.Scale
		local Dist=Vec:Length()
		local particle=emitter:Add(Sprite, self.Pos+Vec)
		particle:SetVelocity(VectorRand()*math.Rand(.5,2)*Dist^.5*self.Scale+Vector(0,0,math.Rand(1500,15000))*self.Scale/Dist^.5)
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0,0,-1200))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.3,1.3)*self.Scale)
		particle:SetStartAlpha(math.Rand(150,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(.1,60)*self.Scale)
		particle:SetEndSize(math.Rand(.1,40)*self.Scale)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1)*6)
		particle:SetColor(255,255,255)
	end
	for i=0,150 do
		local Sprite
		local Rand=math.random(1,3)
		if(Rand==1)then Sprite="effects/splash1" elseif(Rand==2)then Sprite="effects/splash2" elseif(Rand==3)then Sprite="effects/splash4" end
		local Vec=Vector(math.Rand(-80,80),math.Rand(-80,80),0)*self.Scale
		local Dist=Vec:Length()
		local particle=emitter:Add(Sprite, self.Pos+Vec)
		particle:SetVelocity((VectorRand()*math.Rand(.5,2)*Dist^.5*self.Scale+Vector(0,0,math.Rand(1000,10000))*self.Scale/Dist^.5)*2)
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0,0,-1200))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.3,1.3)*self.Scale)
		particle:SetStartAlpha(math.Rand(200,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(10)
		particle:SetEndSize(10)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1)*6)
		particle:SetColor(255,255,255)
	end
	for i=0,100 do
		local Sprite
		local Rand=math.random(1,3)
		if(Rand==1)then Sprite="effects/splash1" elseif(Rand==2)then Sprite="effects/splash2" elseif(Rand==3)then Sprite="effects/splash4" end
		local Vec=Vector(math.Rand(-80,80),math.Rand(-80,80),0)*self.Scale
		local Dist=Vec:Length()
		local particle=emitter:Add(Sprite, self.Pos+Vec)
		particle:SetVelocity((VectorRand()*math.Rand(.5,2)*Dist^.5*self.Scale+Vector(0,0,-math.Rand(500,5000))*self.Scale/Dist^.5)*2)
		particle:SetCollide(false)
		particle:SetLighting(false)
		particle:SetBounce(.01)
		particle:SetGravity(Vector(0,0,600))
		particle:SetAirResistance(10)
		particle:SetDieTime(math.Rand(.3,1)*self.Scale)
		particle:SetStartAlpha(math.Rand(200,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(100)
		particle:SetEndSize(100)
		particle:SetRoll(math.Rand(180, 480))
		particle:SetRollDelta(math.Rand(-1, 1)*6)
		particle:SetColor(255,255,255)
	end
	emitter:Finish()
end
function EFFECT:Think()
	if(self.DieTime>CurTime())then
		self.Size=self.Size+10
		self:NextThink(CurTime()+.1)
		return true
	else
		return false
	end
end
function EFFECT:Render()
	local TimeLeftFraction=(self.DieTime-CurTime())/4
	local Opacity=math.Clamp(TimeLeftFraction*200,0,255)
	---
	render.SetMaterial(Wake)
	render.DrawQuadEasy(self.Pos+self.Normal*5,self.Normal,self.Size,self.Size,Color(255,255,255,Opacity))
	render.DrawQuadEasy(self.Pos+self.Normal*5,self.Normal,self.Size,self.Size,Color(255,255,255,Opacity))
	return
end