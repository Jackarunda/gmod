function EFFECT:Init(data)
	self.Origin=data:GetOrigin()
	self.Vel=data:GetStart()
	local emitter=ParticleEmitter(self.Origin)
	local Pos=self.Origin
	for i=1,5 do
		local particle=emitter:Add("particle/smokestack",Pos+VectorRand()*30)
		if(particle)then
			particle:SetVelocity(VectorRand()*100+self.Vel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(1,3))
			particle:SetColor(50,40,30)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size=math.Rand(10,75)
			particle:SetStartSize(Size)
			particle:SetEndSize(Size*2)
			particle:SetRoll(math.Rand(-360,360))
			particle:SetRollDelta(math.Rand(-0.21,0.21))
			particle:SetAirResistance(500)
			particle:SetGravity(Vector(math.Rand(-1000,1000), math.Rand(-1000,1000), math.Rand(0,-1000)))
			particle:SetCollide(true)
			particle:SetBounce(0.45)
			particle:SetLighting(1)
		end
	end
	for i=1,200 do
		local particle=emitter:Add("effects/fleck_wood"..math.random(1,2),Pos+VectorRand()*20)
		if(particle)then
			particle:SetVelocity(VectorRand()*math.Rand(100,300)+Vector(0,0,100)+self.Vel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(7,10))
			particle:SetColor(255,255,255)			
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			local derpikins=math.random(1,5)
			particle:SetStartSize(derpikins)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360,360))
			particle:SetRollDelta(math.Rand(-0.21,0.21))
			particle:SetAirResistance(1)
			particle:SetGravity(Vector(0,0,math.Rand(-600,-1400)))
			particle:SetCollide(true)
			particle:SetBounce(.5)
			particle:SetLighting(1)
		end
	end
	emitter:Finish()
	--[[
	DLight=DynamicLight(0)
	if(DLight)then
		DLight.Brightness=7
		DLight.Decay=750*10
		DLight.DieTime=CurTime()+.1
		DLight.Pos=self:GetPos()+Vector(1,1,-20)
		DLight.Size=1000
		DLight.r=255
		DLight.g=255
		DLight.b=255
	end
	--]]
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
end