function JMod.EZ_Open_Inventory(ply)
	net.Start("JMod_Inventory")
	net.WriteString(ply:GetModel())
	net.WriteTable(invEnt.JModInv)
	net.Send(ply)
end

function JMod.IsEntContained(container, target)
	return IsValid(target) and (target:EntIndex() ~= -1) and IsValid(target.EZInvOwner) and (target.EZInvOwner == container) and IsValid(target:GetParent()) and (target:GetParent() == target.EZInvOwner)
end

function JMod.AddToInventory(invEnt, target)
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

	table.insert(jmodinv, {name = target.PrintName or target:GetModel(), model = target:GetModel(), ent = target})

	local jmodinvfinal = {}
	for k, v in ipairs(jmodinv) do
		if v.ent then
			local StoredEnt = v.ent
			if JMod.IsEntContained(invEnt, target) then
				table.insert(jmodinvfinal, v)
			end
		end
	end

	invEnt.JModInv = jmodinvfinal
end

function JMod.RemoveFromInventory(invEnt, target, pos)
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

	local jmodinv = invEnt.JModInv or {}

	local jmodinvfinal = {}
	for k, v in ipairs(jmodinv) do
		if v.ent ~= target then
			local StoredEnt = v.ent
			if JMod.IsEntContained(invEnt, StoredEnt) then
				print(invEnt, StoredEnt)
				table.insert(jmodinvfinal, v)
			end
		end
	end

	invEnt.JModInv = jmodinvfinal

	if invEnt.NextLoad and invEnt.CalcWeight then 
		invEnt.NextLoad = CurTime() + 2
		invEnt:EmitSound("Ammo_Crate.Close")
		invEnt:CalcWeight()
	end
end