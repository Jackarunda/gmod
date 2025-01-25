AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bubble Shield"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/jmod/giant_hollow_sphere.mdl"--"models/jmod/giant_hollow_dome.mdl"
ENT.PhysgunDisabled = true
ENT.ShieldRadii = {
	[1] = 240,
	[2] = 360,
	[3] = 540,
	[4] = 810,
	[5] = 1620
}
ENT.mmRHAe = 100 -- for ArcCW, hinders bullet penetration of the shield
ENT.DisableDuplicator =	true

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

function ENT:MyCollisionRulesChanged()
	if not self.m_OldCollisionGroup then self.m_OldCollisionGroup = self:GetCollisionGroup() end
	self:SetCollisionGroup(self.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS)
	self:SetCollisionGroup(self.m_OldCollisionGroup)
	self.m_OldCollisionGroup = nil
end
--]]
function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	local SelfPos = self:GetPos()
	local EndPos = startpos + delta
	local TestNorm = (startpos - (EndPos)):GetNormalized()
	local OurNorm = (SelfPos - startpos):GetNormalized()

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
			--print((TestNorm + OurNorm):Length())
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

	--debugoverlay.Cross(EndPos, 2, 5, Color(255, 0, 0), true)
	--debugoverlay.Line(EndPos, EndPos + TestNorm * 5, 5, Color(255, 255, 255), true)
	--[[
	if bit.band(mask, MASK_SHOT) == MASK_SHOT then

		local EdgeTr = util.TraceLine({
			start = startpos,
			endpos = EndPos,
			mask = MASK_SOLID
		})
		if EdgeTr.Hit and (EdgeTr.Entity:GetClass() == "ent_jack_gmod_bubble_shield") then
			debugoverlay.Cross(EdgeTr.HitPos - EdgeTr.Normal * 5, 2, 5, Color(255, 0, 0), true)
			-- Reflect
			local ReflectAng = TestNorm:Angle()
			ReflectAng:RotateAroundAxis(ReflectAng:Right(), 180)
			local ReflectDir = ReflectAng:Forward()

			return {
				HitPos = EdgeTr.HitPos - EdgeTr.Normal * 5,
				Fraction = 1,
				HitNormal = -EdgeTr.HitNormal
			}
		else
			--print("Miss")
		end
	end
	--]]

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
		self:SetModel(self.Model)
		--self:SetMaterial("models/mat_jack_gmod_hexshield1")
		--self:SetMaterial("models/jmod/icosphere_shield")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_GLOW)
		self:AddEFlags(EFL_NO_DISSOLVE)

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end -- something went wrong

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)
		phys:SetMaterial("solidmetal")

		-- Initializing some values
		self:SetSizeClass(1)
		local ShieldGrade = self:GetSizeClass()
		self.ShieldRadius = self.ShieldRadii[ShieldGrade]
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius

		self:EnableCustomCollisions(true)
		if not(self:GetAmInnerShield()) then
			-- Inner shields are for bullets
			self.InnerShield = ents.Create("ent_jack_gmod_bubble_shield")
			self.InnerShield:SetAmInnerShield(true)
			self.InnerShield.OuterShield = self
			self.InnerShield.Projector = self.Projector
			self.InnerShield:SetPos(self:GetPos() - Vector(0, 0, 10))
			self.InnerShield:Spawn()
			self.InnerShield:SetCollisionGroup(COLLISION_GROUP_WORLD)
			self:DeleteOnRemove(self.InnerShield)
			self.InnerShield:SetModelScale(.85, 0.001)
			self.InnerShield:Activate()
			-- We set ourselves to become the prop blocker
			self:SetCustomCollisionCheck(true)
			self:CollisionRulesChanged()
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
		if dmginfo:IsBulletDamage() or dmginfo:IsExplosionDamage() or dmginfo:GetDamageForce():Length() > 10 then
			local Ripple = EffectData()
			Ripple:SetOrigin(DmgPos)
			Ripple:SetScale(Scale)
			Ripple:SetNormal(Dir)
			util.Effect("eff_jack_gmod_refractripple", Ripple, true, true)
			---
			self:EmitSound("snds_jack_gmod/ez_bubbleshield_hits/"..math.random(1, 7)..".ogg", 65, math.random(90, 110))
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
	end

	function ENT:OnRemove()
		--print("Removed Inner Shield", self:GetAmInnerShield())
		SafeRemoveEntity(self.InnerShield)
		SafeRemoveEntity(self.OuterShield)
	end
end

if CLIENT then
	local GlowSprite = Material("sprites/mat_jack_gmod_bubbleshieldglow")

	hook.Add("PostDrawTranslucentRenderables", "JMOD_DRAWBUBBLESHIELD", function()
		for k, v in ipairs(ents.FindByClass("ent_jack_gmod_bubble_shield")) do
			if not v:GetAmInnerShield() then
				local SelfPos = v:GetPos()
				local Epos = EyePos()
				local Vec = Epos - SelfPos
				local Dist = Vec:Length()
				local R, G, B = JMod.GoodBadColor(v.ShieldStrength)
				R = math.Clamp(R + 30, 0, 255)
				G = math.Clamp(G + 30, 0, 255)
				B = math.Clamp(B + 30, 0, 255)
				if (v.ShieldStrength > .2 or math.Rand(0, 1) > .1) then
					if Dist < 240 then
						local Eang = EyeAngles()
						render.SetMaterial(GlowSprite)
						render.DrawSprite(Epos + Eang:Forward() * 10, 45, 35, Color(R, G, B, 200))
					else
						local DistFrac = math.Clamp(600 - Dist, 0, 600) / 600
						local Size = 550 + 800 * DistFrac ^ 2
						render.SetMaterial(GlowSprite)
						render.DrawSprite(SelfPos, Size, Size, Color(R, G, B, 128))
					end
				end
			end
		end
	end)

	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_GLOW)
		--self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield1")
		self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_sphere.mdl", "models/jmod/icosphere_shield")
		-- Initializing some values
		self.ShieldStrength = 1
		self.ShieldRotate = 0
		self:SetSizeClass(1)
		local ShieldGrade = self:GetSizeClass()
		self.ShieldRadius = self.ShieldRadii[ShieldGrade]
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius
		--
		--if IsInnerShield then
			self:EnableCustomCollisions(true)
		--end
		--self:SetCustomCollisionCheck(true)
		--self:MyCollisionRulesChanged()
		--self:CollisionRulesChanged()
		--
	end

	function ENT:Think()
		local FT = FrameTime()
		self.ShieldRotate = (self.ShieldRotate or 0) + FT
		if (self.ShieldRotate > 360) then
			self.ShieldRotate = self.ShieldRotate - 360
		end
	end

	function ENT:DrawTranslucent(flags)
		if self:GetAmInnerShield() then
			return
		end
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .995 + (math.sin(CurTime() * .5) - 0.015) * .005
		local ShieldAng = SelfAng:GetCopy()
		ShieldAng:RotateAroundAxis(ShieldAng:Up(), self.ShieldRotate)
		if (self.ShieldStrength > .2 or math.Rand(0, 1) > .1) then
			JMod.RenderModel(self.Bubble1, SelfPos, ShieldAng, Vector(1, 1, 1) * ShieldModulate)
		end
	end
	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
