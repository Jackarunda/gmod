

concommand.Add("jmod_friends",function(ply)
	net.Start("JMod_Friends")
	net.WriteBit(false)
	net.WriteTable(ply.JModFriends or {})
	net.Send(ply)
end, nil, "Opens a menu for you to modify your friend list.")

concommand.Add("jmod_reloadconfig",function(ply)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	JMod.InitGlobalConfig()
end, nil, "Refreshes your server config file located in garrysmod/data/jmod_config.txt")

concommand.Add("jmod_resetconfig",function(ply)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	JMod.InitGlobalConfig(true)
end, nil, "Refreshes your server config file located in garrysmod/data/jmod_config.txt")

concommand.Add("jmod_debug_checksalvage",function(ply,cmd,args)
	if not(IsValid(ply) and ply:IsSuperAdmin())then return end
	local Ent=ply:GetEyeTrace().Entity
	if(Ent)then
		local Yield,Msg=JMod.GetSalvageYield(Ent)
		print(Msg)
		PrintTable(Yield)
	end
end, nil, "Shows the potential salvaging yield from whatever you're looking at.")

concommand.Add("jmod_admin_cleanup",function(ply,cmd,args) -- WHY ISN'T THIS A THING ALREADY??
	if(((IsValid(ply))and(ply:IsSuperAdmin()))or not(IsValid(ply)))then
		game.CleanUpMap()
		print("JMod: cleaned up map by admin command")
		timer.Simple(.1,function()
			for k,v in pairs(player.GetAll())do
				JMod.Hint(v,"admin cleanup")
			end
		end)
	end
end, nil, "Does a server-wide admin cleanup of everything.")

concommand.Add("jmod_debug",function(ply,cmd,args)
	--[[
	local splad=EffectData()
	splad:SetOrigin(ply:GetShootPos()+ply:GetAimVector()*1000)
	splad:SetScale(.5)
	splad:SetNormal(Vector(0,0,-1))
	util.Effect("eff_jack_gmod_efpburst",splad,true,true)
	--]]
end)

concommand.Add("jmod_debug_killme",function(ply)
	if not(IsValid(ply))then return end
	if not(GetConVar("sv_cheats"):GetBool())then return end
	ply.EZkillme=true
	print("good luck")
end, nil, "Makes all your entities hate you.")

concommand.Add("jmod_ez_trigger",function(ply, help)
	JMod.EZ_Remote_Trigger(ply)
end, nil, "Triggers any EZ bombs/mini-nades you have armed.")

concommand.Add("jmod_insta_upgrade",function(ply)
	if not(IsValid(ply))then return end
	if not(ply:IsSuperAdmin())then return end
	local Ent=ply:GetEyeTrace().Entity
	if((IsValid(Ent))and(Ent.EZupgradable))then
		Ent:Upgrade()
	end
end, nil, "Instantly upgrades upgradable machines you are looking at.")

concommand.Add("jmod_ez_inv",function(ply,cmd,args)
	if not((IsValid(ply))and(ply:Alive()))then return end
	JMod.EZ_Open_Inventory(ply)
end, nil, "Opens your EZ inventory to manage your armour.")

concommand.Add("jmod_ez_bombdrop",function(ply,cmd,args)
	JMod.EZ_BombDrop(ply)
end, nil, "Drops any bombs you have armed and welded.")

concommand.Add("jmod_ez_launch",function(ply,cmd,args)
	JMod.EZ_WeaponLaunch(ply)
end, nil, "Fires any active missiles you own.")
