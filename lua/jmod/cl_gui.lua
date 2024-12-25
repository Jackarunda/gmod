local FriendMenuOpen = false
local CurrentSelectionMenu = nil
local YesMat = Material("icon16/accept.png")
local NoMat = Material("icon16/cancel.png")
local FavMat = Material("icon16/star.png")
local FriendMat = Material("icon16/user_green.png")
local NotFriendMat = Material("icon16/user_red.png")

-- this is here for caching common colors used in paint functions
local TextColors = {
	ButtonText = Color(255, 255, 255, 100),
	ButtonTextBright = Color(255, 255, 255, 255),
	ButtonTextDark = Color(0, 0, 0, 255),
	DescText = Color(255, 255, 255, 200),
}

local SpecialIcons = {
	["geothermal"] = Material("ez_resource_icons/geothermal.png"),
	["warning"] = Material("ez_misc_icons/warning.png")
}

local RankIcons = {Material("ez_rank_icons/grade_1.png"), Material("ez_rank_icons/grade_2.png"), Material("ez_rank_icons/grade_3.png"), Material("ez_rank_icons/grade_4.png"), Material("ez_rank_icons/grade_5.png")}

JMod.SelectionMenuIcons = {}
local LocallyAvailableResources = nil -- this is here solely for caching and efficieny purposes, I sure hope it doesn't bite me in the ass
local QuestionMarkIcon = Material("question_mark.png")

local JModIcon, JModLegacyIcon = "jmod_icon", "jmod_icon_legacy.png"
list.Set("ContentCategoryIcons", "JMod - EZ Armor", JModIcon.."_armor.png" )
list.Set("ContentCategoryIcons", "JMod - EZ Explosives", JModIcon.."_explosives.png" )
list.Set("ContentCategoryIcons", "JMod - EZ Machines", JModIcon.."_machines.png" )
list.Set("ContentCategoryIcons", "JMod - EZ Misc.", JModIcon..".png" )
list.Set("ContentCategoryIcons", "JMod - EZ Resources", JModIcon.."_resources.png" )
list.Set("ContentCategoryIcons", "JMod - EZ Special Ammo", JModIcon.."_specialammo.png" )
list.Set("ContentCategoryIcons", "JMod - EZ Weapons", JModIcon.."_weapons.png" )
--
list.Set("ContentCategoryIcons", "JMod - LEGACY Armor", JModLegacyIcon )
list.Set("ContentCategoryIcons", "JMod - LEGACY Explosives", JModLegacyIcon )
list.Set("ContentCategoryIcons", "JMod - LEGACY Sentries", JModLegacyIcon )
list.Set("ContentCategoryIcons", "JMod - LEGACY Misc.", JModLegacyIcon )
list.Set("ContentCategoryIcons", "JMod - LEGACY NPCs", JModLegacyIcon )
list.Set("ContentCategoryIcons", "JMod - LEGACY Weapons", JModLegacyIcon )

local BlurryMenus = CreateClientConVar("jmod_cl_blurry_menus", "1", true)
local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local function BlurBackground(panel)
	if not (IsValid(panel) and panel:IsVisible()) then return end
	local layers, density, alpha = 1, 1, 255
	local x, y = panel:LocalToScreen(0, 0)
	local FrameRate, Num, Dark = 1 / FrameTime(), 5, 150

	if BlurryMenus:GetBool() then
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.SetMaterial(blurMat)

		for i = 1, Num do
			blurMat:SetFloat("$blur", (i / layers) * density * Dynamic)
			blurMat:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
		end

		surface.SetDrawColor(0, 0, 0, Dark * Dynamic)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
		Dynamic = math.Clamp(Dynamic + (1 / FrameRate) * 7, 0, 1)
	else
		surface.SetDrawColor(0, 0, 0, 180)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	end
end

