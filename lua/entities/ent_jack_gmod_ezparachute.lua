-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Parachute"
ENT.Spawnable = false 
ENT.AdminSpawnable = false

local STATE_COLLAPSING, STATE_FINE = -1, 0

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Int", 1, "Offset")
end

--hook.Remove("UpdateAnimation", "JMOD_PARACHUTE_ANIM")
--[[hook.Add("UpdateAnimation", "JMOD_PARACHUTE_ANIM", function(ply, vel, maxSped)
	if IsValid(ply) and ply:GetNW2Bool("EZparachuting", false) and IsFirstTimePredicted() then
		--ply:SetPoseParameter("aim_pitch", math.sin(CurTime()) * 90)
		--ply:SetPoseParameter("aim_yaw", math.sin(CurTime()) * 90)
		--ply:SetPoseParameter("body_yaw", math.sin(CurTime()) * 90)
		--ply:SetPoseParameter("body_pitch", math.sin(CurTime()) * 90)
		--jprint(ply:GetPoseParameter("body_pitch"))
		if SERVER then
			for i = 0, ply:GetNumPoseParameters() - 1 do
				local sPose = ply:GetPoseParameterName(i)
				ply:SetPoseParameter(sPose, math.sin(CurTime()) * 90)
				--jprint(sPose, ply:GetPoseParameter(sPose))
			end
		else
			for i = 0, ply:GetNumPoseParameters() - 1 do
				local flMin, flMax = ply:GetPoseParameterRange(i)
				local sPose = ply:GetPoseParameterName(i)
				ply:SetPoseParameter(sPose, math.Remap(math.sin(CurTime()) * 90, 0, 1, flMin, flMax))
			end
		end
		if CLIENT then 
			ply:InvalidateBoneCache()
			ply:SetupBones() 
		end
		--return false
	end
end)]]--
--hook.Remove("CalcMainActivity", "JMOD_PARACHUTE_ANIM")
--[[hook.Add("CalcMainActivity", "JMOD_PARACHUTE_ANIM", function(ply, vel) 
	if ply:GetNW2Bool("EZparachuting", false) then
		return ACT_MP_STAND_IDLE, 24
	end
end)]]--

