JMod.ArmorTableOffsetCache = {}
function JMod.CopyArmorTableForModel(plyMdl)
	JMod.ArmorTableOffsetCache = JMod.ArmorTableOffsetCache or {}
	-- Make a copy of the relevant parts of an armor table and store them.
	if plyMdl and JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets and JMod.LuaConfig.ArmorOffsets[plyMdl] then
		JMod.ArmorTableOffsetCache[plyMdl] = {}
		for k, v in pairs(JMod.LuaConfig.ArmorOffsets[plyMdl]) do
			JMod.ArmorTableOffsetCache[plyMdl][k] = table.Merge(table.FullCopy(JMod.ArmorTable[k]), v)
		end
	end
end

function JMod.CopyAllArmorOffsets()
	if JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets and JMod.LuaConfig.ArmorOffsets then
		for k, v in pairs(JMod.LuaConfig.ArmorOffsets) do
			JMod.CopyArmorTableForModel(k)
		end
	end
end

function JMod.ArmorPlayerModelDraw(ply, nomerge)
	if ply.EZarmor then
		if not ply.EZarmorModels then
			ply.EZarmorModels = {}
		end

		local Time = CurTime()

		if not JMod.ArmorTableOffsetCache or table.IsEmpty(JMod.ArmorTableOffsetCache) then
			JMod.CopyAllArmorOffsets()
		end

		local plyMdl = ply:GetModel()

		if not JMod.ArmorTableOffsetCache[plyMdl] then
			JMod.CopyArmorTableForModel(plyMdl)
		end

		local plyboneedit = {}

		for id, armorData in pairs(ply.EZarmor.items) do
			local ArmorInfo = JMod.ArmorTableOffsetCache[plyMdl] and JMod.ArmorTableOffsetCache[plyMdl][armorData.name] or JMod.ArmorTable[armorData.name]

			if not ArmorInfo then continue end
			if armorData.tgl and ArmorInfo.tgl then
				ArmorInfo = table.Merge(table.FullCopy(ArmorInfo), ArmorInfo.tgl)

				-- for some reason table.Merge doesn't copy empty tables
				for k, v in pairs(ArmorInfo.tgl) do
					if type(v) == "table" then
						if #table.GetKeys(v) == 0 then
							ArmorInfo[k] = {}
						end
					end
				end
			end

			if IsValid(ply.EZarmorModels[id]) then
				local Mdl = ply.EZarmorModels[id]
				local MdlName = string.lower(Mdl:GetModel())

				if MdlName == ArmorInfo.mdl and ArmorInfo.bon then
					-- render it
					local Index = ply:LookupBone(ArmorInfo.bon)

					if Index then
						local Matric = ply:GetBoneMatrix(Index)
						if Matric then
							local Pos, Ang = Matric:GetTranslation(), Matric:GetAngles()

							if Pos and Ang then
								if not(ArmorInfo.merge) or nomerge then
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
								else
									Mdl:SetupBones()
									for i = 0, Mdl:GetBoneCount() do
										Mdl:ManipulateBoneScale(i, ArmorInfo.siz)
									end
								end
								if ArmorInfo.bdg then
									for k, v in pairs(ArmorInfo.bdg) do
										Mdl:SetBodygroup(k, v)
									end
								end

								if ArmorInfo.skin then
									Mdl:SetSkin(ArmorInfo.skin)
								end

								local OldR, OldG, OldB = render.GetColorModulation()
								local Colr = armorData.col
								if (not(ArmorInfo.merge) or nomerge) then
									render.SetColorModulation(Colr.r / 255, Colr.g / 255, Colr.b / 255)
								else
									Mdl:SetColor(Color(Colr.r, Colr.g, Colr.b))
								end

								local NoDraw = hook.Run("JMod_ArmorModelDraw", ply, Mdl, armorData, ArmorInfo)

								if not(NoDraw) and (not(ArmorInfo.merge) or nomerge) then
									Mdl:DrawModel()
								end
								render.SetColorModulation(OldR, OldG, OldB)
							end
						end

						if ArmorInfo.bonsiz then
							ply.EZarmorboneedited = true
							plyboneedit[Index] = ArmorInfo.bonsiz
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
				Mdl:SetModel(ArmorInfo.mdl) -- Garrry!
				Mdl:SetMaterial(ArmorInfo.mat or "")
				Mdl:SetMoveType(MOVETYPE_NONE)
				if ArmorInfo.merge and not(nomerge) then
					Mdl:SetParent(ply, 0)
					Mdl:AddEffects(EF_BONEMERGE)
					Mdl:AddEffects(EF_BONEMERGE_FASTCULL)
					--Mdl:SetPredictable(true)
					--Mdl:FollowBone(ply, 0)
				else
					Mdl:SetPos(ply:GetPos())
					Mdl:SetParent(ply)
					Mdl:SetNoDraw(true)
				end
				ply.EZarmorModels[id] = Mdl
			end
		end
		if ply.EZarmorboneedited then
			local edited = false

			for k = 1, ply:GetBoneCount() do
				if ply:GetManipulateBoneScale(k) ~= (plyboneedit[k] or Vector(1, 1, 1)) then
					ply:ManipulateBoneScale(k, plyboneedit[k] or Vector(1, 1, 1))
				end

				if ply:GetManipulateBoneScale(k) ~= Vector(1, 1, 1) then
					edited = true
				end
			end

			if not edited then
				--print("JMOD: bones not edited")
				ply.EZarmorboneedited = false
			end
		end
	end
