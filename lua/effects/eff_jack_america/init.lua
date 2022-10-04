local matRefraction = Material("jackrefract_ring")
matRefraction:SetInt("$nocull", 1)
local tMats = {}
tMats.Glow1 = Material("sprites/light_glow02")
tMats.Glow2 = Material("sprites/yellowflare")
tMats.Glow3 = Material("sprites/redglow2")

for _, mat in pairs(tMats) do
	mat:SetInt("$spriterendermode", 5)
	mat:SetInt("$ignorez", 1)
	mat:SetInt("$illumfactor", 8)
end

local Shit = Material("sprites/mat_jack_ignorezsprite")

function EFFECT:Init(data)
	local vOffset = data:GetOrigin()
	self.Position = vOffset
	local AddVel = data:GetStart()
	self.Scale = data:GetScale()
	self.TimeToDie = CurTime() + 0.3 * self.Scale
	local Scayul = data:GetScale()
	local Pos = vOffset
	local Spl = EffectData()
	Spl:SetOrigin(vOffset)
	Spl:SetScale(1)
	util.Effect("Explosion", Spl, true, true)
	local OASize = 2

	if self:WaterLevel() == 3 then
		local Splach = EffectData()
		Splach:SetOrigin(vOffset)
		Splach:SetNormal(Vector(0, 0, 1))
		Splach:SetScale(Scayul * 200)
		util.Effect("WaterSplash", Splach)

		return
	end

	self.Emitter = ParticleEmitter(vOffset)

	for k = 0, 120 * Scayul do
		local SprayDirection = (VectorRand() + (AddVel / 5000)):GetNormalized() * math.Rand(0.8, 1.2)
		local red
		local green
		local blue
		local Rand = math.random(1, 3)

		if Rand == 1 then
			red = 130
			green = 0
			blue = 0
		end

		if Rand == 2 then
			red = 0
			green = 0
			blue = 120
		end

		if Rand == 3 then
			red = 200
			green = 200
			blue = 200
		end

		for i = 0, 150 * Scayul do
			local sprite
			local chance = math.random(1, 3)

			if chance == 1 then
				sprite = "particle/smokestack"
			elseif chance == 2 then
				sprite = "particles/smokey"
			elseif chance == 3 then
				sprite = "particle/particle_smokegrenade"
			end

			local particle = self.Emitter:Add(sprite, Pos)
			particle:SetVelocity((SprayDirection * 1750 * i ^ 0.5 * Scayul + AddVel) * OASize)
			particle:SetAirResistance(600 / Scayul ^ 0.5)
			particle:SetGravity(Vector(0, 0, -3.25 * i))
			particle:SetDieTime(math.Rand(10, 30) * i ^ 0.25 / 2)
			particle:SetStartAlpha(math.Rand(150, 200))
			particle:SetEndAlpha(0)
			local Size = math.Clamp(math.Rand(200, 250) * Scayul / (i ^ 0.8), 0, 100) * OASize
			particle:SetStartSize(Size * math.Rand(0.9, 1.1))
			particle:SetEndSize(Size * math.Rand(0.9, 1.1) * 5)
			particle:SetRoll(0)
			particle:SetRollDelta(math.Rand(-1.5, 1.5))
			particle:SetLighting(false)
			particle:SetCollide(true)
			local ShadeVariation = math.Rand(0.95, 1.05)
			particle:SetColor(red * ShadeVariation, green * ShadeVariation, blue * ShadeVariation)
		end
	end

	self.Emitter:Finish()

	timer.Simple(0.05, function()
		for i = 1, 200 do
			timer.Simple(0.1 * i, function()
				local Emitter = ParticleEmitter(vOffset + AddVel * i / 10)

				if Emitter then
					for i = 0, (101 - i) * Scayul do
						local particle = Emitter:Add("sprites/mat_jack_nicespark", vOffset + VectorRand() * math.Rand(0, 2000) * Scayul)
						particle:SetVelocity(Vector(0, 0, 0))
						particle:SetAirResistance(1000)
						particle:SetGravity(Vector(0, 0, 0))
						particle:SetDieTime(0.075)
						particle:SetStartAlpha(255 * ((101 - i) / 101))
						particle:SetEndAlpha(0)
						particle:SetStartSize(400 / i * OASize)
						particle:SetEndSize(0)
						particle:SetRoll(0)
						particle:SetRollDelta(math.Rand(-1, 1))
						particle:SetLighting(false)
						particle:SetColor(255, 255, 255)
						particle:SetCollide(false)
					end

					Emitter:Finish()
				end
			end)
		end
	end)

	local dlight = DynamicLight(self:EntIndex())

	if dlight then
		dlight.Pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.Brightness = 10 * self.Scale
		dlight.Size = 60000 * self.Scale
		dlight.Decay = 500 * self.Scale ^ 0.5
		dlight.DieTime = CurTime() + 0.2
		dlight.Style = 0
	end
end

function EFFECT:Think()
	if self.TimeToDie > CurTime() then
		return true
	else
		return false
	end
end

function EFFECT:Render()
	local TimeLeft = self.TimeToDie - CurTime()
	local TimeFraction = TimeLeft / (0.1 * self.Scale)
	local ReverseFraction = 1 - TimeFraction
	render.SetMaterial(Shit)
	render.DrawSprite(self.Position, 5000 * TimeFraction * self.Scale, 5000 * TimeFraction * self.Scale, Color(255, 255, 255, 255 * TimeFraction))
	render.DrawSprite(self.Position, 15000 * TimeFraction * self.Scale, 15000 * TimeFraction * self.Scale, Color(255, 255, 255, 255 * TimeFraction))
	render.DrawSprite(self.Position, 25000 * TimeFraction * self.Scale, 25000 * TimeFraction * self.Scale, Color(255, 255, 255, 255 * TimeFraction))
end
