-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Machine"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Machines"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.NoSitAllowed=true
----
ENT.Model="models/props_lab/reciever01d.mdl"
ENT.Mass = 150
ENT.IsJackyEZmachine = true
----
ENT.EZconsumes=nil--[[{
	JMod.EZ_RESOURCE_TYPES.BASICPARTS, 
	JMod.EZ_RESOURCE_TYPES.POWER
}--]]
ENT.FlexFuels = nil -- "Flex Fuels" are other resource types that the machine will load as electricity
--- These stats do not change when the machine is upgraded
ENT.StaticPerfSpecs={ 
	MaxElectricity=100,
	MaxDurability=100,
	Armor=1
}
--- These stats change when the machine is upgraded
ENT.DynamicPerfSpecs={ 
	--
}
ENT.DynamicPerfSpecExp=1
ENT.EZstorageSpace = 0
ENT.NextRefillTime = 0

---- Shared Functions ----
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Float",0,"Electricity")
	if(self.CustomSetupDataTables)then
		self:CustomSetupDataTables()
	end
end

--[[
function ENT:GravGunPickupAllowed(ply)
	return true
end
--]]

function ENT:InitPerfSpecs()
	local Grade = self:GetGrade()
	local NetworkTable = {}
	if (self.StaticPerfSpecs) then
		for specName, value in pairs(self.StaticPerfSpecs)do 
			self[specName] = value 
			NetworkTable[specName] = NewValue
		end
	end
	if (self.DynamicPerfSpecs) then
		for specName, value in pairs(self.DynamicPerfSpecs)do
			if(type(value)~="table")then
				if not JMod.EZ_GRADE_BUFFS[Grade] then return end
				local NewValue = value * JMod.EZ_GRADE_BUFFS[Grade] ^ (self.DynamicPerfSpecExp)
				if (NewValue > 2) then
					self[specName] = math.ceil(NewValue)
					NetworkTable[specName] = NewValue
				else
					self[specName] = NewValue
					NetworkTable[specName] = NewValue
				end
			end
		end
	end
	if SERVER then
		net.Start("JMod_MachineSync")
		net.WriteEntity(self)
		net.WriteTable(NetworkTable)
		net.Broadcast()
	end
end

function ENT:Upgrade(level)
	if not(level)then level=self:GetGrade()+1 end
	if(level>5)then return end
	self:SetGrade(level)
	self:InitPerfSpecs()
	self.UpgradeProgress={}
end

