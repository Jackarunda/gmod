function JMod.EZ_Open_ConfigUI(ply)
	if not ply:IsValid() then return end
	if not ply:IsSuperAdmin() then return end
	net.Start("JMod_ConfigUI")
	net.WriteTable(JMod.Config)
	net.Send(ply)
end