﻿local ANGLE = FindMetaTable("Angle")
local VECTOR = FindMetaTable("Vector")

function ANGLE:GetCopy()
	return Angle(self.p, self.y, self.r)
end

function VECTOR:GetCopy()
	return Vector(self.x, self.y, self.z)
end

function table.FullCopy(tab)
	if not tab then return nil end
	local res = {}

	for k, v in pairs(tab) do
		if type(v) == "table" then
			res[k] = table.FullCopy(v) -- we need to go derper
		elseif type(v) == "Vector" then
			res[k] = Vector(v.x, v.y, v.z)
		elseif type(v) == "Angle" then
			res[k] = Angle(v.p, v.y, v.r)
		else
			res[k] = v
		end
	end

	return res
end

local function Stringify(obj)
	if obj == false then return "false" end
	if not obj then return "" end
	local Str, Typ = "", type(obj)

	if Typ == "number" then
		Str = Str .. tostring(math.Round(obj, 4)) .. " "
	elseif Typ == "boolean" or Typ == "Player" or Typ == "NPC" then
		Str = Str .. tostring(obj) .. " "
	elseif Typ == "string" then
		Str = Str .. obj .. " "
	else
		if Typ ~= "table" then
			Str = Str .. tostring(obj)
		else
			for k, v in pairs(obj) do
				Str = Str .. Stringify(k) .. ": " .. Stringify(v) .. ", "
			end
		end
	end

	return Str
end

function jprint(...)
	local items, printstr = {...}, ""

	for k, v in pairs(items) do
		printstr = printstr .. Stringify(v)
	end

	print(printstr)

	if SERVER then
		player.GetAll()[1]:PrintMessage(HUD_PRINTTALK, printstr)
		player.GetAll()[1]:PrintMessage(HUD_PRINTCENTER, printstr)
	elseif CLIENT then
		LocalPlayer():ChatPrint(printstr)
	end
end

function JMod.SetWepSelectIcon(wep, path, shouldRotate)
	local Mat = Material(path .. ".png")

	function wep:DrawWeaponSelection(x, y, w, h, a)
		surface.SetDrawColor(255, 255, 255, a)
		surface.SetMaterial(Mat)
		local Diff = w - h

		if shouldRotate then
			surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, w * .8, w * .8, -35)
		else
			surface.DrawTexturedRect(x + Diff / 2, y - h * .1, h, h)
		end
	end
end

function JMod.CalcWorkSpreadMult(ent, newPos)
	ent.EZworkSpread = ent.EZworkSpread or {
		locations = {},
		lastHit = 0
	}

	local Time = CurTime()

	--reset everything
	if Time - ent.EZworkSpread.lastHit > 3 then
		ent.EZworkSpread.locations = {}
	end

	local Size, Mult, LocalPos, Barycenter = (ent:OBBMaxs() - ent:OBBMins()):Length(), 1, ent:WorldToLocal(newPos), Vector(0, 0, 0)

	if #ent.EZworkSpread.locations > 0 then
		for k, v in pairs(ent.EZworkSpread.locations) do
			Barycenter = Barycenter + v
		end

		Barycenter = Barycenter / #ent.EZworkSpread.locations
	end

	table.insert(ent.EZworkSpread.locations, 1, LocalPos)

	if #ent.EZworkSpread.locations > 4 then
		table.remove(ent.EZworkSpread.locations)
	end

	local Distance = LocalPos:Distance(Barycenter)
	local DistanceFraction = Distance / Size
	Mult = Mult + (5 * DistanceFraction)
	ent.EZworkSpread.lastHit = Time

	return Mult
end

function JMod.GoodBadColor(frac, returnAsStruct, opacity)
	-- color tech from bfs2114
	local r, g, b = math.Clamp(3 - frac * 4, 0, 1), math.Clamp(frac * 2, 0, 1), math.Clamp(-3 + frac * 4, 0, 1)
	if (returnAsStruct) then return Color(r * 255, g * 255, b * 255, opacity or 255) end
	return r * 255, g * 255, b * 255, opacity or 255
end

