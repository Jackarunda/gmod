ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Lua Seat"
ENT.Author = "Copper"
ENT.Contact = [[Copper#3867]]
ENT.Purpose = "Replace the buggy engine vehicles with dynamic and adjustable seats!"
ENT.Instructions = "Spawn the generic seat or use the tool!" 
ENT.Category = "Other"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.AutomaticFrameAdvance = true
ENT.Animated = true
local physcanmanip = GetConVar("luaseat_phys_can_manipulate")

ENT.JuaSeat = true

hook.Add("SetupMove", "JuaSeat - Hold Player", function(ply, mv, cmd)
	if ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
		local veh = ply:GetVehicle()
		if SERVER or game.SinglePlayer() then
			mv:SetOrigin(veh:GetWorldSeatPos())
			mv:SetVelocity(Vector())
			veh.SitTimer = veh.SitTimer or CurTime() + veh:GetSitTime()
			veh.EyeStart = veh.EyeStart or ply:EyePos()
			
			local pos = veh:GetVehicleViewPosition()
			if CurTime() > veh.SitTimer then
				pos = veh:GetVehicleViewPosition()
				else
				local mult = (CurTime() - veh.SitTimer)/veh:GetSitTime()
				pos = LerpVector(mult, veh.EyeStart, veh:GetVehicleViewPosition())
			end
			local rotpos = pos - mv:GetOrigin()
			ply:SetViewOffset(rotpos)
			if mv:KeyPressed(IN_DUCK) then
				veh:SetThirdPersonMode(not veh:GetThirdPersonMode())
				ply:SetParent()
			end
			if mv:KeyReleased(IN_DUCK) then
				ply:RemoveFlags(FL_DUCKING)
				ply:RemoveFlags(FL_ANIMDUCKING)
			end
			if not IsValid(ply.CamController) then
				if veh:GetThirdPersonMode() then
					if veh:GetTPViewLock() == 2 then
						cmd:SetViewAngles((veh:GetSeatAng()))
						ply:SetEyeAngles((veh:GetSeatAng()))
					end
				else
					if veh:GetFPViewLock() == 2 then
						cmd:SetViewAngles((veh:GetSeatAng()))
						ply:SetEyeAngles((veh:GetSeatAng()))
					end
				end
				if veh:GetThirdPersonMode() then
					if veh:GetTPViewLock() == 0 then
						if ply:GetParent() == veh then
							ply:SetEyeAngles(ply:GetAimVector():Angle())
							ply:SetParent()
						end
					end
					if veh:GetTPViewLock() >= 1 then
						if ply:GetParent() ~= veh then
							ply:SetEyeAngles((veh:GetSeatAng()))
							ply:SetAngles(veh:GetAngles() + veh:GetSeatAng())
							ply:SetParent(veh)
							veh:AddEFlags(EFL_HAS_PLAYER_CHILD)
						end
					end
					if veh:GetTPViewLock() == 2 then
						cmd:SetViewAngles((veh:GetSeatAng()))
						ply:SetEyeAngles((veh:GetSeatAng()))
					end
				else
					if veh:GetFPViewLock() == 0 then
						if ply:GetParent() == veh then
							ply:SetEyeAngles(ply:GetAimVector():Angle())
							ply:SetParent()
						end
					end
					if veh:GetFPViewLock() >= 1 then
						if ply:GetParent() ~= veh then
							ply:SetEyeAngles((veh:GetSeatAng()))
							ply:SetAngles(veh:GetAngles() + veh:GetSeatAng())
							ply:SetParent(veh)
							veh:AddEFlags(EFL_HAS_PLAYER_CHILD)
						end
					end
					if veh:GetFPViewLock() == 2 then
						cmd:SetViewAngles((veh:GetSeatAng()))
						ply:SetEyeAngles((veh:GetSeatAng()))
					end
				end
				if veh:GetThirdPersonMode() then
					veh:SetCameraDistance(math.max(15, veh:GetCameraDistance() - (cmd:GetMouseWheel() * veh:GetCameraDistance()/100) * 5))
					if mv:KeyDown(IN_SPEED) then
						veh:SetCameraDistance(math.max(15, veh:GetCameraDistance() - (cmd:GetMouseWheel() * veh:GetCameraDistance()/100) * 15))
					end
				end
			end
			if mv:KeyPressed(IN_USE) then
				ply:ExitVehicle()
				mv:SetOrigin(veh:LocalToWorld(veh:GetExitPos()))
			end
		end
	end
end)

hook.Add("PlayerUse", "JuaSeat - Interrupt Use", function(ply, entity)
	if ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() and ply:GetVehicle() ~= entity then
		if not(ply:GetVehicle():GetAllowUse()) then
			ply:ExitVehicle()
			return false
		end
		if entity:IsVehicle() then
			ply:ExitVehicle()
			return false
		end
	end
end)

hook.Add("PhysgunPickup", "JuaSeat - Deny Physgun", function(ply, entity)
	if physcanmanip and physcanmanip:GetBool() then
		if ply:InVehicle() and ply:GetVehicle() == entity and entity:IsLuaVehicle() then
			return false
		end
	end
end)

hook.Add("GravGunPickupAllowed", "JuaSeat - Deny Gravgun", function(ply, entity)
	if physcanmanip and physcanmanip:GetBool() then
		if ply:InVehicle() and ply:GetVehicle() == entity and entity:IsLuaVehicle() then
			return false
		end
	end
end)

hook.Add("GravGunPunt", "JuaSeat - Deny Gravgun", function(ply, entity)
	if physcanmanip and physcanmanip:GetBool() then
		if ply:InVehicle() and ply:GetVehicle() == entity and entity:IsLuaVehicle() then
			return false
		end
	end
end)

function ENT:GetWorldSeatPos()
	return self:LocalToWorld(self:GetSeatPos())
end

local luaseat_allowdamage = GetConVar("luaseat_damage_in_seat")

hook.Add("EntityTakeDamage", "JuaSeat - Prevent Damage In Seat", function(ent, dmg)
	if ent:IsPlayer() and ent:InVehicle() and ent:GetVehicle():IsLuaVehicle() then
		if luaseat_allowdamage and not luaseat_allowdamage:GetBool() then
			return true
		end
	end
end)

hook.Add("AcceptInput", "JuaSeat - Catch Vehicle Inputs", function(ent, input, activator, caller, value)
	if ent:IsLuaVehicle() then
		if ent["fire"..input] then
			ent["fire"..input](ent, input, activator, caller, value)
		end
	end
end)

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 1, "SeatedPlayer")
	self:NetworkVar("Int", 1, "FPViewLock")
	self:NetworkVar("Int", 2, "TPViewLock")
	self:NetworkVar("Float", 1, "CameraDistance")
	self:NetworkVar("Float", 2, "SitTime")
	self:NetworkVar("Bool", 1, "ThirdPersonMode")
	self:NetworkVar("Bool", 2, "Locked")
	self:NetworkVar("Bool", 3, "CamSolid")
	self:NetworkVar("Bool", 4, "AllowUse")
	self:NetworkVar("Bool", 5, "AllowWep")
	self:NetworkVar("Vector", 1, "SeatPos")
	self:NetworkVar("Vector", 2, "ExitPos")
	self:NetworkVar("Vector", 3, "ViewPos")
	self:NetworkVar("Angle", 1, "SeatAng")
	self:NetworkVar("String", 1, "SitAnim")
end

function ENT:fireLock()
	self:SetLocked(true)
end

function ENT:fireUnlock()
	self:SetLocked(false)
end

local ENTITY_META = FindMetaTable("Entity")

ENTITY_META.IsLuaVehicle = function(self)
	if self.JuaSeat then return true end
	return false
end

local oldv = ENTITY_META.IsVehicle
ENTITY_META.IsVehicle = function(self)
	if self:IsLuaVehicle() then
		return true
	else
		return oldv(self)
	end
end

local holdtypes = {
	["pistol"] = "_pistol",
	["smg"] = "_smg1",
	["grenade"] = "_grenade",
	["ar2"] = "_ar2",
	["shotgun"] = "_shotgun",
	["rpg"] = "_rpg",
	["physgun"] = "_physgun",
	["crossbow"] = "_crossbow",
	["melee"] = "_melee",
	["slam"] = "_slam",
	["normal"] = "",
	["fist"] = "_fist",
	["melee2"] = "_melee2",
	["passive"] = "_passive",
	["knife"] = "_knife",
	["duel"] = "_duel",
	["camera"] = "_camera",
	["magic"] = "_zen",
	["revolver"] = "_pistol",
	[""] = ""
}

local function TranslateAnim(ply, anim, holdtype)
	if anim == "sit" or anim == "idle" or anim == "swim_idle" or anim == "cidle" then
		if holdtype == "" or holdtype == "normal" then
			if anim == "idle" or anim == "swim_idle" or anim == "cidle" then
				anim = anim.."_all"
				if anim == "idle_all" then
					anim = anim.."_01"
				end
			end
			else
			local tag = holdtypes[ply:GetActiveWeapon():GetHoldType()]
			tag = tag or ""
			anim = anim..tag
		end
	end
	return ply:LookupSequence(anim)
end

hook.Add("CalcMainActivity", "JuaSeat - SitAnimation", function(ply)
	if ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
		local wep = ply:GetActiveWeapon()
		local holdtype = ""
		if IsValid(wep) then holdtype = wep:GetHoldType() end
		local seq = TranslateAnim(ply, ply:GetVehicle():GetSitAnim(), holdtype)
		ply:ResetSequence(seq)
		ply:AnimResetGestureSlot(1)
		ply:AnimResetGestureSlot(2)
		ply:AnimResetGestureSlot(3)
		ply:AnimResetGestureSlot(6)
		return ply:GetSequenceActivity(seq), seq
	end
end)
local oldupdate = GAMEMODE.UpdateAnimation
GAMEMODE.UpdateAnimation = function(self, ply, vel, maxseq)
	if ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
		local ang = ply:GetVehicle():LocalToWorldAngles(ply:EyeAngles())
		ply:SetPoseParameter(ply:GetPoseParameterName(2), ang.y - 90)
		ply:SetPoseParameter(ply:GetPoseParameterName(6), ang.y - 90)
		ply:SetPoseParameter(ply:GetPoseParameterName(3), ang.p)
		ply:SetPoseParameter(ply:GetPoseParameterName(7), ang.p)
	end
	return oldupdate
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local PLAYER_META = FindMetaTable("Player")

local oldinv = PLAYER_META.InVehicle
PLAYER_META.InVehicle = function(self)
	if IsValid(self.LuaVehicle) and self.LuaVehicle:GetSeatedPlayer() == self then
		return true
	else
		return oldinv(self)
	end
end
local oldgv = PLAYER_META.GetVehicle
PLAYER_META.GetVehicle = function(self)
	if IsValid(self.LuaVehicle) and self.LuaVehicle:GetSeatedPlayer() == self then
		return self.LuaVehicle
	else
		return oldgv(self)
	end
end

---Vehicle Facsimile Functions

function ENT:GetDriver()
	return self:GetSeatedPlayer()
end

function ENT:GetPassenger()
	return self:GetSeatedPlayer()
end

function ENT:GetVehicleClass()
	return self:GetClass()
end

function ENT:SetVehicleClass()
end

function ENT:GetVehicleViewPosition()
	return self:LocalToWorld(self:GetViewPos()), self:GetAngles(), self:GetSeatedPlayer():GetFOV()
end

function ENT:IsValidVehicle()
	return true
end