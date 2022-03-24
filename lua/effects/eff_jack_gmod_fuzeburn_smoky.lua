
function EFFECT:Init(data)
	
	local vOffset=data:GetOrigin()
	
	local Scayul=data:GetScale()
	local Dir=data:GetNormal()
	local Scl=Scayul
	local Pos=vOffset
	
	if(self:WaterLevel()==3)then
		local Splach=EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0,0,1))
		Splach:SetScale(Scayul*200)
		util.Effect("WaterSplash",Splach)
		return
	end

	local emitter=ParticleEmitter(vOffset)
	if(emitter)then
		for i=0, 30*Scayul^0.5 do

			local Pos=(data:GetOrigin())
		
			local particle=emitter:Add("sprites/mat_jack_nicespark",Pos)

			if(particle)then
				particle:SetVelocity((Dir+VectorRand()*.2)*math.random(10,500)*Scayul)
				
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(0.1,1.5))
				
				local herpdemutterfickendenderp=math.Rand(200,255)
				particle:SetColor(255,herpdemutterfickendenderp-10,herpdemutterfickendenderp-20)		

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)

				particle:SetStartSize(1)
				particle:SetEndSize(0)
				
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				
				particle:SetAirResistance(200)
				
				particle:SetGravity(Vector(0,0,-600))

				particle:SetLighting(false)
				particle:SetCollide(true)
				particle:SetBounce(0.95)

			end
		end
		for i=1,2*Scl do
			local ParticlePos=Pos+Dir+VectorRand()*3
			local particle=emitter:Add("particle/smokestack",ParticlePos)
			particle:SetVelocity(Vector(0,0,math.random(1,200))+VectorRand()*30)
			particle:SetAirResistance(150)
			particle:SetGravity(Vector(0,0,0))
			particle:SetDieTime(math.Rand(.1,1))
			particle:SetStartAlpha(math.random(50,255))
			particle:SetEndAlpha(0)
			local Size=math.Rand(1,20)*Scl
			particle:SetStartSize(Size/2)
			particle:SetEndSize(Size)
			particle:SetRoll(math.Rand(-2,2))
			particle:SetRollDelta(math.Rand(-2,2))
			local Col=math.random(180,255)
			particle:SetColor(Col,Col,Col)
			particle:SetLighting(math.random(1,2)==1)
			particle:SetCollide(false)
		end
		emitter:Finish()
	end
	
	local dlight=DynamicLight(self:EntIndex())
	local Randem=math.Rand(0.75,1)
	if(dlight)then
		dlight.Pos=vOffset
		dlight.r=255*Randem
		dlight.g=200*Randem
		dlight.b=175*Randem
		dlight.Brightness=.5*Scayul^0.5
		dlight.Size=150*Scayul^0.5
		dlight.Decay=1000
		dlight.DieTime=CurTime()+0.1
		dlight.Style=0
	end

end


function EFFECT:Think()

	return false
end


function EFFECT:Render()
end