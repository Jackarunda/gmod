AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Projectile"
ENT.KillName = "Projectile"
ENT.NoSitAllowed = true
ENT.MaxLifeTime = 5
ENT.DefaultSpeed = 600
ENT.FireEffect = "eff_jack_gmod_fire"
-- this has been copied over from Slayer and modified (a lot), which is why it looks so weird
-- Halo FTW
local ThinkRate = 22 --Hz

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 1, "Burning")
end

if SERVER then
	function ENT:Initialize()
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(false)
		self:SetNotSolid(true)
		self.Impacted = false
		self.Stuck = false
		self.StuckEnt = nil
		self.Detonating = false
		self.Armed = false
		self.ArmTime = 0
		self.NextFizz = 0
		self.DamageMul = (self.DamageMul or 1) * math.Rand(.9, 1.1)
		self.SpeedMul = self.SpeedMul or 1
		self.Bounces = 0
		self.MaxBounces = self.MaxBounces or 10
		self.LifeTime = self.LifeTime or math.Rand(self.MaxLifeTime * .1, self.MaxLifeTime)
		if self.Burnin == nil then self.Burnin = true end
		self:SetBurning(self.Burnin)
		---- compensate for inherited velocity ----
		local CurVel = self:GetForward() * self.DefaultSpeed * self.SpeedMul
		local NewVel = CurVel + (self.InitialVel or Vector(0, 0, 100))
		self:SetAngles(NewVel:Angle())
		self.CurVel = NewVel
		self.InitialVel = nil
	end

	local function Inflictor(ent)
		if not IsValid(ent) then return game.GetWorld() end
		local Infl = ent:GetDTEntity(0)
		if IsValid(Infl) then return Infl end

		return ent
	end

	function ENT:Think()
		local Time, Pos = CurTime(), self:GetPos()

		if (self.ArmTime < Time) and not self.Armed then
			self:Arm()
		end

		if self.Stuck then
			if not (IsValid(self.StuckEnt) or self.StuckEnt:IsWorld()) then
				self:Detonate()

				return
			end

			if self.StuckEnt:IsPlayer() and not self.StuckEnt:Alive() then
				self:Detonate()

				return
			end

			if self.StuckEnt:IsNPC() and not (self.StuckEnt:Health() > 0) then
				self:Detonate()

				return
			end

			return
		end

		local Tr

		if self.InitialTrace then
			Tr = self.InitialTrace
			self.InitialTrace = nil
		else
			local Filter = {self, self.Creator}

			--Tr=util.TraceLine({start=Pos,endpos=Pos+self.CurVel/ThinkRate,filter=Filter})
			local Mask, HitWater, HitChainLink = MASK_SHOT, true, false

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
			local Surface = util.GetSurfacePropName(Tr.SurfaceProps)
			local Solid = Surface ~= "water" and Surface ~= "default"

			if Tr.HitSky then
				SafeRemoveEntity(self)

				return
			end

			if IsValid(Tr.Entity) and Tr.Entity.JMod_NapalmBounce then
				local OldVel = self.CurVel
				local OurSpeed = OldVel:Length()
				local NewVec = Tr.Normal:Angle()
				NewVec:RotateAroundAxis(Tr.HitNormal, 180 + math.random(-10, 10))
				NewVec = NewVec:Forward()
				self.CurVel = (-NewVec * OurSpeed) / 2
				self.LifeTime = (self.LifeTime or 1) + .5
				self:SetPos(Tr.HitPos + OldVel:GetNormalized() * -10)
				--debugoverlay.Cross(Tr.HitPos, 5, 5, Color(255, 0, 0), true)
				--debugoverlay.Line(Tr.HitPos, Tr.HitPos + OldVel, 5, Color(255, 255, 0), true)
			else
				self:Detonate(Tr)
			end
		else
			self:SetPos(Pos + self.CurVel / ThinkRate)

			if self.NextFizz < Time and (self.Armed or not self.ArmTime) then
				self.NextFizz = Time + .2

				if math.random(1, 2) == 1 then
					local Zap = EffectData()
					if not self.Burnin then
						--[[Zap:SetOrigin(Pos)
						Zap:SetStart(self.CurVel:GetNormalized() * 1)
						Zap:SetScale(2)
						util.Effect("eff_jack_gmod_spranklerspray", Zap, true, true)--]]
					else
						Zap:SetOrigin(Pos + self.CurVel / ThinkRate)
						Zap:SetStart(self.CurVel)
						util.Effect(self.FireEffect, Zap, true, true)
					end
				end
			end

			self.CurVel = self.CurVel + physenv.GetGravity() / ThinkRate * .5
		end

		self.LifeTime = (self.LifeTime or 1) - (1 / ThinkRate)
		if self.LifeTime < 0 then
			self:Detonate()

			return
		end

		self:NextThink(Time + (1 / ThinkRate))
		self:SetAngles(self.CurVel:Angle())

		return true
	end

	function ENT:Arm()
		self.Armed = true
	end

	--[[function ENT:Stick(tr)
		self.Impacted = true
		self.Detonating = true
		self.Stuck = true
		self.StuckEnt = tr.Entity
	end]]--

	function ENT:OnTakeDamage(dmg)
		--[[if dmg:IsDamageType(DMG_BURN) then
			self:Detonate()
		elseif dmg:IsExplosionDamage() then
			SafeRemoveEntityDelayed(self, 0)
		end--]]
	end

	function ENT:Detonate(tr)
		if self.Exploded then return end
		self.Exploded = true
		local Att, Pos = JMod.GetEZowner(self), (tr and tr.HitPos) or self:GetPos()

		if not IsValid(Att) then
			Att = self
		end

		if tr and tr.Hit then
			if self.Burnin and IsValid(tr.Entity) then
				local Mul = self.DamageMul
				local Dam = DamageInfo()
				Dam:SetDamageType(DMG_BURN)
				Dam:SetDamage(math.random(10, 20) * Mul)
				Dam:SetDamagePosition(Pos)
				Dam:SetAttacker(Att)
				Dam:SetInflictor(Inflictor(self))
				tr.Entity:TakeDamageInfo(Dam)
			end


			local Haz = ents.Create("ent_jack_gmod_ezfirehazard")

			if IsValid(Haz) then
				Haz:SetDTInt(0, 1)
				Haz:SetPos(tr.HitPos + tr.HitNormal * 2)
				Haz:SetAngles(tr.HitNormal:Angle())
				JMod.SetEZowner(Haz, JMod.GetEZowner(self))
				Haz.HighVisuals = self.HighVisuals
				Haz.Burnin = self.Burnin
				Haz:Spawn()
				Haz:Activate()
				
				if IsValid(tr.Entity) then
					Haz:SetParent(tr.Entity)
				end
			end

			SafeRemoveEntity(self)
		else
			if self.Burnin then
				local eff = EffectData()
				eff:SetOrigin(self:GetPos())
				eff:SetNormal(self.CurVel:GetNormalized())
				eff:SetScale(1)
				util.Effect("eff_jack_gmod_heavyfire", eff)
			end

			SafeRemoveEntityDelayed(self, .1)
		end
	end
