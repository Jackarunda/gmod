function EFFECT:Init(data)
	local Pos,Scale,Normal,Spread=data:GetOrigin(),data:GetScale(),data:GetNormal(),data:GetMagnitude()
	local Emitter=ParticleEmitter(Pos)
	if(Normal==Vector(0,0,0))then Normal=nil end
	if(Spread==0)then Spread=nil end
	for i=0,1500 do
		local Dir
		if((Normal)and(Spread))then
			Dir=Vector(Normal.x,Normal.y,Normal.z)
			Dir=Dir+VectorRand()*math.Rand(0,Spread)
			Dir:Normalize()
		else
			Dir=VectorRand()
		end
		local particle=Emitter:Add("particle/smokestack",Pos)
		particle:SetVelocity(VectorRand()*100000)
		particle:SetAirResistance(10)
		particle:SetGravity(Vector(0,0,0))
		particle:SetDieTime(math.Rand(.1,1))
		particle:SetStartAlpha(math.Rand(200,255))
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(math.Rand(10,30)*Scale/6000)
		particle:SetRoll(math.Rand(-3,3))
		particle:SetRollDelta(math.Rand(-3,3))
		particle:SetLighting(true)
		local darg=math.Rand(10,150)
		particle:SetColor(darg,darg,darg)
		particle:SetCollide(true)
	end
	Emitter:Finish()
end
function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end