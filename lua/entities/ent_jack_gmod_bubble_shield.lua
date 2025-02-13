AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bubble Shield"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/jmod/giant_hollow_sphere_1.mdl"
ENT.PhysgunDisabled = true
ENT.ShieldRadii = {
	[1] = 240,
	[2] = 300,
	[3] = 375,
	[4] = 468,
	[5] = 585
}
ENT.mmRHAe = 1000 -- for ArcCW, hinders bullet penetration of the shield
ENT.DisableDuplicator =	true
--
ENT.JMod_NapalmBounce = true

function ENT:GravGunPunt(ply)
	return false
end

function ENT:CanTool(ply, trace, mode, tool, button)

	if (mode == "remover") then return true end

	return false
end

--
hook.Add("ShouldCollide", "JMOD_SHIELDCOLLISION", function(ent1, ent2)
	local snc1 = ent1.ShouldNotCollide
	if snc1 and snc1(ent1, ent2) then return false end

	local snc2 = ent2.ShouldNotCollide
	if snc2 and snc2(ent2, ent1) then return false end
end)

function ENT:ShouldNotCollide(ent)
	if ent:IsPlayer() then return true end
	
	local InsideShield = ent:GetPos():DistToSqr(self:GetPos()) < self.ShieldRadiusSqr
	if InsideShield then return true end

	local Time = CurTime()
	if (ent.JMod_BubbleShieldPassTime and ent.JMod_BubbleShieldPassTime > Time) then return false end

	local TheirSpeed, TheirPhys, MaxSpeed = ent:GetVelocity():Length(), ent:GetPhysicsObject(), 500
	if (IsValid(TheirPhys) and TheirPhys.GetMass) then
		if (TheirPhys:GetMass() > 250) then MaxSpeed = 200 end
	end
	if (TheirSpeed < MaxSpeed) then return true end

	ent.JMod_BubbleShieldPassTime = Time + 3
	return false
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	local SelfPos = self:GetPos()
	local EndPos = startpos + delta
	local TestNorm = (startpos - (EndPos)):GetNormalized()

	if isbox then
		local PointsToCheck = {
			startpos,
			startpos + extents,
			startpos - extents,
			startpos + Vector(extents.x, extents.y, -extents.z),
			startpos + Vector(extents.x, -extents.y, extents.z),
			startpos + Vector(-extents.x, extents.y, -extents.z),
			startpos + Vector(-extents.x, -extents.y, extents.z)
		}
		for i, point in ipairs(PointsToCheck) do
			if SelfPos:DistToSqr(point) < self.ShieldRadiusSqr then
				--print("Box")

				return false
			end
		end
	else
		if SelfPos:DistToSqr(startpos) < self.ShieldRadiusSqr then

			return false
		end
	end

	--
	if (bit.band(mask, MASK_SHOT) == MASK_SHOT) then
		local Frac1, Frac2 = util.IntersectRayWithSphere(startpos, delta, SelfPos, self.ShieldRadius)
		--debugoverlay.Line(startpos, startpos + delta * (Frac1 or 1), 10, Color(255, 0, 0, 255), true)
		if Frac1 and Frac2 then
			return {
				HitPos = startpos + delta * (Frac1 or 1),
				Fraction = Frac1
			}
		end
	end

	return true
end
--]]

function ENT:SetupDataTables()
	self:NetworkVar("Int", 1, "SizeClass")
	self:NetworkVar("Bool", 0, "AmInnerShield")
	self:NetworkVar("Bool", 1, "AmBreaking")
	self:NetworkVar("Float", 0, "Strength")
	self:NetworkVar("Float", 1, "MaxStrength")
end

function ENT:ImpactTrace(tr, dmgType)
	return true
end