end

hook.Add("JMod_ArmorModelDraw", "JMod_NoDrawArmorSweps", function(ply, Mdl, ArmorData, ArmorInfo) 
	if ArmorInfo.eff and ArmorInfo.eff.weapon then
		if IsValid(ply) and ply:IsPlayer() then
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and (wep:GetClass() == ArmorInfo.eff.weapon) and not(IsValid(JMod.GetPlayerHeldEntity(ply))) then
				if ArmorInfo.merge then
					Mdl:SetNoDraw(true)
				else
					return true
				end
			elseif ArmorInfo.merge then
				Mdl:SetNoDraw(false)
			end
		end
	end
end)

hook.Add("PostPlayerDraw", "JMOD_ArmorPlayerDraw", function(ply)
	if not IsValid(ply) then return end
	JMod.ArmorPlayerModelDraw(ply)
end)

net.Receive("JMod_EZarmorSync", function()
	local ply = net.ReadEntity()
	local IsDamageUpdate = net.ReadBool()
	if IsDamageUpdate then
		local ArmorID = net.ReadString()
		local NewDurability = net.ReadFloat()
		if not ply.EZarmor then ply.EZarmor = table.FullCopy(JMod.DEFAULT_ARMOR) end
		for id, armorData in pairs(ply.EZarmor.items) do
			if ArmorID == id then
				armorData.dur = NewDurability
				return
			end
		end
	else
		ply.EZarmor = net.ReadTable()
	end

	if ply.EZarmorModels then
		for k, v in pairs(ply.EZarmorModels) do
			--if IsValid(v) then
				local NoMatch = true
				for id, armorData in pairs(ply.EZarmor.items) do
					if k == id then
						NoMatch = false 
						break
					end
				end
				if NoMatch then
					--print("Removing: ", v)
					v:Remove()
					v = nil
					ply.EZarmorModels[k] = nil
				end
			--else
			--	ply.EZarmorModels[k] = nil
			--end
		end
	end
	
	--PrintTable(ply.EZarmorModels)
	--PrintTable(ply.EZarmor)
end)

concommand.Add("jmod_debug_countclientsidemodels", function()
	print("Entity count : ")
	local entite = {}
	local i = 0

	for k, v in pairs(ents.FindByClass("*C_BaseFlex")) do
		if v:GetModel() == nil then continue end

		if entite[v:GetModel()] == nil then
			entite[v:GetModel()] = 0
		end

		entite[v:GetModel()] = entite[v:GetModel()] + 1
		i = i + 1
	end

	print(i)
	print("-")
	print("- CLIENTSIDE STUFF START :")
	print("-")

	for k, v in pairs(entite) do
		print(v .. " : " .. k)
	end

	print("-")
	print("- CLIENTSIDE STUFF END ...")
	print("-")
end, nil, "Poluxtobee's CS model debug")
