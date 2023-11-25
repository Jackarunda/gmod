function JMod.EZ_Open_Inventory(ply)
	JMod.UpdateInv(ply)
	net.Start("JMod_Inventory")
	net.WriteString(ply:GetModel())
	net.WriteTable(ply.JModInv)
	net.Send(ply)
end

function JMod.GetStorageCapacity(ent)
	local Capacity = 0
	if ent:IsPlayer() then
		Capacity = 50
		if ent.EZarmor and ent.EZarmor.items then
			for id, v in pairs(ent.EZarmor.items) do
				local ArmorInfo = JMod.ArmorTable[v.name]
				if ArmorInfo.storage then
					Capacity = Capacity + ArmorInfo.storage
				end
			end
		end
	end
	return Capacity
end

function JMod.IsEntContained(target, container)
	--print(target, container)
	--print(IsValid(target), (target:EntIndex() ~= -1), IsValid(target.EZInvOwner), (target.EZInvOwner == container), IsValid(target:GetParent()), (target:GetParent() == target.EZInvOwner))
	if container then
		return IsValid(target) and (target:EntIndex() ~= -1) and IsValid(target.EZInvOwner) and (target.EZInvOwner == container) and IsValid(target:GetParent()) and (target:GetParent() == target.EZInvOwner)
	else
		return IsValid(target) and (target:EntIndex() ~= -1) and IsValid(target.EZInvOwner) and IsValid(target:GetParent()) and (target:GetParent() == target.EZInvOwner)
	end
end

function JMod.UpdateInv(invEnt)
	invEnt.JModInv = invEnt.JModInv or {EZresources = {}, items = {}, weight = 0}

	local Capacity = JMod.GetStorageCapacity(invEnt)
	local EntPos = invEnt:LocalToWorld(invEnt:OBBCenter())

	local jmodinvfinal = {EZresources = {}, items = {}, weight = 0}
	for k, v in ipairs(invEnt.JModInv.items) do
		--print(JMod.IsEntContained(v.ent, invEnt), v.ent:GetPhysicsObject():GetMass(), Capacity)
		if JMod.IsEntContained(v.ent, invEnt) then
			local Phys = v.ent:GetPhysicsObject()
			if IsValid(Phys) and (Capacity >= (jmodinvfinal.weight + Phys:GetMass())) then
				jmodinvfinal.weight = math.Round(jmodinvfinal.weight + Phys:GetMass())
			else
				JMod.RemoveFromInventory(invEnt, v.ent, EntPos + Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100)), nil, true)
			end
			table.insert(jmodinvfinal.items, v)
		end
	end
	for typ, amt in pairs(invEnt.JModInv.EZresources) do
		if amt > 0 then
			if (Capacity <= (jmodinvfinal.weight + (amt * JMod.EZ_RESOURCE_INV_WEIGHT))) then
				local Overflow = (amt * JMod.EZ_RESOURCE_INV_WEIGHT) - (Capacity - jmodinvfinal.weight)
				JMod.RemoveFromInventory(invEnt, typ, EntPos + Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 100)), Overflow / JMod.EZ_RESOURCE_INV_WEIGHT, true)
				jmodinvfinal.weight = math.Round(jmodinvfinal.weight + ((amt - Overflow) * JMod.EZ_RESOURCE_INV_WEIGHT))
				jmodinvfinal.EZresources[typ] = math.Round(amt - Overflow / JMod.EZ_RESOURCE_INV_WEIGHT)
			else
				jmodinvfinal.weight = math.Round(jmodinvfinal.weight + (amt * JMod.EZ_RESOURCE_INV_WEIGHT))
				jmodinvfinal.EZresources[typ] = math.Round(amt)
			end
		end
	end

	invEnt.JModInv = jmodinvfinal
	--PrintTable(invEnt.JModInv)
end

