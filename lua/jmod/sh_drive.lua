AddCSLuaFile()

DEFINE_BASECLASS("drive_base")

drive.Register("drive_jmod_sleepingbag",
{
	Init = function(self)
		if SERVER then
			self.Player:SetViewEntity(self.Player)
			self.Player:SetMoveType(MOVETYPE_NONE)
			self.Player:SetParent(self.Entity)
			self.Player:SetLocalPos(self.Entity.SleeperPos)
			self.Player:SetLocalAngles(self.Entity.SleeperAngles)
			self.Player:DrawWorldModel(false)
		end
	end,

	SetupControls = function(self, cmd)
		cmd:SetForwardMove(0)
		cmd:SetSideMove(0)
		cmd:SetUpMove(0)
	end,

	StartMove = function(self, mv, cmd)
		self.Player:SetObserverMode(OBS_MODE_IN_EYE)

		if mv:KeyPressed(IN_USE) then

			self:Stop()
		end
	end,

	Move = function(self, mv)
		mv:SetOrigin(self.Entity:LocalToWorld(self.Entity.SleeperPos))
		mv:SetAngles(self.Entity:LocalToWorldAngles(self.Entity.SleeperAngles))
		mv:SetVelocity(vector_origin)
	end,

	FinishMove = function(self, mv)
		self.Player:SetPos(mv:GetOrigin())
		self.Player:SetAngles(mv:GetAngles())
		self.Player:SetLocalVelocity(vector_origin)
	end,

	CalcView = function(self, view)
		local localViewEntity = GetViewEntity()
		if (localViewEntity == self.Player) or (localViewEntity == self.Entity) then
			view.origin = self.Entity:LocalToWorld(self.Entity.SleeperViewPos)
			view.angles = self.Player:EyeAngles()
			view.drawviewer = true
		end

		return view
	end,

	Stop = function(self)
		BaseClass.Stop(self)
		if type(self.Entity.StopSleepingDrive) == "function" then
			self.Entity:StopSleepingDrive(self.Player, true)
		end
	end

}, "drive_base")

hook.Add("PlayerDriveAnimate", "JMOD_SLEEPINGBAG", function(ply)
	local driveMode = util.NetworkStringToID("drive_jmod_sleepingbag")
	if ply:GetDrivingMode() ~= driveMode then return end
	local sleepingBag = ply:GetDrivingEntity()

	ply:ResetSequenceInfo()
	ply:SetPlaybackRate(0)
	ply:ResetSequence(ply:SelectWeightedSequence(sleepingBag.SleeperActivity))
	ply:SetRenderAngles(sleepingBag:LocalToWorldAngles(sleepingBag.SleeperAngles))
	
	return true
end)