JMod.VOLUMEDIV = 500
JMod.DEFAULT_INVENTORY = {EZresources = {}, items = {}, weight = 0, volume = 0, maxVolume = 0}
JMod.GRABDISTANCE = 70

function JMod.GetStorageCapacity(ent)
	if not(IsValid(ent)) then return 0 end
	if ent.IsJackyEZcrate then return 0 end
	if ent.IsJackyEZresource then return 0 end
	local Capacity = 0
	local Phys = ent:GetPhysicsObject()

	if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
		Capacity = 10
		if ent.EZarmor and ent.EZarmor.items then
			for id, v in pairs(ent.EZarmor.items) do
				local ArmorInfo = JMod.ArmorTable[v.name]
				if ArmorInfo.storage then
					Capacity = Capacity + ArmorInfo.storage
				end
			end
		end
	elseif ent.ArmorName then
		local Specs = JMod.ArmorTable[ent.ArmorName]
		Capacity = Specs.storage
	elseif ent.EZstorageSpace or ent.MaxItems then
		Capacity = ent.EZstorageSpace or ent.MaxItems
	elseif IsValid(Phys) and (ent:GetClass() == "prop_physics") then
		local Vol = Phys:GetVolume()
		if Vol ~= nil then
			local SurfID = util.GetSurfaceIndex(Phys:GetMaterial())
			if SurfID then
				local SurfData = util.GetSurfaceData(SurfID)
				if SurfData.thickness > 0 then
					local SurfArea = Phys:GetSurfaceArea()
					--0.0254 ^ 3 -- hu-in^3 or something like that
					Vol = Vol - (SurfArea * SurfData.thickness * 0.000016387064 * SurfData.density)
					Capacity = math.ceil(Vol / JMod.VOLUMEDIV)
				end
			end
		end
	end

	return Capacity * JMod.Config.QoL.InventorySizeMult
end

function JMod.GetItemVolumeWeight(ent, amt)
	amt = amt or 1

	if isstring(ent) then
		local ResourceWeightFactor = (JMod.Config.ResourceEconomy.ResourceInventoryWeight / JMod.Config.ResourceEconomy.MaxResourceMult)
		local ResourceWeight = ResourceWeightFactor * amt
		return ResourceWeight, ResourceWeightFactor
	elseif IsValid(ent) then
		local Phys = ent:GetPhysicsObject()
		if not IsValid(Phys) then return nil end

		local Vol = Phys:GetVolume()
		local Mass = 0
		if Vol == nil then
			local Mins, Maxs = ent:GetCollisionBounds()
			local X = math.abs(Maxs.x - Mins.x)
			local Y = math.abs(Maxs.y - Mins.y)
			local Z = math.abs(Maxs.z - Mins.z)
			Vol = X * Y * Z
		end
		Vol = ent.JModEZstorableVolume or math.Round(Vol / JMod.VOLUMEDIV, 2)
		Mass = math.ceil(Phys:GetMass())

		return Vol, Mass
	end

	return nil
end

function JMod.IsEntContained(target, container)
	if not IsValid(target) then return false end
	local TargetContainer = target:GetNW2Entity("EZInvOwner", NULL)
	local Contained = IsValid(TargetContainer) and IsValid(target:GetParent()) and (target:GetParent() == TargetContainer)
	if container then
		Contained = Contained and (TargetContainer == container)
	end
	return Contained
end

local function IsActiveItemAllowed(ent)
	--if not IsValid(ent) then return false end
	if not(JMod.Config.QoL.AllowActiveItemsInInventory) and (ent.GetState and ent:GetState() ~= 0) then
		return ent.JModInvAllowedActive
	else
		return true
	end

	for k, v in pairs(ent:GetChildren()) do
		if v.IsVehicle and v:IsVehicle() then return false end
	end

	return false
end