if SERVER then
	function ENT:Initialize()
		
		if self.ParachuteName and JMod.ArmorTable[self.ParachuteName] then
			local ParachuteType = JMod.ArmorTable[self.ParachuteName]
			self.ParachuteMdl = ParachuteType.eff.parachute.mdl
			self.MdlOffset = ParachuteType.eff.parachute.offset
			self.Drag = ParachuteType.eff.parachute.drag
			self.ChuteColor = Color(ParachuteType.clr.r, ParachuteType.clr.g, ParachuteType.clr.b) 
		end

		self:SetModel(self.ParachuteMdl or "models/jessev92/bf2/parachute.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_FLY)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		--self:DrawShadow(true)
		local Phys = self:GetPhysicsObject()

		if IsValid(Phys) then
			Phys:Wake()
			Phys:SetMass(100)
			Phys:EnableDrag(false)
			Phys:SetMaterial("cloth")
		end
		self.SndLoop = CreateSound(self, "JMod_BF2_Para_Idle")
		self.SndLoop:ChangeVolume(0.5)
		timer.Simple(1, function()
			if IsValid(self) then
				self.SndLoop:Play()
			end
		end)
		self.Durability = 100
		self.MdlOffset = self.MdlOffset or 15
		self.Drag = self.Drag or 5
		self:SetNW2Int("AttachBone", self.AttachBone or 0)
		self.ChuteColor = self.ChuteColor or Color(83, 83, 55)

		self:SetColor(self.ChuteColor)
		self:SetOffset(self.MdlOffset)
		self:SetState(STATE_FINE)
		self:SetNW2Float("ChuteProg", 0)
		local Owner = self:GetNW2Entity("Owner")
		timer.Simple(0.5, function() 
			if IsValid(self) and IsValid(Owner) and Owner:IsPlayer() and Owner:Alive() then 
				Owner:ViewPunch(Angle(10, 0, 0))
				Owner:EmitSound("JMod_BF2_Para_Deploy")
			end
		end)
		Owner.EZparachute = self
		self.NextCollapseTime = CurTime()
	end

	function ENT:Think()
		local Time, State, Owner = CurTime(), self:GetState(), self:GetNW2Entity("Owner")
		local ChuteProg = self:GetNW2Float("ChuteProg", 0)

		if IsValid(Owner) then
			if not Owner:GetNW2Bool("EZparachuting", false) then
				self:Collapse() -- We need to check this first and foremost
			end
			------ Parachute Pos and Angles ------
			local DirAng, Aim = Owner:GetVelocity():GetNormalized():Angle(), Owner:GetAngles()
			local AimDirAng = Angle(DirAng.p, (math.abs(DirAng.r) > 1 and DirAng.r) or Aim.y, DirAng.r)
			local BPos = Owner:LocalToWorld(Owner:OBBCenter())
			local BIndex = Owner:LookupBone("ValveBiped.Bip01_Spine2")
			if BIndex then
				local matrix = Owner:GetBoneMatrix(BIndex)
				BPos = matrix:GetTranslation()
			end
			local Pos = BPos + (AimDirAng:Forward() * math.Clamp(ChuteProg - 1, 0, 1) * self.MdlOffset or 0)
			self:SetPos(Pos)

			local Drag = math.Clamp(self.Drag * 0.01, 0, 1)

			if State == STATE_FINE then
				------ Parachute simluation ------
				local WindFactor = JMod.Wind * math.Rand(1, 1.5)
				if Owner:IsPlayer() then
					local Vel = Owner:GetVelocity()
					local NewVel = -Vel * Drag + WindFactor * Drag * 0.5
					if Owner:KeyDown(IN_FORWARD) then
						local AimDir = Owner:GetForward()
						AimDir.z = 0
						NewVel = NewVel + AimDir * 100 * Drag
					end
					Owner:SetVelocity(NewVel * (ChuteProg^.5))
				else
					local Phys = Owner:GetPhysicsObject()
					if Owner:IsRagdoll() then
						Phys = Owner:GetPhysicsObjectNum(self:GetNW2Int("AttachBone", 0))
					end
					if IsValid(Phys) then
						local Vel = Phys:GetVelocity()
						local NewVel = -Vel * Drag + WindFactor * Drag
						Phys:AddVelocity(NewVel * (ChuteProg^.5))
						--Phys:AddAngleVelocity(Phys:GetAngleVelocity())
						JMod.AeroDrag(Owner, self:GetUp(), 0.5, 100)
						if math.abs(Vel:Length()) <= 5 then
							if self.NextCollapseTime <= Time then
								self:Collapse()
							end
						end
					end
				end
				if Owner:WaterLevel() >= 2 then
					Owner:SetNW2Bool("EZparachuting", false)
				end
				self:SetNW2Float("ChuteProg", math.Clamp(ChuteProg + .03, 0, 2))
			end
		else
			self:Collapse()
		end

		if State == STATE_COLLAPSING then
			self:SetNW2Float("ChuteProg", math.Clamp(ChuteProg - .05, 0, 2))
			if ChuteProg <= 0 then
				self:Remove()
			end 
		end

		self:NextThink(Time + 0.01)
		return true
	end

	function ENT:Collapse()
		if self:GetState() == STATE_COLLAPSING then return end
		self:SetState(STATE_COLLAPSING)
		self.SndLoop:Stop()
	end

	function ENT:OnTakeDamage(dmg)
		if dmg:IsDamageType(DMG_RADIATION) then return end
		self.Durability = math.Clamp(self.Durability - (dmg:GetDamage() - (200/dmg:GetDamage())^2), 0, 100)
		if self.Durability <= 0 then
			self:Remove()
		end
	end

	function ENT:OnRemove()
		local Owner = self:GetNW2Entity("Owner")
		if IsValid(Owner) and Owner:GetNW2Bool("EZparachuting", false) then
			Owner:SetNW2Bool("EZparachuting", false)
		end
		if self.SndLoop then
			self.SndLoop:Stop()
		end
	end

	function ENT:GravGunPickupAllowed(ply)
		return false
	end

elseif CLIENT then
	function ENT:Initialize()
		local Owner = self:GetNW2Entity("Owner")
		if IsValid(Owner) then
			self.LerpedYaw = Owner:GetVelocity():GetNormalized():Angle().y
			self.LerpedPitch = Owner:GetVelocity():GetNormalized():Angle().p
		end
	end

	function ENT:Think()
		local FT = FrameTime()
		local ChuteProg = self:GetNW2Float("ChuteProg", 0)
		local Owner = self:GetNW2Entity("Owner")
		self.LerpedYaw = self.LerpedYaw or 0
		self.LerpedPitch = self.LerpedPitch or 0
		if IsValid(Owner) then
			local Dir = Owner:GetVelocity():GetNormalized()
			local DirAng = Dir:Angle()
			local FinalAng = Angle(self.LerpedPitch, self.LerpedYaw, DirAng.r)
			local BPos, BIndex = Owner:LocalToWorld(Owner:OBBCenter()), Owner:LookupBone("ValveBiped.Bip01_Spine2")
			local AttachBone = self:GetNW2Int("AttachBone", 0)
			if BIndex or (AttachBone and AttachBone > 0) then
				BPos = Owner:GetBonePosition(BIndex or AttachBone)
			end
			local Pos = BPos + (FinalAng:Forward() * math.Clamp(ChuteProg - 1, 0, 1) * self:GetOffset() or 0)
			FinalAng:RotateAroundAxis(FinalAng:Right(), 90)
			self:SetRenderAngles(FinalAng)
			self:SetRenderOrigin(Pos)
			if math.abs(DirAng.p - self.LerpedPitch) > 2 then
				self.LerpedPitch = math.ApproachAngle(self.LerpedPitch, DirAng.p, FT * 120)
			end
			if Owner:IsPlayer() then
				self.LerpedYaw = math.ApproachAngle(self.LerpedYaw, Owner:GetAngles().y, FT * 120)
			elseif math.abs(DirAng.p - self.LerpedPitch) > 2 then
				self.LerpedYaw = math.ApproachAngle(self.LerpedYaw, DirAng.y, FT * 120)
			end
		end
	end

	function ENT:Draw()
		local ChuteProg = self:GetNW2Float("ChuteProg", 0)
		local ChuteZ, ChuteExpand = math.Clamp(ChuteProg, 0, 1), math.Clamp(ChuteProg - 1, 0.1, 1)
		local Siz = Vector(1 * ChuteExpand, 1 * ChuteExpand, 1 * ChuteZ)
		local Mat = Matrix()
		Mat:Scale(Siz)
		self:EnableMatrix("RenderMultiply", Mat)
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezparachute", "EZ parachute")
end
