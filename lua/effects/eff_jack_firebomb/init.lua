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
	self.smokeparticles = {}
	self.Emitter = ParticleEmitter(Pos)
	local FireEmitter = ParticleEmitter(Pos)
	local SmokeEmitter = ParticleEmitter(Pos)
	local spawnpos = Pos
	local Scayul = data:GetScale() or 1
	self.Scayul = Scayul
	local AddVel = (data:GetNormal() or Vector(0, 0, -1)) * 100

	for k = 0, 7 * Scayul do
		local SprayDirection = (VectorRand() + (AddVel / 2):GetNormalized()):GetNormalized()
		local particle = self.Emitter:Add("sprites/mat_jack_nicespark", Pos)
		particle:SetVelocity(SprayDirection * 200 * 30 * Scayul + AddVel)
		particle:SetAirResistance(100)
		particle:SetDieTime(math.Rand(2, 3))
		particle:SetColor(255, 200, 175)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(60, 80) * Scayul)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-360, 360))
		particle:SetRollDelta(math.Rand(-0.21, 0.21))
		particle:SetGravity(Vector(0, 0, -600))
		particle:SetCollide(true)
		particle:SetLighting(false)
		particle:SetBounce(0.9)

		for p = 0, 30 * Scayul do
			local particle = self.Emitter:Add("sprites/mat_jack_nicespark", Pos)
			particle:SetVelocity(AddVel + VectorRand() * math.Rand(100, 3000) * Scayul)
			particle:SetAirResistance(20)
			particle:SetDieTime(math.Rand(2, 3))
			particle:SetColor(255, 200, 175)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(255)
			particle:SetStartSize(math.Rand(10, 45) * Scayul)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(-360, 360))
			particle:SetRollDelta(math.Rand(-0.21, 0.21))
			particle:SetGravity(Vector(0, 0, -600))
			particle:SetCollide(true)
			particle:SetLighting(false)
			particle:SetBounce(0.5)
		end

		for i = 0, 15 * Scayul do
			local Inverse = 50 * Scayul - i
			local particle = self.Emitter:Add("particle/smokestack", Pos)
			particle:SetVelocity(SprayDirection * 200 * i * Scayul + AddVel)
			particle:SetAirResistance(200)
			particle:SetGravity(Vector(0, 0, math.Rand(-200, -300)))
			particle:SetDieTime(math.Rand(2, 4) * Scayul)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(10 * Scayul * Inverse + 1)
			particle:SetRoll(math.Rand(20, 80))
			particle:SetRollDelta(math.Rand(-1, 1))
			local derg = math.Rand(200, 255)
			particle:SetColor(derg, derg, derg)
			particle:SetLighting(false)
			particle:SetCollide(true)

			timer.Simple(.75, function()
				if IsValid(FireEmitter) then
					local particle = FireEmitter:Add("particles/flamelet" .. math.random(1, 5), Pos)
					particle:SetVelocity(SprayDirection * 400 * i * Scayul + AddVel)
					particle:SetAirResistance(400)
					particle:SetGravity(Vector(0, 0, math.Rand(400, 1500)))
					particle:SetDieTime(math.Rand(2, 8) * Scayul)
					particle:SetStartAlpha(math.Rand(100, 150))
					particle:SetEndAlpha(0)
					particle:SetStartSize(0)
					particle:SetEndSize(20 * Scayul * Inverse + 1)
					particle:SetRoll(math.Rand(20, 80))
					particle:SetRollDelta(math.Rand(-3, 3))
					local derg = math.Rand(200, 255)
					particle:SetColor(derg, derg, derg - math.random(0, 50))
					particle:SetLighting(false)
					particle:SetCollide(true)
					local particle = FireEmitter:Add("particles/flamelet" .. math.random(1, 5), Pos)
					particle:SetVelocity(SprayDirection * 200 * i * Scayul + AddVel)
					particle:SetAirResistance(200)
					particle:SetGravity(Vector(0, 0, math.Rand(800, 1200)))
					particle:SetDieTime(math.Rand(2, 4) * Scayul)
					particle:SetStartAlpha(math.Rand(150, 200))
					particle:SetEndAlpha(0)
					particle:SetStartSize(0)
					particle:SetEndSize(7 * Scayul * Inverse + 1)
					particle:SetRoll(math.Rand(20, 80))
					particle:SetRollDelta(math.Rand(-3, 3))
					local derg = math.Rand(100, 150)
					particle:SetColor(derg + 100, derg, derg)
					particle:SetLighting(false)
					particle:SetCollide(true)
					FireEmitter:Finish()
				end

				timer.Simple(.75, function()
					if IsValid(SmokeEmitter) then
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

						local particle = SmokeEmitter:Add(sprite, Pos)
						particle:SetVelocity(SprayDirection * 800 * i * Scayul + AddVel)
						particle:SetAirResistance(800)
						particle:SetGravity(Vector(0, 0, math.Rand(200, 8000) * Scayul) + VectorRand() * math.Rand(0, 200) * Scayul)
						particle:SetDieTime(math.Rand(3, 10) * Scayul)
						particle:SetStartAlpha(75)
						particle:SetEndAlpha(0)
						particle:SetStartSize(0)
						particle:SetEndSize(math.Rand(100, 300) * Scayul)
						particle:SetRoll(0)
						particle:SetRollDelta(math.Rand(-3, 3))
						particle:SetLighting(true)
						particle:SetCollide(true)
						local darg = math.Rand(20, 60)
						particle:SetColor(darg, darg, darg)
						SmokeEmitter:Finish()
					end
				end)
			end)
		end
	end

	self.Emitter:Finish()
end

function EFFECT:Think()
end

function EFFECT:Render()
end
