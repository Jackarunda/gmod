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
	local FrameRate, Num, Dark = 1 / FrameTime(), 5, 150

	if GetConVar("jmod_cl_blurry_menus"):GetBool() then
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

--[[-----------------------------------+
|             For ConfigUI,            |
|   Parses the settings in the config  |
|    then draws the correct controls   |
|           for each setting.          |
+-------------------------------------]]
local function PopulateControls(parent, controls, motherFrame)
	-- make the main panel and do some theming
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

    -- create the controls for all the applicable values in the config
    local Y = 0
    local function handle_settings(control_table, AlphabetizedSettings, subcatName)
    	-- add a header for the sub category
        if subcatName then
            local subcatLabel = Scroll:Add("DPanel")
            subcatLabel:SetSize(W - 40, 42)
            subcatLabel:SetPos(0, Y)
            function subcatLabel:Paint(w, h)
                surface.SetDrawColor(255, 255, 255, 60)
                surface.DrawLine(w / 2 - 75, 2, w / 2 + 75, 2)
                surface.DrawLine(w / 2 - 75, 39, w / 2 + 75, 39)
                draw.SimpleText(subcatName, "DermaLarge", w / 2, 6, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            Y = Y + 47
        end

        for k, setting in pairs(AlphabetizedSettings) do
        	-- make a frame for the controls of each config setting so they can be layed out easier
            local control_frame = Scroll:Add("DPanel")
            control_frame:SetSize(W - 40, 42)
            control_frame:SetPos(0, Y)
            function control_frame:Paint(w, h)
                surface.SetDrawColor(50, 50, 50, 60)
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText(setting, "DermaDefault", 5, 15, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            -- special handling of altfunctionkey so that users dont have to go look up all the IN_ enums
            if setting == "AltFunctionKey" then
                local comboBox = control_frame:Add("DComboBox")
                comboBox:SetSize(107, 16)
                comboBox:SetPos(control_frame:GetWide() - 243, control_frame:GetTall() / 2 - 8)
                comboBox:AddChoice("+walk", IN_WALK) -- 1           ____________________
                comboBox:AddChoice("+speed", IN_SPEED) -- 2        | if you want to add more options
                comboBox:AddChoice("+alt1", IN_ALT1) -- 3          | here make sure to both do :AddChoice
                comboBox:AddChoice("+alt2", IN_ALT2) -- 4          | and chuck it in "choices"
                comboBox:SetSortItems(false)
                local choices = {IN_WALK, IN_SPEED, IN_ALT1, IN_ALT2}
                for k, v in ipairs(choices) do
                    if v == control_table[setting] then
                        comboBox:ChooseOptionID(k)
                        continue
                    end
                end

                function comboBox:OnSelect(i, v, d)
                    control_table[setting] = d
                    changes_made = true
                end

                -- help button to inform users of what each IN_ actually means
                local whatButt = control_frame:Add("DButton")
                local x, y = comboBox:GetPos()
                local w, h = comboBox:GetSize()
                whatButt:SetSize(16, 16)
                whatButt:SetPos(x + w + 5, y)
                whatButt:SetText("")
                whatButt:SetTooltip("Click me for more info on what these options mean.")
                function whatButt:Paint(w, h)
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

            -- controls for simple number values, like multipliers, will be a slider
            if type(control_table[setting]) == "number" then
                local slider = control_frame:Add("DNumSlider")
                slider:SetSize(control_frame:GetWide() / 2, 14)
                slider:SetPos((control_frame:GetWide() - 10) - control_frame:GetWide() / 2, control_frame:GetTall() / 2 - 7)
                slider:SetDefaultValue(control_table[setting])
                slider:SetMax(10)
                if setting == "RestrictedPackageShipTime" then slider:SetMax(5000) end
                slider:SetMin(0)
                slider:SetDecimals(2)
                slider:ResetToDefaultValue()
                function slider:OnValueChanged(val)
                    control_table[setting] = val
                    changes_made = true
                end
            end

            -- controls for booleans, will be a checkbox
            if type(control_table[setting]) == "boolean" then
                local checkbox = control_frame:Add("DCheckBox")
                checkbox:SetSize(14, 14)
                checkbox:SetPos(control_frame:GetWide() - 243, control_frame:GetTall() / 2 - 7)
                checkbox:SetValue(control_table[setting])
                function checkbox:OnChange(val)
                    control_table[setting] = val
                    changes_made = true
                end
            end

            -- special handling for tables, creates a dropdown which allows you to add, remove, and edit indexes
            if type(control_table[setting]) == "table" then
                local tablePanel = nil
                local addButton = nil
                local isOpen = false
                local arrow_icon = control_frame:Add("DSprite")
                arrow_icon:SetSize(16, 16)
                arrow_icon:SetPos(control_frame:GetWide() - 243, control_frame:GetTall() / 2)
                local start = SysTime()
                local lerp_reset = false
                local firstTime = true
                function arrow_icon:Paint(w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(arrowMat)
                    if lerp_reset then
                        start = SysTime()
                        lerp_reset = false
                    end

                    if firstTime then
                        if isOpen then firstTime = false end
                        surface.DrawTexturedRectRotated(0, 0, w, h, 0)
                        return
                    end

                    if isOpen then
                        surface.DrawTexturedRectRotated(0, 0, w, h, Lerp((SysTime() - start) / 0.25, 0, -90))
                    else
                        surface.DrawTexturedRectRotated(0, 0, w, h, Lerp((SysTime() - start) / 0.25, -90, 0))
                    end
                end

                local butt = control_frame:Add("DButton")
                butt:SetSize(control_frame:GetSize())
                butt:SetText("")
                function butt:Paint(w, h) -- make it invis
                end

                function butt:DoClick()
                    lerp_reset = true -- reset the timer used for the arrow animation
                    if isOpen and tablePanel then
                        tablePanel:SizeTo(tablePanel:GetWide(), 0, 0.25)
                        timer.Simple(
                            0.25,
                            function()
                                tablePanel:Remove()
                                addButton:Remove()
                            end
                        )
                    else
                    	-- create the panel that will contain all values of the table
                        tablePanel = Scroll:Add("DScrollPanel")
                        local control_frame_x, control_frame_y = control_frame:GetPos()
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

                        function tablePanel:Paint(w, h)
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
                            holder_panel:DockMargin(0, 5, 0, 5)
                            function holder_panel:Paint()
                                return
                            end

                            local textEntry = holder_panel:Add("DTextEntry")
                            textEntry:SetSize(tablePanel:GetWide() - 40, 16)
                            textEntry:SetPos(0, 0)
                            textEntry:SetText(value)
                            textEntry:SetUpdateOnType(true)
                            local lastval = value
                            function textEntry:OnValueChange(val)
                                if val ~= lastval then
                                    control_table[setting][index] = val
                                    changes_made = true
                                end

                                lastval = val
                            end

                            function textEntry:Paint(w, h)
                                surface.SetDrawColor(100, 100, 100, 60)
                                surface.DrawRect(0, 0, w, h)
                                surface.DrawOutlinedRect(0, 0, w, h)
                                surface.SetDrawColor(255, 255, 255, 255)
                                draw.SimpleText(self:GetText(), DermaDefault, 5, 7, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                if math.Round(CurTime() * 2.5) % 2 == 0 and self:HasFocus() then
                                    surface.SetFont("DermaDefault")
                                    local tw, th = surface.GetTextSize(self:GetText())
                                    surface.SetDrawColor(255, 255, 255, 255) -- text cursor
                                    surface.DrawLine(tw + 6, 2, tw + 6, h - 3)
                                end
                            end

                            local removeButt = holder_panel:Add("DButton")
                            removeButt:SetSize(16, 16)
                            removeButt:SetPos(holder_panel:GetWide() - 35, 0)
                            removeButt:SetText("")
                            function removeButt:Paint(w, h)
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

                        for index, value in ipairs(control_table[setting]) do
                            setup_table_value(index, value)
                        end

                        addButton = control_frame:Add("DButton")
                        addButton:SetSize(16, 16)
                        local arrow_x, arrow_y = arrow_icon:GetPos()
                        addButton:SetPos((control_frame:GetWide() - 243) + 16, control_frame:GetTall() / 2 - 8)
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

                    isOpen = not isOpen
                end
            end

            Y = Y + 47
        end
    end

    --[[ this big mess alphabetizes the settings in the config, then passes
         ones not in subcategories to handle_settings() first before doing
         the ones that are in sub categories ]]--
    local AlphabetizedNormal = table.GetKeys(controls["settings"])
    table.sort(AlphabetizedNormal, function(a, b) return a < b end)
    handle_settings(controls["settings"], AlphabetizedNormal, nil) -- normal settings not in sub categories
    local AlphabetizedSubcats = table.GetKeys(controls["subcats"])
    table.sort(AlphabetizedSubcats, function(a, b) return a < b end)
    for _, v in ipairs(AlphabetizedSubcats) do
        local AlphabetizedSubcatSettings = table.GetKeys(controls["subcats"][v])
        table.sort(AlphabetizedSubcatSettings, function(a, b) return a < b end)
        if v == "AvailablePackages" then continue end
        handle_settings(controls["subcats"][v], AlphabetizedSubcatSettings, v)
    end
end

net.Receive(
    "JMod_ConfigUI",
    function(dataLength)
        data = util.JSONToTable(util.Decompress(net.ReadData(dataLength / 8)))
        local config = data
        local catBlacklist = {"Craftables", "Note", "Info"}
        local categories = {}
        changes_made = false

		--[[ 
			End result of the code below
			----------------------------
			categories[]
			└> all main categories
				└> "settings"
				|   └> all top level settings in the category
				└> "subcats"
					└> every sub category in the main category
						└> "settings"
							└> all settings within the subcategory
		]]--

        for cat, st in pairs(config) do
            if table.HasValue(catBlacklist, cat) then continue end
            categories[cat] = {
                subcats = {},
                settings = {}
            }

            for setting, v in pairs(st) do
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
                surface.PlaySound("snds_jack_gmod/ez_gui/menu_open.ogg")
            end

            BlurBackground(self)
        end

        MotherFrame:MakePopup()
        MotherFrame:Center()
        function MotherFrame:OnKeyCodePressed(key)
            if key == KEY_ESCAPE then self:Close() end
        end

        function MotherFrame:OnClose()
            if not self.positiveClosed then surface.PlaySound("snds_jack_gmod/ez_gui/menu_close.ogg") end
            SelectionMenuOpen = false
            if timer.Exists("configui_reset_timeout") then timer.Remove("configui_reset_timeout") end
        end

        local W, H = MotherFrame:GetWide(), MotherFrame:GetTall()
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
        local ActiveTab = AlphabetizedCategoryNames[1]
        PopulateControls(ActiveTabPanel, categories[ActiveTab], MotherFrame)
        local resetButt = TabPanel:Add("DButton")
        resetButt:SetSize(100, 16)
        resetButt:SetPos((TabPanel:GetWide() - 16) - 200, 8)
        resetButt:SetText("Reset to Defaults")
        resetButt:SetTextColor(color_white)
        function resetButt:Paint(w, h)
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
            timer.Create(
                "configui_reset_timeout",
                2,
                1,
                function()
                    hasClicked = false
                    self:SetText("Reset to Defaults")
                end
            )
        end

        local applyButt = TabPanel:Add("DButton")
        applyButt:SetSize(100, 16)
        applyButt:SetPos((TabPanel:GetWide() - 16) - 94, 8)
        applyButt:SetText("")
        applyButt:SetTextColor(color_white)
        function applyButt:Paint(w, h)
            if not changes_made then
                if self:GetText() ~= "" then self:SetText("") end
                return
            end

            if self:GetText() ~= "Apply Changes" then self:SetText("Apply Changes") end
            surface.SetDrawColor(50, 50, 50, 60)
            surface.DrawRect(0, 0, w, h)
            BlurBackground(self)
        end

        function applyButt:DoClick()
            if not changes_made then return end
            local modifiedConfig = {}
            for cat, catTable in pairs(categories) do
                modifiedConfig[cat] = {}
                for normalOrSubcat, settingTable in pairs(catTable) do
                    table.Merge(modifiedConfig[cat], settingTable)
                end
            end

            for _, name in ipairs(catBlacklist) do
                if not modifiedConfig[name] then modifiedConfig[name] = {} end
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
                surface.PlaySound("snds_jack_gmod/ez_gui/click_smol.ogg")
                ActiveTab = self.Category
                PopulateControls(ActiveTabPanel, categories[ActiveTab], MotherFrame)
            end

            tabX = tabX + TextWidth + 15
        end
    end
)