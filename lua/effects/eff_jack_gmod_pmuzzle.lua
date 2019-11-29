function EFFECT:Init(data)

	local dirkshun=data:GetNormal()
	local pozishun=data:GetStart()
	
	local NumParticles=10
	
	local emitter=ParticleEmitter(data:GetOrigin())
	
		for i=0, NumParticles do

			local rollparticle=emitter:Add("particles/flamelet"..math.random(1,3),pozishun+VectorRand()*math.Rand(0,10))

			if(rollparticle)then
				rollparticle:SetVelocity(Vector(math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10))+dirkshun*math.Rand(250,750))
				
				rollparticle:SetLifeTime(0)
				local life=math.Rand(0.025,0.075)
				local begin=CurTime()
				rollparticle:SetDieTime(life)
				
				rollparticle:SetColor(25,math.Rand(150,180),math.Rand(235,255))
				
				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
				
				rollparticle:SetStartSize(10)
				rollparticle:SetEndSize(15)
				
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
				
				rollparticle:SetAirResistance(1000)
				
				rollparticle:SetGravity(Vector(0,0,0))

				rollparticle:SetCollide(false)

				rollparticle:SetLighting(false)
			end
			
			local rollparticle=emitter:Add("particles/flamelet"..math.random(1,3),pozishun)

			if(rollparticle)then
				rollparticle:SetVelocity(Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5))+dirkshun*math.Rand(750,2500))
				
				rollparticle:SetLifeTime(0)
				local life=math.Rand(0.025,0.075)
				local begin=CurTime()
				rollparticle:SetDieTime(life)
				
				rollparticle:SetColor(100,200,255)
				
				rollparticle:SetStartAlpha(255)
				rollparticle:SetEndAlpha(0)
				
				rollparticle:SetStartSize(5)
				rollparticle:SetEndSize(10)
				
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
				
				rollparticle:SetAirResistance(1000)
				
				rollparticle:SetGravity(Vector(0,0,0))

				rollparticle:SetCollide(false)

				rollparticle:SetLighting(false)
			end
		end
		
	emitter:Finish()
end

function EFFECT:Think()

	return false
end

function EFFECT:Render()
end