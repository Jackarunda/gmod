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
ENT.mmRHAe = 100 -- for ArcCW, hinders bullet penetration of the shield
ENT.DisableDuplicator =	true
--
ENT.JMod_NapalmBounce = true

function ENT:GravGunPunt(ply)
	return false
end

hook.Add("EntityTakeDamage", "JMOD_SHIELDEXPLOSION", function( target, dmginfo )
	if target:GetClass() == "ent_jack_gmod_bubble_shield" then return end
	local Shield = NULL
	for _, shield in ipairs(ents.FindByClass("ent_jack_gmod_bubble_shield")) do
		local Mins, Maxes = target:GetCollisionBounds()
		local TargetCenter = target:LocalToWorld(target:OBBCenter())
		if util.IsBoxIntersectingSphere(Mins, Maxes, shield:GetPos() - TargetCenter, shield.ShieldRadius) then
			Shield = shield
			break
		end
	end
	if not IsValid(Shield) then return end
	local FinalDamagePos = dmginfo:GetReportedPosition()
	if FinalDamagePos == vector_origin then
		FinalDamagePos = dmginfo:GetDamagePosition()
	end
	if (FinalDamagePos:DistToSqr(Shield:GetPos()) > Shield.ShieldRadiusSqr) then
		return true
	end
end)

--
hook.Add("ShouldCollide", "JMOD_SHIELDCOLLISION", function(ent1, ent2)
	local snc1 = ent1.ShouldNotCollide
	if snc1 and snc1(ent1, ent2) then return false end

	local snc2 = ent2.ShouldNotCollide
	if snc2 and snc2(ent2, ent1) then return false end
end)

function ENT:ShouldNotCollide(ent)
	--print(ent)
	if ent:IsPlayer() then
		return true
	end
	local TheirVel = ent:GetVelocity()
	local InsideShield = ent:GetPos():DistToSqr(self:GetPos()) < self.ShieldRadiusSqr
	if InsideShield or TheirVel:Length() < 500 then
		return true
	end

	return false
end

--]]
function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	local SelfPos = self:GetPos()
	local EndPos = startpos + delta
	local TestNorm = (startpos - (EndPos)):GetNormalized()
	--local OurNorm = (SelfPos - startpos):GetNormalized()

	--[[if (bit.band(mask, MASK_SHOT) == MASK_SHOT) then
		local RandColServer, RandColorClient = Color(0, math.random(0, 255), 255), Color(255, math.random(0, 255), 0)
		local WhereCameFrom = EndPos + TestNorm * 10
		if CLIENT then
			if isbox then
				debugoverlay.Box(EndPos, -extents, extents, 2, RandColorClient, false)
			else
				debugoverlay.Cross(EndPos, 2, 2, RandColorClient, true)
				debugoverlay.Line(EndPos, startpos, 2, RandColorClient, true)
			end
		else
			if isbox then
				debugoverlay.Box(EndPos, -extents, extents, 2, RandColServer, false)
			else
				debugoverlay.Cross(EndPos, 2, 2, RandColServer, true)
				debugoverlay.Line(EndPos, startpos, 2, RandColServer	, true)
			end
		end
	end--]]

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

	if SERVER then
		--debugoverlay.Cross(startpos, 2, 5, Color(255, 153, 0), true)
		--debugoverlay.Line(EndPos, startpos, 3, Color(96, 255, 3), true)
	end
	--
	if bit.band(mask, MASK_SHOT) == MASK_SHOT then
		return {
			Fraction = 0
		}
	end

	return true
