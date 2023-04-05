JMod.NaturalResourceTable = JMod.NaturalResourceTable or {}

JMod.SmeltingTable = {
	[JMod.EZ_RESOURCE_TYPES.IRONORE] = {
		JMod.EZ_RESOURCE_TYPES.STEEL, .5
	},
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = {
		JMod.EZ_RESOURCE_TYPES.LEAD, .5
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = {
		JMod.EZ_RESOURCE_TYPES.ALUMINUM, .5
	},
	[JMod.EZ_RESOURCE_TYPES.COPPERORE] = {
		JMod.EZ_RESOURCE_TYPES.COPPER, .4
	},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTENORE] = {
		JMod.EZ_RESOURCE_TYPES.TUNGSTEN, .4
	},
	[JMod.EZ_RESOURCE_TYPES.TITANIUMORE] = {
		JMod.EZ_RESOURCE_TYPES.TITANIUM, .4
	},
	[JMod.EZ_RESOURCE_TYPES.SILVERORE] = {
		JMod.EZ_RESOURCE_TYPES.SILVER, .3
	},
	[JMod.EZ_RESOURCE_TYPES.GOLDORE] = {
		JMod.EZ_RESOURCE_TYPES.GOLD, .2
	},
	[JMod.EZ_RESOURCE_TYPES.URANIUMORE] = {
		JMod.EZ_RESOURCE_TYPES.URANIUM, .1
	},
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = {
		JMod.EZ_RESOURCE_TYPES.PLATINUM, .1
	}
}

JMod.RefiningTable = {
	[JMod.EZ_RESOURCE_TYPES.OIL] = {
		[JMod.EZ_RESOURCE_TYPES.FUEL] = 3,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .5,
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .5,
		[JMod.EZ_RESOURCE_TYPES.GAS] = .2
	}
}

-- https://docs.google.com/spreadsheets/d/1-U5iuH2o6hzwhsHVbSRiBa6NJhib-sj8xQcId_e3H_s/edit#gid=0
JMod.EnergyEconomyParameters = {
	BasePowerConversions = {
		[JMod.EZ_RESOURCE_TYPES.FUEL] = 11,
		[JMod.EZ_RESOURCE_TYPES.COAL] = 8,
		[JMod.EZ_RESOURCE_TYPES.WOOD] = 3
	},
	FuelGennyEfficiencies = {
		[JMod.EZ_GRADE_BASIC] = .2,
		[JMod.EZ_GRADE_COPPER] = .275,
		[JMod.EZ_GRADE_SILVER] = .35,
		[JMod.EZ_GRADE_GOLD] = .425,
		[JMod.EZ_GRADE_PLATINUM] = .5
	}
}

