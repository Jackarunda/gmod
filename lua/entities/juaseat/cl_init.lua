include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
end
function ENT:DrawTranslucent()
	self:Draw()
end

hook.Add("PrePlayerDraw", "JuaSeat - Prevent Normal Player Draw", function(ply)
	if ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
		local veh = ply:GetVehicle()
		local angoffset = veh:LocalToWorldAngles(veh:GetSeatAng())
		ply:SetPos(veh:GetWorldSeatPos())
		ply:SetRenderAngles(angoffset)
		ply:SetAngles(angoffset)
		ply:SetupBones()
		if IsValid(ply:GetActiveWeapon()) then
			ply:GetActiveWeapon():SetAngles(angoffset)
			ply:GetActiveWeapon():SetupBones()
		end
		ply:InvalidateBoneCache()
	end
	if ply:InVehicle() and ply:GetVehicle():IsLuaVehicle() then
		ply:DrawShadow(false)
		if IsValid(ply:GetActiveWeapon()) then
			ply:GetActiveWeapon():DrawShadow(false)
		end
		ply.LuS_Reshadowed = true
		elseif ply.LuS_Reshadowed then
		ply:DrawShadow(true)
		if IsValid(ply:GetActiveWeapon()) then
			ply:GetActiveWeapon():DrawShadow(true)
		end
	end

end)

hook.Add("StartCommand", "JuaSeat - Grab Player Eye Pos", function(ply, cmd)
	if ( not ply:InVehicle()  ) and not cmd:KeyDown(IN_USE) then
		ply.LuS_EyeStart = ply:EyePos()
		ply.LuS_EyeStartAng = ply:EyeAngles()
	end
end)

function ENT:Think()
	local ply = self:GetSeatedPlayer()
	self.LastPlayer = self.LastPlayer or ply
	if IsValid(ply) then
		ply.LuaVehicle = self
		self.LastPlayer = ply
		self.SitTimer = self.SitTimer or CurTime() + self:GetSitTime()
		else
		self.SitTimer = nil
		self.EyeStart = nil
	end
	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	local ply = self:GetSeatedPlayer()
	if IsValid(ply) then
		ply:SetMaterial("")
		if IsValid(ply:GetActiveWeapon()) then
			ply:GetActiveWeapon():SetMaterial("")
		end
	end
end

local tr = {}
local force = GetConVar("luaseat_force_camsolid")

hook.Add("CalcVehicleView", "JuaSeat - CalcVehicleView", function(veh, ply, view)
	if not IsValid(ply.CamController) then --Wiremod cam controllers should take priority
		if veh:IsLuaVehicle() and ply:GetViewEntity() == ply then
			local pos = view.origin
		
			local ang = view.angles
			veh.SitTimer = veh.SitTimer or CurTime() + veh:GetSitTime()
			veh.EyeStart = ply.LuS_EyeStart
			veh.EyeStartAng = ply.LuS_EyeStartAng
			if CurTime() > veh.SitTimer then
				pos = veh:GetVehicleViewPosition()
				else
				local mult = (CurTime() - veh.SitTimer)/veh:GetSitTime()
				pos = LerpVector(1 + mult, ply.LuS_EyeStart, veh:GetVehicleViewPosition())
			end
			
			if veh:GetThirdPersonMode() then
				if veh:GetTPViewLock() == 2 then
					ang = veh:LocalToWorldAngles(veh:GetSeatAng())
				end
				else
				if veh:GetFPViewLock() == 2 then
					ang = veh:LocalToWorldAngles(veh:GetSeatAng())
				end
			end
			if veh:GetThirdPersonMode() or ply:GetViewEntity() ~= ply then
				view.drawviewer = true
				tr.HitPos = veh:GetVehicleViewPosition() - (ply:GetAimVector() * veh:GetCameraDistance())
				if veh:GetCamSolid() or force:GetBool() then
					util.TraceHull({
						start=pos,
						endpos = tr.HitPos,
						mins = Vector(-5,-5,-5),
						maxs = Vector(5,5,5),
						filter={veh, ply},
						mask=MASK_SOLID_BRUSHONLY,
						output = tr
					})
				end
				pos = tr.HitPos
			end
			if CurTime() < veh.SitTimer then
				local mult = (CurTime() - veh.SitTimer)/veh:GetSitTime()
				ang = LerpAngle(1 + mult, ply.LuS_EyeStartAng, veh:LocalToWorldAngles(veh:GetSeatAng()))
			end
			view.origin = pos
			view.angles = ang
			return view
		end
	end
end)

hook.Add("CalcViewModelView", "JuaSeat - ViewmodelView", function(wep, entity, oldpos, oldang, pos, ang)
	local veh = LocalPlayer():GetVehicle()
	if IsValid(veh) and veh:IsLuaVehicle() and LocalPlayer():GetViewEntity() == LocalPlayer() then
		local pos
		local ang
		veh.SitTimer = veh.SitTimer or CurTime() + veh:GetSitTime()
		if CurTime() > veh.SitTimer then
			pos = veh:GetVehicleViewPosition()
			else
			local mult = (CurTime() - veh.SitTimer)/veh:GetSitTime()
			pos = LerpVector(1 + mult, LocalPlayer().LuS_EyeStart, veh:GetVehicleViewPosition())
		end
		if CurTime() < veh.SitTimer then
			local mult = (CurTime() - veh.SitTimer)/veh:GetSitTime()
			if veh.EyeStartAng then
				ang = LerpAngle(1 + mult, LocalPlayer().LuS_EyeStartAng, veh:LocalToWorldAngles(veh:GetSeatAng()))
			end
		end
		return pos, ang
	end
end)

hook.Add( "HUDShouldDraw", "JuaSeat - Third Person Scroll Hud", function(elem)
	if LocalPlayer().InVehicle and LocalPlayer():InVehicle() and LocalPlayer():GetVehicle():IsLuaVehicle() then
		if ( elem == "CHudWeaponSelection" ) and LocalPlayer():GetVehicle():GetThirdPersonMode() then
			return false
		end
	end
end)