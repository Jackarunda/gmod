local StreamSprite = Material("effects/bloodstream")
local GlowSprite = Material("sprites/mat_jack_basicglow")

function EFFECT:Init(data)
	local Dir = data:GetNormal()
	local Pos = data:GetOrigin()
	local Ent = data:GetEntity()
	local Scl = data:GetScale()
	local Time = CurTime()
	self.DieTime = Time + 2
	self.Particles = {}
	self.NumParticles = 10
	for i = 1, self.NumParticles do
		local Fraction = i / self.NumParticles
		local InverseFraction = 1 - Fraction
		timer.Simple(Fraction / 10, function()
			if IsValid(Ent) then
				if Ent:IsWeapon() then
					Pos = self:GetTracerShootPos(Pos, Ent, data:GetAttachment()) -- This causes bugs if the entity is undefiened
				else
					Pos = Ent:LocalToWorld(Pos)
				end
			end
			local InWater = bit.band(util.PointContents(Pos), CONTENTS_WATER) == CONTENTS_WATER
			local Scl = InWater and 10 or 3
			table.insert(self.Particles, {
				size = Scl,
				opacity = 255,
				pos = Pos,
				vel = Dir * 1500 + VectorRand() * 15,
				airResist = Fraction * Scl,
				stuck = false,
				posParticle = i == math.ceil(self.NumParticles * .6),
				growthSpeed = i / Fraction
			})
		end)
	end
end

function EFFECT:Think()
	local Time, FT = CurTime(), FrameTime() / GetConVar("host_timescale"):GetFloat()
	if (self.DieTime < Time) then return false end
	for k, v in pairs(self.Particles) do
		if not (v.stuck) then
			local Travel = v.vel * FT
			local Tr = util.TraceLine({
				start = v.pos,
				endpos = v.pos + Travel,
				mask = MASK_NPCWORLDSTATIC
			})
			if (Tr.Hit) then
				v.pos = Tr.HitPos + Tr.HitNormal
				v.stuck = true
			else
				v.pos = v.pos + Travel
			end
			if (v.posParticle) then self.Entity:SetPos(v.pos) end
			v.vel = v.vel - Vector(0, 0, 600  * FT)
			local AirLoss = FT * v.airResist + .01
			v.vel = v.vel * (1 - AirLoss)
			v.vel = v.vel + JMod.Wind * FT * 100
		end
		v.size = v.size + v.growthSpeed * .05 * ((v.stuck and 3) or 1)
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial(StreamSprite)
	local LastPos, Count = nil, 0
	for k, v in pairs(self.Particles) do
		if (v.size < 80) then
			local Sine = math.sin((Count / (self.NumParticles - 2)) * math.pi)
			if (LastPos) then
				local R = math.Clamp(175 + v.size * 1.5, 0, 255)
				local G = math.Clamp(200 + v.size * 1.5, 0, 255)
				local Mult = (v.stuck and 12) or 6
				local Col = Color(R, G, 255, 255 - math.Clamp(v.size * Mult, 0, 255))
				render.DrawBeam(LastPos, v.pos, v.size ^ 1.1, 1, 0, Col)
			end
			LastPos = v.pos
			Count = Count + 1
		end
	end

	--[[]
	render.SetMaterial(GlowSprite)
	for k, v in pairs(self.Particles) do
		render.DrawSprite(v.pos, 32 * (1/k), 32 * (1/k), color_white)
	end
	--]]
	--render.DrawSprite(self.Entity:GetPos(), 32, 32, color_white)
end
