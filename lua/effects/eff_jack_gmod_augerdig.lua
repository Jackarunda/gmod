local ParticleColors = {Color(150, 150, 150), Color(60, 40, 20)}
local FleckSprites = {"effects/fleck_cement1", "effects/fleck_cement2"}
local SmokeSprite = "particle/smokestack"

function EFFECT:Init(data)
	local Origin = data:GetOrigin()
	local Norm = data:GetNormal()
	local Emitter = ParticleEmitter(Origin)

	-- solid dirt/rock particles that spray out haphazardly
	for i = 1, 20 do
		local Particle = Emitter:Add(table.Random(FleckSprites), Origin + VectorRand() * 5)

		if Particle then
			Particle:SetVelocity(Norm * math.random(10, 150) + VectorRand() * math.random(10, 120))
			Particle:SetAirResistance(10)
			Particle:SetDieTime(math.random(5, 10))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			Particle:SetStartSize(math.random(8, 12))
			Particle:SetEndSize(0)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(0)
			Particle:SetGravity(Vector(0, 0, -600))
			Particle:SetLighting(true)
			local Col=table.Random(ParticleColors)
			Particle:SetColor(Col.r, Col.g, Col.b)
			Particle:SetCollide(true)
			Particle:SetBounce(math.Rand(0, .5))
		end
	end

	-- floofy dust particles that spray out haphazardly
	for i = 1, 5 do
		local Particle = Emitter:Add(SmokeSprite, Origin + VectorRand() * 5)

		if Particle then
			Particle:SetVelocity(Norm * math.random(1, 60) + VectorRand() * math.random(1, 60))
			Particle:SetAirResistance(20)
			Particle:SetDieTime(math.random(1, 3))
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(0)
			local Siz = math.random(3, 5)
			Particle:SetStartSize(Siz)
			Particle:SetEndSize(Siz * 10)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(0)
			Particle:SetGravity(Vector(0, 0, -50))
			Particle:SetLighting(true)
			local Col=table.Random(ParticleColors)
			Particle:SetColor(Col.r, Col.g, Col.b)
			Particle:SetCollide(true)
			Particle:SetBounce(math.Rand(0, .3))
		end
	end

	-- solid dirt/rock particles that rise with the same speed as the auger's flutes
	for i = 1, 10 do
		local Particle = Emitter:Add(table.Random(FleckSprites), Origin + VectorRand() * 5)

		if Particle then
			Particle:SetVelocity(Vector(0,0,0))
			Particle:SetAirResistance(1000)
			Particle:SetDieTime(2.5)
			Particle:SetStartAlpha(255)
			Particle:SetEndAlpha(255)
			local Siz = math.random(2, 4)
			Particle:SetStartSize(Siz)
			Particle:SetEndSize(Siz)
			Particle:SetRoll(math.Rand(-3, 3))
			Particle:SetRollDelta(0)
			Particle:SetGravity(Vector(0, 0, 800))
			Particle:SetLighting(true)
			local Col=table.Random(ParticleColors)
			Particle:SetColor(Col.r, Col.g, Col.b)
			Particle:SetCollide(false)
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	-- haha no u
end
