local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local MenuOpen = false
local YesMat = Material("icon16/accept.png")
local NoMat = Material("icon16/cancel.png")
local FavMat = Material("icon16/star.png")
local FriendMat = Material("icon16/user_green.png")
local NotFriendMat = Material("icon16/user_red.png")

local SpecialIcons = {
	["geothermal"] = Material("ez_resource_icons/geothermal.png"),
	["warning"] = Material("ez_misc_icons/warning.png")
}

local RankIcons = {Material("ez_rank_icons/grade_1.png"), Material("ez_rank_icons/grade_2.png"), Material("ez_rank_icons/grade_3.png"), Material("ez_rank_icons/grade_4.png"), Material("ez_rank_icons/grade_5.png")}

local SelectionMenuIcons = {}
local LocallyAvailableResources = nil -- this is here solely for caching and efficieny purposes, i sure hope it doesn't bite me in the ass
local QuestionMarkIcon = Material("question_mark.png")

local function BlurBackground(panel)
	if not (IsValid(panel) and panel:IsVisible()) then return end
	local layers, density, alpha = 1, 1, 255
	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blurMat)
	local FrameRate, Num, Dark = 1 / FrameTime(), 5, 150

	for i = 1, Num do
		blurMat:SetFloat("$blur", (i / layers) * density * Dynamic)
		blurMat:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
	end

	surface.SetDrawColor(0, 0, 0, Dark * Dynamic)
	surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	Dynamic = math.Clamp(Dynamic + (1 / FrameRate) * 7, 0, 1)
end

local function PopulateList(parent, friendList, myself, W, H)
	parent:Clear()
	local Y = 0

	for k, playa in pairs(player.GetAll()) do
		if playa ~= myself then
			playa.JModFriends = playa.JModFriends or {}
			local IsFriendBool = table.HasValue(playa.JModFriends, myself)
			local Panel = parent:Add("DPanel")
			Panel:SetSize(W - 35, 20)
			Panel:SetPos(0, Y)

			function Panel:Paint(w, h)
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(0, 0, w, h)
				draw.SimpleText((playa:IsValid() and playa:Nick()) or "DISCONNECTED", "DermaDefault", 5, 3, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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

				PopulateList(parent, friendList, myself, W, H)
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
		draw.SimpleText(typ, font, x - siz / 2 - 10, y, Col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		draw.SimpleText(UnitText, font, x + siz / 2 + 10, y, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

function JMod.StandardRankDisplay(rank, x, y, siz, opacity)
	font = font or "JMod-Stencil"
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

	if MenuOpen then return end
	MenuOpen = true
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
		MenuOpen = false
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
	PopulateList(Scroll, FriendList, Myself, W, H)
end)

net.Receive("JMod_ColorAndArm", function()
	local Ent, NextColorCheck = net.ReadEntity(), 0
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
			local Col = Picker:GetColor()
			net.Start("JMod_ColorAndArm")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r, Col.g, Col.b))
			net.WriteBit(false)
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
	Butt:SetSize(190, 50)
	Butt:SetText("ARM")

	function Butt:DoClick()
		local Col = Picker:GetColor()
		net.Start("JMod_ColorAndArm")
		net.WriteEntity(Ent)
		net.WriteColor(Color(Col.r, Col.g, Col.b))
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end
end)

net.Receive("JMod_ArmorColor", function()
	local Ent, NextColorCheck = net.ReadEntity(), 0
	if not IsValid(Ent) then return end
	local Frame = vgui.Create("DFrame")
	Frame:SetSize(200, 300)
	Frame:SetPos(ScrW() * .4 - 200, ScrH() * .5)
	Frame:SetDraggable(true)
	Frame:ShowCloseButton(true)
	Frame:SetTitle("EZ Armor")
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
			local Col = Picker:GetColor()
			Col.r = math.max(Col.r, 50)
			Col.g = math.max(Col.g, 50)
			Col.b = math.max(Col.b, 50)
			net.Start("JMod_ArmorColor")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r, Col.g, Col.b))
			net.WriteBit(false)
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
	Butt:SetSize(190, 50)
	Butt:SetText("EQUIP")

	function Butt:DoClick()
		local Col = Picker:GetColor()
		Col.r = math.max(Col.r, 50)
		Col.g = math.max(Col.g, 50)
		Col.b = math.max(Col.b, 50)
		net.Start("JMod_ArmorColor")
		net.WriteEntity(Ent)
		net.WriteColor(Color(Col.r, Col.g, Col.b))
		net.WriteBit(true)
		net.SendToServer()
		Frame:Close()
	end
end)

