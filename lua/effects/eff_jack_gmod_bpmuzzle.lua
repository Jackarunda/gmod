function EFFECT:Init(data)
	local Pos,Dir,Scl=data:GetOrigin(),data:GetNormal(),data:GetScale()
	local emitter=ParticleEmitter(Pos)
	if(emitter)then
		for i=1,40*Scl do
			local ParticlePos=Pos+Dir*math.random(-10,50)
			local particle=emitter:Add("mats_jack_gmod_sprites/flamelet"..math.random(1,5),ParticlePos)
			particle:SetVelocity(Dir*math.Rand(1,2)*i*Scl+VectorRand()*math.random(10,20))
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0,0,math.random(5,50))+JMOD_WIND*100)
			particle:SetDieTime(math.Rand(.1,.3))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size=(30/i)*Scl
			particle:SetStartSize(Size/10)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2,2))
			particle:SetRollDelta(math.Rand(-2,2))
			particle:SetColor(255,255,255)
			particle:SetLighting(false)
			particle:SetCollide(true)
		end
		for i=1,80*Scl do
			local ParticlePos=Pos+Dir*math.random(-10,100)
			local particle=emitter:Add("particle/smokestack",ParticlePos)
			particle:SetVelocity(Dir*math.Rand(2,3)*i*Scl+VectorRand()*math.random(10,20))
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(0,0,math.random(5,50))+JMOD_WIND*50)
			particle:SetDieTime(math.Rand(3,8))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			local Size=math.Clamp(math.Rand(500,1000)/i,20,200)*Scl
			particle:SetStartSize(Size/5)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2,2))
			particle:SetRollDelta(math.Rand(-2,2))
			local Col=math.random(150,255)
			particle:SetColor(Col,Col,Col)
			particle:SetLighting(true)
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