AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Personal Bubble Shield"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.Category = "JMod - EZ Misc."
ENT.AdminSpawnable = false
ENT.Model = "models/jmod/hollow_sphere_personal.mdl"
ENT.PhysgunDisabled = true
ENT.ShieldRadius = 60
ENT.mmRHAe = 100 -- for ArcCW, hinders bullet penetration of the shield
ENT.DisableDuplicator =	true

function ENT:GravGunPunt(ply)
	return false
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	local SelfPos = self:GetPos()
	local EndPos = startpos + delta
	local TestNorm = (startpos - (EndPos)):GetNormalized()
	local OurNorm = (SelfPos - startpos):GetNormalized()

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

				return false
			end
		end
	else
		if SelfPos:DistToSqr(startpos) < self.ShieldRadiusSqr then

			return false
		end
	end

	if bit.band(mask, MASK_SHOT) == MASK_SHOT then
		return {
			Fraction = 0
		}
	end

	return true
end

function ENT:SpawnFunction(ply, tr, ClassName)
	if not IsValid(ply) then return end

	local ent = ents.Create(ClassName)
	ent:SetPos(ply:GetPos())
	ent:SetPlayerOwner(ply)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "PlayerOwner")
	self:NetworkVar("Float", 0, "ShieldStrength")
end

function ENT:ImpactTrace(tr, dmgType)
	return true
end

hook.Add("FinishMove", "JMOD_PERSONALBUBBLESHIELD", function(ply, mv) 
	if IsValid(ply.EZpersonalBubbleShield) then
		local TravelDir = mv:GetVelocity():GetNormalized()
		local TraveDist = mv:GetVelocity():Length()
		local OurCompensationMovement = TravelDir * math.Clamp(TraveDist - ply.EZpersonalBubbleShield.ShieldRadius, 0, TraveDist) * FrameTime()
		local AttachPos = ply:LocalToWorld(ply:OBBCenter())
		if ply:LookupBone("ValveBiped.Bip01_Spine1") then
			AttachPos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Spine1"))
		end
		local FinalPos = AttachPos --+ OurCompensationMovement
		local FinalAng = Angle(0, ply:GetAngles().y, 0)
		ply.EZpersonalBubbleShield:SetPos(FinalPos)
		ply.EZpersonalBubbleShield:SetAngles(FinalAng)
	end
end)

if SERVER then
	function ENT:Initialize()
		-- Initializing some values
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius
		local PlayerOwner = self:GetPlayerOwner()
		self:SetOwner(PlayerOwner)
		--
		self:SetModel("models/jmod/hollow_sphere_personal.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_GLOW)
		self:AddEFlags(EFL_NO_DISSOLVE)
		--

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end -- something went wrong

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)
		phys:SetMaterial("solidmetal")

		--
		self:EnableCustomCollisions(true)
		PlayerOwner.EZpersonalBubbleShield = self
		self:SetShieldStrength(1)
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
			if ShieldTr.Hit and IsValid(ShieldTr.Entity) and ShieldTr.Entity:GetClass() == "ent_jack_gmod_bubble_shield_personal" then
				DmgPos = ShieldTr.HitPos
				Dir = ShieldTr.HitNormal
			end
		end
		
		if IsBullet or dmginfo:IsExplosionDamage() or dmginfo:GetDamageForce():Length() > 100 then
			local Ripple = EffectData()
			Ripple:SetEntity(self)
			Ripple:SetOrigin(DmgPos)
			Ripple:SetScale(Scale)
			Ripple:SetNormal(Dir)
			util.Effect("eff_jack_gmod_refractripple", Ripple, true, true)
			---
			sound.Play("snds_jack_gmod/ez_bubbleshield_hits/"..math.random(1, 7)..".ogg", DmgPos, 65, math.random(90, 110))
		end

		self:SetShieldStrength(self:GetShieldStrength() - (dmginfo:GetDamage() / 100))
	end

	function ENT:Think()
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
			self:GetPhysicsObject():EnableMotion(false)
		end
		if self:IsOnFire() then
			self:Extinguish()
		end
		local CurStrength = self:GetShieldStrength()
		if CurStrength <= 0 then
			self:Remove()
		end
		self:SetShieldStrength(math.Clamp(CurStrength + .005, 0, 1))
	end

	function ENT:OnRemove()
		--
	end
end

