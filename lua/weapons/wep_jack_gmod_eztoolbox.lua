﻿-- Jackarunda 2021
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
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/props_c17/tools_wrench01a.mdl"
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
SWEP.ShowWorldModel = false

SWEP.VElements = {
	["wrench"] = {
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
	}
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
	["wrench"] = {
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
	},
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
	["pickaxe"] = {
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
	},
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
	["axe"] = {
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
	},
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

local PackageBlacklist = {"func_"}

function SWEP:Initialize()
	self:SetHoldType("fist")
	self:SCKInitialize()
	self.NextIdle = 0
	self:Deploy()
	self:SetSelectedBuild(0)
	self:SetTaskProgress(0)
	self.TaskEntity = nil
	self.NextTaskProgress = 0
	self.CurTask = nil

	if SERVER then
		self.Craftables = {}

		for name, info in pairs(JMod.Config.Craftables) do
			if info.craftingType == "toolbox" then
				-- we store this here for client transmission later
				-- because we can't rely on the client having the config
				local infoCopy = table.FullCopy(info)
				infoCopy.name = name
				self.Craftables[name] = info
			end
		end
	end

	self:SetTaskProgress(0)
	self:SetSelectedBuild("")
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
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

	if self.Owner:KeyDown(IN_SPEED) then
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
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self.NextIdle = CurTime() + vm:SequenceDuration()
end

function SWEP:FindNailPos()
	local Pos, Vec = self.Owner:GetShootPos(), self.Owner:GetAimVector()

	local Tr1 = util.QuickTrace(Pos, Vec * 80, {self.Owner})

	if Tr1.Hit then
		local Ent1 = Tr1.Entity
		if Tr1.HitSky or Ent1:IsWorld() or Ent1:IsPlayer() or Ent1:IsNPC() then return nil end
		if not IsValid(Ent1:GetPhysicsObject()) then return nil end

		local Tr2 = util.QuickTrace(Pos, Vec * 120, {self.Owner, Ent1})

		if Tr2.Hit then
			local Ent2 = Tr2.Entity
			if (Ent1 == Ent2) or Tr2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return nil end
			if not Ent2:IsWorld() and not IsValid(Ent2:GetPhysicsObject()) then return nil end
			local Dist = Tr1.HitPos:Distance(Tr2.HitPos)
			if Dist > 30 then return nil end

			return true, Tr1.HitPos, Vec, Ent1, Ent2
		end
	end
end

function SWEP:Nail()
	local Success, Pos, Vec, Ent1, Ent2 = self:FindNailPos()
	if not Success then return end
	local Weld = constraint.Find(Ent1, Ent2, "Weld", 0, 0)

	if Weld then
		local Strength = Weld:GetTable().forcelimit + 3000
		Weld:Remove()

		timer.Simple(.1, function()
			Weld = constraint.Weld(Ent1, Ent2, 0, 0, Strength, false, false)
		end)
	else
		Weld = constraint.Weld(Ent1, Ent2, 0, 0, 3000, false, false)
	end

	local Nail = ents.Create("prop_dynamic")
	Nail:SetModel("models/crossbow_bolt.mdl")
	Nail:SetMaterial("models/shiny")
	Nail:SetColor(Color(50, 50, 50))
	Nail:SetPos(Pos - Vec * 2)
	Nail:SetAngles(Vec:Angle())
	Nail:Spawn()
	Nail:Activate()
	Nail:SetParent(Ent1)
	Ent1.EZnails = Ent1.EZnails or {}
	table.insert(Ent1.EZnails, Nail)
	sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", Pos, 60, math.random(80, 120))
end

function SWEP:GetPackagableObject()
	local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 80, {self.Owner})

	local Ent = Tr.Entity

	if IsValid(Ent) and not Ent:IsWorld() then
		if Ent.EZunpackagable then
			self:Msg("No.")

			return nil
		end

		if Ent:IsPlayer() or Ent:IsNPC() then return nil end
		if Ent:IsRagdoll() then return nil end
		local Constraints, Constrained = constraint.GetTable(Ent), false

		for k, v in pairs(Constraints) do
			if v.Type ~= "NoCollide" then
				Constrained = true
				break
			end
		end

		if Constrained then
			self:Msg("object is constrained")

			return nil
		end

		for k, v in pairs(PackageBlacklist) do
			if string.find(Ent:GetClass(), v) then
				self:Msg("can't package this")

				return nil
			end
		end

		return Ent
	end

	return nil