if SERVER then
	function ENT:Initialize()
		-- Initializing some values
		if self:GetSizeClass() < 1 then self:SetSizeClass(1) end
		local ShieldGrade = self:GetSizeClass()
		self.ShieldRadius = self.ShieldRadii[ShieldGrade]
		self.ShieldRadius = self.ShieldRadius - (self.ShieldRadius / 48)
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius

		self:SetModel("models/jmod/giant_hollow_sphere_"..tostring(ShieldGrade)..".mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_GLOW)
		self:AddEFlags(EFL_NO_DISSOLVE)

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end -- something went wrong

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)
		phys:SetMaterial("solidmetal")

		self:EnableCustomCollisions(true)

		if not(self:GetAmInnerShield()) then
			-- Inner shield is for prop blocking
			self.InnerShield = ents.Create("ent_jack_gmod_bubble_shield")
			self.InnerShield:SetAmInnerShield(true)
			self.InnerShield.OuterShield = self
			self.InnerShield.Projector = self.Projector
			self.InnerShield:SetSizeClass(self:GetSizeClass())
			self.InnerShield:SetPos(self:GetPos() - Vector(0, 0, 10))
			self.InnerShield:Spawn()
			self.InnerShield:SetModelScale(.9, 0.001)
			self.InnerShield:SetCollisionGroup(COLLISION_GROUP_NONE)
			self.InnerShield:SetCustomCollisionCheck(true)
			self.InnerShield:CollisionRulesChanged()
			self.InnerShield:Activate()
		end

		self:SetAmBreaking(false)
		if not(IsValid(self.Projector)) then -- todo: if we have no emitter, die
			local Strength = 100
			self:SetMaxStrength(Strength)
			self:SetStrength(Strength)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.DeltaTime < .1) then return end
		-- kinetic energy: .5*m*v^2
		if not (IsValid(data.HitObject)) then return end
		local Mass = data.HitObject:GetMass()
		local KE = .5 * Mass * data.Speed ^ 2
		self:DoHitEffect(data.HitPos, math.Clamp(KE / 20000000, .5, 5), data.HitNormal)

		-- boing
		local Norm = (data.HitPos - self:GetPos()):GetNormalized()
		timer.Simple(0, function()
			if (IsValid(data.HitObject)) then
				data.HitObject:SetVelocity(Norm * data.Speed * .9)
			end
		end)

		if (data.DeltaTime < .3) then return end

		-- no physgun minging
		if not (data.HitEntity.IsPlayerHolding and data.HitEntity:IsPlayerHolding()) then
			self:TakeShieldDamage(KE / 600000)
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		local SelfPos = self:GetPos()
		local DmgPos = dmginfo:GetDamagePosition()
		local DmgDist = DmgPos:Distance(SelfPos)

		if (DmgDist < (self.ShieldRadius - 10)) then return end -- don't take damage from inside

		local Attacker = dmginfo:GetAttacker()
		local Inflictor = dmginfo:GetInflictor()
		local DmgAmt = dmginfo:GetDamage()
		local DmgForce = dmginfo:GetDamageForce()
		local DmgPosOffset = DmgPos - SelfPos
		local HitNormal = DmgPosOffset:GetNormalized()
		local Scale = (dmginfo:GetDamage() / 30) ^ .5

		-- This is to stop stuff like fire from causing ripples on the shield in weird places
		local IsBullet = dmginfo:IsBulletDamage()
		if DmgDist > (self.ShieldRadius + 10) then
			local ShotOrigin = DmgPos
			--debugoverlay.Cross(ShotOrigin, 2, 5, Color(255, 0, 0), true)
			--debugoverlay.Line(ShotOrigin, DmgPos, 5, Color(255, 0, 0), true)

			local dmgGun = dmginfo.GetWeapon and dmginfo:GetWeapon()
			if IsValid(dmgGun) then
				ShotOrigin = dmgGun:GetPos()
				if dmgGun:GetAttachment(1) then
					ShotOrigin = dmgGun:GetAttachment(1).Pos
				end
			elseif IsValid(Inflictor) then
				ShotOrigin = Inflictor:GetPos()
				if Inflictor:GetAttachment(1) then
					ShotOrigin = Inflictor:GetAttachment(1).Pos
				end
			else
				ShotOrigin = DmgPos + HitNormal
			end
			local IncomingVec = DmgPos - ShotOrigin

			local Frac1, Frac2 = util.IntersectRayWithSphere(ShotOrigin, IncomingVec, SelfPos, self.ShieldRadius)
			if Frac1 then
				DmgPos = ShotOrigin + IncomingVec * Frac1
			end
		end

		if IsBullet or dmginfo:IsExplosionDamage() or DmgForce:Length() > 10 then
			if (DmgDist > (self.ShieldRadius + 10)) then -- this was probably an explosive
				DmgPos = SelfPos + (DmgPosOffset:GetNormalized() * self.ShieldRadius)
			end
			self:DoHitEffect(DmgPos, Scale, HitNormal)
		end

		---[[ -- trying to ricochet bullets ALWAYS crashes the game
		if (IsBullet and math.Rand(0, 1) >= .25) then
			timer.Simple(0, function()
				if (IsValid(self)) then
					self:FireBullets({
						Src = DmgPos + HitNormal * 10,
						Dir = HitNormal,
						Tracer = 1,
						Num = 1,
						Spread = Vector(0, 0, 0),
						Damage = DmgAmt * math.Rand(.75, .95),
						Force = 2,
						Attacker = Attacker,
						IgnoreEntity = self.InnerShield
					})
				end
			end)
		end
		--]]

		self:TakeShieldDamage(DmgAmt)
	end

	function ENT:TakeShieldDamage(amt)
		local CurStrength = self:GetStrength()
		local AmtToLose = amt / 80
		local AmtRemaining = math.Clamp(CurStrength - AmtToLose, .1, self:GetMaxStrength())
		-- jprint(AmtToLose)
		self:SetStrength(AmtRemaining)
		if IsValid(self.OuterShield) then self.OuterShield:SetStrength(AmtRemaining) end
		if IsValid(self.InnerShield) then self.InnerShield:SetStrength(AmtRemaining) end
		if (AmtRemaining <= .1) then
			self:Break()
		end
	end

	function ENT:AcceptRecharge(amt)
		local NewStrength = math.Clamp(self:GetStrength() + amt, .1, self:GetMaxStrength())
		self:SetStrength(NewStrength)
		if IsValid(self.OuterShield) then self.OuterShield:SetStrength(NewStrength) end
		if IsValid(self.InnerShield) then self.InnerShield:SetStrength(NewStrength) end
	end

	function ENT:Think()
		if IsValid(self.Projector) then
			self:SetPos(self.Projector:GetPos() - self.Projector:GetUp() * 120)
			self:SetAngles(self.Projector:GetAngles())
		elseif IsValid(self.OuterShield) then
			self:SetPos(self.OuterShield:GetPos())
			self:SetAngles(self.OuterShield:GetAngles())
		end
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
			self:GetPhysicsObject():EnableMotion(false)
		end
		if self:IsOnFire() then
			self:Extinguish()
		end
	end

	function ENT:Break()
		if (self:GetAmBreaking()) then return end
		self:SetAmBreaking(true)
		if IsValid(self.OuterShield) then self.OuterShield:SetAmBreaking(true) end
		if IsValid(self.InnerShield) then self.InnerShield:SetAmBreaking(true) end
		local SelfPos = self:GetPos()
		local Eff = EffectData()
		Eff:SetOrigin(SelfPos)
		Eff:SetScale(self.ShieldRadius)
		util.Effect("eff_jack_gmod_bubbleshieldburst", Eff, true, true)
		timer.Simple(.333, function()
			if (IsValid(self)) then
				self:EmitSound("snds_jack_gmod/bubble_shield_break.ogg", 80, 100)
				sound.Play("snds_jack_gmod/bubble_shield_break.ogg", SelfPos + vector_up, 80, 100)
				for k, v in pairs(ents.GetAll()) do
					if (v.TakeDamageInfo and v ~= self and v ~= self.InnerShield and v ~= self.OuterShield and v ~= self.Projector and v:GetPos():Distance(SelfPos) < self.ShieldRadius) then
						local Dmg = DamageInfo()
						Dmg:SetAttacker(game.GetWorld())
						Dmg:SetInflictor(self)
						Dmg:SetDamage(5)
						Dmg:SetDamageType(DMG_SHOCK)
						Dmg:SetDamageForce(Vector(0, 0, -10000))
						Dmg:SetDamagePosition(v:GetPos())
						v:TakeDamageInfo(Dmg)
					end
				end
				if IsValid(self.OuterShield) then self.OuterShield:Remove() end
				if IsValid(self.InnerShield) then self.InnerShield:Remove() end
				self:Remove()
			end
		end)
	end

	function ENT:OnRemove()
		SafeRemoveEntity(self.InnerShield)
	end

	function ENT:DoHitEffect(pos, scale, normal)
		local Ripple = EffectData()
		Ripple:SetEntity(self)
		Ripple:SetOrigin(pos)
		Ripple:SetScale(scale)
		Ripple:SetNormal(normal)
		util.Effect("eff_jack_gmod_refractripple", Ripple, true, true)
		---
		local snd = "snds_jack_gmod/ez_bubbleshield_hits/light_"..math.random(1, 3)..".ogg"
		local pitch = math.random(90, 110)
		local lvl = 65
		if (scale >= 2) then
			snd = "snds_jack_gmod/ez_bubbleshield_hits/heavy_"..math.random(1, 3)..".ogg"
			lvl = 75
		end
		sound.Play(snd, pos, lvl, pitch)
		sound.Play(snd, self:GetPos() + Vector(0, 0, 30), lvl, pitch)
	end
