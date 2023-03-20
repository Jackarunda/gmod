-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Parachute"
ENT.Spawnable = false 
ENT.AdminSpawnable = false

local STATE_COLLAPSING, STATE_FINE = -1, 0

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.ParachuteMdl)
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
		self.SndLoop = CreateSound(self, "V92_ZP_BF2_Idle")
		self.SndLoop:ChangeVolume(0.5)
		timer.Simple(1, function()
			if IsValid(self) then
				self.SndLoop:Play()
			end
		end)
		self.Durability = 100
		self:SetState(STATE_FINE)
		self:SetNW2Float("ChuteProg", 0)
		local Owner = self.Owner
		timer.Simple(0.5, function() 
			if IsValid(self) and IsValid(Owner) and Owner:IsPlayer() and Owner:Alive() then 
				Owner:ViewPunch(Angle(10, 0, 0))
				Owner:EmitSound("V92_ZP_BF2_Deploy")
			end 
		end)
		self:SetColor(self.ChuteColor or Color(83, 83, 55))
		--self:SetColor(self.ChuteColor or Color(255, 255, 255))
	end

	function ENT:Think()
		local Time, State, Owner = CurTime(), self:GetState(), self.Owner
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
			AimDirAng:RotateAroundAxis(AimDirAng:Right(), 90)
			self:SetPos(Pos)
			self:SetAngles(AimDirAng)

			local Drag = math.Clamp(self.Drag * 0.01, 0, 1)

			if State == STATE_FINE then
				------ Parachute simluation ------
				if Owner:IsPlayer() then
					local Vel = Owner:GetVelocity()
					local NewVel = -Vel * Drag + JMod.Wind * math.Rand(1, 1.5) * Drag * 0.5
					--jprint(Drag, NewVel)
					--jprint(JMod.Wind)
					if Owner:KeyDown(IN_FORWARD) then
						local AimDir = Owner:GetForward()
						AimDir.z = 0
						NewVel = NewVel + AimDir * 100 * Drag
					end
					Owner:SetVelocity(NewVel * (ChuteProg^.5))
				else
					local Phys = Owner:GetPhysicsObject()
					if Owner:IsRagdoll() then
						Phys = Owner:GetPhysicsObjectNum(1)
					end
					if IsValid(Phys) then
						local Vel = Phys:GetVelocity()
						local NewVel = -Vel * Drag * 2 + JMod.Wind * math.Rand(1, 1.5) * Drag
						Phys:SetVelocity(Vel + NewVel * (ChuteProg^.5))
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
		if IsValid(self.Owner) and self.Owner:GetNW2Bool("EZparachuting", false) then
			self.Owner:SetNW2Bool("EZparachuting", false)
		end
		if self.SndLoop then
			self.SndLoop:Stop()
		end
	end

	function ENT:GravGunPickupAllowed(ply)
		return false
	end

elseif CLIENT then
	function ENT:Draw()
		local Mat = Matrix()
		local ChuteProg = self:GetNW2Float("ChuteProg", 0)
		local ChuteZ, ChuteExpand = math.Clamp(ChuteProg, 0, 1), math.Clamp(ChuteProg - 1, 0.1, 1)
		local Siz = Vector(1 * ChuteExpand, 1 * ChuteExpand, 1 * ChuteZ)
		Mat:Scale(Siz)
		self:EnableMatrix("RenderMultiply", Mat)
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezparachute", "EZ parachute")
end