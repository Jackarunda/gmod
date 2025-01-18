AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bubble Shield"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/jmod/giant_hollow_dome.mdl"
ENT.PhysgunDisabled = true
ENT.ShieldRadiusSqr = 56169

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
	local ShieldEnt = ent1
	local OtherEnt = ent2
	if ent2:GetClass() == "ent_jack_gmod_bubble_shield" then
		ShieldEnt = ent2
		OtherEnt = ent1
	elseif ent1:GetClass() ~= "ent_jack_gmod_bubble_shield" then
		return nil
	end

	if OtherEnt:IsPlayer() then
		return false
	end
	local TheirVel = OtherEnt:GetVelocity()
	local InsideShield = OtherEnt:GetPos():DistToSqr(ShieldEnt:GetPos()) < ShieldEnt.ShieldRadiusSqr
	--local AreTheyTravelingAway = TheirVel:GetNormalized():Dot(ShieldEnt:GetPos() - OtherEnt:GetPos()) > 0
	if InsideShield or TheirVel:Length() < 1000 then
		return false
	end
end)

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMaterial("models/mat_jack_gmod_hexshield")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)--COLLISION_GROUP_WORLD)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self:SetCustomCollisionCheck(true)
		self:CollisionRulesChanged()

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end -- something went wrong

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)
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

local ShieldColor = Color(255, 252, 50)
local Refract = Material("sprites/mat_jack_shockwave")

if CLIENT then
	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.Bubble1 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield")
		self.Bubble2 = JMod.MakeModel(self, "models/jmod/giant_hollow_dome.mdl", "models/mat_jack_gmod_hexshield")
	end

	function ENT:DrawTranslucent(flags)
		local FT = FrameTime()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local ShieldModulate = .98 + (math.sin(CurTime() * .5) - 0.015) * 0.01
		JMod.RenderModel(self.Bubble1, SelfPos, SelfAng, Vector(1, 1, 1) * ShieldModulate, ShieldColor:ToVector())
		JMod.RenderModel(self.Bubble2, SelfPos, SelfAng, nil, ShieldColor:ToVector())

		--render.SetMaterial(Refract)
		--render.DrawSprite(SelfPos, 650, 650, ShieldColor)
	end
	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
