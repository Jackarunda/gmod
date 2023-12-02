JMod.DEFAULT_INVENTORY = {EZresources = {}, items = {}, weight = 0, volume = 0, maxVolume = 0}

function JMod.EZ_Open_Inventory(ply)
	JMod.UpdateInv(ply)
	net.Start("JMod_Inventory")
		net.WriteString(ply:GetModel())
		net.WriteTable(ply.JModInv)
	net.Send(ply)
end

function JMod.GetStorageCapacity(ent)
	local Capacity = 100
	if ent:IsPlayer() then
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
	elseif IsValid(ent:GetPhysicsObject()) then
		Vol = ent:GetPhysicsObject():GetVolume()
		if Vol ~= nil then
			Capacity = math.ceil(Vol / 500)
		end
	end
	return Capacity
end

function JMod.IsEntContained(target, container)
	local Contained = IsValid(target) and (target:EntIndex() ~= -1) and IsValid(target.EZInvOwner) and IsValid(target:GetParent()) and (target:GetParent() == target.EZInvOwner)
	if container then
		Contained = Contained and (target.EZInvOwner == container)
	end
	return Contained
end

function JMod.UpdateInv(invEnt, noplace, transfer)
	invEnt.JModInv = invEnt.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	local Capacity = JMod.GetStorageCapacity(invEnt)
	local EntPos = invEnt:LocalToWorld(invEnt:OBBCenter())

	local RemovedItems = {}

	local jmodinvfinal = table.Copy(JMod.DEFAULT_INVENTORY)
	for k, v in ipairs(invEnt.JModInv.items) do
		--print(JMod.IsEntContained(v.ent, invEnt), v.ent:GetPhysicsObject():GetMass(), Capacity)
		local RandomPos = Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100))
		if JMod.IsEntContained(v.ent, invEnt) then
			local Phys = v.ent:GetPhysicsObject()
			if IsValid(Phys) and not(JMod.Config.QoL.AllowActiveItemsInInventory and (v.ent.GetState and v.ent:GetState() ~= 0)) then
				local Vol = Phys:GetVolume()
				if (Vol ~= nil) then
					Vol = math.ceil(Vol / 500)
					if v.ent.EZstorageVolumeOverride then
						Vol = v.ent.EZstorageVolumeOverride
					end
					if (Capacity >= (jmodinvfinal.volume + Vol)) then
						jmodinvfinal.weight = math.Round(jmodinvfinal.weight + Phys:GetMass())
						jmodinvfinal.volume = math.Round(jmodinvfinal.volume + Vol)
					else
						local Removed = JMod.RemoveFromInventory(invEnt, v.ent, not(noplace) and (EntPos + RandomPos), nil, true, transfer)
						table.insert(RemovedItems, Removed)
					end
				end
			else
				local Removed = JMod.RemoveFromInventory(invEnt, v.ent, not(noplace) and (EntPos + RandomPos), nil, true, transfer)
				table.insert(RemovedItems, Removed)
			end
			table.insert(jmodinvfinal.items, v)
		end
	end
	for typ, amt in pairs(invEnt.JModInv.EZresources) do
		if isstring(typ) then
			if amt > 0 then
				if (Capacity < (jmodinvfinal.volume + (amt * JMod.EZ_RESOURCE_INV_WEIGHT))) then
					local Overflow = (amt * JMod.EZ_RESOURCE_INV_WEIGHT) - (Capacity - jmodinvfinal.volume)
					local OverflowResult = math.Round((amt - Overflow) * JMod.EZ_RESOURCE_INV_WEIGHT)
					if Overflow > 0 then
						local Removed, amt = JMod.RemoveFromInventory(invEnt, {typ, Overflow / JMod.EZ_RESOURCE_INV_WEIGHT}, not(noplace) and (EntPos + Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100))), true)
						table.insert(RemovedItems, {Removed, amt})
					end
					jmodinvfinal.weight = jmodinvfinal.weight + OverflowResult
					jmodinvfinal.volume = jmodinvfinal.volume + OverflowResult
					jmodinvfinal.EZresources[typ] = math.Round(amt - Overflow / JMod.EZ_RESOURCE_INV_WEIGHT)
				else
					jmodinvfinal.weight = jmodinvfinal.weight + math.Round((amt * JMod.EZ_RESOURCE_INV_WEIGHT))
					jmodinvfinal.volume = jmodinvfinal.volume + math.Round((amt * JMod.EZ_RESOURCE_INV_WEIGHT))
					jmodinvfinal.EZresources[typ] = math.Round(amt)
				end
			end
		end
	end

	jmodinvfinal.maxVolume = Capacity

	invEnt.JModInv = jmodinvfinal
	if not(invEnt:IsPlayer() or invEnt.KeepJModInv) and table.IsEmpty(invEnt.JModInv.EZresources) and table.IsEmpty(invEnt.JModInv.items) then
		invEnt.JModInv = nil
	end

	return RemovedItems
