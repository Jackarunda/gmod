AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

local anims = {
	["Pod"] = "drive_pd"
}

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit  then return end

	local ent = ents.Create( ClassName )
	ent:SetModel( "models/props_interiors/Furniture_Couch02a.mdl" )
	local SpawnPos = tr.HitPos - tr.HitNormal * ent:OBBMins().z
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end
function ENT:Initialize()

	self:ResetPhysics()
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use( activator, caller )
	if not IsValid(self:GetSeatedPlayer()) and not activator:InVehicle() then
		self:Enter(activator)
	else
		if activator == self:GetSeatedPlayer() then
			self:Exit()
		end
	end
end

function ENT:ResetPhysics()
	if not util.IsValidProp(self:GetModel()) then
		self:PhysicsInit( SOLID_OBB )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_OBB )
		self:SetUseType( SIMPLE_USE )
	else
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	end
	self:SetCollisionGroup(COLLISION_GROUP_VEHICLE)
	self.LastModel = self:GetModel()
end

function ENT:Think()
	if self.LastModel ~= self:GetModel() then
		self:ResetPhysics()
		self.LastModel = self:GetModel()
	end
end

hook.Add("SetupPlayerVisibility", "ViewFromSeat", function(ply, ent)
	if ply:InVehicle() and IsValid(ply:GetVehicle()) and ply:GetVehicle():IsLuaVehicle() then
		AddOriginToPVS(ply:GetVehicle():LocalToWorld(ply:GetVehicle():GetViewPos()))
	end
end)

function ENT:Enter(ply)
	if self:GetLocked() then self:EmitSound("doors/default_locked.wav") return end
	if hook.Run("CanPlayerEnterVehicle", ply, self, 0) then
		if IsValid(ply.LuaVehicle) then ply.LuaVehicle:Exit() end
		if prone then --Prone Mod Compatibility
			prone.Exit(ply)
		end
		self:SetSeatedPlayer(ply)
		ply.LuaVehicle = self
		--[[if self:GetAllowWep() then
			ply:SetAllowWeaponsInVehicle(true)
		else
			ply.LuS_OldWeps = {}
			ply.LuS_OldActiveWep = ply:GetActiveWeapon()
			if IsValid(ply.LuS_OldActiveWep) then ply.LuS_OldActiveWep = ply.LuS_OldActiveWep:GetClass() end
			for k,v in pairs(ply:GetWeapons()) do
				ply.LuS_OldWeps[k] = v:GetClass()
			end
			ply:StripWeapons()
		end--]]
		ply:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		ply:SetEyeAngles((self:GetSeatAng()))
		ply.LuS_OldViewOffset = ply:GetViewOffset()
		ply.LuS_OldViewOffsetDucked = ply:GetViewOffsetDucked()
		ply:SetMoveType(MOVETYPE_NONE)
		local mins, maxs = ply:GetHull()
		ply.LuS_FullHull_Mins = ply.LuS_FullHull_Mins or mins
		ply.LuS_FullHull_Maxs = ply.LuS_FullHull_Maxs or maxs
		ply:SetHull(ply.LuS_FullHull_Mins/2, ply.LuS_FullHull_Maxs/2)
		if self:GetFPViewLock() > 0 then
			ply:SetPos(self:GetWorldSeatPos())
			ply:SetAngles(self:GetAngles() + self:GetSeatAng())
			ply:SetParent(self)
			self:AddEFlags(EFL_HAS_PLAYER_CHILD)
		end
		hook.Run("PlayerEnteredVehicle", ply, self, 0)
		if IsValid(ply.CamController) then
			ply:SetPos(self:GetWorldSeatPos())
			ply:SetAngles(self:GetAngles() + self:GetSeatAng())
			ply:SetParent(self)
			self:AddEFlags(EFL_HAS_PLAYER_CHILD)
		end
	end
end

