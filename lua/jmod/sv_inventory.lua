JMod.DEFAULT_INVENTORY = {EZresources = {}, items = {}, weight = 0, volume = 0}

function JMod.EZ_Open_Inventory(ply)
	JMod.UpdateInv(ply)
	ply.JModInv.maxVolume = JMod.GetStorageCapacity(ply)
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
		if amt > 0 then
			if (Capacity < (jmodinvfinal.weight + (amt * JMod.EZ_RESOURCE_INV_WEIGHT))) then
				local Overflow = (amt * JMod.EZ_RESOURCE_INV_WEIGHT) - (Capacity - jmodinvfinal.volume)
				if Overflow > 0 then
					local Removed, amt = JMod.RemoveFromInventory(invEnt, typ, not(noplace) and (EntPos + Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100))), Overflow / JMod.EZ_RESOURCE_INV_WEIGHT, true)
					table.insert(RemovedItems, {Removed, amt})
				end
				local OverflowResult = math.Round((amt - Overflow) * JMod.EZ_RESOURCE_INV_WEIGHT)
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

	invEnt.JModInv = jmodinvfinal
	--PrintTable(invEnt.JModInv)

	return RemovedItems
end

function JMod.AddToInventory(invEnt, target, amt, noUpdate)
	--jprint(invEnt, target, amt, noUpdate)
	local AddingResource = ((amt ~= nil) and isstring(target))
	if not(AddingResource) then
		if (JMod.IsEntContained(target, invEnt) or target:IsPlayer()) then return end
		if JMod.Config.QoL.AllowActiveItemsInInventory and (target.GetState and target:GetState() ~= 0) then return end -- Open up! The fun police are here!
	end

	local jmodinv = invEnt.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	if AddingResource then
		jmodinv.EZresources[target] = (jmodinv.EZresources[target] or 0) + amt
	elseif target.IsJackyEZresource then
		local SuppliesLeft = target:GetEZsupplies(target.EZsupplies)
		jmodinv.EZresources[target.EZsupplies] = (jmodinv.EZresources[target.EZsupplies] or 0) + math.min(SuppliesLeft, amt)
		target:SetEZsupplies(target.EZsupplies, SuppliesLeft - (amt or SuppliesLeft))
		JMod.ResourceEffect(target.EZsupplies, target:LocalToWorld(target:OBBCenter()), invEnt:LocalToWorld(invEnt:OBBCenter()), 1, 1, 1)
	else
		DropEntityIfHeld(target)
		target.EZInvOwner = invEnt
		target:SetParent(invEnt)
		target:SetPos(invEnt:OBBCenter())
		target:SetAngles(target.JModPreferredCarryAngles or Angle(0, 0, 0))
		target:SetNoDraw(true)
		target:SetNotSolid(true)
		target:GetPhysicsObject():EnableMotion(false)
		target:GetPhysicsObject():Sleep()
		table.insert(jmodinv.items, {name = target.PrintName or target:GetModel(), model = target:GetModel(), ent = target})
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

	return target, amt
end

function JMod.RemoveFromInventory(invEnt, target, pos, amt, noUpdate, transfer)
	local jmodinv = invEnt.JModInv or table.Copy(JMod.DEFAULT_INVENTORY)

	if JMod.EZ_RESOURCE_ENTITIES[target] and invEnt.JModInv.EZresources[target] then
		local AmountLeft = amt
		local Safety = 0
		if pos then
			while (AmountLeft > 0) or (Safety > 1000) do
				local AmountToGive = math.min(AmountLeft, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
				AmountLeft = AmountLeft - AmountToGive
				timer.Simple(Safety * 0.1, function()
					local Box = ents.Create(JMod.EZ_RESOURCE_ENTITIES[target])
					Box:SetPos(pos + Vector(0, 0, Safety * 10))
					Box:SetAngles(Angle(0, 0, 0))
					Box:Spawn()
					Box:Activate()
					Box:SetResource(AmountToGive)
				end)
				Safety = Safety + 1
			end
		end
		--jprint("Subtracting " .. tostring(amt) .. " of " .. target)
		invEnt.JModInv.EZresources[target] = invEnt.JModInv.EZresources[target] - amt
	else
		if not JMod.IsEntContained(target, invEnt) then return end

		target.EZInvOwner = nil

		if not(isvector(pos)) and not(transfer) then
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

	return target, amt
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
	if command == "drop_res" then
		amt = net.ReadUInt(12)
		resourceType = net.ReadString()
	else
		target = net.ReadEntity()
	end
	local invEnt = net.ReadEntity()

	if not IsValid(invEnt) then
		invEnt = ply
	end

	local Tr = util.QuickTrace(ply:GetPos() + ply:GetViewOffset(), ply:GetAimVector() * 50, ply)

	if command == "take" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
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
		JMod.RemoveFromInventory(invEnt, resourceType, Tr.HitPos + Vector(0, 0, 10), amt)
		--JMod.Hint(ply,"hint item inventory drop")
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

	if Tar.JModInv then
		net.Start("JMod_ItemInventory") -- Send to client so the player can update their inv
		net.WriteEntity(Tar)
		net.WriteString("open_menu")
		net.WriteTable(Tar.JModInv)
		net.Send(ply)
	else
		local TarClass = Tar:GetClass()
		if CanPickup(Tar) or Tar.JModEZstorable or Tar.IsJackyEZresource then
			JMod.UpdateInv(ply)
			local Phys = Tar:GetPhysicsObject()
			local RoomLeft = JMod.GetStorageCapacity(ply) - (ply.JModInv.volume)
			if RoomLeft > 0 then
				local RoomWeNeed = Phys:GetVolume()

				if Tar.IsJackyEZresource then
					RoomWeNeed = math.min(Tar:GetEZsupplies(Tar.EZsupplies) * JMod.EZ_RESOURCE_INV_WEIGHT, RoomLeft)
				elseif RoomWeNeed ~= nil then
					RoomWeNeed = math.ceil(RoomWeNeed / 500)
				end

				if (RoomWeNeed ~= nil) then
					if Tar.EZstorageVolumeOverride then
						RoomWeNeed = Tar.EZstorageVolumeOverride
					end
					if (RoomWeNeed <= RoomLeft) then 
						JMod.AddToInventory(ply, Tar, RoomWeNeed / JMod.EZ_RESOURCE_INV_WEIGHT)
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
end