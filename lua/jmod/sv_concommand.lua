concommand.Add("jmod_friends",function(ply)
	net.Start("JMod_Friends")
	net.WriteBit(false)
	net.WriteTable(ply.JModFriends or {})
	net.Send(ply)
end)

concommand.Add("jmod_reloadconfig",function(ply)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	JMod.InitGlobalConfig()
end)

concommand.Add("jmod_resetconfig",function(ply)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	JMod.InitGlobalConfig(true)
end)

concommand.Add("jmod_debug_killme",function(ply)
	if not(IsValid(ply))then return end
	if not(GetConVar("sv_cheats"):GetBool())then return end
	ply.EZkillme=true
	print("good luck")
end)

concommand.Add("jmod_ez_trigger",function(ply)
	JMod.EZ_Remote_Trigger(ply)
end)

concommand.Add("jmod_insta_upgrade",function(ply)
	if not(IsValid(ply))then return end
	if not(ply:IsSuperAdmin())then return end
	local Ent=ply:GetEyeTrace().Entity
	if((IsValid(Ent))and(Ent.EZupgrades)and(Ent.Upgrade))then
		Ent:Upgrade()
	end
end)

concommand.Add("jmod_ez_inv",function(ply,cmd,args)
	if not((IsValid(ply))and(ply:Alive()))then return end
	JMod.EZ_Open_Inventory(ply)
end)

concommand.Add("jmod_ez_bombdrop",function(ply,cmd,args)
	JMod.EZ_BombDrop(ply)
end)

concommand.Add("jmod_ez_launch",function(ply,cmd,args)
	JMod.EZ_WeaponLaunch(ply)
end)