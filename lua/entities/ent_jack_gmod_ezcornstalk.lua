-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Cornstalk"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = false -- For now...
ENT.Base = "ent_jack_gmod_ezcrop_base"
ENT.Model = "models/jmod/props/plants/corn_stalk01.mdl"
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 0
ENT.EZconsumes = nil
ENT.EZupgradable = false
--
ENT.StaticPerfSpecs = {
	MaxWater = 50,
	MaxDurability = 100
}

if(SERVER)then
	function ENT:CustomInit()
		self.Growth = 0
		self.Hydration = self.Hydration or 0
		self.Helf = 100
		self.LastWheatMat = ""
		self.LastSubModel = 0
		self.NextGrowThink = 0
		self.IsPlanting = false
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
		self:UpdateAppearance()
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1)
		end
		if self.Mutated then self:Mutate() end
	end

	function ENT:Mutate()
		if (self.Mutated) then return end
		self.Mutated = true
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.CHEMICALS}
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Dirt.Impact")

		self:ProduceResource(true)
		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:ProduceResource(destroyed)
		local SpawnPos = Vector(0, 0, 50)
		if (self.Growth >= 66) then
			for i = 1, math.random(1, 3) do
				local Corn = ents.Create("ent_jack_gmod_ezcornear")
				Corn:SetPos(self:GetPos() + (SpawnPos*i) + VectorRand(-10, 10))
				Corn:SetAngles(AngleRand())
				Corn.Mutated = self.Mutated
				Corn:Spawn()
				Corn:Activate()
			end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed > 20) and (data.DeltaTime > 0.2) then
			self:EmitSound("snds_jack_gmod/ez_foliage/plant_brush_" .. math.random(1, 12) .. ".ogg", 65, math.random(90, 110), .8)
		end
	end

	function ENT:TryPlant()
		self.InstalledMat = nil
		self.IsPlanting = true -- Flag to prevent destruction during planting
		local Tr = util.QuickTrace(self:GetPos() + Vector(0, 0, 100), Vector(0, 0, -200), self)
		if (Tr.Hit) then
			self.InstalledMat = Tr.MatType
			if not (table.HasValue(self.UsableMats, self.InstalledMat)) then self:Destroy() return end
			if (self:WaterLevel() > 0) then self:Destroy() return end
			self.EZinstalled = true
			--util.Decal("EZtreeRoots", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			timer.Simple(.1, function()
				if (IsValid(self)) then
					--[[local HitAngle = Tr.HitNormal:Angle()
					HitAngle:RotateAroundAxis(HitAngle:Right(), -90)
					HitAngle:RotateAroundAxis(Tr.HitNormal, math.random(0,  360))
					self:SetAngles(HitAngle)--]]
					self:SetAngles(Angle(0, math.random(0, 360, 0)))
					self:SetPos(Tr.HitPos)
					
					-- Remove any existing constraints before creating new ones
					constraint.RemoveAll(self)
					
					self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 5000, true)
					local phys = self:GetPhysicsObject()
					if IsValid(phys) then
						phys:Sleep()
					end
					self.IsPlanting = false -- Clear planting flag
					JMod.Hint(JMod.GetEZowner(self), "tree growth")
				end
			end)
		else
			self.IsPlanting = false
			self:Destroy()
		end
	end

	function ENT:Think()
		if (self.Helf <= 0) then self:Destroy() return end
		-- Don't check planting status if crop is in the process of being planted
		if not self.IsPlanting then
			-- Check if crop is properly planted - should have a valid weld
			if (self.EZinstalled and not(IsValid(self.GroundWeld))) then 
				self:Destroy() 
				return 
			end
		end
		local Time, SelfPos = CurTime(), self:GetPos()
		if (self.NextGrowThink < Time) then
			self.NextGrowThink = Time + math.random(9, 11)
			local Water, Light, Sky, Ground = self:GetWaterProximity(), self:GetDayLight(), self:CheckSky(SelfPos + self:GetUp() * 10), 1
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
				local Growth = Light * Sky * Ground * 2
				if (self.Helf < 100) then -- heal
					self.Helf = math.Clamp(self.Helf + Growth * JMod.Config.ResourceEconomy.GrowthSpeedMult, 0, 100)
				else
					self.Growth = math.Clamp(self.Growth + Growth * JMod.Config.ResourceEconomy.GrowthSpeedMult, 0, 100)
				end
				if self.Growth > 66 then
					--if (math.random(1, 2) == 1) then
						local Leaf = EffectData()
						Leaf:SetOrigin(SelfPos + Vector(0, 0, 100))
						if (self.Mutated) then
							Leaf:SetStart(Vector(131, 200, 70)) -- This is actually just a sneaky color
						end
						util.Effect("eff_jack_gmod_ezcorndust", Leaf, true, true)
					--end
				end
				local WaterLoss = math.Clamp(1 - Water, .05, 1) * JMod.Config.ResourceEconomy.WaterRequirementMult
				self.Hydration = math.Clamp(self.Hydration - WaterLoss, 0, 100)
			else
				self.Helf = math.Clamp(self.Helf - 1, 0, 100)
			end
			self:UpdateAppearance()
		end
		--
		if self.Mutated and (math.random(0, 2) == 1) then
			local Target = self:FindTarget()
			if (IsValid(Target) and not self:IsLocationBeingWatched(SelfPos)) then 
				if (SelfPos:Distance(Target:GetPos()) <= 120) then 
					if (JMod.ShouldDamageBiologically(Target) and (math.random(1, 10) == 1)) then 
						self:Gas(Target)
					end
				else
					local RandVec = Vector(math.random(-1, 1), math.random(-1, 1), 0) * 100
					local DesiredPosition = Target:GetPos() + RandVec
					local Moved = self:TryMoveTowardPoint(DesiredPosition)

					if not(Moved) then
						self:TryMoveRandomly()
					end
				end
			end
		end
		--
		self:NextThink(Time + math.Rand(2, 4))
		return true
	end



	function ENT:Gas(obj)
		local Dmg, Helf = DamageInfo(), obj:Health()
		Dmg:SetDamageType(DMG_NERVEGAS)
		Dmg:SetDamage(math.random(2, 8) * JMod.Config.Particles.PoisonGasDamage)
		Dmg:SetInflictor(self)
		Dmg:SetAttacker(JMod.GetEZowner(self) or self)
		Dmg:SetDamagePosition(obj:GetPos())
		obj:TakeDamageInfo(Dmg)

		if (obj:Health() < Helf) and obj:IsPlayer() then
			JMod.Hint(obj, "gas damage")
			JMod.TryCough(obj)
		end
	end

	--[[ START GNOME CODE ]]--
	function ENT:FindTarget()
		local SelfPos = self:GetPos()
		if IsValid(self.StalkTarget) then
			return self.StalkTarget
		else
			local RandomTarg = table.Random(ents.FindByClass("ent_jack_gmod_ezsprinkler"))
			for k, v in player.Iterator() do
				if not(IsValid(RandomTarg)) then
					RandomTarg = v
				elseif SelfPos:DistToSqr(RandomTarg:GetPos()) < SelfPos:DistToSqr(v:GetPos()) then
					RandomTarg = v
					break
				end
			end
			self.StalkTarget = RandomTarg
			return RandomTarg
		end
		return nil
	end

	function ENT:FindGroundAt(pos)
		local Tr = util.QuickTrace(pos + Vector(0, 0, 30), Vector(0, 0, -300), {self})

		if Tr.Hit and not Tr.StartSolid then return Tr.HitPos end

		return nil
	end

	function ENT:IsLocationClear(pos)
		local Tr = util.QuickTrace(pos + Vector(0, 0, 100), Vector(0, 0, -200), self)
		if (Tr.Hit) then
			self.InstalledMat = Tr.MatType
			return (table.HasValue(self.UsableMats, self.InstalledMat))
		end
		return false
	end

	function ENT:TryMoveTowardPoint(pos)
		local SelfPos = self:GetPos()
		local Dir = (pos - SelfPos):GetNormalized()
		local NewPos = SelfPos + Dir * 100 * (self.Restlessness or 2)
		local NewGroundPos = self:FindGroundAt(NewPos)

		if NewGroundPos then
			if not self:IsLocationBeingWatched(NewGroundPos) and not self:IsLocationBeingWatched(SelfPos) then
				if self:IsLocationClear(NewGroundPos) then
					self:SnapTo(NewGroundPos)

					return true
				end
			end
		end

		return false
	end

	function ENT:TryMoveRandomly()
		local SelfPos = self:GetPos()
		local Dir = VectorRand()
		local NewPos = SelfPos + Dir * 50 * 1
		local NewGroundPos = self:FindGroundAt(NewPos)

		if NewGroundPos then
			if not self:IsLocationBeingWatched(NewGroundPos) then
				if self:IsLocationClear(NewGroundPos) then
					self:SnapTo(NewGroundPos)

					return true
				end
			end
		end

		return false
	end

	function ENT:SnapTo(pos)
		constraint.RemoveAll(self)
		local Yaw = (pos - self:GetPos()):GetNormalized():Angle().y
		self:SetPos(pos)
		self:SetAngles(Angle(0, Yaw, 0))
		self:TryPlant()
	end

	function ENT:IsLocationBeingWatched(pos)
		--if(true)then return false end
		local PotentialObservers = table.Merge(ents.FindByClass("gmod_cameraprop"), player.GetAll())

		for k, obs in pairs(PotentialObservers) do
			local ObsPos = (obs.GetShootPos and obs:GetShootPos()) or obs:GetPos()
			local DirectVec = ObsPos - pos
			local DirectDir = DirectVec:GetNormalized()
			local FacingDir = (obs.GetAimVector and obs:GetAimVector()) or obs:GetForward()
			local ApproachAngle = -math.deg(math.asin(DirectDir:Dot(FacingDir)))

			if ApproachAngle > 30 then
				local Dist = DirectVec:Length()

				if Dist < 5000 then
					local Tr = util.TraceLine({
						start = pos,
						endpos = ObsPos,
						filter = {self, obs},
						mask = MASK_SHOT - CONTENTS_WINDOW
					})
					local Tr2 = util.TraceLine({
						start = pos + Vector(0, 0, 50),
						endpos = ObsPos,
						filter = {self, obs},
						mask = MASK_SHOT - CONTENTS_WINDOW
					})

					if not Tr.Hit and not Tr2.Hit then return true end
				end
			end
		end

		return false
	end
	--[[ END GNOME CODE ]]--

	function ENT:Use(activator)
		local Alt = JMod.IsAltUsing(activator)
		if Alt and (self.Growth >= 66) then
			self:ProduceResource(false)
			self:Remove()
			--[[self.Growth = 30
			self.Helf = 33
			self:UpdateAppearance()]]--
		end
	end

	function ENT:UpdateAppearance()
		local NewCornMat, NewSubModel, CornColor
		-- my kingdom for Switch statements
		if (self.Growth < 33) then
			NewSubModel = 2
		elseif (self.Growth < 66) then
			NewSubModel = 1
		else
			NewSubModel = 0
		end

		if (self.Hydration < 30) then
			NewCornMat = "cornstalkdry"
		else
			NewCornMat = "cornstalk"
		end

		if (self.Helf < 25) then
			CornColor = Color(145, 141, 93)
		else
			CornColor = Color(255, 255, 255)
		end

		if self.Mutated then
			CornColor = Color(180, 184, 145)
			NewCornMat = "cornstalk"
		end
		if CornColor then
			self:SetColor(CornColor)
		end

		NewCornMat = "models/jmod/props/plants/" .. NewCornMat
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
				if (NewCornMat ~= self.LastWheatMat) then
					self:SetSubMaterial(0, NewCornMat)
					self.LastWheatMat = NewCornMat
				end
			end
		end)
	end
elseif CLIENT then
	local Roots = Material("decals/ez_tree_roots")
	function ENT:CustomInit()
		--
	end
	function ENT:DrawTranslucent()
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
	language.Add("ent_jack_gmod_ezcornstalk", "EZ Corn")
end
