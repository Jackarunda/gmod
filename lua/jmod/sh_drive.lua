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
		--self.Player:SetMoveType(MOVETYPE_NOCLIP)
	end,

	Move = function(self, mv)
		mv:SetOrigin(self.Entity:LocalToWorld(self.Entity.SleeperPos))
		local OurAngles = self.Entity:GetAngles()
		OurAngles:RotateAroundAxis(OurAngles:Up(), 90)
		mv:SetAngles(OurAngles)
		mv:SetVelocity(vector_origin)

		if mv:KeyPressed(IN_USE) then
			if self.Entity.StopSleepingDrive then 
				self.Entity:StopSleepingDrive(self.Player)
			else
				self:Stop()
			end
		end
	end,

	FinishMove = function(self, mv)
		self.Player:SetPos(mv:GetOrigin())
		self.Player:SetLocalAngles(mv:GetAngles())
	end,

	CalcView = function(self, view)
		local localViewEntity = GetViewEntity()
		view.drawviewmodel = false
		if (localViewEntity == self.Player) or (localViewEntity == self.Entity) then
			view.origin = self.Entity:LocalToWorld(self.Entity.SleeperViewPos)
			view.angles = self.Player:EyeAngles()
			--self.Player:SetNoDraw(true)
		else
			--self.Player:SetNoDraw(false)
		end
	end

}, "drive_base")

hook.Add("PlayerDriveAnimate", "JMOD_SLEEPINGBAG", function(ply)
	local driveMode = util.NetworkStringToID("drive_jmod_sleepingbag")
	if ply:GetDrivingMode() ~= driveMode then return end

	ply:SetPlaybackRate(0.1)
	ply:ResetSequence(ply:SelectWeightedSequence(ACT_HL2MP_IDLE))
	local sleepingBag = ply:GetDrivingEntity()
	ply:SetRenderAngles(sleepingBag:LocalToWorldAngles(sleepingBag.SleeperAngles))
	
	return true
end)