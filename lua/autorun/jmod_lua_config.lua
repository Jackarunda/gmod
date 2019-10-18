AddCSLuaFile()
-- add custom functions here
JMOD_LUA_CONFIG = {
	BlueprintFuncs = {
		spawnHL2buggy = function(playa, position, angles)
			local Ent = ents.Create("prop_vehicle_jeep_old")
			Ent:SetModel("models/buggy.mdl")
			Ent:SetKeyValue("vehiclescript","scripts/vehicles/jeep_test.txt")
			Ent:SetPos(position)
			Ent:SetAngles(angles)
			Ent.Owner=playa
			Ent:Spawn()
			Ent:Activate()
		end
	}
}