function JMod.UpdateInv(invEnt, noplace, transfer, emergancyNetwork)
	invEnt.JModInv = invEnt.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	local Capacity = JMod.GetStorageCapacity(invEnt)
	local EntPos = invEnt:LocalToWorld(invEnt:OBBCenter())

	local RemovedItems = {}

	local jmodinvfinal = table.Copy(JMod.DEFAULT_INVENTORY)
	jmodinvfinal.maxVolume = Capacity

	for k, iteminfo in ipairs(invEnt.JModInv.items) do
		if (Capacity > 0) and JMod.IsEntContained(iteminfo.ent, invEnt) and (iteminfo.ent:EntIndex() ~= -1) then
			local Vol, Mass = JMod.GetItemVolumeWeight(iteminfo.ent)
			if (Vol ~= nil) and IsActiveItemAllowed(iteminfo.ent) and (Capacity >= (jmodinvfinal.volume + Vol)) then
				jmodinvfinal.weight = jmodinvfinal.weight + Mass
				jmodinvfinal.volume = jmodinvfinal.volume + math.Round(Vol, 2)
				iteminfo.vol = Vol
				if emergancyNetwork then
					if iteminfo.ent:GetNoDraw() then -- Emergancy networking fix
						iteminfo.ent:SetNoDraw(false)
						timer.Simple(1, function()
							if JMod.IsEntContained(iteminfo.ent, invEnt) then
								iteminfo.ent:SetNoDraw(true)
							end
						end)
					end
				end
			else
				local RandomPos = Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100))
				local TrPos = util.QuickTrace(EntPos, RandomPos, {invEnt}).HitPos
				local Removed = JMod.RemoveFromInventory(invEnt, iteminfo.ent, not(noplace) and TrPos, true, transfer)
				table.insert(RemovedItems, Removed)
			end
			table.insert(jmodinvfinal.items, iteminfo)
		end
	end
	for typ, amt in pairs(invEnt.JModInv.EZresources) do
		if isstring(typ) and (amt > 0) then
			local ResourceWeight, ResourceWeightFactor = JMod.GetItemVolumeWeight(typ, amt)
			if (Capacity < (jmodinvfinal.volume + (ResourceWeight))) then
				local Overflow = (ResourceWeight) - (Capacity - jmodinvfinal.volume)
				local OverflowWeight = math.Round((amt - Overflow) * ResourceWeightFactor)
				local AmountToRemove = math.Round(Overflow / ResourceWeightFactor)
				if Overflow > 0 then
					local Removed, amt = JMod.RemoveFromInventory(invEnt, {typ, AmountToRemove}, not(noplace) and (EntPos + Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100))), true, transfer)
					table.insert(RemovedItems, {Removed, amt})
				end
				jmodinvfinal.weight = jmodinvfinal.weight + OverflowWeight
				jmodinvfinal.volume = jmodinvfinal.volume + OverflowWeight
				jmodinvfinal.EZresources[typ] = math.Round(amt - AmountToRemove)
			else
				jmodinvfinal.weight = jmodinvfinal.weight + math.Round(ResourceWeight)
				jmodinvfinal.volume = jmodinvfinal.volume + math.Round(ResourceWeight)
				jmodinvfinal.EZresources[typ] = math.Round(amt)
			end
		end
	end

	invEnt.JModInv = jmodinvfinal
	if not(invEnt:IsPlayer() or invEnt.KeepJModInv) and table.IsEmpty(invEnt.JModInv.EZresources) and table.IsEmpty(invEnt.JModInv.items) then
		invEnt.JModInv = nil
	end

	if invEnt:IsPlayer() then 
		net.Start("JMod_ItemInventory")
			net.WriteEntity(invEnt)
			net.WriteString("update")
			net.WriteTable(invEnt.JModInv)
		net.Send(invEnt)
	end

	return RemovedItems
end

