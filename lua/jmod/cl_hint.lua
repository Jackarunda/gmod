net.Receive("JMod_Hint",function()
    local new = net.ReadBool()
    if not new then
        notification.AddLegacy(net.ReadString(), NOTIFY_HINT, 10)
        surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" )
        return
    end
end)

