function JMod.EZ_Open_ConfigUI(ply)
	net.Start("JMod_ConfigUI")
	net.WriteTable(JMod.Config)
	net.Send(ply)
end