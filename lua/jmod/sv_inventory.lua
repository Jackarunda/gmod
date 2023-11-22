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
				jmodinvfinal.weight = math.Round(jmodinvfinal.weight + amt - Overflow)
				jmodinvfinal.EZresources[typ] = math.Round(amt)
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
	--print(invEnt, target, JMod.IsEntContained(target))
	if JMod.IsEntContained(target) or target:IsPlayer() then return end

	local jmodinv = invEnt.JModInv or {EZresources = {}, items = {}, weight = 0}

	if target.IsJackyEZresource then
		local SuppliesLeft = target:GetEZsupplies(target.EZsupplies)
		jmodinv.EZresources[target.EZsupplies] = (jmodinv.EZresources[target.EZsupplies] or 0) + math.min(SuppliesLeft, amt)
		target:SetEZsupplies(target.EZsupplies, SuppliesLeft - (amt or SuppliesLeft))
	else
		target.EZInvOwner = invEnt
		target:SetParent(invEnt)
		target:SetPos(Vector(0, 0, 0))
		target:SetAngles(Angle(0, 0, 0))
		target:SetNoDraw(true)
		target:SetNotSolid(true)
		target:GetPhysicsObject():EnableMotion(false)
		target:GetPhysicsObject():Sleep()
		table.insert(jmodinv.items, {name = target.PrintName or target:GetModel(), model = target:GetModel(), ent = target})
	end

	invEnt.JModInv = jmodinv

	if not noUpdate then
		JMod.UpdateInv(invEnt)
	end

	if invEnt:IsPlayer() then
		JMod.Hint(invEnt,"hint item inventory add")
	end
end

function JMod.RemoveFromInventory(invEnt, target, pos, amt, noUpdate)
	local jmodinv = invEnt.JModInv or {EZresources = {}, items = {}, weight = 0}
	local ReturnToSender

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
		target:SetParent(nil)
		target:SetPos(pos)
		target:SetAngles(target.JModPreferredCarryAngles or AngleRand())
		timer.Simple(0, function()
			if IsValid(target) then
				target:GetPhysicsObject():EnableMotion(true)
				target:GetPhysicsObject():Wake()
			end
		end)
	end

	if not noUpdate then
		JMod.UpdateInv(invEnt)
	end

	if invEnt.NextLoad and invEnt.CalcWeight then 
		invEnt.NextLoad = CurTime() + 2
		invEnt:EmitSound("Ammo_Crate.Close")
		invEnt:CalcWeight()
	end
end