function JMod.AddToInventory(invEnt, target, amt, noUpdate)
	if JMod.IsEntContained(target) or target:IsPlayer() then return end

	local jmodinv = invEnt.JModInv or {EZresources = {}, items = {}, weight = 0}

	if target.IsJackyEZresource then
		local SuppliesLeft = target:GetEZsupplies(target.EZsupplies)
		jmodinv.EZresources[target.EZsupplies] = (jmodinv.EZresources[target.EZsupplies] or 0) + math.min(SuppliesLeft, amt)
		target:SetEZsupplies(target.EZsupplies, SuppliesLeft - (amt or SuppliesLeft))
		JMod.ResourceEffect(target.EZsupplies, target:LocalToWorld(target:OBBCenter()), invEnt:LocalToWorld(invEnt:OBBCenter()), 1, 1, 1)
	else
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

	--PrintTable(invEnt.JModInv)

	if noUpdate then
		--
	else
		JMod.UpdateInv(invEnt)
	end

	if invEnt:IsPlayer() then
		JMod.Hint(invEnt,"hint item inventory add")
	end
end

function JMod.RemoveFromInventory(invEnt, target, pos, amt, noUpdate)
	local jmodinv = invEnt.JModInv or {EZresources = {}, items = {}, weight = 0}

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

		invEnt.JModInv.EZresources[target] = invEnt.JModInv.EZresources[target] - amt
	else
		if not JMod.IsEntContained(target, invEnt) then return end

		target.EZInvOwner = nil

		if not pos then
			SafeRemoveEntityDelayed(target, 0)

			return 
		end
		target:SetNoDraw(false)
		target:SetNotSolid(false)
		target:SetAngles(target.JModPreferredCarryAngles or Angle(0, 0, 0))
		target:SetParent(nil)
		target:SetPos(pos)
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

	if IsValid(target) then
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
	
	if command == "take" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
		JMod.AddToInventory(invEnt, target)
	elseif command == "drop" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
		local Tr = util.QuickTrace(ply:GetPos() + ply:GetViewOffset(), ply:GetAimVector() * 50, ply)
		local item = JMod.RemoveFromInventory(invEnt, target, Tr.HitPos + Vector(0, 0, 10))
		JMod.Hint(ply,"hint item inventory drop")
	elseif command == "use" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
		local Tr = util.QuickTrace(ply:GetPos() + ply:GetViewOffset(), ply:GetAimVector() * 50, ply)
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
		local Tr = util.QuickTrace(ply:GetPos() + ply:GetViewOffset(), ply:GetAimVector() * 50, ply)
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

	local Tar = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 50, ply).Entity

	if not(CanPickup(Tar)) then return end

	if Tar.JModInv then
		net.Start("JMod_ItemInventory") -- Send to client so the player can update their inv
		net.WriteEntity(Tar)
		net.WriteString("open_menu")
		net.WriteTable(Tar.JModInv)
		net.Send(ply)
	else
		local TarClass = Tar:GetClass()
		if (TarClass == "prop_physics") or (TarClass == "prop_ragdoll") or Tar.JModEZstorable or Tar.IsJackyEZresource then
			JMod.UpdateInv(ply)
			local Phys = Tar:GetPhysicsObject()
			local RoomLeft = JMod.GetStorageCapacity(ply) - (ply.JModInv.weight)
			if RoomLeft > 0 then
				local RoomWeNeed = Phys:GetMass()
				if Tar.IsJackyEZresource then
					RoomWeNeed = math.min(Tar:GetEZsupplies(Tar.EZsupplies) * JMod.EZ_RESOURCE_INV_WEIGHT, RoomLeft)
				end
				if RoomWeNeed <= RoomLeft then 
					JMod.AddToInventory(ply, Tar, RoomWeNeed / JMod.EZ_RESOURCE_INV_WEIGHT)
					JMod.Hint(ply,"hint item inventory add")
				else
					JMod.Hint(ply,"hint item inventory full")
				end
			end
		end
	end
end