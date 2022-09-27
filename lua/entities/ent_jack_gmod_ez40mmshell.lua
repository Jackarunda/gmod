-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Projectile Grenade Shell"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Model = "models/kali/weapons/mgsv/magazines/ammunition/40mm grenade.mdl"

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:SetModelScale(2, 0)
		self:SetBodygroup(1, 1)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

		timer.Simple(.1, function()
			if IsValid(self) then
				self:GetPhysicsObject():SetMass(1)
			end
		end)

		SafeRemoveEntityDelayed(self, math.random(6, 9))
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("player/pl_shell" .. math.random(1, 3) .. ".wav", 60, 60)
			end
		end
	end
end