-- First arg is inventory entity, second is item or table representing resources, third is to cancel the auto-update
function JMod.AddToInventory(invEnt, target, noUpdate)
	--jprint(invEnt, target, noUpdate)
	invEnt = invEnt or target:GetNW2Entity("EZInvOwner", NULL)
	local Capacity = JMod.GetStorageCapacity(invEnt)
	if Capacity <= 0 then return false end
	local AddingResource = istable(target)
	if not(AddingResource) and (target:IsPlayer() or not(IsActiveItemAllowed(target)) or (target:EntIndex() == -1)) then return false end -- Open up! The fun police are here!

	if JMod.IsEntContained(target) then
		JMod.RemoveFromInventory(target:GetNW2Entity("EZInvOwner", NULL), target, nil, false, true)
	end

	local jmodinv = invEnt.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	if AddingResource then
		local res, amt = target[1], target[2] or Capacity
		if IsValid(res) and res.IsJackyEZresource then
			resEnt = res
			res = resEnt.EZsupplies
			local SuppliesLeft = resEnt:GetEZsupplies(res) or 0
			jmodinv.EZresources[res] = (jmodinv.EZresources[res] or 0) + math.min(SuppliesLeft, amt)
			resEnt:SetEZsupplies(res, SuppliesLeft - (amt or SuppliesLeft))
			JMod.ResourceEffect(res, resEnt:LocalToWorld(resEnt:OBBCenter()), invEnt:LocalToWorld(invEnt:OBBCenter()), 1, 1, 1)
		else
			jmodinv.EZresources[res] = (jmodinv.EZresources[res] or 0) + amt
		end
	elseif IsValid(target) then
		target:ForcePlayerDrop()
		constraint.RemoveAll(target)
		target:SetNW2Entity("EZInvOwner", invEnt)

		local BoneID = invEnt:LookupBone("ValveBiped.Bip01_Spine1")

		if BoneID then
			target.EZoldMoveType = target:GetMoveType()
			target.EZoldNoBoneFollow = target:IsEffectActive(EF_FOLLOWBONE)
			if not(target.EZoldNoBoneFollow) then
				target:AddEffects(EF_FOLLOWBONE)
			end
			target:SetMoveType(MOVETYPE_NONE)
			target:SetParent(invEnt, BoneID)

			local Pos, Ang = invEnt:GetBonePosition(BoneID)
			target:SetPos(Pos)
			target:SetAngles(Ang)
		else
			target:SetParent(invEnt)
			target:SetPos(invEnt:OBBCenter())
			target:SetAngles(Angle(0, 0, 0))
		end
		--[[local InvMin, InvMax, targMin, targMax = invEnt:OBBMins(), invEnt:OBBMaxs(), target:OBBMins(), target:OBBMaxs()
		local PosToFit = Vector(invEnt:OBBCenter())
		for i = 1, 3 do
			PosToFit[i] = InvMax[i] - (targMax[i] - targMin[1])
		end
		target:SetPos(PosToFit)
		target:SetAngles(target.JModPreferredCarryAngles or PosToFit:Angle())--]]
		---
		target:SetNoDraw(true)
		target:SetNotSolid(true)
		if IsValid(target:GetPhysicsObject()) then
			target:GetPhysicsObject():EnableMotion(false)
			target:GetPhysicsObject():Sleep()
		end
		--if invEnt:GetPersistent() then
		--	target:SetPersistent(true)
		--end
		table.insert(jmodinv.items, {name = target.PrintName or target:GetModel(), ent = target, vol = JMod.GetItemVolumeWeight(target)})

		local Children = target:GetChildren()
		if Children then
			for k, v in pairs(Children) do
				v.JModWasNoDraw = v:GetNoDraw()
				v.JModWasNoSolid = v:IsSolid()
				v:SetNoDraw(true)
				v:SetNotSolid(true)
			end
		end
	end

	invEnt.JModInv = jmodinv

	if noUpdate then
		--
	else
		JMod.UpdateInv(invEnt)
	end

	if invEnt:IsPlayer() then
		JMod.Hint(invEnt,"hint item inventory add")
	end

	hook.Run("JMod_OnInventoryAdd", invEnt, target, jmodinv)

	return true
end

