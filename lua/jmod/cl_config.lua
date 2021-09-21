JMod.ClientConfig = JMod.ClientConfig or {}
local function InsertEmptyFileConfig(IP)
	JMod.ClientConfig[IP] = {
		WorkbenchFavs = {},
		BuildKitFavs = {},
		AidRadioFavs = {}
	}		
end
local function PlayerConnectClient()
	local SinglePlayer = game.SinglePlayer()
	local IP = game.GetIPAddress()
	if SinglePlayer then IP = "SinglePlayer" end
	local filename = "jmod_cl_config.txt"
	local Here = file.Exists(filename)
	if Here then
		local Contents = file.Read(filename)
        JMod.ClientConfig=util.JSONToTable(Contents)
    else
		JMod.ClientConfig={}
		JMod.ClientConfig=InsertEmptyFileConfig(IP)
		file.Write(filename, util.TableToJSON(JMod.ClientConfig))
	end
	if not JMod.ClientConfig[IP] then 
		JMod.ClientConfig=InsertEmptyFileConfig(IP)
		file.Write(filename, util.TableToJSON(JMod.ClientConfig))
	end
	print("JMOD: client config file loaded")
end
-- That way you are overriding the default hook.
-- You can use hook.Add to make more functions get called when this event occurs.
hook.Add( "InitPostEntity", "PlayerConnect", function()
	print( "Created a JMOD clientside configuration file." )
end )








concommand.Add("jmod_cl_reloadconfig",function(ply)
	if CLIENT then
	JMod.InitClientConfig(ply)
	end
end)
