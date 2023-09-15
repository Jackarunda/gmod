function JMod.EZ_Open_Inventory(ply)
	net.Start("JMod_Inventory")
	net.WriteString(ply:GetModel())
	net.WriteTable(ply.JModInv)
	net.Send(ply)
end

function JMod.IsEntContained(container, target)
	return IsValid(target) and (target:EntIndex() ~= -1) and IsValid(target.EZInvOwner) and (target.EZInvOwner == container) and IsValid(target:GetParent()) and (target:GetParent() == target.EZInvOwner)
end

function JMod.UpdateInv(invEnt)
	local jmodinv = invEnt.JModInv or {}

	local jmodinvfinal = {}
	for k, v in ipairs(jmodinv) do
		local StoredEnt = v.ent
		--print(invEnt, StoredEnt)
		if IsValid(StoredEnt) then
			if JMod.IsEntContained(invEnt, StoredEnt) then
				table.insert(jmodinvfinal, v)
			end
		elseif v.res then
			table.insert(jmodinvfinal, {name = k, res = k, amt = v})
		end
	end

	invEnt.JModInv = jmodinvfinal
end

function JMod.AddToInventory(invEnt, target)
	--print(invEnt, target, JMod.IsEntContained(invEnt, target))
	if JMod.IsEntContained(invEnt, target) or target:IsPlayer() then return end

	target.EZInvOwner = invEnt
	target:SetParent(invEnt)
	target:SetPos(Vector(0, 0, 0))
	target:SetNoDraw(true)
	target:SetNotSolid(true)
	target:GetPhysicsObject():EnableMotion(false)
	target:GetPhysicsObject():Sleep()
	if invEnt:IsPlayer() then
		JMod.Hint(invEnt,"hint item inventory add")
	end

	local jmodinv = invEnt.JModInv or {}

	if target.IsJackyEZresource then
		table.insert(jmodinv, {name = target.EZsupplies, res = target.EZsupplies, amt = target:GetResource()})
		SafeRemoveEntityDelayed(target, 0)
	else
		table.insert(jmodinv, {name = target.PrintName or target:GetModel(), model = target:GetModel(), ent = target})
	end

	local jmodinvfinal = {}
	local invresources = {}
	for k, v in ipairs(jmodinv) do
		if v.ent then
			local StoredEnt = v.ent
			if JMod.IsEntContained(invEnt, target) then
				table.insert(jmodinvfinal, v)
			end
		elseif v.res then
			if invresources[v.res] then
				invresources[v.res] = invresources[v.res] + v.amt
			else
				invresources[v.res] = v.amt
			end
		end
	end
	if not(table.Empty(invresources)) then
		for k, v in pairs(invresources) do
			table.insert(jmodinvfinal, {name = k, res = k, amt = v})
		end
	end

	invEnt.JModInv = jmodinvfinal
end

function JMod.RemoveFromInventory(invEnt, target, pos, amt)
	if JMod.EZ_RESOURCE_TYPES[target] then
		if not pos then
			pos = invEnt:GetPos() + invEnt:GetUp() * 10
		end
		local Box, Given = ents.Create(JMod.EZ_RESOURCE_ENTITIES[JMod.EZ_RESOURCE_TYPES[target]]), math.min(amt, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
		Box:SetPos(pos)
		Box:SetAngles(invEnt:GetAngles())
		Box:Spawn()
		Box:Activate()
		Box:SetResource(Given)
		--[[timer.Simple(0.1, function()
			if IsValid(Box) and IsValid(activator) and activator:Alive() then
				activator:PickupObject(Box)
			end
		end)--]]
	else
		if not JMod.IsEntContained(invEnt, target) then return end

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

	local jmodinv = invEnt.JModInv or {}

	local jmodinvfinal = {}
	for k, v in ipairs(jmodinv) do
		local StoredEnt = v.ent
		if JMod.IsEntContained(invEnt, StoredEnt) then
			table.insert(jmodinvfinal, v)
		end
	end

	invEnt.JModInv = jmodinvfinal

	if invEnt.NextLoad and invEnt.CalcWeight then 
		invEnt.NextLoad = CurTime() + 2
		invEnt:EmitSound("Ammo_Crate.Close")
		invEnt:CalcWeight()
	end
end