if CLIENT then
	local GlowSprite = Material("sprites/mat_jack_gmod_bubbleshieldglow")

	hook.Add("PostDrawTranslucentRenderables", "JMOD_DRAWBUBBLESHIELD_PERSONAL", function(bDrawingDepth, bDrawingSkybox, isDraw3DSkybox)
		if bDrawingSkybox then return end
		for _, v in ipairs(ents.FindByClass("ent_jack_gmod_bubble_shield_personal")) do
			local SelfPos = v:GetPos()
			local Epos = EyePos()
			local Vec = Epos - SelfPos
			local Dist = Vec:Length()
			local ShieldStrength = v:GetShieldStrength()
			local R, G, B = JMod.GoodBadColor(ShieldStrength)
			R = math.Clamp(R + 30, 0, 255)
			G = math.Clamp(G + 30, 0, 255)
			B = math.Clamp(B + 30, 0, 255)
			if (ShieldStrength > .2 or math.Rand(0, 1) > .1) then
				if Dist < v.ShieldRadius then
					local Eang = EyeAngles()
					render.SetMaterial(GlowSprite)
					render.DrawSprite(Epos + Eang:Forward() * 10, 45, 35, Color(R, G, B, 200))
				else
					local ShieldRadius = v.ShieldRadius
					local ShieldDiameter = ShieldRadius * 2
					local ShieldPie = ShieldRadius * math.pi
					local DistToEdge = Dist - ShieldRadius
					local DistFrac = math.Clamp(ShieldPie - DistToEdge, 0, ShieldPie) / ShieldPie
					local ClosenessCompensation = (ShieldPie * 1.15) * DistFrac ^ (math.pi ^ 2)
					--print(ClosenessCompensation)
					local Siz = (ShieldDiameter * 1.15 + ClosenessCompensation) * v.ShieldGrow
					render.SetMaterial(GlowSprite)
					render.DrawSprite(SelfPos, Siz, Siz, Color(R, G, B, 128))
				end
			end
		end
	end)

	function ENT:Initialize()
		self.ShieldRadiusSqr = self.ShieldRadius * self.ShieldRadius

		local PlayerOwner = self:GetPlayerOwner()
		if IsValid(PlayerOwner) then
			PlayerOwner.EZpersonalBubbleShield = self
		end

		self:SetRenderMode(RENDERMODE_GLOW)
		--self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield1")
		self.Bubble1 = JMod.MakeModel(self, "models/jmod/hollow_sphere_personal.mdl")
		self.Mat = Material("models/jmod/icosphere_shield")
		-- Initializing some values
		self.ShieldGrow = 0
		self.ShieldGrowEnd = CurTime() + .5
		--
		self:EnableCustomCollisions(true)
	end

	function ENT:Think()
		local FT = FrameTime()
		self.ShieldGrow = Lerp(CurTime() - self.ShieldGrowEnd, 0, 1)
	end

	function ENT:DrawTranslucent(flags)
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .995 + (math.sin(CurTime() * .5) - 0.015) * .005
		self:SetRenderAngles(Angle(0, self.GetPlayerOwner():GetAngles().y, 0))
		--
		local RefractAmt = (math.sin(CurTime() * 3) / 2 + .5) * .045 + .005
		self.Mat:SetFloat("$refractamount", RefractAmt)
		local ShieldStrength = self:GetShieldStrength()
		if (ShieldStrength > .2 or math.Rand(0, 1) > .1) then
			local PlayerOwner = self:GetPlayerOwner()
			if IsValid(PlayerOwner) then
				local NewRenderOrigin = PlayerOwner:LocalToWorld(PlayerOwner:OBBCenter())
				if PlayerOwner:IsPlayer() then
					NewRenderOrigin = PlayerOwner:GetBonePosition(PlayerOwner:LookupBone("ValveBiped.Bip01_Spine1") or 0)
				end
				self:SetRenderOrigin(NewRenderOrigin)
			end
			local MacTheMatrix = Matrix()
			MacTheMatrix:Scale(Vector(self.ShieldGrow, self.ShieldGrow, self.ShieldGrow) * ShieldModulate)
			self:EnableMatrix("RenderMultiply", MacTheMatrix)
			self:DrawModel()
		end
	end
	language.Add("ent_jack_gmod_bubble_shield_personal", "Personal Bubble Shield")
end
