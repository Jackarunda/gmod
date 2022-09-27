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
	local Scayul = data:GetScale() / 5000
	self.Scayul = Scayul
	local particle = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), Pos)
	particle:SetVelocity(VectorRand() * math.Rand(0, 200))
	particle:SetAirResistance(2200)
	particle:SetGravity(Vector(0, 0, math.Rand(400, 1500)))
	particle:SetDieTime(math.Rand(.2, .75) * Scayul)
	particle:SetStartAlpha(math.Rand(200, 255))
	particle:SetEndAlpha(0)
	particle:SetStartSize(0)
	particle:SetEndSize(200 * Scayul ^ .5)
	particle:SetRoll(math.Rand(20, 80))
	particle:SetRollDelta(math.Rand(-3, 3))
	local derg = math.Rand(200, 255)
	particle:SetColor(derg, derg, derg - math.random(0, 50))
	particle:SetLighting(false)
	particle:SetCollide(true)
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
	particle:SetVelocity(VectorRand() * math.Rand(0, 200))
	particle:SetAirResistance(400)
	particle:SetGravity(Vector(0, 0, math.Rand(0, 600) * Scayul) + VectorRand() * math.Rand(0, 400) * Scayul)
	particle:SetDieTime(math.Rand(5, 25) * Scayul ^ .5)
	particle:SetStartAlpha(math.Rand(100, 255))
	particle:SetEndAlpha(0)
	particle:SetStartSize(60 * Scayul)
	particle:SetEndSize(math.Rand(150, 175) * Scayul)
	particle:SetRoll(math.Rand(-3, 3))
	particle:SetRollDelta(math.Rand(-1, 1))
	particle:SetLighting(true)
	particle:SetCollide(true)
	local darg = math.Rand(20, 200)
	particle:SetColor(darg, darg, darg)
	self.Emitter:Finish()
	local dlight = DynamicLight(self:EntIndex())
	local Randem = math.Rand(0.75, 1)

	if dlight then
		dlight.Pos = Pos
		dlight.r = 255 * Randem
		dlight.g = 200 * Randem
		dlight.b = 175 * Randem
		dlight.Brightness = 2 * Scayul ^ 0.5
		dlight.Size = 2000 * Scayul ^ 0.5
		dlight.Decay = 18000
		dlight.DieTime = CurTime() + 0.1
		dlight.Style = 0
	end
end

function EFFECT:Think()
end

function EFFECT:Render()
end
