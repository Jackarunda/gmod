-- Jackarunda 2021
AddCSLuaFile()
SWEP.PrintName = "EZ Toolbox"
SWEP.Author = "Jackarunda"
SWEP.Purpose = ""
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_eztoolbox")
SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.EZdroppable = true
SWEP.ViewModel = "models/jmod/ez/c_repairkit.mdl" --"models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/jmod/ez/c_repairkit.mdl" --"models/props_c17/tools_wrench01a.mdl"
SWEP.BodyHolsterModel = "models/weapons/w_models/w_tooljox.mdl"
SWEP.BodyHolsterSlot = "hips"
SWEP.BodyHolsterAng = Angle(-70, 0, 200)
SWEP.BodyHolsterAngL = Angle(-70, -10, -30)
SWEP.BodyHolsterPos = Vector(0, -15, 10)
SWEP.BodyHolsterPosL = Vector(0, -15, -11)
SWEP.BodyHolsterScale = .4
SWEP.ViewModelFOV = 52
SWEP.Slot = 0
SWEP.SlotPos = 5
SWEP.InstantPickup = true -- Fort Fights compatibility
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ShowWorldModel = true
SWEP.EZconsumes = {JMod.EZ_RESOURCE_TYPES.POWER, JMod.EZ_RESOURCE_TYPES.GAS}
SWEP.MaxElectricity = 100
SWEP.MaxGas = 100

