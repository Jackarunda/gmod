function JMod_Hint(ply, key, loc, forceLegacy)
    if not JMOD_CONFIG.Hints or not ply or not key then return nil end
    if tonumber(ply:GetInfo("cl_jmod_hint_enabled")) == 0 then return nil end
   
    ply.JModHintsGiven = ply.JModHintsGiven or {}
	if ply.JModHintsGiven[key] then return false end
	ply.JModHintsGiven[key] = true
    
    local tbl = JMod_Hints[key]
    if not tbl then return nil end
    if loc then tbl.Pos = loc end
    tbl.ShouldMove = (loc ~= nil)
    tbl.Key = key
    if not tbl.Time then tbl.Time = 8 end

    if forceLegacy or tonumber(ply:GetInfo("cl_jmod_hint_legacy")) == 1 then 
        net.Start("JMod_Hint")
            net.WriteBool(false)
            net.WriteString(tbl.Text)
        net.Send(ply)
    else
        net.Start("JMod_Hint")
            net.WriteBool(true)
            net.WriteTable(tbl)
        net.Send(ply)
    end
    
    if tbl.Followup and JMod_Hints[tbl.Followup] then
        timer.Simple(tbl.Time, function()
            if IsValid(ply) then
                JMod_Hint(ply, tbl.Followup)
            end
        end)
    end
    
    return true
end

concommand.Add("jmod_resethints",function(ply,cmd,args)
    if not ply then ply = Player(args[1]) end
    if not ply then return end
    
    ply.JModHintsGiven={}
    print("hints for "..ply:Nick().." reset")
end)

hook.Add("PlayerSpawnedSENT", "JMOD_HINT", function(ply, ent)
    if JMod_Hints[ent:GetClass()] then 
        JMod_Hint(ply, ent:GetClass(), ent)
    end
end)

hook.Add("PlayerInitialSpawn","JMOD_HINT",function(ply)

    if tonumber(ply:GetInfo("cl_jmod_hint_enabled")) == 0 then return end

    if (JMOD_CONFIG) and (JMOD_CONFIG.Hints) then
        timer.Simple(5,function()
            if IsValid(ply) then
                JMod_Hint(ply, "wiki",nil,true)
            end
        end)
        timer.Simple(10,function()
            if IsValid(ply) then
                JMod_Hint(ply, "hint",nil,true)
            end
        end)
        if ply:IsAdmin() then
            timer.Simple(15,function()
                if IsValid(ply) then
                    JMod_Hint(ply, "config",nil,true)
                end
            end)
        end
    end
end)