if(SERVER)then
	function ENT:SpawnFunction(ply,tr,classname)
		local SpawnPos=tr.HitPos+tr.HitNormal*(self.SpawnHeight or 60)
		local ent=ents.Create(classname)
		ent:SetAngles((ent.JModPreferredCarryAngles and ent.JModPreferredCarryAngles) or Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent,ply)
		if JMod.Config.Machines.SpawnMachinesFull then
			ent.SpawnFull = true
		end
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		JMod.Hint(ply, classname)
		return ent
	end

	function ENT:Initialize()
		self.StaticPerfSpecs.BaseClass=nil
		self.DynamicPerfSpecs.BaseClass=nil
		self.EZconsumes = self.EZconsumes or {
			JMod.EZ_RESOURCE_TYPES.BASICPARTS, 
			JMod.EZ_RESOURCE_TYPES.POWER
		}
		--
		self:SetModel(self.Model)
		if(self.Mat)then
			self:SetMaterial(self.Mat)
		end
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local Phys = self:GetPhysicsObject()
		timer.Simple(0, function()
			if Phys:IsValid() then
				Phys:Wake()
				if self.Mass then
					Phys:SetMass(self.Mass)
				end
				if self.EZbuoyancy then
					Phys:SetBuoyancyRatio(self.EZbuoyancy)
				end
			end
		end)
		self:SetState(JMod.EZ_STATE_OFF)
		if self:GetGrade() == 0 then
			self:SetGrade(JMod.EZ_GRADE_BASIC)
		end
		self:InitPerfSpecs()
		self.DamageModifierTable = JMod.DefualtArmorTable
		self.BackupRecipe = self.BackupRecipe or {[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = 100}

		--=== Put things that shoulf be overrideable by machines above this line. ====-
		if(self.CustomInit)then self:CustomInit() end
		--=== Apply changes and state things that shouldn't be overrideable below.====-

		---
		if self.SetupWire and istable(WireLib) then
			self:SetupWire()
		end
		
		self.Durability = self.MaxDurability * JMod.Config.Machines.DurabilityMult
		self:SetNW2Float("EZdurability", self.Durability)
		--print(self:GetNW2Float("EZdurability", -1))
		if self.SetElectricity and self.MaxElectricity then
			if self.SpawnFull then
				self:SetElectricity(self.MaxElectricity)
			else
				self:SetElectricity(0)
			end
		end
		---
		if self.EZownerID then JMod.SetEZowner(self, player.GetBySteamID64(self.EZownerID)) end
		if(JMod.GetEZowner(self))then JMod.Colorify(self) end
		---
		if(self.EZupgradable)then
			self.UpgradeProgress = {}
			self.UpgradeCosts = JMod.CalculateUpgradeCosts((JMod.Config.Craftables[self.PrintName] and JMod.Config.Craftables[self.PrintName].craftingReqs) or (self.BackupRecipe and self.BackupRecipe))
		end

		self:UpdateWireOutputs()
	end

	function ENT:SetupWire()
		if not(istable(WireLib)) then return end
		local WireInputs = {}
		local WireInputDesc = {}
		if self.TurnOn and self.TurnOff then
			table.insert(WireInputs, "Toggle [NORMAL]")
			table.insert(WireInputDesc, "Greater than 1 toggles machine on and off")
			table.insert(WireInputs, "On-Off [NORMAL]")
			table.insert(WireInputDesc, "1 turns on, 0 turns off")
		end
		if self.ProduceResource then
			table.insert(WireInputs, "Produce [NORMAL]")
			table.insert(WireInputDesc, "Produces resource")
		end
		self.Inputs = WireLib.CreateInputs(self, WireInputs, WireInputDesc)
		--
		local WireOutputs = {"State [NORMAL]", "Grade [NORMAL]"}
		local WireOutputDesc = {"The state of the machine \n-1 is broken \n0 is off \n1 is on", "The machine grade"}
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then typ = "Durability" end
			local ResourceName = string.Replace(typ, " ", "")
			local ResourceDesc = "Amount of "..ResourceName.." left"
			--
			local OutResourceName = string.gsub(ResourceName, "^%l", string.upper).." [NORMAL]"
			if not(istable(self.FlexFuels) and table.HasValue(self.FlexFuels, typ)) then
				table.insert(WireOutputs, OutResourceName)
				table.insert(WireOutputDesc, ResourceDesc)
			end
		end
		if self.GetProgress then
			table.insert(WireOutputs, "Progress [NORMAL]")
			table.insert(WireOutputDesc,  "Machine's progress")
		end
		if self.FlexFuels then
			table.insert(WireOutputs, "FlexFuel [NORMAL]")
			table.insert(WireOutputDesc,  "Machine's flex fuel left")
		end
		self.Outputs = WireLib.CreateOutputs(self, WireOutputs, WireOutputDesc)
	end

	function ENT:UpdateWireOutputs()
		if not istable(WireLib) then return end
		WireLib.TriggerOutput(self, "State", self:GetState())
		WireLib.TriggerOutput(self, "Grade", self:GetGrade())
		if self.GetProgress then
			WireLib.TriggerOutput(self, "Progress", self:GetProgress())
		end
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then
				WireLib.TriggerOutput(self, "Durability", self.Durability)
			else
				if istable(self.FlexFuels) and table.HasValue(self.FlexFuels, typ) then
					WireLib.TriggerOutput(self, "FlexFuel", self:GetElectricity())
				elseif self.GetAmmoType and self.AmmoRefundTable and (self.AmmoRefundTable[self:GetAmmoType()].spawnType == typ) then
					WireLib.TriggerOutput(self, "Ammo", self:GetAmmo())
				else
					local MethodName = JMod.EZ_RESOURCE_TYPE_METHODS[typ]
					if MethodName then
						local ResourceGetMethod = self["Get"..MethodName]
						if ResourceGetMethod then
							local ResourceName = string.Replace(typ, " ", "")
							WireLib.TriggerOutput(self, string.gsub(ResourceName, "^%l", string.upper), ResourceGetMethod(self))
						end
					end
				end
			end
		end
	end

	function ENT:TriggerInput(iname, value)
		local State, Owner = self:GetState(), JMod.GetEZowner(self)
		if State < 0 then return end
		if iname == "On-Off" then
			if value == 1 then
				self:TurnOn(Owner)
			elseif value == 0 then
				self:TurnOff(Owner)
			end
		elseif iname == "Toggle" then
			if value > 0 then
				if State == 0 then
					self:TurnOn(Owner)
				elseif State > 0 then
					self:TurnOff(Owner)
				end
			end
		elseif iname == "Produce" then
			if value > 0 then
				self:ProduceResource(Owner)
			end
		end
	end

	function ENT:UpdateDepositKey(checkPos)
		self.DepositKey = JMod.GetDepositAtPos(self, checkPos or (self:GetPos() - Vector(0, 0, self.SpawnHeight or 60)))
		local DepositInfo = JMod.NaturalResourceTable[self.DepositKey]
		if DepositInfo and self.SetResourceType then self:SetResourceType(DepositInfo.typ) end
		return self.DepositKey
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed>80) and (data.DeltaTime>0.2) then
			self:EmitSound("Metal_Box.ImpactSoft")
			local Ent = data.HitEntity
			local Held = false
			if self:IsPlayerHolding() or (IsValid(Ent) and Ent:IsPlayerHolding()) then Held = true end
			if (data.Speed > 150) then
				self:EmitSound("Metal_Box.ImpactHard")
				if (data.Speed > 500) then
					local World = game.GetWorld()
					local CollisionDir = data.OurOldVelocity - data.TheirOldVelocity
					local TheirForce = (.5 * data.HitObject:GetMass() * ((CollisionDir:Length()/16)*0.3048)^2)
					if Ent == World then
						TheirForce = (.5 * physobj:GetMass() * ((CollisionDir:Length()/16)*0.3048)^2)
					end
					local ForceThreshold = physobj:GetMass() * (self.EZanchorage or 1000)
					local PhysDamage = TheirForce/(physobj:GetMass())

					--jprint(PhysDamage)
					--jprint("Their Speed: ", math.Round(CollisionDir:Length()), "Resultant force: "..tostring(math.Round(TheirForce - ForceThreshold)))
					
					if (TheirForce >= ForceThreshold) and (Ent ~= World) then
						JMod.EZinstallMachine(self, false)
					end
					if PhysDamage >= 1 and not(Held) then
						local CrushDamage = DamageInfo()
						CrushDamage:SetDamage(math.floor(PhysDamage))
						CrushDamage:SetDamageType(DMG_CRUSH)
						CrushDamage:SetDamageForce(data.TheirOldVelocity / 1000)
						CrushDamage:SetDamagePosition(data.HitPos)
						CrushDamage:SetAttacker(Ent or World)
						local Inflictor = JMod.GetEZowner(Ent)
						CrushDamage:SetInflictor(Inflictor or Ent)
						self:TakeDamageInfo(CrushDamage)
						self:EmitSound("Metal_Box.Break")
						JMod.DamageSpark(self)

						--[[if data.HitEntity:IsVehicle() then
							local CrashDamage = DamageInfo()
							--jprint(Dmg)
							CrashDamage:SetDamage(Dmg * 2)
							CrashDamage:SetDamageType(DMG_CRUSH)
							CrashDamage:SetDamageForce(data.TheirOldVelocity * -0.001)
							CrashDamage:SetDamagePosition(data.HitPos)
							data.HitEntity:TakeDamageInfo(CrashDamage)
						end]]--
					end
				end
			end
		end
	end

	function ENT:ModConnections(dude)
		local Connections = {}
		for _, cable in pairs(constraint.FindConstraints(self, "JModResourceCable")) do
			if (cable.Ent1 == self) and JMod.ConnectionValid(self, cable.Ent2) then
				table.insert(Connections, {DisplayName = cable.Ent2.PrintName, Index = cable.Ent2:EntIndex()})
			elseif JMod.ConnectionValid(self, cable.Ent1) then
				table.insert(Connections, {DisplayName = cable.Ent1.PrintName, Index = cable.Ent1:EntIndex()})
			else
				JMod.RemoveResourceConnection(self, cable.Ent1)
			end
		end

		if not(IsValid(dude) and dude:IsPlayer()) then return end
		net.Start("JMod_ModifyConnections")
			net.WriteEntity(self)
			net.WriteTable(Connections)
		net.Send(dude)
	end

	function ENT:ConsumeElectricity(amt)
		if not(self.GetElectricity)then return end
		amt = (amt or .2)/(self.ElectricalEfficiency or 1)
		local NewAmt = math.Clamp(self:GetElectricity() - amt, 0.0, self.MaxElectricity)
		self:SetElectricity(NewAmt)
		if(NewAmt <= 0 and self:GetState() > 0)then self:TurnOff() end
	end

	function ENT:DetermineDamageMultiplier(dmg)
		local Mult = 1 / (self.Armor or 1)
		if self.DamageModifierTable then
			for typ, mul in pairs(self.DamageModifierTable)do
				if(dmg:IsDamageType(typ))then Mult = Mult * mul break end
			end
		end
		if(self.CustomDetermineDmgMult)then Mult = Mult * self:CustomDetermineDmgMult(dmg) end
		return Mult
	end

	function ENT:OnTakeDamage(dmginfo)
		if not(IsValid(self))then return end
		self:TakePhysicsDamage(dmginfo)
		--
		local DmgMult = self:DetermineDamageMultiplier(dmginfo)
		if(DmgMult <= .01)then return end
		local Damage = dmginfo:GetDamage() * DmgMult
		--jprint(Damage)
		self.Durability = self.Durability - math.Round(Damage, 2)
		self:SetNW2Float("EZdurability", self.Durability)

		if(self.Durability <= 0)then self:Break(dmginfo) end
		if(self.Durability <= (self.MaxDurability * -2))then self:Destroy(dmginfo) end
	end

	function ENT:Break(dmginfo)
		if(self:GetState() == JMod.EZ_STATE_BROKEN)then return end
		self:SetState(JMod.EZ_STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))
		for i = 1, 20 do JMod.DamageSpark(self) end

		local StartPoint, ToPoint, Spread, Scale, UpSpeed = self:LocalToWorld(self:OBBCenter()), nil, 2, 1, 10
		local Force, GibNum = dmginfo:GetDamageForce(), math.min(JMod.Config.Machines.SupplyEffectMult * self:GetPhysicsObject():GetMass()/2000, 20)

		if JMod.Config.Craftables[self.PrintName] then
			for k, v in pairs(JMod.Config.Craftables[self.PrintName].craftingReqs) do
				JMod.ResourceEffect(k, StartPoint, ToPoint, GibNum * (v / 5000), Spread, Scale, UpSpeed)
			end
		else
			JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.BASICPARTS, StartPoint, ToPoint, GibNum, Spread, Scale, UpSpeed)
		end

		if(self.Pod)then -- machines with seats
			if(IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
			end
			self.Pod:Fire("lock","",0)
		end

		constraint.RemoveConstraints(self, "JModResourceCable")

		if(self.OnBreak)then self:OnBreak() end
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("snd_jack_turretbreak.ogg",70,math.random(80,120))
		for i = 1, 20 do JMod.DamageSpark(self) end

		local StartPoint, ToPoint, Spread, Scale, UpSpeed = self:LocalToWorld(self:OBBCenter()), nil, 2, 1, 10
		local Force, GibNum = dmginfo:GetDamageForce(), math.min(JMod.Config.Machines.SupplyEffectMult * self:GetPhysicsObject():GetMass()/1000, 30)
		if JMod.Config.Craftables[self.PrintName] then
			for k, v in pairs(JMod.Config.Craftables[self.PrintName].craftingReqs) do
				JMod.ResourceEffect(k, StartPoint, ToPoint, GibNum * (v / 800), Spread, Scale, UpSpeed)
			end
		else
			JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.BASICPARTS, StartPoint, ToPoint, GibNum, Spread, Scale, UpSpeed)
		end

		if(self.Pod)then -- machines with seats
			if(IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
			end
		end
		if self.ProduceResource then self:ProduceResource() end
		if self.OnDestroy then self:OnDestroy(dmginfo) end
		self:SetNoDraw(true)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		SafeRemoveEntityDelayed(self, 2)
	end

	function ENT:SFX(str,absPath)
		if(absPath)then
			sound.Play(str,self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,math.random(90,110))
		else
			sound.Play("snds_jack_gmod/"..str..".ogg",self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,100)
		end
	end

	function ENT:Whine(serious)
		local Time=CurTime()
		if(self.NextWhine<Time)then
			self.NextWhine=Time+4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.ogg",70,100)
			self:ConsumeElectricity(.05)
		end
	end

	function ENT:OnRemove()
	end

	function ENT:TryLoadResource(typ, amt)
		if amt <= 0 then return 0 end

		local Time = CurTime()
		if ((self.NextRefillTime or 0) > Time) or (typ == "generic") then return 0 end
		
		for _, v in pairs(self.EZconsumes)do
			if typ == v then
				local Accepted = 0
				if typ == JMod.EZ_RESOURCE_TYPES.POWER then
					local Powa = self:GetElectricity()
					local Missing = self.MaxElectricity - Powa
					if Missing <= 0 then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetElectricity(Powa + Accepted)
					self:EmitSound("snd_jack_turretbatteryload.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES then
					local Supps = self:GetSupplies()
					local Missing = self.MaxSupplies - Supps
					if Missing <= 0 then return 0 end
					--if(Missing<self.MaxSupplies*.1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetSupplies(Supps + Accepted)
					self:EmitSound("snd_jack_turretbatteryload.ogg", 65, math.random(90, 110)) -- TODO: new sound here
				elseif typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then
					local Missing = self.MaxDurability - self.Durability
					if Missing <= 0 then return 0 end
					Accepted = math.min(Missing / 3, amt)
					local Broken = false
					if self.Durability <= 0 then Broken = true end
					self.Durability = math.min(self.Durability + (Accepted * 3), self.MaxDurability)
					if(self.Durability >= self.MaxDurability)then self:RemoveAllDecals() end
					self:EmitSound("snd_jack_turretrepair.ogg", 65, math.random(90, 110))
					if(self.Durability > 0)then
						if(self:GetState() == JMod.EZ_STATE_BROKEN)then self:SetState(JMod.EZ_STATE_OFF) end
						if Broken and self.OnRepair then self:OnRepair() end
					end
					self:SetNW2Float("EZdurability", self.Durability)
				elseif typ == JMod.EZ_RESOURCE_TYPES.GAS then
					local Fool = self:GetGas()
					local Missing = self.MaxGas - Fool
					if(Missing <= 0)then return 0 end
					--if(Missing < self.MaxGas * .1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetGas(Fool + Accepted)
					self:EmitSound("snds_jack_gmod/gas_load.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.AMMO then
					local Ammo = self:GetAmmo()
					local Missing = self.MaxAmmo - Ammo
					if(Missing <= 1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetAmmo(Ammo + Accepted)
					self:EmitSound("snd_jack_turretammoload.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.MUNITIONS then
					local Ammo = self:GetAmmo()
					local Missing = self.MaxAmmo - Ammo
					if(Missing <= 1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetAmmo(Ammo + Accepted)
					self:EmitSound("snd_jack_turretammoload.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.COOLANT then
					local Kewl = self:GetCoolant()
					local Missing = self.MaxCoolant - Kewl
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetCoolant(Kewl+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.WATER then
					local Aqua = self:GetWater()
					local Missing = self.MaxWater - Aqua
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetWater(Aqua+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.CHEMICALS then
					local Chem = self:GetChemicals()
					local Missing = self.MaxChemicals - Chem
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetChemicals(Chem+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.OIL then
					local Oil = self:GetOil()
					local Missing = self.MaxOil - Oil
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetOil(Oil+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.URANIUM then
					local Uran = self:GetUranium()
					local Missing = self.MaxUranium - Uran
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetUranium(Uran+Accepted)
					self:EmitSound("Boulder.ImpactSoft", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.FUEL then
					if (self.FlexFuels and table.HasValue(self.FlexFuels, typ)) then
						local Powa = self:GetElectricity()
						local Missing = self.MaxElectricity - Powa
						if(Missing <= 0)then return 0 end
						local PotentialPower = math.min(Missing, amt * JMod.EnergyEconomyParameters.BasePowerConversions[typ])
						self:SetElectricity(Powa + PotentialPower)
						Accepted = PotentialPower / JMod.EnergyEconomyParameters.BasePowerConversions[typ]
					else
						local Fuel = self:GetFuel()
						local Missing = self.MaxFuel - Fuel
						if(Missing < 1)then return 0 end
						Accepted = math.min(Missing, amt)
						self:SetFuel(Fuel + Accepted)
					end
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.COAL then
					if (self.FlexFuels and table.HasValue(self.FlexFuels, typ)) then
						local Powa = self:GetElectricity()
						local Missing = self.MaxElectricity - Powa
						if(Missing <= 0)then return 0 end
						local PotentialPower = math.min(Missing, amt * JMod.EnergyEconomyParameters.BasePowerConversions[typ])
						self:SetElectricity(Powa + PotentialPower)
						Accepted = PotentialPower / JMod.EnergyEconomyParameters.BasePowerConversions[typ]
					else
						local Coal = self:GetCoal()
						local Missing = self.MaxCoal - Coal
						if(Missing < 1)then return 0 end
						Accepted = math.min(Missing, amt)
						self:SetCoal(Coal + Accepted)
					end
					self:EmitSound("Boulder.ImpactSoft", 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.WOOD then
					if (self.FlexFuels and table.HasValue(self.FlexFuels, typ)) then
						local Powa = self:GetElectricity()
						local Missing = self.MaxElectricity - Powa
						if(Missing <= 0)then return 0 end
						local PotentialPower = math.min(Missing, amt * JMod.EnergyEconomyParameters.BasePowerConversions[typ])
						self:SetElectricity(Powa + PotentialPower)
						Accepted = PotentialPower / JMod.EnergyEconomyParameters.BasePowerConversions[typ]
					else
						local Wood = self:GetWood()
						local Missing = self.MaxWood - Wood
						if(Missing < 1)then return 0 end
						Accepted = math.min(Missing, amt)
						self:SetWood(Wood + Accepted)
					end
					self:EmitSound("Wood.ImpactSoft", 65, math.random(90, 110))
				elseif string.find(typ, " ore") or (typ == JMod.EZ_RESOURCE_TYPES.SAND) then
					if(self.GetOreType and (self:GetOreType() == "generic" or typ == self:GetOreType())) then
						self:SetOreType(typ)
						local COre = self:GetOre()
						local Missing = self.MaxOre - COre
						if(Missing <= 0)then return 0 end
						Accepted = math.min(Missing, amt)
						self:SetOre(COre + Accepted)
						self:EmitSound("Boulder.ImpactSoft", 65, math.random(90, 110))
					end
				end
				if self.ResourceLoaded then self:ResourceLoaded(typ, Accepted) end
				self.NextRefillTime = Time + 1

				return math.ceil(Accepted)
			end
		end

		return 0
	end

	--[[function ENT:OnEntityCopyTableFinish(tbl)
		if self.EZconnections then
			for k, v in pairs(self.EZconnections) do
				if JMod.ConnectionValid(self, Entity(k)) then
					tbl.EZconnections[k] = NULL -- It's gonna be null on the other end anyway
				end
			end
			--tbl.EZconnections = table.FullCopy(self.EZconnections)
			print("Copying EZ connections", self)
			--PrintTable(self.EZconnections)
			PrintTable(tbl.EZconnections)
		end
	end--]]

	-- Entity save/dupe functionality
	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		if not(self:GetPersistent()) and (self.AdminOnly) and (not(JMod.IsAdmin(ply)) and not(self:GetPersistent())) then
			SafeRemoveEntity(self)

			return
		end

		if IsValid(ply) then
			JMod.SetEZowner(self, ply, true)
		elseif self.EZownerID then
			JMod.SetEZowner(self, player.GetBySteamID64(self.EZownerID), true)
		end

		if self.NextUseTime then
			self.NextUseTime = Time + 1
		end

		if self.SoundLoop then
			self.SoundLoop:Stop()
			self.SoundLoop = nil
		end

		if not(JMod.IsAdmin(ply)) and not(self:GetPersistent()) then
			if self.EZconsumes and not(JMod.Config.Machines.SpawnMachinesFull) then
				for _, typ in ipairs(self.EZconsumes) do
					if istable(self.FlexFuels) and table.HasValue(self.FlexFuels, typ) then
						self:SetElectricity(0)
					else
						if JMod.EZ_RESOURCE_TYPE_METHODS[typ] then
							local ResourceSetMethod = self["Set"..JMod.EZ_RESOURCE_TYPE_METHODS[typ]]
							if ResourceSetMethod then
								ResourceSetMethod(self, 0)
							end
						end
					end
				end
			end
			if self.SetProgress then
				self:SetProgress(0)
			end
			if self.EZupgradable then
				self:SetGrade(JMod.EZ_GRADE_BASIC)
				self:InitPerfSpecs()
			end
		end

		timer.Simple(0, function()
			self:ModConnections()
		end)

		if self.EZconnections then
			self.EZconnections = nil -- Down with the old system
		end
		
		if self.OnPostEntityPaste then
			self:OnPostEntityPaste(ply, self, createdEntities)
		end
	end

elseif(CLIENT)then
	net.Receive("JMod_MachineSync", function(len, ply)
		local Ent = net.ReadEntity()
		local NewSpecs = net.ReadTable()
		if IsValid(Ent) then
			if Ent.OnMachineSync then
				Ent:OnMachineSync(NewSpecs)
			else
				for specName, value in pairs(NewSpecs) do
					Ent[specName] = value
				end
			end
		end
	end)

	function ENT:Initialize()
		self:SetModel(self.Model)
		if self.ClientOnly then 
			self:SetNextClientThink(CurTime() + 1)

			return true
		end
		self.StaticPerfSpecs.BaseClass=nil
		self.DynamicPerfSpecs.BaseClass=nil
		if(self.CustomInit)then self:CustomInit() end
		self:InitPerfSpecs()
	end

	function ENT:OnRemove()
		if self.Mdl or self.CSmodels then
			JMod.SafeRemoveCSModel(self, IsValid(self.Mdl) and self.Mdl, self.CSmodels)
		end
	end
end
