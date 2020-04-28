function EFFECT:Init(data)
	local dirkshun=data:GetNormal()
	local pozishun=data:GetStart()
	local skayul=data:GetScale()
	local NumParticles=10*skayul
	local emitter=ParticleEmitter(data:GetOrigin())
		for i=0, NumParticles do
			local rollparticle=emitter:Add("particle/smokestack",pozishun+VectorRand()*math.Rand(0,10)*skayul)
			if(rollparticle)then
				rollparticle:SetVelocity((VectorRand()*math.Rand(0,1000)+dirkshun*math.Rand(250,550))*skayul)
				rollparticle:SetLifeTime(0)
				local life=math.Rand(0.025,0.115)*skayul^0.25
				local begin=CurTime()
				rollparticle:SetDieTime(life)
				rollparticle:SetColor(255,255,255)
				rollparticle:SetStartAlpha(math.Rand(5,30))
				rollparticle:SetEndAlpha(0)
				rollparticle:SetStartSize(10*skayul)
				rollparticle:SetEndSize(12*skayul)
				rollparticle:SetRoll(math.Rand(-360, 360))
				rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
				rollparticle:SetAirResistance(2000)
				rollparticle:SetGravity(Vector(0,0,0))
				rollparticle:SetCollide(false)
				rollparticle:SetLighting(false)
			end
		end
		local rollparticle=emitter:Add("sprites/heatwave",pozishun+VectorRand()*math.Rand(0,10)*skayul)
		if(rollparticle)then
			rollparticle:SetVelocity((VectorRand()*math.Rand(0,1000)+dirkshun*math.Rand(250,550))*skayul)
			rollparticle:SetLifeTime(0)
			local life=math.Rand(0.025,0.05)*skayul^0.25
			local begin=CurTime()
			rollparticle:SetDieTime(life)
			rollparticle:SetColor(255,255,255)
			rollparticle:SetStartAlpha(50)
			rollparticle:SetEndAlpha(0)
			rollparticle:SetStartSize(10*skayul)
			rollparticle:SetEndSize(12*skayul)
			rollparticle:SetRoll(math.Rand(-360, 360))
			rollparticle:SetRollDelta(math.Rand(-0.61, 0.61)*5)
			rollparticle:SetAirResistance(2000)
			rollparticle:SetGravity(Vector(0,0,0))
			rollparticle:SetCollide(false)
			rollparticle:SetLighting(false)
		end
	emitter:Finish()
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
end