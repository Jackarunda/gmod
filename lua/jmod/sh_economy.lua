JMod.NaturalResourceTable = JMod.NaturalResourceTable or {}

JMod.SmeltingTable = {
	[JMod.EZ_RESOURCE_TYPES.IRONORE] = {
		JMod.EZ_RESOURCE_TYPES.STEEL, 1
	},
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = {
		JMod.EZ_RESOURCE_TYPES.LEAD, .5
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = {
		JMod.EZ_RESOURCE_TYPES.ALUMINUM, .5
	},
	[JMod.EZ_RESOURCE_TYPES.COPPERORE] = {
		JMod.EZ_RESOURCE_TYPES.COPPER, .5
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
		JMod.EZ_RESOURCE_TYPES.URANIUM, .2
	},
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = {
		JMod.EZ_RESOURCE_TYPES.PLATINUM, .2
	},
	[JMod.EZ_RESOURCE_TYPES.SAND] = {
		JMod.EZ_RESOURCE_TYPES.GLASS, .75
	},
}

JMod.RefiningTable = {
	[JMod.EZ_RESOURCE_TYPES.OIL] = {
		[JMod.EZ_RESOURCE_TYPES.FUEL] = 4,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .5,
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .5,
		[JMod.EZ_RESOURCE_TYPES.GAS] = .2
	},
	[JMod.EZ_RESOURCE_TYPES.URANIUM] = {
		[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL] = .2
	}
}

-- https://docs.google.com/spreadsheets/d/1-U5iuH2o6hzwhsHVbSRiBa6NJhib-sj8xQcId_e3H_s/edit#gid=0
JMod.EnergyEconomyParameters = {
	BasePowerConversions = {
		[JMod.EZ_RESOURCE_TYPES.FUEL] = 20,
		[JMod.EZ_RESOURCE_TYPES.COAL] = 10,
		[JMod.EZ_RESOURCE_TYPES.WOOD] = 5
	},
	FuelGennyEfficiencies = {
		[JMod.EZ_GRADE_BASIC] = .2,
		[JMod.EZ_GRADE_COPPER] = .275,
		[JMod.EZ_GRADE_SILVER] = .35,
		[JMod.EZ_GRADE_GOLD] = .425,
		[JMod.EZ_GRADE_PLATINUM] = .5
	},
	SteamGennyEfficiencies = {
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
	--[[[JMod.EZ_RESOURCE_TYPES.SAND] = {
		frequency = 5,
		avgamt = 800,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			sand = 2
		}
	},--]]
	--[[[JMod.EZ_RESOURCE_TYPES.CERAMIC] = {
		frequency = 6,
		avgamt = 200,
		avgsize = 200,
		limits = {},
		boosts = {
			water = 3
		}
	},]]--
	[JMod.EZ_RESOURCE_TYPES.OIL] = {
		frequency = 8,
		avgamt = 600,
		avgsize = 300,
		boosts = {
			water = 2
		},
		limits = {}
	},
	[JMod.EZ_RESOURCE_TYPES.COAL] = {
		frequency = 12,
		avgamt = 800,
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
		avgamt = 700,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = {
		frequency = 7,
		avgamt = 600,
		avgsize = 200,
		limits = {
			nowater = true
		},
		boosts = {
			rock = 2
		}
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = {
		frequency = 9,
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
		avgamt = 350,
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
		avgamt = 400,
		avgsize = 200,
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
		[JMod.EZ_RESOURCE_TYPES.LEAD] = .05,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .1,
		[JMod.EZ_RESOURCE_TYPES.COPPER] = .05,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .2,
		[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .05
	},
	canister = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.GAS] = .5
	},
	plastic = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .5
	},
	paintcan = {
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .4,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2
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
		[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2
	},
	dirt = {
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .1,
		[JMod.EZ_RESOURCE_TYPES.CLOTH] = .1
	},
	sand = {
		[JMod.EZ_RESOURCE_TYPES.SAND] = .4
	},
	sandbags = {
		[JMod.EZ_RESOURCE_TYPES.SAND] = .8,
		[JMod.EZ_RESOURCE_TYPES.WOOD] = .1
	},
	concrete = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .5
	},
	paper = {
		[JMod.EZ_RESOURCE_TYPES.PAPER] = .8
	},
	cardboard = {
		[JMod.EZ_RESOURCE_TYPES.PAPER] = .8
	},
	rubber = {
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .8
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
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .3,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2
	},
	flesh = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = 3
	},
	zombieflesh = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = 2
	},
	alienflesh = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = 1,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .5
	},
	antlion = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .5,
		[JMod.EZ_RESOURCE_TYPES.CHEMICALS] = .7
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
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .6,
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .2
	},
	jeeptire = {
		[JMod.EZ_RESOURCE_TYPES.RUBBER] = .6,
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
		[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = .1,
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .1,
		[JMod.EZ_RESOURCE_TYPES.TITANIUM] = .2,
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .1
	},
	hunter = {
		[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES] = .1,
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .1,
		[JMod.EZ_RESOURCE_TYPES.TITANIUM] = .2,
		[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1
	},
	slipperymetal = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .3,
		[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .3
	},
	chainlink = {
		[JMod.EZ_RESOURCE_TYPES.STEEL] = .5
	},
	snow = {
		[JMod.EZ_RESOURCE_TYPES.WATER] = .5
	},
	ice = {
		[JMod.EZ_RESOURCE_TYPES.WATER] = .6
	},
	rock = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .5
	},
	boulder = {
		[JMod.EZ_RESOURCE_TYPES.CERAMIC] = .5
	},
	grass = {
		[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .5
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
				[JMod.EZ_RESOURCE_TYPES.NUTRIENTS] = .8
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
				[JMod.EZ_RESOURCE_TYPES.OIL] = .3,
				[JMod.EZ_RESOURCE_TYPES.FUEL] = .1
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
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .5,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .05,
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .1,
				[JMod.EZ_RESOURCE_TYPES.RUBBER] = .1,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .05,
				[JMod.EZ_RESOURCE_TYPES.LEAD] = .05
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
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.GLASS] = .5,
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2
			}
		},
		{
			substrings = {"radio", "receiver", "monitor", "consolebox"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.BASICPARTS] = .2,
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
			substrings = {"police"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.CLOTH] = 1,
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
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .1,
				[JMod.EZ_RESOURCE_TYPES.LEAD] = .05
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
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .2,
				[JMod.EZ_RESOURCE_TYPES.LEAD] = .5,
				[JMod.EZ_RESOURCE_TYPES.POWER] = 5
			}
		},
		{
			substrings = {"pipe"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.LEAD] = .2,
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .5
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
				[JMod.EZ_RESOURCE_TYPES.RUBBER] = .05,
				[JMod.EZ_RESOURCE_TYPES.LEAD] = .05
			}
		},
		{
			substrings = {"computer", "/props_lab/"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .5,
				[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS] = .1
			}
		},
		{
			substrings = {"sink", "mooring_cleat"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .5,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .3
			}
		},
		{
			substrings = {"pot"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .4,
				[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .2,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .1
			}
		},
		{
			substrings = {"/hunter/"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .7,
			}
		},
		{
			substrings = {"acorn"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.ORGANICS] = .5,
			}
		},
		{
			substrings = {"metalbucket"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .6,
				[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .2
			}
		},
		{
			substrings = {"sawblade"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .6,
				[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = .2,
			}
		},
		{
			substrings = {"/props_wasteland/barricade"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .2,
				[JMod.EZ_RESOURCE_TYPES.WOOD] = .5,
			}
		},
		{
			substrings = {"trashbin"},
			yield = {
				[JMod.EZ_RESOURCE_TYPES.PLASTIC] = .25,
				[JMod.EZ_RESOURCE_TYPES.RUBBER] = .25,
				[JMod.EZ_RESOURCE_TYPES.PAPER] = .2,
				[JMod.EZ_RESOURCE_TYPES.STEEL] = .05,
				[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = .1,
				[JMod.EZ_RESOURCE_TYPES.COPPER] = .05
			}
		}
	}
}

local BlacklistedGroups = {COLLISION_GROUP_DEBRIS, COLLISION_GROUP_WEAPON}
local BlacklistedBor = 0

for i = 1, #BlacklistedGroups do
	BlacklistedBor = bit.bor(BlacklistedBor, BlacklistedGroups[i])
end

function JMod.GetSalvageYield(ent)
	if not IsValid(ent) then return {}, "" end
	if ent.GetState and (ent:GetState() >= 1) then return {}, "bruh, it's active" end

	local Class, Mdl = string.lower(ent:GetClass()), string.lower(ent:GetModel())

	if table.HasValue(BlacklistedGroups, bit.band(ent:GetCollisionGroup(), BlacklistedBor)) then return {}, "cannot salvage: bad collision group" end
	if ent:IsWorld() then return {}, "can't salvage the world" end

	if ent:GetClass() == "ent_jack_gmod_ezcompactbox" then
		if IsValid(ent:GetContents()) then
			ent = ent:GetContents()
		else
			return {}, "cannot salvage: no contents"
		end
	end

	local PhysNum = ent:GetPhysicsObjectCount()
	local Phys = ent:GetPhysicsObject()

	if not IsValid(Phys) then return {}, "cannot salvage: invalid physics" end

	local Mat, Mass = string.lower(Phys:GetMaterial()), Phys:GetMass()

	if not (Mat and Mass and (Mass > 0)) then return {}, "cannot salvage: corrupt physics" end

	local RagMass = nil

	if PhysNum > 1 then
		for i = 1, PhysNum do
			local RagPhys = ent:GetPhysicsObjectNum(i - 1)
			if not IsValid(RagPhys) then break end
			RagMass = (RagMass or 0) + RagPhys:GetMass()
		end
	end
	if Mass > 35 then
		Mass = math.ceil((RagMass or Mass) ^ .9) -- exponent to keep yield from stupidheavy objects from ruining the game
	end

	-- again, more corrections
	if Class == "func_physbox" then
		Mass = Mass / 2
	end

	if Mass > 10000 then return {}, "cannot salvage: too large" end
	if ent:IsNPC() or ent:IsPlayer() then return {}, (tostring(ent.PrintName or "They") .. " don't want to be salvaged") or ".." end
	
	local AnnoyedReplyTable = {
		"no",
		"...no",
		"STOP YOU MORON",
		"I have become wrench, destoyer of entities",
		"Stop it!",
		"You can't salvage this",
		"Stop trying to salvage this already",
	}
	if ent.IsJackyEZresource or ent.EZammo then return {}, table.Random(AnnoyedReplyTable) end
	if Class == "ent_jack_gmod_eztoolbox" then return {}, table.Random(AnnoyedReplyTable) end
	if Class == "ent_jack_ezcompactbox" then return {}, table.Random(AnnoyedReplyTable) end

	if SERVER then
		for k, v in pairs(JMod.Config.Tools.Toolbox.SalvagingBlacklist) do
			if string.find(Class, v) then return {}, "object may not be salvaged" end
		end
	end

	if ent.LVS and (Mat == "default_silent") then Mat = "metalvehicle" end

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
	if ent.BackupRecipe and istable(ent.BackupRecipe) then
		Info = ent.BackupRecipe
		ScaleByMass = false
	end

	for name, info in pairs(JMod.Config.Craftables) do
		if isstring(info.results) and ((info.results == Class) or (string.lower(info.results) == Mdl)) then
			Info = info.craftingReqs
			ScaleByMass = false

			break
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
			Results[k] = math.ceil(v * Mass * 1.5 * JMod.Config.ResourceEconomy.SalvageYield)
		else
			Results[k] = math.ceil(v * .9)
		end
		if ent.LVS and ent.ExplodedAlready then
			Results[k] = Results[k] * .5
		end
		if Results[k] <= 0 then Results[k] = nil end
	end

	if ent.IsJackyEZmachine then
		for k, v in pairs(JMod.EZ_RESOURCE_TYPE_METHODS) do
			local ResourceMethod = ent["Get"..v]
			if not(istable(ent.FlexFuels) and (v == "Electricity")) then
				if ResourceMethod then
					Results[k] = (Results[k] or 0) + math.Round(ResourceMethod(ent))
				end
				if ent.GetOre and ent.GetOreType and ent:GetOreType() ~= "generic" then
					Results[ent:GetOreType()] = (Results[ent:GetOreType()] or 0) + ent:GetOre()
				end
			end
		end

		if ent.EZupgradable then
			local Grade = ent:GetGrade()
			if Grade > 1 then
				for k, v in pairs(ent.UpgradeCosts[Grade]) do
					Results[k] = (Results[k] or 0) + math.Round(v*.9)
				end
			end
		end
	end

	--[[if ent.JModInv then
		for k, v in pairs(ent.JModInv.EZresources) do
			Results[k] = (Results[k] or 0) + v
		end
	end--]]

	local FinalResults, Message = hook.Run("JMod_SalvageResults", ent, Results, Mat, Mdl, Specialized)

	if istable(FinalResults) then
		Results = FinalResults
	elseif isbool(FinalResults) and (FinalResults == false) then
		Results = {}
	end

	return Results, "salvaging results for " .. tostring(ent) .. ":\nphysmat: " .. Mat .. "\nnumber of physics: " .. PhysNum .. "\nmodel: " .. Mdl .. "\nspecialized: " .. tostring(Specialized) .. "\n" .. tostring(Message)
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

function JMod.GetDepositAtPos(machine, positionToCheck, mult)
	mult = mult or 1
	-- first, figure out which deposits we are inside of, if any
	local DepositsInRange = {}

	for k, v in pairs(JMod.NaturalResourceTable) do
		-- Make sure the resource is on the whitelist
		local Dist = positionToCheck:Distance(v.pos)

		-- store they desposit's key if we're inside of it
		if (Dist <= (v.siz * mult)) then
			if IsValid(machine) then
				if istable(machine.BlacklistedResources) and table.HasValue(machine.BlacklistedResources, v.typ) then continue end
				if istable(machine.WhitelistedResources) and not(table.HasValue(machine.WhitelistedResources, v.typ)) then continue end
			end
			if (v.rate or (v.amt > 0)) then
				table.insert(DepositsInRange, k)
			end
		end
	end

	-- now, among all the deposits we are inside of, let's find the closest one
	local ClosestDeposit, ClosestRange = nil, 9e9

	if #DepositsInRange > 0 then
		for k, v in pairs(DepositsInRange) do
			local DepositInfo = JMod.NaturalResourceTable[v]
			local Dist = positionToCheck:Distance(DepositInfo.pos)

			if Dist < ClosestRange then
				ClosestDeposit = v
				ClosestRange = Dist
			end
		end
	end

	if ClosestDeposit then
		return ClosestDeposit
	else
		return nil
	end
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
								--if v.siz < w.siz then
								--	table.remove(tbl, l)
								--else
									table.remove(tbl, k)
								--end
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
	JMod.NatureMats = {[MAT_SNOW]="snow", [MAT_SAND]="sand", [MAT_FOLIAGE]="foliage", [MAT_SLOSH]="slime", [MAT_GRASS]="grass", [MAT_DIRT]="dirt"}
	JMod.CityMats = {[MAT_CONCRETE]="concrete", [MAT_GLASS]="glass", [MAT_METAL]="metal", [MAT_GRATE]="chainlink", [MAT_TILE]="tile", [MAT_VENT]="metalvent", [MAT_PLASTIC]="plastic"}

	local MaxTries, SurfacePropBlacklist, RockNames = 10000, {"paper", "plaster", "rubber", "carpet"}, {"rock", "boulder"}

	local function TabContainsSubString(tbl, str)
		if not str then return false end

		for k, v in pairs(tbl) do
			if string.find(v, str) then return true end
		end

		return false
	end

	local function IsSurfaceSuitable(tr, props, mat, tex)
		if not (tr.Hit and tr.HitWorld and not tr.StartSolid and not tr.HitSky) then return false end
		if not JMod.NatureMats[tr.MatType] then return false end
		if TabContainsSubString(SurfacePropBlacklist, mat) then return false end
		if TabContainsSubString(SurfacePropBlacklist, HitTexture) then return false end
		if tr.HitNormal.z < 0.75 then return false end

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

	local InverseOperationInterval = 10000 --1000

	function JMod.DetermineMapBounds(endFunc)
		print("JMOD: measuring map bounds...")
		local xMin, xMax, yMin, yMax, zMin, zMax, SkyCamPos, SkyCamElims = 9e9, -9e9, 9e9, -9e9, 9e9, -9e9, nil, 0

		for k, v in pairs(ents.FindByClass("sky_camera")) do
			SkyCamPos = v:GetPos() -- only if this is found
			print("JMOD: skybox camera located at:", SkyCamPos)
		end

		for i = 1, 10000 do
			timer.Simple(i / InverseOperationInterval, function()
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
					print("JMOD: " .. math.Round(i / 10000 * 100) .. "%")
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
			--local WorldCenter = Vector(xMax + xMin, yMax + yMin, zMax + zMin)
			--print("DEBUG: WORLDCENTER: " .. tostring(WorldCenter))

			for i = 1, MaxTries do
				timer.Simple(i / InverseOperationInterval, function()
					local CheckPos = Vector(math.random(xMin, xMax), math.random(yMin, yMax), math.random(zMin, zMax))
					debugoverlay.Cross(CheckPos, 10, 2, ColorRand(), true)
					-- we're in the world... start the worldhit trace
					local Tr = util.QuickTrace(CheckPos, Vector(0, 0, -6000))
					debugoverlay.Line(CheckPos, Tr.HitPos, 2, ColorRand(), true)
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

						if #Resources > (MaxResourceDepositCount / 2) then
							for k, v in ipairs(Resources) do
								local ResourceInfo = JMod.ResourceDepositInfo[v.typ]
								v.siz = math.min(v.siz * 2, ResourceInfo.avgsize * 3)
								if not v.rate then
									v.amt = v.amt * 2
								else
									v.rate =  math.min(v.rate * 1.5, ResourceInfo.avgrate * 1.5)
								end
							end
						end

						RemoveOverlaps(Resources)
						table.sort(Resources, function(a, b) return a.siz > b.siz end)
						JMod.NaturalResourceTable = Resources
						print("JMOD: resource generation finished with " .. #Resources .. " resource deposits")

						if GetConVar("sv_cheats"):GetBool() then
							net.Start("JMod_NaturalResources")
								net.WriteBool(false)
								net.WriteTable(JMod.NaturalResourceTable)
							net.Broadcast()
						end
					elseif i % 1000 == 0 then
						print("JMOD: " .. math.Round(i / MaxTries * 100) .. "%")
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

	JMod.ScroungeTableItems = {
		["urban"] = {
			["models/props_junk/PopCan01a.mdl"] = 5,
			["models/props_interiors/furniture_chair01a.mdl"] = 1,
			["models/nova/chair_wood01.mdl"] = 1,
			["models/props_junk/cardboard_box004a.mdl"] = 1,
			["models/props_c17/metalpot002a.mdl"] = 1,
			["models/props_debris/wood_chunk06a.mdl"] = 1,
			["models/props_interiors/pot01a.mdl"] = 2,
			["models/props_interiors/pot02a.mdl"] = 2,
			["models/jmod_scrounge/garbage_coffeemug001a_jmod.mdl"] = 1,
			["models/jmod_scrounge/garbage_glassbottle001a_jmod.mdl"] = 2,
			["models/props_junk/garbage_milkcarton001a.mdl"] = 3,
			["models/props_junk/garbage_metalcan002a.mdl"] = 4,
			["models/props_junk/garbage_takeoutcarton001a.mdl"] = .5,
			["models/props_junk/garbage_plasticbottle003a.mdl"] = 2,
			["models/props_junk/garbage_plasticbottle001a.mdl"] = 2,
			["models/jmod_scrounge/glassbottle01a_jmod.mdl"] = 1,
			["models/jmod_scrounge/glassjug01_jmod.mdl"] = 1,
			["models/props_junk/metal_paintcan001a.mdl"] = 1,
			["models/props_junk/shoe001a.mdl"] = 1,
			["models/jmod_scrounge/terracotta01_jmod.mdl"] = 1,
			["models/props_junk/trafficcone001a.mdl"] = 1,
			["models/props_junk/plasticcrate01a.mdl"] = 1,
			["models/props_junk/metalbucket02a.mdl"] = 2,
			["models/props_vehicles/carparts_tire01a.mdl"] = 2,
			["models/props_junk/cinderblock01a.mdl"] = 1,
			["models/props_junk/propane_tank001a.mdl"] = 1,
			["models/props_vehicles/car002a_physics.mdl"] = .5,
			["models/props_wasteland/barricade001a.mdl"] = 1,
			["models/props_interiors/SinkKitchen01a.mdl"] = 1,
			["models/props_borealis/mooring_cleat01.mdl"] = 2,
			["models/items/car_battery01.mdl"] = 0.3,
			["models/props_junk/TrashBin01a.mdl"] = .3,
			["models/props_junk/wood_crate001a.mdl"] = .3,
			["models/props_junk/bicycle01a.mdl"] = .05
		},
		["rural"] = {
			["ent_jack_gmod_ezwheatseed"] = .5,
			["ent_jack_gmod_ezcornkernals"] = .5,
			["ent_jack_gmod_ezacorn"] = .5,
			["models/jmod_scrounge/logs.mdl"] = 2,
			["models/props_debris/wood_chunk06a.mdl"] = 2,
			["models/props_junk/watermelon01.mdl"] = 1,
			["models/jmod/resources/rock05a.mdl"] = 1,
			["models/props_junk/rock001a.mdl"] = 1,
			["models/props_vehicles/car003b_physics.mdl"] = 0.1,
			["models/props_c17/streetsign004f.mdl"] = 1,
			["models/items/car_battery01.mdl"] = 0.2,
			["models/props_junk/TrashBin01a.mdl"] = .2,
			["models/props_junk/wood_crate001a.mdl"] = .2
		}
	}

	local ScroungedPositions = {}

	function JMod.EZ_ScroungeArea(ply, cmd, args)
		local Time = CurTime()
		local Debug = (args and args[1]) or false --JMod.IsAdmin(ply) and GetConVar("sv_cheats"):GetBool()

		if Debug then
			if not JMod.IsAdmin(ply) then print("JMod: This console command only works for admins") return end
			if not GetConVar("sv_cheats"):GetBool() then print("JMod: This needs sv_cheats set to 1") return end
		end

		local Pos, Range = ply:GetShootPos(), 500

		if not(JMod.Config.General.AllowScrounging) and not(Debug) then ply:PrintMessage(HUD_PRINTCENTER, "Scrounging is not allowed") return end
		if not (Debug) then
			for k, pos in pairs(ScroungedPositions) do
				local DistanceTo = Pos:Distance(pos)
				if (DistanceTo < Range) then ply:PrintMessage(HUD_PRINTCENTER, "This area has been scavenged too recently") return end
			end

			ply.NextScroungeTime = ply.NextScroungeTime or 0
			if ply.NextScroungeTime > Time then ply:PrintMessage(HUD_PRINTCENTER, "Slow down there pardner") return end
			ply.NextScroungeTime = Time + (20 * JMod.Config.ResourceEconomy.ScroungeCooldownMult)
		end

		local ScroungeTable = {}

		for typ, tbl in pairs(JMod.ScroungeTableItems) do
			ScroungeTable[typ] = ScroungeTable[typ] or {}
			for item, freq in pairs(tbl) do
				for i=1, (freq * 10 or 10) do
					table.insert(ScroungeTable[typ], item)
				end
			end
		end
		
		local ScroungeResults = {}
		for i = 1, 100 do
			local StartPos = Pos + Vector(math.random(-Range, Range), math.random(-Range, Range), math.random(0, Range/2))
			local Contents = util.PointContents(StartPos)
			if (bit.band(Contents, CONTENTS_EMPTY) == CONTENTS_EMPTY) or (bit.band(Contents, CONTENTS_TESTFOGVOLUME) == CONTENTS_TESTFOGVOLUME) then
				local DownTr = util.TraceLine({
					start = StartPos,
					endpos = StartPos - Vector(0, 0, Range * 2),
					filter = {ply},
					mask = MASK_SOLID_BRUSHONLY
				})
				if DownTr.Hit then
					local Mat = DownTr.MatType
					local IsNatureMat = not not JMod.NatureMats[Mat]
					local IsCityMat = not not JMod.CityMats[Mat]

					if (IsNatureMat or IsCityMat) then
						table.insert(ScroungeResults, (IsNatureMat and "rural") or (IsCityMat and "urban"))
					end
				end
			end
		end

		if table.IsEmpty(ScroungeResults) then ply:PrintMessage(HUD_PRINTCENTER, "There's nothing here") return end

		local StuffPerScrounge, SpawnedItems, AttemptedCount, MaxAttempts = math.Round(JMod.Config.ResourceEconomy.ScroungeResultAmount), 0, 0, 1000
		local LastEnv
		local StartTr = util.QuickTrace(Pos, Vector(0, 0, Range * .5), ply)
		local StartPos = StartTr.HitPos + StartTr.HitNormal * 5
		while ((SpawnedItems < StuffPerScrounge) and (AttemptedCount < MaxAttempts)) do
			AttemptedCount = AttemptedCount + 1
			--local Contents = util.PointContents(PotentialSpawnPos)
			--if (bit.band(Contents, CONTENTS_EMPTY) == CONTENTS_EMPTY) or (bit.band(Contents, CONTENTS_TESTFOGVOLUME) == CONTENTS_TESTFOGVOLUME) then
				local ConeVec = (Pos - StartPos + VectorRand() * Range * .3):GetNormalized()
				local ConeTr = util.TraceLine({
					start = StartPos,
					endpos = StartPos + ConeVec * Range * 2,
					--mins = Vector(-20, -20, -20),
					--maxs = Vector(20, 20, 20),
					mask = MASK_SOLID,
					filter = {ply}
				})
				debugoverlay.Line(StartPos, ConeTr.HitPos, 5, Color(255, 0, 0), true)
				if ConeTr.Hit and (ConeTr.Entity == game.GetWorld()) then
					local PosSetTr = util.QuickTrace(ConeTr.HitPos + ConeTr.HitNormal * 5, Vector(0, 0, -Range))
					local InsertIntoInv = false

					if PosSetTr.Hit and PosSetTr.Entity == game.GetWorld() then
						local EnvironmentType = table.Random(ScroungeResults)
						local SelectedScroungeTable = ScroungeTable[EnvironmentType]
						local ScroungedItem = table.Random(SelectedScroungeTable)
						local Loot
						if LastEnv and (LastEnv ~= EnvironmentType) and (math.random(1, 1000) == 1) then
							Loot = ents.Create("ent_jack_gmod_ezanomaly_gnome")
						elseif string.find(ScroungedItem, ".mdl") then
							Loot = ents.Create("prop_physics")
							Loot:SetModel(ScroungedItem)
							JMod.SetEZowner(Loot, ply)
							local NumBodyGroups = Loot:GetNumBodyGroups()
							if NumBodyGroups > 0 then
								for i = 0, NumBodyGroups - 1 do
									Loot:SetBodygroup(math.random(0, NumBodyGroups - 1), math.random(0, Loot:GetBodygroupCount(i)))
								end
							end
							if Loot:SkinCount() > 0 then
								Loot:SetSkin(math.random(0, Loot:SkinCount() - 1))
							end
							InsertIntoInv = true
						else
							Loot = ents.Create(ScroungedItem)
							InsertIntoInv = true
						end
						debugoverlay.Line(ConeTr.HitPos + ConeTr.HitNormal * 5, PosSetTr.HitPos, 5, Color(0, 255, 0), true)
						local Mins, Maxs = Loot:GetCollisionBounds()
						local BBVec = Maxs - Mins
						local SpawnHeight = math.max(BBVec.x, BBVec.y, BBVec.z)
						Loot:SetPos(PosSetTr.HitPos + Vector(0, 0, SpawnHeight + 2))
						Loot:SetAngles(AngleRand())
						Loot:Spawn()
						Loot:Activate()
						JMod.SetEZowner(Loot, ply)
						SpawnedItems = SpawnedItems + 1
						LastEnv = EnvironmentType
						
						if JMod.Config.ResourceEconomy.ScroungeDespawnTimeMult > 0 then
							timer.Simple(3, function()
								if (IsValid(Loot)) and (Loot:GetPhysicsObject():GetMass() <= 35) then
									-- record natural resting place
									Loot.SpawnPos = Loot:GetPos()
									timer.Simple(120 * JMod.Config.ResourceEconomy.ScroungeDespawnTimeMult, function()
										if (IsValid(Loot)) then
										local CurPos = Loot:GetPos()
											if (CurPos:Distance(Loot.SpawnPos) <= 1) then
												-- it hasn't moved an inch in a whole two minutes
												constraint.RemoveAll(Loot)
												Loot:SetNotSolid(true)
												Loot:DrawShadow(false)
												Loot:GetPhysicsObject():EnableCollisions(false)
												Loot:GetPhysicsObject():EnableGravity(false)
												Loot:GetPhysicsObject():SetVelocity(Vector(0, 0, -5))
												SafeRemoveEntityDelayed(Loot, 2)
											end
										end
									end)
								end
							end)
						end
					end
				end
			--end
		end

		if not Debug then
			table.insert(ScroungedPositions, Pos)
			timer.Simple(300 * JMod.Config.ResourceEconomy.ScroungeAreaRefreshMult, function()
				if not table.IsEmpty(ScroungedPositions) then
					table.remove(ScroungedPositions, 1)
				end
			end)
		end
	end

	concommand.Add("jmod_debug_scrounge", function(ply, cmd, args)
		if not GetConVar("sv_cheats"):GetBool() then print("JMod: This needs sv_cheats set to 1") return end
		if IsValid(ply) and not JMod.IsAdmin(ply) then return end
		JMod.EZ_ScroungeArea(ply, nil, {true})
	end, nil, "Test scrounging without any modifiers")

	hook.Add("InitPostEntity", "JMod_InitPostEntityServer", function()
		JMod.GenerateNaturalResources()
	end)

	concommand.Add("jmod_admin_generatenaturalresources", function(ply, cmd, args)
		if IsValid(ply) and not JMod.IsAdmin(ply) then return end
		JMod.GenerateNaturalResources() 
	end, nil, "Re-generates the natrual resource deposits")

	concommand.Add("jmod_debug_shownaturalresources", function(ply, cmd, args)
		if not GetConVar("sv_cheats"):GetBool() then print("JMod: This needs sv_cheats set to 1") return end
		if IsValid(ply) and not JMod.IsAdmin(ply) then return end
		net.Start("JMod_NaturalResources")
		net.WriteBool(true)
		net.WriteTable(JMod.NaturalResourceTable)
		net.Send(ply)
	end, nil, "Shows locations for natural resource extraction.")

	--[[concommand.Add("jmod_debug_remove_naturalresource",function(ply,cmd,args)
		if not(GetConVar("sv_cheats"):GetBool())then return end
		if((IsValid(ply))and not(JMod.IsAdmin(ply)))then return end
		for i in #args do
			local depositToRemove = table.remove(JMod.NaturalResourceTable, args[i])
			print("Removed deposit #: " .. args[i])
		end
	end, nil, "Removes one or more natural resource deposits")--]]

elseif CLIENT then
	local ShowNaturalResources = false
	local NaturalResourceDisplayCache = {}

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

		local Ply = LocalPlayer()
		local Wep = Ply:GetActiveWeapon()
		if IsValid(Wep) and Wep.ScanResults then
			for k, v in pairs(Wep.ScanResults) do
				-- let's draw this closer to the ground
				local DrawTrace = util.TraceLine({
					start = v.pos + Vector(0, 0, 20),
					endpos = v.pos + Vector(0, 0, -2),
					filter = {Ply, Wep},
					mask = MASK_SOLID_BRUSHONLY
				})
				local Ang = DrawTrace.HitNormal:Angle()
				Ang:RotateAroundAxis(Ang:Right(), -90)
				JMod.HoloGraphicDisplay(nil, DrawTrace.HitPos + DrawTrace.HitNormal * 5, Ang, 1, 30000, function()
					JMod.StandardResourceDisplay(v.typ, v.amt or v.rate, nil, 0, 0, v.siz * 2, true, nil, 50, v.rate)
				end, true)
			end
		end
	end)
end
