JMod.ClientConfig = JMod.ClientConfig or {}

local function InsertEmptyConfig(Tab, IP)
	Tab[IP] = {
		WorkbenchFavs = {},
		ToolboxFavs = {},
		AidRadioFavs = {}
	}
end

local function PlayerConnectClient()
	local SinglePlayer = game.SinglePlayer()
	local IP = game.GetIPAddress()

	if SinglePlayer then
		IP = "SinglePlayer"
	end

	local filename = "jmod_cl_config.txt"
	local Here = file.Exists(filename, "DATA")
	local AllConfigs = {}

	if Here then
		local Contents = file.Read(filename)
		AllConfigs = util.JSONToTable(Contents)
	else
		InsertEmptyConfig(AllConfigs, IP)
		file.Write(filename, util.TableToJSON(AllConfigs, true))
	end

	if not AllConfigs[IP] then
		InsertEmptyConfig(AllConfigs, IP)
		file.Write(filename, util.TableToJSON(AllConfigs, true))
	end

	JMod.ClientConfig = AllConfigs[IP]
	print("JMOD: client config file loaded")
end

function JMod.SaveClientConfig()
	local SinglePlayer = game.SinglePlayer()
	local IP = game.GetIPAddress()

	if SinglePlayer then
		IP = "SinglePlayer"
	end

	local filename = "jmod_cl_config.txt"
	local Here = file.Exists(filename, "DATA")
	local AllConfigs = {}

	if Here then
		local Contents = file.Read(filename)
		AllConfigs = util.JSONToTable(Contents)
	end

	AllConfigs[IP] = JMod.ClientConfig
	file.Write(filename, util.TableToJSON(AllConfigs, true))
end

hook.Add("InitPostEntity", "PlayerConnect", function()
	PlayerConnectClient()
end)

concommand.Add("jmod_cl_reloadconfig", function(ply)
	if CLIENT then
		PlayerConnectClient()
	end
end, nil, JMod.Lang("command jmod_cl_reloadconfig"))
