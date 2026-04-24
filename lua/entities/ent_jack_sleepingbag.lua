AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Sleeping Bag"
ENT.Author = "Basipek, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.EZrespawnPoint = true
ENT.Mass = 35
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, -90, 90)
ENT.EZcolorable = true
ENT.SleeperPos = Vector(5, 0, 10)
ENT.SleeperViewPos = Vector(-30, 0, 25)
ENT.SleeperAngles = Angle(0, 190, 0)
ENT.SleeperActivity = ACT_HL2MP_ZOMBIE_SLUMP_IDLE
ENT.SleeperEjectPos = Vector(0, 0, 0)
ENT.SleeperDriveMode = "drive_jmod_sleepingbag"

local STATE_ROLLED, STATE_UNROLLED = 0, 1
local MODEL_ROLLED, MODEL_UNROLLED = "models/jmod/props/sleeping_bag_rolled.mdl","models/jmod/props/sleeping_bag.mdl"
local ClothSounds = {"snds_jack_gmod/equip1.ogg", "snds_jack_gmod/equip2.ogg", "snds_jack_gmod/equip3.ogg", "snds_jack_gmod/equip4.ogg", "snds_jack_gmod/equip5.ogg"}

if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetPos(SpawnPos)
		ent:SetAngles(ent.JModPreferredCarryAngles)
		ent:Spawn()
		ent:Activate()
		--JMod.SetEZowner(ent, ply)
		-- local effectdata=EffectData()
		-- effectdata:SetEntity(ent)
		-- util.Effect("propspawn",effectdata)
		return ent
	end

	function ENT:Initialize()
		self.State = self.State or STATE_ROLLED
		if (self.State == STATE_ROLLED)then
			self:RollUp()
		else
			self:Unroll()
		end

		self:SetUseType(SIMPLE_USE)

		local Phys = self:GetPhysicsObject()
		timer.Simple(0, function()
			if Phys:IsValid()then
				Phys:Wake()
				Phys:SetMass(self.Mass)
			end
		end)
		
		self.nextSpawnTime = 0
		self:SetColor(Color(100, 100, 100))
	end

	function ENT:CanPlayerRespawnAt(ply)
		if not IsValid(ply) then return false end
		if (self.State == STATE_UNROLLED) and (not IsValid(self.Sleeper)) then
			if self.nextSpawnTime > CurTime() then
				JMod.Hint(ply,"sleeping bag wait")

				return false
			end
			
			return true
		end

		return false
	end

	function ENT:PlayerRespawnAt(ply)
		if not IsValid(ply) then return end

		ply:SetPos(self:GetPos())
		ply:SetAngles(self:GetAngles())
		self:StartSleepingDrive(ply)

		net.Start("JMod_VisionBlur")
			net.WriteFloat(5)
			net.WriteFloat(2000)
			net.WriteBit(true)
		net.Send(ply)
	end

	function ENT:RollUp()
		self.State = STATE_ROLLED
		self.JModEZstorable = true
		if IsValid(self.Sleeper) then
			self:StopSleepingDrive(self.Sleeper)
		end

		self:SetModel(MODEL_ROLLED)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)    
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)

		sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))
		
		local Phys = self:GetPhysicsObject()
		timer.Simple(0, function()
			if Phys:IsValid()then
				Phys:Wake()
				Phys:SetMass(self.Mass)
			end
		end)
		self:SetPos(self:GetPos() + Vector(0, 0, 20))
		self:SetAngles(self:GetAngles() + Angle(0, -90, 0))
	end

	function ENT:UnRoll()
		self.State = STATE_UNROLLED
		self.JModEZstorable = false
		self:SetModel(MODEL_UNROLLED)
		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)    
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		
		local Phys = self:GetPhysicsObject()
		timer.Simple(0, function()
			if Phys:IsValid()then
				Phys:Wake()
				Phys:SetMass(self.Mass)
			end
		end)

		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Tr = util.TraceLine({
			start = SelfPos + Vector(0, 0, 50),
			endpos = SelfPos - Vector(0, 0, 100),
			filter = { self, self.EZowner }
		})
		if (Tr.Hit) then
			self:SetPos(Tr.HitPos + Tr.HitNormal)
			local Ang = Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			self:SetAngles(Ang)
		end
		sound.Play("snd_jack_clothunequip.ogg", self:GetPos(), 65, math.random(90, 110))
	end

	function ENT:StartSleepingDrive(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		if self.State ~= STATE_UNROLLED then return end
		if IsValid(self.Sleeper) then return end
		if ply:IsDrivingEntity() then return end

		self.SleeperEjectPos = self:WorldToLocal(ply:GetPos())
		self.Sleeper = ply
		drive.PlayerStartDriving(ply, self, self.SleeperDriveMode)
		local OurAngles = self:GetAngles()
		OurAngles:RotateAroundAxis(OurAngles:Up(), 180)
		OurAngles.r = 0
		ply:SetEyeAngles(OurAngles)

		sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))

		self:NextThink(CurTime() + 0.1)
	end

	function ENT:StopSleepingDrive(ply, driveCalled)
		if not(IsValid(ply)) then return end
		if ply ~= self.Sleeper then return end

		local OurAngles = self:GetAngles()
		ply:SetEyeAngles(Angle(OurAngles.p, OurAngles.y, 0))
		ply:SetNoDraw(false)
		ply:DrawWorldModel(true)
		ply:SetMoveType(MOVETYPE_WALK)
		ply:SetParent(nil)

		local hullMins = Vector(-16, -16, 0)
		local hullMaxs = Vector(16, 16, 72)
		local entryWorld = (self.SleeperEjectPos and self:LocalToWorld(self.SleeperEjectPos)) or self:GetPos()

		local safePos = self:GetPos()
		local tr = util.TraceHull({
			start = entryWorld,
			endpos = entryWorld + Vector(0, 0, 1),
			mins = hullMins,
			maxs = hullMaxs,
			filter = { self, ply }
		})
		if not tr.Hit and not tr.StartSolid then
			safePos = entryWorld
		end
	
		timer.Simple(0, function() -- Unparenting apparently sets the player position somewhere else
			if not IsValid(ply) then return end
			ply:SetPos(safePos)
			if IsValid(self) then
				ply:SetVelocity(self:GetVelocity())
			end
		end)
		
		self.Sleeper = nil
		self.SleeperEjectPos = nil
		sound.Play("snd_jack_clothunequip.ogg", self:GetPos(), 65, math.random(90, 110))

		if not driveCalled then
			drive.PlayerStopDriving(ply)
		end
	end

	function ENT:Think()
		if IsValid(self.Sleeper) then
			if self.Sleeper:GetDrivingEntity() ~= self then
				self:StopSleepingDrive(self.Sleeper)
			else
				self:NextThink(CurTime() + 0.25)
				return true
			end
		elseif self.Sleeper ~= nil then
			self.Sleeper = nil
		end
	end

	function ENT:Use(ply)
		if not (ply:IsPlayer()) then return end
		local Alt = JMod.IsAltUsing(ply)
		if (Alt) then
			if (self.State == STATE_UNROLLED) then
				if IsValid(self.EZowner) and self.EZowner ~= ply then
					JMod.Hint(ply,"sleeping bag someone else")
				else
					self:RollUp()
				end
			elseif (self.State == STATE_ROLLED) then
				self:UnRoll()
			end
		else
			if (self.State == STATE_UNROLLED) then
				if not IsValid(self.EZowner) then
					if IsValid(ply.JModSpawnPointEntity) and (ply.JModSpawnPointEntity ~= self) then 
						JMod.SetEZowner(ply.JModSpawnPointEntity, nil) 
						ply.JModSpawnPointEntity:SetColor(Color(100,100,100))
						JMod.Hint(ply, "sleeping bag set spawn")
					end
					JMod.SetEZowner(self, ply, true)
					ply.JModSpawnPointEntity = self
				else
					if (ply ~= self.EZowner) then
						JMod.Hint(ply,"sleeping bag someone else")
					elseif not IsValid(self.Sleeper) and not ply:IsDrivingEntity() then
						self:StartSleepingDrive(ply)
					end
				end
			elseif (self.State == STATE_ROLLED) then
				JMod.Hint(ply, "sleeping bag unroll first")
				ply:PickupObject(self)
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if((dmginfo:IsDamageType(DMG_BURN)) or (dmginfo:IsDamageType(DMG_DIRECT)))then
			if(math.random(1, 3) == 2)then self:Remove() end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if((data.Speed > 50) and (data.DeltaTime > 0.2))then
			self:EmitSound("Flesh.ImpactSoft")
		end
	end

	function ENT:OnRemove()
		if IsValid(self.Sleeper) then
			self:StopSleepingDrive(self.Sleeper)
		end
	end

	function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
		if IsValid(ply) then
			JMod.SetEZowner(self, ply, true)
		elseif self.EZownerID then
			JMod.SetEZowner(self, player.GetBySteamID64(self.EZownerID), true)
		end

		if self.State == STATE_ROLLED then
			self:RollUp()
		else
			self:UnRoll()
		end
	end

elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end