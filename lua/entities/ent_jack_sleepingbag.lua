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

	function ENT:CreatePod()
		if(IsValid(self.Pod))then
			self.Pod:SetParent(nil)
			self.Pod:Fire("kill")
			self.Pod = nil
		end
		local Ang, Up, Right, Forward = self:GetAngles(), self:GetUp(), self:GetRight(), self:GetForward()

		self.Pod = ents.Create("prop_vehicle_prisoner_pod")
		self.Pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		self.Pod:SetPos(self:GetPos()+Up*12-Right*1+Forward*45)
		Ang:RotateAroundAxis(Right, 85)
		self.Pod:SetAngles(Ang)
		self.Pod:Spawn()
		self.Pod:Activate()
		self.Pod:SetParent(self)
		self.Pod:SetNoDraw(true)
		self.Pod:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self.Pod:Fire("lock")
		
	end
	
	function ENT:RollUp()
		self.State = STATE_ROLLED
		self.JModEZstorable = true
		if(IsValid(self.Pod))then
			self.Pod:SetParent(nil)
			self.Pod:Fire("kill")
			self.Pod = nil
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
		self:CreatePod()
	end

	function ENT:Use(ply)
		if not (ply:IsPlayer()) then return end
		local Alt = JMod.IsAltUsing(ply)
		if not IsValid(self.Pod) then self:CreatePod() end
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
					elseif not IsValid(self.Pod:GetDriver()) then -- Get inside if already yours
						self.Pod.EZvehicleEjectPos = self.Pod:WorldToLocal(ply:GetPos())
						self.Pod:Fire("EnterVehicle", "nil", 0, ply, ply)
						sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))
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
		if(self.Pod)then -- machines with seats
			if (IsValid(self.Pod)) then
				if IsValid(self.Pod:GetDriver()) then
					self.Pod:GetDriver():ExitVehicle()
				end
				self.Pod:Remove()
			end
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