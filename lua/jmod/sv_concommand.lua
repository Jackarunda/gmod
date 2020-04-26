concommand.Add("jmod_friends",function(ply)
    net.Start("JMod_Friends")
    net.WriteBit(false)
    net.WriteTable(ply.JModFriends or {})
    net.Send(ply)
end)

concommand.Add("jmod_reloadconfig",function(ply)
    if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
    JMod_InitGlobalConfig()
end)

concommand.Add("jmod_resetconfig",function(ply)
    if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
    JMod_InitGlobalConfig(true)
end)

concommand.Add("jmod_debug_killme",function(ply)
    if not(IsValid(ply))then return end
    if not(GetConVar("sv_cheats"):GetBool())then return end
    ply.EZkillme=true
    ply:PrintMessage(HUD_PRINTCENTER,"good luck")
end)

concommand.Add("jmod_ez_trigger",function(ply)
    JMod_EZ_Remote_Trigger(ply)
end)

concommand.Add("jmod_insta_upgrade",function(ply)
    if not(IsValid(ply))then return end
    if not(ply:IsSuperAdmin())then return end
    local Ent=ply:GetEyeTrace().Entity
    if((IsValid(Ent))and(Ent.EZupgrades)and(Ent.Upgrade))then
        Ent:Upgrade()
    end
end)

concommand.Add("jmod_ez_armor",function(ply,cmd,args)
    if not((IsValid(ply))and(ply:Alive()))then return end
    JMod_EZ_Remove_Armor(ply)
end)

concommand.Add("jmod_ez_mask",function(ply,cmd,args)
    JMod_EZ_Toggle_Mask(ply)
end)

concommand.Add("jmod_ez_headset",function(ply,cmd,args)
    JMod_EZ_Toggle_Headset(ply)
end)

concommand.Add("jmod_ez_bombdrop",function(ply,cmd,args)
    JMod_EZ_BombDrop(ply)
end)

concommand.Add("jmod_ez_launch",function(ply,cmd,args)
    JMod_EZ_WeaponLaunch(ply)
end)