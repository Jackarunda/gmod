util.AddNetworkString("JMod_Friends") -- ^:3
util.AddNetworkString("JMod_ColorAndArm")
util.AddNetworkString("JMod_EZtoolbox")
util.AddNetworkString("JMod_EZworkbench")
util.AddNetworkString("JMod_Hint")
util.AddNetworkString("JMod_EZtimeBomb")
util.AddNetworkString("JMod_LuaConfigSync")
util.AddNetworkString("JMod_PlayerSpawn")
util.AddNetworkString("JMod_ModifyMachine")
util.AddNetworkString("JMod_ModifyConnections")
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
util.AddNetworkString("JMod_LiquidParticle")

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
	if (ply:GetPos():Distance(ent:GetPos()) > 150) then return end

	local AutoColor = net.ReadBool()
	local Col = net.ReadColor()
	local AutoArm = net.ReadBool()

	if AutoColor then
		if ent.EZscannerDanger then
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
			local PlyCol = ply:GetPlayerColor():ToColor()
			ent:SetColor(PlyCol)
		end
		timer.Simple(.1, function()
			if not(IsValid(ent) and IsValid(ply) and ply:Alive()) or (AutoArm) then return end
			net.Start("JMod_ColorAndArm")
			net.WriteEntity(ent)
			net.WriteBool(true)
			net.Send(ply)
		end)
	else
		ent:SetColor(Col)
	end

	if AutoArm then
		if ent.Prime then
			ent:Prime(ply)
		elseif ent.Arm then
			ent:Arm(ply)
		end
	end
end)

net.Receive("JMod_ArmorColor", function(ln, ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local ArmorEnt = net.ReadEntity()
	if not IsValid(ArmorEnt) or not ArmorEnt.ArmorName then return end
	if JMod.ArmorTable[ArmorEnt.ArmorName].clrForced then return end
	if (ply:GetPos():Distance(ArmorEnt:GetPos()) > 150) then return end

	local AutoColor = net.ReadBool()
	local Col = net.ReadColor()
	Col.r = math.max(Col.r, 50)
	Col.g = math.max(Col.g, 50)
	Col.b = math.max(Col.b, 50)
	ArmorEnt:SetColor(Color(Col.r, Col.g, Col.b))

	if AutoColor == true then
		timer.Simple(0.1, function()
			if not(IsValid(ArmorEnt) and IsValid(ply) and ply:Alive()) then return end
			net.Start("JMod_ArmorColor")
				net.WriteEntity(ArmorEnt)
				net.WriteBool(true)
				net.WriteFloat(ArmorEnt.Durability)
				net.WriteFloat(ArmorEnt.Specs.dur)
			net.Send(ply)
		end)
	end
	
	local Equip = tobool(net.ReadBit())

	if Equip then--and JMod.VisCheck(ply:GetShootPos(), Armor, ply) then
		JMod.Hint(ply, "armor weight")
		JMod.EZ_Equip_Armor(ply, ArmorEnt)
	end
end)

net.Receive("JMod_EZtoolbox", function(ln, ply)
	local Wep, Name = net.ReadEntity(), net.ReadString()

	if IsValid(Wep) then
		Wep:SwitchSelectedBuild(Name)
	end
	Wep.EZpreview = net.ReadTable() or {}
end)

net.Receive("JMod_EZworkbench", function(l, ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local bench, name = net.ReadEntity(), net.ReadString()
	if not IsValid(bench) then return end
	if name == "JMOD_SCRAPINV" and bench.ScrapInv then
		bench:ScrapInv(ply)
	elseif bench.TryBuild and ply:GetPos():Distance(bench:GetPos()) < 300 then
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
		ent:EmitSound("snd_jack_minearm.ogg", 60, 100)
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

net.Receive("JMod_ModifyConnections", function(ln, ply)
	if not ply:Alive() then return end
	local Ent, Action = net.ReadEntity(), net.ReadString()
	if not IsValid(Ent) then return end
	local Ent2 = net.ReadEntity()
	--print(Action, Ent, Ent2)
	if (JMod.GetEZowner(Ent) ~= ply) or (ply:GetPos():Distance(Ent:GetPos()) > 500) then return end

	if Action == "connect" then
		JMod.StartResourceConnection(Ent, ply)
	elseif Action == "disconnect" then
		if not IsValid(Ent2) then return end
		JMod.RemoveResourceConnection(Ent, Ent2)
	elseif Action == "disconnect_all" then
		if Ent.DisconnectAll then
			Ent:DisconnectAll()
		else
			JMod.RemoveResourceConnection(Ent)
		end
	elseif Action == "produce" then
		if IsValid(Ent2) and JMod.ConnectionValid(Ent, Ent2) and Ent2.ProduceResource then
			Ent2:ProduceResource()
		else
			Ent:ProduceResource(ply)
		end
	elseif Action == "toggle" then
		if IsValid(Ent2) and JMod.ConnectionValid(Ent, Ent2) and Ent2.GetState then 
			if Ent2:GetState() == JMod.EZ_STATE_OFF then
				Ent2:TurnOn(ply)
			elseif Ent2:GetState() >= JMod.EZ_STATE_ON then
				Ent2:TurnOff(ply)
			end
		elseif Ent.GetState then
			if Ent:GetState() == JMod.EZ_STATE_OFF then
				Ent:TurnOn(ply)
			elseif Ent:GetState() >= JMod.EZ_STATE_ON then
				Ent:TurnOff(ply)
			end
		end
	end
end)

net.Receive("JMod_SaveLoadDeposits", function(ln, ply) 
	if not(JMod.IsAdmin(ply)) then return end
	
	local Operation = net.ReadString()
	local EntryID = net.ReadString()

	if IsValid(ply) then 
		--print(Operation, EntryID)
		if string.lower(Operation) == "save" then
			ply:ConCommand("jmod_deposits_save "..EntryID)
		elseif (string.lower(Operation) == "load") then
			ply:ConCommand("jmod_deposits_load "..EntryID)
		elseif string.lower(Operation) == "load_list" then
			local ListOfOptions = {}
			local FileContents = file.Read("jmod_resources_"..game.GetMap()..".txt")
			
			if FileContents then
				local MapConfig = util.JSONToTable(FileContents) or {}
				for k, v in pairs(MapConfig) do
					table.insert(ListOfOptions, k)
				end
			end
			net.Start("JMod_SaveLoadDeposits")
				net.WriteString("load_list")
				net.WriteTable(ListOfOptions)
			net.Send(ply)
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
