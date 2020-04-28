
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
    if not(IsValid(ply))then return end
    if not(ply:Alive())then return end
    local lowerTxt=string.lower(txt)
    if(lowerTxt=="*trigger*")then JMod_EZ_Remote_Trigger(ply);return "" end
    if(lowerTxt=="*armor*")then JMod_EZ_Remove_Armor(ply);return "" end
    if(lowerTxt=="*mask*")then JMod_EZ_Toggle_Mask(ply);return "" end
    if(lowerTxt=="*headset*")then JMod_EZ_Toggle_Headset(ply);return "" end
    if(lowerTxt=="*bomb*")then JMod_EZ_BombDrop(ply);return "" end
    if(lowerTxt=="*launch*")then JMod_EZ_WeaponLaunch(ply);return "" end
    for k,v in pairs(ents.FindInSphere(ply:GetPos(),150))do
        if(v.EZreceiveSpeech)then
            if(v:EZreceiveSpeech(ply,txt))then return "" end -- hide the player's radio chatter from the server
        end
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
    
    local newTime, newPos = hook.Run("JMod_RadioDelivery", transceiver.Owner, transceiver, pkg, time, pos)
    DeliveryTime = newTime or DeliveryTime
    Pos = newPos or Pos

    JMod_Hint(transceiver.Owner, "aid wait", transceiver)
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
    
    local override, msg = hook.Run("JMod_CanRadioRequest", ply, transceiver, pkg)
    if override == false then
        return msg or "negative on that request."
    end
    
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
