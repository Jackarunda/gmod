local function SetArmorPlayerModelModifications()
	local CSSCTTable = {
		Face={
			["GasMask"]={
				siz=Vector(1,1,1),
				pos=Vector(0,1.7,0),
				ang=Angle(100,180,90),
			},
			["BallisticMask"]={
				siz=Vector(1,1,1),
				pos=Vector(5,-68,0),
				ang=Angle(92,180,90),
			}
		},
		Head={
			["Light"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(1.5,-2,0),
				ang=Angle(-90,0,-90),
			},
			["Medium"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(1,-2,0),
				ang=Angle(-90,0,-90),
			},
			["Heavy"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(1,-3,0),
				ang=Angle(-90,0,-90),
			}
		},
		Torso={
			["Light"]={
				siz=Vector(1.15,1.1,1),
				pos=Vector(-3,-4.5,0),
				ang=Angle(-90,0,90),
			},
			["Medium-Light"]={
				siz=Vector(1.25,1.2,1.2),
				pos=Vector(-3,-6.5,0),
				ang=Angle(-90,0,90),
			},
			["Medium"]={
				siz=Vector(1.2,1.2,1.05),
				pos=Vector(-3,-6.5,0),
				ang=Angle(-90,0,90),
			},
			["Medium-Heavy"]={
				siz=Vector(1.2,1.2,1),
				pos=Vector(-4.5,-10.5,0),
				ang=Angle(-85,0,90),
			},
			["Heavy"]={
				siz=Vector(1,1,1),
				pos=Vector(-10,-50,0),
				ang=Angle(-85,0,90),
			}
		},
		Pelvis={
			["Standard"]={
				siz=Vector(1.5,1.4,1.8),
				pos=Vector(71,0,0),
				ang=Angle(90,-90,0),
			}
		},
		LeftShoulder={
			["Light"]={
				siz=Vector(1.2,1.2,1.2),
				pos=Vector(0,0,-.5),
				ang=Angle(-90,-90,-90),
			},
			["Heavy"]={
				siz=Vector(1,1,1),
				pos=Vector(-6,60,-31),
				ang=Angle(90,-20,110),
			}
		},
		RightShoulder={
			["Light"]={
				siz=Vector(1.2,1.2,1.2),
				pos=Vector(0,0,.5),
				ang=Angle(-90,-90,-90),
			},
			["Heavy"]={
				siz=Vector(1,1,1),
				pos=Vector(-32,55,25),
				ang=Angle(90,30,30),
			}
		},
		LeftForearm={
			["Standard"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(0,0,-.5),
				ang=Angle(0,-90,-50),
			}
		},
		RightForearm={
			["Standard"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(-.5,0,.5),
				ang=Angle(0,-90,50),
			}
		},
		LeftThigh={
			["Standard"]={
				siz=Vector(1.1,1,1.15),
				pos=Vector(0.5,0,-1.5),
				ang=Angle(90,-85,110),
			}
		},
		RightThigh={
			["Standard"]={
				siz=Vector(1.1,1,1.15),
				pos=Vector(.5,0,1),
				ang=Angle(90,-95,80),
			}
		},
		LeftCalf={
			["Standard"]={
				siz=Vector(1.15,1,1.15),
				pos=Vector(-1.5,-1,-.5),
				ang=Angle(-180,-83,-180),
			}
		},
		RightCalf={
			["Standard"]={
				siz=Vector(1.15,1,1.15),
				pos=Vector(-1.5,-1,.5),
				ang=Angle(-180,-83,-180),
			}
		}
	}
	local CSSTTable = {
		Face={
			["GasMask"]={
				siz=Vector(1.2,1,1),
				pos=Vector(0,1.7,0),
				ang=Angle(100,180,90),
			},
			["BallisticMask"]={
				siz=Vector(1,1,1),
				pos=Vector(4.5,-68,0),
				ang=Angle(92,180,90),
			}
		},
		Head={
			["Light"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(1.5,-2,0),
				ang=Angle(-90,0,-90),
			},
			["Medium"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(1,-2,0),
				ang=Angle(-90,0,-90),
			},
			["Heavy"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(1,-3,0),
				ang=Angle(-90,0,-90),
			}
		},
		Torso={
			["Light"]={
				siz=Vector(1.15,1.1,1),
				pos=Vector(-3,-4.5,0),
				ang=Angle(-90,0,90),
			},
			["Medium-Light"]={
				siz=Vector(1.25,1.2,1.2),
				pos=Vector(-3,-6.5,0),
				ang=Angle(-90,0,90),
			},
			["Medium"]={
				siz=Vector(1.2,1.2,1.05),
				pos=Vector(-3,-6.5,0),
				ang=Angle(-90,0,90),
			},
			["Medium-Heavy"]={
				siz=Vector(1.2,1.2,1),
				pos=Vector(-4.5,-10.5,0),
				ang=Angle(-85,0,90),
			},
			["Heavy"]={
				siz=Vector(1,1,1),
				pos=Vector(-10,-50,0),
				ang=Angle(-85,0,90),
			}
		},
		Pelvis={
			["Standard"]={
				siz=Vector(1.5,1.4,1.8),
				pos=Vector(71,0,0),
				ang=Angle(90,-90,0),
			}
		},
		LeftShoulder={
			["Light"]={
				siz=Vector(1.2,1.2,1.2),
				pos=Vector(0,0,-.5),
				ang=Angle(-90,-90,-90),
			},
			["Heavy"]={
				siz=Vector(1,1,1),
				pos=Vector(-6,60,-31),
				ang=Angle(90,-20,110),
			}
		},
		RightShoulder={
			["Light"]={
				siz=Vector(1.2,1.2,1.2),
				pos=Vector(0,0,.5),
				ang=Angle(-90,-90,-90),
			},
			["Heavy"]={
				siz=Vector(1,1,1),
				pos=Vector(-32,55,25),
				ang=Angle(90,30,30),
			}
		},
		LeftForearm={
			["Standard"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(0,0,-.5),
				ang=Angle(0,-90,-50),
			}
		},
		RightForearm={
			["Standard"]={
				siz=Vector(1.2,1,1.2),
				pos=Vector(-.5,0,.5),
				ang=Angle(0,-90,50),
			}
		},
		LeftThigh={
			["Standard"]={
				siz=Vector(1.1,1,1.15),
				pos=Vector(0.5,0,-1.5),
				ang=Angle(90,-85,110),
			}
		},
		RightThigh={
			["Standard"]={
				siz=Vector(1.1,1,1.15),
				pos=Vector(.5,0,1),
				ang=Angle(90,-95,80),
			}
		},
		LeftCalf={
			["Standard"]={
				siz=Vector(1.15,1,1.15),
				pos=Vector(-1.5,-1,-.5),
				ang=Angle(-180,-83,-180),
			}
		},
		RightCalf={
			["Standard"]={
				siz=Vector(1.15,1,1.15),
				pos=Vector(-1.5,-1,.5),
				ang=Angle(-180,-83,-180),
			}
		}
	}
	JMod.LuaConfig.ArmorOffsets["models/player/phoenix.mdl"]=CSSTTable
	JMod.LuaConfig.ArmorOffsets["models/player/guerilla.mdl"]=CSSTTable
	JMod.LuaConfig.ArmorOffsets["models/player/leet.mdl"]=CSSTTable
	JMod.LuaConfig.ArmorOffsets["models/player/arctic.mdl"]=CSSTTable
	JMod.LuaConfig.ArmorOffsets["models/player/swat.mdl"]=CSSCTTable
	JMod.LuaConfig.ArmorOffsets["models/player/urban.mdl"]=CSSCTTable
	JMod.LuaConfig.ArmorOffsets["models/player/gasmask.mdl"]=CSSCTTable
	JMod.LuaConfig.ArmorOffsets["models/player/riot.mdl"]=CSSCTTable
