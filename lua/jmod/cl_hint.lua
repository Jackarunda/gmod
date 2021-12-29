net.Receive("JMod_Hint",function()
	local specific = tobool(net.ReadBit())
	local isLangKey = net.ReadBool()
	local str = net.ReadString()
	if(isLangKey)then str=JMod.Lang(str) end
	MsgC(Color(255,255,255), "[JMod] ", str, "\n")
	notification.AddLegacy(str, NOTIFY_HINT, 10)
	if not(specific)then surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" ) end
end)

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