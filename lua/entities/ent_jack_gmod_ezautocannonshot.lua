-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Autocannon Shot"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.NoPhys = true
ENT.IsEZrocket = true
local ThinkRate = 22 --Hz

---
if SERVER then
	function ENT:Initialize()
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)
		self:SetCollisionBounds(Vector(-20, -20, -10), Vector(20, 20, 10))
		self:PhysicsInitBox(Vector(-20, -20, -10), Vector(20, 20, 10))
		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableCollisions(false)
		end

		self:SetNotSolid(true)
		self.NextDet = 0
		self.FuelLeft = 100
		self.DieTime = CurTime() + 10
		self.NextThrust = 0
		self:Think()
	end

	function ENT:Detonate(tr)
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att, Dir = (tr and tr.HitPos + tr.HitNormal * 5) or self:GetPos() + Vector(0, 0, 30), self.EZowner or self, -self:GetRight()
		JMod.Sploom(Att, SelfPos, 10)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 300)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		---

		if (tr.Hit and tr.Entity and IsValid(tr.Entity)) then -- deal direct bullet impact damage since this is a high-speed projectile
			self:FireBullets({
				Damage = self.Damage * 3,
				Force = self.Damage * 10,
				Num = 1,
				Tracer = 0,
				Spread = Vector(0, 0, 0),
				Src = self:GetPos(),
				Dir = Dir,
				Attacker = Att
			})
		end

		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 50), self.BlastRadius or 100, self.Damage or 100)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				if math.random(1, 4) == 1 then
					ent:Fire("selfdestruct", "", math.Rand(0, 2))
				end
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, .3)
		JMod.BlastDoors(self, SelfPos, 1.5)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos - Dir * 100, Dir * 300)

			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		self:Remove()
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(), -90)

		timer.Simple(.1, function()
			ParticleEffect("50lb_air", SelfPos - Dir * 20, Ang)
		end)
	end

	function ENT:OnRemove()
		--
	end

	--
	local LastTime = 0

	function ENT:Think()
		local Time, Pos, Dir, Speed = CurTime(), self:GetPos(), self.CurVel:GetNormalized(), self.CurVel:Length()
		local Tr

		if self.InitialTrace then
			Tr = self.InitialTrace
			self.InitialTrace = nil
		else
			local Filter = {self}

			table.insert(Filter, self:GetOwner())
			--Tr=util.TraceLine({start=Pos,endpos=Pos+self.CurVel/ThinkRate,filter=Filter})
			local Mask, HitWater, HitChainLink = MASK_SHOT, false, true

			if HitWater then
				Mask = Mask + MASK_WATER
			end

			if HitChainLink then
				Mask = nil
			end

			Tr = util.TraceHull({
				start = Pos,
				endpos = Pos + self.CurVel / ThinkRate,
				filter = Filter,
				mins = Vector(-3, -3, -3),
				maxs = Vector(3, 3, 3),
				mask = Mask
			})
		end

		if Tr.Hit then
			if Tr.HitSky then
				self:Remove()

				return
			end

			self:Detonate(Tr)
		else
			self:SetPos(Pos + self.CurVel / ThinkRate)
			self.CurVel = self.CurVel + physenv.GetGravity() / ThinkRate * 2
		end

		if IsValid(self) then
			if self.DieTime < Time then
				self:Detonate()

				return
			end

			self:NextThink(Time + (1 / ThinkRate))
		end

		LastTime = Time

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = JMod.MakeModel(self, "models/props_combine/headcrabcannister01a.mdl")
		self.RenderPos = self:GetPos()
		self.NextRender = CurTime() + .05
	end

	function ENT:OnRemove()
		if IsValid(self.Mdl) then
			self.Mdl:Remove()
		end
	end

	--
	local GlowSprite = Material("mat_jack_gmod_glowsprite")

	function ENT:Think()
		--
	end

	function ENT:Draw()
		if self.NextRender > CurTime() then return end
		local Pos, Ang, Dir = self.RenderPos, self:GetAngles(), self:GetRight()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		local RenderPos = Pos + Ang:Up() * 1.5 - Ang:Right() * 0 - Ang:Forward() * 1
		JMod.RenderModel(self.Mdl, RenderPos, Ang, Vector(.1, .1, .1), nil, nil, true)
		--
		self.RenderPos = LerpVector(FrameTime() * 20, self.RenderPos, self:GetPos())
	end
end
