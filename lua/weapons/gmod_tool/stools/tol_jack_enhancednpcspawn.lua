TOOL.Category="JMod"
TOOL.Name="#tool.tol_jack_enhancednpcspawn.name"
TOOL.ClientConVar["SelectedNPC"]="nil"
function TOOL:Think()
	--nothing
end
function TOOL:LeftClick(trace)
	if(SERVER)then
		if not(self:GetClientInfo("SelectedNPC")=="nil")then
			undo.Create("Jack-Enhanced NPC")
			undo.SetPlayer(self:GetOwner())
			undo.AddEntity(JackieNPCSpawningTable.Enhanced[self:GetClientInfo("SelectedNPC")](trace.HitPos+trace.HitNormal*32))
			undo.SetCustomUndoText("Undone enhanced NPC")
			undo.Finish()
		else
			return false
		end
	end
	return true
end
function TOOL:RightClick(trace)
	--nothing
end
function TOOL:Reload()
	--nothing
end
if(CLIENT)then
	language.Add( "tool.tol_jack_enhancednpcspawn.name","Enhanced NPC Spawner")
	language.Add( "tool.tol_jack_enhancednpcspawn.desc","Allows individual spawning of Jack-Enhanced HL2 NPCs.")
	language.Add( "tool.tol_jack_enhancednpcspawn.0","Left-Click to spawn the selected NPC.")
	local Options={
		"Antlion Guard",
		"Cavern Guard",
		"Synth Scanner",
		"MetroCop",
		"Strider",
		"HunterCopter",
		"Gunship",
		"Headcrab Canister",
		"Rocket Rebel",
		"Ammo Rebel",
		"Classic Zombie"
	}
	function TOOL.BuildCPanel(CPanel)
		table.sort(Options)
		local RealOptions={}
		for k,dude in pairs(Options)do
			RealOptions[dude]={tol_jack_enhancednpcspawn_SelectedNPC=dude} -- what a monuMENTALLY stupid, non-intuitive method of operation this is. Garry's a fucking idiot.
		end
		CPanel:AddControl("ListBox",{Label="#tool.tol_jack_enhancednpcspawn.name",Height="300",Options=RealOptions})
	end
end