function JModEZarmorSync(ply)
    if not(ply.EZarmor)then return end
    ply.EZarmor.Effects={}
    for slot,info in pairs(ply.EZarmor.slots)do
        local Disabled=false
        if((slot=="Ears")and not(ply.EZarmor.headsetOn))then Disabled=true end
        if((slot=="Face")and not(ply.EZarmor.maskOn))then Disabled=true end
        if not(Disabled)then
            local Info=JMod_ArmorTable[slot][info[1]]
            if(Info.eff)then
                for k,eff in pairs(Info.eff)do
                    ply.EZarmor.Effects[eff]=true
                end
            end
        end
    end
    net.Start("JMod_EZarmorSync")
        net.WriteEntity(ply)
        net.WriteTable(ply.EZarmor)
    net.Broadcast()
end

local MaxArmorProtection={
    [DMG_BULLET]=.9,[DMG_BLAST]=.9,[DMG_CLUB]=.9,[DMG_SLASH]=.9,[DMG_BURN]=.5,[DMG_CRUSH]=.6,[DMG_VEHICLE]=.4
}
function JMod_DamageArmor(ply,slot,amt)
    local ArmorInfo=ply.EZarmor.slots[slot]
    local Name,Dur=ArmorInfo[1],ArmorInfo[2]
    local Specs=JMod_ArmorTable[slot][Name]
    local ShouldWarn50=Dur>Specs.dur*.5
    ArmorInfo[2]=Dur-amt*math.Rand(1.2,1.5)*JMOD_CONFIG.ArmorDegredationMult -- degredation
    if(ArmorInfo[2]<=0)then
        ply:PrintMessage(HUD_PRINTCENTER,slot.." armor destroyed")
        JMod_RemoveArmorSlot(ply,slot,true)
        JModEZarmorSync(ply)
    elseif((ArmorInfo[2]<=Specs.dur*.5)and(ShouldWarn50))then
        ply:PrintMessage(HUD_PRINTCENTER,slot.." armor at 50%")
        JModEZarmorSync(ply)
    end
    JMod_Hint(ply, "armor durability")
end
local function EZgetProtectionFromSlot(ply,slot,amt,typ)
    local ArmorInfo=ply.EZarmor.slots[slot]
    if not(ArmorInfo)then return 0 end
    if((slot=="Face")and not(ply.EZarmor.maskOn))then return 0 end
    if((slot=="Ears")and not(ply.EZarmor.headsetOn))then return 0 end
    local Specs=JMod_ArmorTable[slot][ArmorInfo[1]]
    JMod_DamageArmor(ply,slot,amt)
    return Specs.def or 0
end
local function EZarmorScaleDmg(ply,dmgtype,dmgamt,location,isFace)
    local Block=0
    if(location==HITGROUP_HEAD)then
        if(isFace)then
            Block=Block+EZgetProtectionFromSlot(ply,"Face",dmgamt,dmgtype)
        else
            Block=Block+EZgetProtectionFromSlot(ply,"Head",dmgamt)
        end
    elseif(location==HITGROUP_CHEST)then
        Block=Block+EZgetProtectionFromSlot(ply,"Torso",dmgamt*.67)
        Block=Block+EZgetProtectionFromSlot(ply,"Pelvis",dmgamt*.33)
    elseif(location==HITGROUP_LEFTARM)then
        Block=Block+EZgetProtectionFromSlot(ply,"LeftShoulder",dmgamt*.6)
        Block=Block+EZgetProtectionFromSlot(ply,"LeftForearm",dmgamt*.4)
    elseif(location==HITGROUP_RIGHTARM)then
        Block=Block+EZgetProtectionFromSlot(ply,"RightShoulder",dmgamt*.6)
        Block=Block+EZgetProtectionFromSlot(ply,"RightForearm",dmgamt*.4)
    elseif(location==HITGROUP_LEFTLEG)then
        Block=Block+EZgetProtectionFromSlot(ply,"LeftThigh",dmgamt*.6)
        Block=Block+EZgetProtectionFromSlot(ply,"LeftCalf",dmgamt*.4)
    elseif(location==HITGROUP_RIGHTLEG)then
        Block=Block+EZgetProtectionFromSlot(ply,"RightThigh",dmgamt*.6)
        Block=Block+EZgetProtectionFromSlot(ply,"RightCalf",dmgamt*.4)
    elseif(location==HITGROUP_GENERIC)then
        Block=Block+EZgetProtectionFromSlot(ply,"Face",dmgamt*.05)*.15
        Block=Block+EZgetProtectionFromSlot(ply,"Head",dmgamt*.1)*.15
        Block=Block+EZgetProtectionFromSlot(ply,"Torso",dmgamt*.15)*.2
        Block=Block+EZgetProtectionFromSlot(ply,"Pelvis",dmgamt*.1)*.1
        Block=Block+EZgetProtectionFromSlot(ply,"LeftShoulder",dmgamt*.1)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"LeftForearm",dmgamt*.05)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"RightShoulder",dmgamt*.1)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"RightForearm",dmgamt*.05)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"LeftThigh",dmgamt*.1)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"LeftCalf",dmgamt*.05)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"RightThigh",dmgamt*.1)*.05
        Block=Block+EZgetProtectionFromSlot(ply,"RightCalf",dmgamt*.05)*.05
    end
    return 1-((Block/100)*(MaxArmorProtection[dmgtype]))
