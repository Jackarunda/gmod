-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Virus Particle"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZvirusParticle = true
ENT.AffectRange = 300
--

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self.LifeTime = math.random(50, 100) * JMod.Config.Particles.PoisonGasLingerTime
		self.DieTime = Time + self.LifeTime
		self.NextDmg = Time + 5
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self.CurVel = self.CurVel or VectorRand() * 10
	end

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos = self:GetPos()
		local Force = (VectorRand() * 40) + (JMod.Wind * 5) + Vector(0, 0, -15)

		if (self.NextDmg < CurTime()) then
			JMod.TryVirusInfectInRange(self, JMod.GetEZowner(self), 0, 0)
		end
	
		-- apply acceleration
		self.CurVel = self.CurVel + Force / ThinkRateHz

		-- apply air resistance
		self.CurVel = self.CurVel / 1

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
			self:SetPos(NewPos)
		else
			-- bounce in accordance with Ideal Gas Law
			self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 1)
			local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length()
			CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
			local H = Vector(self.CurVel.x, self.CurVel.y, self.CurVel.z)
			self.CurVel = -(CurVelAng:Forward() * Speed * 0.5) -- These particles aren't very 'gassy'
		end
	end

elseif CLIENT then
	local DebugMat = Material("sprites/mat_jack_jackconfetti")
	local Cheating = GetConVar("sv_cheats")
	function ENT:Initialize()
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
	end

	function ENT:DrawTranslucent()
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
		if self.DebugShow then
			render.SetMaterial(DebugMat)
			render.DrawSprite(self:GetPos(), 40, 40, Color(255, 166, 0, 200))
		end
	end
end
