﻿
concommand.Add("jmod_friends", function(ply)
	net.Start("JMod_Friends")
	net.WriteBit(false)
	net.WriteTable(ply.JModFriends or {})
	net.Send(ply)
end, nil, "Opens a menu for you to modify your friend list.")

concommand.Add("jmod_reloadconfig", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	JMod.InitGlobalConfig()
end, nil, "Refreshes your server config file located in garrysmod/data/jmod_config.txt")

concommand.Add("jmod_resetconfig", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	JMod.InitGlobalConfig(true)
end, nil, "Refreshes your server config file located in garrysmod/data/jmod_config.txt")

concommand.Add("jmod_debug_checksalvage", function(ply, cmd, args)
	if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
	local Ent = ply:GetEyeTrace().Entity

	if Ent then
		local Yield, Msg = JMod.GetSalvageYield(Ent)
		print(Msg)
		PrintTable(Yield)
	end
end, nil, "Shows the potential salvaging yield from whatever you're looking at.")

-- WHY ISN'T THIS A THING ALREADY??
concommand.Add("jmod_admin_cleanup", function(ply, cmd, args)
	if (IsValid(ply) and ply:IsSuperAdmin()) or not IsValid(ply) then
		for k, v in pairs(player.GetAll()) do
			if v ~= ply then
				v:KillSilent()
			end
		end

		game.CleanUpMap()

		timer.Simple(.1, function()
			for k, v in pairs(player.GetAll()) do
				JMod.Hint(v, "admin cleanup")
			end
		end)
	end
end, nil, "Does a server-wide admin cleanup of everything, including players.")

concommand.Add("jmod_admin_sanitizemap", function(ply, cmd, args)
	if (IsValid(ply) and ply:IsSuperAdmin()) or not IsValid(ply) then
		for k, v in pairs(ents.GetAll()) do
			if v.EZfalloutParticle then
				v:Remove()
			end

			if v.EZirradiated then
				v.EZirradiated = nil
			end
		end

		print("JMod: decontaminated map by admin command")
	end
end, nil, "Removes JMod radiation and from map and players")

concommand.Add("jmod_debug", function(ply, cmd, args)
	--JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.PROPELLANT, Vector(100, 0, -100), Vector(-100, 0, -100), 1, 1, 1, 0)
	--local Tr=ply:GetEyeTrace()
	--util.Decal("GiantScorch", Tr.HitPos+Tr.HitNormal, Tr.HitPos-Tr.HitNormal)
	--[[
	local Eff = EffectData()
	Eff:SetOrigin(ply:GetShootPos() + ply:GetAimVector() * 200)
	util.Effect("eff_jack_floating_ice_chunk", Eff, true, true)
	--]]
	local Tr=ply:GetEyeTrace()
	local Flare = ents.Create("ent_jack_gmod_ezflareprojectile")
	Flare:SetPos(Tr.HitPos + Vector(0, 0, 15))
	Flare:Spawn()
	Flare:Activate()
	Flare:GetPhysicsObject():SetVelocity(Vector(0, 0, 1500) + VectorRand() * math.random(0, 100))
	sound.Play("snds_jack_gmod/flaregun_fire.wav", Tr.HitPos, 75, math.random(90, 110))
end)

concommand.Add("jmod_debug_killme", function(ply)
	if not IsValid(ply) then return end
	if not GetConVar("sv_cheats"):GetBool() then return end
	ply.EZkillme = true
	print("good luck")
end, nil, "Makes all your entities hate you.")

concommand.Add("jmod_insta_upgrade", function(ply)
	if not IsValid(ply) then return end
	if not ply:IsSuperAdmin() then return end
	local Ent = ply:GetEyeTrace().Entity

	if IsValid(Ent) and Ent.EZupgradable then
		Ent:Upgrade()
	end
end, nil, "Instantly upgrades upgradable machines you are looking at.")

concommand.Add("jmod_deposits_save", function(ply, cmd, args)
	if not(IsValid(ply)) and not(ply:IsSuperAdmin()) then return end
	local ID = args[1]
	if not ID then
		ID = "map_default"
	end
	JMod.SaveDepositConfig(tostring(ID))
end, nil, "Saves your current map deposit layout, saves are map specific.")

concommand.Add("jmod_deposits_load", function(ply, cmd, args)
	if not(IsValid(ply)) and not(ply:IsSuperAdmin()) then return end
	local ID = args[1]
	if not ID then
		ID = "map_default"
	end
	local Info = JMod.LoadDepositConfig(tostring(ID), args[2] and tostring(args[2]))
	if isstring(Info) then
		print(Info)
		return
	else
		JMod.NaturalResourceTable = Info
		net.Start("JMod_NaturalResources")
		net.WriteBool(false)
		net.WriteTable(JMod.NaturalResourceTable)
		net.Send(ply)
	end
end, nil, "Loads a specified deposit layout, first argument is layout ID, second is map name. \n Only use second argument to force load from a differnt map")

timer.Simple(0, function()
	-- This needs to be here I guess, probably due to load order
	JMod.EZ_CONCOMMANDS = {
		{name = "inv", func = JMod.EZ_Open_Inventory, helpTxt = "Opens your EZ inventory to manage your armour.", noShow = true},
		{name = "bombdrop", func = JMod.EZ_BombDrop, helpTxt = "Drops any bombs you have armed and welded."},
		{name = "launch", func = JMod.EZ_WeaponLaunch, helpTxt = "Fires any active missiles you own."},
		{name = "trigger", func = JMod.EZ_Remote_Trigger, helpTxt = "Triggers any EZ bombs/mini-nades you have armed."},
		{name = "scrounge", func = JMod.EZ_ScroungeArea, helpTxt = "Scrounges area for useful props to salvage."},
		{name = "config", func = JMod.EZ_Open_ConfigUI, helpTxt = "Opens the EZ config editor.", adminOnly = true}
	}

	for _, v in ipairs(JMod.EZ_CONCOMMANDS) do
		concommand.Add("jmod_ez_"..v.name, function(ply, cmd, args)
			if not (IsValid(ply) and ply:Alive()) then return end
			if v.adminOnly and not(ply:IsAdmin()) then ply:PrintMessage(HUD_PRINTCENTER, "This command is admin only") return end
			v.func(ply, cmd, args)
		end, nil, v.helpTxt)
	end
end)