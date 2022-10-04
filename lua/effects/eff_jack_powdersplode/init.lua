local matRefraction = Material("refract_ring")
local tMats = {}
tMats.Glow1 = Material("sprites/light_glow02")
--tMats.Glow1=Material("models/roller/rollermine_glow")
tMats.Glow2 = Material("sprites/yellowflare")
tMats.Glow3 = Material("sprites/redglow2")

for _, mat in pairs(tMats) do
	mat:SetInt("$spriterendermode", 9)
	mat:SetInt("$ignorez", 1)
	mat:SetInt("$illumfactor", 8)
end

function EFFECT:Init(data)
	self.Position = data:GetOrigin()
	self.Position.z = self.Position.z + 4
	self.TimeLeft = CurTime() + 1
	self.GAlpha = 254
	self.DerpAlpha = 254
	self.GSize = 200
	self.CloudHeight = 1 * 2.5
	self.Refract = 0
	self.Size = 48

	if render.GetDXLevel() <= 81 then
		matRefraction = Material("effects/strider_pinch_dudv")
	end

	self.SplodeDist = 2000
	self.BlastSpeed = 6000
	self.lastThink = 0
	self.MinSplodeTime = CurTime() + self.CloudHeight / self.BlastSpeed
	self.MaxSplodeTime = CurTime() + 6
	self.GroundPos = self.Position - Vector(0, 0, self.CloudHeight)
	local Pos = self.Position
	local Velo = data:GetStart()
	self.smokeparticles = {}
	self.Emitter = ParticleEmitter(Pos)
	local spawnpos = Pos
	local Scayul = data:GetScale()
	self.Scayul = Scayul
	local AddVel = Vector(0, 0, 0)

	for cake = 0, 20 do
		local SprayDirection = VectorRand()

		for p = 0, 10 * Scayul do
			local particle = self.Emitter:Add("sprites/mat_jack_nicespark", Pos)
			particle:SetVelocity(AddVel + VectorRand() * math.Rand(100, 5000) * Scayul ^ .5 + Velo)
			particle:SetAirResistance(20)
			particle:SetDieTime(math.Rand(2, 3))
			particle:SetColor(255, 200, 175)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(3, 20) * Scayul ^ .5)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetCollide(true)
			particle:SetLighting(false)
			particle:SetBounce(0.5)
		end

		for i = 0, 6 * Scayul ^ .5 do
			local Inverse = 6 * Scayul ^ .5 - i
			local particle = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), Pos)
			particle:SetVelocity(SprayDirection * 10000 * i * Scayul ^ .5 + AddVel + Velo)
			particle:SetAirResistance(2200)
			particle:SetGravity(Vector(0, 0, math.Rand(400, 1500)))
			particle:SetDieTime(math.Rand(.2, .7) * Scayul)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(150 * Scayul ^ .5 * Inverse + 1)
			particle:SetRoll(math.Rand(20, 80))
			particle:SetRollDelta(math.Rand(-3, 3))
			local derg = math.Rand(200, 255)
			particle:SetColor(derg, derg, derg - math.random(0, 50))
			particle:SetLighting(false)
			particle:SetCollide(true)

			timer.Simple(.1, function()
				local Emitter = ParticleEmitter(Pos)
				local sprite
				local chance = math.random(1, 6)

				if chance == 1 then
					sprite = "particle/smokestack"
				elseif chance == 2 then
					sprite = "particles/smokey"
				elseif chance == 3 then
					sprite = "particle/particle_smokegrenade"
				elseif chance == 4 then
					sprite = "sprites/mat_jack_smoke1"
				elseif chance == 5 then
					sprite = "sprites/mat_jack_smoke2"
				elseif chance == 6 then
					sprite = "sprites/mat_jack_smoke3"
				end

				local particle = Emitter:Add(sprite, Pos)
				particle:SetVelocity(SprayDirection * 1000 * i * Scayul ^ .5 + AddVel + Velo)
				particle:SetAirResistance(200)
				particle:SetGravity(Vector(0, 0, math.Rand(0, 600) * Scayul) + VectorRand() * math.Rand(0, 400) * Scayul)
				particle:SetDieTime(math.Rand(1, 10) * Scayul ^ .5)
				particle:SetStartAlpha(math.Rand(100, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(40 * Scayul ^ .5 * Inverse + .2)
				particle:SetEndSize(math.Rand(180, 200) * Scayul ^ .5 * Inverse + 20)
				particle:SetRoll(math.Rand(-3, 3))
				particle:SetRollDelta(math.Rand(-1, 1))
				particle:SetLighting(true)
				particle:SetCollide(true)
				local darg = math.Rand(200, 255)
				particle:SetColor(darg, darg, darg)
				Emitter:Finish()
			end)
		end
	end

	self.Emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())
	local Randem = math.Rand(0.75, 1)

	if dlight then
		dlight.Pos = Pos
		dlight.r = 255 * Randem
		dlight.g = 200 * Randem
		dlight.b = 175 * Randem
		dlight.Brightness = 5 * Scayul ^ 0.5
		dlight.Size = 8000 * Scayul ^ 0.5
		dlight.Decay = 8000
		dlight.DieTime = CurTime() + 0.2
		dlight.Style = 0
	end
end

function EFFECT:Think()
end

function EFFECT:Render()
end
