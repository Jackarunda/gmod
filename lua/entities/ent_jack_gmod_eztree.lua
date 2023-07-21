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
ENT.UsableMats = {MAT_DIRT, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}

function ENT:CustomSetupDataTables()
	-- we will indicate status through other means
end

if(SERVER)then
	function ENT:CustomInit()
		self.EZupgradable = false
		self.Growth = 0
		self.Hydration = 100
		self.Helf = 100
		self.NextLeafDrop = 0
		self.NextAcornDrop = 0
		self.NextAppleDrop = 0
		self.NextWaterCheck = 0
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
		self:SetProgress(self:GetProgress() - 100)
	end

	function ENT:TryPlant()
		self.InstalledMat = nil
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -200), self)
		if (Tr.Hit) then
			self.InstalledMat = Tr.MatType
			if not (table.HasValue(self.UsableMats, self.InstalledMat)) then self:Remove() return end
			if (self:WaterLevel() > 0) then self:Remove() return end
			self.EZinstalled = true
			util.Decal("EZtreeRoots", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			timer.Simple(.1, function()
				if (IsValid(self)) then
					local HitAngle = Tr.HitNormal:Angle()
					HitAngle:RotateAroundAxis(HitAngle:Right(), -90)
					self:SetAngles(HitAngle)
					self:SetPos(Tr.HitPos)
					self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
				end
			end)
		else
			self:Remove()
		end
	end

	function ENT:GetWaterProximity()
		local WaterAround, SelfPos = 0, self:GetPos()
		for i = 1, 50 do
			local PointToCheck = SelfPos + Vector(math.random(-500, 500), math.random(-500, 500), math.random(0, -500))
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
					WaterAround = WaterAround + .5
				end
			end
		end
		---
		return math.Clamp(WaterAround, 0, 1)
	end

	function ENT:CheckSky()
		local SkyMod, MapName = 1, string.lower(game.GetMap())
		for k, mods in pairs(JMod.MapSolarPowerModifiers)do
			local keywords, mult = mods[1], mods[2]
			for _, word in pairs(keywords) do
				if (string.find(MapName, word)) then SkyMod = mult break end
			end
		end
		local HitAmount, StartPos = 0, self:GetPos() + self:GetUp() * 100
		for i = 1, 10 do
			for j = 1, 10 do
				local Dir = (self:GetAngles() + Angle((i + 11) * 18, (j + 11) * 18, 0)):Forward()
				local Tr = util.TraceLine({start = StartPos, endpos = StartPos + Dir * 9e9, filter = {self}, mask = MASK_SOLID})
				--JMod.Sploom(game.GetWorld(), Tr.HitPos, 1, 10)
				if (Tr.HitSky) then
					HitAmount = HitAmount + .02
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

	function ENT:Think()
		if (self.Helf <= 0) then self:Destroy() return end
		if (self.EZinstalled and not IsValid(self.GroundWeld)) then self:Remove() return end
		local Time, SelfPos = CurTime(), self:GetPos()
		--
		jprint("water " .. self:GetWaterProximity() .. " daylight " .. self:GetDayLight() .. " sky " .. self:CheckSky())
		local WaterLossMult, DaylightMult = 1 - self:GetWaterProximity(), self:GetDayLight() * self:CheckSky()
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
			self.Helf = self.Helf - 1
		else
			local GrowthMult = DaylightMult * (self.Hydration / 100)
		end
		--
		self:NextThink(Time + math.Rand(9, 11))
		return true
	end
elseif CLIENT then
	local Roots = Material("decals/ez_tree_roots")
	function ENT:CustomInit()
		--
	end
	function ENT:Draw()
		--local SelfPos = self:GetPos()
		self:DrawModel()
		--[[
		render.SetMaterial(Roots)
		local rCol = render.GetLightColor(SelfPos)
		rCol.x = rCol.x ^ .5
		rCol.y = rCol.y ^ .5
		rCol.z = rCol.z ^ .5
		local Col = Color(255 * rCol.x, 255 * rCol.y, 255 * rCol.z)
		render.DrawQuadEasy(SelfPos, self:GetUp(), 150, 150, Col, 0)
		--]]
	end
	language.Add("ent_jack_gmod_eztree", "EZ Tree")
end