end

function JMod.AddToInventory(invEnt, target, noUpdate)
	--jprint(invEnt, target, amt, noUpdate)
	if not(IsValid(invEnt)) then return end
	local AddingResource = istable(target)
	if not(AddingResource) and (target:IsPlayer() or (JMod.Config.QoL.AllowActiveItemsInInventory and (target.GetState and target:GetState() ~= 0))) then return end -- Open up! The fun police are here!

	if JMod.IsEntContained(target) then
		JMod.RemoveFromInventory(target.EZInvOwner, target, nil, false, true)
	end

	local jmodinv = invEnt.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	if AddingResource then
		local res, amt = target[1], target[2]
		if IsValid(res) and res.IsJackyEZresource then
			local SuppliesLeft = res:GetEZsupplies(res.EZsupplies)
			jmodinv.EZresources[res.EZsupplies] = (jmodinv.EZresources[res.EZsupplies] or 0) + math.min(SuppliesLeft, amt)
			res:SetEZsupplies(res.EZsupplies, SuppliesLeft - (amt or SuppliesLeft))
			JMod.ResourceEffect(res.EZsupplies, res:LocalToWorld(res:OBBCenter()), invEnt:LocalToWorld(invEnt:OBBCenter()), 1, 1, 1)
		else
			jmodinv.EZresources[res] = (jmodinv.EZresources[res] or 0) + amt
		end
	else
		DropEntityIfHeld(target)
		constraint.RemoveAll(target)
		target.EZInvOwner = invEnt
		target:SetParent(invEnt)
		target:SetPos(invEnt:OBBCenter())
		target:SetAngles(target.JModPreferredCarryAngles or Angle(0, 0, 0))
		target:SetNoDraw(true)
		target:SetNotSolid(true)
		target:GetPhysicsObject():EnableMotion(false)
		target:GetPhysicsObject():Sleep()
		table.insert(jmodinv.items, {name = target.PrintName or target:GetModel(), ent = target})
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

	if AddingResource then
		return target[1], target[2]
	else
		return target
	end
end

