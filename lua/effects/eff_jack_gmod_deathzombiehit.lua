function EFFECT:Init(data)
	
	local NumParticles=1
	
	local emitter=ParticleEmitter(data:GetOrigin())
	
		for i=0, NumParticles do

			local Pos=(data:GetOrigin()+Vector(math.Rand(-3, 3), math.Rand(-3, 3), math.Rand(-3, 3)))
		
			local particle=emitter:Add("sprites/spark", Pos)

			if(particle)then
				particle:SetVelocity(data:GetNormal()*data:GetScale()*5)
				
				particle:SetLifeTime(0)
				particle:SetDieTime(30)
				
				particle:SetColor(100,20,20)			

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				if(self:WaterLevel()>0)then
					particle:SetEndAlpha(0)
				end

				local derpikins=(data:GetScale()*0.035)*math.Rand(0.8,1.2)
				particle:SetStartSize(derpikins)
				particle:SetEndSize(0)
				if(self:WaterLevel()>0)then
					particle:SetEndSize(derpikins*3)
				end
				
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				
				particle:SetAirResistance(100)
				
				particle:SetGravity(Vector(0,0,-1700))
				if(self:WaterLevel()>0)then
					particle:SetGravity(VectorRand()*math.Rand(0,25))
				end
				
				particle:SetCollide(true)
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