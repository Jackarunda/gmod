
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

local function CreateRadioStation(teamID)
	return {
		state=JMod.EZ_STATION_STATE_READY,
		nextDeliveryTime=0,
		nextReadyTime=0,
		deliveryLocation=nil,
		deliveryType=nil,
		teamID=teamID,
		nextNotifyTime=0,
		notified=false,
		restrictedPackageStock={},
		restrictedPackageDelivering=nil,
		restrictedPackageDeliveryTime=0
	}
end

local function NotifyAllRadios(stationID,msgID,direct)
	local Station=JMod.EZ_RADIO_STATIONS[stationID]
	local Radios=ents.FindByClass("ent_jack_gmod_ezaidradio")
	for k,v in pairs(Radios)do
		if(v:GetState()>0 and v:GetOutpostID()==stationID)then
			if(msgID)then
				if(direct)then
					v:Speak(msgID)
				else
					if(v.BFFd)then
						v:Speak(NotifyAllMsgs["bff"][msgID])
					else
						v:Speak(NotifyAllMsgs["normal"][msgID])
					end
				end
			end
			v:SetState(Station.state)
		end
	end
end

local function FindDropPosFromSignalOrigin(origin)
	local Height,Attempts,Pos,AcceptTFVonly=0,0,origin+Vector(0,0,200),false
	while((Attempts<1000)and not(Height>5000))do
		Height=Height+100
		local TestPos=origin+Vector(0,0,Height)
		local Contents=util.PointContents(TestPos)
		local IsEmpty=(bit.band(Contents,CONTENTS_EMPTY)==CONTENTS_EMPTY)
		local IsTFV=(bit.band(Contents,CONTENTS_TESTFOGVOLUME)==CONTENTS_TESTFOGVOLUME)
		if(IsTFV)then
			-- if we ever detect testfogvolume, assume the mapmaker used it properly
			-- and from that point on, accept only tfv as an indication of empty space
			AcceptTFVonly=true
			-- otherwise, accept both tfv and contents_empty
		end
		if(AcceptTFVonly)then
			if(IsTFV)then
				Pos=TestPos
			else
				return Pos
			end
		else
			if((IsEmpty)or(IsTFV))then
				Pos=TestPos
			else
				return Pos
			end
		end
	end
	return Pos
end

