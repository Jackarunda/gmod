AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Tree"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = false
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/props/tree0.mdl"
ENT.EZcolorable = false
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 0
--
ENT.StaticPerfSpecs = {
	MaxWater = 100,
	MaxDurability = 100
}
ENT.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
ENT.GrowthStageStats = {
	{mdl = "models/jmod/props/tree0.mdl", height = 5, wood = 1}, 
	{mdl = "models/jmod/props/tree1.mdl", height = 60, wood = 25}, 
	{mdl = "models/jmod/props/tree2.mdl", height = 120, wood = 100}
}

function ENT:CustomSetupDataTables()
	-- we will indicate status through other means
end

if(SERVER)then
	function ENT:CustomInit()
		self.EZupgradable = false
		self.Growth = 0
		self.Hydration = 20
		self.Health = 100
		self.NextLeafDrop = 0
		self.NextAcornDrop = 0
		self.NextAppleDrop = 0
		self.WaterProximity = self:GetWaterProximity()
		self:TryPlant()
	end

	function ENT:Break(dmginfo)
		self:Destroy(dmginfo)
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Wood.Break")

		local StartPoint, ToPoint, Spread, Scale, UpSpeed = self:LocalToWorld(self:OBBCenter()), nil, 2, 1, 10
		local Force, GibNum = (dmginfo and dmginfo:GetDamageForce()) or Vector(0, 0, 0), math.min(JMod.Config.Machines.SupplyEffectMult * self:GetPhysicsObject():GetMass()/1000, 30)
		
		JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.WOOD, self.GrowthStageStats[self.GrowthStage].wood, Vector(0, 0, 10), nil, Force, false, 0)

		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed>80) and (data.DeltaTime>0.2) then
			self:EmitSound("Wood.ImpactSoft", 100, 80)
			self:EmitSound("Wood.ImpactSoft", 100, 80)
			local Ent = data.HitEntity
			local Held = false
			if self:IsPlayerHolding() or (IsValid(Ent) and Ent:IsPlayerHolding()) then Held = true end
			if (data.Speed > 150) and (data.Speed < 800) then
				self:EmitSound("Wood.ImpactHard", 100, 80)
				self:EmitSound("Wood.ImpactSoft", 100, 80)
			elseif (data.Speed > 800) then
				local Dam, World = DamageInfo(), game.GetWorld()
				local PhysDamage = math.Round(data.Speed / (physobj:GetMass() / data.HitObject:GetMass())^2, 2)
				Dam:SetDamage(PhysDamage)
				Dam:SetAttacker(Ent or World)
				Dam:SetInflictor(Ent or World)
				Dam:SetDamageType(DMG_CRUSH)
				Dam:SetDamagePosition(data.HitPos)
				Dam:SetDamageForce(data.TheirOldVelocity / physobj:GetMass())
				if not Held then
					JMod.DamageSpark(self)
					self:TakeDamageInfo(Dam)
					self:EmitSound("Wood.Break")
				end
			end
		end
	end

	function ENT:Grow()
		self:Upgrade() -- This is for gaining durability
		self.GrowthStage = self.GrowthStage + 1
		self:SetModel(self.GrowthStageStats[self.GrowthStage].mdl)
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
		self:TryPlant()
		self:SetProgress(self:GetProgress() - 100)
	end

	function ENT:TryPlant()
		self.EZinstalled = not(self:GetPhysicsObject():IsMotionEnabled())
		if self.EZinstalled then return end
		self.BaseWaterGain = 0
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -200), self)
		SelfAng = self:GetAngles()
		if (Tr.Hit) and (Tr.HitWorld) then
			local GroundIsSolid = true
			for i = 1, 50 do
				local Contents = util.PointContents(Tr.HitPos - Vector(0, 0, 10 * i))
				if(bit.band(util.PointContents(self:GetPos()), CONTENTS_SOLID) == CONTENTS_SOLID) then GroundIsSolid = false break end
			end
			
			if(GroundIsSolid)then
				local HitAngle = Tr.HitNormal:Angle()
				HitAngle:RotateAroundAxis(self:GetForward(), 90)
				self:SetAngles(Angle(0, 0, 0))
				self:SetPos(Tr.HitPos + Tr.HitNormal * (self.SpawnHeight-3))
				---
				self:GetPhysicsObject():EnableMotion(false)
				self.EZinstalled = true
				---
				self.BaseWaterGain = self:CheckForWater()
				---
				if self:GetWater() < 10 then
					self:Sadden()
				else
					self:SetState(STATE_GROWING)
				end
			else
				self:SetState(STATE_WITHERING)
			end
		end
	end

	function ENT:CheckForWater()
		local WaterAround = 0
		for i = 1, 10 do
			for j = 1, 5 do
				local PointToCheck = self:GetPos() - self:GetUp()*10 + Angle(0, 0, i*36):Forward() * j * 5
				if bit.band( util.PointContents( PointToCheck ), CONTENTS_WATER ) then WaterAround = WaterAround + 0.02 end
			end
		end
		---
		self:UpdateDepositKey()
		---
		local Deposit = JMod.NaturalResourceTable[self.Depositkey]
		if Deposit and Deposit.typ == JMod.EZ_RESOURCE_TYPES.WATER then
			WaterAround = WaterAround + Deposit.rate
		end
		self.BaseWaterGain = WaterAround
	end

	function ENT:CheckSky()
		local SkyMod, MapName = 1, string.lower(game.GetMap())
		for k,mods in pairs(JMod.MapSolarPowerModifiers)do
			local keywords, mult = mods[1], mods[2]
			for _,word in pairs(keywords)do
				if(string.find(MapName,word))then SkyMod=mult break end
			end
		end
		local HitAmount, StartPos = 0, self:GetPos() + self:GetUp()*100
		for i = 1, 10 do
			for j = 1, 10 do
				local Dir = (self:GetAngles() + Angle((i+11)*18, (j+11)*18, 0)):Forward()
				local Tr = util.TraceLine({start = StartPos, endpos = StartPos + Dir*9e9, filter = {self}, mask = MASK_SOLID})
				--JMod.Sploom(game.GetWorld(), Tr.HitPos, 1, 10)
				if (Tr.HitSky) then
					HitAmount = HitAmount + 0.02
				end
			end
		end
		return HitAmount * SkyMod
	end

	function ENT:GetDayLight()
		if(StormFox)then
			local Minutes = StormFox.GetTime()
			local Frac = Minutes / 1440
			Frac = (math.sin(Frac * math.pi * 2 - math.pi / 2) + 0.1)
			local Mult = math.Clamp(Frac, 0, 1)
			if (StormFox.IsNight())then 
				Mult = 0 
			else
				local Weather = StormFox.GetWeather()
				if (Weather == "Fog") or (Weather == "Cloudy")then Mult = 0.3 
				elseif (Weather == "Snowin'") or (Weather == "Sandstorm") then Mult = 0.1 
				elseif (Weather == "Lava Eruption") or (Weather == "Radioactive") then Mult = 0 
				else Mult = 1 end
			end
		end
		return 1
	end

	function ENT:GetWaterProximity()
		local BasePos, DownVec = self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -200)
		for i = 1, 100 do
			local Offset = Vector(math.random(-500, 500), math.random(-500, 500), 0)
			local Tr = util.TraceLine({
				start = BasePos + Offset,
				endpos = BasePos + Offset + DownVec,
				filter = self,
				mask = MASK_SOLID_BRUSHONLY + MASK_WATER
			})
			if (Tr.Hit) then
				print(Tr.Contents)
			end
		end
		return 0
	end

	function ENT:Think()
		if (self.Health <= 0) then self:Destroy() return end
		local Time, SelfPos = CurTime()
		--
		local WaterLossMult, DaylightMult = 1 - self.WaterProximity, self:GetDayLight() * self:CheckSky()
		local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -200), self)
		if not(Tr.Hit)then
			self:Destroy()
			return
		else
			if (Tr.MatType == MAT_GRASS) then
				WaterLossMult = .5
			elseif (Tr.MatType == MAT_DIRT or Tr.MatType == MAT_SLOSH) then
				WaterLossMult = 1
			elseif (Tr.MatType == MAT_SAND) then
				WaterLossMult = 2
			end
		end
		if StormFox and StormFox.IsRaining() then
			WaterLossMult = -1
		end
		--
		self.Hydration = self.Hydration - 1 * WaterLossMult
		if (self.Hydration <= 0) then
			self.Health = self.Health - 1
		else
			local GrowthMult = DaylightMult * (self.Hydration / 100)
		end
		--
		self:NextThink(Time + math.Rand(9, 11))
		return true
	end
elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end

	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_eztree", "EZ Tree")
end
