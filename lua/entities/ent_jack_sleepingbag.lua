ENT.Type 			= "anim"
ENT.PrintName		= "Sleeping Bag"
ENT.Author			= "Basipek"
ENT.Category			= "JMod - EZ Misc."
ENT.Spawnable			= true
ENT.AdminSpawnable		= true

local STATE_ROLLED, STATE_UNROLLED = 0, 1
local MODEL_ROLLED, MODEL_UNROLLED = "","" -- My friend shall rip the ArmA models soon:tm:

if (CLIENT) then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
elseif (SERVER) then

	function ENT:Initialize()
		self.Entity:SetModel(MODEL_ROLLED)
		self.State=STATE_ROLLED
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid( SOLID_VPHYSICS )
		JMod.SetEZowner(self,nil)
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:Wake()
			phys:SetMass(35)
			self:SetColor(Color(100,100,100))
		end
		
		self:SetUseType(SIMPLE_USE)
		
		self.nextSpawnTime=0
		
		self.Pod = ents.Create("prop_vehicle_prisoner_pod")
		self.Pod:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		local Ang, Up, Right, Forward = self:GetAngles(), self:GetUp(), self:GetRight(), self:GetForward()
		self.Pod:SetPos(self:GetPos())
		Ang:RotateAroundAxis(Forward, -90)
		self.Pod:SetAngles(Ang)
		self.Pod:Spawn()
		self.Pod:Activate()
		self.Pod:SetParent(self)
		self.Pod:SetNoDraw(true)
		self.Pod:Fire("lock", "", 0)
	end
	
	function ENT:RollUp() 
		self.State = STATE_ROLLED
		JMod.SetEZowner(self,nil)
		if(IsValid(self.Pod:GetDriver()))then
			self.Pod:GetDriver():ExitVehicle() -- GET OUT OF BED
		end
		self.Pod:Fire("unlock", "", 0)
		self:SetModel(MODEL_ROLLED)
		self.Pod.EZvehicleEjectPos = nil
	end
	
	function ENT:UnRoll() 
		self.State = STATE_UNROLLED
		self.Pod:Fire("lock", "", 0) -- Just to make sure
		self:SetModel(MODEL_UNROLLED)
	end

	function ENT:Use(ply)
		local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)
		if (ply:IsPlayer() and Alt) then
			if (self.State==STATE_UNROLLED) then
				self:RollUp()
			elseif (self.State==STATE_ROLLED) then
				self.UnRoll()
			end
		elseif ply:IsPlayer() then
			if (self.State==STATE_UNROLLED) then
				if (self.EZowner and IsValid(self.EZowner)) then
					if (ply~=self.EZowner) then
						JMod.Hint(ply,"sleeping bag someone else")
					else
						if not IsValid(self.Pod:GetDriver()) then -- Get inside if already yours
							self.Pod.EZvehicleEjectPos = self.Pod:WorldToLocal(activator:GetPos())
							activator:EnterVehicle(self.Pod)
						end
					end
				else
					if (IsValid(ply.JModSpawnPointEntity)) then JMod.SetEZowner(ply.JModSpawnPointEntity,nil);ply.JModSpawnPointEntity:SetColor(Color(100,100,100)) end
					JMod.Hint(ply,"sleeping bag set spawn")
					JMod.SetEZowner(self,ply)
					ply.JModSpawnPointEntity=self
					local Col=ply:GetPlayerColor()
					self:SetColor(Color(255*Col.x,255*Col.y,255*Col.z))
				end
			elseif (self.State==STATE_ROLLED) then
				JMod.Hint(ply,"sleeping bag unroll first")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if((dmginfo:IsDamageType(DMG_BURN))or(dmginfo:IsDamageType(DMG_DIRECT)))then
			if(math.random(1,3)==2)then self:Remove() end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if((data.Speed>80)and(data.DeltaTime>0.2))then
			self.Entity:EmitSound("Body.ImpactSoft")
		end
	end

	function ENT:OnRemove()
		if(IsValid(self.EZowner))then self.EZowner.JModSpawnPointEntity=nil end
		if(self.Pod)then -- machines with seats
		  if(IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
			end
		end
	end
end