elseif CLIENT then
	ENT.MawdelScale = .5

	function ENT:Initialize()
		self.RenderPos = self:GetPos() + self:GetForward() * 20
		self.RenderTime = CurTime() + .175 -- don't draw if we're not fucking moving, gmod sucks so bad
		self.Mawdel = ClientsideModel(Model("models/weapons/ar2_grenade.mdl"))
		self.Mawdel:SetModelScale(self.MawdelScale)
		self.Mawdel:SetMaterial("models/mat_jack_gmod_brightwhite")
		self.Mawdel:SetPos(self:GetPos())
		self.Mawdel:SetParent(self)
		self.Mawdel:SetNoDraw(true)
		self.SpawnTime = CurTime()
	end

	local GlowSprite, SplachSprite = Material("mat_jack_gmod_glowsprite"), Material("effects/jmod/splash2")

	function ENT:Think()
		self.Burnin = self:GetBurning()
		if self.Burnin and (math.random(1, 3) == 3) then
			local Pos, Dir, Ang = self.RenderPos, self:GetForward(), self:GetAngles()
			local dlight = DynamicLight(self:EntIndex())

			if dlight then
				dlight.pos = Pos - Dir * 15
				dlight.r = 255
				dlight.g = 255
				dlight.b = 255
				dlight.brightness = 2
				dlight.Decay = 1000
				dlight.Size = 200
				dlight.DieTime = CurTime() + .1
			end
		end
		self.RenderPos = LerpVector(FrameTime() * 20, self.RenderPos, self:GetPos())
	end

	function ENT:Draw()
		local Time = CurTime()
		local Lived, ScatterFrac = Time - self.SpawnTime, 1

		if not (self.Burnin) then
			render.SetMaterial(SplachSprite)
			render.DrawSprite(self.RenderPos, 100 * Lived, 100 * Lived, Color(255, 255, 255, 200 / Lived))
		else
			local Pos, Dir, Ang = self.RenderPos, self:GetForward(), self:GetAngles()
			self.Mawdel:SetRenderAngles(Ang)
			self.Mawdel:SetRenderOrigin(Pos)
			local OrigR, OrigG, OrigB = render.GetColorModulation()

			if Lived < .5 then
				ScatterFrac = Lived * 2
			end

			ScatterFrac = ScatterFrac - .3
			Pos = Pos + Dir * 10
			render.SetMaterial(GlowSprite)
			local Col = Color(255, 255, 255, math.random(0, 255))

			for i = 1, 10 do
				render.DrawSprite(Pos - Dir * i * 5 + VectorRand() * math.Rand(0, 2) * i * ScatterFrac, 30 * ScatterFrac, 30 * ScatterFrac, Col)
			end

			render.SetColorModulation(OrigR, OrigG, OrigB)
		end
	end
	function ENT:OnRemove()
		if IsValid(self.Mawdel) then
			self.Mawdel:Remove()
		end
	end
end