end

function SWEP:Package()
	local Ent = self:GetPackagableObject()

	if Ent then
		JMod.PackageObject(Ent)
		sound.Play("snds_jack_gmod/packagify.wav", self:GetPos(), 60, math.random(90, 110))

		for i = 1, 3 do
			timer.Simple(i / 3, function()
				if IsValid(self) then
					sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", self:GetPos(), 60, math.random(80, 120))
				end
			end)
		end
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_SPEED) then return end
	self:Pawnch()
	self:SetNextPrimaryFire(CurTime() + .6)
	self:SetNextSecondaryFire(CurTime() + 1)

	if SERVER then
		local Built, Upgraded, SelectedBuild = false, false, self:GetSelectedBuild()
		local Ent, Pos, Norm = self:WhomIlookinAt()

		if SelectedBuild and SelectedBuild ~= "" then
			local buildInfo = self.Craftables[SelectedBuild]
			if not buildInfo then return end
			if (buildInfo.results == "ez nail") and not self:FindNailPos() then return end
			if (buildInfo.results == "ez box") and not self:GetPackagableObject() then return end
			local Sound = buildInfo.results ~= "ez nail" and buildInfo.results ~= "ez box"
			local Reqs = buildInfo.craftingReqs

			if JMod.HaveResourcesToPerformTask(nil, nil, Reqs, self) then
				local override, msg = hook.Run("JMod_CanKitBuild", self.Owner, self, buildInfo)

				if override == false then
					self.Owner:PrintMessage(HUD_PRINTCENTER, msg or "cannot build")

					return
				end

				JMod.ConsumeResourcesInRange(Reqs, nil, nil, self)
				Built = true
				local BuildSteps = math.ceil(20 * (buildInfo.sizeScale or 1))

				for i = 1, BuildSteps do
					timer.Simple(i / 100, function()
						if IsValid(self) then
							if i < BuildSteps then
								if Sound then
									sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", Pos, 60, math.random(80, 120))
								end
							else
								local Class = buildInfo.results

								if Class == "ez nail" then
									self:Nail()
								elseif Class == "ez box" then
									self:Package()
								else
									local StringParts = string.Explode(" ", Class)

									if StringParts[1] and (StringParts[1] == "FUNC") then
										local FuncName = StringParts[2]

										if JMod.LuaConfig and JMod.LuaConfig.BuildFuncs and JMod.LuaConfig.BuildFuncs[FuncName] then
											JMod.LuaConfig.BuildFuncs[FuncName](self.Owner, Pos + Norm * 10 * (buildInfo.sizeScale or 1), Angle(0, self.Owner:EyeAngles().y, 0))
										else
											print("JMOD TOOLBOX ERROR: garrysmod/lua/autorun/JMod.LuaConfig.lua is missing, corrupt, or doesn't have an entry for that build function")
										end
									else
										local Ent = ents.Create(Class)
										Ent:SetPos(Pos + Norm * 10 * (buildInfo.sizeScale or 1))
										Ent:SetAngles(Angle(0, self.Owner:EyeAngles().y, 0))
										JMod.SetOwner(Ent, self.Owner)
										Ent:Spawn()
										Ent:Activate()
									end
								end
							end
						end
					end)
				end
			end

			if not Built then
				self:Msg("missing supplies for build")
			end
		elseif IsValid(Ent) and Ent.ModPerfSpecs and self.Owner:KeyDown(JMod.Config.AltFunctionKey) then
			local State = Ent:GetState()

			if State == -1 then
				self:Msg("device must be repaired before modifying")
			elseif State ~= 0 then
				self:Msg("device must be turned off to modify")
			elseif JMod.HaveResourcesToPerformTask(nil, nil, {
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = 20
			}, self) then
				net.Start("JMod_ModifyMachine")
				net.WriteEntity(Ent)
				net.WriteTable(Ent.ModPerfSpecs)

				if Ent.AmmoTypes then
					net.WriteBit(true)
					net.WriteTable(Ent.AmmoTypes)
					net.WriteString(Ent:GetAmmoType())
				else
					net.WriteBit(false)
				end

				net.Send(self.Owner)
			else
				self:Msg("needs 20 Parts nearby to perform modification")
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
					local UpgradeRate = JMod.Config.ToolKitUpgradeMult * 1 * math.Round(WorkSpreadMult)
					local RequiredMats = Ent.UpgradeCosts[Grade + 1]

					for resourceType, requiredAmt in pairs(RequiredMats) do
						local CurAmt = Ent.UpgradeProgress[resourceType] or 0

						if CurAmt < requiredAmt then
							local ResourceContainer = JMod.FindResourceContainer(resourceType, UpgradeRate, nil, nil, self.Owner)

							if ResourceContainer then
								self:UpgradeEntWithResource(Ent, ResourceContainer, UpgradeRate)
								Upgraded = true
								break
							end
						end
					end

					if not Upgraded then
						local str = "missing supplies for upgrade"

						for k, v in pairs(RequiredMats) do
							str = str .. " \n " .. k .. " " .. v
						end

						self:Msg(str)
					end
				else
					self:Msg("device already highest grade")
				end
			end
		end

		if Built or Upgraded then
			if Built then
				self:BuildEffect(Pos, SelectedBuild, not Sound)
			elseif Upgraded then
				self:UpgradeEffect(Pos, nil, not Sound)
			end
		end
	end
