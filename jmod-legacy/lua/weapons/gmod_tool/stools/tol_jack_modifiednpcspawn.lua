TOOL.Category="JMod"
TOOL.Name="#tool.tol_jack_modifiednpcspawn.name"
TOOL.ClientConVar["SelectedNPC"]="nil"
function TOOL:Think()
	--nothing
end
function TOOL:LeftClick(trace)
	if(SERVER)then
		if not(self:GetClientInfo("SelectedNPC")=="nil")then
			undo.Create("Jacka-Modified NPC")
			undo.SetPlayer(self:GetOwner())
			undo.AddEntity(JackieNPCSpawningTable.Modified[self:GetClientInfo("SelectedNPC")](trace.HitPos+trace.HitNormal*32))
			undo.SetCustomUndoText("Undone modified NPC")
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
	language.Add( "tool.tol_jack_modifiednpcspawn.name","Modified NPC Spawner")
	language.Add( "tool.tol_jack_modifiednpcspawn.desc","Allows individual spawning of Jacka-Modified NPCs.")
	language.Add( "tool.tol_jack_modifiednpcspawn.0","Left-Click to spawn the selected NPC.")
	local Options={
		"Combine Stalker",
		"Elite Combine Cyclops",
		"Elite Combine Biclops",
		"Elite Rebel Grenadier",
		"Elite Rebel Medic",
		"Elite Rebel Marksman",
		"DeathZombie",
		"U.S. Army Rifleman"
	}
	function TOOL.BuildCPanel(CPanel)
		table.sort(Options)
		local RealOptions={}
		for k,dude in pairs(Options)do
			RealOptions[dude]={tol_jack_modifiednpcspawn_SelectedNPC=dude} -- what a monuMENTALLY stupid, non-intuitive method of operation this is. Garry's a fucking idiot.
		end
		CPanel:AddControl("ListBox",{Label="#tool.tol_jack_modifiednpcspawn.name",Height="300",Options=RealOptions})
	end
end