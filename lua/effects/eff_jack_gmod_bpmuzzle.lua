function EFFECT:Init(data)
	local Pos,Dir,Scl=data:GetOrigin(),data:GetNormal(),data:GetScale()
	local emitter=ParticleEmitter(Pos)
	if(emitter)then
		for i=1,40*Scl do
			local ParticlePos=Pos+Dir*math.random(-10,50)
			local particle=emitter:Add("mats_jack_gmod_sprites/flamelet"..math.random(1,5),ParticlePos)
			particle:SetVelocity(Dir*math.Rand(1,3)*i*Scl+VectorRand()*math.random(10,20))
			particle:SetAirResistance(50)
			particle:SetGravity(Vector(0,0,math.random(5,50))+JMod.Wind*100)
			particle:SetDieTime(math.Rand(.1,.3))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size=(20/i)*Scl
			particle:SetStartSize(Size/10)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2,2))
			particle:SetRollDelta(math.Rand(-2,2))
			particle:SetColor(255,255,255)
			particle:SetLighting(false)
			particle:SetCollide(true)
		end
		for i=1,120*Scl do
			local ParticlePos=Pos+Dir*math.random(-10,100)
			local particle=emitter:Add("particle/smokestack",ParticlePos)
			particle:SetVelocity(Dir*math.Rand(2,6)*i*Scl+VectorRand()*math.random(10,20))
			particle:SetAirResistance(150)
			particle:SetGravity(Vector(0,0,math.random(5,50))+JMod.Wind*100*math.Rand(0,1))
			particle:SetDieTime(math.Rand(1,10))
			particle:SetStartAlpha(math.random(50,255))
			particle:SetEndAlpha(0)
			local Size=math.Clamp(math.Rand(250,500)/i,20,200)*Scl
			particle:SetStartSize(Size/2)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2,2))
			particle:SetRollDelta(math.Rand(-2,2))
			local Col=math.random(180,255)
			particle:SetColor(Col,Col,Col)
			particle:SetLighting(math.random(1,2)==1)
			particle:SetCollide(true)
		end
	end
	emitter:Finish()
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
	--
end