SWEP.VElements = {
	--[[["wrench"] = {
		type = "Model",
		model = "models/props_c17/tools_wrench01a.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(3.5, 1.5, 0),
		angle = Angle(0, 90, -90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	["pliers"] = {
		type = "Model",
		model = "models/props_c17/tools_pliers01a.mdl",
		bone = "ValveBiped.Bip01_L_Hand",
		rel = "",
		pos = Vector(2.8, 2.4, -2.5),
		angle = Angle(0, 180, 90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}--]]
}

SWEP.WElements = {
	["saw"] = {
		type = "Model",
		model = "models/props_forest/circularsaw01.mdl",
		bone = "ValveBiped.Bip01_Spine",
		rel = "",
		pos = Vector(-6.753, -0.519, 10.909),
		angle = Angle(104.026, -12.858, -157.793),
		size = Vector(0.75, 0.75, 0.75),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	--[[["wrench"] = {
		type = "Model",
		model = "models/props_c17/tools_wrench01a.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(2.596, 1, 3.635),
		angle = Angle(0, -90, -90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	["pliers"] = {
		type = "Model",
		model = "models/props_c17/tools_pliers01a.mdl",
		bone = "ValveBiped.Bip01_L_Hand",
		rel = "",
		pos = Vector(4.675, 0, -1.558),
		angle = Angle(0, 0, 90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},--]]
	["torch"] = {
		type = "Model",
		model = "models/props_silo/welding_torch.mdl",
		bone = "ValveBiped.Bip01_Spine",
		rel = "",
		pos = Vector(-1.558, 2.596, -8.832),
		angle = Angle(180, 26.882, 38.57),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	--[[["pickaxe"] = {
		type = "Model",
		model = "models/props_mining/pickaxe01.mdl",
		bone = "ValveBiped.Bip01_Spine4",
		rel = "",
		pos = Vector(-22.338, 2.596, -1.558),
		angle = Angle(-92.338, 0, 0),
		size = Vector(0.75, 0.75, 0.75),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},--]]
	["mask"] = {
		type = "Model",
		model = "models/props_silo/welding_helmet.mdl",
		bone = "ValveBiped.Bip01_Head1",
		rel = "",
		pos = Vector(2, 4, 0),
		angle = Angle(90, -20, 0),
		size = Vector(1.1, 1.1, 1.1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	--[[["axe"] = {
		type = "Model",
		model = "models/props_forest/axe.mdl",
		bone = "ValveBiped.Bip01_Spine4",
		rel = "",
		pos = Vector(-7.792, 2, 4),
		angle = Angle(118.052, 87.662, 180),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},--]]
	["toolbox"] = {
		type = "Model",
		model = "models/weapons/w_models/w_tooljox.mdl",
		bone = "ValveBiped.Bip01_Spine4",
		rel = "",
		pos = Vector(-7, 6, 0.518),
		angle = Angle(-180, 85.324, 87.662),
		size = Vector(0.5, 0.5, 0.5),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	["pack1"] = {
		type = "Model",
		model = "models/weapons/w_defuser.mdl",
		bone = "ValveBiped.Bip01_Spine",
		rel = "",
		pos = Vector(-4.676, -7.792, 0),
		angle = Angle(180, 108.7, 90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},
	["pack2"] = {
		type = "Model",
		model = "models/weapons/w_defuser.mdl",
		bone = "ValveBiped.Bip01_Spine",
		rel = "",
		pos = Vector(-3.636, 3.635, 0),
		angle = Angle(3.506, 68.96, 90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
}

SWEP.LastSalvageAttempt = 0
SWEP.NextSwitch = 0

function SWEP:Initialize()
	self:SetHoldType("fist")
	self:SCKInitialize()
	self.NextIdle = 0
	self:Deploy()
	self:SetSelectedBuild("")
	self:SetTaskProgress(0)
	self.TaskEntity = nil
	self.NextTaskProgress = 0
	self.CurTask = nil
	self.CurrentBuildSize = 1
	self.ModifcationCost = 20

	if SERVER then
		self.Craftables = {}

		for name, info in pairs(JMod.Config.Craftables) do
			if (istable(info.craftingType) and table.HasValue(info.craftingType,"toolbox")) or (info.craftingType=="toolbox")then
				-- we store this here for client transmission later
				-- because we can't rely on the client having the config
				local infoCopy = table.FullCopy(info)
				infoCopy.name = name
				self.Craftables[name] = info
			end
		end
	end

	self:SetGas(0)
	self:SetElectricity(0)
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	--vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:ViewModelDrawn()
	self:SCKViewModelDrawn()
end

function SWEP:DrawWorldModel()
	self:SCKDrawWorldModel()
end

local Downness = 0

function SWEP:GetViewModelPosition(pos, ang)
	local FT = FrameTime()

	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		Downness = Lerp(FT * 2, Downness, 10)
	else
		Downness = Lerp(FT * 2, Downness, 0)
	end

	ang:RotateAroundAxis(ang:Right(), -Downness * 5)

	return pos, ang
end

function SWEP:SetupDataTables()
	self:NetworkVar("String", 0, "SelectedBuild")
	self:NetworkVar("Float", 1, "TaskProgress")
	self:NetworkVar("Int", 0, "Electricity")
	self:NetworkVar("Int", 1, "Gas")
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self.NextIdle = CurTime() + vm:SequenceDuration()
end

function SWEP:GetEZsupplies(resourceType, getter)
	local BuildSizeMult = self.CurrentBuildSize or 1
	if IsValid(getter) and getter == self then BuildSizeMult = 0 end
	local AvailableResources = {
		[JMod.EZ_RESOURCE_TYPES.POWER] = self:GetElectricity(),
		[JMod.EZ_RESOURCE_TYPES.GAS] = self:GetGas()
	}
	if resourceType then
		if AvailableResources[resourceType] and AvailableResources[resourceType] > 0 then
			return AvailableResources[resourceType]
		else
			return nil
		end
	else
		return AvailableResources
	end
end

function SWEP:SetEZsupplies(typ, amt, setter)
	if not SERVER then  return end
	local ResourceSetMethod = self["Set"..JMod.EZ_RESOURCE_TYPE_METHODS[typ]]
	if ResourceSetMethod then
		ResourceSetMethod(self, math.Clamp(amt, 0, self["Max"..JMod.EZ_RESOURCE_TYPE_METHODS[typ]] or 100))
	end
end

function SWEP:DetermineBuildPos(zOffset)
	local BuildInfo = self.EZpreview or {sizeScale = 1}
	BuildInfo.SpawnAngles = BuildInfo.SpawnAngles or Angle(0, 0, 0)
	local Ent, Pos, Norm = self:WhomIlookinAt(math.max((BuildInfo.sizeScale or self.CurrentBuildSize) * 30, 100))
	if not BuildInfo then return Ent, Pos, Norm, BuildInfo.SpawnAngles end

	local BuildBoundingBox = {
		mins = Vector(-1, -1, -1),
		maxs = Vector(1, 1, 1)
	}
	if BuildInfo.Box then
		BuildBoundingBox = BuildInfo.Box
	elseif BuildInfo.sizeScale then
		BuildBoundingBox.mins = BuildBoundingBox.mins * BuildInfo.sizeScale
		BuildBoundingBox.maxs = BuildBoundingBox.maxs * BuildInfo.sizeScale
	end

	local SpawnAngle = BuildInfo.SpawnAngles:GetCopy()
	local ForwardDir = SpawnAngle:Forward()
	local ForwardExtent = math.max(math.abs(ForwardDir.x * BuildBoundingBox.maxs.x), math.abs(ForwardDir.x * BuildBoundingBox.mins.x))
	ForwardExtent = math.max(ForwardExtent, math.abs(ForwardDir.y * BuildBoundingBox.maxs.y))
	ForwardExtent = math.max(ForwardExtent, math.abs(ForwardDir.y * BuildBoundingBox.mins.y))

	debugoverlay.Cross(Pos, 5, .2, Color(255, 255, 255), true)
	local WallTrDir = Angle(0, self.Owner:GetAngles().y, 0):Forward()
	local WallTrace = util.TraceLine({
		start = Pos,
		endpos = Pos + WallTrDir * ForwardExtent,
		filter = self.Owner
	})

	if WallTrace.Hit then
		debugoverlay.Cross(WallTrace.HitPos, 5, .2, Color(255, 0, 0), true)
		local Difference = Pos - WallTrace.HitPos
		Difference.z = 0
		Pos = Pos - WallTrDir * (ForwardExtent - Difference:Length())
		Norm = WallTrace.HitNormal
	end

	local FloorTrace = util.TraceLine({
		start = Pos,
		endpos = Pos - Vector(0, 0, math.abs(BuildBoundingBox.mins.z)),
		filter = self.Owner
	})

	if FloorTrace.Hit then
		local Difference = Pos - FloorTrace.HitPos
		debugoverlay.Cross(FloorTrace.HitPos, 5, .2, Color(200, 255, 0), true)
		Pos = Pos + Vector(0, 0, math.abs(BuildBoundingBox.mins.z) - Difference.z)
		Norm = FloorTrace.HitNormal
	end

	if (zOffset) then Pos = Pos + Vector(0, 0, zOffset) end

	return Ent, Pos, Norm, SpawnAngle + Angle(0, self.Owner:GetAngles().y, 0)
end

function SWEP:BuildItem(selectedBuild)
	local Built = false
	local BuildInfo = self.Craftables[selectedBuild]
	local Ent, Pos, Norm, SpawnAngle = self:DetermineBuildPos(BuildInfo.buildZoffset)
	if not BuildInfo then return end
	local MaxElecConsume, MaxGasConsume = 40, 30
	if not(self:GetElectricity() >= math.min(4 * (BuildInfo.sizeScale or 1), MaxElecConsume)) or not(self:GetGas() >= math.min(3 * (BuildInfo.sizeScale or 1), MaxGasConsume)) then
		self:Msg("   You need to refill your gas and/or power\nPress Reload on gas or batteries to refill")
		return
	end
	local Sound = not BuildInfo.noSound
	local Reqs = table.FullCopy(BuildInfo.craftingReqs)
	local ConsumePos = self.Owner:GetShootPos()

	if JMod.HaveResourcesToPerformTask(ConsumePos, nil, Reqs, self) then
		local override, msg, mult = hook.Run("JMod_CanKitBuild", self.Owner, self, BuildInfo)

		if override ~= nil and override == false then
			self:Msg(msg or "cannot build")

			return
		elseif mult and not(JMod.HaveResourcesToPerformTask(ConsumePos, nil, Reqs, self, nil, mult)) then
			self:Msg("Insufficient resources to finish build")

			return
		end
		local SuccessfulConsume = JMod.ConsumeResourcesInRange(Reqs, ConsumePos, nil, self, false, nil, mult or 1)

		Built = true
		local BuildSteps = math.ceil(20 * (BuildInfo.sizeScale or 1))

		self:SetElectricity(self:GetElectricity() - math.Clamp(4 * (BuildInfo.sizeScale or 1), 0, MaxElecConsume))
		self:SetGas(self:GetGas() - math.Clamp(3 * (BuildInfo.sizeScale or 1), 0, MaxGasConsume))

		for i = 1, BuildSteps do
			timer.Simple(i / 100, function()
				if IsValid(self) then
					if i < BuildSteps then
						if Sound then
							sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".ogg", Pos, 60, math.random(80, 120))
						end
					else
						local Class = BuildInfo.results
						local StringParts = string.Explode(" ", Class)
						if StringParts[1] and (StringParts[1] == "FUNC") then
							local FuncName = StringParts[2]

							if JMod.LuaConfig and JMod.LuaConfig.BuildFuncs and JMod.LuaConfig.BuildFuncs[FuncName] then
								JMod.LuaConfig.BuildFuncs[FuncName](self.Owner, Pos, SpawnAngle)
							else
								print("JMOD TOOLBOX ERROR: JMod.LuaConfig is missing, corrupt, or doesn't have an entry for that build function")
							end
						else
							local Ent
							if string.Right(Class, 4) == ".mdl" then
								Ent = ents.Create("prop_physics")
								Ent:SetModel(Class)
								timer.Simple(0, function()
									if IsValid(Ent) and IsValid(Ent:GetPhysicsObject()) then
										if BuildInfo.mass then
											Ent:GetPhysicsObject():SetMass(BuildInfo.mass)
										end
										Ent:GetPhysicsObject():Sleep()
									end
								end)
							else
								Ent = ents.Create(Class)
							end
							Ent:SetPos(Pos)
							Ent:SetAngles(SpawnAngle)
							JMod.SetEZowner(Ent, self.Owner)
							Ent:SetCreator(self.Owner)
							Ent:Spawn()
							Ent:Activate()
							hook.Run("JMod_OnRecipeCrafted", self.Owner, self, Ent, selectedBuild)
							if BuildInfo.skin then
								if istable(BuildInfo.skin) then
									Ent:SetSkin(table.Random(BuildInfo.skin))
								else
									Ent:SetSkin(BuildInfo.skin)
								end
							end
							if BuildInfo.color and istable(BuildInfo.color) then
								Ent:SetColor(Color(BuildInfo.color.r, BuildInfo.color.g, BuildInfo.color.b))
							end
							if BuildInfo.material then
								Ent:SetMaterial(BuildInfo.material)
							end
							if BuildInfo.subMaterial and istable(BuildInfo.subMaterial) then
								for k, v in pairs(BuildInfo.subMaterial) do
									Ent:SetSubMaterial(k, v)
								end
							end
							if BuildInfo.bodygroups and istable(BuildInfo.bodygroups) then
								for k, v in pairs(BuildInfo.bodygroups) do
									Ent:SetBodygroup(k, v)
								end
							end
							JMod.Hint(self.Owner, Class)
						end
						self:Msg("Power: " .. self:GetElectricity() .. " " .. "Gas: " .. self:GetGas() .. " ")
					end
				end
			end)
		end
	end

	if not Built then
		self:Msg("missing supplies for build")
	else
		self:BuildEffect(Pos + Vector(0, 0, 5), selectedBuild, not Sound)
	end
	
	return Built
end

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_SPEED) then return end
	self:Pawnch()
	self:SetNextPrimaryFire(CurTime() + .6)
	self:SetNextSecondaryFire(CurTime() + 1)

	if SERVER then
		local Built, Upgraded, SelectedBuild = false, false, self:GetSelectedBuild()
		local Ent, Pos, Norm = self:WhomIlookinAt(100)

		if SelectedBuild and SelectedBuild ~= "" then
			Built = self:BuildItem(SelectedBuild)
		elseif IsValid(Ent) and Ent.ModPerfSpecs and self.Owner:KeyDown(JMod.Config.General.AltFunctionKey) then
			local State = Ent:GetState()

			if State == JMod.EZ_STATE_BROKEN then
				self:Msg("device must be repaired before modifying")
			elseif State ~= JMod.EZ_STATE_OFF then
				self:Msg("device must be turned off to modify")
			elseif JMod.HaveResourcesToPerformTask(self.Owner:GetShootPos(), 150, {
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = self.ModifcationCost
			}, self) then
				net.Start("JMod_ModifyMachine")
				net.WriteEntity(Ent)
				net.WriteTable(Ent.ModPerfSpecs)

				if Ent.AmmoTypes then
					net.WriteBit(true)
					net.WriteTable(Ent.AmmoTypes)
					net.WriteString(Ent:GetAmmoType())
				elseif Ent.LiquidTypes then
					net.WriteBit(true)
					net.WriteTable(Ent.LiquidTypes)
					net.WriteString(Ent:GetLiquidType())
				else
					net.WriteBit(false)
				end

				net.Send(self.Owner)
			else
				self:Msg("needs " .. tostring(self.ModifcationCost) .. " Parts nearby to perform modification")
			end
		elseif IsValid(Ent) and Ent.EZupgradable then
			local State = Ent:GetState()

			if State == -1 then
				self:Msg("device must be repaired before upgrading")
			elseif State ~= 0 then
				self:Msg("device must be turned off to upgrade")
			else
				local Grade = Ent:GetGrade()

				if Grade < 5 then
					local WorkSpreadMult = JMod.CalcWorkSpreadMult(Ent, Pos)
					local UpgradeRate = JMod.Config.Tools.Toolbox.UpgradeMult * 2 * math.Round(WorkSpreadMult)
					local RequiredMats = Ent.UpgradeCosts[Grade + 1]

					for resourceType, requiredAmt in pairs(RequiredMats) do
						local CurAmt = Ent.UpgradeProgress[resourceType] or 0

						if CurAmt < requiredAmt then
							local ResourceContainer = JMod.FindResourceContainer(resourceType, 1, nil, nil, self)

							if ResourceContainer then
								self:UpgradeEntWithResource(Ent, ResourceContainer, UpgradeRate, resourceType)
								Upgraded = true
								break
							end
						end
					end

					if not Upgraded then
						local str = "missing supplies for upgrade"

						if Ent.UpgradeProgress then 
							for typ, amount in pairs(RequiredMats) do
								str = str .. " \n " .. typ .. ": " .. tostring(RequiredMats[typ] - (Ent.UpgradeProgress[typ] or 0 ))
							end
						else
							for k, v in pairs(RequiredMats) do
								str = str .. " \n " .. k .. " " .. v
							end
						end

						self:Msg(str)
					end
				else
					self:Msg("device already highest grade")
				end
			end
		end
		
		if Upgraded then
			self:UpgradeEffect(Pos, nil, not Sound)
		end
	end
end

function SWEP:ModifyMachine(ent, tbl, ammoType)
	local State = ent:GetState()
	if State == -1 then
		self:Msg("device must be repaired before modifying")
	elseif State ~= 0 then
		self:Msg("device must be turned off to modify")
	elseif JMod.HaveResourcesToPerformTask(self.Owner:GetShootPos(), 150, { [JMod.EZ_RESOURCE_TYPES.BASICPARTS] = self.ModifcationCost }, self) then
		local ChangedSomething = false
		if (ent.GetAmmoType and (ammoType ~= ent:GetAmmoType())) then
			ChangedSomething = true
		elseif (ent.GetLiquidType and (ammoType ~= ent:GetLiquidType())) then
			ChangedSomething = true
		else
			for k, v in pairs(tbl) do
				if not istable(ent.ModPerfSpecs[k]) and ent.ModPerfSpecs[k] ~= v then
					ChangedSomething = true
				end
			end
		end
		if ChangedSomething then
			local SuccessfulConsume = JMod.ConsumeResourcesInRange({
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = self.ModifcationCost
			}, self.Owner:GetShootPos(), nil, self)
			
			if SuccessfulConsume then
				ent:SetMods(tbl, ammoType)
				self:UpgradeEffect(ent:GetPos() + Vector(0, 0, 30), 2)
			end
		end
	else
		self:Msg("needs " .. tostring(self.ModifcationCost) .. " Basic Parts nearby to perform modification")
	end
end

function SWEP:Msg(msg)
	self.Owner:PrintMessage(HUD_PRINTCENTER, msg)
end

function SWEP:UpgradeEntWithResource(recipient, donor, amt, resourceType)
	local DonorCurAmt
	local TakeFromInv = false
	if donor.GetEZsupplies then
		DonorCurAmt = donor:GetEZsupplies(resourceType)
	elseif donor.JModInv then
		DonorCurAmt = donor.JModInv.EZresources[resourceType]
		TakeFromInv = true
	end

	local Grade = recipient:GetGrade()
	local RequiredSupplies = recipient.UpgradeCosts[Grade + 1]
	---
	local CurAmt= recipient.UpgradeProgress[resourceType] or 0
	local Limit = RequiredSupplies[resourceType]
	local Given = math.min(DonorCurAmt, Limit - CurAmt, amt)
	recipient.UpgradeProgress[resourceType] = CurAmt + Given
	---
	local Msg = "UPGRADING\n"

	for typ, amount in pairs(RequiredSupplies) do
		Msg = Msg .. typ .. ": " .. tostring(math.floor(recipient.UpgradeProgress[typ] or 0)) .. "/" .. tostring(RequiredSupplies[typ]) .. "\n"
	end

	self:Msg(Msg)

	---
	if TakeFromInv then
		JMod.RemoveFromInventory(donor, {resourceType, Given})
	else
		donor:SetEZsupplies(resourceType, DonorCurAmt - Given, self)
	end

	local HaveEverything = true

	for typ, amount in pairs(RequiredSupplies) do
		if (recipient.UpgradeProgress[typ] or 0) < amount then
			HaveEverything = false
		end
	end

	if HaveEverything then
		recipient:Upgrade(Grade + 1)
	end
end

--,"fists_uppercut"} -- the uppercut looks so bad
local Anims = {"fists_right", "fists_right", "fists_left", "fists_left"}

function SWEP:Pawnch()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(table.Random(Anims)))
	self:UpdateNextIdle()
end

--[[function SWEP:FlingProp(mdl, force)
	local Prop = ents.Create("prop_physics")
	Prop:SetPos(self:GetPos() + self:GetUp() * 25 + VectorRand() * math.Rand(1, 25))
	Prop:SetAngles(VectorRand():Angle())
	Prop:SetModel(mdl)
	Prop:Spawn()
	Prop:Activate()
	Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	constraint.NoCollide(Prop, self, 0, 0)
	local Phys = Prop:GetPhysicsObject()
	Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() + VectorRand() * math.Rand(1, 300) + self:GetUp() * 100)
	Phys:AddAngleVelocity(VectorRand() * math.Rand(1, 10000))

	if force then
		Phys:ApplyForceCenter(force / 7)
	end

	SafeRemoveEntityDelayed(Prop, math.random(5, 10))
end]]--

function SWEP:SwitchSelectedBuild(name)
	self:SetSelectedBuild(name)
	local BuildInfo = JMod.Config.Craftables[name]
	if BuildInfo and BuildInfo.oneHanded then
		self:SetNW2Bool("EZoneHandedBuild", true)
	else
		self:SetNW2Bool("EZoneHandedBuild", false)
	end
end

function SWEP:Reload()
	if SERVER then
		local Time = CurTime()

		if self.Owner:KeyDown(JMod.Config.General.AltFunctionKey) then
			self:SwitchSelectedBuild("")
		else
			if self.NextSwitch < Time then
				self.NextSwitch = Time + .5
				JMod.Hint(self.Owner, "craft")
				net.Start("JMod_EZtoolbox")
				net.WriteString("toolbox")
				net.WriteEntity(self)
				net.Send(self.Owner)
			end
		end
	end
end

function SWEP:TryLoadResource(typ, amt)
	if amt < 1 then return 0 end
	local Accepted = 0

	for _, v in pairs(self.EZconsumes) do
		if typ == v then
			local CurAmt = self:GetEZsupplies(typ, self) or 0
			local Take = math.min(amt, self.MaxElectricity - CurAmt)
			
			if Take > 0 then
				self:SetEZsupplies(typ, CurAmt + Take)
				if typ == JMod.EZ_RESOURCE_TYPES.POWER then
					sound.Play("snd_jack_turretbatteryload.ogg", self.Owner:GetShootPos(), 65, math.random(90, 110))
				elseif typ == JMod.EZ_RESOURCE_TYPES.GAS then
					sound.Play("snds_jack_gmod/gas_load.ogg", self.Owner:GetShootPos(), 65, math.random(90, 110))
				end
				Accepted = Take
			end
		end
	end

	return Accepted
end

function SWEP:BuildEffect(pos, buildType, suppressSound)
	if CLIENT then return end
	local Scale = (self.Craftables[buildType].sizeScale or 1) ^ .5
	self:UpgradeEffect(pos, Scale * 2, suppressSound)
	local eff = EffectData()
	eff:SetOrigin(pos + VectorRand())
	eff:SetScale(Scale)
	util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
end

function SWEP:UpgradeEffect(pos, scale, suppressSound)
	if CLIENT then return end
	scale = scale or 1
	local effectdata = EffectData()
	effectdata:SetOrigin(pos + VectorRand())
	effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
	effectdata:SetMagnitude(math.Rand(1, 2) * scale) --amount and shoot hardness
	effectdata:SetScale(math.Rand(.5, 1.5) * scale) --length of strands
	effectdata:SetRadius(math.Rand(2, 4) * scale) --thickness of strands
	util.Effect("Sparks", effectdata, true, true)

	if not suppressSound then
		sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(80, 120))
		sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".ogg", pos, 60, math.random(80, 120))
	end
end

function SWEP:WhomIlookinAt(dist)
	dist = dist or 100
	local Filter = {self, self.Owner}

	for k, v in pairs(ents.FindByClass("npc_bullseye")) do
		table.insert(Filter, v)
	end

	local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * dist, Filter)

	return Tr.Entity, Tr.HitPos, Tr.HitNormal
end

function SWEP:SecondaryAttack()
end

--
function SWEP:OnDrop()
	local Kit = ents.Create("ent_jack_gmod_eztoolbox")
	local Pos, Ang = self:GetPos(), self:GetAngles()
	if IsValid(self.EZdropper) and self.EZdropper:IsPlayer() then
		local AimPos, AimVec = self.EZdropper:GetShootPos(), self.EZdropper:GetAimVector()
		local PlaceTr = util.QuickTrace(AimPos, AimVec * 60, {self, self.EZdropper})
		Pos = PlaceTr.HitPos + PlaceTr.HitNormal * 5
	end
	Kit:SetPos(Pos)
	Kit:SetAngles(Ang)
	Kit:Spawn()
	Kit:Activate()

	Kit:SetElectricity(self:GetElectricity())
	Kit:SetGas(self:GetGas())

	local Phys = Kit:GetPhysicsObject()

	if Phys then
		Phys:SetVelocity(self:GetVelocity() / 2)
	end

	self:Remove()
end

function SWEP:OnRemove()
	self:SCKHolster()

	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end

	-- ADDED :
	if CLIENT then
		-- Removes V Models
		for k, v in pairs(self.VElements) do
			local model = v.modelEnt

			if v.type == "Model" and IsValid(model) then
				model:Remove()
			end
		end

		-- Removes W Models
		for k, v in pairs(self.WElements) do
			local model = v.modelEnt

			if v.type == "Model" and IsValid(model) then
				model:Remove()
			end
		end
	end
end

function SWEP:Holster(wep)
	-- Not calling OnRemove to keep the models
	self:SCKHolster()

	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end

	return true
end

function SWEP:Deploy()
	if not IsValid(self.Owner) then return end
	local vm = self.Owner:GetViewModel()

	if IsValid(vm) and vm.LookupSequence then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
		self:UpdateNextIdle()
		self:EmitSound("snds_jack_gmod/toolbox" .. math.random(1, 7) .. ".ogg", 65, math.random(90, 110))
	end

	if SERVER then
		JMod.Hint(self.Owner, "building")
	end

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	return true
end

--[[function SWEP:CreateResourceEntity(pos, typ, amt)
	local Ent = ents.Create(JMod.EZ_RESOURCE_ENTITIES[typ])
	Ent:SetPos(pos)
	Ent:SetAngles(AngleRand())
	Ent:SetCreator(self.Owner)
	Ent:Spawn()
	Ent:Activate()
	Ent:SetEZsupplies(Ent.EZsupplies, amt)
	JMod.SetEZowner(Ent, self.Owner)
	timer.Simple(.1, function()
		if (IsValid(Ent) and IsValid(Ent:GetPhysicsObject())) then 
			Ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0)) --- This is so jank
		end
	end)
end--]]

function SWEP:Think()
	local Time = CurTime()
	local vm = self.Owner:GetViewModel()
	local idletime = self.NextIdle

	if idletime > 0 and Time > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
		self:UpdateNextIdle()
	end

	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		self:SetHoldType("normal")
	else
		self:SetHoldType("fist")

		if self.Owner:KeyDown(IN_ATTACK2) then
			if SERVER and (self.NextTaskProgress < Time) then
				self.NextTaskProgress = Time + .6
				local Alt = self.Owner:KeyDown(JMod.Config.General.AltFunctionKey)
				local Task = (Alt and "loosen") or "salvage"
				local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 80, {self.Owner})
				local Ent, Pos = Tr.Entity, Tr.HitPos

				if IsValid(Ent) then
					if Ent ~= self.TaskEntity or Task ~= self.CurTask then
						self:SetTaskProgress(0)
						self.TaskEntity = Ent
						self.CurTask = Task
					elseif IsValid(Ent:GetPhysicsObject()) then
						local Message = JMod.EZprogressTask(Ent, Pos, self.Owner, (Alt and "loosen") or "salvage")

						if Message then
							self:Msg(Message)
						else
							self:Pawnch()
							sound.Play("snds_jack_gmod/ez_tools/hit.ogg", Pos + VectorRand(), 60, math.random(50, 70))
							sound.Play("snds_jack_gmod/ez_dismantling/" .. math.random(1, 10) .. ".ogg", Pos, 65, math.random(90, 110))
							if SERVER then
								JMod.Hint(self.Owner, "work spread")
								self:SetTaskProgress(Ent:GetNW2Float("EZ"..Task.."Progress", 0))
								timer.Simple(.1, function()
									if IsValid(self) then
										self:UpgradeEffect(Pos, 2, true)
									end
								end)
							end
						end 
					end
				end
			end
		else
			self:SetTaskProgress(0)
		end
	end
end

local LastProg = 0

function SWEP:DrawHUD()
	if GetConVar("cl_drawhud"):GetBool() == false then return end
	local Ply = self.Owner
	if Ply:ShouldDrawLocalPlayer() then return end
	local W, H, Build = ScrW(), ScrH(), self:GetSelectedBuild()

	if Build and (Build ~= "") then
		draw.SimpleTextOutlined(Build, "Trebuchet24", W * .5, H * .7 - 60, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 150))
	end

	draw.SimpleTextOutlined("Power: "..math.floor(self:GetElectricity()), "Trebuchet24", W * .1, H * .5, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("Gas: "..math.floor(self:GetGas()), "Trebuchet24", W * .1, H * .5 + 30, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	
	draw.SimpleTextOutlined("ALT+R: clear build item", "Trebuchet24", W * .4, H * .7 - 30, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	draw.SimpleTextOutlined("R: select build item", "Trebuchet24", W * .4, H * .7, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	draw.SimpleTextOutlined("LMB: build or upgrade", "Trebuchet24", W * .4, H * .7 + 30, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	draw.SimpleTextOutlined("ALT+LMB: modify", "Trebuchet24", W * .4, H * .7 + 60, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	draw.SimpleTextOutlined("RMB: salvage", "Trebuchet24", W * .4, H * .7 + 90, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	draw.SimpleTextOutlined("ALT+RMB: loosen", "Trebuchet24", W * .4, H * .7 + 120, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	draw.SimpleTextOutlined("Backspace: drop kit", "Trebuchet24", W * .4, H * .7 + 150, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
	
	local Prog = self:GetTaskProgress()

	if Prog > 0 then
		draw.SimpleTextOutlined((JMod.IsAltUsing(Ply) and "Loosening...") or "Salvaging...", "Trebuchet24", W * .5, H * .45, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
		draw.RoundedBox(10, W * .3, H * .5, W * .4, H * .05, Color(0, 0, 0, 100))
		draw.RoundedBox(10, W * .3 + 5, H * .5 + 5, W * .4 * LastProg / 100 - 10, H * .05 - 10, Color(255, 255, 255, 100))
	end

	local Tr = util.QuickTrace(Ply:EyePos(), Ply:GetAimVector() * 80, {Ply})
	local Ent = Tr.Entity
	if IsValid(Ent) and Ent.IsJackyEZmachine then
		draw.SimpleTextOutlined((Ent.PrintName and tostring(Ent.PrintName)) or tostring(Ent), "Trebuchet24", W * .7, H * .5, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
		if Ent.MaxDurability then
			draw.SimpleTextOutlined("Durability: "..tostring(math.Round(Ent:GetNW2Float("EZdurability", 0)) + Ent.MaxDurability * 2).."/"..Ent.MaxDurability*3, "Trebuchet24", W * .7, H * .5 + 30, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
		end
		if Ent.EZupgradable and Ent.GetGrade and Ent:GetGrade() > 0 then
			draw.SimpleTextOutlined("Grade: "..tostring(Ent:GetGrade()), "Trebuchet24", W * .7, H * .5 + 60, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
		end
	end

	LastProg = Lerp(FrameTime() * 5, LastProg, Prog)
end

----------------- sck -------------------
function SWEP:SCKHolster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
end

function SWEP:SCKInitialize()
	if CLIENT then
		-- Create a new table for every weapon instance
		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)
		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels

		-- init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()

			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end

			-- Init viewmodel visibility
			if self.ShowViewModel == nil or self.ShowViewModel then
				if IsValid(vm) then
					vm:SetColor(Color(255, 255, 255, 255))
				end
			else
				-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
				vm:SetColor(Color(255, 255, 255, 1))
				-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
				-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
				vm:SetMaterial("Debug/hsv")
			end
		end
	end
end

if CLIENT then
	SWEP.vRenderOrder = nil

	function SWEP:SCKViewModelDrawn()
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		if not self.VElements then return end
		self:UpdateBonePositions(vm)

		if not self.vRenderOrder then
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if v.type == "Model" then
					table.insert(self.vRenderOrder, 1, k)
				elseif v.type == "Sprite" or v.type == "Quad" then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for k, name in ipairs(self.vRenderOrder) do
			local v = self.VElements[name]

			if not v then
				self.vRenderOrder = nil
				break
			end

			if v.hide then continue end
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			if not v.bone then continue end
			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
			if not pos then continue end

			if v.type == "Model" and IsValid(model) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end

				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end

				if v.bodygroup then
					for k, v in pairs(v.bodygroup) do
						if model:GetBodygroup(k) ~= v then
							model:SetBodygroup(k, v)
						end
					end
				end

				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
			elseif v.type == "Sprite" and sprite then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.wRenderOrder = nil

	function SWEP:SCKDrawWorldModel()
		if self.ShowWorldModel == nil or self.ShowWorldModel then
			self:DrawModel()
		end

		if not self.WElements then return end

		if not self.wRenderOrder then
			self.wRenderOrder = {}

			for k, v in pairs(self.WElements) do
				if v.type == "Model" then
					table.insert(self.wRenderOrder, 1, k)
				elseif v.type == "Sprite" or v.type == "Quad" then
					table.insert(self.wRenderOrder, k)
				end
			end
		end

		local bone_ent

		if IsValid(self.Owner) then
			bone_ent = self.Owner
		else
			-- when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]

			if not v then
				self.wRenderOrder = nil
				break
			end

			if v.hide then continue end
			local pos, ang

			if v.bone then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end

			if not pos then continue end
			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if v.type == "Model" and IsValid(model) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end

				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end

				if v.bodygroup then
					for k, v in pairs(v.bodygroup) do
						if model:GetBodygroup(k) ~= v then
							model:SetBodygroup(k, v)
						end
					end
				end

				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
			elseif v.type == "Sprite" and sprite then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		local bone, pos, ang

		if tab.rel and tab.rel ~= "" then
			local v = basetab[tab.rel]
			if not v then return end
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation(basetab, v, ent)
			if not pos then return end
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
		else
			bone = ent:LookupBone(bone_override or tab.bone)
			if not bone then return end
			pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
			local m = ent:GetBoneMatrix(bone)

			if m then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if IsValid(self.Owner) and self.Owner:IsPlayer() and ent == self.Owner:GetViewModel() and self.ViewModelFlip then
				ang.r = -ang.r -- Fixes mirrored models
			end
		end

		return pos, ang
	end

	function SWEP:CreateModels(tab)
		if not tab then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs(tab) do
			if v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists(v.model, "GAME") then
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)

				if IsValid(v.modelEnt) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/" .. v.sprite .. ".vmt", "GAME") then
				local name = v.sprite .. "-"

				local params = {
					["$basetexture"] = v.sprite
				}

				-- make sure we create a unique name based on the selected options
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}

				for i, j in pairs(tocheck) do
					if v[j] then
						params["$" .. j] = 1
						name = name .. "1"
					else
						name = name .. "0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
			end
		end
	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		if self.ViewModelBoneMods then
			if not vm:GetBoneCount() then return end
			local loopthrough = self.ViewModelBoneMods

			if not hasGarryFixedBoneScalingYet then
				allbones = {}

				for i = 0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)

					if self.ViewModelBoneMods[bonename] then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1, 1, 1),
							pos = Vector(0, 0, 0),
							angle = Angle(0, 0, 0)
						}
					end
				end

				loopthrough = allbones
			end

			for k, v in pairs(loopthrough) do
				local bone = vm:LookupBone(k)
				if not bone then continue end
				local s = Vector(v.scale.x, v.scale.y, v.scale.z)
				local p = Vector(v.pos.x, v.pos.y, v.pos.z)
				local ms = Vector(1, 1, 1)

				if not hasGarryFixedBoneScalingYet then
					local cur = vm:GetBoneParent(bone)

					while cur >= 0 do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				if vm:GetManipulateBoneScale(bone) ~= s then
					vm:ManipulateBoneScale(bone, s)
				end

				if vm:GetManipulateBoneAngles(bone) ~= v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end

				if vm:GetManipulateBonePosition(bone) ~= p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end

	function SWEP:ResetBonePositions(vm)
		if not vm:GetBoneCount() then return end

		for i = 0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end
end