function JMod.WhomILookinAt(ply, cone, dist)
	local CreatureTr, ObjTr, OtherTr = nil, nil, nil

	for i = 1, 150 * cone do
		local Vec = (ply:GetAimVector() + VectorRand() * cone):GetNormalized()

		local Tr = util.QuickTrace(ply:GetShootPos(), Vec * dist, {ply})

		if Tr.Hit and not Tr.HitSky and Tr.Entity then
			local Ent, Class = Tr.Entity, Tr.Entity:GetClass()

			if Ent:IsPlayer() or Ent:IsNPC() then
				CreatureTr = Tr
			elseif (Class == "prop_physics") or (Class == "prop_physics_multiplayer") or (Class == "prop_ragdoll") then
				ObjTr = Tr
			else
				OtherTr = Tr
			end
		end
	end

	if CreatureTr then return CreatureTr.Entity, CreatureTr.HitPos, CreatureTr.HitNormal end
	if ObjTr then return ObjTr.Entity, ObjTr.HitPos, ObjTr.HitNormal end
	if OtherTr then return OtherTr.Entity, OtherTr.HitPos, OtherTr.HitNormal end

	return nil, nil, nil
end

--
function JMod.IsDoor(ent)
	local Class = ent:GetClass()

	return (Class == "prop_door") or (Class == "prop_door_rotating") or (Class == "func_door") or (Class == "func_door_rotating")
end

function JMod.VisCheck(pos, target, sourceEnt)
	local filter = {}

	if IsValid(sourceEnt) then
		pos = pos or sourceEnt:LocalToWorld(sourceEnt:OBBCenter())
		table.insert(filter, sourceEnt)
		if IsValid(sourceEnt:GetOwner()) then table.insert(filter, sourceEnt:GetOwner()) end
	end

	if IsValid(target) and target.GetPos then
		if target:GetNoDraw() then return false end
		table.insert(filter, target)
		target = target:LocalToWorld(target:OBBCenter())
	end

	return not util.TraceLine({
		start = pos,
		endpos = target,
		filter = filter,
		mask = MASK_SOLID
	}).Hit
end

function JMod.CountResourcesInRange(pos, range, sourceEnt, cache)
	if cache then return cache end
	pos = pos or (IsValid(sourceEnt) and sourceEnt:LocalToWorld(sourceEnt:OBBCenter()))
	local Results = {}
	--debugoverlay.Cross(pos, 10, 2, Color(255, 255, 255), true)

	for k, obj in pairs(ents.FindInSphere(pos, range or 150)) do
		if obj.GetEZsupplies then
			local Supplies = obj:GetEZsupplies()
			for k, v in pairs(Supplies) do
				if k ~= "generic" then 
					Results[k] = (Results[k] or 0) + v
				end
			end
		end 
		if obj.JModInv then
			local Supplies = obj.JModInv.EZresources or {}
			for k, v in pairs(Supplies) do
				if k ~= "generic" then 
					Results[k] = (Results[k] or 0) + v
				end
			end
		end
	end

	return Results
end

function JMod.HaveResourcesToPerformTask(pos, range, requirements, sourceEnt, cache, mult)
	mult = mult or 1
	local RequirementsMet, ResourcesInRange = true, cache or JMod.CountResourcesInRange(pos, range, sourceEnt, cache)

	local StuffLeftToGet = {}

	for typ, amt in pairs(requirements) do
		if istable(amt) then
			local FlexibleReqs = false
			for Typ, Amt in pairs(amt) do
				if (ResourcesInRange[Typ] and (ResourcesInRange[Typ] >= math.ceil(Amt * mult))) then
					FlexibleReqs = true
					break
				end
			end
			if not(FlexibleReqs) then
				RequirementsMet = false
				break
			end
		elseif not (ResourcesInRange[typ] and (ResourcesInRange[typ] >= math.ceil(amt * mult))) then
			if (amt - (ResourcesInRange[typ] or 0)) > 0 then
				StuffLeftToGet[typ] = amt - (ResourcesInRange[typ] or 0)
			end
			RequirementsMet = false
			--break
		end
	end

	return RequirementsMet, StuffLeftToGet
end

