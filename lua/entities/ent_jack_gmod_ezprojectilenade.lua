-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Projectile Grenade"
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
		self:SetModelScale(2, 0)
		self:SetBodygroup(1, 2)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self.AutoDetTime = CurTime() + 10
		self:GetPhysicsObject():EnableDrag(false)

		timer.Simple(0, function()
			if IsValid(self) then
				self:GetPhysicsObject():SetMass(2)
			end
		end)

		self.Damage = self.Damage or 150
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 200 then
				self:Detonate()
			else
				self:EmitSound(self.ImpactSound)
			end
		end
	end

	function ENT:Think()
		local Time = CurTime()

		if self.AutoDetTime < Time then
			self:Detonate()
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		JMod.Sploom(self.Owner or self, self:GetPos() + Vector(0, 0, 10), self.Damage ^ .95, self.BlastRadius)
		self:Remove()
	end
elseif CLIENT then
	function ENT:Initialize()
		self.NoDrawTime = CurTime() + .5
	end

	function ENT:Draw()
		if self:GetVelocity():Length() < 1 and self.NoDrawTime > CurTime() then
		else -- don't draw
			self:DrawModel()
		end
	end
end