end
local function EZspecialScaleDamage(ply,dmgtype,dmgamt)
    local Block=0
    for slot,info in pairs(ply.EZarmor.slots)do
        if(info)then
            if((slot=="Face")and not(ply.EZarmor.maskOn))then return 1 end
            if((slot=="Ears")and not(ply.EZarmor.headsetOn))then return 1 end
            local Name,Dur,Col=info[1],info[2],info[3]
            local Specs=JMod_ArmorTable[slot][Name]
            local ShouldWarn50,ShouldWarn10=Dur>Specs.dur*.5,Dur>Specs.dur*.1
            if(Specs.spcdef)then
                for typ,amt in pairs(Specs.spcdef)do
                    if(typ==dmgtype)then
                        Block=Block+amt
                        info[2]=Dur-amt*dmgamt*math.Rand(.0004,.0006)*JMOD_CONFIG.ArmorDegredationMult -- degredation
                        if(info[2]<=0)then
                            ply:PrintMessage(HUD_PRINTCENTER,Name.." destroyed")
                            JMod_RemoveArmorSlot(ply,slot,true)
                            JModEZarmorSync(ply)
                        elseif((info[2]<=Specs.dur*.5)and(ShouldWarn50))then
                            ply:PrintMessage(HUD_PRINTCENTER,Name.." at 50% durability")
                            JModEZarmorSync(ply)
                        elseif((info[2]<=Specs.dur*.1)and(ShouldWarn10))then
                            ply:PrintMessage(HUD_PRINTCENTER,Name.." at 10% durability")
                            JModEZarmorSync(ply)
                        end
                    end
                end
            end
        end
    end
    Block=math.Clamp(Block,0,100)
    return 1-Block/100
end
local function JackyDamageHandling(victim,hitgroup,dmginfo)
    if(victim.EZarmor)then
        local Mul,dmg,ply,amt=1,dmginfo,victim,dmginfo:GetDamage()
        if((dmg:IsDamageType(DMG_BULLET))or(dmg:IsDamageType(DMG_BUCKSHOT)))then
            if(hitgroup==HITGROUP_HEAD)then
                local ApproachVec=dmginfo:GetDamageForce():GetNormalized()
                local FacingVec=ply:GetAimVector()
                local DotProduct=FacingVec:DotProduct(ApproachVec)
                local ApproachAngle=(-math.deg(math.asin(DotProduct))+90)
                Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_HEAD,ApproachAngle>=135)
            elseif((hitgroup==HITGROUP_CHEST)or(hitgroup==HITGROUP_STOMACH))then
                Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_CHEST)
            elseif(hitgroup==HITGROUP_LEFTARM)then
                Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_LEFTARM)
            elseif(hitgroup==HITGROUP_RIGHTARM)then
                Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_RIGHTARM)
            elseif(hitgroup==HITGROUP_LEFTLEG)then
                Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_LEFTLEG)
            elseif(hitgroup==HITGROUP_RIGHTLEG)then
                Mul=EZarmorScaleDmg(ply,DMG_BULLET,amt,HITGROUP_RIGHTLEG)
            end
        elseif(dmginfo:IsDamageType(DMG_BLAST))then
            Mul=EZarmorScaleDmg(ply,DMG_BLAST,amt,HITGROUP_GENERIC)
        elseif(dmginfo:IsDamageType(DMG_SLASH))then
            Mul=EZarmorScaleDmg(ply,DMG_SLASH,amt,HITGROUP_GENERIC)
        elseif(dmginfo:IsDamageType(DMG_CLUB))then
            Mul=EZarmorScaleDmg(ply,DMG_CLUB,amt,HITGROUP_GENERIC)
        elseif(dmginfo:IsDamageType(DMG_CRUSH))then
            Mul=EZarmorScaleDmg(ply,DMG_CRUSH,amt,HITGROUP_GENERIC)
        elseif(dmginfo:IsDamageType(DMG_VEHICLE))then
            Mul=EZarmorScaleDmg(ply,DMG_VEHICLE,amt,HITGROUP_GENERIC)
        elseif(dmginfo:IsDamageType(DMG_BURN))then
            Mul=EZarmorScaleDmg(ply,DMG_BURN,amt,HITGROUP_GENERIC)
        else
            if(dmginfo:IsDamageType(DMG_NERVEGAS))then
                Mul=EZspecialScaleDamage(ply,DMG_NERVEGAS,amt)
            elseif(dmginfo:IsDamageType(DMG_RADIATION))then
                Mul=EZspecialScaleDamage(ply,DMG_RADIATION,amt)
            end
        end
        local Reduction=1-Mul
        Reduction=Reduction^(.7*JMOD_CONFIG.ArmorExponentMult)
        Mul=1-Reduction
        dmginfo:ScaleDamage(Mul)
    end
