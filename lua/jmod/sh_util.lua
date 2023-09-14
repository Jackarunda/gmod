﻿local ANGLE = FindMetaTable("Angle")

function ANGLE:GetCopy()
	return Angle(self.p, self.y, self.r)
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

function JMod.VisCheck(pos, targPos, sourceEnt)
	local filter = {}
	pos = (sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos

	if sourceEnt then
		table.insert(filter, sourceEnt)
	end

	if targPos and targPos.GetPos then
		if targPos:GetNoDraw() then return false end
		table.insert(filter, targPos)
		targPos = targPos:LocalToWorld(targPos:OBBCenter())
	end

	return not util.TraceLine({
		start = pos,
		endpos = targPos,
		filter = filter,
		mask = MASK_SOLID_BRUSHONLY
	}).Hit
end

function JMod.CountResourcesInRange(pos, range, sourceEnt, cache)
	if cache then return cache end
	pos = (sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	local Results = {}

	for k, obj in pairs(ents.FindInSphere(pos, range or 150)) do
		if obj.GetEZsupplies and JMod.VisCheck(pos, obj, sourceEnt) and not(sourceEnt and obj == sourceEnt) then
			local Supplies = obj:GetEZsupplies()
			for k, v in pairs(Supplies) do
				Results[k] = (Results[k] or 0) + v
			end
		end
	end
	if sourceEnt and sourceEnt.GetEZsupplies then
		local Supplies = sourceEnt:GetEZsupplies()
		if Supplies then
			for k, v in pairs(Supplies) do
				Results[k] = (Results[k] or 0) + v
			end
		end
	end

	return Results
end

function JMod.HaveResourcesToPerformTask(pos, range, requirements, sourceEnt, cache)
	local RequirementsMet, ResourcesInRange = true, cache or JMod.CountResourcesInRange(pos, range, sourceEnt, cache)

	for typ, amt in pairs(requirements) do
		if not (ResourcesInRange[typ] and (ResourcesInRange[typ] >= amt)) then
			RequirementsMet = false
			break
		end
	end

	return RequirementsMet
end

function JMod.ConsumeResourcesInRange(requirements, pos, range, sourceEnt, useResourceEffects)
	pos = (sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos
	local AllDone, Attempts, RequirementsRemaining = false, 0, table.FullCopy(requirements)

	while not (AllDone or (Attempts > 1000)) do
		local TypesNeeded = table.GetKeys(RequirementsRemaining)

		if TypesNeeded and (#TypesNeeded > 0) then
			local ResourceTypeToLookFor = TypesNeeded[1]
			local AmountWeNeed = RequirementsRemaining[ResourceTypeToLookFor]
			local Donor = JMod.FindResourceContainer(ResourceTypeToLookFor, 1, pos, range, sourceEnt) -- every little bit helps
			if Donor then
				local AmountWeCanTake = Donor:GetEZsupplies(ResourceTypeToLookFor)
				local AmountToTake = math.min(AmountWeNeed, AmountWeCanTake)
				Donor:SetEZsupplies(ResourceTypeToLookFor, AmountWeCanTake - AmountToTake, sourceEnt and sourceEnt)
				RequirementsRemaining[ResourceTypeToLookFor] = RequirementsRemaining[ResourceTypeToLookFor] - AmountToTake
				if (useResourceEffects)then JMod.ResourceEffect(ResourceTypeToLookFor, Donor:LocalToWorld(Donor:OBBCenter()), pos, 1, 1, 1, 300) end

				if RequirementsRemaining[ResourceTypeToLookFor] <= 0 then
					RequirementsRemaining[ResourceTypeToLookFor] = nil
				end
			end
		else
			AllDone = true
		end

		Attempts = Attempts + 1
	end
end

function JMod.FindResourceContainer(typ, amt, pos, range, sourceEnt)
	pos = (sourceEnt and sourceEnt:LocalToWorld(sourceEnt:OBBCenter())) or pos

	for k, obj in pairs(ents.FindInSphere(pos, range or 150)) do
		if obj.GetEZsupplies and not(sourceEnt and obj == sourceEnt) then
			local AvaliableResources = obj:GetEZsupplies(typ)
			if (AvaliableResources and JMod.VisCheck(pos, obj, sourceEnt)) then
				if (typ and AvaliableResources >= amt) then

					return obj
				end
			end
		end
	end
	if IsValid(sourceEnt) and sourceEnt.GetEZsupplies then
		local AvaliableResources = sourceEnt:GetEZsupplies(typ)
		if AvaliableResources then
			if (typ and AvaliableResources >= amt) then

				return sourceEnt
			end
		end
	end
	
end

function JMod.TryCough(ent)
	local Time = CurTime()
	ent.EZcoughTime = ent.EZcoughTime or 0

	if Time > ent.EZcoughTime then
		ent:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 75, math.random(90, 110))

		if ent.ViewPunch then
			ent:ViewPunch(Angle(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)))
		end

		ent.EZcoughTime = CurTime() + math.random(.5, 1)
	end
end

function JMod.ClearLoS(ent1, ent2, ignoreWater, up, onlyHitWorld)
	if not IsValid(ent2) then return false end
	local SelfPos, TargPos = ent1:LocalToWorld(ent1:OBBCenter()) + vector_up * (up or 1), ent2:LocalToWorld(ent2:OBBCenter()) + vector_up

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
