-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Nuclear Fallout"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZfalloutParticle = true
ENT.JModDontIrradiate = true
ENT.AffectRange = 500
ENT.ThinkRate = .5
ENT.MaxLifeTime = 200
--

if SERVER then
	function ENT:CustomInit()
		local Time = CurTime()
		self.MaxVel = 250
		self:SetLifeTime(math.random(100, 200) * JMod.Config.Particles.NuclearRadiationMult)
		self.NextDmg = Time + math.random(1, 10)
		--self.FalloutEff = true--math.random(1, 5) == 1
	end

	function ENT:ShouldDamage(ent)
		return (JMod.ShouldDamageBiologically(ent) and (math.random(1, 5) == 1))
	end

	function ENT:DamageObj(obj)
		JMod.FalloutIrradiate(self, obj)
		self.NextDmg = CurTime() + math.random(1, 5)
	end

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos, Time = self:GetPos(), CurTime()
		local RandDir = Vector(math.random(-10, 10), math.random(-10, 10), math.random(-20, 5))
		--RandDir.z = RandDir.z / 2
		local Force = RandDir + (JMod.Wind * 10)

		local NearbyParticles = 0
		for key, obj in ipairs(ents.FindInSphere(SelfPos, self.AffectRange*1.5)) do
			if not(obj == self) and self:CanSee(obj) then
				if obj.EZgasParticle and not(obj.EZvirusParticle) then
					-- repel in accordance with Ideal Gas Law
					local Vec = (obj:GetPos() - SelfPos):GetNormalized()
					Force = Force - Vec * 1
					NearbyParticles = NearbyParticles + 1
				elseif self.NextDmg < Time and SelfPos:Distance(obj:GetPos()) <= self.AffectRange and self:ShouldDamage(obj) then
					self:DamageObj(obj)
				end
			end
		end

		if (NearbyParticles > 15) then
			self.NearbyParticleTick = (self.NearbyParticleTick or 0) + 1
			if (self.NearbyParticleTick > 10) then
				debugoverlay.Cross(SelfPos, 10, 2, Color(255, 38, 0), true)
				SafeRemoveEntity(self)
			end
		else
			self.NearbyParticleTick = 0
		end
	
		-- apply acceleration
		self.CurVel = self.CurVel + Force / ThinkRateHz

		-- apply air resistance
		--self.CurVel = self.CurVel / 1.5
		self.CurVel = Vector(math.Clamp(self.CurVel.x, -self.MaxVel, self.MaxVel), math.Clamp(self.CurVel.y, -self.MaxVel, self.MaxVel), math.Clamp(self.CurVel.z, -self.MaxVel, self.MaxVel))

		-- observe current velocity
		local NewPos = SelfPos + self.CurVel / ThinkRateHz

		-- make sure we're not gonna hit something. If so, bounce
		local MoveTrace = util.TraceLine({
			start = SelfPos,
			endpos = NewPos,
			filter = { self, self.Canister },
			mask = MASK_SOLID+MASK_WATER
		})
		if not MoveTrace.Hit then
			-- move unobstructed
			self:SetPos(NewPos + MoveTrace.HitNormal * 20)
		else
			if MoveTrace.HitSky and math.random(1, 3) == 1 then
				SafeRemoveEntity(self)

				return
			end
			-- bounce in accordance with Ideal Gas Law
			self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 1)
			local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length()
			CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
			local H = Vector(self.CurVel.x, self.CurVel.y, self.CurVel.z)
			self.CurVel = -(CurVelAng:Forward() * Speed * .5) -- Except for this part
		end

		--[[if self.FalloutEff and self.NextDmg < Time then
			Feff = EffectData()
			Feff:SetOrigin(self:GetPos())
			Feff:SetStart(self.CurVel / 500)
			Feff:SetScale(1)
			util.Effect("eff_jack_gmod_ezfalloutdust", Feff, true, false)
		end--]]
	end
	--
elseif CLIENT then
	--[[function ENT:Initialize()
		self:SetModelScale(10, 0)
	end]]--
	local DebugMat = Material("sprites/mat_jack_jackconfetti")
	local Cheating = GetConVar("sv_cheats")

	function ENT:DrawTranslucent()
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
		if self.DebugShow then
			render.SetMaterial(DebugMat)
			render.DrawSprite(self:GetPos(), 100, 100, Color(82, 77, 65, 200))
		end
	end
end