end

local function JackaScaleDamageHook(victim,hitgroup,dmginfo)
    JackyDamageHandling(victim,hitgroup,dmginfo)
end
hook.Add("ScalePlayerDamage","JMod_ScaleDamageHook",JackaScaleDamageHook)

local function JackaDamageHook(victim,dmginfo)
    if(victim:IsPlayer())then
        JackyDamageHandling(victim,HITGROUP_GENERIC,dmginfo)
    end
end
hook.Add("EntityTakeDamage","JMod_DamageHook",JackaDamageHook)

local function EZgetWeightFromSlot(ply,slot)
    local ArmorInfo=ply.EZarmor.slots[slot]
    if not(ArmorInfo)then return 0 end
    local Name,Dur=ArmorInfo[1],ArmorInfo[2]
    local Specs=JMod_ArmorTable[slot][Name]
    return Specs.wgt or 0
end

local function CalcSpeed(ply)
    local Walk,Run,TotalWeight=ply.EZoriginalWalkSpeed or 200,ply.EZoriginalRunSpeed or 400,0
    for k,v in pairs(JMod_ArmorTable)do
        TotalWeight=TotalWeight+EZgetWeightFromSlot(ply,k)
    end
    local WeighedFrac=TotalWeight/225
    ply.EZarmor.speedfrac=math.Clamp(1-(.8*WeighedFrac*JMOD_CONFIG.ArmorWeightMult),.05,1)
    -- Handled in SetupMove hook
    --ply:SetWalkSpeed(Walk*(1-.8*WeighedFrac))
    --ply:SetRunSpeed(Run*(1-.8*WeighedFrac))
end

local EquipSounds={"snd_jack_clothequip.wav","snds_jack_gmod/equip1.wav","snds_jack_gmod/equip2.wav","snds_jack_gmod/equip3.wav","snds_jack_gmod/equip4.wav","snds_jack_gmod/equip5.wav"}
function JMod_RemoveArmorSlot(ply,slot,broken)
    local Info=ply.EZarmor.slots[slot]
    if not(Info)then return end
    local Specs=JMod_ArmorTable[slot][Info[1]]
    timer.Simple(math.Rand(0,.5),function()
        if(broken)then
            ply:EmitSound("snds_jack_gmod/armorbreak.wav",60,math.random(80,120))
        else
            ply:EmitSound(table.Random(EquipSounds),60,math.random(80,120))
        end
    end)
    if not(broken)then
        local Ent=ents.Create(Specs.ent)
        Ent:SetPos(ply:GetShootPos()+ply:GetAimVector()*30+VectorRand()*math.random(1,20))
        Ent:SetAngles(AngleRand())
        Ent.Durability=Info[2]
        Ent:SetColor(Info[3])
        Ent:Spawn()
        Ent:Activate()
        Ent:GetPhysicsObject():SetVelocity(ply:GetVelocity())
    end
    ply.EZarmor.slots[slot]=nil
end

function JMod_EZ_Equip_Armor(ply,ent)
    if not(IsValid(ent))then return end
    --[[ -- this isn't needed anymore since we're using SetupMove
    if(not(ply.EZarmor)or not(#table.GetKeys(ply.EZarmor)>0))then
        ply.EZoriginalWalkSpeed=ply:GetWalkSpeed()
        ply.EZoriginalRunSpeed=ply:GetRunSpeed()
    end
    --]]
    JMod_RemoveArmorSlot(ply,ent.Slot)
    ply.EZarmor.slots[ent.Slot]={ent.ArmorName,ent.Durability,ent:GetColor()}
    ply:EmitSound(table.Random(EquipSounds),60,math.random(80,120))
    
    if ent.Slot == "Face" then
        JMod_Hint(ply, "armor mask")
    elseif ent.ArmorName == "Headset" then
        JMod_Hint(ply, "armor headset")
    else
        if not JMod_Hint(ply, "armor drop") and JMod_ArmorTable[ent.Slot][ent.ArmorName].wgt >= 15 then
            JMod_Hint(ply, "armor weight")
        end
    end
    
    ent:Remove()
    CalcSpeed(ply)
    JModEZarmorSync(ply)
end

function JMod_EZ_Remove_Armor(ply)
    for k,v in pairs(JMod_ArmorTable)do
        JMod_RemoveArmorSlot(ply,k)
    end
    CalcSpeed(ply)
    JModEZarmorSync(ply)
end
