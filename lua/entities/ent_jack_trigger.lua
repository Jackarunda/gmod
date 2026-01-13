-- Jackarunda 2021 - Trigger Entity
-- A dedicated trigger entity for touch-based detection
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "EZ Trigger"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "OwnerSentry")
end

if SERVER then
	function ENT:Initialize()
		--self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetNotSolid(true)
		
		-- Start disabled
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		
		-- Prevent all interactions
		self:SetUnFreezable(true)
		self.PhysgunDisabled = true
		self.m_tblToolsAllowed = {}
	end

	function ENT:SetTriggerBounds(radius)
		local mins = Vector(-radius, -radius, -radius)
		local maxs = Vector(radius, radius, radius)
		
		self:PhysicsInitBox(mins, maxs)
		
		-- Configure physics object to be non-interactive
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
			phys:SetMass(1)
			phys:AddGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)
		end
		
		-- Apply trigger-only solid flags
		self:SetSolid(SOLID_BBOX)
		self:SetSolidFlags(bit.bor(FSOLID_NOT_SOLID, FSOLID_TRIGGER))
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end

	function ENT:EnableTrigger()
		self:SetSolid(SOLID_BBOX)
		self:SetSolidFlags(bit.bor(FSOLID_NOT_SOLID, FSOLID_TRIGGER))
	end

	function ENT:DisableTrigger()
		self:SetSolid(SOLID_NONE)
	end

	function ENT:StartTouch(ent)
		local sentry = self:GetOwnerSentry()
		if IsValid(sentry) and sentry.OnTargetEnterRange then
			sentry:OnTargetEnterRange(ent)
		end
	end

	function ENT:EndTouch(ent)
		local sentry = self:GetOwnerSentry()
		if IsValid(sentry) and sentry.OnTargetLeaveRange then
			sentry:OnTargetLeaveRange(ent)
		end
	end

	function ENT:PhysgunPickup(ply)
		return false
	end

	function ENT:GravGunPickupAllowed(ply)
		return false
	end

	function ENT:CanTool(ply, trace, tool)
		return false
	end

	function ENT:OnRemove()
		-- Notify sentry if it still exists
		local sentry = self:GetOwnerSentry()
		if IsValid(sentry) then
			sentry.TargetingTrigger = nil
		end
	end

elseif CLIENT then
	local TriggerColor = Color(255, 0, 0)
	local debugconvar = GetConVar("developer")
	function ENT:Draw()
		-- Never draw
		local ply = LocalPlayer()
		local sentry = self:GetOwnerSentry()
		local debugmode = debugconvar:GetBool()
		if IsValid(sentry) and ply:GetEyeTrace().Entity == sentry and debugmode then
			-- Draw a box to show the trigger bounds
			local mins = self:OBBMins()
			local maxs = self:OBBMaxs()
			render.DrawWireframeBox(self:GetPos(), self:GetAngles(), mins, maxs, TriggerColor, false)
		end
	end
end
