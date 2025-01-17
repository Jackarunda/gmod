AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Bubble Shield"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/jmod/giant_hollow_dome.mdl"

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetMaterial("")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)

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
		self:TakePhysicsDamage(dmginfo)
		-- todo
	end
end

if CLIENT then
	function ENT:Initialize()
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
	end
	language.Add("ent_jack_gmod_bubble_shield", "Bubble Shield")
end
