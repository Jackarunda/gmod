local EquipSounds = {"snds_jack_gmod/equip1.ogg", "snds_jack_gmod/equip2.ogg", "snds_jack_gmod/equip3.ogg", "snds_jack_gmod/equip4.ogg", "snds_jack_gmod/equip5.ogg"}

local function IsDamageThisType(dmg, typ)
	if type(typ) ~= "number" then return false end

	if typ == DMG_BULLET then
		if dmg:GetAmmoType() and (game.GetAmmoName(dmg:GetAmmoType()) == "Buckshot") then return false end
	elseif typ == DMG_BUCKSHOT then
		if dmg:GetAmmoType() and (game.GetAmmoName(dmg:GetAmmoType()) == "Buckshot") then return true end
	end

	return dmg:IsDamageType(typ)
end

local function IsDamageOneOfTypes(dmg, types)
	for k, v in pairs(types) do
		if IsDamageThisType(dmg, v) then return true end
	end

	return false
end

function JMod.EZarmorSync(ply)
	if not ply.EZarmor then return end
	ply.EZarmor.effects = {}
	ply.EZarmor.mskmats = {}
	ply.EZarmor.sndlop = nil
	ply.EZarmor.blackvision = nil

	for id, item in pairs(ply.EZarmor.items) do
		local ArmorInfo = table.FullCopy(JMod.ArmorTable[item.name])

		if item.tgl and ArmorInfo.tgl then
			ArmorInfo = table.Merge(ArmorInfo, ArmorInfo.tgl)

			-- for some fucking reason, table.Merge doesn't copy empty tables
			for k, v in pairs(ArmorInfo.tgl) do
				if type(v) == "table" then
					if #table.GetKeys(v) == 0 then
						ArmorInfo[k] = {}
					end
				end
			end
		end

		local dead = item.chrg and ((item.chrg.power and item.chrg.power <= 0) or (item.chrg.chemicals and item.chrg.chemicals <= 0) or (item.chrg.gas and item.chrg.gas <= 0))

		if ArmorInfo.eff and not dead then
			for effName, effMag in pairs(ArmorInfo.eff) do
				if isnumber(effMag) then
					ply.EZarmor.effects[effName] = (ply.EZarmor.effects[effName] or 0) + effMag
				else
					ply.EZarmor.effects[effName] = effMag
				end
			end
		end

		if ArmorInfo.blackvisionwhendead and dead then
			ply.EZarmor.blackvision = true
			JMod.Hint(ply, "vision dead")
		end

		if ArmorInfo.mskmat and ArmorInfo.mskmat ~= "" then
			ply.EZarmor.mskmats[id] = ArmorInfo.mskmat
		end

		if ArmorInfo.sndlop and ArmorInfo.sndlop ~= "" then
			ply.EZarmor.sndlop = ArmorInfo.sndlop
		end
	end
	if not ply.EZarmor.effects.parachute and ply:GetNW2Bool("EZparachuting", false) then
		ply:SetNW2Bool("EZparachuting", false)
	end

	hook.Run("JMod_EZarmorSync", ply)

	net.Start("JMod_EZarmorSync")
		net.WriteEntity(ply)
		net.WriteTable(ply.EZarmor)
	net.Broadcast()
end

function JMod.EZarmorWarning(ply, txt)
	local Time = CurTime()
	ply.NextEZarmorWarning = ply.NextEZarmorWarning or 0
	if ply.NextEZarmorWarning > Time then return end
	ply:PrintMessage(HUD_PRINTTALK, txt)
	ply.NextEZarmorWarning = Time + 15
end

local function IsHitToFace(ply, dmg)
	local FacingDir, DmgDir = ply:GetAimVector(), dmg:GetDamageForce():GetNormalized()
	local ApproachAngle = -math.deg(math.asin(DmgDir:Dot(FacingDir)))

	return ApproachAngle > 45
end

local function IsHitToBack(ply, dmg)
	local FacingDir, DmgDir = ply:GetAimVector(), dmg:GetDamageForce():GetNormalized()
	local ApproachAngle = -math.deg(math.asin(DmgDir:Dot(FacingDir)))

	return ApproachAngle < -30
end

local NonProtectiveSlots = {"ears", "waist"}

