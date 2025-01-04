-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Poison Gas"
ENT.Author = "Jackarunda"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZgasParticle = true
ENT.ThinkRate = 1
ENT.JModDontIrradiate = true
ENT.AffectRange = 300
ENT.MaxLife = 100
ENT.MaxVel = 80
--

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:SetModelScale(2)
		self.NextDmg = Time + 5
		self.CurVel = self.CurVel or VectorRand() * 10
		self.AirResistance = 2
		self:SetLifeTime(math.random(self.MaxLife * .5, self.MaxLife) * JMod.Config.Particles.PoisonGasLingerTime)
		if self.CustomInit then
			self:CustomInit()
		end
	end

	function ENT:SetLifeTime(tim)
		local Time = CurTime()
		self.LifeTime = tim
		self.DieTime = Time + self.LifeTime
	end

	function ENT:ShouldDamage(ent)
		if not IsValid(ent) then return false end
		if ent.EZgasParticle == true then return false end
		if (ent.EZcoughTime or 0) > CurTime() then return false end
		if ent:IsPlayer() then return ent:Alive() end

		if (ent:IsNPC() or ent:IsNextBot()) and ent.Health and ent:Health() then
			local Phys = ent:GetPhysicsObject()

			if IsValid(Phys) then
				local Mat = Phys:GetMaterial()

				if Mat then
					if Mat == "metal" then return false end
					if Mat == "default" then return false end
				end
			end

			return ent:Health() > 0
		end

		return false
	end

	function ENT:CanSee(ent)
		local Tr = util.TraceLine({
			start = self:GetPos(),
			endpos = ent:GetPos(),
			filter = {self, ent, self.Canister},
			mask = MASK_SHOT+MASK_WATER
		})
		return not Tr.Hit
	end

	function ENT:DamageObj(obj)
		local Dmg, Helf = DamageInfo(), obj:Health()
		Dmg:SetDamageType(DMG_NERVEGAS)
		Dmg:SetDamage(math.random(3, 10) * JMod.Config.Particles.PoisonGasDamage)
		Dmg:SetInflictor(self)
		Dmg:SetAttacker(JMod.GetEZowner(self) or self)
		Dmg:SetDamagePosition(obj:GetPos())
		obj:TakeDamageInfo(Dmg)

		if (obj:Health() < Helf) and obj:IsPlayer() then
			JMod.Hint(obj, "gas damage")
			local inhaleProt, skinProt, eyeProt = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)

			if eyeProt < .5 then
				net.Start("JMod_VisionBlur")
				net.WriteFloat(1 * math.Clamp(1 - eyeProt, 0, 1))
				net.WriteFloat(2)
				net.WriteBit(false)
				net.Send(obj)
			end

			if inhaleProt < .75 then
				JMod.TryCough(obj)
			else
				obj.EZcoughTime = CurTime() + .5
			end
		end
	end

	function ENT:Think()
		if CLIENT then return end
		local Time, SelfPos, ThinkRateHz = CurTime(), self:GetPos(), self.ThinkRate

		if self.DieTime < Time then
			self:Remove()
			return
		end

		local OldPos = self:GetPos()
		if self.CalcMove then
			self:CalcMove(ThinkRateHz)
		else
			local Force = VectorRand(-4, 4) + Vector(0, 0, -8) + JMod.Wind * 4

			for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange)) do
				if math.random(1, 2) == 1 and not (obj == self) and self:CanSee(obj) then
					if obj.EZgasParticle and not(obj.EZvirusParticle) then
						-- repel in accordance with Ideal Gas Law
						local NormVec = (obj:GetPos() - SelfPos):GetNormalized()
						Force = Force - NormVec * .5
					elseif (self.NextDmg < Time) and self:ShouldDamage(obj) then
						self:DamageObj(obj)
					end
				end
			end
		
			-- apply acceleration
			self.CurVel = self.CurVel + (Force / ThinkRateHz)

			-- apply air resistance
			--self.CurVel = self.CurVel / (self.AirResistance / ThinkRateHz)

			-- apply max velocity
			self.CurVel = self.CurVel:GetNormalized() * math.min(self.CurVel:Length(), self.MaxVel)

			-- observe current velocity
			local NewPos = SelfPos + (self.CurVel / ThinkRateHz)

			-- make sure we're not gonna hit something. If so, bounce
			local MoveTrace = util.TraceLine({
				start = SelfPos,
				endpos = NewPos,
				filter = { self, self.Canister },
				mask = MASK_SHOT+MASK_WATER
			})
			if MoveTrace.StartSolid or (bit.band(util.PointContents(MoveTrace.HitPos), CONTENTS_WATER) == CONTENTS_WATER) then
				SafeRemoveEntity(self)

				return
			end
			if not MoveTrace.Hit then
				-- move unobstructed
				self:SetPos(NewPos)
			else
				if MoveTrace.HitSky then
					SafeRemoveEntity(self)
	
					return
				end
				-- bounce in accordance with Ideal Gas Law
				self:SetPos(MoveTrace.HitPos + MoveTrace.HitNormal * 1)
				local CurVelAng, Speed = self.CurVel:Angle(), self.CurVel:Length()
				CurVelAng:RotateAroundAxis(MoveTrace.HitNormal, 180)
				local H = Vector(self.CurVel.x, self.CurVel.y, self.CurVel.z)
				self.CurVel = -(CurVelAng:Forward() * Speed)
			end
		end

		--debugoverlay.Line(OldPos, self:GetPos(), 2, Color(0, 89, 255), true)

		-- self:Extinguish()

		-- YOU BETTER THINK AGAIN!
		self:NextThink(Time + math.random(1 / ThinkRateHz, 1.5 / ThinkRateHz))
		return true
	end

	function ENT:OnTakeDamage(dmginfo)
		-- herp
	end

	function ENT:Use(activator, caller)
		-- horp
	end

	function ENT:GravGunPickupAllowed(ply)
		return false
	end

	function ENT:GravGunPunt(ply)
		return false
	end
elseif CLIENT then
	local Mat = Material("particle/smokestack")
	local DebugMat = Material("sprites/mat_jack_jackconfetti")
	local Cheating = GetConVar("sv_cheats")

	function ENT:Initialize()
		self.Col = Color(math.random(120, 120), math.random(120, 150), 75)
		self.Visible = true
		self.Show = true
		self.siz = math.random(50, 150)
		self.LastPos = self:GetPos()

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = math.random(1, 5) == 1
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
	end

	function ENT:DrawTranslucent()
		self.DebugShow = (LocalPlayer().EZshowGasParticles and Cheating:GetBool()) or false
		if self.DebugShow then
			render.SetMaterial(DebugMat)
			render.DrawSprite(self:GetPos(), 50, 50, Color(134, 224, 60, 200))
		end

		local Time = CurTime()

		if self.NextVisCheck < Time then
			self.NextVisCheck = Time + 1
			self.Show = self.Visible and 1 / FrameTime() > 50
		end

		if self.Show then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(self.LastPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, 25))
			self.LastPos = LerpVector(FrameTime() * 1, self.LastPos, self:GetPos())
		end
	end
end
