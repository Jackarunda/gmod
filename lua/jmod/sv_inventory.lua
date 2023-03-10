function JMod.EZ_Open_Inventory(ply)
	net.Start("JMod_Inventory")
	net.WriteString(ply:GetModel())
	net.Send(ply)
end