local function GetProtectionFromSlot(ply, slot, dmg, dmgAmt, protectionMul, shouldDmgArmor, cumulativeCoverage)
	local Protection, Busted = 0, false

	if not(ply.EZarmor and ply.EZarmor.items) then return Protection, Busted end
	for id, armorData in pairs(ply.EZarmor.items) do
		local ArmorInfo = table.FullCopy(JMod.ArmorTable[armorData.name])

		if armorData.tgl and ArmorInfo.tgl then
			ArmorInfo = table.Merge(ArmorInfo, ArmorInfo.tgl)

			-- for some fucking reason table.Merge doesn't copy empty tables
			for k, v in pairs(ArmorInfo.tgl) do
				if type(v) == "table" then
					if #table.GetKeys(v) == 0 then
						ArmorInfo[k] = {}
					end
				end
			end
		end

		if ArmorInfo then
			local CumulativeDivisor = 0

			for armorSlot, coverage in pairs(ArmorInfo.slots) do
				if not table.HasValue(NonProtectiveSlots, armorSlot) then
					CumulativeDivisor = CumulativeDivisor + 1
				end
			end

			for armorSlot, coverage in pairs(ArmorInfo.slots) do
				if not(table.HasValue(NonProtectiveSlots, armorSlot)) and (armorSlot == slot) then
					if not(ArmorInfo.def) then break end
					for damType, damProtection in pairs(ArmorInfo.def) do
						if IsDamageThisType(dmg, damType) then
							Protection = Protection + damProtection * coverage * protectionMul

							if cumulativeCoverage then
								Protection = Protection / (CumulativeDivisor or 1)
							end

							if shouldDmgArmor then
								if not IsDamageOneOfTypes(dmg, JMod.BiologicalDmgTypes) then
									local ArmorDmgAmt = Protection * dmgAmt * JMod.Config.Armor.DegradationMult

									if damType == DMG_BUCKSHOT then
										ArmorDmgAmt = ArmorDmgAmt / 2.5
									end

									if ArmorInfo.resist then
										for dtyp, dres in pairs(ArmorInfo.resist) do
											if IsDamageThisType(dmg, dtyp) then
												ArmorDmgAmt = ArmorDmgAmt * (1 - dres)
												break
											end
										end
									end

									armorData.dur = armorData.dur - ArmorDmgAmt

									if armorData.dur < ArmorInfo.dur * .25 then
										JMod.EZarmorWarning(ply, "armor piece is almost destroyed!")
									end

									if armorData.dur <= 0 then
										JMod.RemoveArmorByID(ply, id, true)
										Busted = true
									end
								elseif armorData.chrg and armorData.chrg.chemicals then
									JMod.DepleteArmorChemicalCharge(ply, Protection * dmgAmt * .02)

									if armorData.chrg.chemicals <= 0 then
										Protection = 0
									end
								end
							end

							break
						end
					end

					break
				end
			end
		end
	end

	return Protection, Busted
end

