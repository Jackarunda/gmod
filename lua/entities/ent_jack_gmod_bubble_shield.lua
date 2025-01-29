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

--[[
hook.Remove("EntityFireBullets", "JMOD_SHIELDBULLETS", function(ent, data) 
	local ShieldBubbles = ents.FindByClass("ent_jack_gmod_bubble_shield")
	if #ShieldBubbles > 0 then
		for k, v in ipairs(ShieldBubbles) do
			--if v:GetAmInnerShield() then
				if data.Src:DistToSqr(v:GetPos()) < v.ShieldRadiusSqr then
					local EdgeTr = util.TraceLine(
						{start = data.Src, 
						endpos = data.Src + data.Dir * data.Distance,
						mask = MASK_SOLID,
						filter = {ent}
					})
					if EdgeTr.Entity == v then
						data.Src = EdgeTr.HitPos + EdgeTr.Normal * 40
						return true
					end
				else

				end
			--end
		end
	end
end)
--]]
hook.Add("EntityTakeDamage", "JMOD_SHIELDEXPLOSION", function( target, dmginfo )
	if target:GetClass() == "ent_jack_gmod_bubble_shield" then return end
	local Shield = NULL
	for _, shield in ipairs(ents.FindByClass("ent_jack_gmod_bubble_shield")) do
		if target:GetPos():DistToSqr(shield:GetPos()) < shield.ShieldRadiusSqr then
			Shield = shield
			break
		end
	end
	if IsValid(Shield) and (dmginfo:GetReportedPosition():DistToSqr(Shield:GetPos()) > Shield.ShieldRadiusSqr) then
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
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius

		self:SetModel("models/jmod/giant_hollow_sphere_"..tostring(ShieldGrade)..".mdl")
		--self:SetMaterial("models/mat_jack_gmod_hexshield1")
		--self:SetMaterial("models/jmod/icosphere_shield")
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
			self:DeleteOnRemove(self.InnerShield)
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
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:OnTakeDamage(dmginfo)
		local DmgPos = dmginfo:GetDamagePosition()
		local SelfPos = self:GetPos()
		local Vec = DmgPos - SelfPos
		local Dir = Vec:GetNormalized()
		local Scale = (dmginfo:GetDamage() / 30) ^ .5
		---
		-- This is to stop stuff like fire from causing ripples on the shield in weird places
		local IsBullet = dmginfo:IsBulletDamage()
		if IsBullet then
			local ShotOrigin = DmgPos

			local Attacker = dmginfo:GetAttacker()
			local Inflictor = dmginfo:GetInflictor()
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

	function ENT:OnRemove()
		--print("Removed Inner Shield", self:GetAmInnerShield())
		SafeRemoveEntity(self.InnerShield)
		SafeRemoveEntity(self.OuterShield)
	end
end

if CLIENT then
	local GlowSprite = Material("sprites/mat_jack_gmod_bubbleshieldglow")
	local WireMat = Material("models/wireframe")

	hook.Add("PostDrawTranslucentRenderables", "JMOD_DRAWBUBBLESHIELD", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
		if bDrawingSkybox then return end
		for _, v in ipairs(ents.FindByClass("ent_jack_gmod_bubble_shield")) do
			if not v:GetAmInnerShield() then
				local SelfPos = v:GetPos()
				local Epos = EyePos()
				local OffsetVec = Epos - SelfPos
				local Dist = OffsetVec:Length()
				local FoV = 1 / (LocalPlayer():GetFOV() / 90)
				local R, G, B = JMod.GoodBadColor(v.ShieldStrength)
				R = math.Clamp(R + 30, 0, 255)
				G = math.Clamp(G + 30, 0, 255)
				B = math.Clamp(B + 30, 0, 255)
				if (v.ShieldStrength > .2 or math.Rand(0, 1) > .1) then
					if Dist < v.ShieldRadius * 1.03 * v.ShieldGrow then
						local Eang = EyeAngles()
						render.SetMaterial(GlowSprite)
						cam.IgnoreZ(true)
							render.DrawSprite(Epos + Eang:Forward() * 10, 45 * FoV, 35, Color(R, G, B, 200))
						cam.IgnoreZ(false)
					else
						local ShieldRadius = v.ShieldRadius
						local ShieldDiameter = ShieldRadius * 2
						local ShieldPie = ShieldRadius * math.pi
						local DistToEdge = Dist - ShieldRadius
						local DistFrac = math.Clamp(ShieldPie - DistToEdge, 0, ShieldPie) / ShieldPie
						local ClosenessCompensation = (ShieldPie * 1.15) * DistFrac ^ (math.pi ^ 2)
						--print(ClosenessCompensation)
						--[[local Siz = (ShieldDiameter * 1.15 + ClosenessCompensation) * v.ShieldGrow
						render.SetMaterial(GlowSprite)
						render.DrawSprite(SelfPos, Siz, Siz, Color(R, G, B, 128))--]]

						-- If you'd like to see the mask layer, you can comment this line out
						render.SetStencilEnable(true)
						render.ClearStencil()
						render.SetStencilTestMask(255)
						render.SetStencilWriteMask(255)
						render.SetStencilPassOperation(STENCILOPERATION_INCRSAT)
						render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
						-- Now, let's confiure the parts of the Stencil system we are going to use
						------ We're creating a mask, so we don't want anything we do right now to draw onto the screen
						------ All pixels should fail the Compare Function (They should NEVER pass)
						render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
						------ When a pixel fails, which they all should, we want to REPLACE their current Stencil value with
						------ whatever the Reference Value is
						render.SetStencilReferenceValue(1)
						render.SetStencilFailOperation(STENCILOPERATION_ZERO)
						-- At this point, we're ready to perform draw operations to create our mask
						render.SetColorMaterial()
						render.DrawSphere(SelfPos, ShieldRadius * v.ShieldGrow * 1.02, 30, 30, Color(0, 0, 0, 0))
						-- Now, we need to re-configure the Stencil system so we can use the mask we just created
						------ Like the Pass and Z Failure operations, we don't want to change the Stencil Buffer if a pixel
						------ fails the Compare Function because that would change the mask
						render.SetStencilFailOperation(STENCILOPERATION_KEEP)
						------ We want to pass (and therefore draw on) pixels that match (Are EQUAL to) the Reference Value
						render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

						-- We're finally ready to draw the content we want to have masked
						local Siz = (ShieldDiameter * 1.15 + ClosenessCompensation) * v.ShieldGrow
						render.SetMaterial(GlowSprite)
						cam.IgnoreZ(true)
							render.DrawSprite(SelfPos, Siz, Siz, Color(R, G, B, 128))
						cam.IgnoreZ(false)
						
						render.SetStencilEnable(false)
					end
				end
			end
		end
	end)

	function ENT:Initialize()
		local ShieldGrade = self:GetSizeClass()

		self:SetRenderMode(RENDERMODE_GLOW)
		--self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield1")
		self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_sphere_"..tostring(ShieldGrade)..".mdl")
		self.Mat = Material("models/jmod/icosphere_shield")
		-- Initializing some values
		self.ShieldStrength = 1
		self.ShieldGrow = 0
		self.ShieldGrowEnd = CurTime() + .5
		self.ShieldRadius = self.ShieldRadii[ShieldGrade]
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius
		--
		self:EnableCustomCollisions(true)
	end

	function ENT:Think()
		local FT = FrameTime()
		self.ShieldGrow = Lerp(CurTime() - self.ShieldGrowEnd, 0, 1)
	end

	function ENT:DrawTranslucent(flags)
		if self:GetAmInnerShield() then
			return
		end
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .995 + (math.sin(CurTime() * .5) - 0.015) * .005
		local ShieldAng = SelfAng:GetCopy()
		ShieldAng:RotateAroundAxis(ShieldAng:Up(), FT)
		self:SetRenderAngles(ShieldAng)
		local RefractAmt = (math.sin(CurTime() * 3) / 2 + .5) * .045 + .005
		self.Mat:SetFloat("$refractamount", RefractAmt)
		if (self.ShieldStrength > .2 or math.Rand(0, 1) > .1) then
			local MacTheMatrix = Matrix()
			MacTheMatrix:Scale(Vector(self.ShieldGrow, self.ShieldGrow, self.ShieldGrow) * ShieldModulate)
			self:EnableMatrix("RenderMultiply", MacTheMatrix)
			self:DrawModel()
			--JMod.RenderModel(self.Bubble1, SelfPos, ShieldAng, Vector(self.ShieldGrow, self.ShieldGrow, self.ShieldGrow) * ShieldModulate, Vector(1, 1, 1), self.Mat)
		end
	end
	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