local NextThink=0
hook.Add("Think","JMod_RADIO_THINK",function()
	local Time=CurTime()
	if(Time<NextThink)then return end
	NextThink=Time+5
	for stationID,station in pairs(JMod.EZ_RADIO_STATIONS)do
		if(station.state==JMod.EZ_STATION_STATE_DELIVERING)then
			if(station.nextDeliveryTime<Time)then
				station.nextReadyTime=Time+math.ceil(JMod.Config.RadioSpecs.DeliveryTimeMult*math.Rand(30,60)*3)
				station.state=JMod.EZ_STATION_STATE_BUSY
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
					local DeliveryItems=JMod.Config.RadioSpecs.AvailablePackages[station.deliveryType]
					timer.Simple(.9,function()
						local Box=ents.Create("ent_jack_aidbox")
						Box:SetPos(DropPos)
						Box.InitialVel=-DropVelocity*10
						Box.Contents=DeliveryItems
						Box.NoFadeIn=true
						Box:SetDTBool(0,"true")
						Box:Spawn()
						Box:Initialize()
						Box:SetPackageName(station.deliveryType)
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
		elseif(station.state==JMod.EZ_STATION_STATE_BUSY)then
			if(station.nextReadyTime<Time)then
				station.state=JMod.EZ_STATION_STATE_READY
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

hook.Add("PlayerSay","JMod_PLAYERSAY",function(ply,txt)
	if not(IsValid(ply))then return end
	if not(ply:Alive())then return end
	local lowerTxt=string.lower(txt)
	if(lowerTxt=="*trigger*")then JMod.EZ_Remote_Trigger(ply);return "" end
	if(lowerTxt=="*bomb*")then JMod.EZ_BombDrop(ply);return "" end
	if(lowerTxt=="*launch*")then JMod.EZ_WeaponLaunch(ply);return "" end
	if((lowerTxt=="*inv*")or(lowerTxt=="*inventory*"))then JMod.EZ_Open_Inventory(ply);return "" end
	for k,v in pairs(ents.FindInSphere(ply:GetPos(),150))do
		if(v.EZreceiveSpeech)then
			if(v:EZreceiveSpeech(ply,txt))then return "" end -- hide the player's radio chatter from the server
		end
	end
	if((ply.EZarmor)and(ply.EZarmor.effects.teamComms))then
		for id,data in pairs(ply.EZarmor.items)do
			local Info=JMod.ArmorTable[data.name]
			if((Info.eff)and(Info.eff.teamComms))then
				local SubtractAmt = JMod.Config.ArmorDegredationMult / 2
				data.chrg.power=math.Clamp(data.chrg.power-SubtractAmt,0,9e9)
				if(data.chrg.power<=Info.chrg.power*.25)then JMod.EZarmorWarning(ply,"armor's electrical charge is almost depleted!") end
			end
		end
		local bestradio = nil
		for _, v in pairs(ents.FindByClass("ent_jack_gmod_ezaidradio")) do
			if v:UserIsAuthorized(ply) and (not bestradio or bestradio:GetPos():Distance(ply:GetPos()) < v:GetPos():DistToSqr(ply:GetPos())) then
				bestradio = v
			end
		end
		if bestradio and bestradio:EZreceiveSpeech(ply, txt) then
			return ""
		end
	end
end)

function JMod.EZradioEstablish(transceiver,teamID)
	local AlliedStations = {}
	for k,v in pairs(JMod.EZ_RADIO_STATIONS) do
		if v.teamID == teamID then 
			table.insert(AlliedStations,k)
		end
	end
	if(#AlliedStations<=0)then
		table.insert(JMod.EZ_RADIO_STATIONS,CreateRadioStation(teamID))
		table.insert(AlliedStations,#JMod.EZ_RADIO_STATIONS)
	end	
	local ChosenStation = nil
	for k,id in pairs(AlliedStations)do
		local Taken=false
		for key,radio in pairs(ents.FindByClass("ent_jack_gmod_ezaidradio"))do
			if(radio~=transceiver and radio:GetState()>0 and radio:GetOutpostID()==id)then Taken=true break end
		end
		if not(Taken)then
			ChosenStation=id
			break
		end
	end
	if not(ChosenStation)then
		for k,v in pairs(AlliedStations) do
			local station = JMod.EZ_RADIO_STATIONS[v]
			if station.state == JMod.EZ_STATION_STATE_READY then
				ChosenStation = v
				break
			end
		end
	end
	if not ChosenStation then ChosenStation=table.Random(AlliedStations) end
	transceiver:SetOutpostID(ChosenStation)
end

function JMod.AddNewRadioOutpost(teamID) -- this is on the global table for third-party use
	table.insert(JMod.EZ_RADIO_STATIONS,CreateRadioStation(teamID))
	for k,ply in pairs(player.GetAll())do
		if((tostring(ply:Team())==teamID)or(tostring(ply:AccountID()==teamID)))then
			ply:PrintMessage(HUD_PRINTTALK,"Your team has gained a radio outpost.")
		end
	end
end

function JMod.RemoveRadioOutPost(teamID) -- this is also on the global table for third-party use
    for k, v in pairs(JMod.EZ_RADIO_STATIONS) do
        if v.teamID == teamID then
            table.remove(JMod.EZ_RADIO_STATIONS, k)
            break
        end
    end
    for _, radio in pairs(ents.FindByClass("ent_jack_gmod_ezaidradio")) do
        radio:TurnOff()
    end
	for k,ply in pairs(player.GetAll())do
		if((tostring(ply:Team())==teamID)or(tostring(ply:AccountID()==teamID)))then
			ply:PrintMessage(HUD_PRINTTALK,"Your team has lost a radio outpost.")
		end
	end
end

function JMod.Add_Radio_Outpost(ply, teamIndex, amt)
	JMod_EZradioEstablish(transceiver:GetOwner():Team(),id)
	local startcount, captured, total = JMod.Config.StartingOutpostCount,0,0
	captured = amt + startcount
	total = captured + amt + startcount 
	if total < startcount then return "Cannot go below starting outpost count!" end
	print("Team "..teamIndex.."has gained "..amt.." outpost!")
end

concommand.Add("jmod_debug_addoutpost", function( ply, cmd, amt )
	if !ply:IsUserGroup("superadmin") then return end
    JMod_Add_Radio_Outpost(ply:Team(), amt)
    print("Added "..amt.." outpost(s) to Team #"..ply:Team()..".")
end)

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

local function StartDelivery(pkg,transceiver,id,bff,ply)
	local Station=JMod.EZ_RADIO_STATIONS[id]
	local Time=CurTime()
	local DeliveryTime,Pos=math.ceil(JMod.Config.RadioSpecs.DeliveryTimeMult*math.Rand(30,60)),ply:GetPos()
	
	local newTime, newPos = hook.Run("JMod_RadioDelivery", transceiver.Owner, transceiver, pkg, time, pos)
	DeliveryTime = newTime or DeliveryTime
	Pos = newPos or Pos

	JMod.Hint(transceiver.Owner, "aid wait", transceiver)
	Station.state=JMod.EZ_STATION_STATE_DELIVERING
	Station.nextDeliveryTime=Time+DeliveryTime
	Station.deliveryLocation=Pos
	Station.deliveryType=pkg
	Station.notified=false
	Station.nextNotifyTime=Time+(DeliveryTime-5)
	NotifyAllRadios(id) -- do a notify to update all radio states
	if(bff)then return "ayo GOOD COPY homie, we sendin "..GetArticle(pkg).." "..pkg.." box right over to "..math.Round(Pos.x).." "..math.Round(Pos.y).." "..math.Round(Pos.z).." in prolly like "..DeliveryTime.." seconds" end
	return "roger wilco, sending "..GetArticle(pkg).." "..pkg.." package to coordinates "..math.Round(Pos.x)..", "..math.Round(Pos.z).."; ETA "..DeliveryTime.." seconds"
end

function JMod.EZradioRequest(transceiver,id,ply,pkg,bff)
	local PackageInfo,Station,Time=JMod.Config.RadioSpecs.AvailablePackages[pkg],JMod.EZ_RADIO_STATIONS[id],CurTime()
	if not(Station)then return end
	NotifyAllRadios(id) -- do a notify to update all radio states
	transceiver.BFFd=bff
	
	local override, msg = hook.Run("JMod_CanRadioRequest", ply, transceiver, pkg)
	if override == false then
		return msg or "negative on that request."
	end
	
	if(Station.state==JMod.EZ_STATION_STATE_DELIVERING)then
		if(bff)then return "no can do bro, we deliverin somethin else" end
		return "negative on that request, we're currently delivering another package"
	elseif(Station.state==JMod.EZ_STATION_STATE_BUSY)then
		if(bff)then return "nah fam we ain't ready yet tryagin l8r aight" end
		return "negative on that request, the delivery team isn't currently on station"
	elseif(Station.state==JMod.EZ_STATION_STATE_READY)then
		if(table.HasValue(JMod.Config.RadioSpecs.RestrictedPackages,pkg))then
			if not(JMod.Config.RadioSpecs.RestrictedPackagesAllowed)then
				if bff then
					return "can't do that fam, HQ is dry and so are we"
				else
					return "negative on that request, neither we nor regional HQ have any of that at this time"
				end
			end
			if(table.HasValue(Station.restrictedPackageStock,pkg))then
				table.RemoveByValue(Station.restrictedPackageStock,pkg)
				return StartDelivery(pkg,transceiver,id,bff,ply)
			else
				if(Station.restrictedPackageDelivering)then
					if bff then
						return "bro, HQ is busy with another special shipment, you gotta wait some more"
					else
						return "negative on that request, we don't have any of that in stock and HQ is currently delivering another special shipment"
					end
				else
					Station.restrictedPackageDelivering=pkg
					local DeliveryTime=JMod.Config.RadioSpecs.RestrictedPackageShipTime*math.Rand(.8,1.2)
					Station.restrictedPackageDeliveryTime=Time+DeliveryTime
					if bff then
						return "homie, we gon get you that special delivery straight from HQ. give us "..GetTimeString(DeliveryTime).." yea?"
					else
						return "roger, we don't have any of that in stock but we've ordered it from regional HQ, it'll be at this outpost in "..GetTimeString(DeliveryTime)
					end
				end
			end
		else
			return StartDelivery(pkg,transceiver,id,bff,ply)
		end
	end
end

function JMod.EZradioStatus(transceiver,id,ply,bff)
	local Station,Time,Msg=JMod.EZ_RADIO_STATIONS[id],CurTime(),""
	if not(Station)then return end
	NotifyAllRadios(id) -- do a notify to update all radio states
	transceiver.BFFd=bff
	if(Station.state==JMod.EZ_STATION_STATE_DELIVERING)then
		Msg="this outpost is currently delivering a package"
		if(bff)then Msg="hey we gettin somethin fo someone else righ now" end
	elseif(Station.state==JMod.EZ_STATION_STATE_BUSY)then
		Msg="this outpost is currently preparing for deliveries"
		if(bff)then Msg="hey homie we pretty busy out here right now jus hol up" end
	elseif(Station.state==JMod.EZ_STATION_STATE_READY)then
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