end

function SWEP:ModifyMachine(ent, tbl, ammoType)
	local State = ent:GetState()

	if State == -1 then
		self:Msg("device must be repaired before modifying")
	elseif State ~= 0 then
		self:Msg("device must be turned off to modify")
	elseif JMod.HaveResourcesToPerformTask(nil, nil, {
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = 50
	}, self) then
		JMod.ConsumeResourcesInRange({
			[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = 50
		}, nil, nil, self)

		ent:SetMods(tbl, ammoType)
		self:UpgradeEffect(ent:GetPos() + Vector(0, 0, 30), 2)
	else
		self:Msg("needs 50 Basic Parts nearby to perform modification")
	end
end

function SWEP:Msg(msg)
	self.Owner:PrintMessage(HUD_PRINTCENTER, msg)
end

function SWEP:UpgradeEntWithResource(recipient, donor, amt)
	local Type, Grade = donor.EZsupplies, recipient:GetGrade()
	local RequiredSupplies = recipient.UpgradeCosts[Grade + 1]
	if not Type then return end
	local CurAmt, DonorCurAmt = recipient.UpgradeProgress[Type] or 0, donor:GetResource()
	local Limit = RequiredSupplies[Type]
	local Given = math.min(DonorCurAmt, Limit - CurAmt, amt)
	recipient.UpgradeProgress[Type] = CurAmt + Given
	---
	local Msg = "UPGRADING\n"

	for typ, amount in pairs(RequiredSupplies) do
		Msg = Msg .. typ .. ": " .. tostring(recipient.UpgradeProgress[typ] or 0) .. "/" .. tostring(RequiredSupplies[typ]) .. "\n"
	end

	self:Msg(Msg)

	---
	if (DonorCurAmt - Given) <= 0 then
		if donor:GetClass() == "ent_jack_gmod_ezcrate" then
			donor:SetResource(0)
			donor:ApplySupplyType("generic")
		else
			donor:Remove()
		end
	else
		donor:SetResource(DonorCurAmt - Given)
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

function SWEP:FlingProp(mdl, force)
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
end

function SWEP:SwitchSelectedBuild(name)
	self:SetSelectedBuild(name)
end

function SWEP:Reload()
	if SERVER then
		local Time = CurTime()

		if self.Owner:KeyDown(JMod.Config.AltFunctionKey) then
		else -- do nothing
			if self.NextSwitch < Time then
				self.NextSwitch = Time + .5
				JMod.Hint(self.Owner, "craft")
				net.Start("JMod_EZtoolbox")
				net.WriteTable(self.Craftables)
				net.WriteEntity(self)
				net.Send(self.Owner)
			end
		end
	end
end

function SWEP:BuildEffect(pos, buildType, suppressSound)
	if CLIENT then return end
	local Scale = (self.Craftables[buildType].sizeScale or 1) ^ .6
	self:UpgradeEffect(pos, Scale * 4, suppressSound)
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
		sound.Play("snds_jack_gmod/ez_tools/hit.wav", pos + VectorRand(), 60, math.random(80, 120))
		sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".wav", pos, 60, math.random(80, 120))
	end
