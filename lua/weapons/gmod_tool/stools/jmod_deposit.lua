TOOL.Category = "JMod"
TOOL.Name = "#tool.jmod_deposit.name"

TOOL.ClientConVar[ "type" ] = "random"
TOOL.ClientConVar[ "amount" ] = "0"
TOOL.ClientConVar[ "size" ] = "0"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload"}
}

local ResourceInfo = JMod.ResourceDepositInfo
local NatrualResourceTypes = table.GetKeys(ResourceInfo)
local prefix = "tool.jmod_deposit"

function TOOL:LeftClick( trace )

	local ResourceType = GetConVar("jmod_deposit_type"):GetString()
	local ResourceAmt = GetConVar("jmod_deposit_amount"):GetInt()
	local DepositSize = GetConVar("jmod_deposit_size"):GetInt()

	if SERVER then

		if ( ResourceType == "random" ) then
			ResourceType = NatrualResourceTypes[math.random(#NatrualResourceTypes)]
		end

		local ChosenInfo = ResourceInfo[ResourceType]

		if DepositSize == 0 then
			DepositSize = math.Round(ChosenInfo.avgsize * math.Rand(.5, 1.5))
		end

		local NewDeposit = {
			typ = ResourceType,
			pos = trace.HitPos,
			siz = DepositSize
		}

		if ( ResourceAmt == 0 ) then
			ResourceAmt = math.Round(ChosenInfo.avgsize * math.Rand(.5, 1.5))

			local Amt, Decimals = (ChosenInfo.avgrate or ChosenInfo.avgamt) * math.Rand(.5, 1.5) * JMod.Config.ResourceEconomy.ResourceRichness, 0
			
			if ChosenInfo.avgrate then
				Decimals = 2
			end

			Amt = math.Round(Amt, Decimals)
	
			if ChosenInfo.avgrate then
				NewDeposit.rate = Amt
			elseif ChosenInfo.avgamt then
				NewDeposit.amt = Amt
			end
		else
			if ChosenInfo.avgrate then
				NewDeposit.rate = ResourceAmt * 0.01
			elseif ChosenInfo.avgamt then
				NewDeposit.amt = ResourceAmt 
			end
		end

		-- Let's try and fill up nil slots
		local GoodIndex = nil
		for k, v in pairs(JMod.NaturalResourceTable) do 
			if not istable(v) then
				GoodIndex = k
			end
		end
		if GoodIndex then
			table.insert(JMod.NaturalResourceTable, GoodIndex, NewDeposit)
		else
			table.insert(JMod.NaturalResourceTable, NewDeposit)
		end
		net.Start("JMod_NaturalResources")
		net.WriteBool(false)
		net.WriteTable(JMod.NaturalResourceTable)
		net.Send(self:GetOwner())
	end

	return true

end

function TOOL:RightClick( trace )
	local HitPos = trace.HitPos
	-- first, figure out which deposits we are inside of, if any
	local DepositsInRange = {}

	for k, v in pairs(JMod.NaturalResourceTable)do
		-- Make sure the resource is on the whitelist
		local Dist = HitPos:Distance(v.pos)

		-- store they desposit's key if we're inside of it
		if (Dist <= v.siz) then
			table.insert(DepositsInRange, k)
		end
	end

	-- now, among all the deposits we are inside of, let's find the closest one
	local ClosestDeposit, ClosestRange = nil, 9e9

	if #DepositsInRange > 0 then
		for k, v in pairs(DepositsInRange)do
			local DepositInfo = JMod.NaturalResourceTable[v]
			local Dist = HitPos:Distance(DepositInfo.pos)

			if(Dist < ClosestRange)then
				ClosestDeposit = v
				ClosestRange = Dist
			end
		end
	end
	if(ClosestDeposit)then 
		JMod.NaturalResourceTable[ClosestDeposit] = nil
		return true
	end
end

function TOOL:Reload(tr)
	if SERVER then
		net.Start("JMod_SaveLoadDeposits")
		net.WriteString("warning")
		net.Send(self:GetOwner())
	end
	return true
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	local Header = vgui.Create("DLabel", CPanel)
	Header:SetText("#"..prefix..".desc")
	CPanel:AddItem(Header)

	CPanel:AddControl( "ComboBox", { Label = "#"..prefix..".presets", MenuButton = 1, Folder = "resource_deposits", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	local ResourceTypeList = vgui.Create("DListView", CPanel)
	ResourceTypeList:SetHeight(300)
	ResourceTypeList:SetMultiSelect(false)
	ResourceTypeList:AddColumn("#"..prefix..".type")
	ResourceTypeList:AddLine("random")
	for _, v in ipairs(NatrualResourceTypes) do 
		ResourceTypeList:AddLine(v)
	end
	ResourceTypeList.OnRowSelected = function( lst, index, pnl )
		GetConVar("jmod_deposit_type"):SetString(pnl:GetColumnText(1))
	end
	CPanel:AddItem(ResourceTypeList)

	local AmountSlider = vgui.Create("DNumSlider", CPanel)
	AmountSlider:SetText("#"..prefix..".amt")
	AmountSlider:SetMinMax(0, 100000)
	AmountSlider:SetDecimals(0)
	AmountSlider:SetConVar("jmod_deposit_amount")
	CPanel:AddItem(AmountSlider)

	local SizeSlider = vgui.Create("DNumSlider", CPanel)
	SizeSlider:SetText("#"..prefix..".size")
	SizeSlider:SetMinMax(0, 1000)
	SizeSlider:SetDecimals(0)
	SizeSlider:SetConVar("jmod_deposit_size")
	CPanel:AddItem(SizeSlider)

	local MenuButton = vgui.Create("DButton", CPanel)
	MenuButton:SetText("#"..prefix..".saveload")
	MenuButton:SetMouseInputEnabled(true)
	function MenuButton:DoClick()
		local MotherFrame = vgui.Create("DFrame")
		MotherFrame:SetTitle("JMod Resource Deposit Save/Load")
		MotherFrame:SetSize(500, 200)
		MotherFrame:Center()
		MotherFrame:MakePopup()

		local W, H = MotherFrame:GetWide(), MotherFrame:GetTall()
		local Instructions = vgui.Create("DLabel", MotherFrame)
		Instructions:SetPos((W * 0.5) - 200, (H * 0.5) - 55)
		Instructions:SetText("Enter ID here, no spaces in name, and at least one non-numeric character.\nPut a space and map name to force load from that file")
		Instructions:SizeToContents()

		local NameEntry = vgui.Create("DTextEntry", MotherFrame)
		NameEntry:SetPos((W / 2) - 200, (H / 2) - 20)
		NameEntry:SetSize(400, 20)

		local SaveButton = vgui.Create("DButton", MotherFrame)
		SaveButton:SetPos((W * 0.2) - 50, H * 0.8)
		SaveButton:SetSize(100, 30)
		SaveButton:SetText("SAVE")
		function SaveButton:DoClick()
			net.Start("JMod_SaveLoadDeposits")
				net.WriteString("save")
				net.WriteString(NameEntry:GetText())
			net.SendToServer()
		end

		local LoadButton = vgui.Create("DButton", MotherFrame)
		LoadButton:SetPos((W * 0.8) - 50, H * 0.8)
		LoadButton:SetSize(100, 30)
		LoadButton:SetText("LOAD")
		function LoadButton:DoClick()
			print("LoadButton pressed")
			print(NameEntry:GetText())
			if NameEntry:GetText() then
				net.Start("JMod_SaveLoadDeposits")
					net.WriteString("load")
					net.WriteString(NameEntry:GetText())
				net.SendToServer()
			else
				net.Start("JMod_SaveLoadDeposits")
					net.WriteString("load_list")
				net.SendToServer()
			end
			--MotherFrame:Close()
		end
	end
	CPanel:AddItem(MenuButton)

	local ShowHideButton = vgui.Create("DButton", CPanel)
	ShowHideButton:SetText("#"..prefix..".showhide")
	ShowHideButton:SetMouseInputEnabled(true)
	function ShowHideButton:DoClick()
		LocalPlayer():ConCommand("jmod_debug_shownaturalresources")
	end
	CPanel:AddItem(ShowHideButton)
end

if ( CLIENT ) then
	language.Add( prefix..".name", "Deposit Placer" )
	language.Add( prefix..".desc", "Use to place JMod natrual resource deposits wherever you like" )
	language.Add( prefix..".presets", "Presets" )
	language.Add( prefix..".left", "Place resource deposit" )
	language.Add( prefix..".right", "Remove resource deposit" )
	language.Add( prefix..".reload", "Clears all resource deposits" )
	language.Add( prefix..".type", "Resource type" )
	language.Add( prefix..".amt", "Resource amount" )
	language.Add( prefix..".size", "Deposit size" )
	language.Add( prefix..".saveload", "Save / Load" )
	language.Add( prefix..".showhide", "Show / Hide (requires sv_cheats)" )
end
