AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Wheat"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = true
ENT.Base = "ent_jack_gmod_eztree"
ENT.Model = "models/jmod/props/plants/razorgrain_pile.mdl"
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
		self.LastWheatMat = ""
		self.LastSubModel = 0
		self.NextGrowThink = 0
		self:UpdateAppearance()
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		self.Helf = self.Helf - dmginfo:GetDamage() / 2

		if (self.Helf <= 33) then
		self:UpdateAppearance()
		elseif (self.Helf <= 0) then 
			self:Destroy() 

			return 
		end
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Dirt.Impact")

		local FoodAmt = 0
		if (self.Growth >= 66) then
			FoodAmt = 100
		elseif (self.Growth >= 33) then
			FoodAmt = 50
		else
			FoodAmt = 25
		end

		local SpawnPos = Vector(0, 0, 100)
		if (FoodAmt > 0) then
			JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.ORGANICS, FoodAmt, SpawnPos, Angle(0, 0, 0), nil, false)
		end

		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed>80) and (data.DeltaTime>0.2) then
			self:EmitSound("Dirt.Impact", 100, 80)
			self:EmitSound("Dirt.Impact", 100, 80)
		end
	end

	function ENT:TryPlant()
		self.InstalledMat = nil
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -200), self)
		if (Tr.Hit) then
			self.InstalledMat = Tr.MatType
			if not (table.HasValue(self.UsableMats, self.InstalledMat)) then self:Remove() return end
			if (self:WaterLevel() > 0) then self:Remove() return end
			self.EZinstalled = true
			--util.Decal("EZtreeRoots", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			timer.Simple(.1, function()
				if (IsValid(self)) then
					local HitAngle = Tr.HitNormal:Angle()
					HitAngle:RotateAroundAxis(HitAngle:Right(), -90)
					HitAngle:RotateAroundAxis(Tr.HitNormal, math.random(0,  360))
					self:SetAngles(HitAngle)
					self:SetPos(Tr.HitPos)
					self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
					self:GetPhysicsObject():Sleep()
				end
			end)
		else
			self:Remove()
		end
	end

	function ENT:GetWaterProximity()
		local WaterAround, SelfPos = 0, self:GetPos()
		for i = 1, 50 do
			local PointToCheck = SelfPos + Vector(math.random(-800, 800), math.random(-800, 800), math.random(0, -200))
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

	function ENT:Think()
		if (self.Helf <= 0) then self:Destroy() return end
		if (self.EZinstalled and not IsValid(self.GroundWeld)) then self:Destroy() return end
		local Time, SelfPos = CurTime(), self:GetPos()
		if (self.NextGrowThink < Time) then
			self.NextGrowThink = Time + math.random(9, 11)
			local Water, Light, Sky, Ground = self:GetWaterProximity(), self:GetDayLight(), self:CheckSky(), 1
			-- jprint("water", Water, "light", Light, "sky", Sky, "ground", Ground, "helf", self.Helf, "growth", self.Growth, "hydration", self.Hydration)
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 50), Vector(0, 0, -200), self)
			if not(Tr.Hit)then
				self:Destroy()
				return
			else
				if (Tr.MatType == MAT_GRASS) then
					Ground = 1
				elseif (Tr.MatType == MAT_DIRT or Tr.MatType == MAT_SLOSH) then
					Ground = .5
				elseif (Tr.MatType == MAT_SAND) then
					Ground = .25
				end
			end
			if StormFox and StormFox.IsRaining() then Water = 1 end
			--
			if (self.Hydration > 0) then
				local Growth = Light * Sky * Ground * 2
				if (self.Helf < 100) then -- heal
					self.Helf = math.Clamp(self.Helf + Growth, 0, 100)
				else -- grow
					self.Growth = math.Clamp(self.Growth + Growth, 0, 100)
				end
				local WaterLoss = math.Clamp(1 - Water, .05, 1) * 2.5
				self.Hydration = math.Clamp(self.Hydration - WaterLoss, 0, 100)
			else
				self.Helf = math.Clamp(self.Helf - 2, 0, 100)
			end
			self:UpdateAppearance()
		end
		--
		self:NextThink(Time + math.Rand(2, 4))
		return true
	end

	function ENT:UpdateAppearance()
		local NewWheatMat, NewSubModel
		-- my kingdom for Switch statements
		if (self.Growth < 33) then
			NewSubModel = 3
		elseif (self.Growth < 66) then
			NewSubModel = 2
		else
			NewSubModel = 0
		end
		if (self.Helf < 25) then
			NewSubModel = 3
		end
		if (self.Hydration < 10) then
			NewWheatMat = "razorgrain_d"
		elseif (self.Hydration < 30) then
			NewWheatMat = "razorgrain_d"
		elseif (self.Hydration < 60) then
			NewWheatMat = "razorgrain_d"
		else
			NewWheatMat = "razorgrain_d"
		end
		NewWheatMat = "models/jmod/props/plants/" .. NewWheatMat
		--
		if (NewSubModel ~= self.LastSubModel) then
			self:SetBodygroup(0, NewSubModel)
			self:DrawShadow(true)
			self:SetUseType(SIMPLE_USE)
			self.LastSubModel = NewSubModel
			--self:TryPlant()
		end
		timer.Simple(0, function()
			if (IsValid(self)) then
				if (NewWheatMat ~= self.LastWheatMat) then
					self:SetSubMaterial(0, NewWheatMat)
					self.LastWheatMat = NewWheatMat
				end
			end
		end)
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