end

function SWEP:WhomIlookinAt()
	local Filter = {self.Owner}

	for k, v in pairs(ents.FindByClass("npc_bullseye")) do
		table.insert(Filter, v)
	end

	local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 80, Filter)

	return Tr.Entity, Tr.HitPos, Tr.HitNormal
end

function SWEP:SecondaryAttack()
end

--
function SWEP:OnDrop()
	local Kit = ents.Create("ent_jack_gmod_eztoolbox")
	Kit:SetPos(self:GetPos())
	Kit:SetAngles(self:GetAngles())
	Kit:Spawn()
	Kit:Activate()
	local Phys = Kit:GetPhysicsObject()

	if Phys then
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() / 2)
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
		self:EmitSound("snds_jack_gmod/toolbox" .. math.random(1, 7) .. ".wav", 65, math.random(90, 110))
	end

	if SERVER then
		JMod.Hint(self.Owner, "building")
	end

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	return true
end

function SWEP:CreateResourceEntity(pos, typ, amt)
	local Ent = ents.Create(JMod.EZ_RESOURCE_ENTITIES[typ])
	Ent:SetPos(pos)
	Ent:SetAngles(AngleRand())
	Ent:Spawn()
	Ent:Activate()
	Ent:SetResource(amt or 100)
	JMod.SetOwner(Ent, self.Owner)
end

function SWEP:Think()
	local Time = CurTime()
	local vm = self.Owner:GetViewModel()
	local idletime = self.NextIdle

	if idletime > 0 and Time > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
		self:UpdateNextIdle()
	end

	local Prog, SetAmt = self:GetTaskProgress(), nil

	if self.Owner:KeyDown(IN_SPEED) then
		self:SetHoldType("normal")
	else
		self:SetHoldType("fist")

		if self.Owner:KeyDown(IN_ATTACK2) then
			if self.NextTaskProgress < Time then
				self.NextTaskProgress = Time + .6
				SetAmt = 0
				local Alt = self.Owner:KeyDown(JMod.Config.AltFunctionKey)

				local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 80, {self.Owner})

				local Ent, Pos = Tr.Entity, Tr.HitPos

				if IsValid(Ent) then
					local Phys = Ent:GetPhysicsObject()
					local Task = (Alt and "loosen") or "salvage"

					if Ent ~= self.TaskEntity or Task ~= self.CurTask then
						self:SetTaskProgress(0)
						self.TaskEntity = Ent
						self.CurTask = Task
					elseif IsValid(Phys) then
						if Alt then
							-- loosen
							--Prog = JMod.UpdateDeconstruct(Ent)
							if constraint.HasConstraints(Ent) or not Phys:IsMotionEnabled() then
								JMod.Hint(self.Owner, "work spread")
								local WorkSpreadMult = JMod.CalcWorkSpreadMult(Ent, Pos)
								local Mass = Phys:GetMass() ^ .8
								local AddAmt = 300 / Mass * WorkSpreadMult * JMod.Config.ToolboxDeconstructSpeedMult
								SetAmt = math.Clamp(Prog + AddAmt, 0, 100)
								self:Pawnch()
								sound.Play("snds_jack_gmod/ez_tools/hit.wav", Pos + VectorRand(), 60, math.random(50, 70))
								sound.Play("snds_jack_gmod/ez_dismantling/" .. math.random(1, 10) .. ".wav", Pos, 65, math.random(90, 110))

								timer.Simple(.1, function()
									if IsValid(self) then
										self:UpgradeEffect(Pos, 1, true)
									end
								end)

								if Prog >= 100 then
									sound.Play("snds_jack_gmod/ez_tools/hit.wav", Pos + VectorRand(), 70, math.random(50, 60))
									constraint.RemoveAll(Ent)
									Phys:EnableMotion(true)
									Phys:Wake()
									SetAmt = 0
								end
							else
								self.Owner:PrintMessage(HUD_PRINTCENTER, "object is already unconstrained")
							end
						else
							-- salvage
							--Prog = JMod.UpdateDeconstruct(Ent)
							if SERVER then
								if constraint.HasConstraints(Ent) or not Phys:IsMotionEnabled() then
									self.Owner:PrintMessage(HUD_PRINTCENTER, "object is constrained")
								else
									local Mass = Phys:GetMass() ^ .8
									local Yield, Msg = JMod.GetSalvageYield(Ent)

									if #table.GetKeys(Yield) <= 0 then
										self.Owner:PrintMessage(HUD_PRINTCENTER, Msg)
									else
										JMod.Hint(self.Owner, "work spread")
										local WorkSpreadMult = JMod.CalcWorkSpreadMult(Ent, Pos)
										local AddAmt = 250 / Mass * WorkSpreadMult * JMod.Config.ToolboxDeconstructSpeedMult
										SetAmt = math.Clamp(Prog + AddAmt, 0, 100)
										self:Pawnch()
										sound.Play("snds_jack_gmod/ez_tools/hit.wav", Pos + VectorRand(), 60, math.random(50, 70))
										sound.Play("snds_jack_gmod/ez_dismantling/" .. math.random(1, 10) .. ".wav", Pos, 65, math.random(90, 110))

										timer.Simple(.1, function()
											if IsValid(self) then
												self:UpgradeEffect(Pos, 2, true)
											end
										end)

										if Prog >= 100 then
											sound.Play("snds_jack_gmod/ez_tools/hit.wav", Pos + VectorRand(), 70, math.random(50, 60))

											--local i = 0
											for k, v in pairs(Yield) do
												--timer.Simple(i*0.5, function()
													local AmtLeft = v

													while AmtLeft > 0 do
														local Remove = math.min(AmtLeft, 100)
														self:CreateResourceEntity(Pos + VectorRand() * 50 + Vector(0, 0, 20), k, Remove)
														AmtLeft = AmtLeft - Remove
													end
												--end)
												--i = i + 1
											end

											SafeRemoveEntity(Ent)
											SetAmt = 0
										end
									end
								end
							end
						end
					end
				end
			end
		else
			SetAmt = 0
		end
	end

	if SERVER and SetAmt ~= nil then
		self:SetTaskProgress(SetAmt)
	end
