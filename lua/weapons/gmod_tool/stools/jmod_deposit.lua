TOOL.Category = "JMod"
TOOL.Name = "#tool.jmod_deposit.name"

TOOL.ClientConVar[ "type" ] = "random"
TOOL.ClientConVar[ "amount" ] = "0"
TOOL.ClientConVar[ "size" ] = "0"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
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
			pos = trace.HitPos + Vector(0, 0, 10),
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

		end

		-- Let's try and fill up nil slots
		local GoodIndex = nil
		for k, v in pairs(JMod.NaturalResourceTable) do 
			if not istable(v) then
				GoodIndex = k
			end
		end
		if GoodIndex then
			table.insert(JMod.NaturalResourceTable, NewDeposit)
		else
			table.insert(JMod.NaturalResourceTable, NewDeposit)
		end
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

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "#"..prefix..".desc" } )

	CPanel:AddControl( "ComboBox", { Label = "#"..prefix..".presets", MenuButton = 1, Folder = "resource_deposits", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "TextBox", { Label = "#"..prefix..".type", Command = "jmod_deposit_type"} )
	CPanel:AddControl( "Slider", { Label = "#"..prefix..".amt", Command = "jmod_deposit_amount", Min = 0, Max = 100000 } )
	CPanel:AddControl( "Slider", { Label = "#"..prefix..".size", Command = "jmod_deposit_size", Min = 0, Max = 500 } )

end

if ( CLIENT ) then
	language.Add( prefix..".name", "Deposit Placer" )
	language.Add( prefix..".desc", "Use to place JMod natrual resource deposits wherever you like" )
	language.Add( prefix..".presets", "Presets" )
	language.Add( prefix..".left", "Place resource deposit" )
	language.Add( prefix..".right", "Remove resource deposit" )
	language.Add( prefix..".type", "Resource type" )
	language.Add( prefix..".amt", "Resource amount" )
	language.Add( prefix..".size", "Deposit size" )
end
