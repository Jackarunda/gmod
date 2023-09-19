-- Based off of JMOD EZ Gas Particle, created by Freaking Fission, uses some code from GChem
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ CS Gas"
ENT.Author = "Jackarunda, Freaking Fission"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZgasParticle = true
ENT.ThinkRate = 1
ENT.AffectRange = 200
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
		self.LifeTime = math.random(50, 100) * JMod.Config.Particles.PoisonGasLingerTime
		self.DieTime = Time + self.LifeTime
		self.NextDmg = Time + 2.5
		self.CurVel = self.CurVel or VectorRand()
	end

	function ENT:DamageObj(obj)
		local RespiratorMultiplier = 1
		local Time = CurTime()
		if obj:IsPlayer() then
			local faceProt, skinProt = JMod.GetArmorBiologicalResistance(obj, DMG_NERVEGAS)
			
			net.Start("JMod_VisionBlur")
			net.WriteFloat(5 * math.Clamp(1 - faceProt, 0, 1))
			net.WriteFloat(2)
			net.WriteBit(false)
			net.Send(obj)
			JMod.Hint(obj, "tear gas")
			if faceProt < 1 then
				JMod.TryCough(obj)
			end
		elseif obj:IsNPC() then
			obj.EZNPCincapacitate = Time + math.Rand(2, 5)
		end

		if math.random(1, 20) == 1 then
			local Dmg, Helf = DamageInfo(), obj:Health()
			Dmg:SetDamageType(DMG_NERVEGAS)
			Dmg:SetDamage(math.random(1, 4) * JMod.Config.Particles.PoisonGasDamage * RespiratorMultiplier)
			Dmg:SetInflictor(self)
			Dmg:SetAttacker(self.EZowner or self)
			Dmg:SetDamagePosition(obj:GetPos())
			obj:TakeDamageInfo(Dmg)
		end
	end

	function ENT:CalcMove(ThinkRateHz)
		local SelfPos, Time = self:GetPos(), CurTime()
		local RandDir = VectorRand(-8, 8)
		RandDir.z = RandDir.z / 2
		local Force = RandDir + (JMod.Wind * 3)

		for key, obj in pairs(ents.FindInSphere(SelfPos, self.AffectRange)) do
			if math.random(1, 2) == 1 and not (obj == self) and self:CanSee(obj) then
				if obj.EZgasParticle and not(obj.EZvirusParticle) then
					-- repel in accordance with Ideal Gas Law
					local Vec = (obj:GetPos() - SelfPos):GetNormalized()
					Force = Force - Vec * 1
				elseif self.NextDmg < Time and self:ShouldDamage(obj) then
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
			mask = MASK_SHOT
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
			self.CurVel = -(CurVelAng:Forward() * Speed)
		end
	end

elseif CLIENT then
	local Mat = Material("effects/smoke_b")

	function ENT:Initialize()
		self.Col = Color(255, 255, 255)
		self.Visible = true
		self.Show = true
		self.siz = 1

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = math.random(1, 2) == 2
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		
		self:SetModelScale(2)
	end

	function ENT:DrawTranslucent()
		self.DebugShow = LocalPlayer().EZshowGasParticles or false
		if self.DebugShow then
			self:DrawModel()
		end

		local Time = CurTime()

		if self.NextVisCheck < Time then
			self.NextVisCheck = Time + 1
			self.Show = self.Visible and 1 / FrameTime() > 50
		end
		self.Show = self.Visible

		if self.Show then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(SelfPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, 15))
			self.siz = math.Clamp(self.siz + FrameTime() * 200, 0, 500)
		end
	end
end
