AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Tree"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = false
ENT.Base = "ent_jack_gmod_ezcrop_base"
ENT.Model = "models/jmod/props/tree0.mdl"
ENT.EZcolorable = false
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 0
ENT.EZupgradable = false
--
ENT.StaticPerfSpecs = {
	MaxElectricity = 0,
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
		self.Growth = 0
		self.Hydration = self.Hydration or 100
		self.OldHydration = self.Hydration
		self.Helf = 100
		self.LastLeafMat = ""
		self.LastBarkMat = ""
		self.LastModel = ""
		self.NextGrowThink = 0
		self.IsPlanting = false
		self:UpdateAppearance()
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if dmginfo:IsDamageType(DMG_BURN) and self.Hydration >= 0 then
			self.Hydration = math.Clamp(self.Hydration - dmginfo:GetDamage() / 4, 0, 100)
		else
			self.Helf = self.Helf - dmginfo:GetDamage() / 2
		end
		if (self.Helf <= 0) then
			self:Destroy(dmginfo) 
			return 
		end
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Wood.Break")

		local WoodAmt, RubberAmt = 0, 0
		if (self.Growth >= 66) then
			WoodAmt = 300
			RubberAmt = ((math.random(1, 2) == 1) and 50) or 0
		elseif (self.Growth >= 33) then
			WoodAmt = 100
		else
			WoodAmt = 25
		end

		if not(self:IsOnFire() or (dmginfo and dmginfo:IsDamageType(DMG_BURN+DMG_SLOWBURN))) then
			local SpawnPos = Vector(0, 0, 100)
			if (WoodAmt > 0) then
				JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.WOOD, WoodAmt, SpawnPos, Angle(0, 0, 0), nil, false)
			end
			if (RubberAmt > 0) then
				JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.RUBBER, RubberAmt, SpawnPos, Angle(0, 0, 0), nil, false)
			end
		end

		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(physobj) then return end
		
		if (data.Speed > 100) and (data.DeltaTime>0.2) then
			self:EmitSound("Wood.ImpactSoft", 100, 80)
			self:EmitSound("Wood.ImpactSoft", 100, 80)
			if IsValid(data.HitObject) then
				local TheirForce = (.5 * data.HitObject:GetMass() * ((data.TheirOldVelocity:Length()/16)*0.3048)^2)
				local ForceThreshold = physobj:GetMass() * 10 * self.Growth
				local PhysDamage = TheirForce/(physobj:GetMass()*100)

				-- Only enable motion if tree is planted and motion is currently disabled
				if self.EZinstalled and not(physobj:IsMotionEnabled()) and (TheirForce >= ForceThreshold) then
					-- Add a small delay to prevent rapid state changes at low tickrates
					timer.Simple(0.1, function()
						if IsValid(self) and IsValid(physobj) and self.EZinstalled then
							physobj:EnableMotion(true)
						end
					end)
				end
				if PhysDamage >= 1 then
					local CrushDamage = DamageInfo()
					CrushDamage:SetDamage(math.floor(PhysDamage))
					CrushDamage:SetDamageType(DMG_CRUSH)
					CrushDamage:SetDamageForce(data.TheirOldVelocity / 1000)
					CrushDamage:SetDamagePosition(data.HitPos)
					self:TakeDamageInfo(CrushDamage)
				end
			end
		end
	end

	function ENT:TryPlant()
		self.InstalledMat = nil
		self.IsPlanting = true -- Flag to prevent destruction during planting
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -200), self)
		if (Tr.Hit) then
			self.InstalledMat = Tr.MatType
			if not (table.HasValue(self.UsableMats, self.InstalledMat)) then self:Remove() return end
			if (self:WaterLevel() > 0) then self:Remove() return end
			self.EZinstalled = true
			util.Decal("EZtreeRoots", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			timer.Simple(.1, function()
				if (IsValid(self)) then
					--[[local HitAngle = Tr.HitNormal:Angle()
					HitAngle:RotateAroundAxis(HitAngle:Right(), -90)
					HitAngle:RotateAroundAxis(Tr.HitNormal, math.random(0,  360))
					self:SetAngles(HitAngle)--]]
					self:SetAngles(Angle(0, math.random(0, 360, 0)))
					self:SetPos(Tr.HitPos + Vector(0, 0, -2))
					if Tr.Entity == game.GetWorld() then
						local phys = self:GetPhysicsObject()
						if IsValid(phys) then
							phys:EnableMotion(false)
						end
						--self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
					else
						self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
						local phys = self:GetPhysicsObject()
						if IsValid(phys) then
							phys:Sleep()
						end
					end
					self.IsPlanting = false -- Clear planting flag
					JMod.Hint(JMod.GetEZowner(self), "tree growth")
				end
			end)
		else
			self.IsPlanting = false
			self:Remove()
		end
	end

	function ENT:Think()
		if (self.Helf <= 0) then self:Destroy() return end
		-- Don't check planting status if tree is in the process of being planted
		if not self.IsPlanting then
			-- Check if tree is properly planted - either welded to an entity or motion disabled on world
			if (self.EZinstalled) then
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					local isWelded = IsValid(self.GroundWeld)
					local isMotionDisabled = not phys:IsMotionEnabled()
					-- Tree should be either welded OR have motion disabled (planted on world)
					if not (isWelded or isMotionDisabled) then
						self:Destroy() 
						return 
					end
				else
					self:Destroy()
					return
				end
			end
		end
		local Time, SelfPos, Owner, Vel = CurTime(), self:GetPos(), self.EZowner, self:GetPhysicsObject():GetVelocity()
		if (self.NextGrowThink < Time) then
			self.NextGrowThink = Time + math.random(9, 11)
			local Water, Light, Sky, Ground = self:GetWaterProximity(), self:GetDayLight(), self:CheckSky(SelfPos + Vector(0, 0, 50)), 1
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
			--
			if (self.Hydration > 0) then
				local Growth = Light * Sky * Ground * 1.5
				if (self.Helf < 100) then -- heal
					self.Helf = math.Clamp(self.Helf + Growth * JMod.Config.ResourceEconomy.GrowthSpeedMult, 0, 100)
				else -- grow
					self.Growth = math.Clamp(self.Growth + Growth * JMod.Config.ResourceEconomy.GrowthSpeedMult, 0, 100)
				end
				local WaterLoss = math.Clamp(1 - Water, .05, 1) * 2.5 * JMod.Config.ResourceEconomy.WaterRequirementMult
				self.Hydration = math.Clamp(self.Hydration - WaterLoss, 0, 100)
			else
				self.Helf = math.Clamp(self.Helf - 2, 0, 100)
			end
			self:UpdateAppearance()
		end
		if (self.Growth >= 100 and self.Helf >= 76 and self.Hydration >= 60) then
			local DropPos = SelfPos + self:GetUp() * 200 + Vector(math.random(-80, 80), math.random(-80, 80), 0)
			if (math.random(1, 2) == 1) then
				local Leaf = EffectData()
				Leaf:SetOrigin(DropPos)
				util.Effect("eff_jack_gmod_ezleaf", Leaf, true, true)
			end
			if (math.random(1, 30) == 2) then
				local Apol = ents.Create("ent_jack_gmod_ezapple")
				Apol:SetPos(DropPos)
				JMod.SetEZowner(Apol, Owner)
				Apol:Spawn()
				Apol:Activate()
				Apol:GetPhysicsObject():SetVelocity(Vel)
				Apol.EZremoveSelf = true
			end
			if (math.random(1, 60) == 10) then
				local Apol = ents.Create("ent_jack_gmod_ezacorn")
				Apol:SetPos(DropPos)
				JMod.SetEZowner(Apol, Owner)
				Apol:Spawn()
				Apol:Activate()
				Apol:GetPhysicsObject():SetVelocity(Vel)
				Apol.EZremoveSelf = true
			end
		end
		--
		self:NextThink(Time + math.Rand(2, 4))
		return true
	end

	function ENT:UpdateAppearance()
		local NewLeafMat, NewBarkMat, NewModel
		local WillDehydrate, WillReachMaturity = false, false
		-- my kingdom for Switch statements
		if (self.Growth < 33) then
			NewModel = "tree0.mdl"
		elseif (self.Growth < 66) then
			NewModel = "tree1.mdl"
		else
			NewModel = "tree2.mdl"
			WillReachMaturity = true
		end
		if (self.Hydration < 10) then
			NewLeafMat = "oak_leaf2"
		elseif (self.Hydration < 30) then
			NewLeafMat = "oak_leaf1"
			if self.OldHydration and self.OldHydration > self.Hydration then
				WillDehydrate = true
			end
		elseif (self.Hydration < 60) then
			NewLeafMat = "oak_leaf0"
		else
			NewLeafMat = "oak_leaf3"
		end
		if (self.Helf < 75) then
			NewBarkMat = "oak_bark1"
		else
			NewBarkMat = "oak_bark0"
		end
		NewModel = "models/jmod/props/" .. NewModel
		NewLeafMat = "models/jmod/props/" .. NewLeafMat
		NewBarkMat = "models/jmod/props/" .. NewBarkMat
		--
		if (NewModel ~= self.LastModel) then
			self:SetModel(NewModel)
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
			self.LastModel = NewModel
			self:TryPlant()
			if (WillReachMaturity) then
				JMod.Hint(JMod.GetEZowner(self), "tree mature")
			end
		end
		timer.Simple(0, function()
			if (IsValid(self)) then
				if (NewBarkMat ~= self.LastBarkMat) then
					self:SetSubMaterial(0, NewBarkMat)
					self.LastBarkMat = NewBarkMat
				end
				if (NewLeafMat ~= self.LastLeafMat) then
					self:SetSubMaterial(1, NewLeafMat)
					self.LastLeafMat = NewLeafMat
					if (WillDehydrate) then
						JMod.Hint(JMod.GetEZowner(self), "plant water")
					end
				end
			end
		end)
		self.OldHydration = self.Hydration
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		self.NextGrowThink = Time + math.random(10, 11)
		timer.Simple(0.1, function()
			if IsValid(self) then
				self.LastModel = ""
				self:UpdateAppearance()
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
