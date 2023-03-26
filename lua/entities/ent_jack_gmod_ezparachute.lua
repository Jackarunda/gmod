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

if SERVER then
	function ENT:Initialize()
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
		self.AttachBone = self.AttachBone or 0
		self.ChuteColor = self.ChuteColor or Color(83, 83, 55)
		self:SetState(STATE_FINE)
		self:SetNW2Float("ChuteProg", 0)
		local Owner = self:GetNW2Entity("Owner")
		timer.Simple(0.5, function() 
			if IsValid(self) and IsValid(Owner) and Owner:IsPlayer() and Owner:Alive() then 
				Owner:ViewPunch(Angle(10, 0, 0))
				Owner:EmitSound("JMod_BF2_Para_Deploy")
			end
		end)
		self:SetColor(self.ChuteColor or Color(83, 83, 55))
		--self:SetColor(self.ChuteColor or Color(255, 255, 255))
		self:SetOffset(self.MdlOffset)
	end

	function ENT:Think()
		local Time, State, Owner = CurTime(), self:GetState(), self:GetNW2Entity("Owner")
		local ChuteProg = self:GetNW2Float("ChuteProg", 0)

		if IsValid(Owner) then
			if not Owner:GetNW2Bool("EZparachuting", false) then
				self:Collapse()
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
			self:SetPos(Owner:GetPos())

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
						Phys = Owner:GetPhysicsObjectNum(self.AttachBone or 0)
					end
					if IsValid(Phys) then
						local Vel = Phys:GetVelocity()
						local NewVel = -Vel * Drag + WindFactor * Drag
						Phys:SetVelocity(Vel + NewVel * (ChuteProg^.5))
						if math.abs(Vel:Length()) <= 5 then
							Owner:SetNW2Bool("EZparachuting", false)
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
			self:SetNW2Float("ChuteProg", math.Clamp(ChuteProg - .03, 0, 2))
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
		self.LerpedYaw = Owner:GetVelocity():GetNormalized():Angle().y
	end

	function ENT:Draw()
		local FT = FrameTime()
		local Mat = Matrix()
		local ChuteProg = self:GetNW2Float("ChuteProg", 0)
		local ChuteZ, ChuteExpand = math.Clamp(ChuteProg, 0, 1), math.Clamp(ChuteProg - 1, 0.1, 1)
		local Siz = Vector(1 * ChuteExpand, 1 * ChuteExpand, 1 * ChuteZ)
		Mat:Scale(Siz)
		self:EnableMatrix("RenderMultiply", Mat)
		local Owner = self:GetNW2Entity("Owner")
		if IsValid(Owner) then
			local DirAng, Aim = Owner:GetVelocity():GetNormalized():Angle(), Owner:GetAngles()
			local FinalAng = Angle(DirAng.p, self.LerpedYaw, DirAng.r)
			local BPos, BIndex = Owner:LocalToWorld(Owner:OBBCenter()), Owner:LookupBone("ValveBiped.Bip01_Spine2")
			if BIndex then
				local matrix = Owner:GetBoneMatrix(BIndex)
				BPos = matrix:GetTranslation()
			end
			local Pos = BPos + (FinalAng:Forward() * math.Clamp(ChuteProg - 1, 0, 1) * self:GetOffset() or 0)
			FinalAng:RotateAroundAxis(FinalAng:Right(), 90)
			self:SetRenderAngles(FinalAng)
			self:SetRenderOrigin(Pos)
			self.LerpedYaw = math.ApproachAngle(self.LerpedYaw, Aim.y, FT * 120)
		end
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezparachute", "EZ parachute")
end
