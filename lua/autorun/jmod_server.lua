include("jmod_shared.lua")
if(SERVER)then
	util.AddNetworkString("JMod_Friends") -- ^:3
	util.AddNetworkString("JMod_MineColor")
	util.AddNetworkString("JMod_EZbuildKit")
	util.AddNetworkString("JMod_EZworkbench")
	util.AddNetworkString("JMod_Hint")
	util.AddNetworkString("JMod_EZtimeBomb")
	util.AddNetworkString("JMod_UniCrate")
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
		if not(ply.JackyArmor)then ply.JackyArmor={} end -- If player does not have an armour table, create one
		if item then -- Check if Item is not nil
			ply.JackyArmor[slot]={}
			ply.JackyArmor[slot].Type= item
			ply.JackyArmor[slot].Colr=colr
			if(slot=="Suit")then
				ply.JackyOriginalModel=ply:GetModel()
				JackaSetPlayerModel(ply,ArmorAppearances[item])
				ply.JackyOriginalColor=ply:GetPlayerColor()   
				ply:SetPlayerColor(Vector(colr.r/255, colr.g/255, colr.b/255)) -- Sets the player colour from the item colour
			end
		else -- Clearing the Armour information
			ply.JackyArmor[slot]=nil
			item="nil"
			colr=Color(0,0,0)
			if((slot=="Suit") and (ply.JackyOriginalModel) and (ply.JackyOriginalColor))then
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
		local loweredText=string.lower(txt) -- Convert to lowercase
		if string.sub(loweredText, 1, 1)=="*" and string.sub(loweredText, string.len(loweredText), -1)=="*" then -- Begins and ends with asterix
			local strippedText=string.sub(loweredText, 2, string.len(loweredText)-1) -- Remove leading and ending asterix
			
			local words={}
			for substring in strippedText:gmatch("%S+") do -- Split string into array
			   table.insert(words, substring)
			end
			if words[1] ~= "drop" and words[1] ~= "drops" then return end -- Only procede if the "drop" or "drops" command is used
			
			local armourTypes={
				["vest"]=ply.JackyArmor.Vest,
				["helmet"]=ply.JackyArmor.Helmet,
				["suit"]=ply.JackyArmor.Suit
			}

			local armourWord=words[2]
 
			if armourTypes[armourWord] then -- Check if second word is valid armour type
				local armour=armourTypes[armourWord]
				local Type= armour.Type
				local Colr= armour.Colr
						local capitalised=armourWord:sub(1,1):upper() .. armourWord:sub(2) -- Capitalise the first letter, because JackaBodyArmorUpdate requires it
				JackaBodyArmorUpdate(ply,capitalised,nil,nil)
				local New=ents.Create(ArmorEntities[Type])
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
			elseif words[2]=="iff" then
				
				local iffTag=ply:GetNetworkedInt("JackyIFFTag")
				if iffTag and (iffTag !=0)then
					ply:SetNetworkedInt("JackyIFFTag", 0)
					local New=ents.Create("ent_jack_ifftag")
					
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

		local iffCon=GetConVar("jids_iff_permanence"):GetInt() -- 0 is on death, 1=TC, 2=Death+TC, 3=Never
		if(iffCon==0 or iffCon==2)then 
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
		local iffCon=GetConVar("jids_iff_permanence"):GetInt() -- 0 is on death, 1=TC, 2=Death+TC, 3=Never
		if(iffCon==1 or iffCon==2)then 
			ply:SetNetworkedInt("JackyIFFTag", 0)
		end
	end
	hook.Add("OnPlayerChangedTeam","JIDS_IFFTagRemoval", JIDS_OnTeamChange)
	
	--Convars
	CreateConVar("jids_iff_permanence", "0", FCVAR_LUA_SERVER, "Should IFF's drop on death or team change. 0=Death, 1=TC, 2=Death+TC, 3=Never (user must drop)")

	-------------
	--- OLD OPSQUADS CODE ---
		--[[
	local function ASS(p,k)
		JPrint(p:GetEyeTrace().Entity:GetModel())
	end
	hook.Add("KeyPress","TITS",ASS)
	--]]
	JackieNPCSpawningTable={
		Enhanced={},
		Modified={}
	}
	function JackyAlterAllegiances(npc,friendly)
		npc:AddEntityRelationship(npc,D_NU,100)
		local Fr,En,Sq="D_LI","D_HT","JIGlobalComms"
		if not(friendly)then Fr="D_HT";En="D_LI";Sq="JIGlobalEnemyComms" end
		npc:SetKeyValue("SquadName",Sq)
		npc:AddRelationship("player "..Fr.." 70")
		npc:AddRelationship("npc_citizen "..Fr.." 70")
		npc:AddRelationship("npc_combine_s "..En.." 60")
		npc:AddRelationship("npc_metropolice "..En.." 60")
		npc:AddRelationship("npc_manhack "..En.." 60")
		npc:AddRelationship("npc_rollermine "..En.." 60")
		npc:AddRelationship("npc_strider "..En.." 60")
		npc:AddRelationship("npc_helicopter "..En.." 60")
		npc:AddRelationship("npc_combinedropship "..En.." 60")
		npc:AddRelationship("npc_combinegunship "..En.." 60")
		npc:AddRelationship("npc_hunter "..En.." 60")
		npc:AddRelationship("npc_synthscanner "..En.." 60")
		npc:AddRelationship("npc_cscanner "..En.." 60")
		npc:AddRelationship("npc_turret_floor "..En.." 60")
		npc:AddRelationship("npc_turret_ceiling "..En.." 60")
		Fr,En=D_LI,D_HT
		if not(friendly)then Fr=D_HT;En=D_LI end
		npc.JIFaction=Sq
		for k,v in pairs(ents.FindByClass("npc_*"))do
			if(v.JIFaction)then
				if(v.JIFaction==Sq)then
					npc:AddEntityRelationship(v,D_LI,70)
					v:AddEntityRelationship(npc,D_LI,70)
				else
					npc:AddEntityRelationship(v,D_HT,70)
					v:AddEntityRelationship(npc,D_HT,70)
				end
			end
		end
	end
	function JackyOpSquadSpawnEvent(ent)
		local Delay=.4
		if(string.find(ent:GetClass(),"antlion"))then Delay=.8 end -- antlions burrow
		ent:DrawShadow(false)
		local effectdata=EffectData()
		effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		timer.Simple(Delay,function()
			if(IsValid(ent))then
				ent:DrawShadow(true)
			end
		end)
		ent.JackyOpSquadNPC=true
		timer.Simple(.5,function()
			if(IsValid(ent))then
				umsg.Start("JackySetClientBoolean")
					umsg.Entity(ent)
					umsg.String("JackyOpSquadNPC")
					umsg.Bool(true)
				umsg.End()
			end
		end)
	end
	function JPrint(msg)
		player.GetAll()[1]:PrintMessage(HUD_PRINTCENTER,tostring(msg))
		player.GetAll()[1]:PrintMessage(HUD_PRINTTALK,"["..tostring(math.Round(CurTime(),1)).."] "..tostring(msg))
	end
	function JackyPlayNPCAnim(npc,name,stationary,time)
		npc:RestartGesture(npc:GetSequenceInfo(npc:LookupSequence(name)).activity)
		if(stationary)then
			npc:StopMoving()
			timer.Create("JackyAnim"..npc:EntIndex(),.1,math.Round(time*10),function()
				if(IsValid(npc))then
					npc:StopMoving()
				end
			end)
		end
		--[[
		JPrint(npc:GetSequenceInfo(npc:LookupSequence(name)).activityname)
		table.foreach(npc:GetSequenceList(),print)
		--]]
	end
	JackyOpSquadsMustPreCacheHumans=true
	local AllCreatureTable={} -- cache this table. Why? *crysis nanosuit voice*: MAXIMUM EFFICIENCY.
	local NoCannonTable={"npc_helicopter","npc_combinedropship","npc_combinegunship"}
	local WarningTable={"vo/npc/male01/getdown02.wav","vo/npc/male01/headsup01.wav","vo/npc/male01/headsup02.wav","vo/npc/male01/watchout.wav"}
	local function VictimShotInFace(victim,dmginfo)
		local AttackDir=dmginfo:GetDamageForce():GetNormalized()
		local FaceDir=victim:GetAimVector()
		local DotProduct=AttackDir:DotProduct(FaceDir)
		local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
		if(ApproachAngle>=140)then
			return true
		else
			return false
		end
	end
	local function ThrowBallistically(ent,targetPos)
		local Vec=targetPos-ent:GetPos()
		local Dist=Vec:Length()
		ent:SetVelocity(1500*(Vec:GetNormalized()+Vector(0,0,Dist^1.5/500000)):GetNormalized()+VectorRand()*math.Rand(0,200))
		ent:SetAngles(ent:GetVelocity():Angle())
	end
	local function MoveCloser(shooter,enemy)
		local EnemyPos=enemy:GetPos()
		local SelfPos=shooter:GetPos()
		local Vec=EnemyPos-SelfPos
		if(Vec:Length()>2000)then
			shooter:SetLastPosition(SelfPos+Vec:GetNormalized()*495+Vector(0,0,100))
			shooter:SetSchedule(SCHED_FORCED_GO_RUN)
		end
	end
	local function ClearLoSBetween(entOne,entTwo)
		local PosOne=entOne:LocalToWorld(entOne:OBBCenter())
		local PosTwo=entTwo:LocalToWorld(entTwo:OBBCenter())
		local TrDat={}
		TrDat.start=PosOne
		TrDat.endpos=PosTwo
		TrDat.filter={entOne,entTwo}
		local Tr=util.TraceLine(TrDat)
		return not(Tr.Hit)
	end
	local function FarNotice(npc,target)
		local TargPos=target:GetPos()
		npc:UpdateEnemyMemory(target,TargPos)
		npc:EmitSound("snd_jack_mgs4alert.wav",70,100)
		local Ang=(target:GetPos()-npc:GetPos())
		Ang=Vector(Ang.x,Ang.y,0)
		npc:SetAngles(Ang:Angle())
		npc:SetEnemy(target)
		local Class=npc:GetClass()
		if(Class=="npc_combine_s")then
			JackyPlayNPCAnim(npc,"signal_advance",false,.75)
		end
	end
	local function CloseNotice(npc,target)
		if not(target:Health()>0)then return end
		local TargPos=target:GetPos()
		npc:UpdateEnemyMemory(target,TargPos)
		npc:EmitSound("snd_jack_mgs4alert.wav",70,100)
		npc:SetEnemy(target)
		local Class=npc:GetClass()
		if(Class=="npc_combine_s")then
			JackyPlayNPCAnim(npc,"signal_takecover",false,.75)
		end
	end
	local function RayClear(posOne,posTwo,ent)
		local TrDat={
			start=posOne,
			endpos=posTwo,
			filter={ent}
		}
		local Tr=util.TraceLine(TrDat)
		return !Tr.Hit
	end
	local function WithinSoManyUnitsOfEachother(entOne,entTwo,dist)
		local PosOne=entOne:GetPos()
		local PosTwo=entTwo:GetPos()
		local RealDist=(PosOne-PosTwo):Length()
		return RealDist<=dist
	end
	local function Facing(looker,lookee)
		local TrueVec=(lookee:GetPos()-looker:GetPos()):GetNormalized()
		local LookVec=looker:GetAimVector()
		local DotProduct=LookVec:DotProduct(TrueVec)
		local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
		if(ApproachAngle<=60)then
			return true
		else
			return false
		end
	end
	local function HeliRotorStrike(heli,thing)
		local Kaschling=DamageInfo()
		Kaschling:SetDamage(75)
		Kaschling:SetDamageType(DMG_SLASH)
		Kaschling:SetDamagePosition(thing:GetPos())
		Kaschling:SetDamageForce(VectorRand()*999999999*3) --9 nines
		Kaschling:SetAttacker(heli)
		Kaschling:SetInflictor(heli)
		thing:TakeDamageInfo(Kaschling)
		thing:EmitSound("ambient/machines/slicer1.wav")
		heli:EmitSound("ambient/machines/slicer2.wav")
		heli:SetVelocity(VectorRand()*500)
	end
	--[[----------------------------------------------------------
		This is the general damage scaling function
	-----------------------------------------------------------]]
	local function JackyOpSquadDamageHook(victim,dmginfo)
		local attacker=dmginfo:GetAttacker()
		local inflictor=dmginfo:GetInflictor()
		if not(IsValid(attacker))then return end
		if not(IsValid(victim))then return end
		if not((attacker.JackyOpSquadNPC)or(victim.JackyOpSquadNPC)or(victim.OpSquadCustomDamageTaker))then return end
		local VictimPos=victim:GetPos()
		local AttackerPos=attacker:GetPos()
		local DamType=dmginfo:GetDamageType()
		local DmgType=dmginfo:GetDamageType()
		local Mult=1
		if(attacker.JackyFirePowerMult)then
			Mult=Mult*attacker.JackyFirePowerMult
		end
		if(victim.JackyProtectionMult)then
			Mult=Mult/victim.JackyProtectionMult
		end
		if((attacker.JackyDamageGroup)and(victim.JackyDamageGroup))then
			if((attacker.JackyDamageGroup==victim.JackyDamageGroup)and not(attacker==victim))then
				Mult=Mult*.1
			end
		end
		if(victim.OpSquadAware)then -- if you get shot
			local Enemy=victim:GetEnemy()
			if not(IsValid(Enemy))then -- and you can't find the shooter
				if not((attacker:IsWorld())or(attacker:GetClass()=="trigger_hurt"))then
					local Pos=victim:GetPos()+Vector(math.random(-1000,1000),math.random(-1000,1000),0)
					victim:SetLastPosition(Pos)
					victim:StopMoving() -- then drop what you're doing
					victim:SetSchedule(SCHED_FORCED_GO_RUN) -- and fucking run
				end
			else
				if(math.random(1,4)==4)then
					victim:SetSchedule(SCHED_RUN_RANDOM)
				end
			end
		end
		if(victim.OpSquadVengeful)then
			local TheD=victim:Disposition(attacker)
			if(((TheD==D_HT)or(TheD==D_FR))and not(string.find(attacker:GetClass(),"turret")))then
				victim:AddEntityRelationship(attacker,D_HT,95)
			end
		end
		if(victim.OpSquadAutoHealer)then
			victim.OpSquadLastAlertTime=CurTime()
		end
		if((attacker.OpSquadHardHitter)and(DamType==DMG_CLUB))then
			Mult=Mult*2
			dmginfo:SetDamageForce(attacker:GetAimVector()*1e5)
		end
		if((attacker.OpSquadUltraMegaSuperPowerDeathZombie)and((DamType==DMG_CLUB)or(DamType==DMG_SLASH)))then
			Mult=Mult*10 -- HULK SMASH
			dmginfo:SetDamageForce(dmginfo:GetDamageForce():GetNormalized()*1e5*dmginfo:GetDamage())
		end
		if(victim.OpSquadStabResistantClothing)then
			local Class=attacker:GetClass()
			if((Class=="npc_headcrab_poison")or(Class=="npc_headcrab_black"))then
				if(math.Rand(0,1)<.8)then
					Mult=Mult*.01
				end
			end
		end
		if((victim.OpSquadCustomDamageTaker)and(dmginfo:IsDamageType(DMG_BLAST)))then
			if(math.random(1,5)==2)then
				victim.OpSquadCustomDamageTaker=false
				for k,ent in pairs(ents.FindInSphere(victim:GetPos(),500))do
					if(ent:GetClass()=="npc_combinedropship")then SafeRemoveEntityDelayed(ent,.05) end
				end
				SafeRemoveEntityDelayed(victim,.05)
				for i=0,20 do
					JMod_Sploom(attacker,victim:GetPos()+VectorRand()*math.Rand(0,500),100)
				end
			end
		end
		if(victim.OpSquadFlameRetardantSuit)then
			if(math.random(1,6)==3)then
				if(victim:IsOnFire())then
					victim:Extinguish()
				end
			end
		end
		if(victim.OpSquadFullBodySuit)then
			if((DamType==DMG_ACID)or(DamType==DMG_POISON)or(DamType==DMG_NERVEGAS))then
				local Class=attacker:GetClass()
				if not((Class=="npc_headcrab_black")or(Class=="npc_headcrab_poison"))then -- these can circumvent the suit by piercing it
					Mult=Mult*.01
				end
			end
		end
		if(victim.OpSquadNoHeadcrab)then
			if(victim:Health()<=1)then
				local Pos=victim:GetPos()+Vector(0,0,30)
				timer.Simple(.01,function()
					for key,crab in pairs(ents.FindInSphere(Pos,90))do
						local Class=crab:GetClass()
						if((Class=="npc_headcrab")or(Class=="npc_headcrab_fast"))then
							SafeRemoveEntity(crab)
						elseif(Class=="prop_ragdoll")then
							local Moddel=crab:GetModel()
							if((Moddel=="models/headcrabclassic.mdl")or(Moddel=="models/headcrab.mdl"))then
								SafeRemoveEntity(crab)
							end
						elseif((Class=="npc_zombie")or(Class=="npc_fastzombie"))then
							crab:SetBodygroup(1,0)
						end
					end
				end)
				umsg.Start("JackyClientHeadcrabRemoval")
					umsg.Vector(Pos)
				umsg.End()
			end
		elseif(victim.OpSquadStalker)then
			if(victim.OpSquadStalkerState=="Stalking")then
				victim.OpSquadStalkerState="Normal"
				victim.OpSquadStalkerCamoAmount=victim.OpSquadStalkerCamoAmount-10
				local Zap=EffectData()
				Zap:SetEntity(victim)
				util.Effect("entity_remove",Zap,true,true)
			end
		end
		dmginfo:ScaleDamage(Mult)
	end
	hook.Add("EntityTakeDamage","JackyOpSquadDamageHook",JackyOpSquadDamageHook)
	local function JackyScaleNPCDamage(victim,hitgroup,dmginfo)
		if not(victim.JackyOpSquadNPC)then return end
		local Mult=1
		if(hitgroup==HITGROUP_HEAD)then
			if(victim.OpSquadGoodHelmet)then
				local dtype=dmginfo:GetDamageType()
				if((dtype==DMG_BULLET)or(dtype==DMG_BUCKSHOT)or(dtype==4098)or(dtype==8194)or(dtype==536875008)or(dtype==536879104)or(dtype==134217792)or(dtype==536875010))then
					local Pos=victim:GetPos()+Vector(0,0,60)+victim:GetAimVector()*10
					local Dir=VectorRand()
					Mult=Mult*.2
					victim:EmitSound("snd_jack_helmetricochet_"..math.random(1,2)..".wav",75,100)
					local Bewlat={}
					Bewlat.Num=2
					Bewlat.Src=Pos
					Bewlat.Dir=Dir
					Bewlat.Spread=Vector(0,0,0)
					Bewlat.Tracer=1
					Bewlat.TracerName="Tracer"
					Bewlat.Force=dmginfo:GetDamageForce()/2
					Bewlat.Damage=dmginfo:GetDamage()/2
					Bewlat.Attacker=dmginfo:GetAttacker()
					Bewlat.Inflictor=dmginfo:GetInflictor()
					victim:FireBullets(Bewlat)
					local effectdata=EffectData()
					effectdata:SetOrigin(Pos)
					effectdata:SetNormal(Dir)
					effectdata:SetMagnitude(2) --amount and shoot hardness
					effectdata:SetScale(.5) --length of strands
					effectdata:SetRadius(1) --thickness of strands
					util.Effect("Sparks",effectdata,true,true)
					victim:SetSequence(ACT_FLINCH_HEAD)
				end
			elseif(victim.OpSquadHelmet)then
				local dtype=dmginfo:GetDamageType()
				if((dtype==DMG_BULLET)or(dtype==DMG_BUCKSHOT)or(dtype==4098)or(dtype==8194)or(dtype==536875008)or(dtype==536879104)or(dtype==134217792)or(dtype==536875010))then
					if not(VictimShotInFace(victim,dmginfo))then
						local Pos=victim:GetPos()+Vector(0,0,60)+victim:GetAimVector()*10
						local Dir=VectorRand()
						Mult=Mult*.2
						victim:EmitSound("snd_jack_helmetricochet_"..math.random(1,2)..".wav",75,100)
						local Bewlat={}
						Bewlat.Num=2
						Bewlat.Src=Pos
						Bewlat.Dir=Dir
						Bewlat.Spread=Vector(0,0,0)
						Bewlat.Tracer=1
						Bewlat.TracerName="Tracer"
						Bewlat.Force=dmginfo:GetDamageForce()/2
						Bewlat.Damage=dmginfo:GetDamage()/2
						Bewlat.Attacker=dmginfo:GetAttacker()
						Bewlat.Inflictor=dmginfo:GetInflictor()
						victim:FireBullets(Bewlat)
						local effectdata=EffectData()
						effectdata:SetOrigin(Pos)
						effectdata:SetNormal(Dir)
						effectdata:SetMagnitude(2) --amount and shoot hardness
						effectdata:SetScale(.5) --length of strands
						effectdata:SetRadius(1) --thickness of strands
						util.Effect("Sparks",effectdata,true,true)
						victim:SetSequence(ACT_FLINCH_HEAD)
					end
				end
			end
		elseif(hitgroup==HITGROUP_CHEST)then
			if(victim.AmericanBulletResistantVest)then
				Mult=Mult*.75
			end
		end
		dmginfo:ScaleDamage(Mult)
	end
	hook.Add("ScaleNPCDamage","JackyScaleNPCDamage",JackyScaleNPCDamage)
	local NextThinkTime=CurTime()
	local NextInfrequentThinkTime=CurTime()
	local NextRandomThinkTime=CurTime()
	local NextRapidThinkTime=CurTime()
	local NextQuickThinkTime=CurTime()
	local NextSomewhatInfrequentThinkTime=CurTime()
	local NextRapidRandomThinkTime=CurTime()
	local function JackyOpSquadThinkHook()
		local Time=CurTime()
		if(NextRapidRandomThinkTime<Time)then
			--nope
			NextRapidRandomThinkTime=NextRapidRandomThinkTime+math.Rand(.05,.5)
		end
		if(NextRapidThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(found.JackyOpSquadNPC)then
					if(found.OpSquadRotorDamage)then
						local SelfPos=found:GetPos()
						for key,thing in pairs(ents.FindInSphere(SelfPos,350))do
							local Class=thing:GetClass()
							if not((Class=="npc_helicopter")or(Class=="npc_gunship")or(Class=="npc_strider"))then
								if(Class=="player")then
									if(thing:Alive())then
										local HeliToVictimVector=(thing:GetPos()-SelfPos):GetNormalized()
										local DotProduct=HeliToVictimVector:DotProduct(found:GetUp())
										local InspectionAngle=(-math.deg(math.asin(DotProduct)))
										if(InspectionAngle<10)then --if you're aBOVE the helicopter's level
											HeliRotorStrike(found,thing)
										end
									end
								elseif(thing:IsNPC())then
									if(thing:Health()>0)then
										local HeliToVictimVector=(thing:GetPos()-SelfPos):GetNormalized()
										local DotProduct=HeliToVictimVector:DotProduct(found:GetUp())
										local InspectionAngle=(-math.deg(math.asin(DotProduct)))
										if(InspectionAngle<10)then --if you're aBOVE the helicopter's level
											HeliRotorStrike(found,thing)
										end
									end
								end
							end
						end
					end
				end
			end
			NextRapidThinkTime=Time+.25
		end
		if(NextQuickThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(found.JackyOpSquadNPC)then
					if(found.OpSquadCareful)then
						local Enemy=found:GetEnemy()
						local SelfPos=found:GetPos()
						if(IsValid(Enemy))then
							local EnemyPos=Enemy:GetPos()
							local OhShit=false
							for key,crap in pairs(ents.FindInSphere(SelfPos,200))do
								local Disp=found:Disposition(crap)
								if((Disp==D_HT)or(Disp==D_FR))then
									OhShit=true
									break
								end
							end
							local Vec=EnemyPos-SelfPos
							if(OhShit)then
								if(math.random(1,6)==2)then
									if(found:GetClass()=="npc_combine_s")then
										if(math.random(1,4)==3)then
											JackyPlayNPCAnim(found,"signal_halt",false,.5)
										end
										found:SetSchedule(SCHED_RUN_FROM_ENEMY_MOB)
									else
										found:SetLastPosition(SelfPos-Vec:GetNormalized()*500)
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								else
									if not(found:GetClass()=="npc_combine_s")then
										found:SetSchedule(SCHED_RUN_FROM_ENEMY_MOB)
									end
								end
							end
						end
					end
				end
			end
			NextQuickThinkTime=Time+.5
		end
		if(NextThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(IsValid(found))then
					if(found.JackyOpSquadNPC)then
						local Enemy=found:GetEnemy()
						local SelfPos=found:GetPos()
						if(found.OpSquadAggressive)then
							if(IsValid(Enemy))then
								if(found:IsCurrentSchedule(SCHED_RUN_FROM_ENEMY_FALLBACK))then -- you pussy
									if(math.Rand(0,1)>.25)then
										found:StopMoving()
										found:ClearSchedule()
										if(math.random(1,2)==1)then
											found:SetLastPosition(SelfPos+found:GetRight()*75+found:GetForward()*75)
										else
											found:SetLastPosition(SelfPos-found:GetRight()*75+found:GetForward()*75)
										end
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								end
							end
						end
						if(found.OpSquadAware)then
							--hear shit
							if(math.random(1,2)==1)then
								if not(IsValid(found:GetEnemy()))then
									for key,thing in pairs(ents.FindInSphere(SelfPos,200))do
										if not(thing==found)then
											local Disp=found:Disposition(thing)
											if((Disp==D_HT)or(Disp==D_FR))then
												if((thing:IsPlayer())and not(GetConVar("ai_ignoreplayers")))then
													CloseNotice(found,thing)
												elseif(thing:IsNPC())then
													CloseNotice(found,thing)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
			NextThinkTime=Time+1
		end
		if(NextSomewhatInfrequentThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(found.JackyOpSquadNPC)then
					local Enemy=found:GetEnemy()
					if(found.OpSquadAggressive)then
						if(IsValid(Enemy))then
							MoveCloser(found,Enemy)
						end
					end
					if(found.OpSquadAutoHealer)then
						local Time=CurTime()
						if not(IsValid(Enemy))then
							if not(found.OpSquadLastAlertTime)then
								found.OpSquadLastAlertTime=Time
							else
								local Health=found:Health()
								local MaxHealth=found:GetMaxHealth()
								if(Health<MaxHealth)then
									if((found.OpSquadLastAlertTime+25)<Time)then
										if(math.random(1,2)==1)then
											found:SetHealth(found:Health()+15)
										end
										found:EmitSound("snd_jack_cyborgheal.wav",65,80)
										found:StopMoving()
										if((found:Health()+1)>=MaxHealth)then
											found:RemoveAllDecals()
										end
										JackyPlayNPCAnim(found,"deathpose_back",true,5.5)
									end
								end
							end
						else
							found.OpSquadLastAlertTime=Time
						end
					end
					if(found.JackyFaction)then
						if(math.random(1,2)==1)then
							for key,dude in pairs(AllCreatureTable)do
								if not((dude.JackyFaction)and(dude.JackyFaction==found.JackyFaction))then
									if((dude.AddEntityRelationship)and(IsValid(found))and(IsValid(dude)))then
										found:AddEntityRelationship(dude,D_HT,72)
										dude:AddEntityRelationship(found,D_HT,72)
									end
								end
							end
						end
					end
				end
			end
			NextSomewhatInfrequentThinkTime=Time+7
		end
		if(NextInfrequentThinkTime<Time)then
			AllCreatureTable=ents.FindByClass("npc_*") -- less responsive but more efficient to cache this table
			if not(GetConVar("ai_ignoreplayers"))then
				table.Add(AllCreatureTable,player.GetAll()) -- players too
			end
			for key,found in pairs(AllCreatureTable)do
				if(IsValid(found))then
					if(found.JackyOpSquadNPC)then
						local Enemy=found:GetEnemy()
						local SelfPos=found:GetPos()
						if(found.JackyFinickyAmmoGiver)then
							if(math.Rand(0,1)>.333)then
								found:Fire("setammoresupplieroff","",math.Rand(0,5))
							else
								found:Fire("setammoresupplieron","",math.Rand(0,5))
							end
						end
						if(found.OpSquadAmazingHunter)then
							if not(IsValid(Enemy))then
								for key,target in pairs(AllCreatureTable)do
									if not(target==found)then
										local Disp=found:Disposition(target)
										if((Disp==D_HT)or(Disp==D_FR))then
											if(Facing(found,target))then
												if(ClearLoSBetween(found,target))then
													FarNotice(found,target)
												end
											end
										end
									end
								end
							end
						end
						if(found.OpSquadMedic)then
							if(math.random(1,2)==1)then
								local Cur=found:Health()
								local Max=found:GetMaxHealth()
								if((Cur<(Max*.9))and not(IsValid(Enemy)))then
									found:StopMoving()
									local Missing=Max-Cur
									found:SetHealth(Cur+Missing*.5)
									found:SetSequence(ACT_COWER)
									found:EmitSound("snd_jack_bandage.wav",65,100)
									JackyPlayNPCAnim(found,"deathpose_back",true,5)
									if(found:Health()>(Max*.8))then
										found:RemoveAllDecals()
									end
								end
							end
						end
						if(found.OpSquadStickTogether)then
							if(math.Rand(0,1)<=.55)then
								local MeetUpPoint=SelfPos
								local Num=1
								for key,other in pairs(AllCreatureTable)do
									if((other.JackyOpSquadNPC)and(other.OpSquadStickTogether)and(other:GetClass()==found:GetClass())and not(other==found))then
										MeetUpPoint=MeetUpPoint+other:GetPos()
										Num=Num+1
									end
								end
								MeetUpPoint=MeetUpPoint/Num -- this is known as the Centroid or Geometric Center
								found:SetLastPosition(MeetUpPoint+Vector(0,0,100))
								if(IsValid(Enemy))then
									found:SetSchedule(SCHED_FORCED_GO_RUN)
								else
									found:SetSchedule(SCHED_FORCED_GO)
								end
								if(math.random(1,4)==2)then
									if(found:GetClass()=="npc_combine_s")then
										JackyPlayNPCAnim(found,"signal_group",false,.75)
									end
								end
							end
						end
					end
				end
			end
			NextInfrequentThinkTime=Time+15
		end
		if(NextRandomThinkTime<Time)then
			for key,found in pairs(AllCreatureTable)do
				if(IsValid(found))then
					if(found.JackyOpSquadNPC)then
						local SelfPos=found:GetPos()
						local Enemy=found:GetEnemy()
						if(found.OpSquadIonBaller)then
							if(math.Rand(0,1)>.333)then
								if(IsValid(Enemy))then
									if(ClearLoSBetween(found,Enemy))then
										if(math.random(1,4)==3)then
											JackyPlayNPCAnim(found,"signal_forward",false,.5)
										end
										timer.Simple(.5,function()
											if((IsValid(Enemy))and(IsValid(found)))then
												local Index=Enemy:EntIndex()
												Enemy:SetName("AboutToGetFuckedUp"..Index)
												found:Fire("throwgrenadeattarget","AboutToGetFuckedUp"..Index)
											end
										end)
									end
								end
							end
						elseif(found.OpSquadGrenadier)then
							if(math.Rand(0,1)>.45)then
								if(IsValid(Enemy))then
									if(found:GetClass()=="npc_citizen")then
										local DangerClose=false
										for key,enpeesee in pairs(ents.FindInSphere(Enemy:GetPos(),200))do
											if(enpeesee:IsNPC())then
												if(enpeesee:GetClass()=="npc_citizen")then --MOVE!!
													DangerClose=true
												end
											elseif(enpeesee:IsPlayer())then --MOVE!!
												DangerClose=true
											end
										end
										if not(DangerClose)then
											if(Facing(found,Enemy))then
												if(ClearLoSBetween(found,Enemy))then
													JackyPlayNPCAnim(found,"reload_ar2",true,1.5)
													timer.Simple(1.5,function()
														if(IsValid(found))then
															if(IsValid(Enemy))then
																if(ClearLoSBetween(found,Enemy))then
																	JackyPlayNPCAnim(found,"shoot_ar2_alt",true,.75)
																	timer.Simple(.1,function()
																		if(IsValid(found))then
																			if(IsValid(Enemy))then
																				local Vec=found:GetAimVector()
																				local Pos=found:GetShootPos()+Vec*20-Vector(0,0,10)
																				local Tr=util.QuickTrace(Pos,Vec*200,found)
																				if not(Tr.Hit)then
																					found:EmitSound("weapons/ar2/ar2_altfire.wav",80,110)
																					sound.Play("weapons/ar2/ar2_altfire.wav",SelfPos,110,80)
																					local Poop=ents.Create("grenade_ar2")
																					Poop:SetPos(Pos)
																					Poop:SetOwner(found)
																					Poop:Spawn()
																					Poop:Activate()
																					ThrowBallistically(Poop,Enemy:GetPos())
																					local Kapang=EffectData()
																					Kapang:SetStart(Pos+Vector(0,0,3))
																					Kapang:SetScale(1)
																					Kapang:SetNormal(Vec)
																					util.Effect("eff_jack_gmod_normalmuzzle",Kapang,true,true)
																				end
																			end
																		end
																	end)
																end
															end
														end
													end)
												end
											end
										else
											if not(found.OpSquadStoic)then
												found:EmitSound(WarningTable[math.random(1,4)])
											end
										end
									else
										if(WithinSoManyUnitsOfEachother(found,Enemy,900))then
											if(math.random(1,4)==3)then
												JackyPlayNPCAnim(found,"signal_forward",false,.5)
											end
											timer.Simple(.5,function()
												if((IsValid(Enemy))and(IsValid(found)))then
													local Index=Enemy:EntIndex()
													Enemy:SetName("AboutToGetFuckedUp"..Index)
													found:Fire("throwgrenadeattarget","AboutToGetFuckedUp"..Index)
												end
											end)
										end
									end
								end
							end
						elseif(found.OpSquadMineDropper)then
							local Chance=.1
							if(IsValid(found:GetTarget()))then Chance=.9 end
							if(math.Rand(0,1)<Chance)then
								found:Fire("equipmine","1",0)
								found:Fire("deploymine","1",2)
							end
						end
						if(found.OpSquadWarspaceCannoneer)then
							if(math.random(1,3)==3)then
								if(IsValid(Enemy))then
									if not((Enemy:IsPlayer())and not(Enemy:Alive()))then
										if not(table.HasValue(NoCannonTable,Enemy:GetClass()))then
											if(ClearLoSBetween(found,Enemy))then
												local name="AboutToGetFuckedUp"..Enemy:EntIndex()
												Enemy:SetName(name)
												found:Fire("setcannontarget",name,0)
												found:Fire("dogroundattack",name,0)
											end
										end
									end
								end
							end
						end
						if(found.OpSquadRandomCroucher)then
							if(math.random(1,2)==1)then
								found:Fire("crouch","",0)
							else
								found:Fire("stand","",0)
							end
						end
						if(found.OpSquadWanderer)then
							if not(IsValid(Enemy))then
								local npcpos=SelfPos
								local Pos=npcpos+VectorRand()*750
								if(math.random(1,3)==2)then Pos=npcpos+found:GetForward()*500 end
								found:SetLastPosition(Pos)
								found:SetSchedule(SCHED_FORCED_GO_RUN)
							end
						end
						if(found.OpSquadBombDropper)then
							if(IsValid(Enemy))then
								if not((Enemy:IsPlayer())and not(Enemy:Alive()))then
									if(Enemy:GetPos().z<SelfPos.z)then			
										local name="AboutToGetFuckedUp"..Enemy:EntIndex()
										Enemy:SetName(name)
										found:Fire("dropbombattargetalways",name,0)
										found:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav")
										if(math.random(1,3)==1)then
											found:Fire("startcarpetbombing","",0)
										else
											found:Fire("stopcarpetbombing","",0)
										end
									end
								end
							else
								found:Fire("stopcarpetbombing","",0)
							end
						end
						if(found.OpSquadInconsistentHeliGunner)then
							local Random=math.random(1,10)
							if(Random==1)then
								found:Fire("disabledeadlyshooting","",0)
							elseif(Random==2)then
								found:Fire("enabledeadlyshooting","",0)
							elseif(Random==3)then
								found:Fire("startlongcycleshooting","",0)
							elseif(Random==4)then
								found:Fire("startnormalshooting","",0)
							end
						end
						if(found.OpSquadStalker)then
							if not(IsValid(Enemy))then
								if(math.random(1,3)==2)then
									if(math.Rand(0,1)>.4)then
										if not(found.OpSquadStalkerCamoIncreasing)then
											found.OpSquadStalkerCamoIncreasing=true
											found:EmitSound("snd_jack_cloakon.wav")
										end
									else
										if(found.OpSquadStalkerCamoIncreasing)then
											found.OpSquadStalkerCamoIncreasing=false
											found:EmitSound("snd_jack_cloakoff.wav")
										end
									end
								end
								if not(IsValid(found.ScannerBuddy))then
									JackyPlayNPCAnim(found,"deploy",true,1)
									timer.Simple(1.1,function()
										if(IsValid(found))then
											local Pop=ents.Create("npc_cscanner")
											Pop:SetKeyValue("SquadName","JackyCombineOpSquad")
											Pop:SetPos(SelfPos+Vector(0,0,70))
											Pop:SetKeyValue("SpotlightDisabled","1")
											Pop:SetHealth(1)
											Pop:SetMaxHealth(1)
											Pop:SetOwner(found)
											Pop.JackyOpSquadDrop={"item_battery"}
											Pop:Spawn()
											Pop:Activate()
											Pop:SetMaterial("models/mat_jack_stalkerscanner")
											Pop:SetModelScale(.25,0)
											Pop:SetColor(Color(50,50,50,255))
											Pop:GetPhysicsObject():SetVelocity(Vector(0,0,100))
											found.ScannerBuddy=Pop
										end
									end)
								else
									if not(IsValid(found.ScannerBuddy:GetEnemy()))then
										if(math.random(1,4)==1)then
											found.ScannerBuddy:SetLastPosition(SelfPos+Vector(0,0,100))
											found.ScannerBuddy:SetSchedule(SCHED_FORCED_GO_RUN)
										elseif(math.random(1,4)==2)then
											found.ScannerBuddy:SetLastPosition(SelfPos+VectorRand()*math.random(1000,20000))
											found.ScannerBuddy:SetSchedule(SCHED_FORCED_GO_RUN)
										end
									end
								end
							else
								if(found.State=="Stalking")then
									local For=found:GetForward()
									if(math.random(1,2)==1)then
										found:SetPos(SelfPos-For*10)
										found:SetLastPosition(SelfPos+found:GetRight()*100)
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									else
										found:SetPos(SelfPos-For*10)
										found:SetLastPosition(SelfPos-found:GetRight()*100)
										found:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								end
							end
						end
					end
				end
			end
			NextRandomThinkTime=Time+math.Rand(1,10)
		end
	end
	hook.Add("Think","JackyOpSquadThinkHook",JackyOpSquadThinkHook)
	function JackyOpSquadDeathHook(ent,attacker,inflictor)
		if not(IsValid(ent))then return end
		if not(ent.JackyOpSquadNPC)then return end
		local EntPos=ent:GetPos()
		if((ent.OpSquadHelmet)and not(ent.BuiltInHelmet))then
			umsg.Start("JackyOpSquadRemoveHelmet")
				umsg.Entity(ent)
			umsg.End()
			local Ow=ents.Create("prop_physics")
			Ow:SetModel("models/haloreach/jarinehelmet.mdl")
			local Pos,Ang=ent:GetBonePosition(6) --head
			local Right=Ang:Right()
			local Up=Ang:Up()
			local Forward=Ang:Forward()
			Ow:SetPos(Pos-Forward*59.3+Right*30-Up*2)
			Ang:RotateAroundAxis(Up,-190)
			Ang:RotateAroundAxis(Right,-95)
			Ang:RotateAroundAxis(Forward,102)
			Ang:RotateAroundAxis(Ang:Right(),20)
			Ow:SetAngles(Ang)
			Ow:Spawn()
			Ow:Activate()
			Ow:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			SafeRemoveEntityDelayed(Ow,20)
		end
		if(ent.JackyOpSquadDrop)then
			local Pos=ent:LocalToWorld(ent:OBBCenter())
			local Vel=ent:GetVelocity()/10
			for key,val in pairs(ent.JackyOpSquadDrop)do
				if(math.Rand(0,1)>.333)then -- a 66 percent chance
					local item=ents.Create(val)
					item:SetPos(Pos+VectorRand()*math.Rand(1,20))
					item:SetAngles(VectorRand():Angle())
					item:Spawn()
					item:Activate()
					item:SetPos(ent:GetPos())
					timer.Simple(0.1,function()
						if(IsValid(item))then
							if(IsValid(item:GetPhysicsObject()))then
								item:GetPhysicsObject():SetVelocity(Vel+VectorRand())
							end
						end
					end)
				end
			end
		end
		if(ent.OpSquadStalker)then
			ent:SetMaterial("")
		end
		if(ent.OpSquadUltraMegaSuperPowerDeathZombie)then
			JMod_Sploom(ent,ent:GetPos()+Vector(0,0,20),135)
			local Poof=EffectData()
			Poof:SetOrigin(ent:LocalToWorld(ent:OBBCenter())-Vector(0,0,10))
			util.Effect("eff_jack_gmod_bloodsplosion",Poof,true,true)
			umsg.Start("JackyOpSquadNoRagdoll")
				umsg.Vector(ent:GetPos())
			umsg.End()
		end
	end
	hook.Add("OnNPCKilled","JackyOpSquadDeathHook",JackyOpSquadDeathHook)
	function JackyOpSquadCreateRagdollHook(ent,ragdoll)
		if not(ent.JackyOpSquadNPC)then return end
		if(ent.OpSquadUltraMegaSuperPowerDeathZombie)then
			ragdoll:Remove()
			return
		end
		ragdoll:SetMaterial(ent:GetMaterial())
	end
	hook.Add("CreateEntityRagdoll","JackyOpSquadCreateRagdollHook",JackyOpSquadCreateRagdollHook)
	--- END OLD OPSQUADS CODE ---
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
	concommand.Add("jmod_reloadconfig",function(ply)
		if not((ply)and(ply:IsSuperAdmin()))then return end
		JMod_InitGlobalConfig()
	end)
	local NextMainThink,NextNutritionThink=0,0
	hook.Add("Think","JMOD_SERVER_THINK",function()
		local Time=CurTime()
		if(NextMainThink>Time)then return end
		NextMainThink=Time+1
		---
		for k,playa in pairs(player.GetAll())do
			if(playa.EZhealth)then
				if(playa:Alive())then
					local Healin=playa.EZhealth
					if(Healin>0)then
						local Amt=1
						if(math.random(1,3)==2)then Amt=2 end
						playa.EZhealth=Healin-Amt
						local Helf,Max=playa:Health(),playa:GetMaxHealth()
						if(Helf<Max)then
							playa:SetHealth(Helf+Amt)
							if(playa:Health()==Max)then playa:RemoveAllDecals() end
						end
					end
				end
			end
		end
		---
		if(NextNutritionThink<Time)then
			NextNutritionThink=Time+10/JMOD_CONFIG.FoodSpecs.DigestSpeed
			for k,playa in pairs(player.GetAll())do
				if(playa.EZnutrition)then
					if(playa:Alive())then
						local Nuts=playa.EZnutrition.Nutrients
						if(Nuts>0)then
							playa.EZnutrition.Nutrients=Nuts-1
							local Helf,Max,Nuts=playa:Health(),playa:GetMaxHealth()
							if(Helf<Max)then
								playa:SetHealth(Helf+1)
								if(playa:Health()==Max)then playa:RemoveAllDecals() end
							elseif(math.Rand(0,1)<.75)then
								local BoostMult=JMOD_CONFIG.FoodSpecs.BoostMult
								local BoostedFrac=(Helf-Max)/Max
								if(math.Rand(0,1)>BoostedFrac)then
									playa:SetHealth(Helf+BoostMult)
									if(playa:Health()>=Max)then playa:RemoveAllDecals() end
								end
							end
						end
					end
				end
			end
		end
	end)
	hook.Add("DoPlayerDeath","JMOD_SERVER_PLAYERDEATH",function(ply)
		ply.EZnutrition=nil
		ply.EZhealth=nil
		ply.EZkillme=nil
	end)
	hook.Add("PlayerLeaveVehicle","JMOD_LEAVEVEHICLE",function(ply,veh)
		if(veh.EZvehicleEjectPos)then
			local WorldPos=veh:LocalToWorld(veh.EZvehicleEjectPos)
			ply:SetPos(WorldPos)
			veh.EZvehicleEjectPos=nil
		end
	end)
	-- EZ Radio Code --
	local NotifyAllMsgs={
		["normal"]={
			["good drop"]="good drop, package away, returning to base",
			["drop failed"]="drop failed, pilot could not locate a good drop position for the reported coordinates. Aircraft is RTB",
			["drop soon"]="be advised, aircraft on site, drop imminent",
			["ready"]="attention, this outpost is now ready to carry out delivery missions"
		},
		["bff"]={
			["good drop"]="AIGHT we dropped it, watch out yo",
			["drop failed"]="yo WHERE THE DROP SITE AT THO soz i gotta get back to base",
			["drop soon"]="ay dudes watch yo head we abouta drop the box",
			["ready"]="aight we GOOD TO GO out here jus tell us whatchya need anytime"
		}
	}
	local function NotifyAllRadios(stationID,msgID,direct)
		local Radios=EZ_RADIO_STATIONS[stationID].transceivers
		for k,v in pairs(Radios)do
			if(IsValid(v))then
				if(direct)then
					v:Speak(msgID)
				else
					if(v.BFFd)then
						v:Speak(NotifyAllMsgs["bff"][msgID])
					else
						v:Speak(NotifyAllMsgs["normal"][msgID])
					end
				end
			else
				Radios[k]=nil
			end
		end
	end
	local function FindDropPosFromSignalOrigin(origin)
		local Height,Attempts,Pos=0,0,nil
		while((Attempts<1000)and not(Height>5000))do
			Height=Height+50
			local TestPos=origin+Vector(0,0,Height)
			local Contents=util.PointContents(TestPos)
			if((Contents==CONTENTS_EMPTY)or(Contents==CONTENTS_TESTFOGVOLUME))then
				Pos=TestPos
			end
		end
		return Pos
	end
	local NextThink=0
	hook.Add("Think","JMod_RADIO_THINK",function()
		local Time=CurTime()
		if(Time<NextThink)then return end
		NextThink=Time+5
		for stationID,station in pairs(EZ_RADIO_STATIONS)do
			if(station.state==EZ_STATION_STATE_DELIVERING)then
				if(station.nextDeliveryTime<Time)then
					station.nextReadyTime=Time+math.ceil(JMOD_CONFIG.RadioSpecs.DeliveryTimeMult*math.Rand(30,60)*3)
					station.state=EZ_STATION_STATE_BUSY
					local DropPos=FindDropPosFromSignalOrigin(station.deliveryLocation)
					if(DropPos)then
						local DropVelocity=VectorRand()
						DropVelocity.z=0
						DropVelocity:Normalize()
						DropVelocity=DropVelocity*400
						local Eff=EffectData()
						Eff:SetOrigin(DropPos)
						Eff:SetStart(DropVelocity)
						util.Effect("eff_jack_gmod_jetflyby",Eff,true,true)
						local DeliveryItems=JMOD_CONFIG.RadioSpecs.AvailablePackages[station.deliveryType]
						timer.Simple(.9,function()
							local Box=ents.Create("ent_jack_aidbox")
							Box:SetPos(DropPos)
							Box.InitialVel=-DropVelocity*10
							Box.Contents=DeliveryItems
							Box.NoFadeIn=true
							Box:SetDTBool(0,"true")
							Box:Spawn()
							Box:Initialize()
							---
							sound.Play("snd_jack_flyby_drop.mp3",DropPos,150,100)
							for k,playa in pairs(ents.FindInSphere(DropPos,6000))do
								if(playa:IsPlayer())then sound.Play("snd_jack_flyby_drop.mp3",playa:GetShootPos(),50,100) end
							end
							NotifyAllRadios(stationID,"good drop")
						end)
					else
						NotifyAllRadios(stationID,"drop failed")
					end
				elseif((station.nextNotifyTime<Time)and not(station.notified))then
					station.notified=true
					NotifyAllRadios(stationID,"drop soon")
				end
			elseif(station.state==EZ_STATION_STATE_BUSY)then
				if(station.nextReadyTime<Time)then
					station.state=EZ_STATION_STATE_READY
					NotifyAllRadios(stationID,"ready")
				end
			end
			if(station.restrictedPackageDelivering)then
				if(station.restrictedPackageDeliveryTime<Time)then
					table.insert(station.restrictedPackageStock,station.restrictedPackageDelivering)
					NotifyAllRadios(stationID,"attention, this outpost has received a special shipment of "..station.restrictedPackageDelivering.." from regional HQ",true)
					station.restrictedPackageDelivering=nil
					station.restrictedPackageDeliveryTime=0
				end
			end
		end
	end)
	hook.Add("PlayerSay","JMod_RADIO_SAY",function(ply,txt)
		if not(ply:Alive())then return end
		if(txt=="*trigger*")then JMod_EZ_Remote_Trigger(ply) end
		for k,v in pairs(ents.FindInSphere(ply:GetPos(),150))do
			if(v.EZreceiveSpeech)then
				if(v:EZreceiveSpeech(ply,txt))then return "" end -- hide the player's radio chatter from the server
			end
		end
	end)
	local SERVER_JMOD_HINT_GIVEN=false
	hook.Add("PlayerInitialSpawn","JMOD_INITIALSPAWN",function(ply)
		if((JMOD_CONFIG)and(JMOD_CONFIG.Hints)and not(SERVER_JMOD_HINT_GIVEN))then
			SERVER_JMOD_HINT_GIVEN=true
			timer.Simple(10,function()
				if(ply)then JMod_Hint(ply,"customize") end
			end)
		end
	end)
	function JMod_EZradioEstablish(transceiver,id)
		local Station=EZ_RADIO_STATIONS[id] or {
			state=EZ_STATION_STATE_READY,
			nextDeliveryTime=0,
			nextReadyTime=0,
			deliveryLocation=nil,
			deliveryType=nil,
			transceivers={},
			nextNotifyTime=0,
			notified=false,
			restrictedPackageStock={},
			restrictedPackageDelivering=nil,
			restrictedPackageDeliveryTime=0
		}
		table.insert(Station.transceivers,transceiver)
		EZ_RADIO_STATIONS[id]=Station
	end
	local function GetArticle(word)
		local FirstLetter=string.sub(word,1,1)
		if(table.HasValue({"a","e","i","o","u"},FirstLetter))then
			return "an"
		else
			return "a"
		end
	end
	local function GetTimeString(seconds)
		local Minutes,Seconds,Result=math.floor(seconds/60),math.floor(seconds%60),""
		if(Minutes>0)then
			Result=Minutes.." minutes"
			if(Seconds>0)then Result=Result..", "..Seconds.." seconds" end
		elseif(Seconds>0)then
			Result=Seconds.." seconds"
		end
		return Result
	end
	local function StartDelivery(pkg,transceiver,station,bff)
		local Time=CurTime()
		local DeliveryTime,Pos=math.ceil(JMOD_CONFIG.RadioSpecs.DeliveryTimeMult*math.Rand(30,60)),transceiver:GetPos()
		station.state=EZ_STATION_STATE_DELIVERING
		station.nextDeliveryTime=Time+DeliveryTime
		station.deliveryLocation=Pos
		station.deliveryType=pkg
		station.notified=false
		station.nextNotifyTime=Time+(DeliveryTime-5)
		if(bff)then return "ayo GOOD COPY homie, we sendin "..GetArticle(pkg).." "..pkg.." box right over to "..math.Round(Pos.x).." "..math.Round(Pos.y).." "..math.Round(Pos.z).." in prolly like "..DeliveryTime.." seconds" end
		return "roger wilco, sending "..GetArticle(pkg).." "..pkg.." package to coordinates "..math.Round(Pos.x).." "..math.Round(Pos.y).." "..math.Round(Pos.z)..", ETA "..DeliveryTime.." seconds"
	end
	function JMod_EZradioRequest(transceiver,id,ply,pkg,bff)
		local PackageInfo,Station,Time=JMOD_CONFIG.RadioSpecs.AvailablePackages[pkg],EZ_RADIO_STATIONS[id],CurTime()
		if not(Station)then
			JMod_EZradioEstablish(transceiver,id)
			Station=EZ_RADIO_STATIONS[id]
		end
		transceiver.BFFd=bff
		if(Station.state==EZ_STATION_STATE_DELIVERING)then
			if(bff)then return "no can do bro, we deliverin somethin else" end
			return "negative on that request, we're currently delivering another package"
		elseif(Station.state==EZ_STATION_STATE_BUSY)then
			if(bff)then return "nah fam we ain't ready yet tryagin l8r aight" end
			return "negative on that request, the delivery team isn't currently on station"
		elseif(Station.state==EZ_STATION_STATE_READY)then
			if(table.HasValue(JMOD_CONFIG.RadioSpecs.RestrictedPackages,pkg))then
				if not(JMOD_CONFIG.RadioSpecs.RestrictedPackagesAllowed)then return "negative on that request, neither we nor regional HQ have any of that at this time" end
				if(table.HasValue(Station.restrictedPackageStock,pkg))then
					table.RemoveByValue(Station.restrictedPackageStock,pkg)
					return StartDelivery(pkg,transceiver,Station,bff)
				else
					if(Station.restrictedPackageDelivering)then
						return "negative on that request, we don't have any of that in stock and HQ is currently delivering another special shipment"
					else
						Station.restrictedPackageDelivering=pkg
						local DeliveryTime=JMOD_CONFIG.RadioSpecs.RestrictedPackageShipTime*math.Rand(.8,1.2)
						Station.restrictedPackageDeliveryTime=Time+DeliveryTime
						return "roger, we don't have any of that in stock but we've ordered it from regional HQ, it'll be at this outpost in "..GetTimeString(DeliveryTime)
					end
				end
			else
				return StartDelivery(pkg,transceiver,Station,bff)
			end
		end
	end
	function JMod_EZradioStatus(transceiver,id,ply,bff)
		local Station,Time,Msg=EZ_RADIO_STATIONS[id],CurTime(),""
		transceiver.BFFd=bff
		if(Station.state==EZ_STATION_STATE_DELIVERING)then
			Msg="this outpost is currently delivering a package"
			if(bff)then Msg="hey we gettin somethin fo someone else righ now" end
		elseif(Station.state==EZ_STATION_STATE_BUSY)then
			Msg="this outpost is currently preparing for deliveries"
			if(bff)then Msg="hey homie we pretty busy out here right now jus hol up" end
		elseif(Station.state==EZ_STATION_STATE_READY)then
			Msg="this outpost is ready to accept delivery missions"
			if(bff)then Msg="ANYTHING U NEED WE GOTCHU" end
		end
		if(#Station.restrictedPackageStock>0)then
			local InventoryList=""
			for k,v in pairs(Station.restrictedPackageStock)do
				InventoryList=InventoryList..v..", "
			end
			Msg=Msg..", and has a special stock of "..InventoryList
		end
		if(Station.restrictedPackageDelivering)then
			Msg=Msg..", and has a special delivery of "..Station.restrictedPackageDelivering.." arriving from regional HQ in "..GetTimeString(Station.restrictedPackageDeliveryTime-Time)
		end
		return Msg
	end
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
	function JMod_EZ_Remote_Trigger(ply)
		if not(IsValid(ply))then return end
		if not(ply:Alive())then return end
		sound.Play("snd_jack_detonator.wav",ply:GetShootPos(),55,math.random(90,110))
		timer.Simple(.75,function()
			if((IsValid(ply))and(ply:Alive()))then
				for k,v in pairs(ents.GetAll())do
					if((v.JModEZremoteTriggerFunc)and(v.Owner)and(v.Owner==ply))then
						v:JModEZremoteTriggerFunc(ply)
					end
				end
			end
		end)
	end
	net.Receive("JMod_MineColor",function(ln,ply)
		if not((IsValid(ply))and(ply:Alive()))then return end
		local Mine=net.ReadEntity()
		local Col=net.ReadColor()
		local Arm=tobool(net.ReadBit())
		if not(IsValid(Mine))then return end
		Mine:SetColor(Col)
		if(Arm)then Mine:Arm(ply) end
	end)
	-- copied from Homicide
	function JMod_BlastThatDoor(ent,vel)
		local Moddel,Pozishun,Ayngul,Muteeriul,Skin=ent:GetModel(),ent:GetPos(),ent:GetAngles(),ent:GetMaterial(),ent:GetSkin()
		sound.Play("Wood_Crate.Break",Pozishun,60,100)
		sound.Play("Wood_Furniture.Break",Pozishun,60,100)
		ent:Fire("open","",0)
		ent:SetNoDraw(true)
		ent:SetNotSolid(true)
		if((Moddel)and(Pozishun)and(Ayngul))then
			local Replacement=ents.Create("prop_physics")
			Replacement:SetModel(Moddel);Replacement:SetPos(Pozishun+Vector(0,0,1))
			Replacement:SetAngles(Ayngul)
			if(Muteeriul)then Replacement:SetMaterial(Muteeriul) end
			if(Skin)then Replacement:SetSkin(Skin) end
			Replacement:SetModelScale(.9,0)
			Replacement:Spawn()
			Replacement:Activate()
			if(vel)then Replacement:GetPhysicsObject():SetVelocity(vel) end
			timer.Simple(3,function()
				if(IsValid(Replacement))then Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON) end
			end)
			timer.Simple(6,function()
				if(IsValid(ent))then ent:SetNotSolid(false);ent:SetNoDraw(false) end
				if(IsValid(Replacement))then Replacement:Remove() end
			end)
		end
	end
	function JMod_PackageObject(ent,pos,ang,ply)
		if(pos)then
			ent=ents.Create(ent)
			ent:SetPos(pos)
			ent:SetAngles(ang)
			if(ply)then
				ent.Owner=ply
				ent:SetOwner(ply)
			end
			ent:Spawn()
			ent:Activate()
		end
		local Bocks=ents.Create("ent_jack_gmod_ezcompactbox")
		Bocks:SetPos(ent:LocalToWorld(ent:OBBCenter())+Vector(0,0,20))
		Bocks:SetAngles(ent:GetAngles())
		Bocks:SetContents(ent)
		if(ply)then
			Bocks.Owner=ply
			Bocks:SetOwner(ply)
		end
		Bocks:Spawn()
		Bocks:Activate()
	end
	function JMod_WreckBuildings(blaster,pos,power)
		power=power*JMOD_CONFIG.ExplosionPropDestroyPower
		local LoosenThreshold,DestroyThreshold=400*power,100*power
		for k,prop in pairs(ents.FindInSphere(pos,100*power))do
			local Phys=prop:GetPhysicsObject()
			if(not(prop==blaster)and(IsValid(Phys)))then
				local PropPos=prop:LocalToWorld(prop:OBBCenter())
				if(prop:Visible(blaster))then
					local Mass=Phys:GetMass()
					if(Mass<=DestroyThreshold)then
						SafeRemoveEntity(prop)
					elseif(Mass<=LoosenThreshold)then
						Phys:EnableMotion(true)
						constraint.RemoveAll(prop)
						Phys:ApplyForceOffset((PropPos-pos):GetNormalized()*300*power*Mass,PropPos+VectorRand()*10)
					else
						Phys:ApplyForceOffset((PropPos-pos):GetNormalized()*300*power*Mass,PropPos+VectorRand()*10)
					end
				end
			end
		end
	end
	function JMod_BlastDoors(blaster,pos,power)
		for k,door in pairs(ents.FindInSphere(pos,50*power))do
			if((blaster:Visible(door))and(JMod_IsDoor(door)))then
				local Vel=(door:LocalToWorld(door:OBBCenter())-pos):GetNormalized()*1000
				JMod_BlastThatDoor(door,Vel)
			end
		end
	end
	function JMod_Sploom(attacker,pos,mag)
		local Sploom=ents.Create("env_explosion")
		Sploom:SetPos(pos)
		Sploom:SetOwner(attacker or game.GetWorld())
		Sploom:SetKeyValue("iMagnitude",mag)
		Sploom:Spawn()
		Sploom:Activate()
		Sploom:Fire("explode","",0)
	end
	local TriggerKeys={IN_ATTACK,IN_USE,IN_ATTACK2}
	function JMod_ThrowablePickup(playa,item)
		playa:PickupObject(item)
		local HookName="EZthrowable_"..item:EntIndex()
		hook.Add("KeyPress",HookName,function(ply,key)
			if not(IsValid(playa))then hook.Remove("KeyPress",HookName) return end
			if not(ply==playa)then return end
			if((IsValid(item))and(ply:Alive()))then
				local Phys=item:GetPhysicsObject()
				if(key==IN_ATTACK)then
					timer.Simple(0,function()
						if(IsValid(Phys))then Phys:ApplyForceCenter(ply:GetAimVector()*600*Phys:GetMass()) end
					end)
				elseif(key==IN_ATTACK2)then
					timer.Simple(0,function()
						if(IsValid(Phys))then Phys:ApplyForceCenter(ply:GetAimVector()*200*Phys:GetMass()) end
					end)
				end
			end
			if(table.HasValue(TriggerKeys,key))then hook.Remove("KeyPress",HookName) end
		end)
	end
	net.Receive("JMod_EZbuildKit",function(ln,ply)
		local Num,Wep=net.ReadInt(8),ply:GetWeapon("wep_jack_gmod_ezbuildkit")
		if(IsValid(Wep))then
			Wep:SwitchSelectedBuild(Num)
		end
	end)
	net.Receive("JMod_EZworkbench",function(ln,ply)
		local Bench,Name=net.ReadEntity(),net.ReadString()
		if((IsValid(Bench))and(ply:Alive()))then
			if(ply:GetPos():Distance(Bench:GetPos())<200)then
				Bench:TryBuild(Name,ply)
			end
		end
	end)
	net.Receive("JMod_EZtimeBomb",function(ln,ply)
		local ent=net.ReadEntity()
		local tim=net.ReadInt(16)
		if((ent:GetState()==0)and(ent.Owner==ply)and(ply:Alive())and(ply:GetPos():Distance(ent:GetPos())<=150))then
			ent:SetTimer(math.min(tim,600))
			ent.DisarmNeeded=math.min(tim,600)/2
			ent:NextThink(CurTime()+1)
			ent:SetState(1)
			ent:EmitSound("weapons/c4/c4_plant.wav",60,120)
			ent:EmitSound("snd_jack_minearm.wav",60,100)
		end
	end)
	net.Receive("JMod_UniCrate",function(ln,ply)
		local box=net.ReadEntity()
		local class=net.ReadString()
		if !IsValid(box) or (box:GetPos() - ply:GetPos()):Length()>100 or !box.Items[class] or box.Items[class]<=0 then return end
		box.Items[class]=(box.Items[class]>1) and (box.Items[class] - 1) or nil
		local ent=ents.Create(class)
		ent:SetPos(box:GetPos())
		ent:SetAngles(box:GetAngles())
		ent:Spawn()
		ply:PickupObject(ent)
		timer.Simple(0, function() box:SetItemCount(box:GetItemCount() - math.max(ent:GetPhysicsObject():GetVolume()/1000, 1)) end)
		box.NextLoad=CurTime()+2
		box:EmitSound("Ammo_Crate.Close")
		box:CalcWeight()
	end)
	--[[
	concommand.Add("damnit",function(ply,cmd,args)
		ents.FindByClass("prop_ragdoll")[1]:SetPos(ply:GetPos())
		for i=0,100 do
			--ents.FindByClass("prop_ragdoll")[1]:SetRagdollPos(i,ply:GetPos())
		end
	end)
	--]]
end

