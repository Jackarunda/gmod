/*---------------------------------------------------------
	EFFECT:Init(data)
---------------------------------------------------------*/
function EFFECT:Init(data)
	
	local vOffset=data:GetOrigin()
	
	local Scayul=data:GetScale()
	
	if(self:WaterLevel()==3)then
		local Splach=EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0,0,1))
		Splach:SetScale(Scayul*200)
		util.Effect("WaterSplash",Splach,true,true)
		return
	end
	
	local Splach=EffectData()
	Splach:SetOrigin(vOffset)
	Splach:SetNormal(Vector(0,0,1))
	Splach:SetScale(Scayul*200)
	util.Effect("Explosion",Splach,true,true)

	local emitter=ParticleEmitter(vOffset)
		
		for i=0,10 do
			local particle=emitter:Add("effects/fire_cloud1", vOffset+VectorRand()*math.Rand(0,300))
			particle:SetVelocity(math.Rand(40,60)*VectorRand()*Scayul)
			particle:SetAirResistance(20)
			particle:SetDieTime(.05*Scayul)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(100*Scayul)
			particle:SetEndSize(200*Scayul)
			particle:SetRoll(math.Rand(180, 480))
			particle:SetRollDelta(math.Rand(-1, 1)*6)
			particle:SetColor(175,220,255)
		end
	
		for i=0,40*Scayul do
			local sprite
			local chance=math.random(1,6)
			if(chance==1)then
				sprite="particle/smokestack"
			elseif(chance==2)then
				sprite="particles/smokey"
			elseif(chance==3)then
				sprite="particle/particle_smokegrenade"
			elseif(chance==4)then
				sprite="sprites/Smoke1"
			elseif(chance==5)then
				sprite="sprites/Smoke2"
			elseif(chance==6)then
				sprite="sprites/Smoke3"
			end
			local particle=emitter:Add(sprite, vOffset)
			particle:SetVelocity(math.Rand(300,850)*VectorRand()*Scayul)
			particle:SetAirResistance(300)
			particle:SetGravity(Vector(0, 0, math.Rand(25, 100)))
			particle:SetDieTime(math.Rand(4,7))
			particle:SetStartAlpha(math.Rand(100,200))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(20, 30)*Scayul)
			particle:SetEndSize(math.Rand(30, 40)*Scayul)
			particle:SetRoll(0)
			particle:SetRollDelta(math.Rand(-3,3))
			particle:SetLighting(true)
			local darg=math.Rand(200,255)
			particle:SetColor(darg,darg,darg)

		end
		
		for i=0, 5*Scayul^2 do
			local Debris=emitter:Add( "effects/fleck_cement"..math.random(1,2),vOffset)
			if(Debris)then
				Debris:SetVelocity(VectorRand()*math.Rand(250,1500)*Scayul^0.5)
				Debris:SetDieTime(3*math.random(0.6,1))
				Debris:SetStartAlpha(255)
				Debris:SetEndAlpha(0)
				Debris:SetStartSize(math.random(1,5)*Scayul^0.5)
				Debris:SetRoll( math.Rand(0,360))
				Debris:SetRollDelta( math.Rand(-5,5))			
				Debris:SetAirResistance(1) 			 			
				Debris:SetColor(105,100,90)
				Debris:SetGravity(Vector(0,0,-700)) 
				Debris:SetCollide( true )
				Debris:SetBounce( 1 )		
				Debris:SetLighting(true)
			end
		end
		
		for i=0, 75*Scayul do

			local Pos=(data:GetOrigin()+Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)))
		
			local particle=emitter:Add("sprites/spark", Pos)

			if(particle)then
				particle:SetVelocity(VectorRand()*math.Rand(4000, 6000)*Scayul)
				
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(0.3,0.6))
				
				local herpdemutterfickendenderp=math.Rand(200,255)
				particle:SetColor(255,herpdemutterfickendenderp,herpdemutterfickendenderp-50)			

				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)

				particle:SetStartSize(math.Rand(2,5)*Scayul)
				particle:SetEndSize(0)
				
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				
				particle:SetAirResistance(200)
				
				particle:SetGravity(Vector(math.Rand(-1000, 500), math.Rand(-1000, 1000), math.Rand(0, 1000)))

				particle:SetCollide(true)
				particle:SetBounce(0.9)

			end
		end
		
		local particle=emitter:Add("sprites/heatwave", vOffset)
		particle:SetVelocity(Vector(0,0,0))
		particle:SetAirResistance(200)
		particle:SetGravity(VectorRand()*math.Rand(0,200))
		particle:SetDieTime(math.Rand(0.03, 0.05)*Scayul)
		particle:SetStartAlpha(40)
		particle:SetEndAlpha(0)
		particle:SetStartSize(170*Scayul)
		particle:SetEndSize(170*Scayul)
		particle:SetRoll(math.Rand(0,10))
		particle:SetRollDelta(6000)

	emitter:Finish()
end

/*---------------------------------------------------------
	EFFECT:Think()
---------------------------------------------------------*/
function EFFECT:Think()

	return false
end

/*---------------------------------------------------------
	EFFECT:Render()
---------------------------------------------------------*/
function EFFECT:Render()
end