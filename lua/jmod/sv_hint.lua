function JMod.Hint(ply, key, loc, specific)
	if not JMod.Config.Hints or not ply or not key then return nil end
	ply.JModHintsGiven = ply.JModHintsGiven or {}
	if ply.JModHintsGiven[key] and not specific then return false end
	ply.JModHintsGiven[key] = true
	
	local tbl = JMod.Hints[key]
	if(specific)then tbl = JMod.SpecificHints[key] end
	if not tbl then return nil end
	if loc then tbl.Pos = loc end
	tbl.ShouldMove = (loc ~= nil)
	tbl.Key = key
	if not tbl.Time then tbl.Time = 8 end
	net.Start("JMod_Hint")
	net.WriteBool(specific)
	net.WriteString(tbl.Text)
	net.Send(ply)
	
	if tbl.Followup and JMod.Hints[tbl.Followup] then
		timer.Simple(tbl.Time, function()
			if IsValid(ply) then
				JMod.Hint(ply, tbl.Followup, loc, specific)
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
	if JMod.Hints[ent:GetClass()] then 
		JMod.Hint(ply, ent:GetClass(), ent)
	end
end)

hook.Add("PlayerInitialSpawn","JMOD_HINT",function(ply)
	if (JMod.Config) and (JMod.Config.Hints) then
		timer.Simple(10,function()
			if IsValid(ply) then
				if ply:IsSuperAdmin() then
					timer.Simple(5,function()
						if IsValid(ply) then
							JMod.Hint(ply, "config")
						end
					end)
					timer.Simple(10,function()
						if IsValid(ply) then
							JMod.Hint(ply, "qol")
						end
					end)
					timer.Simple(15,function()
						if IsValid(ply) then
							JMod.Hint(ply, "hint reset")
						end
					end)
				end
			end
		end)
	end
end)