-- local FavIcon=Material("white_star_64.png")
local function PopulateItems(parent, items, typ, motherFrame, entity, enableFunc, clickFunc)
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
				desc = desc .. resourceName .. " x" .. tostring(resourceAmt) .. ", "
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
						surface.PlaySound("snds_jack_gmod/ez_gui/hover_ready.wav")
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
			local ItemIcon = SelectionMenuIcons[itemName]

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

				surface.PlaySound("snds_jack_gmod/ez_gui/click_big.wav")
				motherFrame.positiveClosed = true
				motherFrame:Close()
			else
				surface.PlaySound("snds_jack_gmod/ez_gui/miss.wav")
			end
		end

		Y = Y + 47
	end
end

local function StandardSelectionMenu(typ, displayString, data, entity, enableFunc, clickFunc, sidePanelFunc)
	-- first, populate icons
	for name, info in pairs(data) do
		if not SelectionMenuIcons[name] then
			if file.Exists("materials/jmod_selection_menu_icons/" .. tostring(name) .. ".png", "GAME") then
				SelectionMenuIcons[name] = Material("jmod_selection_menu_icons/" .. tostring(name) .. ".png")
			elseif info.results and file.Exists("materials/entities/" .. tostring(info.results) .. ".png", "GAME") then
				SelectionMenuIcons[name] = Material("entities/" .. tostring(info.results) .. ".png")
			else
				-- special logic for random tables and resources and such
				local itemClass = info.results

				if type(itemClass) == "table" then
					itemClass = itemClass[1]
				end

				if type(itemClass) == "table" then
					itemClass = itemClass[1]
				end

				if itemClass == "RAND" then
					SelectionMenuIcons[name] = QuestionMarkIcon
				elseif type(itemClass) == "string" then
					local IsResource = false

					for k, v in pairs(JMod.EZ_RESOURCE_ENTITIES) do
						if v == itemClass then
							IsResource = true
							SelectionMenuIcons[name] = JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[k]
						end
					end

					if not IsResource then
						SelectionMenuIcons[name] = Material("entities/" .. itemClass .. ".png")
					end
				end
			end
		end
	end

	-- then, populate info with nearby available resources
	LocallyAvailableResources = JMod.CountResourcesInRange(entity:GetPos(), 150, entity)
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
			surface.PlaySound("snds_jack_gmod/ez_gui/menu_open.wav")
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
			surface.PlaySound("snds_jack_gmod/ez_gui/menu_close.wav")
		end
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
		TabPanelX = W * .25 + 10
		TabPanelW = W * .75 - 20
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
			surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.wav")
			ActiveTab = self.Category
			PopulateItems(ActiveTabPanel, Categories[ActiveTab], typ, MotherFrame, entity, enableFunc, clickFunc)
		end

		tabX = tabX + TextWidth + 15
	end

	PopulateItems(ActiveTabPanel, Categories[ActiveTab], typ, MotherFrame, entity, enableFunc, clickFunc)
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

	StandardSelectionMenu('crafting', "EZ Tool Box", Buildables, Kit, function(name, info, ply, ent) -- enable func
return JMod.HaveResourcesToPerformTask(ent:GetPos(), 150, info.craftingReqs, ent, LocallyAvailableResources) end, function(name, info, ply, ent)
		-- click func
		net.Start("JMod_EZtoolbox")
		net.WriteEntity(ent)
		net.WriteString(name)
		net.SendToServer()
	end, nil)
end)

-- no side display for now
net.Receive("JMod_EZworkbench", function()
	local Bench = net.ReadEntity()
	local Buildables = net.ReadTable()

	StandardSelectionMenu('crafting', Bench.PrintName, Buildables, Bench, function(name, info, ply, ent) -- enable func
return JMod.HaveResourcesToPerformTask(ent:GetPos(), 200, info.craftingReqs, ent, LocallyAvailableResources) end, function(name, info, ply, ent)
		-- click func
		net.Start("JMod_EZworkbench")
		net.WriteEntity(ent)
		net.WriteString(name)
		net.SendToServer()
	end, nil)
end)

