local function CopyArmorTableToPlayer(ply)
	-- make a copy of the global armor spec table, personalize it, and store it on the player
	ply.JMod_ArmorTableCopy=table.FullCopy(JMod_ArmorTable)
	local plyMdl=ply:GetModel()
	if JMOD_LUA_CONFIG and JMOD_LUA_CONFIG.ArmorOffsets and JMOD_LUA_CONFIG.ArmorOffsets[plyMdl] then
		table.Merge(ply.JMod_ArmorTableCopy,JMOD_LUA_CONFIG.ArmorOffsets[plyMdl])
	end
end
function JMod_ArmorPlayerModelDraw(mdl)
	if(mdl.EZarmor)then
		if not(mdl.EZarmorModels)then mdl.EZarmorModels={} end
		local Time=CurTime()
		if(not(mdl.JMod_ArmorTableCopy)or(mdl.NextEZarmorTableCopy<Time))then
			CopyArmorTableToPlayer(mdl)
			mdl.NextEZarmorTableCopy=Time+30
		end
		for id,armorData in pairs(mdl.EZarmor.items)do
			local ArmorInfo=mdl.JMod_ArmorTableCopy[armorData.name]
			if((armorData.tgl)and(ArmorInfo.tgl))then
				ArmorInfo=table.Merge(table.FullCopy(ArmorInfo),ArmorInfo.tgl)
			end
			if(mdl.EZarmorModels[id])then
				local Mdl=mdl.EZarmorModels[id]
				local MdlName=Mdl:GetModel()
				if(MdlName==ArmorInfo.mdl)then
					-- render it
					local Index=mdl:LookupBone(ArmorInfo.bon)
					if(Index)then
						local Pos,Ang=mdl:GetBonePosition(Index)
						if((Pos)and(Ang))then
							local Right,Forward,Up=Ang:Right(),Ang:Forward(),Ang:Up()
							Pos=Pos+Right*ArmorInfo.pos.x+Forward*ArmorInfo.pos.y+Up*ArmorInfo.pos.z
							Ang:RotateAroundAxis(Right,ArmorInfo.ang.p)
							Ang:RotateAroundAxis(Up,ArmorInfo.ang.y)
							Ang:RotateAroundAxis(Forward,ArmorInfo.ang.r)
							Mdl:SetRenderOrigin(Pos)
							Mdl:SetRenderAngles(Ang)
							local Mat=Matrix()
							Mat:Scale(ArmorInfo.siz)
							Mdl:EnableMatrix("RenderMultiply",Mat)
							local OldR,OldG,OldB=render.GetColorModulation()
							local Colr=armorData.col
							render.SetColorModulation(Colr.r/255,Colr.g/255,Colr.b/255)
							Mdl:DrawModel()
							render.SetColorModulation(OldR,OldG,OldB)
						end
					end
				else
					-- remove it
					mdl.EZarmorModels[id]:Remove()
					mdl.EZarmorModels[id]=nil
				end
			else
				-- create it
				local Mdl=ClientsideModel(ArmorInfo.mdl)
				Mdl:SetModel(ArmorInfo.mdl) -- what the FUCK garry
				Mdl:SetPos(mdl:GetPos())
				Mdl:SetMaterial(ArmorInfo.mat or "")
				Mdl:SetParent(mdl)
				Mdl:SetNoDraw(true)
				mdl.EZarmorModels[id]=Mdl
			end
		end
	end
end
hook.Add("PostPlayerDraw","JMOD_ArmorPlayerDraw",function(ply)
	if not(IsValid(ply))then return end
	JMod_ArmorPlayerModelDraw(ply)
end)
net.Receive("JMod_EZarmorSync",function()
	local ply=net.ReadEntity()
	ply.EZarmor=net.ReadTable()
end)