local function LocationalDmgHandling(ply, hitgroup, dmg)
	local Mul = 1
	local AmmoTypeID, AmmoAPmul, AmmoHPmul = dmg:GetAmmoType(), 1, 1

	if AmmoTypeID then
		local AmmoName = game.GetAmmoName(AmmoTypeID)

		if AmmoName then
			local AmmoInfo = JMod.GetAmmoSpecs(AmmoName)

			if AmmoInfo then
				AmmoAPmul = 1 - (AmmoInfo.armorpiercing or 0)
				AmmoHPmul = 1 + (AmmoInfo.expanding or 0)
			end
		end
	end

	if ply.EZarmor and #table.GetKeys(ply.EZarmor.items) > 0 then
		local RelevantSlots, DmgAmt = {}, dmg:GetDamage()

		if hitgroup == HITGROUP_HEAD then
			if IsHitToFace(ply, dmg) then
				RelevantSlots.eyes = .5
				RelevantSlots.mouthnose = .5
			else
				RelevantSlots.head = 1
			end
		elseif hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_GENERIC then
			if IsHitToBack(ply, dmg) then
				RelevantSlots.chest = 1
				RelevantSlots.back = 1
			else
				RelevantSlots.chest = 1
			end
		elseif hitgroup == HITGROUP_STOMACH then
			RelevantSlots.abdomen = .5
			RelevantSlots.pelvis = .5
		elseif hitgroup == HITGROUP_RIGHTARM then
			RelevantSlots.rightshoulder = .5
			RelevantSlots.rightforearm = .5
		elseif hitgroup == HITGROUP_LEFTARM then
			RelevantSlots.leftshoulder = .5
			RelevantSlots.leftforearm = .5
		elseif hitgroup == HITGROUP_RIGHTLEG then
			RelevantSlots.rightthigh = .5
			RelevantSlots.rightcalf = .5
		elseif hitgroup == HITGROUP_LEFTLEG then
			RelevantSlots.leftthigh = .5
			RelevantSlots.leftcalf = .5
		end

		local Protection, ArmorPieceBroke = 0, false

		for slot, relevance in pairs(RelevantSlots) do
			local ProtectionForThisSlot, Busted = GetProtectionFromSlot(ply, slot, dmg, DmgAmt, relevance, true, false)
			--print("[JMod] Protection for " .. slot .. ": " .. ProtectionForThisSlot)
			Protection = Protection + ProtectionForThisSlot
			ArmorPieceBroke = ArmorPieceBroke or Busted
		end

		local NoProtection = Protection <= .05

		if NoProtection then
			Mul = Mul * AmmoHPmul
		else
			Protection = Protection * AmmoAPmul

			if AmmoAPmul < 1 and JMod.Config.QoL.RealisticLocationalDamage then
				Mul = Mul * JMod.BodyPartDamageMults[hitgroup] ^ (.6 + (1 - AmmoAPmul))
			end
		end

		Mul = (Mul * (1 - Protection)) / JMod.Config.Armor.ProtectionMult

		-- if there's no armor on the struck bodypart
		if NoProtection then 
			if JMod.Config.QoL.RealisticLocationalDamage then
				Mul = Mul * JMod.BodyPartDamageMults[hitgroup]
			end
		else
			sound.Play("snds_jack_gmod/ricochet_"..math.random(1,2)..".ogg", ply:GetShootPos() + VectorRand() * 10, 70, math.random(80,120))
		end

		if ArmorPieceBroke then
			JMod.CalcSpeed(ply)
			JMod.EZarmorSync(ply)
		end
	elseif JMod.Config.QoL.RealisticLocationalDamage then
		Mul = Mul * (JMod.BodyPartDamageMults[hitgroup] or 1) * AmmoHPmul
	else
		Mul = Mul * AmmoHPmul
	end

	dmg:ScaleDamage(Mul)
end