function JMod.RemoveFromInventory(invEnt, target, pos, noUpdate, transfer)
	invEnt = invEnt or target:GetNW2Entity("EZInvOwner", NULL)
	if not(IsValid(invEnt)) then return end

	local RemovingResource = istable(target)

	if RemovingResource then
		RemovingResource = true
		local resTyp = target[1]
		local amt = target[2]
		if JMod.EZ_RESOURCE_ENTITIES[resTyp] and invEnt.JModInv.EZresources[resTyp] then
			local AmountLeft = amt
			local Safety = 0
			if (pos) and not(transfer) then
				while (AmountLeft > 0) or (Safety > 1000) do
					local AmountToGive = math.min(AmountLeft, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
					AmountLeft = AmountLeft - AmountToGive
					timer.Simple(Safety * 0.1, function()
						local Box = ents.Create(JMod.EZ_RESOURCE_ENTITIES[resTyp])
						Box:SetPos(pos + Vector(0, 0, Safety * 10))
						Box:SetAngles(Angle(0, 0, 0))
						Box:Spawn()
						Box:Activate()
						Box:SetEZsupplies(Box.EZsupplies, AmountToGive)
					end)
					Safety = Safety + 1
				end
			end
			invEnt.JModInv.EZresources[resTyp] = invEnt.JModInv.EZresources[resTyp] - amt
		end
	elseif JMod.IsEntContained(target, invEnt) then 
		target:SetNW2Entity("EZInvOwner", nil)

		if not(pos) and not(transfer) then
			SafeRemoveEntity(target)
		else
			target:SetNoDraw(false)
			target:SetNotSolid(false)
			target:SetAngles(target.JModPreferredCarryAngles or Angle(0, 0, 0))
			if target.EZoldMoveType then
				target:SetMoveType(target.EZoldMoveType)
				target.EZoldMoveType = nil
			end
			if target.EZoldNoBoneFollow then
				target:RemoveEffects(EF_FOLLOWBONE)
				target.EZoldNoBoneFollow = nil
			end
			target:SetParent(nil)
			target:SetPos(pos or invEnt:GetPos())
			local Phys = target:GetPhysicsObject()
			timer.Simple(0, function()
				if IsValid(Phys) then
					--if IsValid(target.JModInventoryAnchor) then
					--	target.JModInventoryAnchor:Remove()
					--end
					Phys:EnableGravity(true)
					Phys:EnableMotion(true)
					Phys:Wake()
					if IsValid(invEnt) and IsValid(invEnt:GetPhysicsObject()) then
						Phys:SetVelocity(invEnt:GetPhysicsObject():GetVelocity())
					end
				end
			end)
			local Children = target:GetChildren()
			if Children then
				for k, v in pairs(Children) do
					v:SetNoDraw(v.JModWasNoDraw or false)
					v:SetNotSolid(v.JModWasNoSolid or false)
				end
			end
		end
	end

	if noUpdate then
		--
	else
		JMod.UpdateInv(invEnt)
	end

	hook.Run("JMod_OnInventoryRemove", invEnt, target, jmodinv)

	if RemovingResource then
		return target[1], target[2]
	else
		return target
	end
end

hook.Add("JMod_OnInventoryRemove", "JMod_CalcWeight", function(invEnt, target, jmodinv)
	if invEnt.NextLoad and invEnt.CalcWeight then 
		invEnt.NextLoad = CurTime() + 2
		--invEnt:EmitSound("Ammo_Crate.Close")
		invEnt:CalcWeight()
	end
end)

hook.Add("JMod_OnInventoryAdd", "JMod_CalcWeight", function(invEnt, target, jmodinv)
	if invEnt.NextLoad and invEnt.CalcWeight then 
		invEnt.NextLoad = CurTime() + 2
		--nvEnt:EmitSound("Ammo_Crate.Close")
		invEnt:CalcWeight()
	end
end)

local pickupWhiteList = {
	["prop_ragdoll"] = false,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

local CanPickup = function(ent)
	if not(IsValid(ent)) then return false end
	if not(ent.JModEZstorable or ent.IsJackyEZresource) then return pickupWhiteList[ent:GetClass()] or false end
	if ent:IsNPC() or ent:IsPlayer() or ent:IsWorld() then return false end
	if string.find("func_", ent:GetClass()) then return false end
	if CLIENT then return true end
	if IsValid(ent:GetPhysicsObject()) and (ent:GetPhysicsObject():IsMotionEnabled()) then return true end

	return false
end

local CanSeeInventoryEnt = function(ent, ply)
	local InvEntPos = ent:LocalToWorld(ent:OBBCenter())
	local CanSeeNonPlyInv = not util.TraceLine({
		start = ply:GetShootPos(),
		endpos = InvEntPos,
		filter = {ply, ent, ent:GetParent()},
		mask = MASK_SOLID
	}).Hit
	
	return ply:GetShootPos():Distance(InvEntPos) < 200 and CanSeeNonPlyInv
end

-- I put this in here because they all have to do with each other
net.Receive("JMod_ItemInventory", function(len, ply)
	local command = net.ReadString()
	local desiredAmt, resourceType, target
	if string.find(command, "_res") then
		desiredAmt = net.ReadUInt(12)
		resourceType = net.ReadString()
	else
		target = net.ReadEntity()
	end
	local invEnt = net.ReadEntity()

	local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * JMod.GRABDISTANCE, ply)
	local InvSound = util.GetSurfaceData(Tr.SurfaceProps).impactSoftSound
	local NonPlyInv = (invEnt ~= ply)
	local CanSeeNonPlyInv = CanSeeInventoryEnt(invEnt, ply)

	--print(command, invEnt, target, CanSeeNonPlyInv, JMod.IsEntContained(target, invEnt))
	--jprint((NonPlyInv and InvSound) or ("snds_jack_gmod/equip"..math.random(1, 5)..".ogg"))

	-- 'take' means from another inventory, use grab if it's on the ground
	-- 'stow' means put in another inventory
	if command == "take" then
		if not(IsValid(target)) then 
			JMod.Hint(ply, "hint item inventory missing") 
			JMod.UpdateInv(invEnt) 
			return false 
		end
		if CanSeeNonPlyInv and JMod.IsEntContained(target, invEnt) then
			local Added = JMod.AddToInventory(ply, target)
			if Added then
				sound.Play((InvSound) or ("snd_jack_clothequip.ogg"), Tr.HitPos, 60, math.random(90, 110))
			else
				ply:PrintMessage(HUD_PRINTCENTER, "Cannot take")
			end
		end
	elseif command == "stow" then
		if not(IsValid(target)) then 
			JMod.Hint(ply, "hint item inventory missing") 
			JMod.UpdateInv(invEnt) 
			return false 
		end
		if CanSeeNonPlyInv and JMod.IsEntContained(target, ply) then
			local Added = JMod.AddToInventory(invEnt, target)
			if Added then 
				sound.Play((InvSound) or ("snd_jack_clothequip.ogg"), Tr.HitPos, 60, math.random(90, 110)) 
			else
				ply:PrintMessage(HUD_PRINTCENTER, "Cannot stow")
			end
		end
	elseif command == "drop" then
		if NonPlyInv and not(CanSeeNonPlyInv) then return end
		if not(JMod.IsEntContained(target, invEnt)) then 
			JMod.Hint(ply, "hint item inventory missing") 
			JMod.UpdateInv(invEnt) 

			return false 
		end
		JMod.RemoveFromInventory(invEnt, target, Tr.HitPos + Tr.HitNormal * 10)
		sound.Play(((invEnt ~= ply) and InvSound) or ("snd_jack_clothunequip.ogg"), Tr.HitPos, 60, math.random(90, 110))
		JMod.Hint(ply,"hint item inventory drop")
	elseif (command == "use") or (command == "prime") then
		if NonPlyInv and not(CanSeeNonPlyInv) then return end
		if not(JMod.IsEntContained(target, invEnt)) then 
			JMod.Hint(ply, "hint item inventory missing") 
			JMod.UpdateInv(invEnt) 
			return false 
		end
		local item = JMod.RemoveFromInventory(invEnt, target, Tr.HitPos + Tr.HitNormal * 10)
		if item then
			Phys = item:GetPhysicsObject()
			if pickupWhiteList[item:GetClass()] and IsValid(Phys) and (Phys:GetMass() <= 35) then
				ply:DropObject()
				ply:PickupObject(item)
			else
				ply:DropObject()
				item:Use(ply, ply, USE_ON)
				if command == "prime" and item.Prime then
					timer.Simple(0.1, function()
						if IsValid(item) then item:Prime() end
					end)
				end
			end
		end
		sound.Play(((invEnt ~= ply) and InvSound) or ("snd_jack_clothunequip.ogg"), Tr.HitPos, 60, math.random(90, 110))
	elseif command == "drop_res" then
		if NonPlyInv and not(CanSeeNonPlyInv) then return end
		local amt = math.Clamp(desiredAmt, 0, invEnt.JModInv.EZresources[resourceType] or 0)
		JMod.RemoveFromInventory(invEnt, {resourceType, amt}, Tr.HitPos + Tr.HitNormal * 10, false)
		sound.Play(((invEnt ~= ply) and InvSound) or ("snd_jack_clothunequip.ogg"), Tr.HitPos, 60, math.random(90, 110))
	elseif command == "take_res" then
		if not(CanSeeNonPlyInv) then return end
		local amt = math.Clamp(desiredAmt, 0, invEnt.JModInv.EZresources[resourceType] or 0)
		if invEnt.IsJackyEZresource then
			amt = math.Clamp(desiredAmt, 0, invEnt:GetEZsupplies(resourceType) or 0)
			invEnt:SetEZsupplies(resourceType, invEnt:GetEZsupplies(resourceType) - amt)
		else
			JMod.RemoveFromInventory(invEnt, {resourceType, amt}, nil, false)
		end
		local Added = JMod.AddToInventory(ply, {resourceType, amt})
		if Added then
			sound.Play("snd_jack_clothequip.ogg", Tr.HitPos, 60, math.random(90, 110)) --"snds_jack_gmod/equip"..math.random(1, 5)..".ogg"
		else
			ply:PrintMessage(HUD_PRINTCENTER, "Cannot take")
		end
	elseif command == "stow_res" then
		if not(CanSeeNonPlyInv) then return end
		local amt = math.Clamp(desiredAmt, 0, ply.JModInv.EZresources[resourceType] or 0)
		local Added = JMod.AddToInventory(invEnt, {resourceType, amt})
		if not Added then
			if invEnt.EZconsumes and table.HasValue(invEnt.EZconsumes, resourceType) then
				amt = invEnt:TryLoadResource(resourceType, amt)
				JMod.RemoveFromInventory(ply, {resourceType, amt}, nil, false)
			else
				ply:PrintMessage(HUD_PRINTCENTER, "Could not stow or load resource")
			end
		else
			sound.Play(InvSound, Tr.HitPos, 60, math.random(90, 110))
			JMod.RemoveFromInventory(ply, {resourceType, amt}, nil, false)
		end
	elseif command == "full" then
		JMod.Hint(ply,"hint item inventory full")
	elseif command == "missing" then
		JMod.UpdateInv(invEnt, nil, nil, true)
		JMod.Hint(ply,"hint item inventory missing")
	end
	--JMod.UpdateInv(invEnt)
end)

function JMod.OpenEntityInventory(ent, ply)
	if not IsValid(ent) or not(ent.JModInv) then return end
	if not (IsValid(ply) and ply:Alive()) then return end
	local ShouldOpenInv = hook.Run("JMod_ShouldOpenInventory", ent, ply)
	if ShouldOpenInv ~= nil and not(ShouldOpenInv) then return end

	net.Start("JMod_ItemInventory")
		net.WriteEntity(ent)
		net.WriteString("open_menu")
		net.WriteTable(ent.JModInv)
	net.Send(ply)
end

function JMod.EZ_GrabItem(ply, cmd, args)
	if not SERVER then return end
	if not(IsValid(ply)) or not(ply:Alive()) then return end
	local Time = CurTime()
	if (ply.EZnextGrabTime or 0) > Time then return end
	ply.EZnextGrabTime = Time + 1

	local TargetEntity = NULL

	if args[1] then
		TargetEntity = Entity(tonumber(args[1]))
	end

	if not(IsValid(TargetEntity)) or not(CanSeeInventoryEnt(TargetEntity, ply)) then
		TargetEntity = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * JMod.GRABDISTANCE, ply).Entity
	end

	if not(IsValid(TargetEntity)) then ply:PrintMessage(HUD_PRINTCENTER, "Nothing to grab") return end

	if TargetEntity.JModInv and (next(TargetEntity.JModInv.items) or next(TargetEntity.JModInv.EZresources)) then
		JMod.UpdateInv(TargetEntity)
		JMod.OpenEntityInventory(TargetEntity, ply)
		sound.Play("snd_jack_clothequip.ogg", ply:GetPos(), 50, math.random(90, 110))

	elseif not(TargetEntity:IsConstrained()) and CanPickup(TargetEntity) then
		JMod.UpdateInv(ply)
		local RoomLeft = math.floor((ply.JModInv.maxVolume) - (ply.JModInv.volume))
		if RoomLeft > 0 then
			local ResourceWeight = (JMod.Config.ResourceEconomy.ResourceInventoryWeight / JMod.Config.ResourceEconomy.MaxResourceMult)
			local RoomWeNeed = JMod.GetItemVolumeWeight(TargetEntity)
			local IsResources = false

			if TargetEntity.IsJackyEZresource then
				local Amt = tonumber(args[2])
				if not Amt then
					if ply:KeyDown(IN_SPEED) then
						Amt = 9e9
					else
						net.Start("JMod_ItemInventory")
							net.WriteEntity(TargetEntity)
							net.WriteString("take_res")
							net.WriteTable({})
						net.Send(ply)

						return 
					end
				end

				local SuppliesLeft = TargetEntity:GetEZsupplies(TargetEntity.EZsupplies)
				Amt = math.floor(math.min(Amt or SuppliesLeft), SuppliesLeft)
				RoomWeNeed = math.min(Amt * ResourceWeight, RoomLeft)
				IsResources = true
			end
			
			if (RoomWeNeed ~= nil) then
				if (RoomWeNeed <= RoomLeft) then
					local Added = JMod.AddToInventory(ply, (IsResources and {TargetEntity, RoomWeNeed / ResourceWeight}) or TargetEntity)
					--
					if not(Added) then
						ply:PrintMessage(HUD_PRINTCENTER, "Couldn't grab item")
					else
						local Wep = ply:GetActiveWeapon()
						if IsValid(Wep) then
							Wep:SendWeaponAnim(ACT_VM_DRAW)
						end
						ply:ViewPunch(Angle(1, 0, 0))
						ply:SetAnimation(PLAYER_ATTACK1)
						--
						--JMod.Hint(ply,"hint item inventory add")
						sound.Play("snd_jack_clothequip.ogg", ply:GetPos(), 60, math.random(90, 110))
					end
				else
					JMod.Hint(ply,"hint item inventory full")
				end
			elseif RoomWeNeed == nil then
				ply:PrintMessage(HUD_PRINTCENTER, "Cannot stow, corrupt physics")
			end
		else
			JMod.Hint(ply,"hint item inventory full")
		end
	end
