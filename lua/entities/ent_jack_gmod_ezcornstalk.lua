-- AdventureBoots 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "EZ Corn"
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
--
ENT.StaticPerfSpecs = {
	MaxWater = 100,
	MaxDurability = 100
}

function ENT:CustomSetupDataTables()
	-- we will indicate status through other means
end

if(SERVER)then
	function ENT:CustomInit()
		self.EZupgradable = false
		self.Growth = 0
		self.Hydration = self.Hydration or 100
		self.Helf = 100
		self.LastWheatMat = ""
		self.LastSubModel = 0
		self.NextGrowThink = 0
		self.Mutated = false
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
		self:UpdateAppearance()
		self:UseTriggerBounds(true, 0)
	end

	function ENT:Mutate()
		if (self.Mutated) then return end
		self.Mutated = true
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.EXPLOSIVES}
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Dirt.Impact")

		self:ProduceResource(true)
		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:ProduceResource(destroyed)
		local SpawnPos = Vector(0, 0, 100)
		if (self.Growth >= 66) then
			--JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.ORGANICS, 50, SpawnPos, Angle(0, 0, 0), nil, false)
			if self.Mutated then
				JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.MUNITIONS, math.random(10, 30), SpawnPos, Angle(0, 0, 0), nil, false)
			else
				for i = 1, math.random(1, 3) do
					local Corn = ents.Create("ent_jack_gmod_ezcornear")
					Corn:SetPos(SpawnPos + VectorRand(-10, 10))
					Corn:SetAngles(AngleRand())
					Corn:Spawn()
					Corn:Activate()
				end
			end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		--jprint("Cutting colision", data.DeltaTime)
		if (data.Speed > 80) and (data.DeltaTime > 0.2) then
			self:EmitSound("Dirt.Impact", 100, 80)
			self:EmitSound("Dirt.Impact", 100, 80)
			if IsValid(data.HitObject) then
				local TheirForce = (.5 * data.HitObject:GetMass() * ((data.TheirOldVelocity:Length()/16)*0.3048)^2)
				local ForceThreshold = physobj:GetMass() * 10 * self.Growth
				local PhysDamage = TheirForce/(physobj:GetMass()*100)

				if PhysDamage >= 1 then
					local CrushDamage = DamageInfo()
					CrushDamage:SetDamage(math.floor(PhysDamage))
					CrushDamage:SetDamageType(DMG_CRUSH)
					--CrushDamage:SetDamageForce(data.TheirOldVelocity / 1000)
					CrushDamage:SetDamagePosition(data.HitPos)
					self:TakeDamageInfo(CrushDamage)
				end
			end
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
					if Tr.Entity == game.GetWorld() then
						self:GetPhysicsObject():EnableMotion(false)
						--self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
					else
						self.GroundWeld = constraint.Weld(self, Tr.Entity, 0, 0, 50000, true)
						self:GetPhysicsObject():Sleep()
					end
					JMod.Hint(self.EZowner, "tree growth")
				end
			end)
		else
			self:Remove()
		end
	end

	function ENT:Think()
		if (self.Helf <= 0) then self:Destroy() return end
		if (self.EZinstalled and not(IsValid(self.GroundWeld) or not(self:GetPhysicsObject():IsMotionEnabled()))) then self:Destroy() return end
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
					self.Helf = math.Clamp(self.Helf + Growth, 0, 100)
				else
					self.Growth = math.Clamp(self.Growth + Growth, 0, 100)
				end
				local WaterLoss = math.Clamp(1 - Water, .05, 1)
				self.Hydration = math.Clamp(self.Hydration - WaterLoss, 0, 100)
			else
				self.Helf = math.Clamp(self.Helf - 1, 0, 100)
			end
			self:UpdateAppearance()
		end
		--
		self:NextThink(Time + math.Rand(2, 4))
		return true
	end

	function ENT:Use(activator)
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
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
			NewCornMat = "corn01t_d"
		elseif (self.Hydration < 60) then
			NewCornMat = "cornv81t_d"
		else
			NewCornMat = "cornv81t_d"
		end

		if (self.Helf < 25) then
			CornColor = Color(145, 141, 93)
		end

		if self.Mutated then
			CornColor = Color(180, 184, 145)
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
