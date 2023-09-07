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
		self.jackSleepingBagOwner=nil
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:Wake()
			phys:SetMass(35)
			self:SetColor(Color(100,100,100))
		end
		
		self:SetUseType(SIMPLE_USE)
		
		self.nextSpawnTime=0
	end

	function ENT:Use(a)
		local Alt = a:KeyDown(JMod.Config.General.AltFunctionKey)
		if (a:IsPlayer() and Alt) then
			--Turn into rolled bedroll
		elseif a:IsPlayer() then 
			if (self.jackSleepingBagOwner and IsValid(self.jackSleepingBagOwner)) then
				if (a~=self.jackSleepingBagOwner) then
					a:PrintMessage(HUD_PRINTCENTER,"This bed is already claimed!")
				else
					a:PrintMessage(HUD_PRINTCENTER,"This bed is already yours!")
				end
			else
				if (IsValid(a.jackSleepingBag)) then a.jackSleepingBag.jackSleepingBagOwner=nil;a.jackSleepingBag:SetColor(Color(100,100,100)) end
				a:PrintMessage(HUD_PRINTCENTER,"Bed has been claimed!")
				self.jackSleepingBagOwner=a
				a.jackSleepingBag=self
				local Col=a:GetPlayerColor()
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
		if(IsValid(self.jackSleepingBagOwner))then self.jackSleepingBagOwner.jackSleepingBag=nil end
	end

	local function jackSpawnHook(p)
		if((p.jackSleepingBag)and(IsValid(p.jackSleepingBag)))then
			if(p.jackSleepingBag.nextSpawnTime<CurTime())then
				p.jackSleepingBag.nextSpawnTime=CurTime()+60
				p:SetPos(p.jackSleepingBag:GetPos())
				local effectdata=EffectData()
				effectdata:SetEntity(p)
				util.Effect("propspawn",effectdata)
			else
				p:PrintMessage(HUD_PRINTCENTER,"You must wait 60 seconds before spawning at your bed again.")
			end
		end
	end
	hook.Add("PlayerSpawn","jackSpawnHook",jackSpawnHook)
end