JMod.ResourceDepositInfo = {
	[JMod.EZ_RESOURCE_TYPES.WATER] = {
		frequency = 10,
		avgrate = .5,
		avgsize = 400,
		limits = {
			nowater = true
		},
		boosts = {
			sand = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.OIL] = {
		frequency = 8,
		avgamt = 500,
		avgsize = 300,
		boosts = {
			water = 2
		},
		limits = {}
	},
	[JMod.EZ_RESOURCE_TYPES.COAL] = {
		frequency = 12,
		avgamt = 500,
		avgsize = 300,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.IRONORE] = {
		frequency = 12,
		avgamt = 500,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = {
		frequency = 8,
		avgamt = 500,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = {
		frequency = 10,
		avgamt = 500,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.COPPERORE] = {
		frequency = 8,
		avgamt = 400,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTENORE] = {
		frequency = 4,
		avgamt = 300,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.TITANIUMORE] = {
		frequency = 4,
		avgamt = 300,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.SILVERORE] = {
		frequency = 3,
		avgamt = 300,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.GOLDORE] = {
		frequency = 2,
		avgamt = 300,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.URANIUMORE] = {
		frequency = 2,
		avgamt = 300,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = {
		frequency = 2,
		avgamt = 300,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.DIAMOND] = {
		dependency = JMod.EZ_RESOURCE_TYPES.COAL,
		frequency = .2,
		avgamt = 80,
		avgsize = 100,
		limits = {}, -- covered by the limits of coal already
		boosts = {}
	},
	["geothermal"] = {
		frequency = 2,
		avgrate = .5,
		avgsize = 100,
		limits = {
			nowater = true
		},
		boosts = {
			snow = 2
		}
	}
}

local SalvagingTable = {
	metalgrate = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .1,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
	},
	default = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2
	},
	wood = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .7
	},
	wood_panel = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .5
	},
	wood_crate = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .5
	},
	wood_furniture = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .4,
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .1,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .05
	},
    wood_solid = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .7
	},
	metal = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .2
	},
	metal_barrel = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .4
	},
	metal_box = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .4
	},
	floating_metal_barrel = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.FUEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.OIL] = .3
	},
	metalpanel = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .5
	},
	metalvehicle = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .1,
		[JMod.EZ_RESOURCE_TYPES.COPPER] = .05,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .1,
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .05
	},
	canister = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.GAS] = .4
	},
	plastic = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .5
	},
	paintcan = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .4,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .1
	},
	plastic_barrel = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
		[JMod.EZ_RESOURCE_TYPES.WATER] = .3
	},
	plastic_barrel_buoyant = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
		[JMod.EZ_RESOURCE_TYPES.WATER] = .3
	},
	plastic_box = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
		[JMod.EZ_RESOURCE_TYPES.GLASS] = .2,
		[JMod.EZ_RESOURCE_TYPES.COPPER] = .2
	},
	computer = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
		[JMod.EZ_RESOURCE_TYPES.COPPER] = .2,
		[JMod.EZ_RESOURCE_TYPES.SILVER] = .1,
		[JMod.EZ_RESOURCE_TYPES.GOLD] = .05,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .1
	},
	dirt = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .1,
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .1
	},
	sand = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .1,
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .1
	},
	sandbags = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .1,
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .1
	},
	concrete = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .4
	},
	paper = {
		[JMod.EZ_RESOURCE_TYPES.PAPER] = .5
	},
	cardboard = {
		[JMod.EZ_RESOURCE_TYPES.PAPER] = .6
	},
	rubber = {
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .5
	},
	carpet = {
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .4,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .1
	},
	watermelon = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .8
	},
	porcelain = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .4
	},
	item = {
		[JMod.EZ_RESOURCE_TYPES.POWER] = .3,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .3
	},
	glassbottle = {
		[JMod.EZ_RESOURCE_TYPES.GLASS] = .4
	},
	glass = {
		[JMod.EZ_RESOURCE_TYPES.GLASS] = .5
	},
	popcan = {
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .8
	},
	pottery = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .4
	},
	wood_plank = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .5
	},
	ceiling_tile = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .4
	},
	metalvent = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .1,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
		[JMod.EZ_RESOURCE_TYPES.PAPER] = .1
	},
	flesh = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = 3
	},
	zombieflesh = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = 2
	},
	alienflesh = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = 1.5,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .5
	},
	antlion = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .5,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = 1.5
	},
	weapon = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .1,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
		[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = .05,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .2
	},
	rubbertire = {
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .3,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2
	},
	jeeptire = {
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .3,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .2
	},
	hay = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .3
	},
	brick = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .4
	},
	solidmetal = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .4,
		[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = .1,
		[JMod.EZ_RESOURCE_TYPES.TITANIUM] = .1
	},
	combine_metal = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .4,
		[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = .1,
		[JMod.EZ_RESOURCE_TYPES.TITANIUM] = .1
	},
	gm_torpedo = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES] = .4,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2
	},
	phx_ww2bomb = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES] = .4,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2
	},
	phx_explosiveball = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES] = .4,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2
	},
	grenade = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES] = .7
	},
	crowbar = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .8
	},
	wood_panel = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .2,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .05,
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .05
	},
	tile = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .5,
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .1
	},
	strider = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .1,
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .1,
		[JMod.EZ_RESOURCE_TYPES.TITANIUM] = .1,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1
	},
	slipperymetal = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .3
	},
	chainlink = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .5
	}
}

