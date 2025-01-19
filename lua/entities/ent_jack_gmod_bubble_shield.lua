AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bubble Shield"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/jmod/giant_hollow_dome.mdl"
ENT.PhysgunDisabled = true
ENT.ShieldRadiusSqr = 238 * 238
ENT.mmRHAe = 10 -- for ArcCW, hinders bullet penetration of the shield

function ENT:GravGunPunt(ply)
	return false
end

--[[
hook.Add("EntityFireBullets", "JMOD_SHIELDBULLETS", function(ent, data) 
	local ShieldBubbles = ents.FindByClass("ent_jack_gmod_bubble_shield")
	if #ShieldBubbles > 0 then
		for k, v in ipairs(ShieldBubbles) do
			if data.Src:DistToSqr(v:GetPos()) < v.ShieldRadiusSqr then
				local EdgeTr = util.TraceLine(
					{start = data.Src, 
					endpos = data.Src + data.Dir * data.Distance,
					mask = MASK_ALL,
					filter = {ent}
				})
				if EdgeTr.Entity == v then
					data.Src = EdgeTr.HitPos + EdgeTr.Normal * 30
					return true
				end
			end
		end
	end
end)
--]]

--[[
hook.Add("ShouldCollide", "JMOD_SHIELDCOLLISION", function(ent1, ent2)
	local snc1 = ent1.ShouldNotCollide
	if snc1 and snc1(ent1, ent2) then return false end

	local snc2 = ent2.ShouldNotCollide
	if snc2 and snc2(ent2, ent1) then return false end
end)

function ENT:ShouldNotCollide(ent)
	if ent:IsPlayer() then
		return true
	end
	local TheirVel = ent:GetVelocity()
	local InsideShield = ent:GetPos():DistToSqr(self:GetPos()) < self.ShieldRadiusSqr
	if InsideShield or TheirVel:Length() < 1000 then
		return true
	end

	return false
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	if startpos:DistToSqr(self:GetPos()) < self.ShieldRadiusSqr then
		return false
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
		self:SetModel(self.Model)
		self:SetMaterial("models/mat_jack_gmod_hexshield1")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_GLOW)

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end -- something went wrong

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)
		phys:SetMaterial("solidmetal")

		--self:EnableCustomCollisions(true)
		--self:SetCustomCollisionCheck(true)
		--self:CollisionRulesChanged()

		--[[
		if (not(self:GetAmInnerShield())) then
			self.InnerShield = ents.Create("ent_jack_gmod_bubble_shield")
			self.InnerShield:SetAmInnerShield(true)
			self.InnerShield.OuterShield = self
			self.InnerShield:SetPos(self:GetPos() - Vector(0, 0, 10))
			self.InnerShield:Spawn()
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
		local Ripple = EffectData()
		Ripple:SetOrigin(DmgPos)
		Ripple:SetScale(Scale)
		Ripple:SetNormal(Dir)
		util.Effect("eff_jack_gmod_refractripple", Ripple, true, true)
		---
		self:EmitSound("snds_jack_gmod/ez_bubbleshield_hits/"..math.random(1, 7)..".ogg", 65, math.random(90, 110))
		---
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
			if IsValid(self:GetPhysicsObject()) then
				self:GetPhysicsObject():EnableMotion(false)
			end
		end
	end

	function ENT:OnRemove()
		if (IsValid(self.InnerShield)) then self.InnerShield:Remove() end
	end
end

if CLIENT then
	local GlowSprite = Material("sprites/mat_jack_gmod_bubbleshieldglow")

	hook.Add("PostDrawTranslucentRenderables", "JMOD_POSTDRAWTRANSLUCENTRENDERABLES", function()
		for k, v in ipairs(ents.FindByClass("ent_jack_gmod_bubble_shield")) do
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
	end)

	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_GLOW)
		self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield1")
		self.ShieldStrength = 1
	end

	function ENT:DrawTranslucent(flags)
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .995 + (math.sin(CurTime() * .5) - 0.015) * .005
		self.ShieldRotate = (self.ShieldRotate or 0) + FT
		local ShieldAng = SelfAng:GetCopy()
		ShieldAng:RotateAroundAxis(ShieldAng:Up(), self.ShieldRotate)
		if (self.ShieldStrength > .2 or math.Rand(0, 1) > .1) then
			JMod.RenderModel(self.Bubble1, SelfPos, ShieldAng, Vector(1, 1, 1) * ShieldModulate)
		end
	end
	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
