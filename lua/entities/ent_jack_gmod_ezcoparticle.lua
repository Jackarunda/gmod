-- Based off of JMOD EZ Gas Particle, created by Freaking Fission, uses some code from GChem
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ Carbon-monoxide Gas"
ENT.Author = "Jackarunda, Freaking Fission"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.ThinkRate = 2
ENT.AffectRange = 200
ENT.MaxLife = 120
ENT.MaxVel = 100
--

if SERVER then
	function ENT:CustomInit()
		local Time = CurTime()
		self.NextDmg = Time + 2.5
		self.CurVel = self.CurVel or VectorRand() * 50
		self.AirResistance = 1
	end

	function ENT:DamageObj(obj)
		local Time = CurTime()
		if obj:IsPlayer() then
			local inhaleProt, skinProt, eyeProt = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)

			JMod.DepleteArmorChemicalCharge(obj, (inhaleProt) * .02)

			if inhaleProt < .75 then
				JMod.TryCough(obj)
				if math.random(1, 10) == 1 then
					local Dmg = DamageInfo()
					Dmg:SetDamageType(DMG_NERVEGAS)
					Dmg:SetDamage(math.random(3, 10) * JMod.Config.Particles.PoisonGasDamage)
					Dmg:SetInflictor(self)
					Dmg:SetAttacker(JMod.GetEZowner(self))
					Dmg:SetDamagePosition(obj:GetPos())
					obj:TakeDamageInfo(Dmg)
				end
			else
				obj.EZcoughTime = Time + .5
			end
		elseif obj:IsNPC() then
			obj.EZNPCincapacitate = Time + math.Rand(2, 5)
		end
	end

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos, Time = self:GetPos(), CurTime()
		local RandDir = VectorRand(-6, 6)
		RandDir.z = RandDir.z * .5
		local Force = RandDir + (JMod.Wind * 4) + Vector(0, 0, -8)

		for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange)) do
			if math.random(1, 2) == 1 and not (obj == self) and self:CanSee(obj) then
				if obj.EZgasParticle and not(obj.EZvirusParticle) then
					-- repel in accordance with Ideal Gas Law
					local Vec = (obj:GetPos() - SelfPos):GetNormalized()
					Force = Force - Vec * .5
				elseif self.NextDmg < Time and self:ShouldDamage(obj) then
					self:DamageObj(obj)
				end
			end
		end
	
		-- apply acceleration
		self.CurVel = self.CurVel + Force / ThinkRateHz

		-- apply air resistance
		--self.CurVel = self.CurVel / 1.5

		-- apply max velocity
		self.CurVel = self.CurVel:GetNormalized() * math.min(self.CurVel:Length(), self.MaxVel)

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
			self:SetPos(NewPos + MoveTrace.HitNormal * 1)
		else
			-- bounce in accordance with Ideal Gas Law
			self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 10)
			local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length() * .8
			CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
			local H = Vector(self.CurVel.x, self.CurVel.y, self.CurVel.z)
			self.CurVel = -(CurVelAng:Forward() * Speed)
		end
	end

elseif CLIENT then
	local Mat = Material("effects/smoke_b")
	local DebugMat = Material("sprites/mat_jack_jackconfetti")
	local Cheating = GetConVar("sv_cheats")

	function ENT:Initialize()
		self.Col = Color(124, 124, 124)
		self.Visible = true
		self.Show = true
		self.siz = .5
		self.RenderPos = self:GetPos()

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = math.random(1, 2) == 2
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
	end

	function ENT:DrawTranslucent()
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
		if self.DebugShow then
			render.SetMaterial(DebugMat)
			render.DrawSprite(self:GetPos(), 50, 50, Color(48, 48, 48, 200))
		end

		local Time = CurTime()

		if self.Visible then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(self.RenderPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, 5))
			self.RenderPos = LerpVector(FrameTime() * 1, self.RenderPos, SelfPos)
			self.siz = math.Clamp(self.siz + FrameTime() * 200, 0, 500)
		end
	end
end
