AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Sleeping Bag"
ENT.Author = "Basipek, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.EZrespawnPoint = true
ENT.Mass = 35
ENT.JModEZstorable = true

local STATE_ROLLED, STATE_UNROLLED = 0, 1
local MODEL_ROLLED, MODEL_UNROLLED = "models/jmod/props/sleeping_bag_rolled.mdl","models/jmod/props/sleeping_bag.mdl"
local ClothSounds = {"snds_jack_gmod/equip1.ogg", "snds_jack_gmod/equip2.ogg", "snds_jack_gmod/equip3.ogg", "snds_jack_gmod/equip4.ogg", "snds_jack_gmod/equip5.ogg"}

if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
elseif (SERVER) then

	function ENT:Initialize()
		self.State = STATE_ROLLED
		self:SetModel(MODEL_ROLLED)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid( SOLID_VPHYSICS )
		JMod.SetEZowner(self, nil)
		local phys = self:GetPhysicsObject()
		if phys:IsValid()then
			phys:Wake()
			phys:SetMass(35)
			self:SetColor(Color(100, 100, 100))
		end
		
		self:SetUseType(SIMPLE_USE)
		
		self.nextSpawnTime = 0
		--self:CreatePod()
	end

	function ENT:CreatePod()
		if(IsValid(self.Pod))then
			self.Pod:SetParent(nil)
			self.Pod:Fire("kill")
			self.Pod = nil
		end
		self.Pod = ents.Create("prop_vehicle_prisoner_pod")
		self.Pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		local Ang, Up, Right, Forward = self:GetAngles(), self:GetUp(), self:GetRight(), self:GetForward()
		self.Pod:SetPos(self:GetPos()+Up*12-Right*1+Forward*45)
		--Ang:RotateAroundAxis(Up, 0)
		--Ang:RotateAroundAxis(Forward, 0)
		Ang:RotateAroundAxis(Right, 85)
		self.Pod:SetAngles(Ang)
		self.Pod:Spawn()
		self.Pod:Activate()
		self.Pod:SetParent(self)
		self.Pod:SetNoDraw(true)
		self.Pod:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self.Pod:Fire("lock")
		--self.Pod.IsJackyPod = true
		--self.Pod.EZvehicleEjectPos = 
		--self.Pod:SetNotSolid(true)
		--self.Pod:Fire("lock", "", 0)
		--self.Pod:SetThirdPersonMode(false)
		--self.Pod:SetCameraDistance(0)
	end
	
	function ENT:RollUp()
		self.State = STATE_ROLLED
		--JMod.SetEZowner(self, nil)
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
		self:SetUseType(SIMPLE_USE)

		sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(self.Mass)
		end
		self:SetPos(self:GetPos() + Vector(0, 0, 20))
	end

	function ENT:UnRoll()
		self.State = STATE_UNROLLED
		self:SetModel(MODEL_UNROLLED)
		
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)    
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetMass(self.Mass)
		end
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
		local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)
		if not IsValid(self.Pod) then self:CreatePod() end
		if (Alt) then
			if (self.State == STATE_UNROLLED) then
				self:RollUp()
			elseif (self.State == STATE_ROLLED) then
				self:UnRoll()
			end
		else
			if (self.State == STATE_UNROLLED) then
				if IsValid(self.EZowner) and IsValid(ply.JModSpawnPointEntity) and (ply.JModSpawnPointEntity == self) then
					if (ply ~= self.EZowner) then
						JMod.Hint(ply,"sleeping bag someone else")
					else
						if not IsValid(self.Pod:GetDriver()) then -- Get inside if already yours
							self.Pod.EZvehicleEjectPos = self.Pod:WorldToLocal(ply:GetPos())
							self.Pod:Fire("EnterVehicle", "nil", 0, ply, ply)
							sound.Play("snd_jack_clothequip.ogg", self:GetPos(), 65, math.random(90, 110))
						end
					end
				else
					if (IsValid(ply.JModSpawnPointEntity)) then 
						JMod.SetEZowner(ply.JModSpawnPointEntity, nil) 
						ply.JModSpawnPointEntity:SetColor(Color(100,100,100))
					end
					JMod.Hint(ply, "sleeping bag set spawn")
					JMod.SetEZowner(self, ply)
					ply.JModSpawnPointEntity = self
					local Col = ply:GetPlayerColor()
					self:SetColor(Color(255*Col.x,255*Col.y,255*Col.z))
					--JMod.Colorify(self)
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
		if(IsValid(self.EZowner))then self.EZowner.JModSpawnPointEntity=nil end
		if(self.Pod)then -- machines with seats
		  if(IsValid(self.Pod) and IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
				self.Pod:Remove()
			end
		end
	end
end