function JMod.RemoveFromInventory(invEnt, target, pos, noUpdate, transfer)
	--jprint(invEnt, target, pos, noUpdate, transfer)
	invEnt = invEnt or target.EZInvOwner
	if not(IsValid(invEnt)) then return end

	local RemovingResource

	if istable(target) then
		RemovingResource = true
		local resTyp = target[1]
		local amt = target[2]
		if JMod.EZ_RESOURCE_ENTITIES[resTyp] and invEnt.JModInv.EZresources[resTyp] then
			local AmountLeft = amt
			local Safety = 0
			if pos then
				while (AmountLeft > 0) or (Safety > 1000) do
					local AmountToGive = math.min(AmountLeft, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
					AmountLeft = AmountLeft - AmountToGive
					timer.Simple(Safety * 0.1, function()
						local Box = ents.Create(JMod.EZ_RESOURCE_ENTITIES[resTyp])
						Box:SetPos(pos + Vector(0, 0, Safety * 10))
						Box:SetAngles(Angle(0, 0, 0))
						Box:Spawn()
						Box:Activate()
						Box:SetResource(AmountToGive)
					end)
					Safety = Safety + 1
				end
			end
			invEnt.JModInv.EZresources[resTyp] = invEnt.JModInv.EZresources[resTyp] - amt
		end
	elseif JMod.IsEntContained(target, invEnt) then 
		target.EZInvOwner = nil

		if not(pos) and not(transfer) then
			SafeRemoveEntityDelayed(target, 0)
		else
			target:SetNoDraw(false)
			target:SetNotSolid(false)
			target:SetAngles(target.JModPreferredCarryAngles or Angle(0, 0, 0))
			target:SetParent(nil)
			target:SetPos(pos or Vector(0, 0 ,0))
			local Phys = target:GetPhysicsObject()
			timer.Simple(0, function()
				if IsValid(Phys) then
					Phys:EnableMotion(true)
					Phys:Wake()
					if IsValid(invEnt) and IsValid(invEnt:GetPhysicsObject()) then
						Phys:SetVelocity(invEnt:GetPhysicsObject():GetVelocity())
					end
				end
			end)
		end
	end

	if noUpdate then
		--
	else
		JMod.UpdateInv(invEnt)
	end

	if invEnt.NextLoad and invEnt.CalcWeight then 
		invEnt.NextLoad = CurTime() + 2
		invEnt:EmitSound("Ammo_Crate.Close")
		invEnt:CalcWeight()
	end

	if RemovingResource then
		return target[1], target[2]
	else
		return target
	end
end

local pickupWhiteList = {
	--["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

local CanPickup = function(ent)
	if not(IsValid(ent)) then return false end
	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return false end
	local class = ent:GetClass()
	if pickupWhiteList[class] then return true end
	if CLIENT then return true end
	if IsValid(ent:GetPhysicsObject()) then return true end

	return false
end

-- I put this in here because they all have to do with each other
net.Receive("JMod_ItemInventory", function(len, ply)
	local command = net.ReadString()
	local amt, resourceType, target
	if (command == "drop_res") or (command == "take_res") then
		amt = net.ReadUInt(12)
		resourceType = net.ReadString()
	else
		target = net.ReadEntity()
	end
	local invEnt = net.ReadEntity()

	if not IsValid(invEnt) then
		invEnt = ply
	end

	local Tr = util.QuickTrace(ply:GetPos() + ply:GetViewOffset(), ply:GetAimVector() * 60, ply)

	if command == "take" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
		if (JMod.IsEntContained(target) and (Tr.Entity ~= invEnt)) or (Tr.Entity ~= target) then return end
		JMod.AddToInventory(invEnt, target)
	elseif command == "drop" then
		if not(JMod.IsEntContained(target, invEnt)) then JMod.Hint(ply, "hint item inventory missing") JMod.UpdateInv(invEnt) return false end
		local item = JMod.RemoveFromInventory(invEnt, target, Tr.HitPos + Vector(0, 0, 10))
		JMod.Hint(ply,"hint item inventory drop")
	elseif command == "use" then
		if not(JMod.IsEntContained(target, invEnt)) then JMod.Hint(ply, "hint item inventory missing") JMod.UpdateInv(invEnt) return false end
		local item = JMod.RemoveFromInventory(invEnt, target, Tr.HitPos + Vector(0, 0, 10))
		if item then
			Phys = item:GetPhysicsObject()
			if pickupWhiteList[item:GetClass()] and IsValid(Phys) and (Phys:GetMass() <= 35) then
				ply:PickupObject(item)
			else
				print(ply:KeyDown(JMod.Config.General.AltFunctionKey))
				item:Use(ply, ply, USE_ON)
			end
		end
	elseif command == "drop_res" then
		JMod.RemoveFromInventory(invEnt, {resourceType, amt}, Tr.HitPos + Vector(0, 0, 10), false)
	elseif command == "take_res" then
		if invEnt ~= ply then
			if (Tr.Entity ~= invEnt) then return end
			JMod.RemoveFromInventory(ply, {resourceType, amt}, nil, false)
			JMod.AddToInventory(invEnt, {resourceType, amt})
		else
			JMod.RemoveFromInventory(invEnt, {resourceType, amt}, nil, false)
			JMod.AddToInventory(ply, {resourceType, amt})
		end
	elseif command == "full" then
		JMod.Hint(ply,"hint item inventory full")
	elseif command == "missing" then
		JMod.UpdateInv(invEnt)
		JMod.Hint(ply,"hint item inventory missing")
	end
end)

function JMod.EZ_GrabItem(ply, cmd, args)
	if not(IsValid(ply)) or not(ply:Alive()) then return end

	local Tar = args[1] 

	if not IsValid(Tar) then
		Tar = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 80, ply).Entity
	end

	if Tar.JModInv and not(table.IsEmpty(Tar.JModInv.items) and table.IsEmpty(Tar.JModInv.EZresources)) then
		JMod.UpdateInv(Tar)
		net.Start("JMod_ItemInventory")
			net.WriteEntity(Tar)
			net.WriteString("open_menu")
			net.WriteTable(Tar.JModInv)
		net.Send(ply)
	elseif not(Tar:IsConstrained()) and ((CanPickup(Tar) and Tar.JModEZstorable) or Tar.IsJackyEZresource) then
		JMod.UpdateInv(ply)
		local Phys = Tar:GetPhysicsObject()
		local RoomLeft = (ply.JModInv.maxVolume) - (ply.JModInv.volume)
		if RoomLeft > 0 then
			local RoomWeNeed = Phys:GetVolume()
			local IsResources = false

			if Tar.IsJackyEZresource then
				RoomWeNeed = math.min(Tar:GetEZsupplies(Tar.EZsupplies) * JMod.EZ_RESOURCE_INV_WEIGHT, RoomLeft)
				IsResources = true
			elseif RoomWeNeed ~= nil then
				if Tar.EZstorageVolumeOverride then
					RoomWeNeed = Tar.EZstorageVolumeOverride
				else
					RoomWeNeed = math.ceil(RoomWeNeed / 500)
				end
			end
			
			if (RoomWeNeed ~= nil) then
				if (RoomWeNeed <= RoomLeft) then 
					JMod.AddToInventory(ply, (IsResources and {Tar, RoomWeNeed / JMod.EZ_RESOURCE_INV_WEIGHT}) or Tar)
					JMod.Hint(ply,"hint item inventory add")
				end
			elseif RoomWeNeed == nil then
				ply:PrintMessage(HUD_PRINTCENTER, "Cannot stow, corrupt physics")
			else
				JMod.Hint(ply,"hint item inventory full")
			end
		end
	end
end

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