-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Plant"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.NoSitAllowed = true
----
ENT.Model="models/jmod/props/tree0.mdl"
ENT.Mass=150
ENT.JModDontIrradiate = false
ENT.EZcolorable = false
----
ENT.EZconsumes={
	JMod.EZ_RESOURCE_TYPES.WATER
}
--[[ENT.StaticPerfSpecs={
	MaxDurability=100,
	MaxWater=100,
	Armor=1,
}]]--
ENT.UsableMats = {MAT_DIRT, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}
---- Shared Functions ----
--[[function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Water") -- We will indicate this through other means
	if(self.CustomSetupDataTables)then
		self:CustomSetupDataTables()
	end
end]]--

--[[
function ENT:GravGunPickupAllowed(ply)
	return true
end
--]]

--[[function ENT:InitPerfSpecs()
	local NetworkTable = {}
	if (self.StaticPerfSpecs) then
		for specName, value in pairs(self.StaticPerfSpecs)do 
			self[specName] = value 
			NetworkTable[specName] = NewValue
		end
	end
	if SERVER then
		net.Start("JMod_MachineSync")
		net.WriteEntity(self)
		net.WriteTable(NetworkTable)
		net.Broadcast()
	end
end]]--

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
		JMod.Hint(ply, classname)
		return ent
	end

	function ENT:Initialize()
		---
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
		self.DamageModifierTable = JMod.TreeArmorTable
		self.BackupRecipe = {[JMod.EZ_RESOURCE_TYPES.WOOD] = 100}
		self.MaxWater = 100

		--=== Put things that shoulf be overrideable by machines above this line. ====-
		if(self.CustomInit)then self:CustomInit() end
		--=== Apply changes and state things that shouldn't be overrideable below.====-
		if self.TryPlant then
			self:TryPlant()
		end
		if self.SpawnFull then
			self:SetWater(self.Hydration or 100)
		else
			self:SetWater(0)
		end
		---
		--if(JMod.GetEZowner(self))then JMod.Colorify(self) end --No ownership for plants, maybe
		---
		self.NextRefillTime = 0
	end

	function ENT:Break(dmginfo)
		self:Destroy(dmginfo)
	end

	function ENT:GetWater()
		return self.Hydration
	end

	function ENT:SetWater(amt)
		self.Hydration = amt
	end

	function ENT:UpdateDepositKey()
		self.DepositKey = JMod.GetDepositAtPos(self, self:GetPos() - Vector(0, 0, self.SpawnHeight or 60))
		return self.DepositKey
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed > 100) and (data.DeltaTime>0.2) then
			self:EmitSound("Wood.ImpactSoft", 100, 80)
			self:EmitSound("Wood.ImpactSoft", 100, 80)
			if IsValid(data.HitObject) then
				local TheirForce = (.5 * data.HitObject:GetMass() * ((data.TheirOldVelocity:Length()/16)*0.3048)^2)
				local ForceThreshold = physobj:GetMass() * 10 * self.Growth
				local PhysDamage = TheirForce/(physobj:GetMass()*100)

				--jprint(PhysDamage)
				--jprint("Their Speed: ", math.Round(data.TheirOldVelocity:Length()), "Resultant force: "..tostring(math.Round(TheirForce - ForceThreshold)))

				if self.EZinstalled and not(physobj:IsMotionEnabled()) and (TheirForce >= ForceThreshold) then
					physobj:EnableMotion(true)
					--physobj:SetVelocity(data.TheirOldVelocity:GetNormalized() * ((TheirForce - ForceThreshold) / (physobj:GetMass() * self.Growth)))
				end
				if PhysDamage >= 1 then
					local CrushDamage = DamageInfo()
					CrushDamage:SetDamage(math.floor(PhysDamage))
					CrushDamage:SetDamageType(DMG_CRUSH)
					CrushDamage:SetDamageForce(data.TheirOldVelocity / 1000)
					CrushDamage:SetDamagePosition(data.HitPos)
					self:TakeDamageInfo(CrushDamage)

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

	function ENT:DetermineDamageMultiplier(dmg)
		local Mult = .5 / (self.Armor or 1)
		for typ, mul in pairs(self.DamageModifierTable)do
			if(dmg:IsDamageType(typ))then Mult = Mult * mul break end
		end
		if(self.CustomDetermineDmgMult)then Mult = Mult * self:CustomDetermineDmgMult(dmg) end
		return Mult
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Damage = dmginfo:GetDamage() * self:DetermineDamageMultiplier(dmginfo)
		if dmginfo:IsDamageType(DMG_RADIATION) and isfunction(self.Mutate) and (math.random(0, 10000) >= 9999) then
			self:Mutate()
		end
		if (dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_SLOWBURN)) and self.Hydration > 0 then
			self.Hydration = math.Clamp(self.Hydration - Damage, 0, 100)
		else
			self.Helf = self.Helf - Damage
		end
		if (self.Helf <= 0) then
			self:Destroy(dmginfo) 
			return 
		end
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Wood.Break", 70, math.random(80, 120))
		self:EmitSound("Wood_Solid.Break", 70, math.random(80, 120))
		--for i = 1, 20 do JMod.DamageSpark(self) end

		local StartPoint, ToPoint, Spread, Scale, UpSpeed = self:LocalToWorld(self:OBBCenter()), nil, 2, 1, 10
		local Force, GibNum = dmginfo:GetDamageForce(), math.min(JMod.Config.Machines.SupplyEffectMult * self:GetPhysicsObject():GetMass()/1000, 30)
		if self.GibModels then
			for k, v in pairs(self.GibModels) do
				--JMod.ResourceEffect(k, StartPoint, ToPoint, GibNum * (v / 800), Spread, Scale, UpSpeed)
			end
		else
			JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.WOOD, StartPoint, ToPoint, GibNum, Spread, Scale, UpSpeed)
		end
		
		if self.OnDestroy then self:OnDestroy(dmginfo) end
		self:SetNoDraw(true)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		SafeRemoveEntityDelayed(self, 2)
	end

	function ENT:GetWaterProximity()
		local WaterAround, SelfPos = 0, self:GetPos()
		if StormFox and StormFox.IsRaining() then return 1 end -- Why do expensive calcs if it's raining?
		for i = 1, 50 do
			local PointToCheck = SelfPos + Vector(math.random(-800, 800), math.random(-800, 800), math.random(0, -500))
			if (bit.band(util.PointContents(PointToCheck), CONTENTS_WATER) == CONTENTS_WATER) then WaterAround = WaterAround + .1 end
		end
		-- figger out all deposits we are inside of
		local DepositsInRange = {}
		for k, v in pairs(JMod.NaturalResourceTable) do
			local Dist = SelfPos:Distance(v.pos)
			if (Dist <= v.siz) then
				if (v.rate or (v.amt > 0)) then
					table.insert(DepositsInRange, k)
				end
			end
		end
		-- now, among all the deposits we are inside of, let's figger out if one is water
		if #DepositsInRange > 0 then
			for k, v in pairs(DepositsInRange) do
				local DepositInfo = JMod.NaturalResourceTable[v]
				if (DepositInfo.typ == JMod.EZ_RESOURCE_TYPES.WATER) then
					WaterAround = WaterAround + .9
				end
			end
		end
		---
		return math.Clamp(WaterAround, 0, 1)
	end

	function ENT:CheckSky(Pos)
		local SkyMod, MapName = 1, string.lower(game.GetMap())
		for k, mods in pairs(JMod.MapSolarPowerModifiers)do
			local keywords, mult = mods[1], mods[2]
			for _, word in pairs(keywords) do
				if (string.find(MapName, word)) then SkyMod = mult break end
			end
		end
		local HitAmount = 0
		for i = 1, 9 do -- Pitch
			for j = 1, 36 do -- Yaw
				local Dir = Angle(i * -18, j * 10, 0):Forward()
				local Tr = util.QuickTrace(Pos, Dir * 20000, self)
				if (Tr.HitSky) then HitAmount = HitAmount + .01 end
			end
		end
		return math.Clamp(HitAmount, 0, 1) * SkyMod
	end

	local DayLightMultipliers = {
		["Fog"] = 0.3,
		["Cloudy"] = 0.1,
		["Snowin'"] = 0.1,
		["Sandstorm"] = 0.1,
		["Lava Eruption"] = 0,
		["Radioactive"] = 0
	}

	function ENT:GetDayLight()
		if(StormFox)then
			local Minutes = StormFox.GetTime()
			local Frac = Minutes / 1440
			Frac = (math.sin(Frac * math.pi * 2 - math.pi / 2) + 0.1)
			local Mult = Frac--math.Clamp(Frac, 0, 1)
			if (StormFox.IsNight())then 
				Mult = 0 
			else
				local Weather = StormFox.GetWeather()
				if DayLightMultipliers[Weather] then 
					Mult = Mult * DayLightMultipliers[Weather]
				else 
					Mult = 1 
				end
			end
		end
		return 1
	end

	function ENT:OnRemove()
	end

	function ENT:TryLoadResource(typ, amt)
		if(amt <= 0)then return 0 end
		local Time = CurTime()
		if (self.NextRefillTime > Time) or (typ == "generic") then return 0 end
		for _,v in pairs(self.EZconsumes)do
			if(typ == v)then
				local Accepted = 0
				if(typ == JMod.EZ_RESOURCE_TYPES.WATER)or(typ == JMod.EZ_RESOURCE_TYPES.CHEMICALS)or(typ == JMod.EZ_RESOURCE_TYPES.PROPELLANT)then
					local Aqua = self:GetWater()
					local Missing = self.MaxWater - Aqua
					if(Missing < 1)then return 0 end
					Accepted=math.min(Missing,amt)
					self:SetWater(Aqua+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				--[[elseif(typ == JMod.EZ_RESOURCE_TYPES.CHEMICALS)then
					local Chem = self:GetChemicals()
					local Missing = self.MaxChemicals - Chem
					if(Missing < 1)then return 0 end
					Accepted = math.min(Missing,amt)
					self:SetChemicals(Chem + Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 65, math.random(90, 110))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.PROPELLANT)then
					local Wata = self.Hydration
					local Missing = 100 - Wata
					if (Missing <= 0) then return 0 end
					Accepted = math.min(Missing, amt)
					self.Hydration = Wata + Accepted
					self.LastWateredTime = Time
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 60, math.random(120, 130))
				elseif(typ == JMod.EZ_RESOURCE_TYPES.EXPLOSIVES)then
					local Wata = self.Hydration
					local Missing = 100 - Wata
					if (Missing <= 0) then return 0 end
					Accepted = math.min(Missing, amt)
					self.Hydration = Wata + Accepted
					self.LastWateredTime = Time
					self:EmitSound("snds_jack_gmod/liquid_load.ogg", 60, math.random(120, 130))--]]
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
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + 1
		if ent.NextUseTime then
			ent.NextUseTime = Time + 1
		end
		if ent.UpdateAppearance then
			ent:UpdateAppearance()
		end
	end

	hook.Add("GravGunOnPickedUp", "JMOD_Fruit_GravGun_TimeReset", function(ply, ent) 
		if ent.LastTouchedTime then
			ent.LastTouchedTime = CurTime()
		end
	end)

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
		self:SetModel(self.Model)
		if self.ClientOnly then return end
		self.MaxWater = 100
		if(self.CustomInit)then self:CustomInit() end
	end

	function ENT:OnRemove()
		if self.Mdl or self.CSmodels then
			JMod.SafeRemoveCSModel(self, IsValid(self.Mdl) and self.Mdl, self.CSmodels)
		end
	end
end
