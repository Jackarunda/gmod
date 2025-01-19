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

function ENT:GravGunPunt(ply)
	return false
end

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

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMaterial("models/mat_jack_gmod_hexshield")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end -- something went wrong

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)

		--self:EnableCustomCollisions(true)
		--self:SetCustomCollisionCheck(true)
		--self:CollisionRulesChanged()
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:OnTakeDamage(dmginfo)
		--self:TakePhysicsDamage(dmginfo)
		-- todo
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
end

if CLIENT then
	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield")
		--self.Bubble2 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield")
		--self:EnableCustomCollisions(true)
		--self:SetCustomCollisionCheck(true)
		--self:CollisionRulesChanged()
	end

	local ShieldColor = Color(255, 255, 255)
	local GlowSprite = Material("sprites/mat_jack_gmod_bubbleshieldglow")
	function ENT:DrawTranslucent(flags)
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .98 + (math.sin(CurTime() * .5) - 0.015) * 0.01
		self.ShieldRotate = (self.ShieldRotate or 0) + FT
		local ShieldAng = SelfAng:GetCopy()
		ShieldAng:RotateAroundAxis(ShieldAng:Up(), self.ShieldRotate)
		JMod.RenderModel(self.Bubble1, SelfPos, ShieldAng, Vector(1, 1, 1) * ShieldModulate, ShieldColor:ToVector())
		--JMod.RenderModel(self.Bubble2, SelfPos, ShieldAng, nil, ShieldColor:ToVector())

		local Epos = EyePos()
		local Vec = Epos - SelfPos
		local Dist = Vec:Length()
		local Dir = Vec:GetNormalized()
		local DistFrac = (math.Clamp(1000 - Dist, 0, 1000) / 1000) ^ 2
		--jprint(DistFrac)
		render.SetMaterial(GlowSprite)
		render.DrawSprite(SelfPos + Dir * 240, 350, 350, Color(255, 255, 255, 100))

		--render.SetMaterial(Refract)
		--render.DrawSprite(SelfPos, 650, 650, ShieldColor)
	end
	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
