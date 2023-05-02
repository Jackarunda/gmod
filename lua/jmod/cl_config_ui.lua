local blurMat = Material("pp/blurscreen")
local Dynamic = 0
local downMat = Material("icon16/arrow_down.png")
local rightMat = Material("icon16/arrow_right.png")

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

/*-----------------------------------+
 |           For ConfigUI,           |
 | Parses the settings in the config |
 |  then draws the correct controls  |
 |         for each setting.         |
 +-----------------------------------*/

local function PopulateControls(parent, controls, motherFrame)
	parent:Clear()
	local W, H = parent:GetWide(), parent:GetTall()
	local Scroll = vgui.Create("DScrollPanel", parent)
	Scroll:SetSize(W - 20, H - 20)
	Scroll:SetPos(10, 10)
	---
	local Y, AlphabetizedSettings = 0, table.GetKeys(controls["settings"])
	table.sort(AlphabetizedSettings, function(a, b) return a < b end)

	for k, setting in pairs(AlphabetizedSettings) do
		local control_frame = Scroll:Add("DPanel")
		control_frame:SetSize(W - 40, 42)
		control_frame:SetPos(0, Y)

		function control_frame:Paint(w, h)

			surface.SetDrawColor(50, 50, 50, 60)

			surface.DrawRect(0, 0, w, h)

			draw.SimpleText(setting, "DermaDefault", 5, 15, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end

		if type(controls["settings"][setting]) == "number" then
			local slider = control_frame:Add("DNumSlider")
			slider:SetSize(control_frame:GetWide()/2,14)
			slider:SetPos((control_frame:GetWide() - 10) - control_frame:GetWide()/2, control_frame:GetTall()/2 - 7)
			slider:SetDefaultValue(controls["settings"][setting])
			slider:SetMax(10)
			slider:SetMin(0.1)
			slider:ResetToDefaultValue()

			function slider:OnValueChanged(val)
				controls["settings"][setting] = val
			end

		end

		if type(controls["settings"][setting]) == "boolean" then
			local checkbox = control_frame:Add("DCheckBox")
			checkbox:SetSize(14,14)
			checkbox:SetPos(control_frame:GetWide() - (243), control_frame:GetTall()/2 - 7)
			checkbox:SetValue(controls["settings"][setting])

			function checkbox:OnValueChanged(val)
				controls["settings"][setting] = val
			end
		end

		if type(controls["settings"][setting]) == "table" then

			local mat = rightMat
			local tablePanel = nil
			local isOpen = false

			local icon = control_frame:Add("DSprite") -- why a button? because derma
			icon:SetMaterial(mat)
			icon:SetSize(16,16)
			icon:SetPos(control_frame:GetWide() - (243), control_frame:GetTall()/2)

			local butt = control_frame:Add("DButton")
			butt:SetSize(control_frame:GetSize())
			butt:SetText("")
			function butt:Paint(w,h) end -- make it invis

			function butt:DoClick()
				if mat == rightMat then mat = downMat else mat = rightMat end

				icon:SetMaterial(mat)

				if isOpen and tablePanel then tablePanel:Remove() else

					tablePanel = Scroll:Add("DScrollPanel")
					local control_frame_x,control_frame_y = control_frame:GetPos()
					tablePanel:SetSize(control_frame:GetWide(), 150)
					tablePanel:SetPos(control_frame_x, control_frame_y + control_frame:GetTall())
					function tablePanel:Paint(w,h,x,y)
						surface.SetDrawColor(50, 50, 50, 60)
						surface.DrawRect(0, 0, w, h)

						BlurBackground(self)
					end

					local y2 = 10
					
					for index,value in ipairs(controls["settings"][setting]) do
						local textEntry = tablePanel:Add("DTextEntry")
						textEntry:SetSize(tablePanel:GetWide() - 75, 16)
						textEntry:SetPos(5, y2)
						textEntry:SetText(value)
						y2 = y2 + 24

						--aPanel:Add("DButton")
					end
				end
				
				isOpen = !isOpen
			
			end
		end


		Y = Y + 47
	end
end

/*-----------+
 | Config UI |
 +-----------*/

net.Receive("JMod_ConfigUI", function()
	local config = net.ReadTable() -- NETWORKED IN SV_CONFIG_UI, NEEDS PERMISSION CHECK

	local catBlacklist = {"Craftables", "Note", "RadioSpecs", "Info"}

	local specialTables = {}

	local categories = {}

	-- for cat,st in pairs(config) do
	-- 	if table.HasValue(catBlacklist, cat) then continue end
	-- 	categories[cat] = st
	-- end

	for cat,st in pairs(config) do
		if table.HasValue(catBlacklist, cat) then continue end

		categories[cat] = {["subcats"] = {}, ["settings"] = {}}

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
			PopulateControls(ActiveTabPanel, categories[ActiveTab], MotherFrame)
		end

		tabX = tabX + TextWidth + 15
	end

end)