elseif CLIENT then
	local BubbleGlowSprite = Material("sprites/mat_jack_gmod_bubbleshieldglow")
	local GlowSprite = Material("sprites/mat_jack_basicglow")
	local BeamMat = Material("cable/physbeam")--"cable/crystal_beam1")--
	--local WireMat = Material("models/wireframe")
	local MASK_COLOR = Color(0, 0, 0, 0)

	function ENT:Initialize()
		local ShieldGrade = self:GetSizeClass()

		self:SetRenderMode(RENDERMODE_GLOW)
		self.Mat = Material("models/jmod/icosphere_shield")
		-- Initializing some values
		self.ShieldGrow = 0
		self.ShieldGrowEnd = CurTime() + .25
		self.ShieldRadius = self.ShieldRadii[ShieldGrade]
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius
		--
		self:EnableCustomCollisions(true)
		self.BeamScroll = 0
	end

	function ENT:Think()
		local FT = FrameTime()
		self.ShieldGrow = Lerp(CurTime() - self.ShieldGrowEnd, 0, 1)
		self.BeamScroll = (self.BeamScroll - FT * 2) % 1 -- (self.BeamScroll or 0)
	end

	local function RenderShieldBeam(self, beamColor)
		local SelfPos = self:GetPos()
		local Epos = EyePos()
		local ShieldGrade = self:GetSizeClass()
		local BeamWidth = 20
		local BeamColor = beamColor
		local SelfUp = self:GetUp()
		local Time = CurTime()
		local EmitPos = SelfPos + SelfUp * 78
		local Extent = SelfUp * (self.ShieldRadius - 78) * .95 + Vector(math.sin(Time) * 10, math.cos(Time) * 10, 0)
		local Scroll = self.BeamScroll
		--render.SetColorMaterial()
		render.SetMaterial(BeamMat)
		render.StartBeam(5)
			render.AddBeam(EmitPos, 5, Scroll, BeamColor)
			for i = 1, 3 do
				local ThisBeamWidth = BeamWidth * i
				render.AddBeam(EmitPos + Extent * (i / 4) - SelfUp * (ThisBeamWidth / 2), ThisBeamWidth, Scroll + (i / 4), BeamColor)
			end
			render.AddBeam(EmitPos + Extent, BeamWidth * ShieldGrade, Scroll + 1, BeamColor)
		render.EndBeam()
		render.SetMaterial(GlowSprite)
		render.DrawSprite(EmitPos + (Epos - EmitPos):GetNormalized() * 4, 30, 30, BeamColor)
		render.DrawSprite(EmitPos + Extent, BeamWidth * 4 * ShieldGrade, 30 * ShieldGrade, BeamColor)
	end

	local BubbleBlur = 0
	function ENT:DrawTranslucent(flags)
		if self:GetAmInnerShield() then return end
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .995 + (math.sin(CurTime() * .5) - 0.015) * .005
		local ShieldAng = SelfAng:GetCopy()
		--
		ShieldAng:RotateAroundAxis(ShieldAng:Up(), FT)
		self:SetRenderAngles(ShieldAng)
		--
		local RefractAmt = (math.sin(CurTime() * 3) / 2 + .5) * .045 + .005
		local Strength = self:GetStrength()
		local StrengthFrac = Strength / self:GetMaxStrength()
		if (StrengthFrac > .15 or math.Rand(0, 1) > .1) then
			local Xmod, Ymod, Zmod = 1, 1, 1
			if (self:GetAmBreaking()) then
				Xmod = math.Rand(.95, 1.05)
				Ymod = math.Rand(.95, 1.05)
				Zmod = math.Rand(.95, 1.05)
				RefractAmt = .3
			end
			self.Mat:SetFloat("$refractamount", RefractAmt)
			local MacTheMatrix = Matrix()
			MacTheMatrix:Scale(Vector(self.ShieldGrow * Xmod, self.ShieldGrow * Ymod, self.ShieldGrow * Zmod) * ShieldModulate)
			self:EnableMatrix("RenderMultiply", MacTheMatrix)
			self:DrawModel()
			-- STENCILS!
			local Epos = EyePos()
			local OffsetVec = Epos - SelfPos
			local OffsetNorm = OffsetVec:GetNormalized()
			local Dist = OffsetVec:Length()
			local FoV = 1 / (render.GetViewSetup().fov / 180)
			local R, G, B = JMod.GoodBadColor(StrengthFrac)
			R = math.Clamp(R + 30, 0, 255)
			G = math.Clamp(G + 30, 0, 255)
			B = math.Clamp(B + 30, 0, 255)
			local GlowColor = Color(R, G, B, 128)
			if Dist < self.ShieldRadius * 1.03 * self.ShieldGrow then
				local Eang = EyeAngles()
				render.SetMaterial(BubbleGlowSprite)
				render.DrawSprite(Epos + Eang:Forward() * 10, 45 * FoV * Xmod, 35 * Ymod, GlowColor)
				RenderShieldBeam(self, GlowColor)
			else
				local ShieldDiameter = self.ShieldRadius * 2
				local ShieldPie = self.ShieldRadius * math.pi
				local DistToEdge = Dist - self.ShieldRadius
				local DistFrac = math.Clamp(ShieldPie - Dist, 0, ShieldPie) / ShieldPie
				local SizeMult = 1.1 --+ 3.14 * (DistFrac ^ math.pi * 2)
				local MoveMult = self.ShieldRadius * ((DistFrac + .2) ^ math.pi)
				--print(SizeMult, MoveMult)

				-- Set up the stencil op with safe values
				render.SetStencilEnable(true)
				render.ClearStencil()
				render.SetStencilTestMask(255)
				render.SetStencilWriteMask(255)
				-- We want to keep only the pixels that pass the depth check
				render.SetStencilReferenceValue(1)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
				render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
				render.SetStencilFailOperation(STENCILOPERATION_ZERO)
				-- Pass everything and just check depth
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
				-- Setup the mask with a color material
				render.SetColorMaterial()
				-- Perspective offset is for helping with making it look more like the glow is coming from the edge of the shield.
				local ShieldSizeOffset = .05
				local PerspectiveOffset = OffsetNorm * (self.ShieldRadius * ShieldSizeOffset)
				-- We are drawing it completely invisible becasue it's a mask
				-- There might be another way to do this, but this works for now
				render.DrawSphere(SelfPos - PerspectiveOffset, self.ShieldRadius * (1 + ShieldSizeOffset + .01) * self.ShieldGrow, 50, 50, MASK_COLOR)
				-- Now we are drawing the effects, so we don't really want to modify the stencil buffer mask
				-- We won't bother with the depth test because we are going to be ignoring Z anyway
				render.SetStencilFailOperation(STENCILOPERATION_KEEP)
				-- Typical equator function for finding what's on the mask
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
				-- Now we are going to draw the glow
				--
				local Siz = ShieldDiameter * SizeMult * self.ShieldGrow
				render.SetMaterial(BubbleGlowSprite)
				render.DrawSprite(SelfPos + OffsetNorm * MoveMult, Siz * Xmod, Siz * Ymod, GlowColor)
				render.SetStencilEnable(false)
			end
			-- blur the player's vision if his eyes are intersecting the shield
			local BlurDistRange, BlurDistBegin = self.ShieldRadius * .1, self.ShieldRadius * .95
			local BlurDistEnd = BlurDistBegin + BlurDistRange
			local DistDiff = math.abs(Dist - self.ShieldRadius)
			if (Dist > BlurDistBegin) and (Dist < BlurDistEnd) then
				BubbleBlur = ((1 - (DistDiff / BlurDistRange)) - .5) * 2
			else
				BubbleBlur = 0
			end
		end
	end

	local blurMaterial = Material('pp/bokehblur')

	hook.Add("RenderScreenspaceEffects", "JMod_BubbleShieldScreenSpace", function()
		if (BubbleBlur > 0) then
			if GetConVar("jmod_cl_blurry_menus"):GetBool() then
				render.UpdateScreenEffectTexture()
				blurMaterial:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
				blurMaterial:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
				blurMaterial:SetFloat("$size", (BubbleBlur * 30))
				blurMaterial:SetFloat("$focus", 1)
				blurMaterial:SetFloat("$focusradius", 1)
				render.SetMaterial(blurMaterial)
				render.DrawScreenQuad()
			else
				-- We grey out the screen for potato users
				surface.SetDrawColor(100, 120, 100, math.min(255 * BubbleBlur, 240))
				surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
			end
		end
	end)

	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
