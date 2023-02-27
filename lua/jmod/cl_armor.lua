function JMod.CopyArmorTableToPlayer(ply)
	-- make a copy of the global armor spec table, personalize it, and store it on the player
	ply.JMod_ArmorTableCopy = table.FullCopy(JMod.ArmorTable)
	local plyMdl = ply:GetModel()

	if JMod.LuaConfig and JMod.LuaConfig.ArmorOffsets and JMod.LuaConfig.ArmorOffsets[plyMdl] then
		table.Merge(ply.JMod_ArmorTableCopy, JMod.LuaConfig.ArmorOffsets[plyMdl])
	end
end

function JMod.ArmorPlayerModelDraw(ply)
	if ply.EZarmor then
		if not ply.EZarmorModels then
			ply.EZarmorModels = {}
		end

		local Time = CurTime()

		if not ply.JMod_ArmorTableCopy or ((ply.NextEZarmorTableCopy or 0) < Time) then
			JMod.CopyArmorTableToPlayer(ply)
			ply.NextEZarmorTableCopy = Time + 30
		end

		local plyboneedit = {}

		for id, armorData in pairs(ply.EZarmor.items) do
			local ArmorInfo = ply.JMod_ArmorTableCopy[armorData.name]

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
						local Pos, Ang = ply:GetBonePosition(Index)

						if Pos and Ang then
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

							if ArmorInfo.bdg then
								for k, v in pairs(ArmorInfo.bdg) do
									Mdl:SetBodygroup(k, v)
								end
							end

							if ArmorInfo.skin then
								Mdl:SetSkin(ArmorInfo.skin)
							end

							Mdl:DrawModel()
							render.SetColorModulation(OldR, OldG, OldB)
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
				Mdl:SetPos(ply:GetPos())
				Mdl:SetMaterial(ArmorInfo.mat or "")
				Mdl:SetParent(ply)
				Mdl:SetNoDraw(true)
				--Mdl.JModCSModel = true -- doesn't seem to be working though
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
				print("not edited")
				ply.EZarmorboneedited = false
			end
		end
	end
end

hook.Add("PostPlayerDraw", "JMOD_ArmorPlayerDraw", function(ply)
	if not IsValid(ply) then return end
	JMod.ArmorPlayerModelDraw(ply)
end)

net.Receive("JMod_EZarmorSync", function()
	local ply = net.ReadEntity()
	ply.EZarmor = net.ReadTable()

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
