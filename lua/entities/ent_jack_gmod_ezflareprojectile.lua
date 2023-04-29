-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Flare Projectile"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/kali/weapons/mgsv/magazines/ammunition/40mm grenade.mdl"
ENT.Material = nil
ENT.ModelScale = nil
ENT.ImpactSound = "Grenade.ImpactHard"
ENT.CollisionGroup = COLLISION_GROUP_NONE

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetBodygroup(1, 2)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:GetPhysicsObject():EnableDrag(false)

		timer.Simple(0, function()
			if IsValid(self) then
				self:GetPhysicsObject():SetMass(2)
			end
		end)

		self.StartFloatingTime = CurTime() + 3
		self.Floating = false

		SafeRemoveEntityDelayed(self, 25)
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:Think()
		local Time = CurTime()

		if (self.StartFloatingTime < Time and not self.Floating) then
			self.Floating = true
			self:GetPhysicsObject():EnableDrag(true)
			self:GetPhysicsObject():SetDamping(20, 20)
		end

		local Vel = self:GetVelocity()

		local Fsh = EffectData()
		Fsh:SetOrigin(self:GetPos())
		Fsh:SetScale(1)
		Fsh:SetNormal(-Vel:GetNormalized())
		Fsh:SetStart(Vel)
		util.Effect("eff_jack_gmod_projectileflareburn", Fsh, true, true)

		if (self.Floating) then self:GetPhysicsObject():ApplyForceCenter(JMod.Wind * 200) end

		self:NextThink(Time + .1)
		return true
	end
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		local BurnDir = -self:GetVelocity():GetNormalized()
		local R, G, B = 255, 50, 25

		render.SetMaterial(GlowSprite)
		local EyeVec = EyePos() - Pos
		local EyeDir, Dist = EyeVec:GetNormalized(), EyeVec:Length()
		local DistFrac = math.Clamp(Dist, 0, 400) / 400
		render.DrawSprite(Pos + BurnDir * 8 + EyeDir * 20, 400, 400, Color(R, G, B, 255 * DistFrac))

		for i = 1, 10 do
			render.DrawSprite(Pos + BurnDir * (8 + i) + VectorRand() + EyeDir * 20, 40 - i, 40 - i, Color(R, G, B, math.random(100, 200)))
			render.DrawSprite(Pos + BurnDir * (8 + i) + VectorRand() + EyeDir * 20, 20 - i, 20 - i, Color(255, 255, 255, math.random(100, 200)))
		end
	end

	language.Add("ent_jack_gmod_ezflareprojectile", "EZ Flare Projectile")
end
