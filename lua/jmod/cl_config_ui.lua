local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local arrowMat = Material("icon16/arrow_right.png")
local addIconMat = Material("icon16/add.png")
local removeIconMat = Material("icon16/delete.png")
local infoIconMat = Material("icon16/information.png")
local changes_made = false

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

--[[-----------------------------------+
|             For ConfigUI,            |
|   Parses the settings in the config  |
|    then draws the correct controls   |
|           for each setting.          |
+-------------------------------------]]

local function PopulateControls(parent, data, motherFrame, isCraftables)
	parent:Clear()
	local W, H = parent:GetWide(), parent:GetTall()
	local Scroll = vgui.Create("DScrollPanel", parent)
	Scroll:SetSize(W - 20, H - 20)
	Scroll:SetPos(10, 10)
	local sbar = Scroll:GetVBar()
	function sbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
	end
	function sbar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 200))
	end
	function sbar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 200))
	end
	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(75, 75, 75, 200))
	end
	---
	local Y = 0

	local function handle_settings(control_table, AlphabetizedSettings, subcatName)
		if subcatName then
			local subcatLabel = Scroll:Add("DPanel")
			subcatLabel:SetSize(W - 40, 42)
			subcatLabel:SetPos(0, Y)

			function subcatLabel:Paint(w, h)

				surface.SetDrawColor(255, 255, 255, 60)
				surface.DrawLine(w/2 - 75, 2, w/2 + 75, 2)
				surface.DrawLine(w/2 - 75, 39, w/2 + 75, 39)

				draw.SimpleText(subcatName, "DermaLarge", w/2, 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			Y = Y + 47
		end

		for k, setting in pairs(AlphabetizedSettings) do

			--if setting == "AltFunctionKey" then continue end
			
			local control_frame = Scroll:Add("DPanel")
			control_frame:SetSize(W - 40, 42)
			control_frame:SetPos(0, Y)

			function control_frame:Paint(w, h)

				surface.SetDrawColor(50, 50, 50, 60)

				surface.DrawRect(0, 0, w, h)

				draw.SimpleText(setting, "DermaDefault", 5, 15, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
			
			if setting == "AltFunctionKey" then
				local comboBox = control_frame:Add("DComboBox")
				comboBox:SetSize(107,16)
				comboBox:SetPos(control_frame:GetWide() - 243, control_frame:GetTall()/2 - 8)

				comboBox:AddChoice("+walk", IN_WALK)   -- 1
				comboBox:AddChoice("+speed", IN_SPEED) -- 2
				comboBox:AddChoice("+alt1", IN_ALT1)   -- 3
				comboBox:AddChoice("+alt2", IN_ALT2)   -- 4

				comboBox:SetSortItems(false)
				
				local choices = {IN_WALK,IN_SPEED,IN_ALT1,IN_ALT2}

				for k,v in ipairs(choices) do
					if v == control_table[setting] then
						comboBox:ChooseOptionID(k)
						continue
					end
				end

				function comboBox:OnSelect(i,v,d)
					control_table[setting] = d
					changes_made = true
				end

				local whatButt = control_frame:Add("DButton")
				local x,y = comboBox:GetPos()
				local w,h = comboBox:GetSize()
				whatButt:SetSize(16,16)
				whatButt:SetPos(x + w + 5, y)
				whatButt:SetText("")
				whatButt:SetTooltip("Click me for more info on what these options mean.")

				function whatButt:Paint(w,h)
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(infoIconMat)
					surface.DrawTexturedRect(0, 0, w, h)
				end

				function whatButt:DoClick()
					gui.OpenURL("https://wiki.facepunch.com/gmod/Enums/IN")
				end

				Y = Y + 47
				continue
			end

			if type(control_table[setting]) == "number" then
				
				local slider = control_frame:Add("DNumSlider")
				slider:SetSize(control_frame:GetWide()/2,14)
				slider:SetPos((control_frame:GetWide() - 10) - control_frame:GetWide()/2, control_frame:GetTall()/2 - 7)
				slider:SetDefaultValue(control_table[setting])
				slider:SetMax(10)
				if setting=="RestrictedPackageShipTime" then slider:SetMax(5000) end
 				slider:SetMin(0)
				slider:SetDecimals(2)
				slider:ResetToDefaultValue()

				function slider:OnValueChanged(val)
					control_table[setting] = math.Round(val, 2)
					changes_made = true
				end

			end

			if type(control_table[setting]) == "boolean" then
				local checkbox = control_frame:Add("DCheckBox")
				checkbox:SetSize(14,14)
				checkbox:SetPos(control_frame:GetWide() - 243, control_frame:GetTall()/2 - 7)
				checkbox:SetValue(control_table[setting])

				function checkbox:OnChange(val)
					control_table[setting] = val
					changes_made = true
				end
			end

			if type(control_table[setting]) == "table" then

				local tablePanel = nil
				local addButton = nil
				local isOpen = false

				local arrow_icon = control_frame:Add("DSprite")
				arrow_icon:SetSize(16,16)
				arrow_icon:SetPos(control_frame:GetWide() - (243), control_frame:GetTall()/2)

				local start = SysTime()
				local lerp_reset = false
				local firstTime = true

				function arrow_icon:Paint(w,h)
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial(arrowMat)

					if lerp_reset then 
						start = SysTime()
						lerp_reset = false
					end

					if firstTime then
						if isOpen then
							firstTime = false
						end
						surface.DrawTexturedRectRotated(0,0,w,h,0)
						return
					end

					if isOpen then
						surface.DrawTexturedRectRotated(0,0,w,h,Lerp((SysTime() - start) / 0.25, 0, -90))
					else
						surface.DrawTexturedRectRotated(0,0,w,h,Lerp((SysTime() - start) / 0.25, -90, 0))
					end
				end

				local butt = control_frame:Add("DButton")
				butt:SetSize(control_frame:GetSize())
				butt:SetText("")
				function butt:Paint(w,h) end -- make it invis

				function butt:DoClick()

					lerp_reset = true -- reset the timer used for the arrow animation

					if isOpen and tablePanel then
						tablePanel:SizeTo(tablePanel:GetWide(), 0, 0.25)

						timer.Simple(0.25, function() tablePanel:Remove();addButton:Remove() end)
					else
						tablePanel = Scroll:Add("DScrollPanel")
						local control_frame_x,control_frame_y = control_frame:GetPos()
						tablePanel:SetSize(control_frame:GetWide(), 150)
						tablePanel:SetPos(control_frame_x, control_frame_y + control_frame:GetTall())
						tablePanel:SlideDown(0.25)

						local sbar = tablePanel:GetVBar()
						function sbar:Paint(w, h)
							draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
						end
						function sbar.btnUp:Paint(w, h)
							draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
						end
						function sbar.btnDown:Paint(w, h)
							draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
						end
						function sbar.btnGrip:Paint(w, h)
							draw.RoundedBox(0, 0, 0, w, h, Color(75, 75, 75))
						end
						
						function tablePanel:Paint(w,h)
							surface.SetDrawColor(50, 50, 50, 60)
							surface.DrawRect(0, 0, w, h)

							BlurBackground(self)
						end

						function setup_table_value(index, value)

							if value == nil then value = "" end

							local holder_panel = tablePanel:Add("DPanel")
							holder_panel:SetSize(tablePanel:GetWide(), 16)
							holder_panel:SetText(value)
							holder_panel:Dock(TOP)
							holder_panel:DockMargin(0,5,0,5)
							function holder_panel:Paint() return end


							local textEntry = holder_panel:Add("DTextEntry")
							textEntry:SetSize(tablePanel:GetWide() - 40, 16)
							textEntry:SetPos(0,0)
							textEntry:SetText(value)
							textEntry:SetUpdateOnType(true)

							local lastval = value

							function textEntry:OnValueChange(val)
								if val != lastval then
									control_table[setting][index] = val
									changes_made = true
								end
								lastval = val
							end

							function textEntry:Paint(w,h)
								surface.SetDrawColor(100, 100, 100, 60)
								surface.DrawRect(0, 0, w, h)
								surface.DrawOutlinedRect(0,0,w,h)
								surface.SetDrawColor(255, 255, 255, 255)

								draw.SimpleText(self:GetText(), DermaDefault, 5,7,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

								if math.Round(CurTime() * 2.5) % 2 == 0 and self:HasFocus() then
									surface.SetFont("DermaDefault")
									local tw,th = surface.GetTextSize(self:GetText())
									surface.SetDrawColor(255, 255, 255, 255)					-- text cursor
									surface.DrawLine(tw + 6, 2, tw + 6, h-3)
								end

							end

							local removeButt = holder_panel:Add("DButton")
							removeButt:SetSize(16,16)
							removeButt:SetPos(holder_panel:GetWide() - 35, 0)
							removeButt:SetText("")

							function removeButt:Paint(w,h)
								surface.SetDrawColor(255, 255, 255, 255)
								surface.SetMaterial(removeIconMat)
								surface.DrawTexturedRect(0, 0, w, h)
							end

							function removeButt:DoClick()
								table.remove(control_table[setting], index)
								changes_made = true
								holder_panel:Remove()
								self:Remove()
							end
						end

						for index,value in ipairs(control_table[setting]) do
							setup_table_value(index, value)
						end

						addButton = control_frame:Add("DButton")
						addButton:SetSize(16,16)
						local arrow_x,arrow_y = arrow_icon:GetPos()
						addButton:SetPos((control_frame:GetWide() - 243) + 16, control_frame:GetTall()/2 -8)
						addButton:SetText("")

						function addButton:DoClick()
							local i = #control_table[setting] + 1
							table.insert(control_table[setting], i, "")
							changes_made = true
							setup_table_value(i, nil)
						end

						function addButton:Paint(w, h)
							if isOpen then
								surface.SetDrawColor(255, 255, 255, Lerp((SysTime() - start) / 0.25, 0, 255))
							else
								surface.SetDrawColor(255, 255, 255, Lerp((SysTime() - start) / 0.25, 255, 0))
							end
							surface.SetMaterial(addIconMat)
							surface.DrawTexturedRect(0, 0, w, h)
						end
					end
					isOpen = !isOpen
				end
			end


			Y = Y + 47
		end
	end

	local function handle_craftables(selectedMachine)

		local selectedMachine = selectedMachine or "workbench"

		local craftables = {}

		local function sortData(itemInfo, itemName, machine)
			craftables[machine] = craftables[machine] or {}
			
			local category = itemInfo.category or "other"
			craftables[machine][category] = craftables[machine][category] or {}
			
			craftables[machine][category][itemName] = itemInfo
		end

		for itemName, itemInfo in pairs(data) do
			local machine = itemInfo.craftingType or "other"

			if istable(machine) then
				for _,m in pairs(machine) do
					fuckthis(itemInfo,itemName,m)
					print(m)
				end
			else
				fuckthis(itemInfo,itemName,machine)
			end

		end

		local holder_panel = parent:Add("DPanel")
		holder_panel:SetSize(W,H)
		function holder_panel:Paint() end

		local machinesPanel = holder_panel:Add("DScrollPanel")
		machinesPanel:SetSize(W/4, H - 20)
		machinesPanel:Dock(LEFT)
		machinesPanel:DockMargin(5,5,0,5)
		function machinesPanel:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 50)
			surface.DrawRect(0, 0, w, h)
		end

		local w, h = machinesPanel:GetSize()
		craftablesPanel = holder_panel:Add("DScrollPanel")
		craftablesPanel:SetSize(630, H - 20)
		craftablesPanel:Dock(LEFT)
		craftablesPanel:DockMargin(5,5,5,5)
		function craftablesPanel:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 50)
			surface.DrawRect(0, 0, w, h)
		end
		local sbar = craftablesPanel:GetVBar()
		function sbar:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
		end
		function sbar.btnUp:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
		end
		function sbar.btnDown:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
		end
		function sbar.btnGrip:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(75, 75, 75))
		end

		for k,v in pairs(craftables) do
			machineButton = machinesPanel:Add("DButton")
			machineButton:SetHeight(50)
			machineButton:Dock(TOP)
			machineButton:DockMargin(5,5,5,5)

			label = k 

			label = string.SetChar(label, 1, string.sub(string.upper(label), 1, 1))
			machineButton:SetText(label)
			machineButton:SetTextColor(color_white)

			function machineButton:Paint(w,h)

				local Hovr = self:IsHovered()
				local Col = (Hovr and 80) or 20
				surface.SetDrawColor(0, 0, 0, (k == selectedMachine and 100) or Col)

				surface.DrawRect(0, 0, w, h)

				--BlurBackground(self)
			end

			function machineButton:DoClick()
				handle_craftables(string.lower(self:GetText()))
				surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.wav")
				holder_panel:Remove()
			end
		end

		local Y = 0

		local w, h = craftablesPanel:GetSize()
		for k,v in pairs(craftables[selectedMachine]) do
			local catLabel = craftablesPanel:Add("DPanel")
			catLabel:SetSize(w - 40, 42)
			catLabel:SetPos(0, Y)

			function catLabel:Paint(w, h)

				surface.SetDrawColor(255, 255, 255, 60)
				surface.DrawLine(w/2 - 75, 2, w/2 + 75, 2)
				surface.DrawLine(w/2 - 75, 39, w/2 + 75, 39)

				draw.SimpleText(k, "DermaLarge", w/2, 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			Y = Y + 47
			for k,v in pairs(v) do
				if not JMod.SelectionMenuIcons[k] then
					if file.Exists("materials/jmod_selection_menu_icons/" .. tostring(k) .. ".png", "GAME") then
						JMod.SelectionMenuIcons[k] = Material("jmod_selection_menu_icons/" .. tostring(k) .. ".png")
					elseif v.results and file.Exists("materials/entities/" .. tostring(v.results) .. ".png", "GAME") then
						JMod.SelectionMenuIcons[k] = Material("entities/" .. tostring(v.results) .. ".png")
					else
						-- special logic for random tables and resources and such
						local itemClass = v.results

						if type(itemClass) == "table" then
							itemClass = itemClass[1]
						end

						if type(itemClass) == "table" then
							itemClass = itemClass[1]
						end

						if itemClass == "RAND" then
							JMod.SelectionMenuIcons[k] = QuestionMarkIcon
						elseif type(itemClass) == "string" then
							local IsResource = false

							for k, v in pairs(JMod.EZ_RESOURCE_ENTITIES) do
								if v == itemClass then
									IsResource = true
									JMod.SelectionMenuIcons[k] = JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[k]
								end
							end

							if not IsResource then
								JMod.SelectionMenuIcons[k] = Material("entities/" .. itemClass .. ".png")
							end
						end
					end
				end

				local Butt = craftablesPanel:Add("DButton")
				Butt:SetSize(w - 20, 42)
				Butt:SetPos(0, Y)
				Butt:SetText("")
				local typ = "crafting"
				local itemInfo = v
				local itemName = k
				local desc = itemInfo.description or ""

				if typ == "crafting" then
					desc = desc .. "\n "

					for resourceName, resourceAmt in pairs(itemInfo.craftingReqs) do
						desc = desc .. resourceName .. " x" .. tostring(resourceAmt) .. ", "
					end
				end

				Butt:SetTooltip(desc)
				Butt.enabled = true
				Butt:SetMouseInputEnabled(true)
				Butt.hovered = false

				function Butt:Paint(w, h)
					local Hovr = self:IsHovered()

					if Hovr then
						if not self.hovered then
							self.hovered = true
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
							local Txt = "x" .. tostring(resourceAmt)
							surface.SetFont("DermaDefault")
							local TxtSize = surface.GetTextSize(Txt)
							draw.SimpleText(Txt, "DermaDefault", X - TxtSize, 15, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
							X = X - (TxtSize + 3)
							surface.SetMaterial(JMod.EZ_RESOURCE_TYPE_ICONS_SMOL[resourceName])
							surface.SetDrawColor(255, 255, 255, 255)
							surface.DrawTexturedRect(X - 32, 5, 32, 32)
							X = X - (32 + 6)
						end
					end
				end
				Y = Y + 47
			end
		end
	end

	if isCraftables then
		handle_craftables()
		return
	end

	local AlphabetizedNormal = table.GetKeys(data["settings"])
	table.sort(AlphabetizedNormal, function(a, b) return a < b end)

	handle_settings(data["settings"],AlphabetizedNormal, nil) -- normal settings not in sub catagories

	local AlphabetizedSubcats = table.GetKeys(data["subcats"])
	table.sort(AlphabetizedSubcats, function(a, b) return a < b end)

	for _,v in ipairs(AlphabetizedSubcats) do

		local AlphabetizedSubcatSettings = table.GetKeys(data["subcats"][v])
		table.sort(AlphabetizedSubcatSettings, function(a, b) return a < b end)

		handle_settings(data["subcats"][v], AlphabetizedSubcatSettings, v)

		if v == "AvailablePackages" then continue end

		handle_settings(data["subcats"][v], AlphabetizedSubcatSettings, v)

	end
end 

net.Receive("JMod_ConfigUI", function(dataLength)
	data = util.JSONToTable(util.Decompress(net.ReadData(dataLength)))

	local config = data

	local catBlacklist = {"Craftables", "Note", "Info"}

	local specialTables = {}

	local categories = {}

	-- for cat,st in pairs(config) do
	-- 	if table.HasValue(catBlacklist, cat) then continue end
	-- 	categories[cat] = st
	-- end

	for cat,st in pairs(config) do
		if cat == "Craftables" then
			categories["Craftables"] = {}
			
			for craftable,settings in pairs(st) do
				categories["Craftables"][craftable] = settings
			end
		end

		if table.HasValue(catBlacklist, cat) then continue end

		categories[cat] = {subcats = {}, settings = {}}

		for setting,v in pairs(st) do
			if type(v) == "table" and v[1] == nil then
				local subcat = setting
				categories[cat]["subcats"][subcat] = {}
				for subsetting, subv in pairs(v) do
					categories[cat]["subcats"][subcat][subsetting] = subv
				end
			else
				categories[cat]["settings"][setting] = v
			end
		end
	end

	local MotherFrame = vgui.Create("DFrame")
	MotherFrame.positiveClosed = false
	MotherFrame.storted = false
	MotherFrame:SetSize(900, 500)
	MotherFrame:SetVisible(true)
	MotherFrame:SetDraggable(true)
	MotherFrame:ShowCloseButton(true)
	MotherFrame:SetTitle("EZ Config Editor")

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
		if key == KEY_ESCAPE then
			self:Close()
		end
	end

	function MotherFrame:OnClose()
		if not self.positiveClosed then
			surface.PlaySound("snds_jack_gmod/ez_gui/menu_close.wav")
		end
		SelectionMenuOpen = false
		if timer.Exists("configui_reset_timeout") then timer.Remove("configui_reset_timeout") end
	end

	local W, H, Myself = MotherFrame:GetWide(), MotherFrame:GetTall(), LocalPlayer()

	local TabPanel = vgui.Create("DPanel", MotherFrame)
	local TabPanelX, TabPanelW = 10, W - 20

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

	local AlphabetizedCategoryNames = table.GetKeys(categories)
	table.sort(AlphabetizedCategoryNames, function(a, b) return a < b end)

	local key = table.KeyFromValue(AlphabetizedCategoryNames, "Craftables")

	table.move(AlphabetizedCategoryNames, key, key, #AlphabetizedCategoryNames)
	table.remove(AlphabetizedCategoryNames, key)

	local ActiveTab = AlphabetizedCategoryNames[1]
	PopulateControls(ActiveTabPanel, categories[ActiveTab], MotherFrame, false)

	local resetButt = TabPanel:Add("DButton")

	resetButt:SetSize(100,16)
	resetButt:SetPos((TabPanel:GetWide() - 16) - 200, 8)
	resetButt:SetText("Reset to Defaults")
	resetButt:SetTextColor(color_white)

	function resetButt:Paint(w,h)

		surface.SetDrawColor(50, 50, 50, 60)

		surface.DrawRect(0, 0, w, h)

		BlurBackground(self)
	end

	local hasClicked = false

	function resetButt:DoClick()
		
		if hasClicked == true then
			changes_made = false
			LocalPlayer():ConCommand("jmod_resetconfig")
			LocalPlayer():ConCommand("jmod_ez_config")
			MotherFrame:Close()
			return
		end

		hasClicked = true
		
		self:SetText("Are you sure?")
		
		timer.Create("configui_reset_timeout", 2, 1, function()
			hasClicked = false
			self:SetText("Reset to Defaults")
		end)
	end

	local applyButt = TabPanel:Add("DButton")

	applyButt:SetSize(100,16)
	applyButt:SetPos((TabPanel:GetWide() - 16) - 94, 8)
	applyButt:SetText("")
	applyButt:SetTextColor(color_white)

	function applyButt:Paint(w,h)
		if not changes_made then
			if self:GetText() != "" then self:SetText("") end
			return
		end

		if self:GetText() != "Apply Changes" then self:SetText("Apply Changes") end

		surface.SetDrawColor(50, 50, 50, 60)

		surface.DrawRect(0, 0, w, h)

		BlurBackground(self)
	end

	function applyButt:DoClick()
		if not changes_made then return end

		local modifiedConfig = {}

		for cat,catTable in pairs(categories) do
			if cat == "Craftables" then continue end
			modifiedConfig[cat] = {}
			for normalOrSubcat,settingTable in pairs(catTable) do
				table.Merge(modifiedConfig[cat], settingTable)
			end
		end

		for _,name in ipairs(catBlacklist) do
			
			if not modifiedConfig[name] then
				modifiedConfig[name] = {}
			end

			if name == "Note" then
				modifiedConfig[name] = config[name]
			else
				table.Merge(modifiedConfig[name], config[name])
			end
		end

		net.Start("JMod_ApplyConfig")
		net.WriteData(util.Compress(util.TableToJSON(modifiedConfig)))
		net.SendToServer()

		changes_made = false
	end

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
			if cat == "Craftables" then
				PopulateControls(ActiveTabPanel, categories["Craftables"], motherFrame, true)
			else
				PopulateControls(ActiveTabPanel, categories[ActiveTab], MotherFrame, false)
			end
		end

		tabX = tabX + TextWidth + 15
	end

end)