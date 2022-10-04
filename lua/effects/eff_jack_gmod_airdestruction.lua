function EFFECT:Init(data)
	
	local NumParticles=1
	
	local emitter=ParticleEmitter(data:GetOrigin())
	
		local size=data:GetScale()
		local vel=data:GetScale()
	
		for i=0, NumParticles do

			local Pos=(data:GetOrigin()+Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-5, 5)))
		
			local particle=emitter:Add("sprites/heatwave",Pos)

			if(particle)then
				particle:SetVelocity(VectorRand()*100)
				
				particle:SetLifeTime(0)
				particle:SetDieTime(0.25*size)
				
				particle:SetColor(255,255,255)			

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)

				particle:SetStartSize(20)
				particle:SetEndSize(50*math.Rand(0.8,1.2))
				
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				
				particle:SetAirResistance(100)
				
				particle:SetGravity(Vector(0,0,0))
				
				particle:SetCollide(false)
				particle:SetBounce(0)

				particle:SetLighting(1)
			end
		end
		
	emitter:Finish()
end

function EFFECT:Think()

	return false
end

function EFFECT:Render()
end