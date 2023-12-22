-- AdventureBoots 2023
local ParticleColors = {Color(185, 185, 185), Color(226, 223, 220)}
local DustSprites = {"effects/fleck_cement1", "effects/fleck_cement2"}
local CloudSprites = {"particle/smokestack"}

function EFFECT:Init(data)
	local Pos, Vel, Scl = data:GetOrigin(), data:GetStart(), data:GetScale()
	local Emitter = ParticleEmitter(Pos)
	local CloudSprite = table.Random(CloudSprites)
	local DustSprite = table.Random(DustSprites)

	local Tr = util.QuickTrace(Pos, Vector(0, 0, -500), nil)

	if Tr.Hit then
		-- Falling dust
		for i = 1, 10 * Scl do
			local Particle = Emitter:Add(DustSprite, Pos + Vector(math.random(-500, 500), math.random(-500, 500), math.random(-50, 200)))
			if Particle then
				Particle:SetVelocity(Vel)
				Particle:SetAirResistance(250)
				Particle:SetDieTime(math.random(7, 15))
				Particle:SetStartAlpha(200)
				Particle:SetEndAlpha(0)
				local Siz = math.Rand(5, 10)
				Particle:SetStartSize(Siz)
				Particle:SetEndSize(Siz)
				Particle:SetRoll(math.Rand(-3, 3))
				Particle:SetRollDelta(math.Rand(-2, 2))
				local Vec = Vector(math.random(-10, 10), math.random(-10, 10), math.random(-90, -120)) + JMod.Wind * 150
				Particle:SetGravity(Vec)
				Particle:SetLighting(false)
				--local darg = math.Rand(50, 100)
				Particle:SetColor(table.Random(ParticleColors))
				Particle:SetCollide(true)
				Particle:SetBounce(1)
				---
				--[[Particle:SetNextThink(CurTime())
				Particle:SetThinkFunction( function( pa )
					pa:SetColor( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) ) -- Randomize it
					pa:SetNextThink( CurTime() ) -- Makes sure the think hook is actually ran.
				end )]]--
			end
		end
	elseif Tr.Fraction >= .9 then
		--Clouds of dust
		for i = 1, 5 do
			local Particle = Emitter:Add(CloudSprite, Pos + Vector(math.random(-100, 100), math.random(-100, 100), math.random(-50, 50)))
			if Particle then
				Particle:SetVelocity(Vel + Vector(0, 0, 100))
				Particle:SetAirResistance(250)
				Particle:SetDieTime(math.random(8, 10))
				Particle:SetStartAlpha(255)
				Particle:SetEndAlpha(0)
				local Siz = math.Rand(250, 400)
				Particle:SetStartSize(Siz / 2)
				Particle:SetEndSize(Siz)
				Particle:SetRoll(math.Rand(-1, 1))
				Particle:SetRollDelta(math.Rand(-2, 2))
				local Vec = VectorRand() * 150 + JMod.Wind * 150
				Vec.z = Vec.z / 2
				Particle:SetGravity(Vec)
				Particle:SetLighting(false)
				local darg = math.Rand(50, 100)
				Particle:SetColor(darg, darg, darg)
				Particle:SetCollide(true)
				Particle:SetBounce(1)
				---
				Particle:SetNextThink(CurTime())
			end
		end
	end

	Emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
-- no u