end

function JMod.InitGlobalConfig(forceNew)
	local NewConfig={
		Author="Jackarunda",
		Version=37,
		Note="radio packages must have all lower-case names, see http://wiki.garrysmod.com/page/Enums/IN for key numbers",
		Hints=true,
		AltFunctionKey=IN_WALK,
		SentryPerformanceMult=1,
		MedBayHealMult=1,
		MedKitHealMult=1,
		ToolKitUpgradeMult=1,
		MineDelay=1,
		MinePower=1,
		DoorBreachResetTimeMult=1,
		SupplyEffectMult=1,
		FumigatorGasAmount=1,
		PoisonGasDamage=1,
		PoisonGasLingerTime=1,
		DetpackPowerMult=1,
		AmmoCarryLimitMult=1,
		MicroBlackHoleGeneratorChargeSpeed=1,
		MicroBlackHoleEvaporateSpeed=1,
		MicroBlackHoleGravityStrength=1,
		BuildKitDeWeldSpeed=1,
		HandGrabStrength=1,
		BombDisarmSpeed=1,
		ExplosionPropDestroyPower=1,
		ArmorProtectionMult=1,
		ArmorDegredationMult=1,
		ArmorChargeDepletionMult=1,
		ArmorWeightMult=1,
		WeaponDamageMult=1,
		WeaponSwayMult=1,
		NukeRangeMult=1,
		NukePowerMult=1,
		NuclearRadiationMult=1,
		NuclearRadiationSickness=true,
		VirusSpreadMult=1,
		FragExplosions=true,
		ResourceEconomy={
			OreFrequency=1,
			OreRichness=1,
			OilFrequency=1,
			OilRichness=1,
			GeothermalPowerMult=1,
			ProductionSpeed=1
		},
		QoL={
			RealisticLocationalDamage=false,
			ExtinguishUnderwater=false,
			RealisticFallDamage=false,
			Drowning=false,
			GiveHandsOnSpawn=false,
			BleedDmgMult=0,
			BleedSpeedMult=0
		},
		FoodSpecs={
			DigestSpeed=1,
			ConversionEfficiency=1,
			EatSpeed=1,
			BoostMult=1
		},
		WeaponsThatUseMunitions={
			"weapon_rpg",
			"weapon_frag"
		},
		WeaponAmmoBlacklist={
			"weapon_crossbow"
		},
		RadioSpecs={
			DeliveryTimeMult=1,
			ParachuteDragMult=1,
			AvailablePackages={
				["parts"]={
					{"ent_jack_gmod_ezparts",5}
				},
				["advanced parts"]={
					{"ent_jack_gmod_ezadvparts",2}
				},
				["advanced textiles"]={
					{"ent_jack_gmod_ezadvtextiles",2}
				},
				["batteries"]={
					{"ent_jack_gmod_ezbattery",4}
				},
				["ammo"]={
					{"ent_jack_gmod_ezammo",5}
				},
				["coolant"]={
					{"ent_jack_gmod_ezcoolant",6}
				},
				["munitions"]={
					{"ent_jack_gmod_ezmunitions",3}
				},
				["explosives"]={
					{"ent_jack_gmod_ezexplosives",3}
				},
				["chemicals"]={
					{"ent_jack_gmod_ezchemicals",3}
				},
				["fuel"]={
					{"ent_jack_gmod_ezfuel",4}
				},
				["propellant"]={
					{"ent_jack_gmod_ezpropellant",4}
				},
				["gas"]={
					{"ent_jack_gmod_ezgas",3}
				},
				["build kits"]={
					{"ent_jack_gmod_ezbuildkit",2}
				},
				["rations"]={
					{"ent_jack_gmod_eznutrients",5}
				},
				["medical supplies"]={
					{"ent_jack_gmod_ezmedsupplies",2}
				},
				["resource crate"]={
					"ent_jack_gmod_ezcrate"
				},
				["storage crate"]={
					"ent_jack_gmod_ezcrate_uni"
				},
				["frag grenades"]={
					{"ent_jack_gmod_ezfragnade",10}
				},
				["gas grenades"]={
					{"ent_jack_gmod_ezgasnade",6}
				},
				["tear gas grenades"]={
					{"ent_jack_gmod_ezcsnade",6}
				},
				["impact grenades"]={
					{"ent_jack_gmod_ezimpactnade",10}
				},
				["incendiary grenades"]={
					{"ent_jack_gmod_ezfirenade",6}
				},
				["satchel charges"]={
					{"ent_jack_gmod_ezsatchelcharge",4}
				},
				["sticky bomb"]={
					{"ent_jack_gmod_ezstickynade",6}
				},
				["mini grenades"]={
					{"ent_jack_gmod_eznade_impact",5},
					{"ent_jack_gmod_eznade_proximity",5},
					{"ent_jack_gmod_eznade_remote",5},
					{"ent_jack_gmod_eznade_timed",5}
				},
				["timebombs"]={
					{"ent_jack_gmod_eztimebomb",3}
				},
				["hl2 ammo"]={
					"item_ammo_357","item_ammo_357_large","item_ammo_ar2","item_ammo_ar2_large",
					"item_ammo_ar2_altfire","item_ammo_ar2_altfire","item_ammo_ar2_altfire",
					"item_ammo_crossbow","item_ammo_pistol","item_ammo_pistol_large",
					"item_rpg_round","item_rpg_round","item_rpg_round",
					"item_box_buckshot","item_ammo_smg1","item_ammo_smg1_large",
					"item_ammo_smg1_grenade","item_ammo_smg1_grenade","item_ammo_smg1_grenade",
					"weapon_frag","weapon_frag","weapon_frag"
				},
				["sentry"]={
					"ent_jack_gmod_ezsentry"
				},
				["supply radio"]={
					"ent_jack_gmod_ezaidradio"
				},
				["medkits"]={
					{"ent_jack_gmod_ezmedkit",3}
				},
				["landmines"]={
					{"ent_jack_gmod_ezlandmine",10}
				},
				["mini bounding mines"]={
					{"ent_jack_gmod_ezboundingmine",8}
				},
				["fumigators"]={
					{"ent_jack_gmod_ezfumigator",2}
				},
				["fougasse mines"]={
					{"ent_jack_gmod_ezfougasse",4}
				},
				["detpacks"]={
					{"ent_jack_gmod_ezdetpack",8}
				},
				["slams"]={
					{"ent_jack_gmod_ezslam",5}
				},
				["antimatter"]={
					"ent_jack_gmod_ezantimatter"
				},
				["fissile material"]={
					"ent_jack_gmod_ezfissilematerial"
				},
				["dynamite"]={
					{"ent_jack_gmod_ezdynamite",12}
				},
				["flashbangs"]={
					{"ent_jack_gmod_ezflashbang",8}
				},
				["powder kegs"]={
					{"ent_jack_gmod_ezpowderkeg",4}
				},
				["smoke grenades"]={
					{"ent_jack_gmod_ezsmokenade",4},
					{"ent_jack_gmod_ezsignalnade",4}
				},
				["stick grenades"]={
					{"ent_jack_gmod_ezsticknade",4},
					"ent_jack_gmod_ezsticknadebundle"
				},
				["mini claymores"]={
					{"ent_jack_gmod_ezminimore",4}
				},
				["tnt"]={
					{"ent_jack_gmod_eztnt",3}
				},
				["thermal goggles"]={
					{"ent_jack_gmod_ezarmor_thermals",2}
				},
				["night vision goggles"]={
					{"ent_jack_gmod_ezarmor_nvgs",4}
				},
				["headsets"]={
					{"ent_jack_gmod_ezarmor_headset",8}
				},
				["armor"]={
					"ent_jack_gmod_ezarmor_balmask","ent_jack_gmod_ezarmor_gasmask",
					"ent_jack_gmod_ezarmor_hlshoulder","ent_jack_gmod_ezarmor_llshoulder",
					"ent_jack_gmod_ezarmor_llshoulder","ent_jack_gmod_ezarmor_lrshoulder",
					"ent_jack_gmod_ezarmor_ltorso","ent_jack_gmod_ezarmor_mhead",
					"ent_jack_gmod_ezarmor_mhtorso","ent_jack_gmod_ezarmor_mtorso",
					"ent_jack_gmod_ezarmor_mtorso","ent_jack_gmod_ezarmor_slcalf",
					"ent_jack_gmod_ezarmor_slforearm","ent_jack_gmod_ezarmor_slthigh",
					"ent_jack_gmod_ezarmor_spelvis","ent_jack_gmod_ezarmor_lrcalf",
					"ent_jack_gmod_ezarmor_srforearm","ent_jack_gmod_ezarmor_lrthigh",
					"ent_jack_gmod_ezarmor_nvgs","ent_jack_gmod_ezarmor_thermals",
					"ent_jack_gmod_ezarmor_headset"
				}
			},
			RestrictedPackages={"antimatter","fissile material"},
			RestrictedPackageShipTime=600,
			RestrictedPackagesAllowed=true
		},
		Blueprints={
["EZ Automated Field Hospital"]={
    "ent_jack_gmod_ezfieldhospital",
    {
        JMod.EZ_RESOURCE_TYPES.PARTS=400,
        JMod.EZ_RESOURCE_TYPES.POWER=100,
        JMod.EZ_RESOURCE_TYPES.ADVPARTS=80,
        JMod.EZ_RESOURCE_TYPES.MEDSUPPLIES=50
    },
    2,
    "Machines"
},
["EZ Big Bomb"]={
	"ent_jack_gmod_ezbigbomb",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=200,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=600
	},
	1.5,
	"Explosives"		
},	
["EZ Bomb"]={			
	"ent_jack_gmod_ezbomb",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=150,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=300
	},
	1,
	"Explosives"		
},	
["EZ Cluster Bomb"]={			
	"ent_jack_gmod_ezclusterbomb",		
	{
		JMod.EZ_RESOURCE_TYPES.PARTS=150,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=150
	},
	1,
	"Explosives"		
},
["EZ General Purpose Crate"]={			
	"ent_jack_gmod_ezcrate_uni",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=50	
	},
	1,
	"Other"
},	
["EZ HE Rocket"]={			
	"ent_jack_gmod_ezherocket",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=50,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=50,
		JMod.EZ_RESOURCE_TYPES.PROPELLANT=100
	},
	1,
	"Explosives"		
},
["EZ HEAT Rocket"]={			
	"ent_jack_gmod_ezheatrocket",		
	{
		JMod.EZ_RESOURCE_TYPES.PARTS=50,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=50,
		JMod.EZ_RESOURCE_TYPES.PROPELLANT=100	
	},
	1,
	"Explosives"		
},	
["EZ Incendiary Bomb"]={			
	"ent_jack_gmod_ezincendiarybomb",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=50,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=10,
		JMod.EZ_RESOURCE_TYPES.FUEL=200,
		JMod.EZ_RESOURCE_TYPES.CHEMICALS=20
	},
	1,
	"Explosives"		
},	
["EZ Mega Bomb"]={			
	"ent_jack_gmod_ezmoab",		
	{
		JMod.EZ_RESOURCE_TYPES.PARTS=400,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=1200
	},
	1,
	"Explosives"		
},
["EZ Micro Black Hole Generator"]={			
	"ent_jack_gmod_ezmbhg",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=300,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=120,
		JMod.EZ_RESOURCE_TYPES.POWER=600,
		JMod.EZ_RESOURCE_TYPES.ANTIMATTER=10
	},
	1.5,
	"Machines"		
},	
["EZ Micro Nuclear Bomb"]={			
	"ent_jack_gmod_eznuke",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=300,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=40,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=300,
		JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL=10
	},
	1,
	"Explosives"		
},	
["EZ Mini Naval Mine"]={			
	"ent_jack_gmod_eznavalmine",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=150,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=200	
	},
	1,
	"Explosives"		
},	
["EZ Nano Nuclear Bomb"]={			
	"ent_jack_gmod_eznuke_small",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=100,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=20,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=150,
		JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL=5
	},
	1,
	"Explosives"
},	
["EZ Resource Crate"]={			
	"ent_jack_gmod_ezcrate",		
	{
		JMod.EZ_RESOURCE_TYPES.PARTS=100	
	},
	1.5,
	"Other"		
},	
["EZ Sentry"]={			
	"ent_jack_gmod_ezsentry",		
	{
		JMod.EZ_RESOURCE_TYPES.PARTS=200,
		JMod.EZ_RESOURCE_TYPES.POWER=100,
		JMod.EZ_RESOURCE_TYPES.AMMO=300,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=20,
		JMod.EZ_RESOURCE_TYPES.COOLANT=100
	},
	1,
	"Machines"		
},	
["EZ Small Bomb"]={			
	"ent_jack_gmod_ezsmallbomb",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=150,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=150
	},
	1,
	"Explosives"		
},
["EZ Supply Radio"]={			
	"ent_jack_gmod_ezaidradio",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=100,
		JMod.EZ_RESOURCE_TYPES.POWER=100,	
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=20	
	},
	1,
	"Machines"		
},	
["EZ Thermobaric Bomb"]={			
	"ent_jack_gmod_ezthermobaricbomb",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=100,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=20,
		JMod.EZ_RESOURCE_TYPES.PROPELLANT=300,
		JMod.EZ_RESOURCE_TYPES.CHEMICALS=10
	},
	1,
	"Explosives"		
},	
["EZ Thermonuclear Bomb"]={			
	"ent_jack_gmod_eznuke_big",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=400,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=100,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=600,
		JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL=20
	},
	1.5,
	"Explosives"		
},	
["EZ Vehicle Mine"]={			
	"ent_jack_gmod_ezatmine",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=40,
		JMod.EZ_RESOURCE_TYPES.EXPLOSIVES=100
	},
	.75,
	"Explosives"		
},	
["EZ Workbench"]={			
	"ent_jack_gmod_ezworkbench",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=500,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=40,
		JMod.EZ_RESOURCE_TYPES.POWER=100,
		JMod.EZ_RESOURCE_TYPES.GAS=100
	},
	1.5,
	"Machines"		
},	
["HL2 Buggy"]={			
	"FUNC spawnHL2buggy",		
	{	
		JMod.EZ_RESOURCE_TYPES.PARTS=500,
		JMod.EZ_RESOURCE_TYPES.POWER=50,
		JMod.EZ_RESOURCE_TYPES.ADVPARTS=10,
		JMod.EZ_RESOURCE_TYPES.FUEL=300,
		JMod.EZ_RESOURCE_TYPES.AMMO-600
    },
    2,
	"Other"	
},					
		},
		Recipes={
			["EZ Ammo"]={"ent_jack_gmod_ezammo",{parts=30,propellant=40,explosives=5},"Resources"},
			["EZ Ballistic Mask"]={"ent_jack_gmod_ezarmor_balmask",{parts=10,advtextiles=5},"Apparel"},
			["EZ Build Kit"]={"ent_jack_gmod_ezbuildkit",{parts=100,advparts=20,gas=50,power=50},"Tools"},
			["EZ Detpack"]={"ent_jack_gmod_ezdetpack",{parts=5,explosives=20},"Weapons"},
			["EZ Dynamite"]={"ent_jack_gmod_ezdynamite",{parts=5,explosives=5},"Weapons"},
			["EZ Explosives"]={"ent_jack_gmod_ezexplosives",{parts=5,chemicals=150},"Resources"},
			["EZ Flashbang"]={"ent_jack_gmod_ezflashbang",{parts=10,explosives=2,chemicals=2},"Weapons"},
			["EZ Fougasse Mine"]={"ent_jack_gmod_ezfougasse",{parts=20,fuel=100,explosives=5},"Weapons"},
			["EZ Fragmentation Grenade"]={"ent_jack_gmod_ezfragnade",{parts=10,explosives=5},"Weapons"},
			["EZ Fumigator"]={"ent_jack_gmod_ezfumigator",{parts=30,gas=100,chemicals=50},"Weapons"},
			["EZ Gas Grenade"]={"ent_jack_gmod_ezgasnade",{parts=5,gas=20,chemicals=15},"Weapons"},
			["EZ Tear Gas Grenade"]={"ent_jack_gmod_ezcsnade",{parts=5,gas=20,chemicals=15},"Weapons"},
			["EZ Gas Mask"]={"ent_jack_gmod_ezarmor_gasmask",{parts=10,chemicals=10,advtextiles=2},"Apparel"},
			["EZ Gebalte Ladung"]={"ent_jack_gmod_ezsticknadebundle",{parts=50,explosives=50},"Weapons"},
			["EZ Headset"]={"ent_jack_gmod_ezarmor_headset",{parts=20,power=10},"Apparel"},
			["EZ Heavy Left Shoulder Armor"]={"ent_jack_gmod_ezarmor_hlshoulder",{parts=15,advtextiles=10},"Apparel"},
			["EZ Heavy Right Shoulder Armor"]={"ent_jack_gmod_ezarmor_hrshoulder",{parts=15,advtextiles=10},"Apparel"},
			["EZ Heavy Torso Armor"]={"ent_jack_gmod_ezarmor_htorso",{parts=20,advtextiles=30},"Apparel"},
			["EZ Impact Grenade"]={"ent_jack_gmod_ezimpactnade",{parts=5,explosives=10},"Weapons"},
			["EZ Incendiary Grenade"]={"ent_jack_gmod_ezfirenade",{parts=5,explosives=5,fuel=30},"Weapons"},
			["EZ Landmine"]={"ent_jack_gmod_ezlandmine",{parts=10,explosives=5},"Weapons"},
			["EZ Light Helmet"]={"ent_jack_gmod_ezarmor_lhead",{parts=15,advtextiles=5},"Apparel"},
			["EZ Respirator"]={"ent_jack_gmod_ezarmor_respirator",{parts=10,chemicals=5},"Apparel"},
			["EZ Riot Helmet"]={"ent_jack_gmod_ezarmor_riot",{parts=10,advtextiles=5},"Apparel"},
			["EZ Heavy Riot Helmet"]={"ent_jack_gmod_ezarmor_rioth",{parts=20,advtextiles=10},"Apparel"},
			["EZ Ultra Heavy Helmet"]={"ent_jack_gmod_ezarmor_maska",{parts=40,advtextiles=20},"Apparel"},
			["EZ Light Left Shoulder Armor"]={"ent_jack_gmod_ezarmor_llshoulder",{parts=10,advtextiles=5},"Apparel"},
			["EZ Light Right Shoulder Armor"]={"ent_jack_gmod_ezarmor_lrshoulder",{parts=10,advtextiles=5},"Apparel"},
			["EZ Light Torso Armor"]={"ent_jack_gmod_ezarmor_ltorso",{parts=15,advtextiles=10},"Apparel"},
			["EZ Medical Supplies"]={"ent_jack_gmod_ezmedsupplies",{parts=20,chemicals=50,advparts=10,advtextiles=10},"Resources"},
			["EZ Medium Helmet"]={"ent_jack_gmod_ezarmor_mhead",{parts=20,advtextiles=10},"Apparel"},
			["EZ Medium Torso Armor"]={"ent_jack_gmod_ezarmor_mtorso",{parts=15,advtextiles=20},"Apparel"},
			["EZ Medium-Heavy Torso Armor"]={"ent_jack_gmod_ezarmor_mhtorso",{parts=15,advtextiles=25},"Apparel"},
			["EZ Medium-Light Torso Armor"]={"ent_jack_gmod_ezarmor_mltorso",{parts=15,advtextiles=15},"Apparel"},
			["EZ Medkit"]={"ent_jack_gmod_ezmedkit",{parts=20,medsupplies=50},"Tools"},
			["EZ Mini Bounding Mine"]={"ent_jack_gmod_ezboundingmine",{parts=20,explosives=5,propellant=5},"Weapons"},
			["EZ Mini Claymore"]={"ent_jack_gmod_ezminimore",{parts=20,explosives=5},"Weapons"},
			["EZ Mini Impact Grenade"]={"ent_jack_gmod_eznade_impact",{parts=5,explosives=3},"Weapons"},
			["EZ Mini Proximity Grenade"]={"ent_jack_gmod_eznade_proximity",{parts=5,explosives=3},"Weapons"},
			["EZ Mini Remote Grenade"]={"ent_jack_gmod_eznade_remote",{parts=5,explosives=3},"Weapons"},
			["EZ Mini Timed Grenade"]={"ent_jack_gmod_eznade_timed",{parts=5,explosives=3},"Weapons"},
			["EZ Munitions"]={"ent_jack_gmod_ezmunitions",{parts=100,propellant=100,explosives=100},"Resources"},
			["EZ Night Vision Goggles"]={"ent_jack_gmod_ezarmor_nvgs",{parts=30,advparts=10,power=20},"Apparel"},
			["EZ Powder Keg"]={"ent_jack_gmod_ezpowderkeg",{parts=10,propellant=400},"Weapons"},
			["EZ Propellant"]={"ent_jack_gmod_ezpropellant",{parts=2,chemicals=80},"Resources"},
			["EZ SLAM"]={"ent_jack_gmod_ezslam",{parts=20,explosives=15},"Weapons"},
			["EZ Satchel Charge"]={"ent_jack_gmod_ezsatchelcharge",{parts=10,explosives=80},"Weapons"},
			["EZ Signal Grenade"]={"ent_jack_gmod_ezsignalnade",{parts=10,explosives=1,chemicals=10},"Weapons"},
			["EZ Smoke Grenade"]={"ent_jack_gmod_ezsmokenade",{parts=10,explosives=1,chemicals=10},"Weapons"},
			["EZ Left Calf Armor"]={"ent_jack_gmod_ezarmor_slcalf",{parts=10,advtextiles=5},"Apparel"},
			["EZ Left Forearm Armor"]={"ent_jack_gmod_ezarmor_slforearm",{parts=10,advtextiles=5},"Apparel"},
			["EZ Light Left Thigh Armor"]={"ent_jack_gmod_ezarmor_llthigh",{parts=10,advtextiles=5},"Apparel"},
			["EZ Heavy Left Thigh Armor"]={"ent_jack_gmod_ezarmor_hlthigh",{parts=20,advtextiles=10},"Apparel"},
			["EZ Pelvis Armor"]={"ent_jack_gmod_ezarmor_spelvis",{parts=10,advtextiles=10},"Apparel"},
			["EZ Right Calf Armor"]={"ent_jack_gmod_ezarmor_srcalf",{parts=10,advtextiles=5},"Apparel"},
			["EZ Right Forearm Armor"]={"ent_jack_gmod_ezarmor_srforearm",{parts=10,advtextiles=5},"Apparel"},
			["EZ Light Right Thigh Armor"]={"ent_jack_gmod_ezarmor_lrthigh",{parts=10,advtextiles=5},"Apparel"},
			["EZ Heavy Right Thigh Armor"]={"ent_jack_gmod_ezarmor_hrthigh",{parts=20,advtextiles=10},"Apparel"},
			["EZ Stick Grenade"]={"ent_jack_gmod_ezsticknade",{parts=10,explosives=10},"Weapons"},
			["EZ Sticky Bomb"]={"ent_jack_gmod_ezstickynade",{parts=10,explosives=10,chemicals=10},"Weapons"},
			["EZ TNT"]={"ent_jack_gmod_eztnt",{parts=20,explosives=60},"Weapons"},
			["EZ Thermal Goggles"]={"ent_jack_gmod_ezarmor_thermals",{parts=30,advparts=20,power=20},"Apparel"},
			["EZ Time Bomb"]={"ent_jack_gmod_eztimebomb",{parts=30,explosives=150},"Weapons"}
		}
	}
	local FileContents=file.Read("JMod_Config.txt")
	if(FileContents)then
		local Existing=util.JSONToTable(FileContents)
		if((Existing)and(Existing.Version))then
			if(Existing.Version==NewConfig.Version)then
				JMod.Config=util.JSONToTable(FileContents)
			else
				file.Write("JMod_Config_OLD.txt",FileContents)
			end
		end
	end
	if((not(JMod.Config))or(forceNew))then
		JMod.Config=NewConfig
		file.Write("JMod_Config.txt",util.TableToJSON(JMod.Config,true))
	end
	print("JMOD: config file loaded")
	-- jmod lua config --
	if not(JMod.LuaConfig)then JMod.LuaConfig={BuildFuncs={},ArmorOffsets={}} end
	JMod.LuaConfig.BuildFuncs=JMod.LuaConfig.BuildFuncs or {}
	JMod.LuaConfig.ArmorOffsets=JMod.LuaConfig.ArmorOffsets or {}
	
	JMod.LuaConfig.BuildFuncs.spawnHL2buggy=function(playa, position, angles)
		local Ent=ents.Create("prop_vehicle_jeep_old")
		Ent:SetModel("models/buggy.mdl")
		Ent:SetKeyValue("vehiclescript","scripts/vehicles/jeep_test.txt")
		Ent:SetPos(position)
		Ent:SetAngles(angles)
		JMod.Owner(Ent,playa)
		Ent:Spawn()
		Ent:Activate()
	end
	SetArmorPlayerModelModifications()
	print("JMOD: lua config file loaded")
end

hook.Add("Initialize","JMOD_Initialize",function()
	if(SERVER)then JMod.InitGlobalConfig() end
end)

-- todo: fix riot shield mat