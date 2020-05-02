resource.AddWorkshop("1919689921")
resource.AddWorkshop("1919703147")
resource.AddWorkshop("1919692947")
resource.AddWorkshop("1919694756")


local function JackaSpawnHook(ply)
    ply.JModFriends=ply.JModFriends or {}
    ply.EZarmor={
        slots={},
        maskOn=true,
        headsetOn=true,
        speedFrac=nil,
        Effects={}
    }
    JModEZarmorSync(ply)
    ply.EZhealth=nil
    ply.EZirradiated=nil
    net.Start("JMod_PlayerSpawn")
    net.WriteBit(JMOD_CONFIG.Hints)
    net.Send(ply)
end
hook.Add("PlayerSpawn","JackaSpawnHook",JackaSpawnHook)

hook.Add("GetPreferredCarryAngles","JMOD_PREFCARRYANGS",function(ent)
    if(ent.JModPreferredCarryAngles)then return ent.JModPreferredCarryAngles end
end)

local NextMainThink,NextNutritionThink,NextArmorThink,NextSync=0,0,0,0
hook.Add("Think","JMOD_SERVER_THINK",function()
    local Time=CurTime()
    if(NextMainThink>Time)then return end
    NextMainThink=Time+1
    ---
    for k,playa in pairs(player.GetAll())do
        local Alive=playa:Alive()
        if((playa.EZhealth)and(Alive))then
            local Healin=playa.EZhealth
            if(Healin>0)then
                local Amt=1
                if(math.random(1,3)==2)then Amt=2 end
                playa.EZhealth=Healin-Amt
                local Helf,Max=playa:Health(),playa:GetMaxHealth()
                if(Helf<Max)then
                    playa:SetHealth(math.Clamp(Helf+Amt,0,Max))
                    if(playa:Health()==Max)then playa:RemoveAllDecals() end
                end
            end
        end
        if((playa.EZirradiated)and(Alive))then
            local Rads=playa.EZirradiated
            if((Rads>0)and(math.random(1,3)==1))then
                playa.EZirradiated=math.Clamp(Rads-.5,0,9e9)
                local Helf,Max=playa:Health(),playa:GetMaxHealth()
                local Dmg=DamageInfo()
                Dmg:SetAttacker(playa)
                Dmg:SetInflictor(game.GetWorld())
                Dmg:SetDamage(1)
                Dmg:SetDamageType(DMG_GENERIC)
                Dmg:SetDamagePosition(playa:GetShootPos())
                playa:TakeDamageInfo(Dmg)
                
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
    ---
    if(NextArmorThink<Time)then
        NextArmorThink=Time+10
        for k,playa in pairs(player.GetAll())do
            if((playa.EZarmor)and(playa:Alive()))then
                if(playa.EZarmor.Effects.nightVision)then
                    for slot,slotInfo in pairs(playa.EZarmor.slots)do
                        local Info=JMod_ArmorTable[slot][slotInfo[1]]
                        if((Info.eff)and(table.HasValue(Info.eff,"nightVision")))then
                            JMod_DamageArmor(playa,slot,.5)
                        end
                    end
                elseif(playa.EZarmor.Effects.thermalVision)then
                    for slot,slotInfo in pairs(playa.EZarmor.slots)do
                        local Info=JMod_ArmorTable[slot][slotInfo[1]]
                        if((Info.eff)and(table.HasValue(Info.eff,"thermalVision")))then
                            JMod_DamageArmor(playa,slot,.5)
                        end
                    end
                end
                JModEZarmorSync(playa)
            end
        end
    end
    ---
    if(NextSync<Time)then
        NextSync=Time+30
        net.Start("JMod_LuaConfigSync")
        net.WriteTable((JMOD_LUA_CONFIG and JMOD_LUA_CONFIG.ArmorOffsets) or {})
        net.Broadcast()
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

hook.Add("PlayerCanSeePlayersChat","JMOD_PLAYERSEECHAT",function(txt,teamOnly,listener,talker)
    if((talker.EZarmor)and(talker.EZarmor.Effects.teamComms))then
        return JMod_PlayersCanComm(listener,talker)
    end
end)

hook.Add("PlayerCanHearPlayersVoice","JMOD_PLAYERHEARVOICE",function(listener,talker)
    if((talker.EZarmor)and(talker.EZarmor.Effects.teamComms))then
        return JMod_PlayersCanComm(listener,talker)
    end
end)

