-- Jackarunda 2021
local Sprites={"particle/smokestack"}--,"particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1"}--,"sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
function EFFECT:Init(data)
	local Pos, Norm, Vel, Life, ColAng=data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetScale(), data:GetAngles()
	local R, G, B = 0, 0, 0
	local Emitter=ParticleEmitter(Pos)
	local Sprite=Sprites[math.random(1, #Sprites)]
	for i=1, 2 do
		local FireParticle=Emitter:Add(Sprite,Pos)
		if FireParticle then
			FireParticle:SetVelocity(Vel+Norm*math.random(50, 100)+VectorRand()*10)
			FireParticle:SetAirResistance(100)
			FireParticle:SetDieTime(math.Rand(5, 20))
			FireParticle:SetStartAlpha(255)
			FireParticle:SetEndAlpha(0)

			local Size=math.Rand(30, 60)
			FireParticle:SetStartSize(Size/5)
			FireParticle:SetEndSize(Size*1)
			FireParticle:SetRoll(math.Rand(-3, 3))
			FireParticle:SetRollDelta(math.Rand(-2, 2))

			local Vec=VectorRand()*10+Vector(0, 0, 200)+JMod.Wind*150
			FireParticle:SetGravity(Vec)
			FireParticle:SetLighting(false)
			
			local Brightness=math.Rand(.5, 1)
			FireParticle:SetColor(255*Brightness, 0*Brightness, 0*Brightness)
			FireParticle:SetCollide(true)
			FireParticle:SetBounce(1)
		end
	end
    /*for i=1, 2 do
		local RollParticle=Emitter:Add(Sprite,Pos)
		if RollParticle then
			RollParticle:SetVelocity(Vel+Norm*math.random(50, 100)+VectorRand()*10)
			RollParticle:SetAirResistance(100)
			RollParticle:SetDieTime(math.Rand(5, 20))
			RollParticle:SetStartAlpha(255)
			RollParticle:SetEndAlpha(0)

			local Size=math.Rand(20, 40)
			RollParticle:SetStartSize(Size/20)
			RollParticle:SetEndSize(Size*8)
			RollParticle:SetRoll(math.Rand(-3, 3))
			RollParticle:SetRollDelta(math.Rand(-2, 2))

			local Vec=VectorRand()*10+Vector(0, 0, 200)+JMod.Wind*150
			RollParticle:SetGravity(Vec)
			RollParticle:SetLighting(false)
			
			local Brightness=math.Rand(.5, 1)
			RollParticle:SetColor(0*Brightness, 0*Brightness, 0*Brightness)
			RollParticle:SetCollide(true)
			RollParticle:SetBounce(1)
		end
	end*/
	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	-- no u
end