local function FullBodyDmgHandling(ply, dmg, biological, isInSewage)
	--if (#table.GetKeys(ply.EZarmor.items) <= 0) then return end
	local Mul, Protection, DmgAmt, ArmorPieceBroke = 1, 0, dmg:GetDamage(), false

	for slot, healthMult in pairs(JMod.BodyPartHealthMults) do
		local ProtectionForThisSlot, Busted = GetProtectionFromSlot(ply, slot, dmg, DmgAmt, (biological and 1) or healthMult, true, biological)
		Protection = Protection + ProtectionForThisSlot
		ArmorPieceBroke = ArmorPieceBroke or Busted
	end

	local NoProtection, AmmoTypeID, AmmoAPmul, AmmoHPmul = Protection <= .05, dmg:GetAmmoType(), 1, 1

	if AmmoTypeID then
		local AmmoName = game.GetAmmoName(AmmoTypeID)

		if AmmoName then
			local AmmoInfo = JMod.GetAmmoSpecs(AmmoName)

			if AmmoInfo then
				AmmoAPmul = 1 - (AmmoInfo.armorpiercing or 0)
				AmmoHPmul = 1 + (AmmoInfo.expanding or 0)
			end
		end
	end

	if NoProtection then
		Mul = Mul * AmmoHPmul
	else
		Protection = Protection * AmmoAPmul
	end

	Mul = (Mul * 1 - (Protection * JMod.Config.Armor.ProtectionMult))

	if Mul < .001 then
		dmg:ScaleDamage(0)
	else
		dmg:ScaleDamage(Mul)

		if isInSewage then
			if math.Rand(0, 1) < JMod.Config.Particles.SludgeVirusInfectChance then
				JMod.ViralInfect(ply, game.GetWorld())
			end
		end
	end

	if ArmorPieceBroke then
		JMod.CalcSpeed(ply)
		JMod.EZarmorSync(ply)
	end
end

hook.Add("ScalePlayerDamage", "JMod_ScalePlayerDamage", function(ply, hitgroup, dmginfo)
	if ply.EZarmor then
		LocationalDmgHandling(ply, hitgroup, dmginfo)
	end
end)

hook.Add("ScaleNPCDamage", "JMod_ScaleNPCdamage", function(npc, hitgroup, dmginfo)
	LocationalDmgHandling(npc, hitgroup, dmginfo)
end)

hook.Add("EntityTakeDamage", "JMod_EntityTakeDamage", function(victim, dmginfo)
	if victim:IsPlayer() then 
		victim.JMod_IsSleeping = false
		if victim.EZarmor then
			local Helf, IsPiercingDmg, Att = victim:Health(), IsDamageOneOfTypes(dmginfo, JMod.PiercingDmgTypes), dmginfo:GetAttacker()
			local IsShit = bit.band(util.PointContents(victim:GetShootPos()), 268435472) == 268435472
			local IsInSewage = (dmginfo:IsDamageType(DMG_ACID) or dmginfo:IsDamageType(DMG_RADIATION)) and IsShit

			if IsDamageOneOfTypes(dmginfo, JMod.LocationalDmgTypes) then
				-- scaling handled in scaleplayerdamage
			elseif IsDamageOneOfTypes(dmginfo, JMod.FullBodyDmgTypes) then
				FullBodyDmgHandling(victim, dmginfo, false, IsInSewage)
			elseif IsDamageOneOfTypes(dmginfo, JMod.BiologicalDmgTypes) then
				FullBodyDmgHandling(victim, dmginfo, true, IsInSewage)
			end

			if JMod.Config.QoL.BleedDmgMult > 0 and IsPiercingDmg then
				timer.Simple(0, function()
					local NewHelf = victim:Health()
					local HelfLoss = Helf - NewHelf

					if NewHelf > 0 and HelfLoss > 0 then
						victim.EZbleeding = (victim.EZbleeding or 0) + HelfLoss * JMod.Config.QoL.BleedDmgMult
						victim.EZbleedAttacker = Att
						JMod.SyncBleeding(victim)
					end
				end)
			end
		end
	end
end)

function JMod.RemoveAllArmor(ply)
	for k, v in pairs(ply.EZarmor.items) do
		JMod.RemoveArmorByID(ply, k, false)
	end

	JMod.EZarmorSync(ply)
end

function JMod.CalcSpeed(ply)
	local Walk, Run, TotalWeight = ply.EZoriginalWalkSpeed or 200, ply.EZoriginalRunSpeed or 400, 0
	local Phys = ply:GetPhysicsObject()

	for k, v in pairs(ply.EZarmor.items) do
		local ArmorInfo = JMod.ArmorTable[v.name]
		TotalWeight = TotalWeight + ArmorInfo.wgt
	end

	if ply.JModInv and ply.JModInv.weight then
		TotalWeight = TotalWeight + ply.JModInv.weight
	end
	
	ply.EZarmor.totalWeight = TotalWeight

	local WeighedFrac = TotalWeight / 250
	ply.EZarmor.speedfrac = math.Clamp(1 - (.8 * WeighedFrac * JMod.Config.Armor.WeightMult), .05, 1)

	hook.Run("JMod_CalcArmorSpeed", ply)

	if ply.EZarmor.totalWeight >= 150 then
		JMod.Hint(ply, "chonky boi")
	end
end

hook.Add("PlayerFootstep", "JMOD_PlayerFootstep", function(ply, pos, foot, snd, vol, filter)
	if ply.EZarmor then
		--local Num=#table.GetKeys(ply.EZarmor.items)
		if ply.EZarmor.totalWeight >= 150 then
			ply:EmitSound("snd_jack_gear" .. tostring(math.random(1, 6)) .. ".ogg", 58, math.random(70, 130))
		end
		--local InventoryItems = ply.JModInv and ply.JModInv.items
	end
end)

function JMod.RemoveArmorByID(ply, ID, broken)
	local Info = ply.EZarmor.items[ID]
	if not Info then return end
	local Specs = JMod.ArmorTable[Info.name]

	if Specs.eff and Specs.eff.weapon then
		local Wep = ply:GetWeapon(Specs.eff.weapon)

		if IsValid(Wep) then
			local PastSwep = ply:GetPreviousWeapon()
			if IsValid(PastSwep) and (ply:GetActiveWeapon() == Wep) then ply:SelectWeapon(PastSwep:GetClass()) end
			Wep:Remove()
		end
	end

	timer.Simple(math.Rand(0, .5), function()
		if broken then
			ply:EmitSound("snds_jack_gmod/armorbreak.ogg", 60, math.random(80, 120))
			ply:PrintMessage(HUD_PRINTTALK, Info.name .. " has been destroyed")
		else
			if Specs.snds and Specs.snds.uneq then
				ply:EmitSound(Specs.snds.uneq, 60, math.random(80, 120))
			else
				ply:EmitSound(table.Random(EquipSounds), 60, math.random(80, 120))
			end
		end
	end)

	local Ent -- This is for if we can stow stuff in the armor when it's unequpped

	if broken then
		if Specs.eff and Specs.eff.explosive then
			local FireAmt = (Info.chrg and Info.chrg.fuel and math.random(2, 4)) or 0
			JMod.EnergeticsCookoff(ply:GetPos(), game.GetWorld(), 1, 1, 0, FireAmt)
		end
	else
		Ent = ents.Create(Specs.ent)
		Ent:SetPos(ply:GetShootPos() + ply:GetAimVector() * 30 + VectorRand() * math.random(1, 20))
		Ent:SetAngles(AngleRand())
		Ent.Durability = Info.dur

		if Info.chrg then
			Ent.ArmorCharges = table.FullCopy(Info.chrg)
		end

		Ent.EZID = ID
		Ent:SetColor(Info.col)
		Ent:Spawn()
		Ent:Activate()
		Ent:GetPhysicsObject():SetVelocity(ply:GetVelocity())
	end

	if Specs.plymdl then
		-- if this is a suit, we need to reset the player's model when he takes it off
		if ply.EZoriginalPlayerModel then
			JMod.SetPlayerModel(ply, ply.EZoriginalPlayerModel)
		end

		ply:SetColor(Color(255, 255, 255))
		ply.EZarmor.suited = false
		ply.EZarmor.bodygroups = nil
	end

	ply.EZarmor.items[ID] = nil
	
	local StowItems = not(broken) and Specs.storage and IsValid(Ent)

	local RemovedItems = JMod.UpdateInv(ply, StowItems, true)

	if StowItems and not(table.IsEmpty(RemovedItems)) then
		for _, v in ipairs(RemovedItems) do
			timer.Simple(0, function()
				local Success = JMod.AddToInventory(Ent, v)
			end)
		end
	end

	hook.Run("JMod_ArmorRemoved", ply, Info, Specs, Ent, broken)

	return Ent
end

local function GetArmorBySlot(currentArmorItems, slot)
	for id, currentArmorData in pairs(currentArmorItems) do
		if JMod.ArmorTable[currentArmorData.name].slots[slot] ~= nil then return id, currentArmorData end
	end

	return nil, nil
end

local function GetAreSlotsClear(currentArmorItems, newArmorName)
	local NewArmorInfo = JMod.ArmorTable[newArmorName]
	local RequiredSlots = NewArmorInfo.slots

	for id, currentArmorData in pairs(currentArmorItems) do
		local CurrentArmorInfo = JMod.ArmorTable[currentArmorData.name]

		for newSlotName, newCoverage in pairs(RequiredSlots) do
			for oldSlotName, oldCoverage in pairs(CurrentArmorInfo.slots) do
				if oldSlotName == newSlotName then return false, id end
			end
		end
	end

	return true, nil
end

function JMod.SetPlayerModel(ply, mod)
	ply:SetModel(mod)
	local simplemodel = player_manager.TranslateToPlayerModelName(mod)
	local info = player_manager.TranslatePlayerHands(simplemodel)
	local Hans = ply:GetHands()

	if IsValid(Hans) then
		Hans:SetModel(info.model)
	end
end

function JMod.EZ_Equip_Armor(ply, nameOrEnt)
	local NewArmorName = nameOrEnt
	local NewArmorID, NewArmorDurability, NewArmorColor, NewArmorSpecs, NewArmorCharges

	if type(nameOrEnt) ~= "string" then
		if not IsValid(nameOrEnt) then return end
		NewArmorName = nameOrEnt.ArmorName
		NewArmorSpecs = JMod.ArmorTable[NewArmorName]
		NewArmorID = nameOrEnt.EZID
		NewArmorDurability = nameOrEnt.Durability or NewArmorSpecs.dur
		NewArmorColor = nameOrEnt:GetColor()
		NewArmorCharges = nameOrEnt.ArmorCharges
		nameOrEnt:Remove()
	else
		NewArmorSpecs = JMod.ArmorTable[NewArmorName]
		NewArmorID = JMod.GenerateGUID()
		NewArmorColor = Color(128, 128, 128)
		NewArmorDurability = NewArmorSpecs.dur

		if NewArmorSpecs.chrg then
			NewArmorCharges = table.FullCopy(NewArmorSpecs.chrg)
		end
	end

	local AreSlotsClear, ConflictingItemID = GetAreSlotsClear(ply.EZarmor.items, NewArmorName)

	while not AreSlotsClear do
		JMod.RemoveArmorByID(ply, ConflictingItemID)
		AreSlotsClear, ConflictingItemID = GetAreSlotsClear(ply.EZarmor.items, NewArmorName)
	end

	local NewVirtualArmorItem = {
		name = NewArmorName,
		dur = NewArmorDurability,
		col = NewArmorColor,
		chrg = NewArmorCharges,
		id = NewArmorID,
		tgl = false
	}

	ply.EZarmor.items[NewArmorID] = NewVirtualArmorItem

	if NewArmorSpecs.plymdl then
		-- if this is a suit, we need to set the player's model and color accordingly
		ply.EZarmor.suited = true
		ply.EZarmor.bodygroups = NewArmorSpecs.bdg or nil

		if not ply.EZoriginalPlayerModel then
			ply.EZoriginalPlayerModel = ply:GetModel()
		end

		JMod.SetPlayerModel(ply, NewArmorSpecs.plymdl)
		ply:SetColor(NewArmorColor)

		if NewArmorSpecs.bdg then
			for k, v in pairs(NewArmorSpecs.bdg) do
				ply:SetBodygroup(k, v)
			end
		end
	end

	if NewArmorSpecs.snds and NewArmorSpecs.snds.eq then
		ply:EmitSound(NewArmorSpecs.snds.eq, 60, math.random(80, 120))
	else
		ply:EmitSound(table.Random(EquipSounds), 60, math.random(80, 120))
	end

	if IsValid(nameOrEnt) and nameOrEnt.JModInv then
		nameOrEnt.KeepJModInv = true
		for _, v in ipairs(nameOrEnt.JModInv.items) do
			JMod.AddToInventory(ply, v.ent)
		end
		for k, v in pairs(nameOrEnt.JModInv.EZresources) do
			JMod.AddToInventory(ply, {k, v})
		end
		nameOrEnt.KeepJModInv = false
	end

	JMod.CalcSpeed(ply)
	JMod.EZarmorSync(ply)
end

net.Receive("JMod_Inventory", function(ln, ply)
	if not ply:Alive() then return end
	local ActionType = net.ReadInt(8) -- 1: Remove armor | 2: Toggle armor | 3: Repair armor | 4: Recharge armor | 5: Color armor
	local ID = net.ReadString()

	if ActionType == 1 then
		
		JMod.RemoveArmorByID(ply, ID)
	elseif ActionType == 2 then
		local ItemData = ply.EZarmor.items[ID]
		if ItemData and JMod.ArmorTable[ItemData.name].tgl then
			ply.EZarmor.items[ID].tgl = not ply.EZarmor.items[ID].tgl
		end
	elseif ActionType == 3 then
		local ItemData = ply.EZarmor.items[ID]
		local ItemInfo = JMod.ArmorTable[ItemData.name]
		local RepairRecipe, RepairStatus, BuildRecipe = {}, 0, nil
		for k, v in pairs(JMod.Config.Craftables) do
			if v.results == ItemInfo.ent then
				if ItemData.dur < ItemInfo.dur * .9 then
					BuildRecipe = v.craftingReqs
				end

				break
			end
		end

		if not BuildRecipe then
			BuildRecipe = JMod.BackupArmorRepairRecipes[ItemData.name]
		end

		local AvailableResources = {}
		if BuildRecipe then
			local DamagedFraction = 1 - (ItemData.dur / ItemInfo.dur)
			for resourceName, resourceAmt in pairs(BuildRecipe) do
				-- If it requires things it also consumes, like fuel, gas and chemicals, we shouldn't require those for repair
				if ItemInfo.chrg[resourceName] then
					resourceAmt = 0
				end
				local RequiredAmt = math.floor(resourceAmt * DamagedFraction * 1.2) -- 20% efficiency penalty for not needing a workbench

				if RequiredAmt > 0 then
					RepairRecipe[resourceName] = RequiredAmt
				end
			end

			RepairStatus = 1

			---
			AvailableResources = JMod.CountResourcesInRange(nil, nil, ply)
			if JMod.HaveResourcesToPerformTask(nil, nil, RepairRecipe, ply, AvailableResources) then
				RepairStatus = 2
				JMod.ConsumeResourcesInRange(BuildRecipe, nil, nil, ply)
				ItemData.dur = ItemInfo.dur
			end
		end

		if RepairStatus == 0 then
			ply:PrintMessage(HUD_PRINTCENTER, "Item can not be repaired")
		elseif RepairStatus == 1 then
			local mats = ""

			for k, v in pairs(RepairRecipe) do
				local AmountNeeded = math.max(0, v - (AvailableResources[k] or 0))
				if next(RepairRecipe, k) ~= nil then
					mats = mats .. k .. " x" .. tostring(AmountNeeded) .. ", "
				else
					mats = mats .. k .. " x" .. tostring(AmountNeeded)
				end

			end

			ply:PrintMessage(HUD_PRINTCENTER, "Missing resources for repair, need: \n" .. mats)
		elseif RepairStatus == 2 then
			ply:PrintMessage(HUD_PRINTCENTER, "Item repaired")

			for i = 1, 10 do
				sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".ogg", ply:GetPos(), 60, math.random(80, 120))
			end
		end
	elseif ActionType == 4 then
		local ItemData = ply.EZarmor.items[ID]
		local ItemInfo = JMod.ArmorTable[ItemData.name]
		if ItemInfo.chrg  then
			local RechargeRecipe, RechargeStatus, PartialRecharge = {}, 0, false

			for resourceName, maxAmt in pairs(ItemInfo.chrg) do
				local missing = maxAmt - ItemData.chrg[resourceName]

				if missing > 0 then
					RechargeRecipe[resourceName] = missing
					RechargeStatus = 1
				end
			end

			if RechargeStatus == 1 then
				local AvailableResources, ResourcesToConsume = JMod.CountResourcesInRange(nil, nil, ply), {}

				for resourceName, missing in pairs(RechargeRecipe) do
					missing = math.ceil(missing)
					if AvailableResources[resourceName] then
						local AmtToConsume = math.Clamp(AvailableResources[resourceName], 0, missing)
						ResourcesToConsume[resourceName] = math.Clamp(AvailableResources[resourceName], 0, missing)
						ItemData.chrg[resourceName] = math.Clamp(ItemData.chrg[resourceName] + AmtToConsume, 0, ItemInfo.chrg[resourceName])

						if AmtToConsume >= missing then
							RechargeRecipe[resourceName] = nil
							PartialRecharge = true
						else
							RechargeRecipe[resourceName] = missing - AmtToConsume
							PartialRecharge = true
						end
					end
				end

				JMod.ConsumeResourcesInRange(ResourcesToConsume, nil, nil, ply)

				if table.IsEmpty(RechargeRecipe) then
					RechargeStatus = 2
				end
			end

			if RechargeStatus == 0 then
				ply:PrintMessage(HUD_PRINTCENTER, "Item can not be recharged")

			elseif RechargeStatus == 1 then
				local mats = ""

				for k, v in pairs(RechargeRecipe) do
					if next(RechargeRecipe, k) ~= nil then
						mats = mats .. k .. ", "
					else
						mats = mats .. k
					end
				end

				if PartialRecharge then
					ply:PrintMessage(HUD_PRINTCENTER, "Item partially recharged, still needs: " .. mats)
					sound.Play("items/ammo_pickup.ogg", ply:GetPos(), 60, math.random(100, 140))
				else
					ply:PrintMessage(HUD_PRINTCENTER, "Missing resources for recharge, needs: " .. mats)
				end

			elseif RechargeStatus == 2 then
				ply:PrintMessage(HUD_PRINTCENTER, "Item recharged")
				sound.Play("items/ammo_pickup.ogg", ply:GetPos(), 60, math.random(100, 140))
			end
		end
	elseif ActionType == 5 then
		local NewColor = net.ReadColor()
		if ID == "" then
			for k, v in pairs(ply.EZarmor.items) do
				local ItemInfo = JMod.ArmorTable[v.name]
				if not ItemInfo["clrForced"] then
					ply.EZarmor.items[k].col = {r = NewColor.r, g = NewColor.g, b = NewColor.b, a = 255}
				end
			end
		else
			local ItemData = ply.EZarmor.items[ID]
			local ItemInfo = JMod.ArmorTable[ItemData.name]
			if not ItemInfo["clrForced"] then
				ply.EZarmor.items[ID].col = {r = NewColor.r, g = NewColor.g, b = NewColor.b, a = 255}
			end
		end
	end

	JMod.CalcSpeed(ply)
	JMod.EZarmorSync(ply)
end)

