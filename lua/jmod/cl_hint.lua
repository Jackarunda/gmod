-- Part of the code and inspiration from GIGABABAIT
-- Original addon: https://steamcommunity.com/sharedfiles/filedetails/?id=2058653864

surface.CreateFont("JModHintFont", {
	font = "BahnSchrift",
	size = 48,
	weight = 500,
	antialias = true,
})

local arUp = Material("hint/up.png", "smooth")
local arRight = Material("hint/right.png", "smooth")
local arDown = Material("hint/down.png", "smooth")
local arLeft = Material("hint/left.png", "smooth")
local start = SysTime()

net.Receive("JMod_Hint",function()
	local specific = tobool(net.ReadBit())
	local str = net.ReadString()
	MsgC(Color(255,255,255), "[JMod] ", str, "\n")
	notification.AddLegacy(str, NOTIFY_HINT, 10)
	if not(specific)then surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" ) end
end)

local NeedAltKeyMsg = true
net.Receive("JMod_PlayerSpawn",function()
	local DoHints = tobool(net.ReadBit())
	if not input.LookupBinding("+walk") then
		chat.AddText(Color(255,0,0), "Your Walk key is not bound; JMod entities will be mostly unusable.")
		chat.AddText(Color(255,0,0), "Please bind it in Settings or with concommand 'bind alt +walk'.")
	end
end)

concommand.Add("jmod_wiki", function()
	gui.OpenURL("https://github.com/Jackarunda/gmod/wiki")
end)