local function PopulateFriendList(parent, friendList, myself, W, H)
	parent:Clear()
	local Y = 0

	for k, playa in player.Iterator() do
		if playa ~= myself then
			playa.JModFriends = playa.JModFriends or {}
			local IsFriendBool = table.HasValue(playa.JModFriends, myself)
			local Panel = parent:Add("DPanel")
			Panel:SetSize(W - 35, 20)
			Panel:SetPos(0, Y)

			function Panel:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(0, 0, w, h)
				draw.SimpleText((playa:IsValid() and playa:Nick()) or "DISCONNECTED", "DermaDefault", 5, 3, TextColors.ButtonTextBright, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end

			local Buttaloney = vgui.Create("DButton", Panel)
			Buttaloney:SetPos(Panel:GetWide() - 25, 0)
			Buttaloney:SetSize(20, 20)
			Buttaloney:SetText("")
			local InLikeFlynn = table.HasValue(friendList, playa)

			function Buttaloney:Paint(w, h)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial((InLikeFlynn and YesMat) or NoMat)
				surface.DrawTexturedRect(2, 2, 16, 16)
			end

			function Buttaloney:DoClick()
				surface.PlaySound("garrysmod/ui_click.wav")

				if InLikeFlynn then
					table.RemoveByValue(friendList, playa)
				else
					table.insert(friendList, playa)
				end

				PopulateFriendList(parent, friendList, myself, W, H)
			end

			local IsFriendIcon = vgui.Create("DSprite", Panel)
			IsFriendIcon:SetPos(Panel:GetWide() - 50, 0)
			IsFriendIcon:SetSize(20, 20)
			IsFriendIcon:SetText("")

			function IsFriendIcon:Paint(w, h)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial((IsFriendBool and FriendMat) or NotFriendMat)
				surface.DrawTexturedRect(2, 2, 16, 16)
			end

			Y = Y + 25
		end
	end
end

function JMod.StandardResourceDisplay(typ, amt, maximum, x, y, siz, vertical, font, opacity, rateDisplay, brite)
	font = font or "JMod-Stencil"
	opacity = opacity or 150
	brite = brite or 200
	surface.SetDrawColor(255, 255, 255, opacity)
	surface.SetMaterial(JMod.EZ_RESOURCE_TYPE_ICONS[typ] or SpecialIcons[typ])
	surface.DrawTexturedRect(x - siz / 2, y - siz / 2, siz, siz)
	local Col = Color(brite, brite, brite, opacity)
	local UnitText = tostring(amt) .. " UNITS"

	if rateDisplay then
		UnitText = tostring(amt) .. " PER SECOND"
	end

	if vertical then
		draw.SimpleText(typ, font, x, y - siz / 2 - 10, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		draw.SimpleText(UnitText, font, x, y + siz / 2 + 10, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	else
		--[[local typExplode = string.Explode(" ", typ)
		for i = 1, #typExplode do
			typExplode[i] = string.upper(string.sub(typExplode[i], 1, 1)) .. string.sub(typExplode[i], 2) .. "\n"
		end
		typ = table.concat(typExplode)
		local fontsize = draw.GetFontHeight(font)
		draw.DrawText(typ, font, x - siz / 2 - 10, y / #typExplode - fontsize / 2, Col, TEXT_ALIGN_RIGHT)--]]
		draw.SimpleText(typ, font, x - siz / 2 - 10, y, Col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(UnitText, font, x + siz / 2 + 10, y, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

function JMod.StandardRankDisplay(rank, x, y, siz, opacity)
	opacity = opacity or 150
	surface.SetDrawColor(255, 255, 255, opacity)
	surface.SetMaterial(RankIcons[rank])
	surface.DrawTexturedRect(x - siz / 2, y - siz / 2, siz, siz)
end

function JMod.HoloGraphicDisplay(ent, relPos, relAng, scale, renderDist, renderFunc, absolutePositions)
	if absolutePositions then
		if EyePos():Distance(relPos) < renderDist then
			cam.Start3D2D(relPos, relAng, scale)
			renderFunc()
			cam.End3D2D()
		end

		return
	end

	local Ang, Pos = Angle(0, 0, 0), Vector(0, 0, 0)

	if IsValid(ent) and ent.GetAngles then
		Ang = ent:GetAngles()
		Pos = ent:GetPos()
	else -- we're using world coordinates
		Pos = relPos
		Ang = relAng
	end

	local Right, Up, Forward = Ang:Right(), Ang:Up(), Ang:Forward()

	if EyePos():Distance(Pos) < renderDist then
		if ent then
			Ang:RotateAroundAxis(Right, relAng.p)
			Ang:RotateAroundAxis(Up, relAng.y)
			Ang:RotateAroundAxis(Forward, relAng.r)
		end

		local RenderPos = Pos + relPos.x * Right + relPos.y * Forward + relPos.z * Up

		-- world coords
		if not ent then
			RenderPos = Pos + Vector(0, 0, 50)
		end

		cam.Start3D2D(RenderPos, Ang, scale)
		renderFunc()
		cam.End3D2D()
	end
end

net.Receive("JMod_Friends", function()
	local Updating = tobool(net.ReadBit())

	if Updating then
		local Playa = net.ReadEntity()
		local FriendList = net.ReadTable()
		Playa.JModFriends = FriendList

		return
	end

	if FriendMenuOpen then return end
	FriendMenuOpen = true
	local Frame, W, H, Myself, FriendList = vgui.Create("DFrame"), 300, 400, LocalPlayer(), net.ReadTable()
	Frame:SetPos(40, 80)
	Frame:SetSize(W, H)
	Frame:SetTitle("Select Allies")
	Frame:SetVisible(true)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:MakePopup()
	Frame:Center()

	Frame.OnClose = function()
		FriendMenuOpen = false
		net.Start("JMod_Friends")
		net.WriteTable(FriendList)
		net.SendToServer()
	end

	function Frame:OnKeyCodePressed(key)
		if (key == KEY_Q) or (key == KEY_ESCAPE) then
			self:Close()
		end
	end

	function Frame:Paint()
		BlurBackground(self)
	end

	local Scroll = vgui.Create("DScrollPanel", Frame)
	Scroll:SetSize(W - 15, H)
	Scroll:SetPos(10, 30)
	PopulateFriendList(Scroll, FriendList, Myself, W, H)
end)

local OldMouseX, OldMouseY = 0, 0
net.Receive("JMod_ColorAndArm", function()
	local Ent, UpdateColor, NextColorCheck = net.ReadEntity(), net.ReadBool(), 0

	if UpdateColor == true then
		input.SetCursorPos(OldMouseX, OldMouseY)
	end
	if not IsValid(Ent) then return end
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(200, 300)
	Frame:SetPos(ScrW() * .4 - 200, ScrH() * .5)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:SetTitle(Ent.PrintName or "Select Color")
	Frame:MakePopup()
	local Picker

	function Frame:Paint()
		BlurBackground(self)
		local Time = CurTime()

		if NextColorCheck < Time then
			if not IsValid(Ent) then
				Frame:Close()

				return
			end

			NextColorCheck = Time + .25
			net.Start("JMod_ColorAndArm")
			net.WriteEntity(Ent)
			net.WriteBool(false)
			local Col = Picker:GetColor()
			net.WriteColor(Color(Col.r, Col.g, Col.b))
			net.WriteBool(false)
			net.SendToServer()
		end
	end

	Picker = vgui.Create("DColorMixer", Frame)
	Picker:SetPos(5, 25)
	Picker:SetSize(190, 215)
	Picker:SetAlphaBar(false)
	Picker:SetWangs(false)
	Picker:SetPalette(true)
	Picker:SetColor(Ent:GetColor())
	local Butt = vgui.Create("DButton", Frame)
	Butt:SetPos(5, 245)
	Butt:SetSize(95, 50)
	Butt:SetText("ARM")

	function Butt:DoClick()
		net.Start("JMod_ColorAndArm")
		net.WriteEntity(Ent)
		net.WriteBool(false)
		local Col = Picker:GetColor()
		net.WriteColor(Color(Col.r, Col.g, Col.b))
		net.WriteBool(true)
		net.SendToServer()
		Frame:Close()
	end

	local ButtWhat = vgui.Create("DButton", Frame)
	ButtWhat:SetPos(100, 245)
	ButtWhat:SetSize(95, 50)
	ButtWhat:SetText("AUTO-COLOR")

	function ButtWhat:DoClick()
		net.Start("JMod_ColorAndArm")
		net.WriteEntity(Ent)
		net.WriteBool(true)
		net.WriteColor(Color(255, 255, 255))
		net.WriteBool(false)
		net.SendToServer()
		OldMouseX, OldMouseY = input.GetCursorPos()
		Frame:Close()
	end
	if LocalPlayer():KeyDown(IN_SPEED) then
		net.Start("JMod_ColorAndArm")
		net.WriteEntity(Ent)
		net.WriteBool(true)
		net.WriteColor(Color(255, 255, 255))
		net.WriteBool(true)
		net.SendToServer()
		Frame:Close()
	end
end)

net.Receive("JMod_ArmorColor", function()
	local Ent, UpdateColor, NextColorCheck = net.ReadEntity(), net.ReadBool(), 0
	local Durability, MaxDurability = net.ReadFloat(), net.ReadFloat()

	if UpdateColor == true then
		input.SetCursorPos(OldMouseX, OldMouseY)
	end

	if not IsValid(Ent) then return end
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(200, 320)
	Frame:SetPos(ScrW() * .4 - 200, ScrH() * .5)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:SetTitle("EZ Armor Color")
	Frame:MakePopup()
	local Picker

	function Frame:Paint(w, h)
		BlurBackground(self)
		local Time = CurTime()

		if NextColorCheck < Time then
			if not IsValid(Ent) then
				Frame:Close()

				return
			end

			NextColorCheck = Time + .25
			net.Start("JMod_ArmorColor")
				net.WriteEntity(Ent)
				net.WriteBool(false)
				local Col = Picker:GetColor()
				net.WriteColor(Color(Col.r, Col.g, Col.b))
				net.WriteBit(false)
			net.SendToServer()
		end

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(5, 25, 190, 18)
		local DR, DG, DB = JMod.GoodBadColor(Durability / MaxDurability, false)
		surface.SetDrawColor(DR, DG, DB, 100)
		surface.DrawRect(5, 25, 190 * (Durability / MaxDurability), 18)
		draw.SimpleText("Durability: " .. math.Round(Durability, 2), "DermaDefault", 100, 34, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	Picker = vgui.Create("DColorMixer", Frame)
	Picker:SetPos(5, 45)
	Picker:SetSize(190, 215)
	Picker:SetAlphaBar(false)
	Picker:SetWangs(false)
	Picker:SetPalette(true)
	Picker:SetColor(Ent:GetColor())

	local Butt = vgui.Create("DButton", Frame)
	Butt:SetPos(5, 265)
	Butt:SetSize(95, 50)
	Butt:SetText("EQUIP")

	function Butt:DoClick()
		net.Start("JMod_ArmorColor")
		net.WriteEntity(Ent)
		net.WriteBool(false)
		local Col = Picker:GetColor()
		net.WriteColor(Color(Col.r, Col.g, Col.b))
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end

	local ButtWhat = vgui.Create("DButton", Frame)
	ButtWhat:SetPos(100, 265)
	ButtWhat:SetSize(95, 50)
	ButtWhat:SetText("AUTO-COLOR")

	function ButtWhat:DoClick()
		net.Start("JMod_ArmorColor")
		net.WriteEntity(Ent)
		net.WriteBool(true)
		net.WriteColor(LocalPlayer():GetPlayerColor():ToColor())
		net.WriteBit(false)
		net.SendToServer()
		OldMouseX, OldMouseY = input.GetCursorPos()
		Frame:Close()
	end
	if LocalPlayer():KeyDown(IN_SPEED) then
		net.Start("JMod_ArmorColor")
		net.WriteEntity(Ent)
		net.WriteBool(false)
		net.WriteColor(LocalPlayer():GetPlayerColor():ToColor())
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end
end)

-- local FavIcon=Material("white_star_64.png")
local function PopulateItems(parent, items, typ, motherFrame, entity, enableFunc, clickFunc, mult)
	mult = mult or 1
	parent:Clear()
	local W, H = parent:GetWide(), parent:GetTall()
	local Scroll = vgui.Create("DScrollPanel", parent)
	Scroll:SetSize(W - 20, H - 20)
	Scroll:SetPos(10, 10)
	---
	local Pos, Range = entity:GetPos(), 150
	local Y, AlphabetizedItemNames = 0, table.GetKeys(items)
	table.sort(AlphabetizedItemNames, function(a, b) return a < b end)

	for k, itemName in pairs(AlphabetizedItemNames) do
		local Butt = Scroll:Add("DButton")
		Butt:SetSize(W - 40, 42)
		Butt:SetPos(0, Y)
		Butt:SetText("")
		local itemInfo = items[itemName]
		local desc = itemInfo.description or ""

		if typ == "crafting" then
			desc = desc .. "\n "

			for resourceName, resourceAmt in pairs(itemInfo.craftingReqs) do
				desc = desc .. resourceName .. " x" .. tostring(math.ceil(resourceAmt * ((not(itemInfo.noRequirementScaling) and mult) or 1))) .. ", "
			end
		end

		Butt:SetTooltip(desc)
		Butt.enabled = enableFunc(itemName, itemInfo, LocalPlayer(), entity)
		Butt:SetMouseInputEnabled(true)
		Butt.hovered = false

		function Butt:Paint(w, h)
			local Hovr = self:IsHovered()

			if Hovr then
				if not self.hovered then
					self.hovered = true

					if self.enabled then
						surface.PlaySound("snds_jack_gmod/ez_gui/hover_ready.ogg")
					end
				end
			else
				self.hovered = false
			end

			local Brite = (Hovr and 50) or 30

			if self.enabled then
				surface.SetDrawColor(Brite, Brite, Brite, 60)
			else
				surface.SetDrawColor(0, 0, 0, (Hovr and 50) or 20)
			end

			surface.DrawRect(0, 0, w, h)
			local ItemIcon = JMod.SelectionMenuIcons[itemName]

			if ItemIcon then
				--surface.SetDrawColor(100,100,100,(self.enabled and 255)or 40)
				--surface.DrawRect(5,5,32,32)
				surface.SetMaterial(ItemIcon)
				surface.SetDrawColor(255, 255, 255, (self.enabled and 255) or 40)
				surface.DrawTexturedRect(5, 5, 32, 32)
			end

			draw.SimpleText(itemName, "DermaDefault", (ItemIcon and 47) or 5, 15, Color(255, 255, 255, (self.enabled and 255) or 40), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			if typ == "crafting" then
				local X = w - 30 -- let's draw the resources right to left

				for resourceName, resourceAmt in pairs(itemInfo.craftingReqs) do
					resourceAmt = math.ceil(resourceAmt * ((not(itemInfo.noRequirementScaling) and mult) or 1))
					local Have = LocallyAvailableResources[resourceName] and (LocallyAvailableResources[resourceName] >= resourceAmt)
					local Txt = "x" .. tostring(resourceAmt)
					surface.SetFont("DermaDefault")
					local TxtSize = surface.GetTextSize(Txt)
					draw.SimpleText(Txt, "DermaDefault", X - TxtSize, 15, Color(255, 255, 255, (Have and 255) or 40), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					X = X - (TxtSize + 3)
					surface.SetMaterial(JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[resourceName])
					surface.SetDrawColor(255, 255, 255, (Have and 255) or 30)
					surface.DrawTexturedRect(X - 32, 5, 32, 32)
					X = X - (32 + 6)
				end
			end
		end

		function Butt:DoClick()
			if self.enabled then
				timer.Simple(.5, function()
					if IsValid(entity) then
						clickFunc(itemName, itemInfo, LocalPlayer(), entity)
					end
				end)

				surface.PlaySound("snds_jack_gmod/ez_gui/click_big.ogg")
				motherFrame.positiveClosed = true
				motherFrame:Close()
			else
				surface.PlaySound("snds_jack_gmod/ez_gui/miss.ogg")
			end
		end

		Y = Y + 47
	end
end

local function CacheSelectionMenuIcon(name, info)
	if not JMod.SelectionMenuIcons[name] then
		if file.Exists("materials/jmod_selection_menu_icons/" .. tostring(name) .. ".png", "GAME") then
			JMod.SelectionMenuIcons[name] = Material("jmod_selection_menu_icons/" .. tostring(name) .. ".png")
		elseif info then
			if file.Exists("materials/entities/" .. tostring(info) .. ".png", "GAME") then
				JMod.SelectionMenuIcons[name] = Material("entities/" .. tostring(info) .. ".png")
			elseif string.find(tostring(info), ".mdl") then
				local CleanStringName = string.Replace(tostring(info), ".mdl", "")
				if file.Exists("materials/spawnicons/" .. CleanStringName .. ".png", "GAME") then
					JMod.SelectionMenuIcons[name] = Material("spawnicons/" .. CleanStringName .. ".png")
				else
					local Buttalony = vgui.Create("SpawnIcon")
					Buttalony:SetModel(tostring(info))
					Buttalony:SetSize(64, 64)
					Buttalony:RebuildSpawnIcon()
					hook.Add("SpawniconGenerated", "JMod_ImagePrecacher_" .. name, function(lastModel, imageName, modelsLeft) 
						print(name, tostring(info), lastModel, imageName, modelsLeft)
						if (lastModel) and (lastModel == tostring(info)) then
							imageName = imageName:Replace("materials\\", "")
							imageName = imageName:Replace("materials/", "")
							JMod.SelectionMenuIcons[name] = Material(imageName)
							hook.Remove("SpawniconGenerated", "JMod_ImagePrecacher_" .. name)
							if IsValid(Buttalony) then
								Buttalony:Remove()
							end
						end
					end)
					--JMod.SelectionMenuIcons[name] = QuestionMarkIcon
				end
			else
				-- special logic for random tables and resources and such
				local itemClass = info

				if type(itemClass) == "table" then
					itemClass = itemClass[1]
				end

				if type(itemClass) == "table" then
					itemClass = itemClass[1]
				end

				if itemClass == "RAND" then
					JMod.SelectionMenuIcons[name] = QuestionMarkIcon
				elseif type(itemClass) == "string" then
					local IsResource = false

					for k, v in pairs(JMod.EZ_RESOURCE_ENTITIES) do
						if v == itemClass then
							IsResource = true
							JMod.SelectionMenuIcons[name] = JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[k]
						end
					end

					if not IsResource then
						JMod.SelectionMenuIcons[name] = Material("entities/" .. itemClass .. ".png")
					end
				end
			end
		end
	end

	return JMod.SelectionMenuIcons[name]
end

local function StandardSelectionMenu(typ, displayString, data, entity, enableFunc, clickFunc, sidePanelFunc, mult)
	mult = mult or 1
	-- first, populate icons
	if IsValid(CurrentSelectionMenu) then return end
	for name, info in pairs(data) do
		CacheSelectionMenuIcon(name, info.results or "") 
	end

	-- then, populate info with nearby available resources
	if typ == "crafting" then
		LocallyAvailableResources = JMod.CountResourcesInRange(entity:LocalToWorld(entity:OBBCenter()), 150, entity)
	end
	-- then, proceed with making the rest of the menu
	local MotherFrame = vgui.Create("DFrame")
	MotherFrame.positiveClosed = false
	MotherFrame.storted = false
	MotherFrame:SetSize(900, 500)
	MotherFrame:SetVisible(true)
	MotherFrame:SetDraggable(true)
	MotherFrame:ShowCloseButton(true)
	MotherFrame:SetTitle(displayString)

	function MotherFrame:Paint()
		if not self.storted then
			self.storted = true
			surface.PlaySound("snds_jack_gmod/ez_gui/menu_open.ogg")
		end

		BlurBackground(self)
	end

	MotherFrame:MakePopup()
	MotherFrame:Center()

	function MotherFrame:OnKeyCodePressed(key)
		if key == KEY_Q or key == KEY_ESCAPE or key == KEY_E then
			self:Close()
		end
	end

	function MotherFrame:OnClose()
		if not self.positiveClosed then
			surface.PlaySound("snds_jack_gmod/ez_gui/menu_close.ogg")
		end
		CurrentSelectionMenu = nil
	end

	local W, H, Myself = MotherFrame:GetWide(), MotherFrame:GetTall(), LocalPlayer()
	local Categories = {}

	for itemName, itemInfo in pairs(data) do
		local Category = itemInfo.category or "Other"
		Categories[Category] = Categories[Category] or {}
		Categories[Category][itemName] = itemInfo
	end

	local TabPanel = vgui.Create("DPanel", MotherFrame)
	local TabPanelX, TabPanelW = 10, W - 20

	if sidePanelFunc then
		local WidthModifier = 200
		MotherFrame:SetWide(W + WidthModifier)
		MotherFrame:SetX(MotherFrame:GetX() - WidthModifier / 2)
		local SidePanel = vgui.Create("DPanel", MotherFrame)
		SidePanel:Dock(LEFT)
		SidePanel:DockMargin(0, 0, 5, 0)
		SidePanel:SetSize(200, H)
		function SidePanel:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 50)
			surface.DrawRect(0, 0, w, h)
		end
		MotherFrame.SidePanel = SidePanel
		sidePanelFunc(SidePanel)
		--TabPanelX = W * .25
		--TabPanelW = W * .75 - 20
		TabPanel:Dock(RIGHT)
	end

	TabPanel:SetPos(TabPanelX, 30)
	TabPanel:SetSize(TabPanelW, H - 40)

	function TabPanel:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(0, 0, w, h)
	end

	local tabX = 10
	local ActiveTabPanel = vgui.Create("DPanel", TabPanel)
	ActiveTabPanel:SetPos(10, 30)
	ActiveTabPanel:SetSize(TabPanelW - 20, 420)

	function ActiveTabPanel:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, w, h)
	end

	local AlphabetizedCategoryNames = table.GetKeys(Categories)
	table.sort(AlphabetizedCategoryNames, function(a, b) return a < b end)
	local ActiveTab = AlphabetizedCategoryNames[1]

	for k, cat in pairs(AlphabetizedCategoryNames) do
		surface.SetFont("DermaDefault")
		local TabBtn, TextWidth = vgui.Create("DButton", TabPanel), surface.GetTextSize(cat)
		TabBtn:SetPos(tabX, 10)
		TabBtn:SetSize(TextWidth + 10, 20)
		TabBtn:SetText("")
		TabBtn.Category = cat

		function TabBtn:Paint(x, y)
			local Hovr = self:IsHovered()
			local Col = (Hovr and 80) or 20
			surface.SetDrawColor(0, 0, 0, (ActiveTab == self.Category and 100) or Col)
			surface.DrawRect(0, 0, x, y)
			draw.SimpleText(self.Category, "DermaDefault", x * 0.5, 10, Color(255, 255, 255, (ActiveTab == self.Category and 255) or 40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		function TabBtn:DoClick()
			surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")
			ActiveTab = self.Category
			PopulateItems(ActiveTabPanel, Categories[ActiveTab], typ, MotherFrame, entity, enableFunc, clickFunc, mult)
		end

		tabX = tabX + TextWidth + 15
	end

	PopulateItems(ActiveTabPanel, Categories[ActiveTab], typ, MotherFrame, entity, enableFunc, clickFunc, mult)

	CurrentSelectionMenu = MotherFrame
	return MotherFrame
end

--[[
if #JMod.ClientConfig.BuildKitFavs > 0 then
	local Tab={}
	for k,v in pairs(JMod.ClientConfig.BuildKitFavs)do
		table.insert(Tab,v)
	end
	Categories["Favourites"]=Tab
end
--]]
net.Receive("JMod_EZtoolbox", function()
	local Buildables = net.ReadTable()
	local Kit = net.ReadEntity()

	if IsValid(CurrentSelectionMenu) then return end
	local MotherFrame = StandardSelectionMenu('crafting', "EZ Tool Box", Buildables, Kit, 
	function(name, info, ply, ent) -- enable func

		return JMod.HaveResourcesToPerformTask(ent:GetPos(), 150, info.craftingReqs, ent, LocallyAvailableResources) 
	end, 
	function(name, info, ply, ent)-- click func

		-- wireframe preview
		ent.EZpreview = {}
		local StringParts = string.Explode(" ", info["results"])	
		local Ang = nil 
		if info.spawnRotation then
			Ang = Angle(0, info.spawnRotation, 0)
		end															  
		if StringParts[1] and (StringParts[1] == "FUNC") then
			if not info.sizeScale or (StringParts[2] == "EZnail") or (StringParts[2] == "EZbolt") then
				ent.EZpreview = {Box = nil, sizeScale = 1, SpawnAngles = Ang or Angle(0, 0, 0)} --No way to tell size
			else
				local ScaledMinMax = Vector(info.sizeScale * 10, info.sizeScale * 10, info.sizeScale * 10)
				ent.EZpreview = {Box = {mins = -ScaledMinMax, maxs = ScaledMinMax}, sizeScale = info.sizeScale, SpawnAngles = Ang or Angle(0, 0, 0)}
			end
		else
			local temp_ent
			if (string.Right(info["results"], 4) == ".mdl") then
				temp_ent = ents.CreateClientProp(info["results"])
				if not(util.IsValidModel(info["results"])) then
					print("JMod: Invalid model in config: " .. info["results"])
				else
					temp_ent:SetModel(info["results"])
				end
			else
				temp_ent = ents.CreateClientside(info["results"])
				if temp_ent.IsJackyEZmachine then
					temp_ent.ClientOnly = true
				end
			end
			temp_ent:SetNextClientThink(CurTime() + 0.1)
			temp_ent:SetNoDraw(true)
			temp_ent:Spawn()									-- have to do this to get an accurate bounding box
			local Min, Max = temp_ent:OBBMaxs(), temp_ent:OBBMins() 		-- couldn't find a better way
			Ang = Ang or (temp_ent.JModPreferredCarryAngles and temp_ent.JModPreferredCarryAngles)

			if Min:IsZero() and Max:IsZero() then
				if info.sizeScale then
					local ScaledMinMax = Vector(info.sizeScale * 10, info.sizeScale * 10, info.sizeScale * 10)
					Min = -ScaledMinMax
					Max = ScaledMinMax
				elseif IsValid(temp_ent.Mdl) then
					Min, Max = temp_ent.Mdl:GetModelBounds()
				end
			end
			local OriginDiff = temp_ent:LocalToWorld(temp_ent:OBBCenter()) - temp_ent:GetPos()
			Min = Min - OriginDiff
			Max = Max - OriginDiff
			SafeRemoveEntityDelayed(temp_ent, 0)

			ent.EZpreview = {Box = {mins = Min, maxs = Max}, sizeScale = info.sizeScale and info.sizeScale, SpawnAngles = Ang or Angle(0, 0, 0)}
		end
		net.Start("JMod_EZtoolbox")
			net.WriteEntity(ent)
			net.WriteString(name)
			net.WriteTable(ent.EZpreview)
		net.SendToServer()
	end, 
	function(parent) -- side panel func
		local W, H, Myself = parent:GetWide(), parent:GetTall(), LocalPlayer()

		local ResourceScroller = vgui.Create("DScrollPanel", parent)
		ResourceScroller:SetSize(W - 20, H - 20)
		ResourceScroller:SetPos(10, 10)
		ResourceScroller:Dock(FILL)
		ResourceScroller:DockMargin(0, 0, 0, 0)
		ResourceScroller:SetPaintBackground(false)
		ResourceScroller.VerticalScrollbar = true
		ResourceScroller.HorizontalScrollbar = false

		for k, v in pairs(LocallyAvailableResources) do
			local ResourcePanel = vgui.Create("DPanel", ResourceScroller)
			ResourcePanel:SetSize(W - 20, 40)
			ResourcePanel:Dock(TOP)
			ResourcePanel:DockMargin(0, 0, 0, 5)
			function ResourcePanel:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawRect(0, 0, w, h)
				JMod.StandardResourceDisplay(k, v, nil, w * .55, h * .5, 30, false, "JMod-Stencil-XS")
			end
			ResourcePanel:SetTooltip(k .. " x" .. v)
		end
	end)
end)

net.Receive("JMod_EZworkbench", function()
	local Bench = net.ReadEntity()
	local Buildables = net.ReadTable()
	local Multiplier = net.ReadFloat()

	if IsValid(CurrentSelectionMenu) then return end
	local MotherFrame = StandardSelectionMenu('crafting', Bench.PrintName, Buildables, Bench, 
	function(name, info, ply, ent) -- enable func
		return JMod.HaveResourcesToPerformTask(ent:GetPos(), 200, info.craftingReqs, ent, LocallyAvailableResources, (not(info.noRequirementScaling) and Multiplier) or 1) 
	end, function(name, info, ply, ent)
		-- click func
		net.Start("JMod_EZworkbench")
		net.WriteEntity(ent)
		net.WriteString(name)
		net.SendToServer()
	end, 
	function(parent) -- side panel func
		local W, H, Myself = parent:GetWide(), parent:GetTall(), LocalPlayer()

		local ResourceScroller = vgui.Create("DScrollPanel", parent)
		ResourceScroller:SetSize(W - 20, H - 20)
		ResourceScroller:SetPos(10, 10)
		ResourceScroller:DockMargin(0, 5, 0, 0)
		ResourceScroller:Dock(FILL)
		ResourceScroller:SetPaintBackground(false)
		ResourceScroller.VerticalScrollbar = true
		ResourceScroller.HorizontalScrollbar = false

		for k, v in pairs(LocallyAvailableResources) do
			local ResourcePanel = vgui.Create("DPanel", ResourceScroller)
			ResourcePanel:SetSize(W - 20, 40)
			ResourcePanel:Dock(TOP)
			ResourcePanel:DockMargin(0, 0, 0, 5)
			function ResourcePanel:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawRect(0, 0, w, h)
				JMod.StandardResourceDisplay(k, v, nil, w * .55, h * .5, 30, false, "JMod-Stencil-XS")
			end
			ResourcePanel:SetTooltip(k .. " x" .. v)
		end

		if Bench:GetClass() == "ent_jack_gmod_ezprimitivebench" then
			local ScrapButton = vgui.Create("DButton", parent)
			ScrapButton:SetText("")
			ScrapButton:SetSize(W - 20, 40)
			ScrapButton:SetPos(10, H - 30)
			ScrapButton:DockMargin(1, 5, 1, 5)
			ScrapButton:Dock(BOTTOM)
			ScrapButton.DoClick = function()
				net.Start("JMod_EZworkbench")
					net.WriteEntity(Bench)
					net.WriteString("JMOD_SCRAPINV")
				net.SendToServer()
				parent:GetParent():Close()
			end
			ScrapButton:SetTooltip("Salvages the props in your Inventory")
			function ScrapButton:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawRect(0, 0, w, h)
				draw.SimpleText("SALVAGE INVENTORY PROPS", "JMod-Stencil-XS", w * .5, h * .5, TextColors.ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end, Multiplier)
end)

net.Receive("JMod_EZtimeBomb", function()
	local ent = net.ReadEntity()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300, 120)
	frame:SetTitle("Time Bomb")
	frame:SetDraggable(true)
	frame:Center()
	frame:MakePopup()

	function frame:Paint()
		BlurBackground(self)
	end

	local bg = vgui.Create("DPanel", frame)
	bg:SetPos(90, 30)
	bg:SetSize(200, 25)

	function bg:Paint(w, h)
		surface.SetDrawColor(Color(255, 255, 255, 100))
		surface.DrawRect(0, 0, w, h)
	end

	local tim = vgui.Create("DNumSlider", frame)
	tim:SetText("Set Time")
	tim:SetSize(280, 20)
	tim:SetPos(10, 30)
	tim:SetMin(10)
	tim:SetMax(600)
	tim:SetValue(10)
	tim:SetDecimals(0)
	local apply = vgui.Create("DButton", frame)
	apply:SetSize(100, 30)
	apply:SetPos(100, 75)
	apply:SetText("ARM")

	apply.DoClick = function()
		net.Start("JMod_EZtimeBomb")
		net.WriteEntity(ent)
		net.WriteInt(tim:GetValue(), 16)
		net.SendToServer()
		frame:Close()
	end
end)

local function GetAvailPts(specs)
	local Pts = 0

	for k, v in pairs(specs) do
		if isnumber(v) then
			Pts = Pts - v
		end
	end

	return Pts
end

net.Receive("JMod_ModifyMachine", function()
	local Ent = net.ReadEntity()
	local Specs = net.ReadTable()
	local AmmoTypes, AmmoType, AvailPts = nil, nil, GetAvailPts(Specs)
	local ErrorTime = 0

	if tobool(net.ReadBit()) then
		AmmoTypes = net.ReadTable()
		AmmoType = net.ReadString()
	end

	---
	local frame = vgui.Create("DFrame")
	frame:SetSize(600, 400)
	frame:SetTitle("Modify Machine")
	frame:SetDraggable(true)
	frame:Center()
	frame:MakePopup()

	function frame:Paint()
		BlurBackground(self)
	end

	local bg = vgui.Create("DPanel", frame)
	bg:SetPos(10, 30)
	bg:SetSize(580, 360)

	function bg:Paint(w, h)
		surface.SetDrawColor(Color(0, 0, 0, 100))
		surface.DrawRect(0, 0, w, h)
	end

	local X, Y = 10, 10

	for attrib, value in pairs(Specs) do
		local Panel = vgui.Create("DPanel", bg)
		Panel:SetPos(X, Y)
		Panel:SetSize(275, 40)

		if isnumber(value) then
			function Panel:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(0, 0, w, h)
				draw.SimpleText(attrib .. ": " .. Specs[attrib], "DermaDefault", 137, 10, TextColors.ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			local MinButt = vgui.Create("DButton", Panel)
			MinButt:SetPos(10, 10)
			MinButt:SetSize(20, 20)
			MinButt:SetText("-")

			function MinButt:DoClick()
				Specs[attrib] = math.Clamp(Specs[attrib] - 1, -10, 10)
				AvailPts = GetAvailPts(Specs)
			end

			local MaxButt = vgui.Create("DButton", Panel)
			MaxButt:SetPos(245, 10)
			MaxButt:SetSize(20, 20)
			MaxButt:SetText("+")

			function MaxButt:DoClick()
				if AvailPts > 0 then
					Specs[attrib] = math.Clamp(Specs[attrib] + 1, -10, 10)
					AvailPts = GetAvailPts(Specs)
				end
			end

		elseif istable(value) then
			local IsMin = value.Min and isnumber(value.Min)

			function Panel:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(0, 0, w, h)
				if IsMin then
					draw.SimpleText(attrib, "DermaDefault", 137, 5, TextColors.ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("Min", "DermaDefault", 75, 12, TextColors.ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					draw.SimpleText("Max", "DermaDefault", 200, 12, TextColors.ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				else
					draw.SimpleText(attrib, "DermaDefault", 137, 5, TextColors.ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				end
			end

			if IsMin then
				local MinNumBox = vgui.Create("DNumSlider", Panel)
				--MinNumBox:SetPos(0, 5)
				MinNumBox:Dock(LEFT)
				--MinNumBox:SetWide(200)
				MinNumBox:SetMin(-360)
				MinNumBox:SetMax(0)
				MinNumBox:SetDecimals(0)
				MinNumBox:SetValue(Specs[attrib].Min)
				MinNumBox.OnValueChanged = function(_, val)
					Specs[attrib].Min = math.Round(val)
				end
			end

			if value.Max and isnumber(value.Max) then
				local MaxNumBox = vgui.Create("DNumSlider", Panel)
				if IsMin then
					MaxNumBox:Dock(RIGHT)
				else
					--MaxNumBox:Dock(FILL)
					MaxNumBox:SetPos(-50, 20)
					MaxNumBox:SetSize(300, 20)
				end
				MaxNumBox:SetMin(0)
				MaxNumBox:SetMax(360)
				MaxNumBox:SetDecimals(0)
				MaxNumBox:SetValue(Specs[attrib].Max)
				MaxNumBox.OnValueChanged = function(_, val)
					Specs[attrib].Max = math.Round(val)
				end
			end
		end

		Y = Y + 50

		if Y >= 300 then
			X = X + 285
			Y = 10
		end
	end

	local Display = vgui.Create("DPanel", bg)
	Display:SetSize(600, 40)
	Display:SetPos(100, 315)

	function Display:Paint()
		local Col = (ErrorTime > CurTime() and Color(255, 0, 0, 255)) or TextColors.ButtonTextBright
		draw.SimpleText("Available spec points: " .. AvailPts, "DermaDefault", 250, 0, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Trade traits to achieve desired performance", "DermaDefault", 250, 20, TextColors.ButtonTextBright, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local Apply = vgui.Create("DButton", bg)
	Apply:SetSize(100, 40)
	Apply:SetPos(240, 310)
	Apply:SetText("Accept")

	function Apply:DoClick()
		if AvailPts > 0 then
			ErrorTime = CurTime() + 1

			return
		end

		net.Start("JMod_ModifyMachine")
		net.WriteEntity(Ent)
		net.WriteTable(Specs)

		if AmmoTypes then
			net.WriteBit(true)
			net.WriteString(AmmoType)
		else
			net.WriteBit(false)
		end

		net.SendToServer()
		frame:Close()
	end

	if AmmoTypes then
		local DComboBox = vgui.Create("DComboBox", bg)
		DComboBox:SetPos(10, 320)
		DComboBox:SetSize(150, 20)
		DComboBox:SetValue(AmmoType)

		for k, v in pairs(AmmoTypes) do
			DComboBox:AddChoice(k)
		end

		function DComboBox:OnSelect(index, value)
			AmmoType = value
		end
	end
end)

net.Receive("JMod_EZradio", function()
	local isMessage = net.ReadBool()

	if isMessage then
		local parrot = net.ReadBool()
		local msg = net.ReadString()
		local radio = net.ReadEntity()
		local ply = net.ReadEntity()

		if not IsValid(radio) then return end

		local tbl = {radio:GetColor(), "Aid Radio", Color(255, 255, 255), ": ", msg}

		if parrot then
			tbl = {Color(200, 200, 200), "(HIDDEN) ", ply, Color(255, 255, 255), ": ", Color(200, 200, 200), msg}
		end

		chat.AddText(unpack(tbl))

		if LocalPlayer():GetPos():DistToSqr(radio:GetPos()) > 200 * 200 then
			radio:EmitSound("/npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".ogg", 65, 120)
		end

		return
	end

	local Radio = net.ReadEntity()
	local Orderables = net.ReadTable()
	JMod.Config.RadioSpecs = {
		DeliveryTimeMult = 1,
		ParachuteDragMult = 1,
		StartingOutpostCount = 1,
		AvailablePackages = {}
	}
	JMod.Config.RadioSpecs.AvailablePackages = Orderables

	if IsValid(CurrentSelectionMenu) then return end
	local MotherFrame = StandardSelectionMenu('selecting', "EZ Radio", Orderables, Radio, function(name, info, ply, ent)
		-- enable func
		local override, msg = hook.Run("JMod_CanRadioRequest", ply, ent, name)
		if override == false then return false end

		return true
	end, function(name, info, ply, ent)
		-- click func
		ply:ConCommand("say supply radio: " .. name)
	end, nil)
end)

local OpenDropdown = nil

-- no side display for now
local ArmorSlotButtons = {
	{
		title = "Drop",
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(1, 8) -- drop
			net.WriteString(itemID)
			net.SendToServer()
		end
	},
	{
		title = "Toggle",
		visTestFunc = function(slot, itemID, itemData, itemInfo) return itemInfo.tgl end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(2, 8) -- toggle
			net.WriteString(itemID)
			net.SendToServer()
		end,
		dontClose = true
	},
	{
		title = "Repair",
		visTestFunc = function(slot, itemID, itemData, itemInfo) return itemData.dur < itemInfo.dur * .9 end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(3, 8) -- repair
			net.WriteString(itemID)
			net.SendToServer()
		end,
		dontClose = true
	},
	{
		title = "Recharge",
		visTestFunc = function(slot, itemID, itemData, itemInfo)
			if itemInfo.chrg then
				for resource, maxAmt in pairs(itemInfo.chrg) do
					if itemData.chrg[resource] < maxAmt then return true end
				end
			end

			return false
		end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(4, 8) -- recharge
			net.WriteString(itemID)
			net.SendToServer()
		end,
		dontClose = true
	},
	{
		title = "Color",
		visTestFunc = function(slot, itemID, itemData, itemInfo) return not(itemInfo.clrForced) end,
		actionFunc = function(slot, itemID, itemData, itemInfo, motherFrame)
			local Panel = vgui.Create("DFrame")
			Panel:SetSize(200, 300)
			Panel:SetPos(ScrW()/2, ScrH()/2 - 300)
			Panel:SetTitle("EZ Armor Color")
			Panel:MakePopup()

			function Panel:Paint(w, h)
				BlurBackground(self)
			end

			local ColorPicker = vgui.Create("DColorMixer", Panel)
			ColorPicker:SetPos(5, 25)
			ColorPicker:SetSize(190, 215)
			ColorPicker:SetAlphaBar(false)
			ColorPicker:SetWangs(false)
			ColorPicker:SetPalette(true)
			if itemData.col then
				ColorPicker:SetColor(Color(itemData.col.r, itemData.col.g, itemData.col.b))
			end
			
			local Buttony = vgui.Create("DButton", Panel)
			Buttony:SetPos(5, 245)
			Buttony:SetSize(95, 50)
			Buttony:SetText("CHANGE")
			Buttony.DoClick = function()
				net.Start("JMod_Inventory")
				net.WriteInt(5, 8) -- color
				net.WriteString(itemID)
				local Col = ColorPicker:GetColor()
				net.WriteColor(Color(Col.r, Col.g, Col.b))
				net.SendToServer()
			end

			local AutoButtony = vgui.Create("DButton", Panel)
			AutoButtony:SetPos(100, 245)
			AutoButtony:SetSize(95, 50)
			AutoButtony:SetText("AUTO-COLOR")
			AutoButtony.DoClick = function()
				ColorPicker:SetColor(LocalPlayer():GetPlayerColor():ToColor())
			end

			OpenDropdown = Panel
		end,
		dontClose = true
	}
}

local ArmorResourceNiceNames = {
	chemicals = "Chemicals",
	power = "Electricity",
	gas = "Compressed Gas",
	fuel = "Fuel",
}
local ResourceColors = {
	chemicals = Color(19, 155, 19),
	power = Color(200, 200, 0),
	gas = Color(132, 187, 187),
	fuel = Color(200, 20, 0),
}

local function CreateArmorSlotButton(parent, slot, x, y)
	local Buttalony, Ply = vgui.Create("DButton", parent), LocalPlayer()
	Buttalony:SetSize(180, 40)
	Buttalony:SetPos(x, y)
	Buttalony:SetText("")
	Buttalony:SetCursor("hand")
	local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(Ply.EZarmor, slot)

	function Buttalony:Paint(w, h)
		ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(Ply.EZarmor, slot)
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText(JMod.ArmorSlotNiceNames[slot], "DermaDefault", Buttalony:GetWide() / 2, 10, ButtonTextBright, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local Str = "--EMPTY--"
		if ItemID then
			Str = ItemData.name --..": "..math.Round(ItemData.dur/ItemInfo.dur*100).."%"

			if ItemData.tgl and ItemInfo.tgl.slots[slot] == 0 then
				Str = "DISENGAGED"
			end
			--
			local DuribilityFrac = ItemData.dur / ItemInfo.dur
			local DurR, DurB, DurG, DurA = JMod.GoodBadColor(DuribilityFrac, false, 25)
			surface.SetDrawColor(DurR, DurB, DurG, DurA)
			surface.DrawRect(0, 0, w * DuribilityFrac, h)
			--
			local DurDesc = "Durability: " .. math.Round(ItemData.dur, 1) .. "/" .. ItemInfo.dur

			if ItemInfo.chrg then
				local ChargeBarHeight = h / 20
				local Index = 1

				for res, maxAmt in pairs(ItemInfo.chrg) do
					local BarColor = ResourceColors[res]
					surface.SetDrawColor(BarColor.r, BarColor.g, BarColor.b, 200)
					surface.DrawRect(0, h - ChargeBarHeight * Index, w * (ItemData.chrg[res] / maxAmt), ChargeBarHeight)
					DurDesc = DurDesc .. "\n" .. ArmorResourceNiceNames[res] .. ": " .. math.Round(ItemData.chrg[res], 1) .. "/" .. maxAmt
					Index = Index + 1
				end
			end

			Buttalony:SetTooltip(DurDesc)
		else
			Buttalony:SetTooltip("slot is empty")
		end
		draw.SimpleText(Str, "DermaDefault", Buttalony:GetWide() / 2, 25, TextColors.ButtonText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function Buttalony:DoClick()
		if IsValid(OpenDropdown) then
			OpenDropdown:Remove()

			return
		end

		if not ItemID then return end
		local Options = {}

		for k, option in pairs(ArmorSlotButtons) do
			if not option.visTestFunc or option.visTestFunc(slot, ItemID, ItemData, ItemInfo) then
				table.insert(Options, option)
			end
		end

		local ChargeBarHeight = 15
		local StartHeight = 20
		if ItemInfo.chrg then
			StartHeight = StartHeight + (ChargeBarHeight * table.Count(ItemInfo.chrg) + 5)
		end

		local Dropdown = vgui.Create("DPanel", parent)
		Dropdown:SetSize(Buttalony:GetWide(), #Options * 40 + StartHeight)
		local ecks, why = gui.MousePos()
		local harp, darp = parent:GetPos()
		local fack, fock = parent:GetSize()
		local floop, florp = Dropdown:GetSize()
		Dropdown:SetPos(math.Clamp(ecks - harp, 0, fack - floop), math.Clamp(why - darp, 0, fock - florp))

		function Dropdown:Paint(w, h)
			surface.SetDrawColor(70, 70, 70, 220)
			surface.DrawRect(0, 0, w, h)
			if not ItemID then 
				Dropdown:Remove()
			end

			local DurDesc = "Durability: " .. math.Round(ItemData.dur, 1) .. "/" .. ItemInfo.dur
			draw.SimpleText(DurDesc, DermaDefault, w / 2, ChargeBarHeight - ChargeBarHeight * 0.75, TextColors.DescText, TEXT_ALIGN_CENTER)

			if ItemInfo.chrg then
				local Index = 1

				for res, maxAmt in pairs(ItemInfo.chrg) do
					local BarColor = ResourceColors[res]
					surface.SetDrawColor(BarColor.r, BarColor.g, BarColor.b, 100)
					local HeightStep = Index * ChargeBarHeight * 1.1 + 5
					surface.DrawRect(5, HeightStep, w * (ItemData.chrg[res] / maxAmt) - 10, ChargeBarHeight)
					draw.SimpleText(ArmorResourceNiceNames[res] .. ": " .. math.Round(ItemData.chrg[res], 1) .. "/" .. maxAmt, DermaDefault, w / 2, HeightStep, TextColors.DescText, TEXT_ALIGN_CENTER)
					Index = Index + 1
				end
				
			end
		end

		for k, option in pairs(Options) do
			local Butt = vgui.Create("DButton", Dropdown)
			Butt:SetPos(5, (k - 1) * 40 + StartHeight + 5)
			Butt:SetSize(floop - 10, 30)
			--Butt:SetText(option.title)
			Butt:SetText("")

			function Butt:Paint(w, h)
				surface.SetDrawColor(255, 255, 255, 200)
				surface.DrawRect(0, 0, w, h)
		
				draw.SimpleText(option.title, "DermaDefault", w / 2, h / 2, TextColors.ButtonTextDark, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			function Butt:DoClick()
				option.actionFunc(slot, ItemID, ItemData, ItemInfo, motherFrame)
				if not(option.dontClose) and IsValid(parent) then
					parent:Close()
				else
					Dropdown:Remove()
				end
			end
		end

		OpenDropdown = Dropdown
	end
end

local function CreateCommandButton(parent, commandTbl, x, y, num)
	local Buttalony, Ply = vgui.Create("DButton", parent), LocalPlayer()
	Buttalony:SetSize(180, 20)
	Buttalony:SetPos(x, y)
	Buttalony:SetText("")
	Buttalony:SetCursor("hand")

	function Buttalony:Paint(w, h)
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(0, 0, w, h)

		draw.SimpleText(num..": "..commandTbl.name, "DermaDefault", w / 2, 10, TextColors.ButtonText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local HelpStr = commandTbl.helpTxt
	if commandTbl.adminOnly then
		HelpStr = "ADMIN ONLY!\n"..commandTbl.helpTxt
	end
		
	Buttalony:SetTooltip(HelpStr)

	function Buttalony:DoClick()
		Ply:ConCommand("jmod_ez_"..commandTbl.name)
		if IsValid(parent) then
			parent:Close()
		end
	end
end

--Item Inventory
local function CreateInvButton(parent, itemTable, x, y, w, h, scrollFrame, invEnt)
	if not(itemTable and IsValid(itemTable.ent)) then
		print(invEnt)
		net.Start("JMod_ItemInventory")
			net.WriteString("missing")
			net.WriteEntity(NULL)
			net.WriteEntity(invEnt)
		net.SendToServer()

		if IsValid(parent) then
			parent:Close()
		end

		return
	end

	local Buttalony, Ply = vgui.Create("DButton", scrollFrame), LocalPlayer()
	local Matty = nil
	if string.find(itemTable.ent:GetClass(), "prop_") then
		Buttalony:Remove()
		Buttalony = vgui.Create("SpawnIcon", scrollFrame)
		Buttalony:SetModel(itemTable.name)
	else
		Matty = CacheSelectionMenuIcon(itemTable.name, itemTable.ent:GetClass())
		if Matty then
			Buttalony:SetMaterial(Matty)
		end
	end

	Buttalony:SetText("")--itemTable.name)
	Buttalony:SetSize(w, h)
	Buttalony:SetPos(x, y)
	Buttalony:SetCursor("hand")
	
	function Buttalony:Paint(w, h)
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(0, 0, w, h)
		if self:IsHovered() then
			surface.SetDrawColor(61, 118, 192, 100)
			surface.DrawOutlinedRect(0, 0, w, h, 3)
			surface.SetDrawColor(255, 255, 255, 100)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
		--draw.SimpleText(itemTable.name, "DermaDefault", Buttalony:GetWide() / 2, 40, TextColors.ButtonText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local HelpStr = itemTable.name..":\n"..(itemTable.vol or "N/A").." Volume"
	
	Buttalony:SetTooltip(HelpStr)
	
	function Buttalony:DoClick()
		if OpenDropdown then
			OpenDropdown:Remove()
		end
		
		local Options={
			[1]={
				title="Drop",
				actionFunc = function(itemTable)
					if IsValid(itemTable.ent) then
						net.Start("JMod_ItemInventory")
							net.WriteString("drop")
							net.WriteEntity(itemTable.ent)
							net.WriteEntity(invEnt)
						net.SendToServer()
					else
						net.Start("JMod_ItemInventory")
							net.WriteString("missing")
							net.WriteEntity(NULL)
							net.WriteEntity(invEnt)
						net.SendToServer()
					end
				end
			},
			[2]={
				title="Use",
				actionFunc = function(itemTable)
					if IsValid(itemTable.ent) then
						net.Start("JMod_ItemInventory")
							net.WriteString("use")
							net.WriteEntity(itemTable.ent)
							net.WriteEntity(invEnt)
						net.SendToServer()
					else
						net.Start("JMod_ItemInventory")
							net.WriteString("missing")
							net.WriteEntity(NULL)
							net.WriteEntity(Ply)
						net.SendToServer()
					end
				end
			},
			--[[[3]={
				title="Prime",
				actionFunc = function(itemTable)
					--Ply:ConCommand("+alt1")
					net.Start("JMod_ItemInventory")
					net.WriteString("prime")
					net.WriteEntity(itemTable.ent)
					if invEnt ~= Ply then
						net.WriteEntity(invEnt)
					else
						net.WriteEntity(NULL)
					end
					net.SendToServer()
				end
			}--]]
		}

		if itemTable.ent.EZinvPrime then
			table.insert(Options, {
				title="Prime",
				actionFunc = function(itemTable)
					net.Start("JMod_ItemInventory")
					net.WriteString("prime")
					net.WriteEntity(itemTable.ent)
					net.WriteEntity(invEnt)
					net.SendToServer()
				end
			})
		end

		if invEnt == Ply then
			table.insert(Options, {
				title="Stow",
				actionFunc = function(itemTable)
					if IsValid(itemTable.ent) then
						net.Start("JMod_ItemInventory")
							net.WriteString("stow")
							net.WriteEntity(itemTable.ent)
							net.WriteEntity(Ply:GetEyeTrace().Entity)
						net.SendToServer()
					else
						net.Start("JMod_ItemInventory")
							net.WriteString("missing")
							net.WriteEntity(NULL)
							net.WriteEntity(invEnt)
						net.SendToServer()
					end
				end
			})
		else
			table.insert(Options, {
				title="Take",
				actionFunc = function(itemTable)
					if IsValid(itemTable.ent) then
						net.Start("JMod_ItemInventory")
							net.WriteString("take")
							net.WriteEntity(itemTable.ent)
							net.WriteEntity(Ply:GetEyeTrace().Entity)
						net.SendToServer()
					else
						net.Start("JMod_ItemInventory")
							net.WriteString("missing")
							net.WriteEntity(NULL)
							net.WriteEntity(invEnt)
						net.SendToServer()
					end
				end
			})
		end
		
		local ButtonTall = 25
		local Dropdown = vgui.Create("DPanel", parent)
		Dropdown:SetSize(Buttalony:GetWide(), #Options * ButtonTall * 1.35)
		local ecks, why = gui.MousePos()
		local harp, darp = parent:GetPos()
		local fack, fock = parent:GetSize()
		local floop, florp = Dropdown:GetSize()
		Dropdown:SetPos(math.Clamp(ecks - harp, 0, fack - floop), math.Clamp(why - darp, 0, fock - florp))

		function Dropdown:Paint(w, h)
			surface.SetDrawColor(70, 70, 70, 220)
			surface.DrawRect(0, 0, w, h)
		end

		for k, option in pairs(Options) do
			local Butt = vgui.Create("DButton", Dropdown)
			Butt:SetPos(5, k * ButtonTall * 1.25 - ButtonTall)
			Butt:SetSize(floop - 10, ButtonTall)
			Butt:SetText(option.title)

			function Butt:DoClick()
				option.actionFunc(itemTable)
				if IsValid(parent) then
					parent:Close()
				end
			end
		end

		OpenDropdown = Dropdown
	end
end

local function CreateResButton(parent, resourceType, amt, x, y, w, h, scrollFrame, invEnt)
	local Buttalony, Ply = vgui.Create("DButton", scrollFrame), LocalPlayer()
	Buttalony:SetText("")
	Buttalony:SetSize(w, h)
	Buttalony:SetPos(x, y)
	Buttalony:SetCursor("hand")
	
	function Buttalony:Paint(w, h)
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(0, 0, w, h)
		if isstring(resourceType) then
			JMod.StandardResourceDisplay(resourceType, amt, "JMod-Stencil-XS", w / 2, h / 3, 30, true)
		end
		draw.SimpleText(amt, "JMod-Stencil-XS", w / 2, 40, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if self:IsHovered() then
			surface.SetDrawColor(61, 118, 192, 100)
			surface.DrawOutlinedRect(0, 0, w, h, 3)
			surface.SetDrawColor(255, 255, 255, 100)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end
	end

	HelpStr = (resourceType .. " x" .. amt)
	
	Buttalony:SetTooltip(HelpStr)
	
	function Buttalony:DoClick()
		if OpenDropdown then
			OpenDropdown:Remove()
		end

		local frame = vgui.Create("DFrame")
		frame:SetSize(350, 160)
		frame:SetTitle("Resource drop amount")
		frame:Center()
		frame:MakePopup()

		function frame:Paint(w, h)
			BlurBackground(self)
		end

		local amtSlide = vgui.Create("DNumSlider", frame)
		amtSlide:SetText(string.upper(resourceType))
		amtSlide:SetSize(280, 20)
		amtSlide:SetPos((frame:GetWide() - amtSlide:GetWide()) / 2, 30)
		amtSlide:SetMin(0)
		amtSlide:SetMax(amt)
		amtSlide:SetValue(((JMod.Config.ResourceEconomy and JMod.Config.ResourceEconomy.MaxResourceMult) or 1) * 100)
		amtSlide:SetDecimals(0)

		local apply = vgui.Create("DButton", frame)
		apply:SetSize(100, 30)
		apply:SetPos((frame:GetWide() - apply:GetWide()) / 2, 75)
		apply:SetText("DROP")

		apply.DoClick = function()
			net.Start("JMod_ItemInventory")
				net.WriteString("drop_res")
				net.WriteUInt(amtSlide:GetValue(), 12)
				net.WriteString(resourceType)
				net.WriteEntity(invEnt)
			net.SendToServer()
			frame:Close()
			if IsValid(parent) then
				parent:Close()
			end
		end

		if invEnt == Ply then
			local stow = vgui.Create("DButton", frame)
			stow:SetSize(100, 30)
			stow:SetPos((frame:GetWide() - apply:GetWide()) / 2, 120)
			stow:SetText("STOW")

			stow.DoClick = function()
				net.Start("JMod_ItemInventory")
					net.WriteString("stow_res")
					net.WriteUInt(amtSlide:GetValue(), 12)
					net.WriteString(resourceType)
					net.WriteEntity(Ply:GetEyeTrace().Entity)
					net.WriteEntity(invEnt)
				net.SendToServer()
				frame:Close()
				if IsValid(parent) then
					parent:Close()
				end
			end
		else
			local tek = vgui.Create("DButton", frame)
			tek:SetSize(100, 30)
			tek:SetPos((frame:GetWide() - apply:GetWide()) / 2, 120)
			tek:SetText("TAKE")

			tek.DoClick = function()
				net.Start("JMod_ItemInventory")
					net.WriteString("take_res")
					net.WriteUInt(amtSlide:GetValue(), 12)
					net.WriteString(resourceType)
					net.WriteEntity(invEnt)
					net.WriteEntity(invEnt)
				net.SendToServer()
				frame:Close()
				if IsValid(parent) then
					parent:Close()
				end
			end
		end
		
		OpenDropdown = frame
	end
end

local CurrentJModInvScreen = nil
local JModInventoryMenu = function(PlyModel, itemTable)
	local Ply = LocalPlayer()
	--[[if IsValid(PlyModel) then
		Ply = PlyModel
		PlyModel = Ply:GetModel()
	end--]]
	local weight = (Ply.EZarmor) and (Ply.EZarmor.totalWeight) or 0
	if itemTable then
		Ply.JModInv = itemTable
	end

	if IsValid(CurrentSelectionMenu) then return end

	local motherFrame = vgui.Create("DFrame")
	motherFrame:SetSize(800, 400)
	motherFrame:SetVisible(true)
	motherFrame:SetDraggable(true)
	motherFrame:ShowCloseButton(true)
	motherFrame:SetTitle("Inventory | Current Inventory Weight: " .. weight .. "kg. | Current Inventory Volume: " .. tostring(Ply.JModInv.volume) .. "/" .. tostring(Ply.JModInv.maxVolume))

	function motherFrame:Paint()
		BlurBackground(self)
	end

	motherFrame:MakePopup()
	motherFrame:Center()

	function motherFrame:OnClose()
		if OpenDropdown then
			OpenDropdown:Remove()
		end
		CurrentSelectionMenu = nil
	end

	local PDispBG = vgui.Create("DPanel", motherFrame)
	PDispBG:SetPos(200, 30)
	PDispBG:SetSize(200, 360)

	function PDispBG:Paint(w, h)
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(0, 0, w, h)
	end

	local PlayerDisplay = vgui.Create("DModelPanel", PDispBG)
	PlayerDisplay:SetPos(0, 0)
	PlayerDisplay:SetSize(PDispBG:GetWide(), PDispBG:GetTall())
	PlayerDisplay:SetModel(PlyModel or Ply:GetModel())
	local FakePly = PlayerDisplay:GetEntity()
	PlayerDisplay:SetLookAt(FakePly:GetBonePosition(0))
	PlayerDisplay:SetFOV(37)
	PlayerDisplay:SetCursor("arrow")
	motherFrame.PlayerDisplay = PlayerDisplay
	FakePly:SetLOD(0)

	local PDispBT = vgui.Create("DButton", motherFrame)
	PDispBT:SetPos(200, 30)
	PDispBT:SetSize(200, 360)
	PDispBT:SetText("")
	PDispBT:SetTooltip("You can drag the model to rotate it.")

	function PDispBT:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 0)
		surface.DrawRect(0, 0, w, h)
	end

	function PDispBT:DoClick()
		if OpenDropdown then
			OpenDropdown:Remove()
		end
	end

	local entAngs = nil
	local curDif = nil
	local lastCurPos = input.GetCursorPos()
	local doneOnce = false

	function PlayerDisplay:LayoutEntity(ent)

		if not PDispBT:IsDown() then
			entAngs = ent:GetAngles()
			doneOnce = false
		else
			if not doneOnce then
				lastCurPos = input.GetCursorPos()
				doneOnce = true
			end

			curDif = input.GetCursorPos() - lastCurPos
			
			ent:SetAngles( Angle( 0, entAngs.y + curDif % 360, 0 ) )
		end
	end

	FakePly:SetSkin(Ply:GetSkin())
	--FakePly:SetColor(Color(255, 208, 0))
	--FakePly:SetMaterial("models/mat_jack_aidboxside")
	for k, v in pairs( Ply:GetBodyGroups() ) do
		local cur_bgid = Ply:GetBodygroup( v.id )
		FakePly:SetBodygroup( v.id, cur_bgid )
	end
	FakePly.GetPlayerColor = function() return Vector( GetConVarString( "cl_playercolor" ) ) end
	
	
	if Ply.EZarmor.suited then
		FakePly:SetColor(Ply:GetColor())
		if Ply.EZarmor.bodygroups then
			for k, v in pairs(Ply.EZarmor.bodygroups) do
				FakePly:SetBodygroup(k, v)
			end
		end
	end

	function PlayerDisplay:PostDrawModel(ent)
		ent.EZarmor = Ply.EZarmor
		JMod.ArmorPlayerModelDraw(ent, true)
	end

	function motherFrame:OnRemove()
		local ent = PlayerDisplay:GetEntity()
		if not ent.EZarmor then return end
		if not ent.EZarmor.items then return end

		for id, v in pairs(ent.EZarmor.items) do
			if(ent.EZarmorModels[id])then ent.EZarmorModels[id]:Remove() end
		end
		CurrentSelectionMenu = nil
		CurrentJModInvScreen = nil
	end

	local ArmorButtonsLeft = {"head", "eyes", "mouthnose", "ears", "leftshoulder", "leftforearm", "leftthigh", "leftcalf"}
	local ArmorButtonsRight = {"chest", "back", "waist", "pelvis", "rightshoulder", "rightforearm", "rightthigh", "rightcalf"}

	---
	for k, v in ipairs(ArmorButtonsLeft) do
		CreateArmorSlotButton(motherFrame, v, 10, 30 + ((k - 1) * 45))
	end
	---
	for k, v in ipairs(ArmorButtonsRight) do
		CreateArmorSlotButton(motherFrame, v, 410, 30 + ((k - 1) * 45))
	end
	local ShownCommands = {}
	for k, v in ipairs(JMod.EZ_CONCOMMANDS) do
		if v.noShow and v.noShow == true then continue end
		CreateCommandButton(motherFrame, v, 600, 30 + (#ShownCommands * 25), #ShownCommands + 1)
		table.insert(ShownCommands, v.name)
	end
	
	--Item Inventory
	function motherFrame:UpdateItemInventory()
		if self:Find("ItemInventory") then self:Find("ItemInventory"):Remove() end
		local Ply = LocalPlayer()

		local DScrollyPanel = vgui.Create( "DScrollPanel", self, "ItemInventory")
		DScrollyPanel:SetPos(600, 30 + (#ShownCommands * 25))
		DScrollyPanel:SetSize(180, 370 - (#ShownCommands * 25))
		local ShownItems = 0
		local ButtonSize = 55
		if Ply.JModInv then
			for k, v in ipairs(Ply.JModInv.items) do
				CreateInvButton(self, v, (ShownItems % 3 * ButtonSize), (math.floor(ShownItems/3) * ButtonSize), ButtonSize, ButtonSize, DScrollyPanel, Ply)
				ShownItems = ShownItems + 1
			end
			for k, v in pairs(Ply.JModInv.EZresources) do
				CreateResButton(self, k, v, (ShownItems % 3 * ButtonSize), (math.floor(ShownItems/3) * ButtonSize), ButtonSize, ButtonSize, DScrollyPanel, Ply, k)
				ShownItems = ShownItems + 1
			end
		end
		if ShownItems <= 0 then
			if self:Find("GrabInfoLabel") then self:Find("GrabInfoLabel"):Remove() end
			local InfoLabel = vgui.Create("DLabel", self, "GrabInfoLabel")
			InfoLabel:SetPos(610, 100 + (#ShownCommands * 25))
			InfoLabel:SetSize(300, 20)
			InfoLabel:SetText("Use Grab command to pick up items.")
		end
		local weight = (Ply.EZarmor) and (Ply.EZarmor.totalWeight) or 0
		self:SetTitle("Inventory | Current Inventory Weight: " .. weight .. "kg. | Current Inventory Volume: " .. tostring(Ply.JModInv.volume) .. "/" .. tostring(Ply.JModInv.maxVolume))
	end

	motherFrame:UpdateItemInventory()

	function motherFrame:OnKeyCodePressed(num)
		if num == 1 then num = 11 end -- Weird wrap around for the 0 slot
		if ShownCommands[num - 1] then
			Ply:ConCommand("jmod_ez_"..ShownCommands[num - 1])
			motherFrame:Close()
			
			return true
		elseif num == KEY_Q or num == KEY_ESCAPE or num == KEY_E then
			motherFrame:Close()

			return true
		end
	end

	--function motherFrame

	CurrentSelectionMenu = motherFrame
	CurrentJModInvScreen = motherFrame

	local ModifiedMenu = hook.Run("JMod_ModifyInventoryScreen", motherFrame) -- Thinking about this for special item functions

	return motherFrame
end

list.Set("DesktopWindows", "JMod Inventory Button", {
	title = "JMod Inventory",
	icon = JModIcon..".png",
	init = function( icon, window )
		LocalPlayer():ConCommand("jmod_ez_inv")
	end
})

net.Receive("JMod_ItemInventory", function(len, sender) -- for when we pick up stuff with JMOD HANDS
	local invEnt = net.ReadEntity()
	local command = net.ReadString()
	local newInv = net.ReadTable()

	local Ply = LocalPlayer()
	if not(IsValid(invEnt)) then 
		invEnt = Ply
	end

	if newInv and istable(newInv) then
		invEnt.JModInv = newInv
	end

	if not (command or isstring(command)) then return end

	if command == "open_menu" then
		if IsValid(CurrentSelectionMenu) then return end
		local frame = vgui.Create("DFrame")
		frame:SetSize(210, 315)
		frame:SetTitle((invEnt.PrintName or invEnt:GetClass() or "Player"))
		frame:Center()
		frame:MakePopup()
		--frame:SetKeyboardInputEnabled(false)

		frame.OnClose = function()
			if OpenDropdown then
				OpenDropdown:Remove()
			end
			frame = nil
		end

		frame.Paint = function(self, w, h)
			BlurBackground(self)
		end

		function frame:UpdateItemInventory(invEnt, newInv)
			local scrollPanel = vgui.Create("DScrollPanel", self)
			scrollPanel:SetSize(200, 270)
			scrollPanel:SetPos(5, 30)
			
			local ShownItems = 0
			if newInv then
				for k, v in ipairs(newInv.items) do
					CreateInvButton(self, v, (ShownItems % 4 * 50), (math.floor(ShownItems/4) * 50), 50, 50, scrollPanel, invEnt)
					ShownItems = ShownItems + 1
				end
				if newInv.EZresources then
					for k, v in pairs(newInv.EZresources) do
						CreateResButton(self, k, v, (ShownItems % 4 * 50), (math.floor(ShownItems/4) * 50), 50, 50, scrollPanel, invEnt)
						ShownItems = ShownItems + 1
					end
				end
			end
			local Status = vgui.Create("DLabel", self)
			Status:SetSize(200, 10)
			Status:SetPos(2, 300)
			Status:SetText("Current Inventory Space: " .. tostring(invEnt.JModInv.volume) .. "/" .. tostring(invEnt.JModInv.maxVolume))
		end

		frame:UpdateItemInventory(invEnt, newInv)

		CurrentJModInvScreen = frame
	elseif command == "update" then
		if IsValid(CurrentJModInvScreen) then
			CurrentJModInvScreen:UpdateItemInventory(invEnt, newInv)
		end
	elseif command == "take_res" then
		if OpenDropdown then
			OpenDropdown:Remove()
		end

		local ResourceGrabFrame = vgui.Create("DFrame")
		ResourceGrabFrame:SetSize(350, 120)
		ResourceGrabFrame:SetTitle("Resource take amount")
		ResourceGrabFrame:Center()
		ResourceGrabFrame:MakePopup()

		function ResourceGrabFrame:Paint(w, h)
			BlurBackground(self)
		end

		local amtSlide = vgui.Create("DNumSlider", ResourceGrabFrame)
		amtSlide:SetText(string.upper(invEnt.EZsupplies))
		amtSlide:SetSize(280, 20)
		amtSlide:SetPos((ResourceGrabFrame:GetWide() - amtSlide:GetWide()) / 2, 30)
		amtSlide:SetMin(0)
		amtSlide:SetMax(invEnt:GetEZsupplies(invEnt.EZsupplies))
		amtSlide:SetValue(((JMod.Config.ResourceEconomy and JMod.Config.ResourceEconomy.MaxResourceMult) or 1) * 100)
		amtSlide:SetDecimals(0)
		
		local tek = vgui.Create("DButton", ResourceGrabFrame)
		tek:SetSize(ResourceGrabFrame:GetWide() / 2, 30)
		tek:SetPos(ResourceGrabFrame:GetWide() / 4, 80)
		tek:SetText("TAKE")

		function tek:DoClick()
			Ply:ConCommand("jmod_ez_grab " .. tostring(invEnt:EntIndex()) .. " " .. amtSlide:GetValue())
			ResourceGrabFrame:Close()
		end

		OpenDropdown = ResourceGrabFrame
	end
end)

net.Receive("JMod_Inventory", function()
	if IsValid(CurrentJModInvScreen) then
		CurrentJModInvScreen:Close()
	end
	JModInventoryMenu(net.ReadString(), net.ReadTable())
end)

local MachineStatus = {
	[-1] = {"BROKEN", "icon16/bullet_red.png"},
	[0] = {"OFFLINE", "icon16/bullet_black.png"},
	[1] = {"ONLINE", "icon16/bullet_green.png"}
}

net.Receive("JMod_ModifyConnections", function()
	local Ent = net.ReadEntity()
	local Connections = net.ReadTable()
	local Frame = vgui.Create("DFrame")
	Frame:SetTitle("Modify Connections ["..Ent:EntIndex().."]")
	Frame:SetSize(300, 400)
	Frame:Center()
	Frame:MakePopup()

	function Frame:Paint()
		BlurBackground(self)
	end

	local List = vgui.Create("DListView", Frame)
	List:Dock(FILL)
	List:SetMultiSelect(false)
	List:AddColumn("Machine")
	List:AddColumn("EntID")
	List:AddColumn("Status")

	for _, connection in ipairs(Connections) do
		local Line = List:AddLine(connection.DisplayName, connection.Index)
		local Machine = Entity(connection.Index)
		if IsValid(Machine) then
			local StatusIcon = vgui.Create("DImage", Line)
			if Machine.GetState then
				local State = math.Clamp(Machine:GetState(), -1, 1)
				StatusIcon:SetImage(MachineStatus[State][2])
				Line:SetColumnText(3, MachineStatus[State][1])
			else
				StatusIcon:SetImage("icon16/bullet_black.png")
			end
			StatusIcon:SetSize(16, 16)
			StatusIcon:Dock(RIGHT)
		end
	end

	local ButtonOptions = {
		{Text = "Connect New", Func = "connect", Icon = "icon16/connect.png"},
		{Text = "Disconnect", Func = "disconnect", Icon = "icon16/disconnect.png"},
		{Text = "Disconnect All", Func = "disconnect_all", Icon = "icon16/disconnect.png"},
		{Text = "Produce Resource", Func = "produce", Icon = "icon16/brick_add.png"},
		{Text = "Toggle Machine", Func = "toggle", Icon = "icon16/application_lightning.png"}
	}

	List.OnRowSelected = function(panel, rowIndex, row)
		-- Open a dropdown menu to either turn on and off machine or disconnect it
		local DropDown = vgui.Create("DMenu", Frame)
		DropDown:SetSize(150, 20)
		DropDown:SetX(List:GetX() + List:GetWide() - DropDown:GetWide() - 8)
		DropDown:SetY(List:GetY() + 15 + (rowIndex * 17))
		for k, v in ipairs(ButtonOptions) do
			if (v.Func ~= "connect") and (v.Func ~= "disconnect_all") and not (((v.Func == "toggle") or (v.Func == "produce")) and List:GetLine(rowIndex):GetValue(3) == "BROKEN") then
				local Option = DropDown:AddOption(v.Text, function()
					net.Start("JMod_ModifyConnections")
						net.WriteEntity(Ent)
						net.WriteString(v.Func)
						net.WriteEntity(Entity(tonumber(row:GetValue(2))))
					net.SendToServer()
					Frame:Close()
				end)
				Option:SetIcon(v.Icon)
			end
		end
	end

	--[[List.Paint = function(x, y)
		draw.RoundedBox(0, 0, 0, x:GetWide(), x:GetTall(), Color(10, 10, 10, 100))
	end--]]

	for k, v in ipairs(ButtonOptions) do
		if (v.Func ~= "disconnect") then
			local SelectButton = vgui.Create("DButton", Frame)
			SelectButton:SetText(v.Text)
			SelectButton:SetHeight(22)
			SelectButton:Dock(BOTTOM)
			SelectButton.DoClick = function()
				if v.Func == "disconnect_all" then
					local ConfirmPopup = vgui.Create("DFrame")
					ConfirmPopup:SetTitle("Confirm Disconnect All")
					ConfirmPopup:SetSize(300, 100)
					ConfirmPopup:Center()
					ConfirmPopup:MakePopup()

					local ConfirmButton = vgui.Create("DButton", ConfirmPopup)
					ConfirmButton:SetText("Disconnect All")
					ConfirmButton:SetHeight(22)
					ConfirmButton:Dock(BOTTOM)
					ConfirmButton.DoClick = function()
						net.Start("JMod_ModifyConnections")
							net.WriteEntity(Ent)
							net.WriteString(v.Func)
							net.WriteEntity(NULL)
						net.SendToServer()
						ConfirmPopup:Close()
					end
					ConfirmButton:DockPadding(2, 2, 2, 2)

					local CancelButton = vgui.Create("DButton", ConfirmPopup)
					CancelButton:SetText("Cancel")
					CancelButton:SetHeight(22)
					CancelButton:Dock(BOTTOM)
					CancelButton.DoClick = function()
						ConfirmPopup:Close()
					end
					CancelButton:DockPadding(2, 2, 2, 2)
				else
					net.Start("JMod_ModifyConnections")
						net.WriteEntity(Ent)
						net.WriteString(v.Func)
						net.WriteEntity(NULL)
					net.SendToServer()
				end
				Frame:Close()
			end
			SelectButton:DockPadding(2, 2, 2, 2)
			local Icon = vgui.Create("DImage", SelectButton)
			Icon:SetImage(v.Icon)
			Icon:SetSize(16, 16)
			Icon:Dock(RIGHT)
			--[[SelectButton.Paint = function(x, y)
				draw.RoundedBox(0, 0, 0, x:GetWide(), x:GetTall(), Color(10, 10, 10, 100))
			end--]]
		end
	end
end)

local Yeps = {"Yes", "yep", "Of course", "Leave me alone", ">:)"}

net.Receive("JMod_SaveLoadDeposits", function()
	local command = net.ReadString()
	--print(command)
	if command == "warning" then
		local MotherFrame = vgui.Create("DFrame")
		MotherFrame:SetTitle("Warning")
		MotherFrame:SetSize(400, 200)
		MotherFrame:Center()
		MotherFrame:MakePopup()

		local W, H = MotherFrame:GetWide(), MotherFrame:GetTall()

		local WarningText = vgui.Create("DLabel", MotherFrame)
		WarningText:SetPos((W * 0.25) - 10, H * 0.4)
		WarningText:SetSize(300, 20)
		WarningText:SetText("Are you sure you want to remove all deposits?")

		local YepButton = vgui.Create("DButton", MotherFrame)
		YepButton:SetPos(W * 0.25, H * 0.6)
		YepButton:SetSize(200, 50)
		YepButton:SetText(table.Random(Yeps))
		function YepButton:DoClick()
			net.Start("JMod_SaveLoadDeposits")
				net.WriteString("clear")
			net.SendToServer()
			MotherFrame:Close()
		end
	elseif command == "load_list" then
		local Options = net.ReadTable()

		local MotherFrame = vgui.Create("DFrame")
		MotherFrame:SetSize(400, 600)
		MotherFrame:SetVisible(true)
		MotherFrame:SetDraggable(true)
		MotherFrame:ShowCloseButton(true)
		MotherFrame:SetTitle("Load_Options")
		MotherFrame:Center()
		MotherFrame:MakePopup()

		function MotherFrame:Paint()
			BlurBackground(self)
		end	

		local Dropdown = vgui.Create("DPanel", MotherFrame)
		Dropdown:SetSize(MotherFrame:GetWide(), #Options * 40)
		local ecks, why = gui.MousePos()
		local harp, darp = MotherFrame:GetPos()
		local fack, fock = MotherFrame:GetSize()
		local floop, florp = Dropdown:GetSize()
		--Dropdown:SetPos(math.Clamp(ecks - harp, 0, fack - floop), math.Clamp(why - darp, 0, fock - florp))
		--Dropdown:SetPos(0, 20)
		Dropdown:Dock(TOP)

		function Dropdown:Paint(w, h)
			surface.SetDrawColor(70, 70, 70, 220)
			surface.DrawRect(0, 0, w, h)
		end

		for k, option in pairs(Options) do
			local Butt = vgui.Create("DButton", Dropdown)
			Butt:SetPos(5, k * 40 - 35)
			Butt:SetSize(floop - 20, 25)
			Butt:SetText(option)

			function Butt:DoClick()
				net.Start("JMod_SaveLoadDeposits")
					net.WriteString("load")
					net.WriteString(option)
				net.SendToServer()
				MotherFrame:Close()
			end
		end
	end
end)