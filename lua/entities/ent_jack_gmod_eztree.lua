﻿AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Tree"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc"
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Model = "models/jmod/props/tree0.mdl"
ENT.EZcolorable = false
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 0
--
ENT.StaticPerfSpecs = {
	MaxElectricity = 0,
	MaxWater = 100
}
ENT.DynamicPerfSpecs = {
	MaxDurability = 10,
}
ENT.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
ENT.GrowthStageStats = {
	{mdl = "models/jmod/props/tree0.mdl", height = 5, wood = 1}, 
	{mdl = "models/jmod/props/tree1.mdl", height = 60, wood = 25}, 
	{mdl = "models/jmod/props/tree2.mdl", height = 120, wood = 100}
}

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 0, "Water") -- Because why does a tree need electricity?
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Visibility")
end

local STATE_WITHERING, STATE_SAD, STATE_GROWING = -1, 0, 1

if(SERVER)then
	function ENT:CustomInit()
		self.EZupgradable = false
		self:TurnOn()
		self:SetProgress(0)
		self.GrowthStage = 1
		self.DepositKey = 0
		self.BaseWaterGain = 0
		self.LastState = STATE_GROWING
		local mapName = game.GetMap()
		self:TryPlant()
	end

	function ENT:Use(activator)
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
		local Force, GibNum = dmginfo:GetDamageForce(), math.min(JMod.Config.Machines.SupplyEffectMult * self:GetPhysicsObject():GetMass()/1000, 30)
		
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
		return HitAmount*SkyMod
	end

	function ENT:Sadden() 
		self:SetState(STATE_SAD)
		self:SetSubMaterial(1, "models/jmod/props/oak_leaf1")
	end

	function ENT:Wither() 
		self:SetState(STATE_WITHERING)
		self:SetSubMaterial(1, "models/jmod/props/oak_leaf1")
	end

	function ENT:GetDayLight()
		if(StormFox)then
			local Minutes = StormFox.GetTime()
			local Frac = Minutes / 1440
			Frac = (math.sin(Frac * math.pi * 2 - math.pi / 2) + 0.1)
			return math.Clamp(Frac, 0, 1)
		end
		return 1
	end

	function ENT:Think()
		local State = self:GetState()
		local WaterGain = self.BaseWaterGain or 0

		if not self:GetPhysicsObject():IsMotionEnabled() then
			self.EZinstalled = false
		end

		if State >= STATE_SAD then
			if self.LastState ~= STATE_GROWING then
				self:SetSubMaterial(1, "models/jmod/props/oak_leaf0")
			end
			if not self.EZinstalled then
				self:SetState(STATE_WITHERING)

				return
			end
			local WeatherMult = 1
			if(StormFox)then 
				if (StormFox.IsNight())then 
					WeatherMult = 0 
				else
					local Weather = StormFox.GetWeather()
					if (Weather == "Fog") or (Weather == "Cloudy")then WeatherMult = 0.3 
					elseif (Weather == "Snowin'") or (Weather == "Sandstorm") then WeatherMult = 0.1 
					elseif (Weather == "Lava Eruption") or (Weather == "Radioactive") then WeatherMult = 0 
					else WeatherMult = 1 end
				end
				if StormFox.IsRaining() then
					WaterGain = WaterGain + .8
				end
			end
			
			local Daylight = self:GetDayLight()
			self:SetVisibility(self:CheckSky() * WeatherMult * Daylight)
			local Vis = self:GetVisibility()
			local Grade = self:GetGrade()

			if self:GetProgress() < 100 then
				local Rate = math.Round(1 * Vis, 2)
				if State == STATE_SAD then
					self:SetProgress(math.Round(self:GetProgress() + Rate * .5, 2))
				else
					self:SetProgress(math.Round(self:GetProgress() + Rate, 2))
				end
				self:SetWater(math.Clamp(self:GetWater() + (WaterGain - (.5 + Rate)), 0, 100))
			end

			if self:GetProgress() >= 100 then
				self:Grow()
			end
			
		elseif State == STATE_WITHERING then
		end

		if State ~= STATE_GROWING and self:GetWater() >= 10 then
			self:SetState(STATE_GROWING)
		end

		self.LastState = State

		self:NextThink(CurTime() + math.random(9, 11))
		return true
	end

	function ENT:TurnOn() end --Stub
	function ENT:TurnOff() end --Stub

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		ent.NextUse = Time + math.Rand(0, 3)
	end

elseif CLIENT then
	function ENT:CustomInit()
		self:DrawShadow(true)
	end
	
	function ENT:Draw()
		local SelfPos,SelfAng,State=self:GetPos(),self:GetAngles(),self:GetState()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		local Grade = self:GetGrade()
		---
		self:DrawModel()
		---
		if State == STATE_WITHERING then return end
		---

		if DetailDraw then
			if Closeness < 20000 and State == STATE_GROWING then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 0)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(), 90)
				local Opacity = math.random(50, 150)
				local ElecFrac = self:GetProgress() / 100
				local VisFrac = self:GetVisibility()
				local R, G, B = JMod.GoodBadColor(ElecFrac)
				local VR, VG, VB = JMod.GoodBadColor(VisFrac)
				cam.Start3D2D(SelfPos + Up * 35 - Forward * 15 - Right * 30, DisplayAng, .1)
				surface.SetDrawColor(10,10,10,Opacity+50)
				surface.DrawRect(390,80,128,128)
				JMod.StandardRankDisplay(Grade,452,148,118,Opacity+50)
				draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 150, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac * 100)) .. "%", "JMod-Display", 150, 60, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined("EFFICIENCY", "JMod-Display", 350, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(tostring(math.Round(VisFrac * 100)) .. "%", "JMod-Display", 350, 60, Color(VR, VG, VB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_eztree", "EZ Tree")
end
