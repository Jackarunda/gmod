util.AddNetworkString("JMod_Friends") -- ^:3
util.AddNetworkString("JMod_MineColor")
util.AddNetworkString("JMod_EZbuildKit")
util.AddNetworkString("JMod_EZworkbench")
util.AddNetworkString("JMod_Hint")
util.AddNetworkString("JMod_EZtimeBomb")
util.AddNetworkString("JMod_UniCrate")
util.AddNetworkString("JMod_LuaConfigSync")
util.AddNetworkString("JMod_PlayerSpawn")
util.AddNetworkString("JMod_SignalNade")
util.AddNetworkString("JMod_ModifyMachine")
util.AddNetworkString("JMod_NuclearBlast")
util.AddNetworkString("JMod_ArmorColor")
util.AddNetworkString("JMod_EZarmorSync")
util.AddNetworkString("JMod_EZradio")

net.Receive("JMod_Friends",function(length,ply)
    local List,Good=net.ReadTable(),true
    for k,v in pairs(List)do
        if not((IsValid(v))and(v:IsPlayer()))then Good=false end
    end
    if(Good)then
        ply.JModFriends=List
        ply:PrintMessage(HUD_PRINTCENTER,"JMod EZ friends list updated")
        net.Start("JMod_Friends")
        net.WriteBit(true)
        net.WriteEntity(ply)
        net.WriteTable(List)
        net.Broadcast()
    else
        ply.JModFriends={}
    end
end)

net.Receive("JMod_MineColor",function(ln,ply)
    if not((IsValid(ply))and(ply:Alive()))then return end
    local Mine=net.ReadEntity()
    local Col=net.ReadColor()
    local Arm=tobool(net.ReadBit())
    if not(IsValid(Mine))then return end
    Mine:SetColor(Col)
    if(Arm)then Mine:Arm(ply) end
end)

net.Receive("JMod_ArmorColor",function(ln,ply)
    if not((IsValid(ply))and(ply:Alive()))then return end
    local Armor=net.ReadEntity()
    local Col=net.ReadColor()
    local Equip=tobool(net.ReadBit())
    if not(IsValid(Armor))then return end
    Armor:SetColor(Col)
    if(Equip)then JMod_EZ_Equip_Armor(ply,Armor) end
end)

net.Receive("JMod_SignalNade",function(ln,ply)
    if not((IsValid(ply))and(ply:Alive()))then return end
    local Nade=net.ReadEntity()
    local Col=net.ReadColor()
    local Arm=tobool(net.ReadBit())
    if not(IsValid(Nade))then return end
    Nade:SetColor(Col)
    if(Arm)then Nade:Prime() end
end)

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
        ent.DisarmNeeded=math.Round(math.min(tim,600)/4)
        ent:NextThink(CurTime()+1)
        ent:SetState(1)
        ent:EmitSound("weapons/c4/c4_plant.wav",60,120)
        ent:EmitSound("snd_jack_minearm.wav",60,100)
    end
end)

net.Receive("JMod_UniCrate",function(ln,ply)
    local box=net.ReadEntity()
    local class=net.ReadString()
    if !IsValid(box) or (box:GetPos() - ply:GetPos()):Length()>100 or not box.Items[class] or box.Items[class][1] <= 0 then return end
    local ent=ents.Create(class)
    ent:SetPos(box:GetPos())
    ent:SetAngles(box:GetAngles())
    ent:Spawn()
    ent:Activate()
    timer.Simple(0.01, function() ply:PickupObject(ent) end)
    box:SetItemCount(box:GetItemCount() - box.Items[class][2])
    box.Items[class] = box.Items[class][1] > 1 and {(box.Items[class][1] - 1), box.Items[class][2]} or nil
    box.NextLoad = CurTime() + 2
    box:EmitSound("Ammo_Crate.Close")
    box:CalcWeight()
end)

net.Receive("JMod_ModifyMachine",function(ln,ply)
    if not(ply:Alive())then return end
    local AmmoType=nil
    local Ent,Tbl,HasAmmoType=net.ReadEntity(),net.ReadTable(),tobool(net.ReadBit())
    if(HasAmmoType)then AmmoType=net.ReadString() end
    if not(IsValid(Ent))then return end
    if not(Ent:GetPos():Distance(ply:GetPos())<200)then return end
    local Wepolini=ply:GetActiveWeapon()
    if not((Wepolini)and(Wepolini.ModifyMachine))then return end
    Wepolini:ModifyMachine(Ent,Tbl,AmmoType)
end)