end
--]]

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "AmInnerShield")
	self:NetworkVar("Int", 1, "SizeClass")
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

		--
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
		--]]
		if not(IsValid(self.Projector)) then -- todo: if we have no emitter, die
			local Strength = 100
			self:SetMaxStrength(Strength)
			self:SetStrength(Strength)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:OnTakeDamage(dmginfo)
		local DmgPos = dmginfo:GetDamagePosition()
		local Attacker = dmginfo:GetAttacker()
		local Inflictor = dmginfo:GetInflictor()
		local DmgAmt = dmginfo:GetDamage()
		local SelfPos = self:GetPos()
		local Vec = DmgPos - SelfPos
		local Dir = Vec:GetNormalized()
		local Scale = (dmginfo:GetDamage() / 30) ^ .5
		---
		-- This is to stop stuff like fire from causing ripples on the shield in weird places
		local IsBullet = dmginfo:IsBulletDamage()
		if IsBullet then
			local ShotOrigin = DmgPos

			if IsValid(Attacker) and Attacker.GetShootPos then
				ShotOrigin = Attacker:GetShootPos()
			elseif IsValid(Inflictor) then
				ShotOrigin = dmginfo:GetInflictor():GetPos()
			end

			local ShieldTr = util.TraceLine({
				start = ShotOrigin,
				endpos = DmgPos,
				filter = {Attacker, Inflictor},
				mask = MASK_SOLID
			})
			if ShieldTr.Hit and IsValid(ShieldTr.Entity) and ShieldTr.Entity:GetClass() == "ent_jack_gmod_bubble_shield" then
				DmgPos = ShieldTr.HitPos
				Dir = ShieldTr.HitNormal
			end
		end
		
		if IsBullet or dmginfo:IsExplosionDamage() or dmginfo:GetDamageForce():Length() > 10 then
			local Ripple = EffectData()
			Ripple:SetEntity(self)
			Ripple:SetOrigin(DmgPos)
			Ripple:SetScale(Scale)
			Ripple:SetNormal(Dir)
			util.Effect("eff_jack_gmod_refractripple", Ripple, true, true)
			---
			sound.Play("snds_jack_gmod/ez_bubbleshield_hits/"..math.random(1, 7)..".ogg", DmgPos, 65, math.random(90, 110))
		end
		---
		--print(dmginfo:GetAttacker())
		--[[ -- attempted bullet ricochet, but this crashes the game
		if (dmginfo:IsBulletDamage() and true) then
			local Dmg = dmginfo:GetDamage()
			local DmgForce = dmginfo:GetDamageForce()
			local DmgDir = DmgForce:GetNormalized()
			local DmgDirAng = DmgDir:Angle()
			DmgDirAng:RotateAroundAxis(Dir, 180)
			---
			self:FireBullets({
				Src = DmgPos,
				Dir = Dir,
				Tracer = 1,
				Num = 1,
				Spread = Vector(0,0,0),
				Damage = Dmg,
				Force = DmgForce,
				Attacker = dmginfo:GetAttacker()
			})
		end
		--]]

		-- finally, we actually take the damage
		local CurStrength = self:GetStrength()
		local AmtToLose = DmgAmt
		local AmtRemaining = CurStrength - AmtToLose
		self:SetStrength(AmtRemaining)
		if (AmtRemaining <= 0) then
			self:Break()
		end
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
		local Eff = EffectData()
		Eff:SetEntity(self)
		util.Effect("propspawn", Eff, true, true)
		self:Remove()
	end

	function ENT:OnRemove()
		SafeRemoveEntity(self.InnerShield)
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
		--
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
		if self:GetAmInnerShield() then
			return
		end
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .995 + (math.sin(CurTime() * .5) - 0.015) * .005
		local ShieldAng = SelfAng:GetCopy()
		--
		ShieldAng:RotateAroundAxis(ShieldAng:Up(), FT)
		self:SetRenderAngles(ShieldAng)
		--
		local RefractAmt = (math.sin(CurTime() * 3) / 2 + .5) * .045 + .005
		self.Mat:SetFloat("$refractamount", RefractAmt)
		local Strength = self:GetStrength() / self:GetMaxStrength()
		if (Strength > .2 or math.Rand(0, 1) > .1) then
			local MacTheMatrix = Matrix()
			MacTheMatrix:Scale(Vector(self.ShieldGrow, self.ShieldGrow, self.ShieldGrow) * ShieldModulate)
			self:EnableMatrix("RenderMultiply", MacTheMatrix)
			self:DrawModel()
			-- STENCILS!
			local Epos = EyePos()
			local OffsetVec = Epos - SelfPos
			local Dist = OffsetVec:Length()
			local FoV = 1 / (render.GetViewSetup().fov / 180)
			local R, G, B = JMod.GoodBadColor(Strength)
			R = math.Clamp(R + 30, 0, 255)
			G = math.Clamp(G + 30, 0, 255)
			B = math.Clamp(B + 30, 0, 255)

			if (Strength > .2 or math.Rand(0, 1) > .1) then
				if Dist < self.ShieldRadius * 1.03 * self.ShieldGrow then
					local Eang = EyeAngles()
					render.SetMaterial(BubbleGlowSprite)
					render.DrawSprite(Epos + Eang:Forward() * 10, 45 * FoV, 35, Color(R, G, B, 200))
					RenderShieldBeam(self, Color(R, G, B, 128))
				else
					local ShieldDiameter = self.ShieldRadius * 2
					local ShieldPie = self.ShieldRadius * math.pi
					local DistToEdge = Dist - self.ShieldRadius
					local DistFrac = math.Clamp(ShieldPie - DistToEdge, 0, ShieldPie) / ShieldPie
					local ClosenessCompensation = (ShieldPie * 1.15) * DistFrac ^ (math.pi ^ 2)
					local SizeInPix = render.ComputePixelDiameterOfSphere(SelfPos, self.ShieldRadius)
					--print(DistFrac, ClosenessCompensation)

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
					local PerspectiveOffset = OffsetVec:GetNormalized() * (self.ShieldRadius * ShieldSizeOffset)
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
					local Siz = (ShieldDiameter * 1.1 + ClosenessCompensation) * self.ShieldGrow
					local SizPix = (ShieldDiameter * 1.1 + (SizeInPix * DistFrac)) * self.ShieldGrow
					render.SetMaterial(BubbleGlowSprite)
					render.DrawSprite(SelfPos, Siz, Siz, Color(R, G, B, 128))
					--render.DrawSprite(SelfPos, SizPix, SizPix, Color(R, G, B, 128))--]]
					--[[
					local PosData = SelfPos:ToScreen()
					local oldW, oldH = ScrW(), ScrH()
					render.SetViewPort(0, 0, oldW, oldH)
					cam.Start2D()
					local W, H = ScrW(), ScrH()
						if PosData.visible then
							surface.SetMaterial(BubbleGlowSprite)
							surface.SetDrawColor(R, G, B, 128)
							surface.DrawTexturedRect(PosData.x - SizeInPix / 2, PosData.y - SizeInPix / 2, SizeInPix, SizeInPix)
						end
					cam.End2D()
					render.SetViewPort(0, 0, oldW, oldH)--]]
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