end

local LastProg = 0

function SWEP:DrawHUD()
	if GetConVar("cl_drawhud"):GetBool() == false then return end
	if self.Owner:ShouldDrawLocalPlayer() then return end
	local W, H, Build = ScrW(), ScrH(), self:GetSelectedBuild()
	local W, H, Msg = ScrW(), ScrH()

	if Build and (Build ~= "") then
		draw.SimpleTextOutlined(Build, "Trebuchet24", W * .5, H * .7 - 50, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 150))
	end

	draw.SimpleTextOutlined("R: select build item", "Trebuchet24", W * .4, H * .7, Color(255, 255, 255, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("LMB: build or upgrade", "Trebuchet24", W * .4, H * .7 + 30, Color(255, 255, 255, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("ALT+LMB: modify", "Trebuchet24", W * .4, H * .7 + 60, Color(255, 255, 255, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("RMB: salvage", "Trebuchet24", W * .4, H * .7 + 90, Color(255, 255, 255, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("ALT+RMB: loosen", "Trebuchet24", W * .4, H * .7 + 120, Color(255, 255, 255, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("Backspace: drop kit", "Trebuchet24", W * .4, H * .7 + 150, Color(255, 255, 255, 50), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	local Prog = self:GetTaskProgress()

	if Prog > 0 then
		draw.SimpleTextOutlined((self.Owner:KeyDown(JMod.Config.AltFunctionKey) and "Loosening...") or "Salvaging...", "Trebuchet24", W * .5, H * .45, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
		draw.RoundedBox(10, W * .3, H * .5, W * .4, H * .05, Color(0, 0, 0, 100))
		draw.RoundedBox(10, W * .3 + 5, H * .5 + 5, W * .4 * LastProg / 100 - 10, H * .05 - 10, Color(255, 255, 255, 100))
	end

	LastProg = Lerp(FrameTime() * 5, LastProg, Prog)
end

----------------- shit -------------------
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
