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
ENT.Mass=150
----
ENT.PropModels={
	"models/props_lab/reciever01d.mdl",
	"models/props/cs_office/computer_caseb_p2a.mdl",
	"models/props/cs_office/computer_caseb_p3a.mdl",
	"models/props/cs_office/computer_caseb_p4a.mdl",
	"models/props/cs_office/computer_caseb_p5a.mdl",
	"models/props/cs_office/computer_caseb_p5b.mdl",
	"models/props/cs_office/computer_caseb_p6a.mdl",
	"models/props/cs_office/computer_caseb_p6b.mdl",
	"models/props/cs_office/computer_caseb_p7a.mdl",
	"models/props/cs_office/computer_caseb_p8a.mdl",
	"models/props/cs_office/computer_caseb_p9a.mdl",
	"models/gibs/helicopter_brokenpiece_02.mdl",
	"models/gibs/manhack_gib03.mdl",
	"models/gibs/manhack_gib04.mdl",
	"models/gibs/manhack_gib05.mdl",
	"models/gibs/manhack_gib06.mdl",
	"models/gibs/metal_gib1.mdl",
	"models/gibs/metal_gib2.mdl",
	"models/gibs/metal_gib3.mdl",
	"models/gibs/metal_gib4.mdl",
	"models/gibs/metal_gib5.mdl",
	"models/gibs/scanner_gib01.mdl",
	"models/gibs/scanner_gib02.mdl",
	"models/props_c17/canisterchunk01d.mdl",
	"models/props_c17/canisterchunk01b.mdl",
	"models/props_c17/canisterchunk01l.mdl",
	"models/props_c17/canisterchunk01m.mdl",
	"models/props_c17/canisterchunk02b.mdl",
	"models/props_c17/canisterchunk02c.mdl",
	"models/props_c17/canisterchunk02d.mdl",
	"models/props_c17/canisterchunk02e.mdl",
	"models/props_c17/canisterchunk02f.mdl",
	"models/props_c17/canisterchunk01a.mdl",
	"models/props_c17/canisterchunk01h.mdl",
	"models/props_c17/oildrumchunk01a.mdl",
	"models/props_c17/oildrumchunk01b.mdl",
	"models/props_c17/oildrumchunk01c.mdl",
	"models/props_c17/oildrumchunk01d.mdl",
	"models/props_c17/oildrumchunk01e.mdl",
	"models/props_c17/oildrumchunk01a.mdl",
	"models/props_c17/oildrumchunk01b.mdl",
	"models/props_c17/oildrumchunk01c.mdl",
	"models/props_c17/oildrumchunk01d.mdl",
	"models/props_c17/oildrumchunk01e.mdl",
	"models/props_canal/boat001a_chunk010.mdl",
	"models/props_canal/boat001a_chunk06.mdl",
	"models/props_debris/concrete_chunk04a.mdl",
	"models/props_debris/concrete_chunk05g.mdl",
	"models/props_debris/prison_wallchunk001f.mdl",
	"models/props_debris/wood_chunk04a.mdl",
	"models/props_debris/wood_chunk06b.mdl",
	"models/props_junk/glassjug01_chunk01.mdl",
	"models/props_junk/glassjug01_chunk03.mdl",
	"models/props_junk/vent001_chunk1.mdl",
	"models/props_junk/vent001_chunk2.mdl",
	"models/props_junk/vent001_chunk3.mdl",
	"models/props_junk/vent001_chunk4.mdl",
	"models/props_junk/vent001_chunk5.mdl",
	"models/props_junk/vent001_chunk6.mdl",
	"models/props_junk/vent001_chunk7.mdl",
	"models/props_junk/vent001_chunk8.mdl",
	"models/props_junk/wood_crate001a_chunk03.mdl",
	"models/props_wasteland/prison_toiletchunk01g.mdl",
	"models/props_wasteland/prison_toiletchunk01h.mdl",
	"models/props_wasteland/prison_toiletchunk01i.mdl",
	"models/props_wasteland/prison_toiletchunk01j.mdl",
	"models/props_wasteland/prison_toiletchunk01k.mdl",
	"models/props_wasteland/prison_toiletchunk01l.mdl",
	"models/props_wasteland/prison_toiletchunk01m.mdl",
	"models/props_wasteland/prison_toiletchunk01e.mdl",
	"models/props_wasteland/prison_toiletchunk01c.mdl",
	"models/props_wasteland/prison_sinkchunk001b.mdl",
	"models/props_wasteland/prison_sinkchunk001c.mdl",
	"models/props_wasteland/prison_sinkchunk001d.mdl",
	"models/props_wasteland/prison_sinkchunk001e.mdl",
	"models/props_wasteland/prison_sinkchunk001g.mdl",
	"models/props_wasteland/prison_sinkchunk001h.mdl",
	"models/Mechanics/gears/gear12x6_small.mdl",
	"models/Mechanics/gears/gear12x12.mdl",
	"models/props_phx/gears/bevel12.mdl",
	"models/props_phx/gears/bevel9.mdl",
	"models/Mechanics/gears2/gear_12t2.mdl",
	"models/Mechanics/gears/gear12x6_small.mdl",
	"models/Mechanics/gears/gear12x12.mdl",
	"models/props_phx/gears/bevel12.mdl",
	"models/props_phx/gears/bevel9.mdl",
	"models/Mechanics/gears2/gear_12t2.mdl"
}
ENT.EZconsumes={
	JMod.EZ_RESOURCE_TYPES.BASICPARTS, 
	JMod.EZ_RESOURCE_TYPES.POWER
}
ENT.FlexFuels = nil -- "Flex Fuels" are other resource types that the machine will load as electricity
ENT.DamageTypeTable={
	[DMG_BUCKSHOT]=.2,
	[DMG_SNIPER]=.7,
	[DMG_CRUSH]=1,
	[DMG_BULLET]=.5,
	[DMG_SLASH]=.2,
	[DMG_BLAST]=.8,
	[DMG_CLUB]=.9,
	[DMG_SHOCK]=1,
	[DMG_BURN]=.3,
	[DMG_ACID]=.4,
	[DMG_PLASMA]=.4,
	[DMG_VEHICLE]=1,
	[DMG_DROWN]=0,
	[DMG_PARALYZE]=0,
	[DMG_NERVEGAS]=0,
	[DMG_POISON]=0,
	[DMG_RADIATION]=0,
	[DMG_FALL]=1,
	[DMG_SONIC]=.6,
	[DMG_ENERGYBEAM]=.8,
	[DMG_SLOWBURN]=.3,
	[DMG_PHYSGUN]=1,
	[DMG_AIRBOAT]=.5,
	[DMG_DISSOLVE]=.6,
	[DMG_BLAST_SURFACE]=.8,
	[DMG_DIRECT]=.3,
	[DMG_GENERIC]=1,
	[DMG_MISSILEDEFENSE]=1
}
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
		for specName, value in 
			pairs(self.StaticPerfSpecs)do self[specName] = value 
			NetworkTable[specName] = NewValue
		end
	end
	if (self.DynamicPerfSpecs) then
		for specName, value in pairs(self.DynamicPerfSpecs)do
			if(type(value)~="table")then
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
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.SetOwner(ent,ply)
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
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(self.Mass)
        end
		self:SetState(JMod.EZ_STATE_OFF)
		self:SetGrade(JMod.EZ_GRADE_BASIC)
		self:InitPerfSpecs()
		if(self.CustomInit)then self:CustomInit() end
		self.Durability = self.MaxDurability
		if GetConVar("sv_cheats"):GetBool() then
			self:SetElectricity(self.MaxElectricity)
		else
			self:SetElectricity(0)
		end
		---
		if(self.Owner)then JMod.Colorify(self) end
		---
		if(self.EZupgradable)then
			self.UpgradeProgress={}
			self.UpgradeCosts=JMod.CalculateUpgradeCosts(JMod.Config.Craftables[self.PrintName] and JMod.Config.Craftables[self.PrintName].craftingReqs)
		end
		self.NextRefillTime = 0
	end

	function ENT:PhysicsCollide(data,physobj)
		if((data.Speed>80)and(data.DeltaTime>0.2))then
			self.Entity:EmitSound("Metal_Box.ImpactHard")
			if(data.Speed>800 and not self:IsPlayerHolding() and not (data.HitEntity and data.HitEntity.IsPlayerHolding and data.HitEntity:IsPlayerHolding()))then
				local Dam,World=DamageInfo(),game.GetWorld()
				Dam:SetDamage(data.Speed/3)
				Dam:SetAttacker(data.HitEntity or World)
				Dam:SetInflictor(data.HitEntity or World)
				Dam:SetDamageType(DMG_CRUSH)
				Dam:SetDamagePosition(data.HitPos)
				Dam:SetDamageForce(data.TheirOldVelocity)
				JMod.DamageSpark(self)
				self:TakeDamageInfo(Dam)
			end
		end
	end

	function ENT:ConsumeElectricity(amt)
		if not(self.GetElectricity)then return end
		amt = (amt or .2)/(self.ElectricalEfficiency or 1)
		local NewAmt = math.Clamp(self:GetElectricity() - amt, 0.0, self.MaxElectricity)
		self:SetElectricity(NewAmt)
		if(NewAmt <= 0 and self:GetState() > 0)then self:TurnOff() end
	end

	function ENT:DetermineDamageMultiplier(dmg)
		local Mult = .5 / (self.Armor or 1)
		for typ, mul in pairs(self.DamageTypeTable)do
			if(dmg:IsDamageType(typ))then Mult = Mult * mul break end
		end
		if(self.CustomDetermineDmgMult)then Mult = Mult * self:CustomDetermineDmgMult(dmg) end
		return Mult
	end

	function ENT:OnTakeDamage(dmginfo)
		if not(IsValid(self))then return end
		self:TakePhysicsDamage(dmginfo)
		--
		local DmgMult = self:DetermineDamageMultiplier(dmginfo)
		if(DmgMult <= .001)then return end
		local Damage = dmginfo:GetDamage() * DmgMult
		self.Durability = self.Durability - Damage

		if(self.Durability <= 0)then self:Break(dmginfo) end
		if(self.Durability <= -(self.MaxDurability * 2))then self:Destroy(dmginfo) end
	end

	function ENT:Break(dmginfo)
		if(self:GetState() == JMod.EZ_STATE_BROKEN)then return end
		self:SetState(JMod.EZ_STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))
		for i = 1, 20 do JMod.DamageSpark(self) end

		local StartPoint, ToPoint, Spread, Scale, UpSpeed = self:LocalToWorld(self:OBBCenter()), nil, 2, 1, 10
		local Force, GibNum = dmginfo:GetDamageForce(), math.min(JMod.Config.SupplyEffectMult * self:GetPhysicsObject():GetMass()/2000, 20)

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
		if(self.OnBreak)then self:OnBreak() end
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i = 1, 20 do JMod.DamageSpark(self) end

		local StartPoint, ToPoint, Spread, Scale, UpSpeed = self:LocalToWorld(self:OBBCenter()), nil, 2, 1, 10
		local Force, GibNum = dmginfo:GetDamageForce(), math.min(JMod.Config.SupplyEffectMult * self:GetPhysicsObject():GetMass()/1000, 30)
		if JMod.Config.Craftables[self.PrintName] then
			for k, v in pairs(JMod.Config.Craftables[self.PrintName].craftingReqs) do
				JMod.ResourceEffect(k, StartPoint, ToPoint, GibNum * (v / 3000), Spread, Scale, UpSpeed)
			end
		else
			JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.BASICPARTS, StartPoint, ToPoint, GibNum, Spread, Scale, UpSpeed)
		end

		if(self.Pod)then -- machines with seats
			if(IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
			end
		end
		if(self.OnDestroy)then self:OnDestroy(dmginfo) end
		SafeRemoveEntityDelayed(self, 0.1)
	end

	function ENT:SFX(str,absPath)
		if(absPath)then
			sound.Play(str,self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,math.random(90,110))
		else
			sound.Play("snds_jack_gmod/"..str..".wav",self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,100)
		end
	end

	function ENT:Whine(serious)
		local Time=CurTime()
		if(self.NextWhine<Time)then
			self.NextWhine=Time+4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.wav",70,100)
			self:ConsumeElectricity(.05)
		end
	end

	function ENT:OnRemove()
		--
	end

	function ENT:TryLoadResource(typ, amt)
		if(amt <= 0)then return 0 end
		local Time = CurTime()
		if self.NextRefillTime > Time then return 0 end
		for k,v in pairs(self.EZconsumes)do
			if(typ == v)then
				local Accepted = 0
				if(typ == JMod.EZ_RESOURCE_TYPES.POWER)then
					local Powa = self:GetElectricity()
					local Missing = self.MaxElectricity - Powa
					if(Missing <= 0)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetElectricity(Powa + Accepted)
					self:EmitSound("snd_jack_turretbatteryload.wav", 65, math.random(90, 110))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES)then
					local Supps = self:GetSupplies()
					local Missing = self.MaxSupplies - Supps
					if(Missing <= 0)then return 0 end
					--if(Missing<self.MaxSupplies*.1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetSupplies(Supps + Accepted)
					self:EmitSound("snd_jack_turretbatteryload.wav", 65, math.random(90, 110)) -- TODO: new sound here
				elseif(typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS)then
					local Missing = self.MaxDurability - self.Durability
					if(Missing <= self.MaxDurability * .25)then return 0 end
					Accepted = math.min(Missing, amt)
					self.Durability = self.Durability + Accepted
					if(self.Durability >= self.MaxDurability)then self:RemoveAllDecals() end
					self:EmitSound("snd_jack_turretrepair.wav", 65, math.random(90, 110))
					if(self.Durability > 0)then
						if(self:GetState() == JMod.EZ_STATE_BROKEN)then self:SetState(JMod.EZ_STATE_OFF) end
					end
				elseif(typ == JMod.EZ_RESOURCE_TYPES.GAS)then
					local Fool = self:GetGas()
					local Missing = self.MaxGas - Fool
					if(Missing <= 0)then return 0 end
					--if(Missing < self.MaxGas * .1)then return 0 end
					Accepted=math.min(Missing, amt)
					self:SetGas(Fool + Accepted)
					self:EmitSound("snds_jack_gmod/gas_load.wav", 65, math.random(90, 110))
				elseif(typ==JMod.EZ_RESOURCE_TYPES.AMMO)then
					local Ammo = self:GetAmmo()
					local Missing = self.MaxAmmo - Ammo
					if(Missing <= 1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetAmmo(Ammo + Accepted)
					self:EmitSound("snd_jack_turretammoload.wav", 65, math.random(90, 110))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.MUNITIONS)then
					local Ammo = self:GetAmmo()
					local Missing = self.MaxAmmo - Ammo
					if(Missing <= 1)then return 0 end
					Accepted = math.min(Missing, amt)
					self:SetAmmo(Ammo + Accepted)
					self:EmitSound("snd_jack_turretammoload.wav", 65, math.random(90, 110))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.COOLANT)then
					local Kewl = self:GetCoolant()
					local Missing = self.MaxCoolant - Kewl
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetCoolant(Kewl+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.wav", 65, math.random(90, 110))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.WATER)then
					local Aqua = self:GetWater()
					local Missing = self.MaxWater - Aqua
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetWater(Aqua+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.wav", 65, math.random(90, 110))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.CHEMICALS)then
					local Chem = self:GetChemicals()
					local Missing = self.MaxChemicals - Chem
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetChemicals(Chem+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.wav", 65, math.random(90, 110))
				elseif(typ==JMod.EZ_RESOURCE_TYPES.OIL)then
					local Oil = self:GetOil()
					local Missing = self.MaxOil - Oil
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetOil(Oil+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.wav", 65, math.random(90, 110))
				elseif(typ==JMod.EZ_RESOURCE_TYPES.FUEL)then
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
					self:EmitSound("snds_jack_gmod/liquid_load.wav", 65, math.random(90, 110))
				elseif(typ==JMod.EZ_RESOURCE_TYPES.COAL)then
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
				elseif (string.find(typ, " ore")) then
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

	-- Entity save/dupe functionality
	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetOwner(self, ply)
		ent.NextRefillTime = Time + math.random(0.1, 0.5)
	end

elseif(CLIENT)then
	net.Receive("JMod_MachineSync", function(len, ply)
		local Ent = net.ReadEntity()
		local NewSpecs = net.ReadTable()
		if IsValid(Ent) then
			for specName, value in pairs(NewSpecs) do
				Ent[specName] = value
			end
		end
	end)

	function ENT:Initialize()
		self.StaticPerfSpecs.BaseClass=nil
		self.DynamicPerfSpecs.BaseClass=nil
		self:InitPerfSpecs()
		if(self.CustomInit)then self:CustomInit() end
	end

	function ENT:OnRemove()
		if(self.CSmodels)then
			for k,v in pairs(self.CSmodels)do
				if(IsValid(v))then
					v:Remove()
				end
			end
		elseif(self.Mdl)then
			self.Mdl:Remove()
		end
	end
end
