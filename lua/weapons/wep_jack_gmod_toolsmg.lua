SWEP.Base="gmod_tool"
SWEP.PrintName="Y'all Done Fucked Up"
SWEP.Primary.Automatic=true

-- Trace a line then send the result to a mode function
function SWEP:PrimaryAttack()
	local Trajectory=(self.Owner:GetAimVector()+VectorRand()*.1):GetNormalized()
	local tr=util.GetPlayerTrace(self.Owner,Trajectory)
	tr.mask=toolmask
	local trace=util.TraceLine(tr)
	if (!trace.Hit)then return end
	local tool=self:GetToolObject()
	if (!tool)then return end
	tool:CheckObjects()
	-- Does the server setting say it's ok?
	if (!tool:Allowed()) then return end
	-- Ask the gamemode if it's ok to do this
	local mode=self:GetMode()
	if(!gamemode.Call("CanTool",self.Owner,trace,mode,tool,1))then return end
	if(!tool:LeftClick(trace))then return end
	self:DoShootEffect(trace.HitPos,trace.HitNormal,trace.Entity,trace.PhysicsBone,IsFirstTimePredicted() )
	self:SetNextPrimaryFire(CurTime()+.02)
end

-- Think does stuff every frame
function SWEP:Think()
	-- SWEP:Think is called one more time clientside
	-- after holstering using Player:SelectWeapon in multiplayer
	if ( CLIENT && self.m_uHolsterFrame == FrameNumber() ) then return end
	local owner = self:GetOwner()
	if ( !owner:IsPlayer() ) then return end
	local curmode = owner:GetInfo( "gmod_toolmode" )
	self.Mode = curmode
	local tool = self:GetToolObject( curmode )
	if ( !tool ) then return end
	tool:CheckObjects()
	local lastmode = self.current_mode
	self.last_mode = lastmode
	self.current_mode = curmode
	-- Release ghost entities if we're not allowed to use this new mode?
	if ( !tool:Allowed() ) then
		if ( lastmode ) then
			local lastmode_obj = self:GetToolObject( lastmode )
			if ( lastmode_obj ) then
				lastmode_obj:ReleaseGhostEntity()
			end
		end
		return
	end
	if ( lastmode && lastmode != curmode ) then
		local lastmode_obj = self:GetToolObject( lastmode )
		if ( lastmode_obj ) then
			-- We want to release the ghost entity just in case
			lastmode_obj:Holster()
		end
	end
	--tool.LeftClickAutomatic
	self.Primary.Automatic = true -- MUAHAHAHAHA
	self.Secondary.Automatic = tool.RightClickAutomatic || false
	self.RequiresTraceHit = tool.RequiresTraceHit || true
	tool:Think()
end