end

function JMod.EZ_Open_Inventory(ply)
	JMod.Hint(ply, "scrounge")
	JMod.UpdateInv(ply)
	net.Start("JMod_Inventory")
		net.WriteString(ply:GetModel())
		net.WriteTable(ply.JModInv)
	net.Send(ply)
end

function JMod.EZ_QuickNade(ply, cmd, args)
	if not (IsValid(ply) and ply:Alive()) then return false end
	if (ply.EZnextQuickNadeTime or 0) > CurTime() then return false end
	ply.EZnextQuickNadeTime = CurTime() + 1

	for k, tbl in ipairs(ply.JModInv.items) do
		local Nade = tbl.ent

		if IsValid(Nade) and Nade.EZinvPrime or Nade.EZinvThrowable then
			local SafetyTr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 50, {ply, Nade})
			local Nade = JMod.RemoveFromInventory(ply, Nade, SafetyTr.HitPos + SafetyTr.HitNormal * 5)

			timer.Simple(0.01, function()
				if IsValid(Nade) and IsValid(ply) and ply:Alive() then
					Nade:Use(ply, ply, USE_ON)
					timer.Simple(0.01, function()
						if IsValid(Nade) and not(Nade.AlreadyPickedUp) and Nade.GetState and Nade.Prime and (Nade:GetState() == JMod.EZ_STATE_OFF) then Nade:Prime() end
					end)
				end
			end)

			sound.Play("snd_jack_clothunequip.ogg", ply:GetShootPos(), 60, math.random(90, 110))

			return true
		end
	end
