function JMod.EZ_WeaponLaunch(ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local Weps = {}
	local Pods = {}

	for k, ent in ents.Iterator() do
		if ent.EZlaunchableWeaponLoadTime and JMod.GetEZowner(ent) == ply then
			table.insert(Pods, ent)
		elseif ent.EZlaunchableWeaponArmedTime and JMod.GetEZowner(ent) == ply and ent:GetState() == 1 then
			table.insert(Weps, ent)
		end
	end

	local FirstWep, Earliest = nil, 9e9

	for k, wep in pairs(Weps) do
		if wep.EZlaunchableWeaponArmedTime < Earliest then
			FirstWep = wep
			Earliest = wep.EZlaunchableWeaponArmedTime
		end
	end

	for k, pod in pairs(Pods) do
		if pod.EZlaunchableWeaponLoadTime < Earliest then
			FirstWep = pod
			Earliest = pod.EZlaunchableWeaponLoadTime
		end
	end

	if IsValid(FirstWep) then
		-- knock knock it's pizza time
		FirstWep:EmitSound("buttons/button6.wav", 75, 110)

		timer.Simple(.2, function()
			if IsValid(FirstWep) then
				if FirstWep.EZlaunchableWeaponLoadTime then
					FirstWep:LaunchRocket(#FirstWep.Rockets, true, ply)
				elseif FirstWep.EZlaunchableWeaponArmedTime then
					FirstWep.DropOwner = ply
					FirstWep:Launch()
				end
			end
		end)
	end
end

function JMod.EZ_BombDrop(ply)
	if not (IsValid(ply) and ply:Alive()) then return end
	local Boms = {}
	local Bays = {}

	for k, ent in ents.Iterator() do
		if ent.EZdroppableBombArmedTime and IsValid(ent.EZowner) and ent.EZowner == ply then
			table.insert(Boms, ent)
		elseif ent.EZdroppableBombLoadTime and IsValid(ent.EZowner) and ent.EZowner == ply then
			table.insert(Bays, ent)
		end
	end

	local FirstBom, Earliest = nil, 9e9

	for k, bay in pairs(Bays) do
		if (bay.EZdroppableBombLoadTime < Earliest) and (#bay.Bombs > 0) then
			FirstBom = bay
			Earliest = bay.EZdroppableBombLoadTime
		end
	end

	for k, bom in pairs(Boms) do
		if (bom.EZdroppableBombArmedTime < Earliest) and (constraint.HasConstraints(bom) or not bom:GetPhysicsObject():IsMotionEnabled()) then
			FirstBom = bom
			Earliest = bom.EZdroppableBombArmedTime
		end
	end

	if IsValid(FirstBom) then
		-- knock knock it's pizza time
		FirstBom:EmitSound("buttons/button6.wav", 75, 120)

		timer.Simple(.2, function()
			if IsValid(FirstBom) then
				if FirstBom.EZdroppableBombArmedTime then
					if FirstBom.Drop then
						FirstBom:Drop(ply)
					else
						constraint.RemoveAll(FirstBom)
						FirstBom:GetPhysicsObject():EnableMotion(true)
						FirstBom:GetPhysicsObject():Wake()
						FirstBom.DropOwner = ply
					end
				elseif FirstBom.EZdroppableBombLoadTime then
					FirstBom:BombRelease(#FirstBom.Bombs, true, ply)
				end
			end
		end)
	end
end

function JMod.EZ_Remote_Trigger(ply)
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	sound.Play("snd_jack_detonator.ogg", ply:GetShootPos(), 55, math.random(90, 110))

	timer.Simple(.75, function()
		if IsValid(ply) and ply:Alive() then
			for k, v in ents.Iterator() do
				if v.JModEZremoteTriggerFunc and v.EZowner and (v.EZowner == ply) then
					v:JModEZremoteTriggerFunc(ply)
				end
			end
		end
	end)
end

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

-- WHY ISN'T THIS A THING ALREADY??
concommand.Add("jmod_admin_cleanup", function(ply, cmd, args)
	if (IsValid(ply) and ply:IsSuperAdmin()) or not IsValid(ply) then
		for k, v in player.Iterator() do
			if v ~= ply then
				v:KillSilent()
			end
		end

		game.CleanUpMap()

		timer.Simple(.1, function()
			for k, v in player.Iterator() do
				JMod.Hint(v, "admin cleanup")
			end
		end)
	end
end, nil, "Does a server-wide admin cleanup of everything, including players.")

concommand.Add("jmod_admin_sanitizemap", function(ply, cmd, args)
	if (IsValid(ply) and ply:IsSuperAdmin()) or not IsValid(ply) then
		for k, v in ents.Iterator() do
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
	if not(JMod.IsAdmin(ply)) then return end
	--[[
	for i = 1, 100 do
		timer.Simple(i / 20, function()
			JMod.LiquidSpray(ply:GetShootPos() - ply:GetUp() * 10 + ply:GetRight() * 10, ply:GetAimVector() * 1000, 1, 1, 2)
		end)
	end
	--]]
	---[[
	local EffData = EffectData()
	EffData:SetOrigin(ply:GetShootPos() + ply:GetAimVector() * 500)
	EffData:SetScale(240)
	util.Effect("eff_jack_gmod_bubbleshieldburst", EffData, true, true)
	--]]
	--print(JMod.GetHoliday())
	--JMod.DebugArrangeEveryone(ply)
	--JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.PROPELLANT, Vector(100, 0, -100), Vector(-100, 0, -100), 1, 1, 1, 0)
	--local Tr=ply:GetEyeTrace()
	--util.Decal("GiantScorch", Tr.HitPos+Tr.HitNormal, Tr.HitPos-Tr.HitNormal)
	--[[
	local Eff = EffectData()
	Eff:SetOrigin(ply:GetShootPos() + ply:GetAimVector() * 200)
	util.Effect("eff_jack_floating_ice_chunk", Eff, true, true)
	local Tr=ply:GetEyeTrace()
	local Flare = ents.Create("ent_jack_gmod_ezflareprojectile")
	Flare:SetPos(Tr.HitPos + Vector(0, 0, 15))
	Flare:Spawn()
	Flare:Activate()
	Flare:GetPhysicsObject():SetVelocity(Vector(0, 0, 1500) + VectorRand() * math.random(0, 100))
	sound.Play("snds_jack_gmod/flaregun_fire.ogg", Tr.HitPos, 75, math.random(90, 110))
	--]]
	--[[
	local tre = ents.Create("ent_jack_gmod_eztree")
	tre:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, 10))
	tre:Spawn()
	tre:Activate()
	JMod.SetEZowner(tre, ply)
	--]]
	--[[
	local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 500, ply)
	Feff = EffectData()
	Feff:SetOrigin(Tr.HitPos)
	Feff:SetStart(Vector(0,0,0))
	Feff:SetScale(1)
	util.Effect("eff_jack_gmod_ezfalloutdust", Feff, true, false)
	--]]
	--[[
	net.Start("JMod_VisionBlur")
	net.WriteFloat(75)
	net.WriteFloat(2000)
	net.WriteBit(true)
	net.Send(ply)
	--]]
end)

concommand.Add("jmod_debug_killme", function(ply)
	if not IsValid(ply) then return end
	if not GetConVar("sv_cheats"):GetBool() then return end
	ply.EZkillme = true
	print("good luck")
end, nil, "Makes all your entities hate you.")

concommand.Add("jmod_insta_upgrade", function(ply, cmd, args)
	if not IsValid(ply) then return end
	if not ply:IsSuperAdmin() then return end
	local Ent = ply:GetEyeTrace().Entity

	local Level = tonumber(args[1]) and tonumber(args[1]) or nil
	if IsValid(Ent) and Ent.EZupgradable then
		Ent:Upgrade(Level)
	elseif IsValid(Ent) and Ent.Growth then
		Ent.Growth = 100
	end
end, nil, "Instantly upgrades upgradable machines you are looking at. \nEnter a number for desired grade")

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