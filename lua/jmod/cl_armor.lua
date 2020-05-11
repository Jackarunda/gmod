local function CopyArmorTableToPlayer(ply)
    -- make a copy of the global armor spec table, personalize it, and store it on the player
    ply.JMod_ArmorTableCopy = table.FullCopy(JMod_ArmorTable)
    local plyMdl = ply:GetModel()

    if JMOD_LUA_CONFIG and JMOD_LUA_CONFIG.ArmorOffsets and JMOD_LUA_CONFIG.ArmorOffsets[plyMdl] then
        table.Merge(ply.JMod_ArmorTableCopy, JMOD_LUA_CONFIG.ArmorOffsets[plyMdl])
    end
end

local function JMOD_ArmorPlayerDraw(ply)
    if not (IsValid(ply)) then return end

    if ((ply.EZarmor) and (ply.EZarmorModels)) then
        local Time = CurTime()

        if (not (ply.JMod_ArmorTableCopy) or (ply.NextEZarmorTableCopy < Time)) then
            CopyArmorTableToPlayer(ply)
            ply.NextEZarmorTableCopy = Time + 30
        end

        for id, armorData in pairs(ply.EZarmor.items) do
            local ArmorInfo = table.Copy(ply.JMod_ArmorTableCopy[armorData.name])

            if armorData.disengaged then
                if ply.JMod_ArmorTableCopy[armorData.name].tglmod then
                    ArmorInfo = table.Merge(ArmorInfo, ply.JMod_ArmorTableCopy[armorData.name].tglmod)
                else
                    continue
                end
            end

            if (ply.EZarmorModels[id]) then
                local Mdl = ply.EZarmorModels[id]
                local MdlName = Mdl:GetModel()

                if (MdlName == ArmorInfo.mdl) then
                    -- render it
                    local Index = ply:LookupBone(ArmorInfo.bon)

                    if (Index) then
                        local Pos, Ang = ply:GetBonePosition(Index)

                        if ((Pos) and (Ang)) then
                            local Right, Forward, Up = Ang:Right(), Ang:Forward(), Ang:Up()
                            Pos = Pos + Right * ArmorInfo.pos.x + Forward * ArmorInfo.pos.y + Up * ArmorInfo.pos.z
                            Ang:RotateAroundAxis(Right, ArmorInfo.ang.p)
                            Ang:RotateAroundAxis(Up, ArmorInfo.ang.y)
                            Ang:RotateAroundAxis(Forward, ArmorInfo.ang.r)
                            Mdl:SetRenderOrigin(Pos)
                            Mdl:SetRenderAngles(Ang)
                            local Mat = Matrix()
                            Mat:Scale(ArmorInfo.siz)
                            Mdl:EnableMatrix("RenderMultiply", Mat)
                            local OldR, OldG, OldB = render.GetColorModulation()
                            local Colr = armorData.col
                            render.SetColorModulation(Colr.r / 255, Colr.g / 255, Colr.b / 255)
                            Mdl:DrawModel()
                            render.SetColorModulation(OldR, OldG, OldB)
                        end
                    end
                else
                    -- remove it
                    ply.EZarmorModels[id]:Remove()
                    ply.EZarmorModels[id] = nil
                end
            else
                -- create it
                local Mdl = ClientsideModel(ArmorInfo.mdl)
                Mdl:SetModel(ArmorInfo.mdl) -- what the FUCK garry
                Mdl:SetPos(ply:GetPos())
                Mdl:SetMaterial(ArmorInfo.mat or "")
                Mdl:SetParent(ply)
                Mdl:SetNoDraw(true)
                for k, v in pairs(ArmorInfo.bdg or {}) do
                    Mdl:SetBodygroup(k, v)
                end
                ply.EZarmorModels[id] = Mdl
            end
        end
    end
end

hook.Add("PostPlayerDraw", "JMOD_ArmorPlayerDraw", JMOD_ArmorPlayerDraw)

net.Receive("JMod_EZarmorSync", function()
    local ply = net.ReadEntity()
    local tbl = net.ReadTable()
    if not (IsValid(ply)) then return end
    ply.EZarmor = tbl
    if ply.EZarmorModels then for _, v in pairs(ply.EZarmorModels) do v:Remove() end end
    ply.EZarmorModels = {}
end)