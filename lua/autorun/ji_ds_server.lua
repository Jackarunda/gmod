include("JI_DS_Shared.lua")
if(SERVER)then
	util.AddNetworkString("JMod_Friends") -- ^:3
	local ArmorDisadvantages={
		--vests
		["Ballistic Nylon"]=.99,
		["Stab Vest"]=.95,
		["Soft Kevlar"]=.95,
		["Kevlar SAPI"]=.75,
		["Impact Vest"]=.7,
		--suits
		["Hazardous Material"]=.75,
		["Fire-Faraday"]=.75,
		["EOD"]=.5
	}
	local ArmorAppearances={
		--suits
		["Hazardous Material"]="models/dpfilms/jetropolice/playermodels/pm_police_bt.mdl",
		["Fire-Faraday"]="models/dpfilms/jetropolice/playermodels/pm_policetrench.mdl",
		["EOD"]="models/juggerjaut_player.mdl"
	}
	local ArmorAdvantages={
		--vests
		["Ballistic Nylon"]={[DMG_SLASH]=.8,[DMG_CLUB]=.95,[DMG_CRUSH]=.95,[DMG_BULLET]=.85,[DMG_BUCKSHOT]=.85,[DMG_BLAST]=.6},
		["Stab Vest"]={[DMG_SLASH]=.2,[DMG_CLUB]=.8,[DMG_CRUSH]=.8,[DMG_BULLET]=.99,[DMG_BUCKSHOT]=.99,[DMG_BLAST]=.99},
		["Soft Kevlar"]={[DMG_SLASH]=.9,[DMG_CLUB]=.9,[DMG_CRUSH]=.9,[DMG_BULLET]=.7,[DMG_BUCKSHOT]=.6,[DMG_BLAST]=.5,[DMG_AIRBOAT]=.75},
		["Kevlar SAPI"]={[DMG_SLASH]=.8,[DMG_CLUB]=.6,[DMG_CRUSH]=.6,[DMG_BULLET]=.4,[DMG_BUCKSHOT]=.3,[DMG_BLAST]=.4,[DMG_AIRBOAT]=.5},
		["Impact Vest"]={[DMG_SLASH]=.5,[DMG_CLUB]=.3,[DMG_CRUSH]=.2,[DMG_BULLET]=.8,[DMG_BUCKSHOT]=.8,[DMG_BLAST]=.9,[DMG_VEHICLE]=.3},
		--helmets
		["Steel"]={{[DMG_SLASH]=.9,[DMG_CLUB]=.8,[DMG_CRUSH]=.8,[DMG_BLAST]=.9},.4},
		["Kevlar Resin"]={{[DMG_SLASH]=.95,[DMG_CLUB]=.95,[DMG_CRUSH]=.95,[DMG_BLAST]=.95},.6},
		["Polyethylene"]={{[DMG_SLASH]=.9,[DMG_CLUB]=.9,[DMG_CRUSH]=.9,[DMG_BLAST]=.9},.65},
		["Riot"]={{[DMG_SLASH]=.8,[DMG_CLUB]=.8,[DMG_CRUSH]=.8,[DMG_BLAST]=.85},.1},
		["Impact"]={{[DMG_SLASH]=.6,[DMG_CLUB]=.7,[DMG_CRUSH]=.6,[DMG_BLAST]=.85},.05},
		--suits
		["Hazardous Material"]={[DMG_BURN]=.9,[DMG_DIRECT]=.9,[DMG_SLASH]=.75,[DMG_DROWN]=.001,[DMG_PARALYZE]=.001,[DMG_NERVEGAS]=.001,[DMG_POISON]=.001,[DMG_ACID]=.001,[DMG_RADIATION]=.01},
		["Fire-Faraday"]={[DMG_BURN]=.01,[DMG_DIRECT]=.01,[DMG_SLOWBURN]=.01,[DMG_SHOCK]=.1,[DMG_ENERGYBEAM]=.1,[DMG_PLASMA]=.2,[DMG_DISSOLVE]=.3},
		["EOD"]={[DMG_BURN]=.8,[DMG_ACID]=.8,[DMG_SLASH]=.2,[DMG_CLUB]=.2,[DMG_CRUSH]=.2,[DMG_BULLET]=.4,[DMG_BUCKSHOT]=.3,[DMG_BLAST]=.3,[DMG_AIRBOAT]=.5,[DMG_VEHICLE]=.2,[DMG_POISON]=.75}
	}
	local ArmorEntities={
		--vests
		["Ballistic Nylon"]="ent_jack_bodyarmor_vest_bn",
		["Stab Vest"]="ent_jack_bodyarmor_vest_sv",
		["Soft Kevlar"]="ent_jack_bodyarmor_vest_sk",
		["Kevlar SAPI"]="ent_jack_bodyarmor_vest_ks",
		["Impact Vest"]="ent_jack_bodyarmor_vest_im",
		--helmets
		["Steel"]="ent_jack_bodyarmor_helm_st",
		["Kevlar Resin"]="ent_jack_bodyarmor_helm_kr",
		["Polyethylene"]="ent_jack_bodyarmor_helm_pe",
		["Riot"]="ent_jack_bodyarmor_helm_ri",
		["Impact"]="ent_jack_bodyarmor_helm_im",
		--suits
		["Hazardous Material"]="ent_jack_suit_hazmat",
		["Fire-Faraday"]="ent_jack_suit_fire",
		["EOD"]="ent_jack_suit_eod"
	}
	function JackaSetPlayerModel(ply,mod)
		ply:SetModel(mod)
		local simplemodel=player_manager.TranslateToPlayerModelName(mod)
		local info=player_manager.TranslatePlayerHands(simplemodel)
		local Hans=ply:GetHands()
		if(IsValid(Hans))then Hans:SetModel(info.model) end
	end
	function JackaGenericUseEffect(ply)
		if(ply:IsPlayer())then
			local Wep=ply:GetActiveWeapon()
			if(IsValid(Wep))then Wep:SendWeaponAnim(ACT_VM_DRAW) end
			ply:ViewPunch(Angle(1,0,0))
			ply:SetAnimation(PLAYER_ATTACK1)
		end
	end
	function JackaBodyArmorUpdate(ply, slot, item, colr)
		if not(ply.JackyArmor) then ply.JackyArmor={} end -- If player does not have an armour table, create one
		if item then -- Check if Item is not nil
			ply.JackyArmor[slot] = {}
			ply.JackyArmor[slot].Type= item
			ply.JackyArmor[slot].Colr = colr
			if (slot == "Suit") then
				ply.JackyOriginalModel = ply:GetModel()
				JackaSetPlayerModel(ply,ArmorAppearances[item])
				ply.JackyOriginalColor = ply:GetPlayerColor()   
				ply:SetPlayerColor(Vector(colr.r/255, colr.g/255, colr.b/255)) -- Sets the player colour from the item colour
			end
		else -- Clearing the Armour information
			ply.JackyArmor[slot]=nil
            item = "nil"
            colr = Color(0,0,0)
			if ((slot=="Suit") and (ply.JackyOriginalModel) and (ply.JackyOriginalColor)) then
				JackaSetPlayerModel(ply,ply.JackyOriginalModel)
				ply:SetPlayerColor(ply.JackyOriginalColor)
			end
		end
		
		if(ply.JackyArmor.OrigRun)then ply:SetRunSpeed(ply.JackyArmor.OrigRun) end
		ply.JackyArmor.OrigRun=nil
		
		if(ply.JackyArmor.Vest)then
			ply.JackyArmor.OrigRun=ply:GetRunSpeed()
			local NewSpd=ArmorDisadvantages[ply.JackyArmor.Vest.Type]*ply.JackyArmor.OrigRun
			ply:SetRunSpeed(NewSpd)
		elseif(ply.JackyArmor.Suit)then
			ply.JackyArmor.OrigRun=ply:GetRunSpeed()
			local NewSpd=ArmorDisadvantages[ply.JackyArmor.Suit.Type]*ply.JackyArmor.OrigRun
			ply:SetRunSpeed(NewSpd)
		end
        
        umsg.Start("JackaBodyArmorUpdateClient")
        umsg.Entity(ply)
        umsg.String(slot)
        umsg.String(item)
        umsg.Short(colr.r)
        umsg.Short(colr.g)
        umsg.Short(colr.b)
        umsg.End()
        
	end
	function JackaSentryControl(ply,term,sent)
		ply.JackaSentryControl=sent
		ply.JackaSentryTerminal=term
		term.Controller=ply
		term.Controlled=sent
		sent.ControllingPly=ply
		sent.ControllingTerminal=term
		ply:SetFOV(90,0)
		--ply:SetDSP(58,false)
		ply.OriginalJumpPower=ply:GetJumpPower()
		ply:SetJumpPower(0)
		sent:SetDTBool(2,false)
		ply:Give("wep_jack_sentrycontrols")
		ply:SelectWeapon("wep_jack_sentrycontrols")
		ply:SetViewEntity(sent)
		umsg.Start("JackaSentryControl")
		umsg.Entity(ply)
		umsg.Entity(term)
		umsg.Entity(sent)
		umsg.End()
	end
	function JackaSentryControlWipe(ply,term,sent)
		ply.JackaSentryControl=nil
		ply.JackaSentryTerminal=nil
		term.Controller=nil
		term.Controlled=nil
		sent.ControllingPly=nil
		sent.ControllingTerminal=nil
		ply:SetFOV(0,0)
		timer.Simple(.1,function() if(IsValid(ply))then ply:SetJumpPower(ply.OriginalJumpPower) end end)
		sent:SetDTInt(3,0)
		ply:StripWeapon("wep_jack_sentrycontrols")
		ply:SetViewEntity(ply)
		if(term)then term:EmitSound("snd_jack_dronebeep.wav",70,90) end
		umsg.Start("JackaSentryControlWipe")
		umsg.Entity(ply)
		umsg.Entity(term)
		umsg.Entity(sent)
		umsg.End()
	end
	local function StepSound(ply,pos,foot,snd,vol,filter)
		if((ply.JackyArmor)and(ply.JackyArmor.Vest))then
			if((ply.JackyArmor.Vest.Type=="Kevlar SAPI")or(ply.JackyArmor.Vest.Type=="Soft Kevlar")or(ply.JackyArmor.Vest.Type=="Ballistic Nylon"))then
				ply:EmitSound("snd_jack_gear"..tostring(math.random(1,6))..".wav",55,math.random(90,110))
			end
		elseif((ply.JackyArmor)and(ply.JackyArmor.Suit)and(ply.JackyArmor.Suit.Type=="EOD"))then
			local Snd="snd_jack_gear"..tostring(math.random(1,6))..".wav"
			local Ptch=math.random(80,90)
			ply:EmitSound(Snd,75,Ptch)
			ply:EmitSound(Snd,55,Ptch)
		end
	end
	hook.Add("PlayerFootstep","JackyArmorFootstep",StepSound)
	local function RemoveArmor(ply, txt)
		local loweredText = string.lower(txt) -- Convert to lowercase
        if string.sub(loweredText, 1, 1) == "*" and string.sub(loweredText, string.len(loweredText), -1) == "*" then -- Begins and ends with asterix
            local strippedText = string.sub(loweredText, 2, string.len(loweredText)-1) -- Remove leading and ending asterix
            
            local words = {}
            for substring in strippedText:gmatch("%S+") do -- Split string into array
               table.insert(words, substring)
            end
            if words[1] ~= "drop" and words[1] ~= "drops" then return end -- Only procede if the "drop" or "drops" command is used
            
            local armourTypes = {
                ["vest"] = ply.JackyArmor.Vest,
                ["helmet"] = ply.JackyArmor.Helmet,
                ["suit"] = ply.JackyArmor.Suit
            }

            local armourWord = words[2]
 
            if armourTypes[armourWord] then -- Check if second word is valid armour type
                local armour = armourTypes[armourWord]
                local Type= armour.Type
                local Colr= armour.Colr
                        local capitalised = armourWord:sub(1,1):upper() .. armourWord:sub(2) -- Capitalise the first letter, because JackaBodyArmorUpdate requires it
                JackaBodyArmorUpdate(ply,capitalised,nil,nil)
                local New = ents.Create(ArmorEntities[Type])
                New:SetPos(ply:GetShootPos()+ply:GetAimVector()*30-ply:GetUp()*20)
                New:Spawn()
                New:Activate()
                New:SetColor(Colr)
                
                if armourWord ~= "helmet" then -- Hardcoded as an exception because it is a one-off
                    ply:EmitSound("snd_jack_clothunequip.wav",70,100)
                else
                    ply:EmitSound("Flesh.ImpactSoft")
                end
                
                ply:PrintMessage(HUD_PRINTCENTER, "Removed " .. capitalised)
				        JackaGenericUseEffect(ply)
            elseif words[2] == "iff" then
                
                local iffTag = ply:GetNetworkedInt("JackyIFFTag")
                if iffTag and (iffTag !=0) then
                    ply:SetNetworkedInt("JackyIFFTag", 0)
                    local New = ents.Create("ent_jack_ifftag")
                    
                    New:SetPos(ply:GetShootPos()+ply:GetAimVector()*30-ply:GetUp()*20)
                    New:Spawn()
                    New:Activate()
                    
                    ply:EmitSound("snd_jack_tinyequip.wav",75,100)
                    JackaGenericUseEffect(ply)
                    ply:PrintMessage(HUD_PRINTCENTER,"Removed IFF Tag")
                else
                    ply:ChatPrint("You are not wearing an IFF")
                end
            else
                ply:PrintMessage(HUD_PRINTCENTER, "You are not wearing this armour type...")
            end
        end

	end
	hook.Add("PlayerSay","JackyArmorChat",RemoveArmor)
	local function JackaSpawnHook(ply)
		ply.JModFriends=ply.JModFriends or {}
		JackaBodyArmorUpdate(ply,"Vest",nil,nil)
		JackaBodyArmorUpdate(ply,"Helmet",nil,nil)
		JackaBodyArmorUpdate(ply,"Suit",nil,nil)
		if((ply.JackaSleepPoint)and(IsValid(ply.JackaSleepPoint)))then
			if(ply.JackaSleepPoint.NextSpawnTime<CurTime())then
				ply.JackaSleepPoint.NextSpawnTime=CurTime()+60
				ply:SetPos(ply.JackaSleepPoint:GetPos())
				ply:PrintMessage(HUD_PRINTCENTER,"You must wait 60 seconds before spawning here again")
				local effectdata=EffectData()
				effectdata:SetEntity(ply)
				util.Effect("propspawn",effectdata)
			end
		else
			for key,ent in pairs(ents.FindInSphere(ply:GetPos(),500))do
				if(ent.JackyArmoredPanel)then
					print(tostring(ent).." was found too close to a player's spawn point. It was removed in order to prevent minging.")
					SafeRemoveEntity(ent)
				end
			end
		end
	end
	hook.Add("PlayerSpawn","JackaSpawnHook",JackaSpawnHook)
	local function JackyDamageHandling(victim,hitgroup,dmginfo)
		if(victim.JackyArmor)then
			local NewScale=1
			if(victim.JackyArmor.Suit)then
				local Damages=ArmorAdvantages[victim.JackyArmor.Suit.Type]
				for damtype,mul in pairs(Damages)do
					if(dmginfo:IsDamageType(damtype))then
						NewScale=NewScale*mul
					end
				end
				if((victim.JackyArmor.Suit.Type=="Fire-Faraday")or(victim.JackyArmor.Suit.Type=="EOD"))then
					if(victim:IsOnFire())then
						if(math.random(1,5)==2)then victim:Extinguish() end
					end
				end
				if(victim.JackyArmor.Suit.Type=="EOD")then
					if((dmginfo:IsDamageType(DMG_BULLET))or(dmginfo:IsDamageType(DMG_BUCKSHOT)))then
						if(hitgroup==HITGROUP_HEAD)then
							if(math.Rand(0,1)<.8)then
								victim:EmitSound("snd_jack_ricochet_"..tostring(math.random(1,2))..".wav",70,100)
								victim:ViewPunch(Angle(math.random(-20,20),math.random(-20,20),0))
								NewScale=NewScale*.0001
							else
								victim:EmitSound("Drywall.ImpactHard")
							end
						end
					end
				end
			else
				if((dmginfo:IsDamageType(DMG_BULLET))or(dmginfo:IsDamageType(DMG_BUCKSHOT)))then
					if(victim.JackyArmor.Vest)then
						if((hitgroup==HITGROUP_CHEST)or(hitgroup==HITGROUP_STOMACH))then
							local Damages=ArmorAdvantages[victim.JackyArmor.Vest.Type]
							for damtype,mul in pairs(Damages)do
								if(dmginfo:IsDamageType(damtype))then
									NewScale=NewScale*mul
								end
							end
						end
					end
					if(victim.JackyArmor.Helmet)then
						if(hitgroup==HITGROUP_HEAD)then
							if(math.Rand(0,1)<ArmorAdvantages[victim.JackyArmor.Helmet.Type][2])then
								victim:EmitSound("snd_jack_ricochet_"..tostring(math.random(1,2))..".wav",70,100)
								victim:ViewPunch(Angle(math.random(-20,20),math.random(-20,20),0))
								NewScale=NewScale*.0001
							else
								if(victim.JackyArmor.Helmet.Type=="Steel")then
									victim:EmitSound("SolidMetal.BulletImpact")
								else
									victim:EmitSound("Drywall.ImpactHard")
								end
							end
						end
					end
				else
					if(victim.JackyArmor.Vest)then
						local Damages=ArmorAdvantages[victim.JackyArmor.Vest.Type]
						for damtype,mul in pairs(Damages)do
							if(dmginfo:IsDamageType(damtype))then
								NewScale=NewScale*mul
							end
						end
						if(victim.JackyArmor.Vest.Type=="Stab Vest")then
							local Class=dmginfo:GetAttacker():GetClass()
							if((Class=="npc_headcrab_black")or(Class=="npc_headcrab_poison"))then
								if(math.Rand(0,1)>.2)then
									NewScale=NewScale*.001
								end
							end
						end
					end
					if(victim.JackyArmor.Helmet)then
						local Damages=ArmorAdvantages[victim.JackyArmor.Helmet.Type][1]
						for damtype,mul in pairs(Damages)do
							if(dmginfo:IsDamageType(damtype))then
								NewScale=NewScale*mul
							end
						end
					end
				end
			end
			dmginfo:ScaleDamage(NewScale)
		end
	end
	local function JackaScaleDamageHook(victim,hitgroup,dmginfo)
		JackyDamageHandling(victim,hitgroup,dmginfo)
	end
	hook.Add("ScalePlayerDamage","JackaScaleDamageHook",JackaScaleDamageHook)
	local function JackaDamageHook(victim,dmginfo)
		if(victim:IsPlayer())then
			JackyDamageHandling(victim,HITGROUP_GENERIC,dmginfo)
		end
	end
	hook.Add("EntityTakeDamage","JackaDamageHook",JackaDamageHook)
	local function ModifyMove(ply,mvd,cmd)
		--[[ -- Customizable Weaponry 2 conflicts with this because its author is a retard
		if(ply.JackyArmor)then
			if(ply.JackyArmor.Vest)then
				local NewSpd=ArmorDisadvantages[ply.JackyArmor.Vest.Type]*ply:GetRunSpeed()
				mvd:SetMaxSpeed(NewSpd)
				mvd:SetMaxClientSpeed(NewSpd)
			elseif(ply.JackyArmor.Suit)then
				local NewSpd=ArmorDisadvantages[ply.JackyArmor.Suit.Type]*ply:GetRunSpeed()
				mvd:SetMaxSpeed(NewSpd)
				mvd:SetMaxClientSpeed(NewSpd)
			end
		end
		--]]
		if(ply.JackaSentryControl)then
			mvd:SetMaxSpeed(1)
			mvd:SetMaxClientSpeed(1)
		end
	end
	hook.Add("SetupMove","JackaModifyMove",ModifyMove)
	local function Disconn(ply)
		if(ply.JackaSentryControl)then
			JackaSentryControlWipe(ply,ply.JackaSentryTerminal,ply.JackaSentryControl)
		end
	end
	hook.Add("PlayerDisconnected","JackaPlyDisconn",Disconn)
	local function CmdDet(...)
		local args={...}
		local ply=args[1]
		ply:ConCommand("jacky_fougasse_det")
		ply:ConCommand("jacky_claymore_det")
	end
	concommand.Add("jacky_remote_det",CmdDet)
	local function JackaDeathHook(ply)
		if(ply.JackaSentryControl)then
			JackaSentryControlWipe(ply,ply.JackaSentryTerminal,ply.JackaSentryControl)
		end
		if((ply.JackyArmor)and(ply.JackyArmor.Suit)and(ply.JackyArmor.Suit.Type=="EOD"))then
			-- the MW2 port doesn't have the right traits to be a ragdoll
			ply:SetModel(ply.JackyOriginalModel)
			ply:SetPlayerColor(ply.JackyOriginalColor)
		end

        local iffCon = GetConVar("jids_iff_permanence"):GetInt() -- 0 is on death, 1=TC, 2=Death+TC, 3=Never
        if (iffCon == 0 or iffCon == 2) then 
            ply:SetNetworkedInt("JackyIFFTag", 0)
        end
        
	end
	hook.Add("DoPlayerDeath","JackaDeathHook",JackaDeathHook)
	local function JackaControls(ply,key)
		if(ply.JackaSentryControl)then
			ply.JackaSentryControl:TakeInputs(key)
		end
	end
	hook.Add("KeyPress","JackaSentryControls",JackaControls)
	local function JackaControlsN(ply,key)
		if(ply.JackaSentryControl)then
			ply.JackaSentryControl:TakeNegativeInputs(key)
		end
	end
	hook.Add("KeyRelease","JackaSentryControlsN",JackaControlsN)
    local function JIDS_OnTeamChange(ply)
        local iffCon = GetConVar("jids_iff_permanence"):GetInt() -- 0 is on death, 1=TC, 2=Death+TC, 3=Never
        if (iffCon == 1 or iffCon == 2) then 
            ply:SetNetworkedInt("JackyIFFTag", 0)
        end
    end
    hook.Add("OnPlayerChangedTeam","JIDS_IFFTagRemoval", JIDS_OnTeamChange)
    
    --Convars
    CreateConVar("jids_iff_permanence", "0", FCVAR_LUA_SERVER, "Should IFF's drop on death or team change. 0=Death, 1=TC, 2=Death+TC, 3=Never (user must drop)")

	-------------
	hook.Add("GetPreferredCarryAngles","JMOD_PREFCARRYANGS",function(ent)
		if(ent.JModPreferredCarryAngles)then return ent.JModPreferredCarryAngles end
	end)
	--- NO U ---
	concommand.Add("jmod_friends",function(ply)
		net.Start("JMod_Friends")
		net.WriteTable(ply.JModFriends or {})
		net.Send(ply)
	end)
	net.Receive("JMod_Friends",function(length,ply)
		local List,Good=net.ReadTable(),true
		for k,v in pairs(List)do
			if not((IsValid(v))and(v:IsPlayer()))then Good=false end
		end
		if(Good)then
			ply.JModFriends=List
			ply:PrintMessage(HUD_PRINTCENTER,"JMod EZ friends list updated")
		else
			ply.JModFriends={}
		end
	end)
end

