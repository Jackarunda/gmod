function JMod_Hint(ply,...)
	if not JMOD_CONFIG.Hints then return end
    if isfunction(l4dgi_hint) then return end
	local HintKeys={...}
	ply.NextJModHint=ply.NextJModHint or 0
	ply.JModHintsGiven=ply.JModHintsGiven or {}
	if ply.NextJModHint > CurTime() then return end
    
	for k,key in pairs(HintKeys) do
		if not ply.JModHintsGiven[key] then
			ply.JModHintsGiven[key] = true
			ply.NextJModHint = CurTime() + 1
			net.Start("JMod_Hint")
			net.WriteString(key)
			net.Send(ply)
			break
		end
	end
end

function JMod_L4DHint(ply, key, loc)
    if not JMOD_CONFIG.Hints or not ply or not key then return nil end
    if not isfunction(l4dgi_hint) then return nil end
    
    ply.JModHintsGiven = ply.JModHintsGiven or {}
	if ply.JModHintsGiven[key] then return false end
	ply.JModHintsGiven[key] = true
    
    local tbl = JMod_L4DHints[key]
    if not tbl then return nil end
    if loc then tbl.Pos = loc end
    tbl.ShouldMove = (loc ~= nil)
    if not tbl.Time then tbl.Time = 10 end
    --if not tbl.Identifier then tbl.Identifier = key end
    l4dgi_hint(tbl, ply)
    return true
end

concommand.Add("jmod_resethints",function(ply,cmd,args)
    ply.JModHintsGiven={}
    print("hints for "..ply:Nick().." reset")
end)

hook.Add("PlayerSpawnedSENT", "JMOD_HINT", function(ply, ent)
    if JMod_L4DHints[ent:GetClass()] then 
        JMod_L4DHint(ply, ent:GetClass(), ent)
        if not ply.JModHintsGiven["pickup"] and ent:GetPhysicsObject():GetMass() <= 50 then
            timer.Simple(5, function() if IsValid(ply) and IsValid(ent) then JMod_L4DHint(ply, "pickup") end end)
        end
    end
end)