function ENT:Exit()
	local ply = self:GetSeatedPlayer()
	if hook.Run("CanExitVehicle", self, ply) then
		if IsValid(ply) then
			ply.LuaVehicle = nil
			ply:SetAllowWeaponsInVehicle(false)
			--[[if ply.LuS_OldWeps and #ply.LuS_OldWeps > 0 then
				for k,v in pairs(ply.LuS_OldWeps) do
					ply:Give(v)
					ply:RemoveAmmo(ply:GetWeapon(v):GetMaxClip1(), ply:GetWeapon(v):GetPrimaryAmmoType())
				end
				ply:SelectWeapon(ply.LuS_OldActiveWep)
				ply.LuS_OldWeps = nil
				ply.LuS_OldActiveWep = nil
			end--]]
			self:SetSeatedPlayer()
			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			ply:SetViewOffset(ply.LuS_OldViewOffset or Vector(0, 0, 64))
			ply:SetViewOffsetDucked(ply.LuS_OldViewOffsetDucked or Vector(0, 0, 28))
			ply:SetParent()
			ply:SetMoveType(MOVETYPE_WALK)
			ply:SetPos(self:LocalToWorld(self:GetExitPos()))
			ply:SetEyeAngles(self:GetAngles():Forward():Angle())
			if ply.LuS_FullHull_Mins then
				ply:SetHull(ply.LuS_FullHull_Mins, ply.LuS_FullHull_Maxs)
			end
			hook.Run("PlayerLeaveVehicle", ply, self)
		end
	end
end

hook.Add("PlayerDeath", "JuaSeat - Leave On Death", function(ply, inflict, attack)
	if IsValid(ply.LuaVehicle) then
		ply.LuaVehicle:Exit()
	end
end)

function ENT:OnRemove()
	if IsValid(self:GetSeatedPlayer()) then
		self:Exit()
	end
end

local tab = {
	Model = "models/props_interiors/Furniture_Couch02a.mdl",
	FPViewLock = 0,
	TPViewLock = 0,
	CamSolid = false,
	AllowUse = false,
	AllowWep = false,
	SeatPos = Vector(),
	ExitPos = Vector(),
	ViewPos = Vector(),
	SeatAng = Angle(),
	SitAnim = "sit",
	SitTime = 1
}

function ENT:PreEntityCopy()
	for k,v in pairs(tab) do
		tab[k] = self["Get"..k](self)
	end
	self.DupeInfo = tab
	duplicator.StoreEntityModifier(self, "JuaSeat_DupeInfo", tab)
end

local ApplySeatInfo = function(Player, Entity, Data)
	if not Data then return end
	for k,v in pairs(Data) do
		Entity["Set"..k](Entity, v)
	end
end

duplicator.RegisterEntityModifier("JuaSeat_DupeInfo", ApplySeatInfo)

function ENT:PostEntityPaste()
	
end

local PLAYER_META = FindMetaTable("Player")

local oldenter = PLAYER_META.EnterVehicle
PLAYER_META.EnterVehicle = function(self, vehicle)
	if vehicle:IsLuaVehicle() then
		vehicle:Enter(self)
	else
		return oldenter(self, vehicle)
	end
end
local oldexit = PLAYER_META.ExitVehicle
PLAYER_META.ExitVehicle = function(self)
	local vehicle = self:GetVehicle()
	if vehicle:IsLuaVehicle() then
		vehicle:Exit()
	else
		return oldexit(self)
	end
end

---Vehicle Facsimile Functions

function ENT:BoostTimeLeft()
	return 0
end

function ENT:CheckExitPoint()
	return self:LocalToWorld(self:GetExitPos())
end

function ENT:EnableEngine()
	return nil
end

function ENT:GetHLSpeed()
	return self:GetVelocity():Length()
end

function ENT:GetMaxSpeed()
	return 0
end

local blankparams = {
	RPM = 0,
	gear = 0,
	isTorqueBoosting = false,
	speed = 0,
	steeringAngle = 0,
	wheelsInContact = false
}

function ENT:GetOperatingParams()
	return blankparams
end

function ENT:GetPassengerSeatPoint()
	return self:GetWorldSeatPos(), self:GetAngles()
end

function ENT:GetRPM()
	return 0
end

function ENT:GetSpeed()
	return 0
end

function ENT:GetSteering()
	return 0
end

function ENT:GetSteeringDegrees()
	return 0
end

function ENT:GetThrottle()
	return 0
end

