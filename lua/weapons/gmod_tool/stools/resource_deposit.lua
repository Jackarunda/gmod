TOOL.Category = "JMod"
TOOL.Name = "Deposit Placer"
TOOL.Mode = "jmod_deposit"

TOOL.ClientConVar[ "type" ] = "random"
TOOL.ClientConVar[ "amount" ] = "0"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" }
}

cleanup.Register( "Resource Deposits" )

function TOOL:LeftClick( trace )
	local ResourceType = GetConVar("jmod_deposit_type"):GetString()
	local ResourceAmt = GetConVar("jmod_deposit_amount"):GetInt()

	if ResourceType == "random" then
		ResourceType = table.Random(JMod.EZ_RESOURCE_TYPES)
	end

	if ResourceAmt == 0 then
		ResourceAmt = math.random(100, 1000)
	end

	local NewDeposit = {
		typ = ResourceType,
		pos = trace.HitPos + Vector(0, 0, 10),
		siz = ResourceAmt
	}
	PrintTable(NewDeposit)

	if SERVER then

		local Index = table.insert(JMod.NaturalResourceTable, NewDeposit)

		undo.Create( "Resource Deposit" )
			undo.AddFunction(function(tab) 
				JMod.NaturalResourceTable[Index] = nil
			end)
			undo.SetPlayer( ply )
		undo.Finish()
	end

	return true

end

function TOOL:RightClick( trace )

end

if ( SERVER ) then


end

function TOOL:UpdateGhostDeposit( ent, pl )

end

function TOOL:Think()

	self:UpdateGhostDeposit( self.GhostEntity, self:GetOwner() )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "JMod resource deposit tool" } )

	CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "resource_deposit", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

	CPanel:AddControl( "TextBox", { Label = "Resource Type", Command = ""} )
	CPanel:AddControl( "Slider", { Label = "Amount", Command = "", Min = 100, Max = 100000 } )

end