function JMod.ConsumeResourcesInRange(requirements, pos, range, sourceEnt, useResourceEffects, propsToConsume, mult)
	mult = mult or 1
	pos = pos or (sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter()))
	local AllDone, Attempts, RequirementsRemaining = false, 0, table.FullCopy(requirements)

	while not (AllDone or (Attempts > 1000)) do
		local TypesNeeded = table.GetKeys(RequirementsRemaining)

		if TypesNeeded and (#TypesNeeded > 0) then
			local ResourceTypeToLookFor = TypesNeeded[1]
			local AmountWeNeed = math.ceil(RequirementsRemaining[ResourceTypeToLookFor] * mult)
			
			if propsToConsume then
				for entID, yield in pairs(propsToConsume) do
					local HasWhatWeNeed = false
					for typ, amt in pairs(yield) do
						if RequirementsRemaining[typ] then
							RequirementsRemaining[typ] = RequirementsRemaining[typ] - amt
							HasWhatWeNeed = true
							if (RequirementsRemaining[typ] <= 0) then
								RequirementsRemaining[typ] = nil
							end
						end
					end
					local Ent = Entity(entID)
					--[[if Ent.JModInv then
						for _, v in ipairs(Ent.JModInv.items) do
							JMod.RemoveFromInventory(Ent, v.ent, pos + VectorRand() * 50)
						end
					end--]]
					--print(Entity(entID), HasWhatWeNeed)
					if HasWhatWeNeed then
						SafeRemoveEntity(Ent) -- R.I.P. Props
					end
				end

				if not AllDone then
					propsToConsume = nil
				end
			else
				local Donor = JMod.FindResourceContainer(ResourceTypeToLookFor, 1, pos, range, sourceEnt) -- every little bit helps
				if IsValid(Donor) then
					local AmountToTake = 0
					if Donor.JModInv then
						local AmountWeCanTake = Donor.JModInv.EZresources[ResourceTypeToLookFor]
						AmountToTake = math.min(AmountWeNeed, AmountWeCanTake)
						Donor.JModInv.EZresources[ResourceTypeToLookFor] = (AmountWeCanTake - AmountToTake)
					else
						local AmountWeCanTake = Donor:GetEZsupplies(ResourceTypeToLookFor)
						if AmountWeCanTake then
							AmountToTake = math.min(AmountWeNeed, AmountWeCanTake)
							Donor:SetEZsupplies(ResourceTypeToLookFor, AmountWeCanTake - AmountToTake, sourceEnt and sourceEnt)
						end
					end
					RequirementsRemaining[ResourceTypeToLookFor] = RequirementsRemaining[ResourceTypeToLookFor] - AmountToTake
					if (useResourceEffects)then JMod.ResourceEffect(ResourceTypeToLookFor, Donor:LocalToWorld(Donor:OBBCenter()), pos, 1, 1, 1, 300) end

					if (RequirementsRemaining[ResourceTypeToLookFor] <= 0) then
						RequirementsRemaining[ResourceTypeToLookFor] = nil
					end
				end
			end
		else
			AllDone = true
		end

		Attempts = Attempts + 1
	end

	if next(RequirementsRemaining) then
		return AllDone, RequirementsRemaining
	else
		return AllDone
	end
end

function JMod.FindResourceContainer(typ, amt, pos, range, sourceEnt)
	if not typ then return end
	local ValidSource = IsValid(sourceEnt)
	pos = pos or (ValidSource and sourceEnt:LocalToWorld(sourceEnt:OBBCenter()))

	for k, obj in pairs(ents.FindInSphere(pos, range or 150)) do
		if not(sourceEnt and obj == sourceEnt) then
			if obj.GetEZsupplies then
				local AvailableResources = obj:GetEZsupplies(typ)
				if AvailableResources and (AvailableResources >= amt) then
					--if JMod.VisCheck(pos, obj, sourceEnt) then

						return obj
					--end
				end
			elseif obj.JModInv then
				local AvailableResources = obj.JModInv.EZresources[typ]
				if AvailableResources and (AvailableResources >= amt) then
					--if JMod.VisCheck(pos, obj, sourceEnt) then

						return obj
					--end
				end
			end
		end
	end
	-- We do this so that the search algorithm prefers other containers before the source
	if ValidSource then
		if sourceEnt.GetEZsupplies then
			local AvailableResources = sourceEnt:GetEZsupplies(typ)
			if AvailableResources then
				if (typ and AvailableResources >= amt) then

					return sourceEnt
				end
			end
		elseif sourceEnt.JModInv then
			local AvailableResources = sourceEnt.JModInv.EZresources[typ]
			if AvailableResources then
				if (typ and AvailableResources >= amt) then

					return sourceEnt
				end
			end
		end 
	end
end

function JMod.FindSuitableScrap(pos, range, sourceEnt)
	pos = (sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	local AvailableResources, LocalScrap = {}, {}

	for k, obj in ipairs(ents.FindInSphere(pos, range or 200)) do 
		local Clss = obj:GetClass()
		if (Clss == "prop_physics") or (Clss == "prop_ragdoll") then
			if obj:GetPhysicsObject():GetMass() <= 40 then
				local Yield, Message = JMod.GetSalvageYield(obj)

				if (#table.GetKeys(Yield) > 0) then
					local EntID = obj:EntIndex()
					LocalScrap[EntID] = {}
					for k, v in pairs(Yield) do
						LocalScrap[EntID][k] = v
						AvailableResources[k] = (AvailableResources[k] or 0) + v
					end
				end
			end
		end
	end

	return AvailableResources, LocalScrap
end

function JMod.TryCough(ent)
	local Time = CurTime()
	ent.EZcoughTime = ent.EZcoughTime or 0

	if Time > ent.EZcoughTime then
		local SoundName = "ambient/voices/cough" .. math.random(1, 4) .. ".wav"
		ent:EmitSound(SoundName, 75, math.random(90, 110))

		if ent.ViewPunch then
			ent:ViewPunch(Angle(math.random(0, 10), math.random(-2, 2), math.random(-2, 2)))
		end

		ent.EZcoughTime = CurTime() + SoundDuration("ambient/voices/cough" .. math.random(1, 4) .. ".wav") + math.Rand(.3, .6)
	end
end

function JMod.ClearLoS(ent1, ent2, ignoreWater, up, onlyHitWorld)
	if not IsValid(ent2) then return false end
	local SelfPos, TargPos = ent1:LocalToWorld(ent1:OBBCenter()) + ent1:GetUp() * (up or 1), ent2:LocalToWorld(ent2:OBBCenter())

	local Mask = MASK_SHOT + MASK_WATER
	if onlyHitWorld then
		Mask = MASK_SOLID_BRUSHONLY
	elseif ignoreWater then
		Mask = MASK_SHOT
	end

	local Tr = util.TraceLine({
		start = SelfPos,
		endpos = TargPos,
		filter = {ent1, ent2},
		mask = Mask
	})

	return not Tr.Hit
end

function JMod.PlyHasArmorEff(ply, eff)
	if IsValid(ply) and ply.EZarmor and ply.EZarmor.effects then 
		if eff then
			return ply.EZarmor.effects[eff]
		else
			return ply.EZarmor.effects
		end
	end

	return false
end

function JMod.IsAdmin(ply)
	return (game.SinglePlayer()) or ((IsValid(ply) and ply:IsPlayer()) and (ply:IsUserGroup("admin") or ply:IsUserGroup("superadmin")))
end

function JMod.DebugPos(pos, siz, label)
	siz = siz or 1
	label = label or math.Round(CurTime(), 2)
end

function JMod.DebugRay(pos, siz, label)
	siz = siz or 1
	label = label or math.Round(CurTime(), 2)
	-- ayo
end

local Holidays = {
	Christmas = {
		startDay = 350, -- 350, roughly the start of the week before the week of christmas most years
		endDay = 364 -- 364, roughly a week after
	},
	Easter = {
		startDay = 85, -- 85, roughly 5 days before easter most years
		endDay = 95 -- 95, roughly 3 days after
	}
}
local CachedHoliday, NextCheck = nil, 0
function JMod.GetHoliday()
	if not (JMod.Config.QoL.SeasonalEventsEnabled) then return end
	local Time = CurTime()
	if (NextCheck < Time) then
		local CurDay = tonumber(os.date("%j")) -- get day of the year, 1-366
		for holidayName, days in pairs(Holidays) do
			if (CurDay >= days.startDay and CurDay <= days.endDay) then
				CachedHoliday = holidayName
			end
		end
		NextCheck = Time + 360 -- only check once every hour
	end
	return CachedHoliday
end

function JMod.IsAltUsing(ply)
	if ply.EZaltUse ~= nil then return ply.EZaltUse end
	if ply.KeyDown then return ply:KeyDown(JMod.Config.General.AltFunctionKey) end
	return false
end