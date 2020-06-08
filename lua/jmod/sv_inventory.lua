function JMod_EZ_Open_Inventory(ply)
	net.Start("JMod_Inventory")
	net.Send(ply)
end