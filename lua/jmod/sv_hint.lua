function JMod.Hint(ply, key)
	if not (JMod.Config.Hints and ply and key) then return nil end
	if not IsValid(ply) then return end
	local tbl = JMod.Hints[key]
	if not tbl then return nil end
	ply.JModHintsGiven = ply.JModHintsGiven or {}
	local Limit = tbl.RepeatCount or 0
	if (ply.JModHintsGiven[key] or 0) > Limit then return false end
	ply.JModHintsGiven[key] = (ply.JModHintsGiven[key] or 0) + 1
	net.Start("JMod_Hint")

	if tbl.LangKey then
		net.WriteBool(true)
		net.WriteString(tbl.LangKey)
	else
		net.WriteBool(false)
		net.WriteString(tbl.Text)
	end

	net.WriteInt(tbl.IconType or 3, 8)
	net.WriteInt(tbl.Time or 8, 8)
	net.Send(ply)

	if tbl.Followup and JMod.Hints[tbl.Followup] then
		timer.Simple(tbl.Time or 8, function()
			if IsValid(ply) then
				JMod.Hint(ply, tbl.Followup)
			end
		end)
	end

	return true
end

concommand.Add("jmod_resethints", function(ply, cmd, args)
	if not ply then
		ply = Player(args[1])
	end

	if not ply then return end
	ply.JModHintsGiven = {}
	print("hints for " .. ply:Nick() .. " reset")
end, nil, "Resets your Jmod hints.")

hook.Add("PlayerInitialSpawn", "JMOD_HINT", function(ply)
	if JMod.Config and JMod.Config.Hints then
		timer.Simple(10, function()
			if IsValid(ply) then
				if ply:IsSuperAdmin() then
					timer.Simple(5, function()
						if IsValid(ply) then
							JMod.Hint(ply, "config")
						end
					end)

					timer.Simple(10, function()
						if IsValid(ply) then
							JMod.Hint(ply, "qol")
						end
					end)

					timer.Simple(15, function()
						if IsValid(ply) then
							JMod.Hint(ply, "hint reset")
						end
					end)
				end
			end
		end)
	end
end)