hook.Add("OnDamagedByExplosion", "JModOnDamagedByExplosion", function(ply, dmg)
	if JMod.PlyHasArmorEff(ply, "earPro") then return true end
end)

concommand.Add("jmod_debug_fullarmor", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	local target = ply

	if args[1] == "looking" then
		target = ply:GetEyeTrace().Entity
	elseif tonumber(args[1]) and player.GetByID(tonumber(args[1])) then
		target = player.GetByID(tonumber(args[1]))
	end

	if not IsValid(target) then
		print("invalid target")

		return
	end

	JMod.EZ_Equip_Armor(target, "Ultra-Heavy-Helmet")
	JMod.EZ_Equip_Armor(target, "Heavy-Vest")
	JMod.EZ_Equip_Armor(target, "Pelvis-Panel")
	JMod.EZ_Equip_Armor(target, "Heavy-Left-Shoulder")
	JMod.EZ_Equip_Armor(target, "Heavy-Right-Shoulder")
	JMod.EZ_Equip_Armor(target, "Left-Forearm")
	JMod.EZ_Equip_Armor(target, "Right-Forearm")
	JMod.EZ_Equip_Armor(target, "Heavy-Left-Thigh")
	JMod.EZ_Equip_Armor(target, "Heavy-Right-Thigh")
	JMod.EZ_Equip_Armor(target, "Left-Calf")
	JMod.EZ_Equip_Armor(target, "Right-Calf")
end, nil, "Adds full armour onto yourself.")

concommand.Add("jmod_debug_givearmortotarget", function(ply, cmd, args)
	if not (ply and ply:IsSuperAdmin()) then return end
	local playa = ply:GetEyeTrace().Entity

	if playa and playa:IsPlayer() then
		if JMod.ArmorTable[args[1]] then
			JMod.EZ_Equip_Armor(playa, args[1])
			print("gave", playa, args[1])
		else
			print("invalid armor name")
		end
	else
		print("invalid aim target")
	end
end, nil, "Adds full armour to your target.")

concommand.Add("jmod_debug_removearmor", function(ply, cmd, args)
	if not ply:IsSuperAdmin() then return end
	local target = ply

	if args[1] == "looking" then
		target = ply:GetEyeTrace().Entity
	elseif tonumber(args[1]) and player.GetByID(tonumber(args[1])) then
		target = player.GetByID(tonumber(args[1]))
	end

	if not IsValid(target) then
		print("invalid target")

		return
	end

	for k, v in pairs(ply.EZarmor.items) do
		JMod.RemoveArmorByID(ply, k, tobool(args[2]))
	end
end, nil, "Removes armor from your target.")
