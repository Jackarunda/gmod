ENT.Type 			= "anim"
ENT.PrintName		= "Sleeping Bag"
ENT.Author			= "Basipek"
ENT.Category			= "JMod - Misc"
ENT.Spawnable			= true
ENT.AdminSpawnable		= true


if (CLIENT) then
	function ENT:Draw()
		self.Entity:DrawModel()
	end
elseif (SERVER) then

	function ENT:Initialize()
		self.Entity:SetModel("models/props_equipment/sleeping_bag1.mdl")
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
	end

	function ENT:Use(ply)
		local Alt = ply:KeyDown(JMod.Config.General.AltFunctionKey)
		if (ply:IsPlayer() and Alt) then
			--Turn into rolled bedroll
		elseif ply:IsPlayer() then
			
			if (self.EZowner and IsValid(self.EZowner)) then
				if (ply~=self.EZowner) then
					JMod.Hint(ply,"sleeping bag someone else")
				else
					JMod.Hint(ply,"sleeping bag already you")
				end
			else
				if (IsValid(ply.JModSpawnPointEntity)) then ply.JModSpawnPointEntity.EZowner=nil;ply.JModSpawnPointEntity:SetColor(Color(100,100,100)) end
				JMod.Hint(ply,"sleeping bag set spawn")
				JMod.SetEZowner(self,ply)
				ply.JModSpawnPointEntity=self
				local Col=ply:GetPlayerColor()
				self:SetColor(Color(255*Col.x,255*Col.y,255*Col.z))
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
	end
end