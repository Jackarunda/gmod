local Hints={
	["afh"]="E to enter and get healed",
	["airburst det"]="detonates in midair automatically",
	["ammobox"]="ALT+E to refill ammo of any weapon",
	["antimatter"]="CAUTION EXTREMELY DANGEROUS VERY FRAGILE HANDLE WITH CARE",
	["arm"]="ALT+E to arm",
	["armor remove"]="type *armor* or concommand jmod_ez_armor to unequip all armor",
	["armor"]="ALT+E to select color and wear armor",
	["auto anchor"]="bomb will automatially anchor itself below the surface of the water",
	["binding"]="remember, console commands can be bound to a key",
	["black powder pile"]="ALT+E to ignite black powder, E to sweep away",
	["black powder ignite"]="black powder can ignite powder kegs and anything with a pyro fuze, like dynamite",
	["blasting machine"]="ALT+E on the blasting machine to detonate the satchel charge",
	["bomb drop"]="weld/nail bomb to vehicle, then type *bomb* or cmd jmod_ez_bombdrop to detach",
	["bomb guidable"]="use a guidance kit to turn into a guided bomb",
	["building"]="stand near resources in order to use them",
	["bury"]="can only be buried in grass, dirt, snow or mud",
	["crafting"]="set resources near workbench in order to use them",
	["crate"]="tap resource against to store \n press E to retrieve resource",
	["contact det"]="when armed, bomb will detonate on contact",
	["customize"]="To customize JMod, or to disable these hints, check out garrysmod/data/jmod_config.txt",
	["decontaminate"]="can also remove radioactive fallout from a person",
	["detpack combo"]="detpacks can destroy props \n multiple combine for more power",
	["detpack stick"]="hold E on detpack then release E to stick the detpack",
	["disarm"]="tap E to disarm",
	["eat"]="ALT+E to consume",
	["fix"]="tap parts box against to repair",
	["friends"]="concommand jmod_friends to specify allies",
	["grenade"]="ALT+E to pick up and arm grenade. LMB for hard throw, RMB for soft throw",
	["guidance kit"]="tap against an EZ Bomb or EZ Big Bomb to create a guided bomb",
	["headset"]="type *headset* or concommand jmod_ez_headset to toggle ear equipment",
	["headset comms"]="with a headset, only friends and teammates can hear your voip and see your chat",
	["item crate"]="tap item against to store \n press E to retrieve item",
	["impact det"]="when armed, bomb will detonate upon impact",
	["jmod hands drag"]="move slowly to drag heavier objects (crouch/alt)",
	["jmod hands grab"]="RMB to grab objects",
	["jmod hands move"]="punches also can move you (jump boost/climbing)",
	["jmod hands"]="RMB to block, R to put hands down",
	["launch"]="weld/nail weapon to vehicle, then type *launch* or cmd jmod_ez_launch to launch",
	["mask"]="type *mask* or concommand jmod_ez_mask to toggle face equipment",
	["mininade"]="mininades can be stuck to larger explosives to trigger them",
	["modify"]="use the build kit to modify",
	["powder keg"]="ALT+E to open and pour a line of black powder",
	["radsickness"]="taking damage from radiation sickness, decontaminate in field hospital",
	["remote det"]="chat *trigger* \n or concommand jmod_ez_trigger",
	["slam stick"]="hold E on SLAM then release E to stick SLAM",
	["slam trigger"]="SLAMs can be stuck to larger explosives to trigger them",
	["radio comm"]="radio needs to see sky",
	["slam stick"]="hold E on SLAM then release E to stick the SLAM",
	["splitterring"]="SHIFT+ALT+E to toggle fragmentation sleeve",
	["supplies"]="tap supplies against to refill, tap parts against to repair",
	["timebomb stick"]="hold E on timebomb then release E to stick the timebomb",
	["unpackage"]="double tap ALT+E to unpackage",
	["upgrade"]="use Build Kit to upgrade",
	["water arm"]="arm bomb and drop in water",
	["water det"]="bomb must be in water to detonate"
}

-- TODO why is this on shared?
function JMod_Hint(ply,...)
	if(CLIENT)then return end
	if not(JMOD_CONFIG.Hints)then return end
	local HintKeys={...}
	ply.NextJModHint=ply.NextJModHint or 0
	ply.JModHintsGiven=ply.JModHintsGiven or {}
	local Time=CurTime()
	if(ply.NextJModHint>Time)then return end
	for k,key in pairs(HintKeys)do
		if not(table.HasValue(ply.JModHintsGiven,key))then
			table.insert(ply.JModHintsGiven,key)
			ply.NextJModHint=Time+1
			net.Start("JMod_Hint")
			net.WriteString(Hints[key])
			net.Send(ply)
			break
		end
	end
end

if(SERVER)then
	concommand.Add("jmod_resethints",function(ply,cmd,args)
		ply.JModHintsGiven={}
		print("hints for "..ply:Nick().." reset")
	end)
end