local SpecializedSalvagingTable = {
	classname = {}, -- todo: implement
	modelname = {
		{
			substrings = {"crate_fruit", "fruit_crate"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.WOOD] = .2,
				[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .4
			}
		},
		{
			substrings = {"food"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .9
			}
		},
		{
			substrings = {"explosive"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES] = .4
			}
		},
		{
			substrings = {"oildrum"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.OIL] = .4
			}
		},
		{
			substrings = {"vendingmachine"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
				[JMod.EZ_RESOURCE_TYPES.WATER] = .3,
				[JMod.EZ_RESOURCE_TYPES.NUTRIENTS] = .3
			}
		},
		{
			substrings = {"machine", "laundry_washer", "engine", "laundry_dryer"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .4,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .1
			}
		},
		{
			substrings = {"generator0"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .1,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .3
			}
		},
		{
			substrings = {"forklift"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .1,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .05,
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
				[JMod.EZ_RESOURCE_TYPES.RUBBER] = .1,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .05
			}
		},
		{
			substrings = {"propane", "coolingtank"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.GAS] = .6
			}
		},
		{
			substrings = {"gaspump", "gascan"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.FUEL] = .6
			}
		},
		{
			substrings = {"spotlight"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .1,
				[JMod.EZ_RESOURCE_TYPES.GLASS] = .5
			}
		},
		{
			substrings = {"radio", "receiver", "monitor", "consolebox"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .1,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .2,
				[JMod.EZ_RESOURCE_TYPES.GOLD] = .05,
				[JMod.EZ_RESOURCE_TYPES.SILVER] = .1,
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1
			}
		},
		{
			substrings = {"combine_soldier", "combine_super_soldier"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES] = .3,
				[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .3
			}
		},
		{
			substrings = {"helicopter"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.TITANIUM] = .1,
				[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .2,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .2,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .1
			}
		},
		{
			substrings = {"train0"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .3
			}
		},
		{
			substrings = {"battery"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
				[JMod.EZ_RESOURCE_TYPES.POWER] = .7
			}
		},
		{
			substrings = {"ammocrate"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .1,
				[JMod.EZ_RESOURCE_TYPES.AMMO] = .7
			}
		},
		{
			substrings = {"garbage_plasticbottle"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
				[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .8
			}
		},
		{
			substrings = {"/blu/tanks/", "_apc"}, -- simphys tanks and HL2 APCs
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .05,
				[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = .1,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .1,
				[JMod.EZ_RESOURCE_TYPES.RUBBER] = .05
			}
		},
		{
			substrings = {"/hunter/"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .7,
			}
		}
	}
}