local blankvparams = {
	wheelsPerAxle = 0,
	axleCount = 0,
	axles = {
		brakeFactor = 0,
		offset = Vector(),
		raytraceCenterOffset = Vector(),
		raytraceOffset = Vector(),
		suspension_maxBodyForce = 0,
		suspension_springConstant = 0,
		suspension_springDamping = 0,
		suspension_springDampingCompression = 0,
		suspension_stabilizerConstant = 0,
		torqueFactor = 0,
		wheelOffset = Vector(),
		wheels_brakeMaterialIndex = 0,
		wheels_damping = 0,
		wheels_frictionScale = 0,
		wheels_inertia = 0,
		wheels_mass = 0,
		wheels_materialIndex = 0,
		wheels_radius = 0,
		wheels_rotdamping = 0,
		wheels_skidMaterialIndex = 0,
		wheels_springAdditionalLength = 0
	},
	body = {
		addGravity = 0,
		counterTorqueFactor = 0,
		keepUprightTorque = 0,
		massCenterOverride = Vector(),
		massOverride = 0,
		maxAngularVelocity = 0,
		tiltForce = 0,
		tiltForceHeight = 0
	},
	engine = {
		autobrakeSpeedFactor = 0,
		autobrakeSpeedGain = 0,
		axleRatio = 0,
		boostDelay = 0,
		boostDuration = 0,
		boostForce = 0,
		boostMaxSpeed = 0,
		gearCount = 0,
		gearRatio = {
			0, 0, 0, 0
		},
		horsepower = 0,
		isAutoTransmission = true,
		maxRPM = 0,
		maxRevSpeed = 0,
		maxSpeed = 0,
		shiftDownRPM = 0,
		shiftUpRPM = 0,
		throttleTime = 0,
		torqueBoost = true
	},
	steering = {
		boostSteeringRateFactor = 0,
		boostSteeringRestRateFactor = 0,
		brakeSteeringRateFactor = 0,
		degreesBoost = 0,
		degreesFast = 0,
		degreesSlow = 0,
		dustCloud = false,
		isSkidAllowed = true,
		powerSlideAccel = 0,
		speedFast = 0,
		speedSlow = 0,
		steeringExponent = 0,
		steeringRateFast = 0,
		steeringRateSlow = 0,
		steeringRestRateFast = 0,
		steeringRestRateSlow = 0,
		throttleSteeringRestRateFactor = 0,
		turnThrottleReduceFast = 0,
		turnThrottleReduceSlow = 0
	}
}

function ENT:GetVehicleParams()
	return blankvparams
end

function ENT:GetWheel()
	return nil
end

function ENT:WheelBaseHeight()
	return 0
end

function ENT:GetWheelContactPoint()
	return Vector(), 0, false
end

function ENT:GetWheelCount()
	return 0
end

function ENT:GetWheelTotalHeight()
	return 0
end

function ENT:HasBoost()
	return false
end

function ENT:HasBrakePedal()
	return false
end

function ENT:IsBoosting()
	return false
end

function ENT:IsEngineEnabled()
	return false
end

function ENT:IsEngineStarted()
	return false
end

function ENT:IsVehicleBodyInWater()
	return self:WaterLevel() > 1
end

function ENT:ReleaseHandbrake()
end

function ENT:SetBoost()
end

function ENT:SetHandbrake()
end

function ENT:SetHasBrakePedal()
end

function ENT:SetMaxReverseThrottle()
end

function ENT:SetMaxThrottle()
end

function ENT:SetSpringLength()
end

function ENT:SetSteering()
end

function ENT:SetThrottle()
end

function ENT:SetVehicleEntryAnim()
end

function ENT:SetVehicleParams()
end

function ENT:SetWheelFriction()
end

function ENT:StartEngine()
end


--Prone Mod Compatibility
if prone then
	hook.Add("prone.CanEnter", "JuaSeat - Cancel Prone In Seats", function(ply)
		if IsValid(ply) and ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
			return false
		end
	end)
	hook.Add("prone.CanExit", "JuaSeat - Cancel Prone In Seats", function(ply)
		if IsValid(ply) and ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
			return false
		end
	end)
end