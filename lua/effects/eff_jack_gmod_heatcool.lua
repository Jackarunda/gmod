function EFFECT:Init(data)
	
	if(self:WaterLevel()>0)then
	
		local NumParticles=1
		
		local emitter=ParticleEmitter(data:GetOrigin())
		
		for i=0, NumParticles do

			local Pos=(data:GetOrigin())
				
			local colorangle=Angle(255,255,255)
			local red=colorangle.p
			local green=colorangle.y
			local blue=colorangle.r
			local wind=data:GetStart()
				
			local rollparticle=emitter:Add("effects/bubble",Pos+VectorRand()*3)

			if(rollparticle)then
				rollparticle:SetVelocity(Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10)))
					
				rollparticle:SetLifeTime(0)
				local life=math.Rand(1,2)
				local begin=CurTime()
				rollparticle:SetDieTime(life)
					
				local shadevariation=math.Rand(-10,10)
				rollparticle:SetColor(math.Clamp(255+shadevariation+math.Rand(-5,5),0,255),math.Clamp(255+shadevariation+math.Rand(-5,5),0,255),math.Clamp(255+shadevariation+math.Rand(-5,5),0,255))			

				rollparticle:SetStartAlpha(200)
				rollparticle:SetEndAlpha(0)
					
				rollparticle:SetStartSize(4)
				rollparticle:SetEndSize(15)
					
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
					
				rollparticle:SetAirResistance(1000)
					
				rollparticle:SetGravity(Vector(math.Rand(-500, 500), math.Rand(-500, 500),math.Rand(2000,5000)))

				rollparticle:SetCollide(true)

				rollparticle:SetLighting(false)

			end
		end
		return
	end
	
	local NumParticles=1
	
	local emitter=ParticleEmitter(data:GetOrigin())
	
		for i=0, NumParticles do

			local Pos=(data:GetOrigin())
			
			local culur=math.random(200,255)
			local colorangle=Angle(culur,culur,culur)
			local red=colorangle.p
			local green=colorangle.y
			local blue=colorangle.r
			local wind=data:GetStart()
			
			//these first two particles (rollparticles) are just so it looks like there's thick smoke rolling off of the grenade, instead of smoke particles appearing next to the grenade
		
			local particle=emitter:Add("particle/smokestack", Pos) --particles/smokey is a nice volumetric smoke sprite

			if(particle)then
				particle:SetVelocity(Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
				
				particle:SetLifeTime(0)
				local life=math.Rand(0.5,1)
				local begin=CurTime()
				particle:SetDieTime(life)
				
				local shadevariation=math.Rand(-20,20)
				particle:SetColor(math.Clamp(red+shadevariation+math.Rand(-5,5),0,255),math.Clamp(green+shadevariation+math.Rand(-5,5),0,255),math.Clamp(blue+shadevariation+math.Rand(-5,5),0,255))			

				particle:SetStartAlpha(150)
				particle:SetEndAlpha(0)
				
				particle:SetStartSize(1)
				particle:SetEndSize(10)
				
				particle:SetRoll(math.Rand(-360, 260)) --if using the nice particle, set this to something small and remove the RollDelta
				particle:SetRollDelta(math.Rand(-0.61, 0.61))
				
				particle:SetAirResistance(20)
				
				particle:SetGravity(Vector(math.Rand(-20, 20), math.Rand(-20, 20),math.Rand(50,100)))

				particle:SetCollide(true)

				particle:SetLighting(true)
			end
			
			local particle=emitter:Add("sprites/heatwave", Pos) --particles/smokey is a nice volumetric smoke sprite

			if(particle)then
				particle:SetVelocity(Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10)))
				
				particle:SetLifeTime(0)
				local life=0.075
				local begin=CurTime()
				particle:SetDieTime(life)
				
				local shadevariation=math.Rand(-20,20)
				particle:SetColor(math.Clamp(red+shadevariation+math.Rand(-5,5),0,255),math.Clamp(green+shadevariation+math.Rand(-5,5),0,255),math.Clamp(blue+shadevariation+math.Rand(-5,5),0,255))			

				particle:SetStartAlpha(50)
				particle:SetEndAlpha(0)
				
				particle:SetStartSize(5)
				particle:SetEndSize(10)
				
				particle:SetRoll(math.Rand(-360, 260)) --if using the nice particle, set this to something small and remove the RollDelta
				particle:SetRollDelta(math.Rand(-0.61, 0.61))
				
				particle:SetAirResistance(1000)
				
				particle:SetGravity(Vector(math.Rand(-500, 500), math.Rand(-500, 500),math.Rand(1000,2000)))

				particle:SetCollide(true)

				particle:SetLighting(true)
			end
		end
		
	emitter:Finish()
end

function EFFECT:Think()

	return false
end

function EFFECT:Render()
end