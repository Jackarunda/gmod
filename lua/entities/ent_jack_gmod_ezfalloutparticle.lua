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
ENT.AffectRange = 2500
ENT.ThinkRate = 1
--

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self:SetModel("models/dav0r/hoverball.mdl")
		self:SetMaterial("models/debug/debugwhite")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableCollisions(false)
			phys:EnableGravity(false)
		end
		self.LifeTime = self.LifeTime or math.random(100, 200) * JMod.Config.Particles.NuclearRadiationMult
		self.DieTime = Time + self.LifeTime
		self.NextDmg = Time + math.random(1, 10)
		self.FalloutEff = true--math.random(1, 5) == 1
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
		local RandDir = Vector(math.random(-200, 200), math.random(-200, 200), math.random(-100, 100))
		--RandDir.z = RandDir.z / 2
		local Force = RandDir + (JMod.Wind * 3) + Vector(0, 0, -50)

		local NearbyParticles = 0
		for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange*2)) do
			if math.random(1, 2) == 1 and not (obj == self) and self:CanSee(obj) then
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
	
		-- apply acceleration
		self.CurVel = self.CurVel + Force / ThinkRateHz

		-- apply air resistance
		self.CurVel = self.CurVel / 1.5

		-- observe current velocity
		local NewPos = SelfPos + self.CurVel / ThinkRateHz

		-- make sure we're not gonna hit something. If so, bounce
		local MoveTrace = util.TraceLine({
			start = SelfPos,
			endpos = NewPos,
			filter = { self, self.Canister },
			mask = MASK_SHOT+MASK_WATER
		})
		if not MoveTrace.Hit then
			-- move unobstructed
			self:SetPos(NewPos)
		else
			-- bounce in accordance with Ideal Gas Law
			self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 1)
			local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length()
			CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
			local H = Vector(self.CurVel.x, self.CurVel.y, self.CurVel.z)
			self.CurVel = -(CurVelAng:Forward() * Speed * 2)
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

	function ENT:DrawTranslucent()
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		if self.DebugShow then
			self:DrawModel()
			self:SetModelScale(10, 0)
		end
	end
end
