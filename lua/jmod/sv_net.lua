util.AddNetworkString("JMod_Friends") -- ^:3
util.AddNetworkString("JMod_ColorAndArm")
util.AddNetworkString("JMod_EZtoolbox")
util.AddNetworkString("JMod_EZworkbench")
util.AddNetworkString("JMod_Hint")
util.AddNetworkString("JMod_EZtimeBomb")
util.AddNetworkString("JMod_LuaConfigSync")
util.AddNetworkString("JMod_PlayerSpawn")
util.AddNetworkString("JMod_ModifyMachine")
util.AddNetworkString("JMod_NuclearBlast")
util.AddNetworkString("JMod_VisionBlur")
util.AddNetworkString("JMod_ArmorColor")
util.AddNetworkString("JMod_EZarmorSync")
util.AddNetworkString("JMod_Inventory")
util.AddNetworkString("JMod_ItemInventory") -- Item inventory
util.AddNetworkString("JMod_EZradio")
util.AddNetworkString("JMod_EZweaponMod")
util.AddNetworkString("JMod_Bleeding")
util.AddNetworkString("JMod_SFX")
util.AddNetworkString("JMod_Ravebreak")
util.AddNetworkString("JMod_NaturalResources")
util.AddNetworkString("JMod_SaveLoadDeposits")
util.AddNetworkString("JMod_ResourceScanner")
util.AddNetworkString("JMod_VisualGunRecoil")
util.AddNetworkString("JMod_EquippableSync")
util.AddNetworkString("JMod_MachineSync")
util.AddNetworkString("JMod_Debugging") -- engineer gaming
util.AddNetworkString("JMod_ConfigUI")
util.AddNetworkString("JMod_ApplyConfig")

net.Receive("JMod_Friends", function(length, ply)
	local List, Good = net.ReadTable(), true

	for k, v in pairs(List) do
		if not (IsValid(v) and v:IsPlayer()) then
			Good = false
		end
	end

	if Good then
		ply.JModFriends = List
		ply:PrintMessage(HUD_PRINTCENTER, "JMod EZ friends list updated")
		net.Start("JMod_Friends")
		net.WriteBit(true)
		net.WriteEntity(ply)
		net.WriteTable(List)
		net.Broadcast()
	else
		ply.JModFriends = {}
	end
end)

net.Receive("JMod_ColorAndArm", function(l, ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local ent = net.ReadEntity()
	if not (IsValid(ent) and ent.JModGUIcolorable) then return end
	if ply:GetPos():DistToSqr(ent:GetPos()) > 15000 then return end
		local AutoColor = net.ReadBit()
		local Col = net.ReadColor()

		if AutoColor == 1 then
			local Tr = util.QuickTrace(ent:GetPos() + Vector(0, 0, 10), Vector(0, 0, -50), ent)
			if Tr.Hit then
				local Info = JMod.HitMatColors[Tr.MatType]

				if Info then
					ent:SetColor(Info[1])

					if Info[2] then
						ent:SetMaterial(Info[2])
					end
				end
			end
		else
			ent:SetColor(Col)
		end

	if net.ReadBit() == 1 then
		if ent.Prime then
			ent:Prime(ply)
		elseif ent.Arm then
			ent:Arm(ply)
		end
	end
end)

net.Receive("JMod_ArmorColor", function(ln, ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local Armor = net.ReadEntity()
	if not IsValid(Armor) or not Armor.ArmorName then return end
	local Col = net.ReadColor()
	Armor:SetColor(Col)
	local Equip = tobool(net.ReadBit())

	if Equip then
		JMod.Hint(ply, "armor weight")
		JMod.EZ_Equip_Armor(ply, Armor)
	end
end)

net.Receive("JMod_EZtoolbox", function(ln, ply)
	local Wep, Name = net.ReadEntity(), net.ReadString()

	if IsValid(Wep) then
		Wep:SwitchSelectedBuild(Name)
	end
end)

net.Receive("JMod_EZworkbench", function(l, ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local bench, name = net.ReadEntity(), net.ReadString()

	if (IsValid(bench) and bench.TryBuild) and ply:GetPos():DistToSqr(bench:GetPos()) < 15000 then
		bench:TryBuild(name, ply)
	end
end)

net.Receive("JMod_EZtimeBomb", function(ln, ply)
	local ent = net.ReadEntity()
	local tim = net.ReadInt(16)

	if (ent:GetState() == 0) and (ent.EZowner == ply) and ply:Alive() and (ply:GetPos():Distance(ent:GetPos()) <= 150) then
		ent:SetTimer(math.min(tim, 600))
		ent.DisarmNeeded = math.Round(math.min(tim, 600) / 4)
		ent:NextThink(CurTime() + 1)
		ent:SetState(1)
		ent:EmitSound("weapons/c4/c4_plant.wav", 60, 120)
		ent:EmitSound("snd_jack_minearm.wav", 60, 100)
	end
end)

net.Receive("JMod_ModifyMachine", function(ln, ply)
	if not ply:Alive() then return end
	local AmmoType = nil
	local Ent, Tbl, HasAmmoType = net.ReadEntity(), net.ReadTable(), tobool(net.ReadBit())

	if HasAmmoType then
		AmmoType = net.ReadString()
	end

	if not IsValid(Ent) then return end
	if not (Ent:GetPos():Distance(ply:GetPos()) < 200) then return end
	local Wepolini = ply:GetActiveWeapon()
	if not (Wepolini and Wepolini.ModifyMachine) then return end
	Wepolini:ModifyMachine(Ent, Tbl, AmmoType)
end)

net.Receive("JMod_SaveLoadDeposits", function(ln, ply) 
	local Operation = net.ReadString()
	local EntryID = net.ReadString()
	if IsValid(ply) then 
		--print(Operation, EntryID)
		if string.lower(Operation) == "save" then
			ply:ConCommand("jmod_deposits_save "..EntryID)
		elseif string.lower(Operation) == "load" then
			ply:ConCommand("jmod_deposits_load "..EntryID)
		elseif string.lower(Operation) == "clear" then
			JMod.NaturalResourceTable = {}
			net.Start("JMod_NaturalResources")
				net.WriteBool(false)
				net.WriteTable(JMod.NaturalResourceTable)
			net.Send(ply)
		end
	end
end)

net.Receive("JMod_ApplyConfig", function(ln, ply)
	if not ply:IsValid() then return end
	if not ply:IsSuperAdmin() then return end
	local data = util.JSONToTable(util.Decompress(net.ReadData(ln)))
	JMod.InitGlobalConfig(true, data)
end)


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

	print(command, amt, resourceType, target, invEnt)
	
	if command == "take" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
		JMod.AddToInventory(invEnt, target)
	elseif command == "drop" then
		if not(IsValid(target)) then JMod.Hint(ply, "hint item inventory missing") return false end
		local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 50, ply)
		JMod.RemoveFromInventory(invEnt, target, Tr.HitPos + Vector(0, 0, 10))
		JMod.Hint(ply,"hint item inventory drop")
	elseif command == "drop_res" then
		local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 50, ply)
		JMod.RemoveFromInventory(invEnt, resourceType, Tr.HitPos + Vector(0, 0, 10), amt)
		--JMod.Hint(ply,"hint item inventory drop")
	elseif command == "use" then
		---
	elseif command == "full" then
		JMod.Hint(ply,"hint item inventory full")
	elseif command == "missing" then
		JMod.UpdateInv(invEnt)
		JMod.Hint(ply,"hint item inventory missing")
	end
end)