end

concommand.Add("jmod_ez_quicknade", function(ply, cmd, args)
	JMod.EZ_QuickNade(ply, cmd, args)
end, nil, "Quick throw first grenade in JMod inventory")

concommand.Add("jmod_debug_stow", function(ply, cmd, args) 
	if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
	if not GetConVar("sv_cheats"):GetBool() then return end

	local Tr = ply:GetEyeTrace()
	if IsValid(Tr.Entity) then
		if ply.JModInv.items[1] and IsValid(ply.JModInv.items[1].ent) then
			JMod.AddToInventory(Tr.Entity, ply.JModInv.items[1].ent)
		else
			local ResourceToAdd, Amount = next(ply.JModInv.EZresources)
			if ResourceToAdd then
				JMod.RemoveFromInventory(ply, {ResourceToAdd, Amount}, nil, false, true)
				JMod.AddToInventory(Tr.Entity, {ResourceToAdd, Amount})
			end
		end
	end
end, nil, "Attempts to stow first item of inventory in container")

hook.Add("EntityRemoved", "JMOD_DUMPINVENTORY", function(ent)
	if not(ent:IsPlayer()) and ent.JModInv then
		local Pos = ent:GetPos()
		if ent.JModInv.EZresources then
			for k, v in pairs(ent.JModInv.EZresources) do
				local ColTr = util.QuickTrace(Pos, VectorRand() * JMod.GRABDISTANCE, ent)
				JMod.RemoveFromInventory(ent, {k, v}, ColTr.HitPos, true, false)
			end
		end

		if ent.JModInv.items then
			for _, v in ipairs(ent.JModInv.items) do
				local ColTr = util.QuickTrace(Pos, VectorRand() * JMod.GRABDISTANCE, ent)
				JMod.RemoveFromInventory(ent, v.ent, ColTr.HitPos, true, false)
			end
		end
	end
end)