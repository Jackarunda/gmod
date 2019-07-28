-- Jackarunda 2019
local Sprites={"particle/smokestack","particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1","sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
function EFFECT:Init(data)
	local Pos,Scale=data:GetOrigin(),data:GetScale()
	local Emitter=ParticleEmitter(Pos)
	for i=0,10*Scayul do
		local Sprite=table.Random(Sprites)
		local Particle=Emitter:Add(Sprite,Pos)
		if(particle)then
			Particle:SetVelocity(math.Rand(10,500)*VectorRand()*Scale)
			Particle:SetAirResistance(1000)
			Particle:SetDieTime(math.Rand(.5,2)*Scale)
			Particle:SetStartAlpha(math.Rand(25,255))
			Particle:SetEndAlpha(0)
			local Size=math.Rand(1,20)*Scale
			Particle:SetStartSize(Size)
			Particle:SetEndSize(Size*3)
			Particle:SetRoll(math.Rand(-3,3))
			Particle:SetRollDelta(math.Rand(-2,2))
			Particle:SetGravity(Vector(0,0,math.random(-10,-100)))
			Particle:SetLighting(true)
			local darg=math.Rand(200,255)
			Particle:SetColor(darg,darg,darg)
			Particle:SetCollide(false)
		end
	end
	Emitter:Finish()
end
function EFFECT:Think()
	return false
end
function EFFECT:Render()
	-- no u
end