local ResourceToMethod = {
	[JMod.EZ_RESOURCE_TYPES.POWER] = "Electricity",
	[JMod.EZ_RESOURCE_TYPES.GAS] = "Gas",
	[JMod.EZ_RESOURCE_TYPES.COOLANT] = "Coolant",
	[JMod.EZ_RESOURCE_TYPES.WATER] = "Water",
	[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = "Chemicals",
	[JMod.EZ_RESOURCE_TYPES.OIL] = "Oil",
	[JMod.EZ_RESOURCE_TYPES.FUEL] = "Fuel",
	[JMod.EZ_RESOURCE_TYPES.AMMO] = "Ammo",
	[JMod.EZ_RESOURCE_TYPES.MUNITIONS] = "Munitions",
	[JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES] = "Supplies",
	[JMod.EZ_RESOURCE_TYPES.COAL] = "Coal"
}

function JMod.GetSalvageYield(ent)
	if not IsValid(ent) then return {}, "" end
	local Class, Mdl = string.lower(ent:GetClass()), string.lower(ent:GetModel())
	if ent:IsWorld() then return {}, "can't salvage the world" end
	local Phys = ent:GetPhysicsObject()
	if not IsValid(Phys) then return {}, "cannot salvage: invalid physics" end
	local Mat, Mass = string.lower(Phys:GetMaterial()), Phys:GetMass()
	if not (Mat and Mass and (Mass > 0)) then return {}, "cannot salvage: corrupt physics" end
	Mass = math.ceil(Mass ^ .9) -- exponent to keep yield from stupidheavy objects from ruining the game

	-- again, more corrections
	if Class == "func_physbox" then
		Mass = Mass / 2
	end

	if Mass > 10000 then return {}, "cannot salvage: too large" end
	if ent:IsNPC() or ent:IsPlayer() then return {}, (ent.PrintName and tostring(ent.PrintName .. " doesn't want to be salvaged")) or ".." end
	local AnnoyedReplyTable = {
		"no",
		"...no",
		"STOP YOU MORON",
		"I have become wrench, destoyer of entities",
		"Stop it!",
		"You can't salvage this",
		"Stop trying to salvage this already",
	}
	if ent.EZsupplies or ent.EZammo then return {}, table.Random(AnnoyedReplyTable) end
	if Class == "ent_jack_gmod_eztoolbox" then return {}, table.Random(AnnoyedReplyTable) end
	if Class == "ent_jack_ezcompactbox" then return {}, table.Random(AnnoyedReplyTable) end

	if SERVER then
		for k, v in pairs(JMod.Config.SalvagingBlacklist) do
			if string.find(Class, v) then return {}, "object may not be salvaged" end
		end
	end

	local Specialized, Info = false, SalvagingTable[Mat]

	for _, typeInfo in pairs(SpecializedSalvagingTable.modelname) do
		for k, v in pairs(typeInfo.substrings) do
			if string.find(Mdl, v) then
				Info = typeInfo.yield
				Specialized = true
				break
			end
		end

		if Specialized then break end
	end

	local ScaleByMass = true

	for name, info in pairs(JMod.Config.Craftables) do
		if info.results == Class then
			Info = info.craftingReqs
			ScaleByMass = false
		end
	end

	if not Info then return {}, "cannot salvage: unknown physics material " .. Mat end

	if Info.random then
		local Types = table.GetKeys(Info.random)
		local ChosenType = table.Random(Types)

		Info = {
			[ChosenType] = Info.random[ChosenType]
		}
	end

	local Results = {}

	for k, v in pairs(Info) do
		if ScaleByMass then
			Results[k] = math.ceil(v * Mass)
		else
			Results[k] = math.ceil(v * .6)
		end
	end

	if ent.IsJackyEZmachine then
		for k, v in pairs(ResourceToMethod) do
			local ResourceMethod = ent["Get"..v]
			if ent["Get"..v] then
				Results[k] = (Results[k] or 0) + ResourceMethod(ent)
			end
			if ent.GetOre and ent.GetOreType and ent:GetOreType() ~= "generic" then
				Results[ent.GetOreType()] = Results[ent.GetOreType()] or 0 + ent:GetOre()
			end
		end
	end

	return Results, "salvaging results for " .. tostring(ent) .. ":\nphysmat: " .. Mat .. "\nmodel: " .. Mdl .. "\nspecialized: " .. tostring(Specialized)
end

function JMod.CalculateUpgradeCosts(buildRequirements)
	if not buildRequirements then return nil end
	local Results, OrigBasic, OrigPrec, OrigAdv = {}, buildRequirements[JMod.EZ_RESOURCE_TYPES.BASICPARTS] or 0, buildRequirements[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] or 0, buildRequirements[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] or 0
	Results[1] = table.FullCopy(buildRequirements)

	Results[2] = {
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = math.Round(OrigBasic * .3),
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = math.Round(OrigPrec * .9),
		[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = math.Round(OrigAdv * .1)
	}

	Results[3] = {
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = math.Round(OrigBasic * .1),
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = math.Round(OrigPrec * .7 + OrigBasic * .3),
		[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = math.Round(OrigAdv * .2)
	}

	Results[4] = {
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = math.Round(OrigPrec * .7 + OrigBasic * .5),
		[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = math.Round(OrigAdv * .2 + OrigBasic * .1)
	}

	Results[5] = {
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = math.Round(OrigPrec * .5 + OrigBasic * .5),
		[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = math.Round(OrigAdv * .5 + OrigBasic * .4 + OrigPrec * .4)
	}

	for grade, mats in pairs(Results) do
		for mat, amt in pairs(mats) do
			if amt <= 0 then
				mats[mat] = nil
			end
		end
	end

	return Results
end

if SERVER then
	concommand.Add("jmod_debug_checksalvage", function(ply, cmd, args)
		if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
		local Ent = ply:GetEyeTrace().Entity

		if Ent then
			local Yield, Msg = JMod.GetSalvageYield(Ent)
			print(Msg)
			PrintTable(Yield)
		end
	end, nil, "prints out the potential resource yield from the object you're looking at")

	local function RemoveOverlaps(tbl)
		local Finished, Tries, RemovedCount = false, 0, 0
		local ResourceInfo = JMod.ResourceDepositInfo

		while not Finished do
			local Removed = false

			for k, v in pairs(tbl) do
				for l, w in pairs(tbl) do
					if l ~= k then
						local Info, Info2 = ResourceInfo[v.typ], ResourceInfo[w.typ]
						local OverlapAllowed = (Info.dependency == w.typ) or (Info2.dependency == v.typ)

						-- dependent resources are meant to overlap
						if not OverlapAllowed then
							local Dist, Min = v.pos:Distance(w.pos), v.siz + w.siz

							if Dist < Min then
								table.remove(tbl, k)
								RemovedCount = RemovedCount + 1
								Removed = true
								break
							end
						end
					end
				end

				if Removed then break end
			end

			if not Removed then
				Finished = true
			end

			Tries = Tries + 1
			if Tries > 10000 then return end
		end

		print("JMOD: removed " .. RemovedCount .. " overlapping resource deposits")
	end

	--[[
	local function WeightByAltitude(tbl,low,deweightOthers)
		local AvgAltitude,Count=0,0
		for k,v in pairs(tbl)do
			AvgAltitude=AvgAltitude+v.pos.z
			Count=Count+1
		end
		AvgAltitude=AvgAltitude/Count
		for k,v in pairs(tbl)do
			if(low)then
				if(v.pos.z<AvgAltitude)then v.amt=v.amt*2 end
			else
				if(v.pos.z>AvgAltitude)then v.amt=v.amt*2 end
			end
			if(deweightOthers)then
				if(low)then
					if(v.pos.z>AvgAltitude)then v.amt=v.amt/2 end
				else
					if(v.pos.z<AvgAltitude)then v.amt=v.amt/2 end
				end
			end
		end
	end
	--]]
	local NatureMats, MaxTries, SurfacePropBlacklist, RockNames = {MAT_SNOW, MAT_SAND, MAT_FOLIAGE, MAT_SLOSH, MAT_GRASS, MAT_DIRT}, 10000, {"paper", "plaster", "rubber", "carpet"}, {"rock", "boulder"}

	local function TabContainsSubString(tbl, str)
		if not str then return false end

		for k, v in pairs(tbl) do
			if string.find(v, str) then return true end
		end

		return false
	end

	local function IsSurfaceSuitable(tr, props, mat, tex)
		if not (tr.Hit and tr.HitWorld and not tr.StartSolid and not tr.HitSky) then return false end
		if not table.HasValue(NatureMats, tr.MatType) then return false end
		if TabContainsSubString(SurfacePropBlacklist, mat) then return false end
		if TabContainsSubString(SurfacePropBlacklist, HitTexture) then return false end

		return true
	end

	local function AnyPositionsVisible(stort, eyund, offsets)
		-- this func traces positions, each with height offsets, until one of the traces clears
		if not (stort and eyund) then return false end

		for k, v in pairs(offsets) do
			local Tr = util.TraceLine({
				start = stort + Vector(0, 0, v[1]),
				endpos = eyund + Vector(0, 0, v[2])
			})

			if not Tr.Hit then return true end
		end

		return false
	end

	function JMod.DetermineMapBounds(endFunc)
		print("JMOD: measuring map bounds...")
		local xMin, xMax, yMin, yMax, zMin, zMax, SkyCamPos, SkyCamElims = 9e9, -9e9, 9e9, -9e9, 9e9, -9e9, nil, 0

		for k, v in pairs(ents.FindByClass("sky_camera")) do
			SkyCamPos = v:GetPos() -- only if this is found
			print("JMOD: skybox camera located at:", SkyCamPos)
		end

		for i = 1, 10000 do
			timer.Simple(i / 1000, function()
				local Pos = Vector(math.random(-20000, 20000), math.random(-20000, 20000), math.random(-20000, 20000))

				if util.IsInWorld(Pos) then
					if not AnyPositionsVisible(SkyCamPos, Pos, {
						{0, 0},
						{1000, 0},
						{0, 500},
						{0, -500},
						{0, 1000},
						{1000, 1000}
					}) then
						xMin = math.min(xMin, Pos.x)
						xMax = math.max(xMax, Pos.x)
						yMin = math.min(yMin, Pos.y)
						yMax = math.max(yMax, Pos.y)
						zMin = math.min(zMin, Pos.z)
						zMax = math.max(zMax, Pos.z)
					else
						SkyCamElims = SkyCamElims + 1
					end
				end

				if i == 10000 then
					zMax = zMax * .9 -- idk, gmod is gay
					print("JMOD: " .. SkyCamElims .. " detection positions eliminated due to being in the skybox")
					print("JMOD: map bounds determined to be:", xMin, xMax, yMin, yMax, zMin, zMax)
					endFunc(xMin, xMax, yMin, yMax, zMin, zMax)
				elseif i % 1000 == 0 then
					print(math.Round(i / 10000 * 100) .. "%")
				end
			end)
		end
	end

	function JMod.GenerateNaturalResources()
		JMod.NaturalResourceTable = {}

		-- first, we have to find the ground
		JMod.DetermineMapBounds(function(xMin, xMax, yMin, yMax, zMin, zMax)
			local GroundVectors = {}
			print("JMOD: generating natural resources...")

			for i = 1, MaxTries do
				timer.Simple(i / 1000, function()
					local CheckPos = Vector(math.random(xMin, xMax), math.random(yMin, yMax), math.random(zMin, zMax))
					-- we're in the world... start the worldhit trace
					local Tr = util.QuickTrace(CheckPos, Vector(0, 0, -4000))
					local Props = util.GetSurfaceData(Tr.SurfaceProps)
					local MatName = string.lower((Props and Props.name) or "")
					local HitTexture = string.lower(Tr.HitTexture)

					if IsSurfaceSuitable(Tr, Props, MatName, HitTexture) then
						-- alright... we've found a good world surface
						table.insert(GroundVectors, {
							pos = Tr.HitPos,
							mat = Tr.MatType,
							rock = TabContainsSubString(RockNames, MatName),
							water = bit.band(util.PointContents(Tr.HitPos + Vector(0, 0, 1)), CONTENTS_WATER) == CONTENTS_WATER
						})
					end

					if i == MaxTries then
						local Frequencies = {}

						for k, v in pairs(JMod.ResourceDepositInfo) do
							for i = 1, v.frequency do
								table.insert(Frequencies, k)
							end
						end

						local Resources, MaxResourceDepositCount = {}, 300

						for k, PosInfo in pairs(GroundVectors) do
							if #Resources < MaxResourceDepositCount then
								local ChosenType = table.Random(Frequencies)
								local ChosenInfo = JMod.ResourceDepositInfo[ChosenType]

								-- we'll handle these afterward
								if not ChosenInfo.dependency then
									if not (PosInfo.water and ChosenInfo.limits.nowater) then
										local Amt, Decimals = (ChosenInfo.avgrate or ChosenInfo.avgamt) * math.Rand(.5, 1.5) * JMod.Config.ResourceEconomy.ResourceRichness, 0

										if ChosenInfo.avgrate then
											Decimals = 2
										end

										if PosInfo.water and ChosenInfo.boosts.water then
											Amt = Amt * math.Rand(2, 4)
										end

										if PosInfo.rock and ChosenInfo.boosts.rock then
											Amt = Amt * math.Rand(2, 4)
										end

										if PosInfo.sand and PosInfo.mat == MAT_SAND then
											Amt = Amt * math.Rand(2, 4)
										end

										if PosInfo.snow and PosInfo.mat == MAT_SNOW then
											Amt = Amt * math.Rand(2, 4)
										end

										-- randomly boost the amt in order to create the potential for conflict ( ͡° ͜ʖ ͡°)
										if math.random(1, 5) == 4 then
											Amt = Amt * math.Rand(1, 5)
										end

										Amt = math.Round(Amt, Decimals)

										local Resource = {
											typ = ChosenType,
											pos = PosInfo.pos,
											siz = math.Round(ChosenInfo.avgsize * math.Rand(.5, 1.5))
										}

										if ChosenInfo.avgrate then
											Resource.rate = Amt
										elseif ChosenInfo.avgamt then
											Resource.amt = Amt
										end

										table.insert(Resources, Resource)
									end
								end
							end
						end

						-- remove initial overlaps
						RemoveOverlaps(Resources)
						-- now let's handle dependent resources
						local ResourcesToAdd = {}

						for name, info in pairs(JMod.ResourceDepositInfo) do
							if info.dependency then
								for k, resourceData in pairs(Resources) do
									if resourceData.typ == info.dependency then
										if math.Rand(0, 1) < info.frequency then
											local Amt = info.avgamt * math.Rand(.5, 1.5) * JMod.Config.ResourceEconomy.ResourceRichness

											if math.random(1, 5) == 4 then
												Amt = Amt * math.Rand(1, 5)
											end

											Amt = math.Round(Amt)

											local Resource = {
												typ = name,
												pos = resourceData.pos + Vector(math.random(-100, 100), math.random(-100, 100), 0),
												siz = math.Round(info.avgsize * math.Rand(.5, 1.5))
											}

											if info.avgrate then
												Resource.rate = Amt
											elseif info.avgamt then
												Resource.amt = Amt
											end

											table.insert(ResourcesToAdd, Resource)
										end
									end
								end
							end
						end

						table.Add(Resources, ResourcesToAdd)
						RemoveOverlaps(Resources)
						table.sort(Resources, function(a, b) return a.siz > b.siz end)
						JMod.NaturalResourceTable = Resources
						print("JMOD: resource generation finished with " .. #Resources .. " resource deposits")
					elseif i % 1000 == 0 then
						print(math.Round(i / MaxTries * 100) .. "%")
					end
				end)
			end
		end)
	end

	function JMod.DepleteNaturalResource(key, amt)
		local Tab = JMod.NaturalResourceTable[key]
		if not Tab then return end
		if Tab.rate then return end
		Tab.amt = math.Round(Tab.amt - amt, 4)

		if Tab.amt <= 0 then
			-- we don't use table.remove because the index shifting causes too many other problems
			JMod.NaturalResourceTable[key] = nil
		end
	end

	hook.Add("InitPostEntity", "JMod_InitPostEntityServer", function()
		JMod.GenerateNaturalResources()
	end)

	concommand.Add("jmod_debug_shownaturalresources", function(ply, cmd, args)
		if not GetConVar("sv_cheats"):GetBool() then print("JMod: This needs sv_cheats set to 1") return end
		if IsValid(ply) and not ply:IsSuperAdmin() then return end
		net.Start("JMod_NaturalResources")
		net.WriteBool(true)
		net.WriteTable(JMod.NaturalResourceTable)
		net.Send(ply)
	end, nil, "Shows locations for natural resource extraction.")
	--[[concommand.Add("jmod_debug_remove_naturalresource",function(ply,cmd,args)
		if not(GetConVar("sv_cheats"):GetBool())then return end
		if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
		for i in #args do
			local depositToRemove = table.remove(JMod.NaturalResourceTable, args[i])
			print("Removed deposit #: " .. args[i])
		end
	end, nil, "Removes one or more natural resource deposits")]]
	--
elseif CLIENT then
	local ShowNaturalResources = false

	net.Receive("JMod_NaturalResources", function()
		if net.ReadBool() then
			ShowNaturalResources = not ShowNaturalResources
			print("natural resource display: " .. tostring(ShowNaturalResources))
		end
		JMod.NaturalResourceTable = net.ReadTable()
	end)

	net.Receive("JMod_Debugging", function()
		local Typ = net.ReadInt(8)

		if Typ == 1 then
			JMod.DebugPositions = net.ReadTable()
		end
	end)

	local DebugMat = Material("sprites/grip_hover")

	hook.Add("PostDrawTranslucentRenderables", "JMod_EconTransRend", function()
		if ShowNaturalResources then
			for k, v in pairs(JMod.NaturalResourceTable) do
				JMod.HoloGraphicDisplay(nil, v.pos, Angle(0, 0, 0), 1, 30000, function()
					JMod.StandardResourceDisplay(v.typ, v.amt or v.rate, nil, 0, 0, v.siz * 2, true, nil, nil, v.rate)
				end)
			end
		end

		if JMod.DebugPositions then
			local Pos = EyePos()

			for k, v in pairs(JMod.DebugPositions) do
				JMod.HoloGraphicDisplay(nil, v, Angle(0, 0, 0), 5, 10000, function()
					surface.SetDrawColor(255, 255, 255, 100)
					surface.SetMaterial(DebugMat)
					surface.DrawTexturedRect(0, 0, 100, 100)
				end)
			end
		end
	end)
end
