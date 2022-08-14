-- Jackarunda 2021
local Sprites={"sprites/mat_jack_smoke1"}--"particle/smokestack","particles/smokey","particle/particle_smokegrenade","sprites/mat_jack_smoke1","sprites/mat_jack_smoke2","sprites/mat_jack_smoke3"}
function EFFECT:Init(data)
	local Pos, Norm, Vel, Life=data:GetOrigin(), data:GetNormal(), data:GetStart(), data:GetScale()
	local Emitter=ParticleEmitter(Pos)
	local Sprite=Sprites[math.random(1, #Sprites)]
    local Firesprite="mats_jack_gmod_sprites/flamelet"
    for i=1, 2 do
		local FireParticle=Emitter:Add(Firesprite..math.random(1,5),Pos+VectorRand()*2)
		if FireParticle then
			FireParticle:SetVelocity(Vel+Norm*math.random(150, 200)+VectorRand()*10)
			FireParticle:SetAirResistance(1)
			FireParticle:SetDieTime(math.Rand(1, 2))
			FireParticle:SetStartAlpha(255)
			FireParticle:SetEndAlpha(0)

			local Size=math.Rand(20, 40)
			FireParticle:SetStartSize(Size/2)
			FireParticle:SetEndSize(Size*5)
			--FireParticle:SetRoll(math.Rand(-5, 5))
			--FireParticle:SetRollDelta(math.Rand(-1, 1))

			local Vec=VectorRand()*10+Vector(0, 0, 100)+JMod.Wind*150
			FireParticle:SetGravity(Vec)
			FireParticle:SetLighting(false)
			
			local Brightness=math.Rand(.5, 1)
			FireParticle:SetColor(255*Brightness, 100*Brightness, 1*Brightness)
			FireParticle:SetCollide(true)
			FireParticle:SetBounce(1)
		end
	end
	for i=1, 2 do
		local RollParticle=Emitter:Add(Sprite,Pos)
		if RollParticle then
			RollParticle:SetVelocity(Vel+Norm*math.random(150, 200)+VectorRand()*10)
			RollParticle:SetAirResistance(80)
			RollParticle:SetDieTime(math.Rand(5, 20))
			RollParticle:SetStartAlpha(200)
			RollParticle:SetEndAlpha(0)

			local Size=math.Rand(40, 60)
			RollParticle:SetStartSize(Size/20)
			RollParticle:SetEndSize(Size*10)
			RollParticle:SetRoll(math.Rand(-5, 5))
			RollParticle:SetRollDelta(math.Rand(-1, 1))

			local Vec=VectorRand()*10+Vector(0, 0, 150)+JMod.Wind*150
			RollParticle:SetGravity(Vec)
			RollParticle:SetLighting(false)
			
			local Brightness=math.Rand(.5, 1)
			RollParticle:SetColor(1*Brightness, 1*Brightness, 1*Brightness)
			RollParticle:SetCollide(true)
			RollParticle:SetBounce(1)
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