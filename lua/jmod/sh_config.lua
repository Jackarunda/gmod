local function JMod_SetArmorPlayerModelModifications()
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
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/phoenix.mdl"]=CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/guerilla.mdl"]=CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/leet.mdl"]=CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/arctic.mdl"]=CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/swat.mdl"]=CSSCTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/urban.mdl"]=CSSCTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/gasmask.mdl"]=CSSCTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/riot.mdl"]=CSSCTTable
end

function JMod_InitGlobalConfig(forceNew)
	local NewConfig={
		Author="Jackarunda",
		Version=24,
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
		FumigatorGasAmount=1,
		PoisonGasDamage=1,
		PoisonGasLingerTime=1,
		DetpackPowerMult=1,
		MicroBlackHoleGeneratorChargeSpeed=1,
		MicroBlackHoleEvaporateSpeed=1,
		MicroBlackHoleGravityStrength=1,
		BuildKitDeWeldSpeed=1,
		HandGrabStrength=1,
		BombDisarmSpeed=1,
		ExplosionPropDestroyPower=1,
		ArmorExponentMult=1,
		ArmorDegredationMult=1,
		ArmorWeightMult=1,
		NukeRangeMult=1,
		NukePowerMult=1,
		NuclearRadiationMult=1,
		NuclearRadiationSickness=true,
		FragExplosions=true,
		FoodSpecs={
			DigestSpeed=1,
			ConversionEfficiency=1,
			EatSpeed=1,
			BoostMult=1
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
					"ent_jack_gmod_ezarmor_hlshoulder","ent_jack_gmod_ezarmor_hrshoulder",
					"ent_jack_gmod_ezarmor_htorso","ent_jack_gmod_ezarmor_lhead",
					"ent_jack_gmod_ezarmor_llshoulder","ent_jack_gmod_ezarmor_lrshoulder",
					"ent_jack_gmod_ezarmor_ltorso","ent_jack_gmod_ezarmor_mhead",
					"ent_jack_gmod_ezarmor_mhtorso","ent_jack_gmod_ezarmor_mltorso",
					"ent_jack_gmod_ezarmor_mtorso","ent_jack_gmod_ezarmor_slcalf",
					"ent_jack_gmod_ezarmor_slforearm","ent_jack_gmod_ezarmor_slthigh",
					"ent_jack_gmod_ezarmor_spelvis","ent_jack_gmod_ezarmor_srcalf",
					"ent_jack_gmod_ezarmor_srforearm","ent_jack_gmod_ezarmor_srthigh",
					"ent_jack_gmod_ezarmor_nvgs","ent_jack_gmod_ezarmor_thermals",
					"ent_jack_gmod_ezarmor_headset"
				}
			},
			RestrictedPackages={"antimatter","fissile material"},
			RestrictedPackageShipTime=600,
			RestrictedPackagesAllowed=true
		},
		Blueprints={
			["EZ Automated Field Hospital"]={"ent_jack_gmod_ezfieldhospital",{parts=400,power=100,advparts=80,medsupplies=50},2,"Machines"},
			["EZ Big Bomb"]={"ent_jack_gmod_ezbigbomb",{parts=200,explosives=600},1.5,"Explosives"},
			["EZ Bomb"]={"ent_jack_gmod_ezbomb",{parts=150,explosives=300},1,"Explosives"},
			["EZ Cluster Bomb"]={"ent_jack_gmod_ezclusterbomb",{parts=150,explosives=150},1,"Explosives"},
			["EZ General Purpose Crate"]={"ent_jack_gmod_ezcrate_uni",{parts=50},1,"Other"},
			["EZ HE Rocket"]={"ent_jack_gmod_ezherocket",{parts=50,explosives=50,propellant=100},1,"Explosives"},
			["EZ HEAT Rocket"]={"ent_jack_gmod_ezheatrocket",{parts=50,explosives=50,propellant=100},1,"Explosives"},
			["EZ Incendiary Bomb"]={"ent_jack_gmod_ezincendiarybomb",{parts=50,explosives=10,fuel=200,chemicals=20},1,"Explosives"},
			["EZ Mega Bomb"]={"ent_jack_gmod_ezmoab",{parts=400,explosives=1200},1,"Explosives"},
			["EZ Micro Black Hole Generator"]={"ent_jack_gmod_ezmbhg",{parts=300,advparts=120,power=600,antimatter=10},1.5,"Machines"},
			["EZ Micro Nuclear Bomb"]={"ent_jack_gmod_eznuke",{parts=300,advparts=40,explosives=300,fissilematerial=10},1,"Explosives"},
			["EZ Mini Naval Mine"]={"ent_jack_gmod_eznavalmine",{parts=150,explosives=200},1,"Explosives"},
			["EZ Nano Nuclear Bomb"]={"ent_jack_gmod_eznuke_small",{parts=100,advparts=20,explosives=150,fissilematerial=5},1,"Explosives"},
			["EZ Resource Crate"]={"ent_jack_gmod_ezcrate",{parts=100},1.5,"Other"},
			["EZ Sentry"]={"ent_jack_gmod_ezsentry",{parts=200,power=100,ammo=300,advparts=20},1,"Machines"},
			["EZ Small Bomb"]={"ent_jack_gmod_ezsmallbomb",{parts=150,explosives=150},1,"Explosives"},
			["EZ Supply Radio"]={"ent_jack_gmod_ezaidradio",{parts=100, power=100,advparts=20},1,"Machines"},
			["EZ Thermobaric Bomb"]={"ent_jack_gmod_ezthermobaricbomb",{parts=100,explosives=20,propellant=300,chemicals=10},1,"Explosives"},
			["EZ Thermonuclear Bomb"]={"ent_jack_gmod_eznuke_big",{parts=400,advparts=100,explosives=600,fissilematerial=20},1.5,"Explosives"},
			["EZ Vehicle Mine"]={"ent_jack_gmod_ezatmine",{parts=40,explosives=100},.75,"Explosives"},
			["EZ Workbench"]={"ent_jack_gmod_ezworkbench",{parts=500,advparts=40,power=100,gas=100},1.5,"Machines"},
			["HL2 Buggy"]={"FUNC spawnHL2buggy",{parts=500,power=50,advparts=10,fuel=300,ammo=600},2,"Other"}
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
			["EZ Standard Left Calf Armor"]={"ent_jack_gmod_ezarmor_slcalf",{parts=10,advtextiles=5},"Apparel"},
			["EZ Standard Left Forearm Armor"]={"ent_jack_gmod_ezarmor_slforearm",{parts=10,advtextiles=5},"Apparel"},
			["EZ Standard Left Thigh Armor"]={"ent_jack_gmod_ezarmor_slthigh",{parts=10,advtextiles=5},"Apparel"},
			["EZ Standard Pelvis Armor"]={"ent_jack_gmod_ezarmor_spelvis",{parts=10,advtextiles=10},"Apparel"},
			["EZ Standard Right Calf Armor"]={"ent_jack_gmod_ezarmor_srcalf",{parts=10,advtextiles=5},"Apparel"},
			["EZ Standard Right Forearm Armor"]={"ent_jack_gmod_ezarmor_srforearm",{parts=10,advtextiles=5},"Apparel"},
			["EZ Standard Right Thigh Armor"]={"ent_jack_gmod_ezarmor_srthigh",{parts=10,advtextiles=5},"Apparel"},
			["EZ Stick Grenade"]={"ent_jack_gmod_ezsticknade",{parts=10,explosives=10},"Weapons"},
			["EZ Sticky Bomb"]={"ent_jack_gmod_ezstickynade",{parts=10,explosives=10,chemicals=10},"Weapons"},
			["EZ TNT"]={"ent_jack_gmod_eztnt",{parts=20,explosives=60},"Weapons"},
			["EZ Thermal Goggles"]={"ent_jack_gmod_ezarmor_thermals",{parts=30,advparts=20,power=20},"Apparel"},
			["EZ Time Bomb"]={"ent_jack_gmod_eztimebomb",{parts=30,explosives=150},"Weapons"}
		}
	}
	local FileContents=file.Read("jmod_config.txt")
	if(FileContents)then
		local Existing=util.JSONToTable(FileContents)
		if((Existing)and(Existing.Version))then
			if(Existing.Version==NewConfig.Version)then
				JMOD_CONFIG=util.JSONToTable(FileContents)
			else
				file.Write("jmod_config_OLD.txt",FileContents)
			end
		end
	end
	if((not(JMOD_CONFIG))or(forceNew))then
		JMOD_CONFIG=NewConfig
		file.Write("jmod_config.txt",util.TableToJSON(JMOD_CONFIG,true))
	end
	print("JMOD: config file loaded")
	-- jmod lua config --
	if not(JMOD_LUA_CONFIG)then JMOD_LUA_CONFIG={BuildFuncs={},ArmorOffsets={}} end
	JMOD_LUA_CONFIG.BuildFuncs=JMOD_LUA_CONFIG.BuildFuncs or {}
	JMOD_LUA_CONFIG.ArmorOffsets=JMOD_LUA_CONFIG.ArmorOffsets or {}
	
	JMOD_LUA_CONFIG.BuildFuncs.spawnHL2buggy=function(playa, position, angles)
		local Ent=ents.Create("prop_vehicle_jeep_old")
		Ent:SetModel("models/buggy.mdl")
		Ent:SetKeyValue("vehiclescript","scripts/vehicles/jeep_test.txt")
		Ent:SetPos(position)
		Ent:SetAngles(angles)
		JMod_Owner(Ent,playa)
		Ent:Spawn()
		Ent:Activate()
	end
	JMod_SetArmorPlayerModelModifications()
	print("JMOD: lua config file loaded")
end

hook.Add("Initialize","JMOD_Initialize",function()
	if(SERVER)then JMod_InitGlobalConfig() end
end)