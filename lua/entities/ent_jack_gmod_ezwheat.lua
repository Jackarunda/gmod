AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "EZ Wheat"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.Spawnable = false -- For now...
ENT.Base = "ent_jack_gmod_ezcrop_base"
ENT.Model = "models/jmod/props/plants/razorgrain_pile.mdl"
--
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.SpawnHeight = 0
ENT.EZconsumes = nil
ENT.EZupgradable = false
--
ENT.StaticPerfSpecs = {
	MaxWater = 100,
	MaxDurability = 100
}
--
ENT.NextCutTime = 0

function ENT:CustomSetupDataTables()
	-- we will indicate status through other means
end

if(SERVER)then
	function ENT:CustomInit()
		self.Growth = 0
		self.Hydration = self.Hydration or 100
		self.Helf = 100
		self.LastWheatMat = ""
		self.LastSubModel = 0
		self.NextGrowThink = 0
		self.Mutated = false
		self.IsPlanting = false
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.WATER}
		self:UpdateAppearance()
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(1)
		end
	end

	function ENT:Mutate()
		if (self.Mutated) then return end
		self.Mutated = true
		self.EZconsumes = {JMod.EZ_RESOURCE_TYPES.PROPELLANT}
		self:SetTrigger(true)
		self:UseTriggerBounds(true, 0)
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed = true
		self:EmitSound("Dirt.Impact")

		if not(self:IsOnFire() or (dmginfo and (dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_SLOWBURN)))) then
			local SpawnPos = Vector(0, 0, 100)
			local FoodAmt = 0
			if (self.Growth >= 66) then
				FoodAmt = 100
			elseif (self.Growth >= 33) then
				FoodAmt = 50
			else
				FoodAmt = 25
			end

			if (FoodAmt > 0) then
				local Seedy = ents.Create("ent_jack_gmod_ezwheatseed")
				Seedy:SetPos(self:LocalToWorld(SpawnPos + VectorRand(-50, 50)))
				Seedy:SetAngles(AngleRand())
				Seedy:Spawn()
				Seedy:Activate()
				if (self.Mutated) then
					JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.AMMO, FoodAmt / 2, SpawnPos, Angle(0, 0, 0), nil, false)
					if math.random(1, 2) == 1 then
						Seedy:Mutate()
					end
				else
					JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.ORGANICS, FoodAmt, SpawnPos, Angle(0, 0, 0), nil, false)
				end
			end
		end

		SafeRemoveEntityDelayed(self, 0)
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed > 20) and (data.DeltaTime > 0.2) then
			self:EmitSound("snds_jack_gmod/ez_foliage/grass_brush_" .. math.random(1, 7) .. ".ogg", 65, math.random(90, 110), .5)
		end
		--[[if (self.Mutated) and (data.Speed > 30) and (data.DeltaTime > 0.2) and IsValid(data.HitEntity) and (data.HitEntity:IsPlayer()) then
			local PlyToCut = data.HitEntity
			local Cut = DamageInfo()
			Cut:SetDamage(2)
			Cut:SetDamageType(DMG_SLASH)
			Cut:SetDamageForce(-data.TheirOldVelocity*1.1)
			Cut:SetDamagePosition(data.HitPos + self:GetUp() * 32)
			PlyToCut:TakeDamageInfo(Cut)
			PlyToCut:SetVelocity(-data.TheirOldVelocity*.9)
			PlyToCut:ViewPunch(Angle(0, 0, math.random(-8, 8)))
			self:EmitSound("npc/headcrab/headbite.wav", 100, 100)
		end--]]
	end

	function ENT:Touch(ply)
		if not self.Mutated then return end
		if not(IsValid(ply) and (ply:IsPlayer() or ply:IsNPC() or ply:IsNextBot())) then return end
		local Time = CurTime()
		if (self.NextCutTime > Time) then return end
		local TheirVel = ply:GetVelocity()
		local TheirSpeed = TheirVel:Length()
		if TheirSpeed < 30 then return end
		local Cut = DamageInfo()
		Cut:SetDamage(2)
		Cut:SetDamageType(DMG_SLASH)
		Cut:SetDamageForce(-TheirVel*1.1)
		Cut:SetDamagePosition(ply:GetPos() + self:GetUp() * 32)
		Cut:SetInflictor(self)
		Cut:SetAttacker(JMod.GetEZowner(self))
		ply:TakeDamageInfo(Cut)
		ply:SetVelocity(-TheirVel*.9)
		if ply:IsPlayer() then
			ply:ViewPunch(Angle(0, 0, math.random(-8, 8)))
		end
		self:EmitSound("npc/headcrab/headbite.wav", 100, 100)

		JMod.EZimmobilize(ply, 1, self)
		self.NextCutTime = Time + 1
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
					local HitAngle = Tr.HitNormal:Angle()
					HitAngle:RotateAroundAxis(HitAngle:Right(), -90)
					HitAngle:RotateAroundAxis(Tr.HitNormal, math.random(0,  360))
					self:SetAngles(HitAngle)
					--self:SetAngles(Angle(0, math.random(0, 360, 0)))
					self:SetPos(Tr.HitPos + Tr.HitNormal * 1)
					
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
		--jprint(self.Helf, self.EZinstalled, self.GroundWeld)
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
					self.Growth = math.Clamp(self.Growth + Growth * JMod.Config.ResourceEconomy.GrowthSpeedMult, 0, (self.Mutated and 65) or 100)
				end
				local WaterLoss = math.Clamp(1 - Water, .05, 1) * JMod.Config.ResourceEconomy.WaterRequirementMult
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



	function ENT:UpdateAppearance()
		local NewWheatMat, NewSubModel, WheatColor
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
			WheatColor = Color(222, 228, 168)
		else
			NewWheatMat = "razorgrain_d"
			WheatColor = Color(207, 228, 168)
		end
		if self.Mutated then
			WheatColor = Color(180, 184, 145)
		end
		if WheatColor then
			self:SetColor(WheatColor)
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