-- no side display for now
-- todo: this menu will be deprecated when we get the inventory system
net.Receive("JMod_UniCrate", function()
	local box = net.ReadEntity()
	local items = net.ReadTable()
	local frame = vgui.Create("DFrame")
	frame:SetSize(200, 300)
	frame:SetTitle("Storage Crate")
	frame:Center()
	frame:MakePopup()

	frame.OnClose = function()
		frame = nil
	end

	frame.Paint = function(self, w, h)
		BlurBackground(self)
	end

	local scrollPanel = vgui.Create("DScrollPanel", frame)
	scrollPanel:SetSize(190, 270)
	scrollPanel:SetPos(5, 30)
	local layout = vgui.Create("DIconLayout", scrollPanel)
	layout:SetSize(190, 270)
	layout:SetPos(0, 0)
	layout:SetSpaceY(5)

	for class, tbl in pairs(items) do
		local sent = scripted_ents.Get(class)
		local button = vgui.Create("DButton", layout)
		button:SetSize(190, 25)
		button:SetText("")

		function button:Paint(w, h)
			surface.SetDrawColor(50, 50, 50, 100)
			surface.DrawRect(0, 0, w, h)
			local msg = sent.PrintName .. " x" .. tbl[1] .. " (" .. (tbl[2] * tbl[1]) .. " volume)"
			draw.SimpleText(msg, "DermaDefault", 5, 3, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		button.DoClick = function()
			net.Start("JMod_UniCrate")
			net.WriteEntity(box)
			net.WriteString(class)
			net.SendToServer()
			frame:Close()
		end
	end
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
		Pts = Pts - v
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

		function Panel:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)
			draw.SimpleText(attrib .. ": " .. Specs[attrib], "DermaDefault", 137, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
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
		local Col = (ErrorTime > CurTime() and Color(255, 0, 0, 255)) or Color(255, 255, 255, 255)
		draw.SimpleText("Available spec points: " .. AvailPts, "DermaDefault", 250, 0, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText("Trade traits to achieve desired performance", "DermaDefault", 250, 20, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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

		local tbl = {radio:GetColor(), "Aid Radio", Color(255, 255, 255), ": ", msg}

		if parrot then
			tbl = {Color(200, 200, 200), "(HIDDEN) ", LocalPlayer(), Color(255, 255, 255), ": ", Color(200, 200, 200), msg}
		end

		chat.AddText(unpack(tbl))

		if LocalPlayer():GetPos():DistToSqr(radio:GetPos()) > 200 * 200 then
			local radiovoices = file.Find("sound/npc/combine_soldier/vo/*.wav", "GAME")

			for i = 1, math.Round(string.len(msg) / 15) do
				timer.Simple(i * .75, function()
					if IsValid(radio) and (radio:GetState() > 0) then
						LocalPlayer():EmitSound("/npc/combine_soldier/vo/" .. radiovoices[math.random(1, #radiovoices)], 65, 120, 0.25)
					end
				end)
			end
		end

		return
	end

	local Radio = net.ReadEntity()
	local Orderables = net.ReadTable()

	StandardSelectionMenu('selecting', "EZ Radio", Orderables, Radio, function(name, info, ply, ent)
		-- enable func
		local override, msg = hook.Run("JMod_CanRadioRequest", ply, ent, name)
		if override == false then return false end

		return true
	end, function(name, info, ply, ent)
		-- click func
		ply:ConCommand("say supply radio: " .. name)
	end, nil)
end)

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
		end
	},
	{
		title = "Repair",
		visTestFunc = function(slot, itemID, itemData, itemInfo) return itemData.dur < itemInfo.dur * .9 end,
		actionFunc = function(slot, itemID, itemData, itemInfo)
			net.Start("JMod_Inventory")
			net.WriteInt(3, 8) -- repair
			net.WriteString(itemID)
			net.SendToServer()
		end
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
		end
	}
}

local ArmorResourceNiceNames = {
	chemicals = "Chemicals",
	power = "Electricity"
}

local OpenDropdown = nil

local function CreateArmorSlotButton(parent, slot, x, y)
	local Buttalony, Ply = vgui.Create("DButton", parent), LocalPlayer()
	Buttalony:SetSize(180, 40)
	Buttalony:SetPos(x, y)
	Buttalony:SetText("")
	Buttalony:SetCursor("hand")
	local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(Ply.EZarmor, slot)

	function Buttalony:Paint(w, h)
		surface.SetDrawColor(50, 50, 50, 100)
		surface.DrawRect(0, 0, w, h)
		draw.SimpleText(JMod.ArmorSlotNiceNames[slot], "DermaDefault", Buttalony:GetWide() / 2, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if ItemID then
			local Str = ItemData.name --..": "..math.Round(ItemData.dur/ItemInfo.dur*100).."%"

			if ItemData.tgl and ItemInfo.tgl.slots[slot] == 0 then
				Str = "DISENGAGED"
			end

			draw.SimpleText(Str, "DermaDefault", Buttalony:GetWide() / 2, 25, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	if ItemID then
		local str = "Durability: " .. math.Round(ItemData.dur, 1) .. "/" .. ItemInfo.dur

		if ItemInfo.chrg then
			for resource, maxAmt in pairs(ItemInfo.chrg) do
				str = str .. "\n" .. ArmorResourceNiceNames[resource] .. ": " .. math.Round(ItemData.chrg[resource], 1) .. "/" .. maxAmt
			end
		end

		Buttalony:SetTooltip(str)
	else
		Buttalony:SetTooltip("slot is empty")
	end

	function Buttalony:DoClick()
		if OpenDropdown then
			OpenDropdown:Remove()
		end

		if not ItemID then return end
		local Options = {}

		for k, option in pairs(ArmorSlotButtons) do
			if not option.visTestFunc or option.visTestFunc(slot, ItemID, ItemData, ItemInfo) then
				table.insert(Options, option)
			end
		end

		local Dropdown = vgui.Create("DPanel", parent)
		Dropdown:SetSize(Buttalony:GetWide(), #Options * 40)
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
			Butt:SetPos(5, k * 40 - 35)
			Butt:SetSize(floop - 10, 30)
			Butt:SetText(option.title)

			function Butt:DoClick()
				option.actionFunc(slot, ItemID, ItemData, ItemInfo)
				parent:Close()
			end
		end

		OpenDropdown = Dropdown
	end
end

net.Receive("JMod_Inventory", function()
	local Ply = LocalPlayer()
	local weight = Ply.EZarmor.totalWeight
	local motherFrame = vgui.Create("DFrame")
	motherFrame:SetSize(600, 400)
	motherFrame:SetVisible(true)
	motherFrame:SetDraggable(true)
	motherFrame:ShowCloseButton(true)
	motherFrame:SetTitle("Inventory | Current Armour Weight: " .. weight .. "kg.")

	function motherFrame:Paint()
		BlurBackground(self)
	end

	motherFrame:MakePopup()
	motherFrame:Center()

	function motherFrame:OnKeyCodePressed(key)
		if key == KEY_Q or key == KEY_ESCAPE or key == KEY_E then
			self:Close()
		end
	end

	function motherFrame:OnClose()
		if OpenDropdown then
			OpenDropdown:Remove()
		end
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
	PlayerDisplay:SetModel(Ply:GetModel())
	PlayerDisplay:SetLookAt(PlayerDisplay:GetEntity():GetBonePosition(0))
	PlayerDisplay:SetFOV(37)
	PlayerDisplay:SetCursor("arrow")
	local Ent = PlayerDisplay:GetEntity()

	local PDispBT = vgui.Create("DButton", motherFrame)
	PDispBT:SetPos(200, 30)
	PDispBT:SetSize(200, 360)
	PDispBT:SetText("")

	function PDispBT:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 0)
		surface.DrawRect(0, 0, w, h)
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

	Ent:SetSkin(Ply:GetSkin())
	for k, v in pairs( Ply:GetBodyGroups() ) do
		local cur_bgid = Ply:GetBodygroup( v.id )
		Ent:SetBodygroup( v.id, cur_bgid )
	end
	Ent.GetPlayerColor = function() return Vector( GetConVarString( "cl_playercolor" ) ) end
	

	if Ply.EZarmor.suited and Ply.EZarmor.bodygroups then
		PlayerDisplay:SetColor(Ply:GetColor())

		for k, v in pairs(Ply.EZarmor.bodygroups) do
			Ent:SetBodygroup(k, v)
		end
	end

	function PlayerDisplay:PostDrawModel(ent)
		ent.EZarmor = Ply.EZarmor
		JMod.ArmorPlayerModelDraw(ent)
	end

	function PlayerDisplay:DoClick()
		if OpenDropdown then
			OpenDropdown:Remove()
		end
	end

	function motherFrame:OnRemove()
		ent = PlayerDisplay:GetEntity()
		if not ent.EZarmor then return end
		if not ent.EZarmor.items then return end

		for id, v in pairs(ent.EZarmor.items) do
			if(ent.EZarmorModels[id])then ent.EZarmorModels[id]:Remove() end
		end
	end

	---
	CreateArmorSlotButton(motherFrame, "head", 10, 30)
	CreateArmorSlotButton(motherFrame, "eyes", 10, 75)
	CreateArmorSlotButton(motherFrame, "mouthnose", 10, 120)
	CreateArmorSlotButton(motherFrame, "ears", 10, 165)
	CreateArmorSlotButton(motherFrame, "leftshoulder", 10, 210)
	CreateArmorSlotButton(motherFrame, "leftforearm", 10, 255)
	CreateArmorSlotButton(motherFrame, "leftthigh", 10, 300)
	CreateArmorSlotButton(motherFrame, "leftcalf", 10, 345)
	---
	CreateArmorSlotButton(motherFrame, "rightshoulder", 410, 30)
	CreateArmorSlotButton(motherFrame, "rightforearm", 410, 75)
	CreateArmorSlotButton(motherFrame, "chest", 410, 120)
	CreateArmorSlotButton(motherFrame, "back", 410, 165)
	CreateArmorSlotButton(motherFrame, "pelvis", 410, 210)
	CreateArmorSlotButton(motherFrame, "rightthigh", 410, 255)
	CreateArmorSlotButton(motherFrame, "rightcalf", 410, 300)
end)
