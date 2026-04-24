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

		self.EZvehicleEjectPos = self:WorldToLocal(ply:GetPos())
		self.Sleeper = ply
		ply:SetParent(self)
		ply:SetLocalPos(self.SleeperPos)
		ply:SetLocalAngles(self.SleeperAngles)
		ply:SetMoveType(MOVETYPE_NOCLIP)
		drive.PlayerStartDriving(ply, self, "drive_jmod_sleepingbag")
		local OurAngles = self:GetAngles()
		OurAngles:RotateAroundAxis(OurAngles:Up(), 180)
		OurAngles.r = 0
		ply:SetEyeAngles(OurAngles)

		sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))

		self:NextThink(CurTime() + 0.1)
	end

	function ENT:StopSleepingDrive(ply)
		if not(IsValid(ply)) then return end
		
		if ply:IsDrivingEntity() then
			drive.PlayerStopDriving(ply)
		end
		ply:SetParent(nil)
		local OurAngles = self:GetAngles()
		ply:SetEyeAngles(Angle(OurAngles.p, OurAngles.y, 0))
		ply:SetMoveType(MOVETYPE_WALK)

		local hullMins = Vector(-16, -16, 0)
		local hullMaxs = Vector(16, 16, 72)
		local entryWorld = (self.EZvehicleEjectPos and self:LocalToWorld(self.EZvehicleEjectPos)) or self:GetPos()

		local candidates = {
			entryWorld,
			self:GetPos() + self:GetUp() * 40,
			self:GetPos() + self:GetForward() * 40 + self:GetUp() * 8,
			self:GetPos() - self:GetForward() * 40 + self:GetUp() * 8,
			self:GetPos() + self:GetRight() * 40 + self:GetUp() * 8,
			self:GetPos() - self:GetRight() * 40 + self:GetUp() * 8,
		}

		local safePos
		for _, cand in ipairs(candidates) do
			local tr = util.TraceHull({
				start = cand,
				endpos = cand,
				mins = hullMins,
				maxs = hullMaxs,
				filter = { self, ply }
			})
			if not tr.Hit and not tr.StartSolid then
				local groundTr = util.TraceLine({
					start = cand,
					endpos = cand - Vector(0, 0, 64),
					filter = { self, ply }
				})
				if groundTr.Hit then
					safePos = cand
					break
				end
			end
		end

		ply:SetPos(safePos or entryWorld)
		self.Sleeper = nil
		sound.Play("snd_jack_clothunequip.ogg", self:GetPos(), 65, math.random(90, 110))
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