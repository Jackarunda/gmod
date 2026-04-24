AddCSLuaFile()

DEFINE_BASECLASS("drive_base")

drive.Register("drive_jmod_sleepingbag",
{
	Init = function(self)
		if SERVER then
			self.Player:SetViewEntity(self.Player)
		end
	end,

	SetupControls = function(self, cmd)
		cmd:SetForwardMove(0)
		cmd:SetSideMove(0)
		cmd:SetUpMove(0)
	end,

	StartMove = function(self, mv, cmd)
		if cmd:KeyDown(IN_USE) then
			mv:AddKey(IN_USE)
		end
	end,

	Move = function(self, mv)
		if mv:KeyPressed(IN_USE) then
			if self.Entity.StopSleepingDrive then 
				self.Entity:StopSleepingDrive(self.Player)
			else
				self:Stop()
			end

			return
		end

		mv:SetOrigin(self.Entity.SleeperPos)
		mv:SetAngles(self.Entity.SleeperAngles)
		mv:SetVelocity(vector_origin)
	end,

	FinishMove = function(self, mv)
		self.Player:SetLocalPos(mv:GetOrigin())
		self.Player:SetLocalAngles(mv:GetAngles())
	end,

	CalcView = function(self, view)
		local localViewEntity = GetViewEntity()
		if (localViewEntity == self.Player) or (localViewEntity == self.Entity) then
			view.origin = self.Entity:LocalToWorld(self.Entity.SleeperViewPos)
			view.angles = self.Player:EyeAngles()
			view.drawviewer = true -- Doesn't draw view model if true
			self.Player:SetNoDraw(true) 
		else
			self.Player:SetNoDraw(false)
		end

		return view
	end,

	Stop = function(self)
		BaseClass.Stop(self)
		self.Player:SetNoDraw(false)
	end

}, "drive_base")

hook.Add("PlayerDriveAnimate", "JMOD_SLEEPINGBAG", function(ply)
	local driveMode = util.NetworkStringToID("drive_jmod_sleepingbag")
	if ply:GetDrivingMode() ~= driveMode then return end
	local sleepingBag = ply:GetDrivingEntity()

	ply:ResetSequence(ply:SelectWeightedSequence(sleepingBag.SleeperActivity))
	ply:ResetSequenceInfo()
	ply:SetPlaybackRate(0)
	ply:SetRenderAngles(sleepingBag:LocalToWorldAngles(sleepingBag.SleeperAngles))
	
	return true
end)