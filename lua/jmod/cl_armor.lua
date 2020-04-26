local function CopyArmorTableToPlayer(ply)
    -- make a copy of the global armor spec table, personalize it, and store it on the player
    ply.JMod_ArmorTableCopy=table.FullCopy(JMod_ArmorTable)
    local plyMdl=ply:GetModel()
    if JMOD_LUA_CONFIG and JMOD_LUA_CONFIG.ArmorOffsets and JMOD_LUA_CONFIG.ArmorOffsets[plyMdl] then
        table.Merge(ply.JMod_ArmorTableCopy,JMOD_LUA_CONFIG.ArmorOffsets[plyMdl])
    end
end

local EZarmorBoneTable={
    Torso="ValveBiped.Bip01_Spine2",
    Head="ValveBiped.Bip01_Head1",
    Ears="ValveBiped.Bip01_Head1",
    LeftShoulder="ValveBiped.Bip01_L_UpperArm",
    RightShoulder="ValveBiped.Bip01_R_UpperArm",
    LeftForearm="ValveBiped.Bip01_L_Forearm",
    RightForearm="ValveBiped.Bip01_R_Forearm",
    LeftThigh="ValveBiped.Bip01_L_Thigh",
    RightThigh="ValveBiped.Bip01_R_Thigh",
    LeftCalf="ValveBiped.Bip01_L_Calf",
    RightCalf="ValveBiped.Bip01_R_Calf",
    Pelvis="ValveBiped.Bip01_Pelvis",
    Face="ValveBiped.Bip01_Head1"
}
local function JMOD_ArmorPlayerDraw(ply)
    if not(IsValid(ply))then return end
    if((ply.EZarmor)and(ply.EZarmorModels))then
        local Time=CurTime()
        if(not(ply.JMod_ArmorTableCopy)or(ply.NextEZarmorTableCopy<Time))then
            CopyArmorTableToPlayer(ply)
            ply.NextEZarmorTableCopy=Time+1--30
        end
        for slot,info in pairs(ply.EZarmor.slots)do
            local Name,Durability,Colr,Render=info[1],info[2],info[3],true
            if((slot=="Face")and not(ply.EZarmor.maskOn))then Render=false end
            if((slot=="Ears")and not(ply.EZarmor.headsetOn))then Render=false end
            local Specs,plyMdl=ply.JMod_ArmorTableCopy[slot][Name],ply:GetModel()
            
            if(Render)then
                if(ply.EZarmorModels[slot])then
                    local Mdl=ply.EZarmorModels[slot]
                    local MdlName=Mdl:GetModel()
                    if(MdlName==Specs.mdl)then
                        -- render it
                        local Index=ply:LookupBone(EZarmorBoneTable[slot])
                        if(Index)then
                            local Pos,Ang=ply:GetBonePosition(Index)
                            if((Pos)and(Ang))then
                                local Right,Forward,Up=Ang:Right(),Ang:Forward(),Ang:Up()
                                Pos=Pos+Right*Specs.pos.x+Forward*Specs.pos.y+Up*Specs.pos.z
                                Ang:RotateAroundAxis(Right,Specs.ang.p)
                                Ang:RotateAroundAxis(Up,Specs.ang.y)
                                Ang:RotateAroundAxis(Forward,Specs.ang.r)
                                Mdl:SetRenderOrigin(Pos)
                                Mdl:SetRenderAngles(Ang)
                                local Mat=Matrix()
                                Mat:Scale(Specs.siz)
                                Mdl:EnableMatrix("RenderMultiply",Mat)
                                local OldR,OldG,OldB=render.GetColorModulation()
                                render.SetColorModulation(Colr.r/255,Colr.g/255,Colr.b/255)
                                Mdl:DrawModel()
                                render.SetColorModulation(OldR,OldG,OldB)
                            end
                        end
                    else
                        -- remove it
                        ply.EZarmorModels[slot]:Remove()
                        ply.EZarmorModels[slot]=nil
                    end
                else
                    -- create it
                    local Mdl=ClientsideModel(Specs.mdl)
                    Mdl:SetModel(Specs.mdl) -- what the FUCK garry
                    Mdl:SetPos(ply:GetPos())
                    Mdl:SetMaterial(Specs.mat or "")
                    Mdl:SetParent(ply)
                    Mdl:SetNoDraw(true)
                    ply.EZarmorModels[slot]=Mdl
                end
            end
        end
    end
end
hook.Add("PostPlayerDraw","JMOD_ArmorPlayerDraw",JMOD_ArmorPlayerDraw)
