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
					"ent_jack_gmod_ezFISSILEMATERIAL]"
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
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=400,
					[JMod.EZ_RESOURCE_TYPES.POWER]=100,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=80,
					[JMod.EZ_RESOURCE_TYPES.MEDSUPPLIES]=50
				},
				2,
				"Machines",
				"Heals players so you don't have to get more blood on you."
			},
			["EZ Big Bomb"]={
				"ent_jack_gmod_ezbigbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=200,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=600
				},
				1.5,
				"Explosives",
				"Bigger than the EZ bomb, but smaller than the Mega."
			},	
			["EZ Bomb"]={			
				"ent_jack_gmod_ezbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=300
				},
				1,
				"Explosives",
				"Ol' reliable, a good way to send the enemy running for the bunkers."	
			},	
			["EZ Cluster Bomb"]={			
				"ent_jack_gmod_ezclusterbomb",		
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=150
				},
				1,
				"Explosives",
				"For when you need to send hundreds of tiny bombs rather than a big one."
			},
			["EZ General Purpose Crate"]={			
				"ent_jack_gmod_ezcrate_uni",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50	
				},
				1,
				"Other",
				"It's a box, tap it with whatever you want to store. Only works with JMod items."
			},	
			["EZ HE Rocket"]={			
				"ent_jack_gmod_ezherocket",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=50,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=100
				},
				1,
				"Explosives",
				"Pointy end goes forward towards soon to be explosion. Stay away from rear unless you want 3rd degree burns."
			},
			["EZ HEAT Rocket"]={			
				"ent_jack_gmod_ezheatrocket",		
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=50,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=100	
				},
				1,
				"Explosives",
				"EZ HE Rocket, except it's a lot more effective against armored vehicles with less boom."
			},	
			["EZ Incendiary Bomb"]={			
				"ent_jack_gmod_ezincendiarybomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=200,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=20
				},
				1,
				"Explosives",
				"Fire bomb. Detonates in the air to ensure max spread of napalm."
			},	
			["EZ Mega Bomb"]={			
				"ent_jack_gmod_ezmoab",		
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=400,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=1200
				},
				1,
				"Explosives",
				"Anything on the surface of the enemy bunker is gonna be gone, and they'll need to cleanup the bunker."		
			},
			["EZ Micro Black Hole Generator"]={			
				"ent_jack_gmod_ezmbhg",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=300,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=120,
					[JMod.EZ_RESOURCE_TYPES.POWER]=600,
					[JMod.EZ_RESOURCE_TYPES.ANTIMATTER]=10
				},
				1.5,
				"Machines",
				"Takes a couple minutes to spin up, and then creates an impossibly weak black hole."
			},	
			["EZ Micro Nuclear Bomb"]={			
				"ent_jack_gmod_eznuke",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=300,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=40,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=300,
					[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]=10
				},
				1,
				"Explosives",
				"Half the map is gonna be gone along with the bunker."
			},	
			["EZ Mini Naval Mine"]={			
				"ent_jack_gmod_eznavalmine",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=200	
				},
				1,
				"Explosives",
				"Ships beware! This mine is ready to send em to davy jones' locker!"
			},	
			["EZ Nano Nuclear Bomb"]={			
				"ent_jack_gmod_eznuke_small",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=150,
					[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]=5
				},
				1,
				"Explosives",
				"Uranium is powerful, making this tiny bomb as strong as the Mega bomb, while also having radiation as a bonus."
			},	
			["EZ Resource Crate"]={			
				"ent_jack_gmod_ezcrate",		
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100	
				},
				1.5,
				"Other",
				"Store your resources here, so you don't have to stack em so much in the warehouse."
			},	
			["EZ Sentry"]={			
				"ent_jack_gmod_ezsentry",		
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=200,
					[JMod.EZ_RESOURCE_TYPES.POWER]=100,
					[JMod.EZ_RESOURCE_TYPES.AMMO]=300,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.COOLANT]=100
				},
				1,
				"Machines",
				"Shoots enemies so you don't have to! Just remember to refill the ammo and power."
			},	
			["EZ Small Bomb"]={			
				"ent_jack_gmod_ezsmallbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=150
				},
				1,
				"Explosives",
				"A small alternative to the EZ Bomb, it has airbrakes for low altitude bombing."
			},
			["EZ Supply Radio"]={			
				"ent_jack_gmod_ezaidradio",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.POWER]=100,	
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=20	
				},
				1,
				"Machines",
				"Order more supplies for free. Just place it outside and watch for the package."
			},	
			["EZ Thermobaric Bomb"]={			
				"ent_jack_gmod_ezthermobaricbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=20,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=300,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10
				},
				1,
				"Explosives",
				"Bunker buster, will cause more damage if you place it indoors."
			},	
			["EZ Thermonuclear Bomb"]={			
				"ent_jack_gmod_eznuke_big",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=400,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=600,
					[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]=20
				},
				1.5,
				"Explosives",
				"Now we are all sons of bitches."
			},	
			["EZ Vehicle Mine"]={			
				"ent_jack_gmod_ezatmine",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=40,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=100
				},
				.75,
				"Explosives",
				"A good way of stopping enemy tanks from passing through."
			},	
			["EZ Workbench"]={			
				"ent_jack_gmod_ezworkbench",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=500,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=40,
					[JMod.EZ_RESOURCE_TYPES.POWER]=100,
					[JMod.EZ_RESOURCE_TYPES.GAS]=100
				},
				1.5,
				"Machines",
				"Craft all your smaller items here."
			},	
			["HL2 Buggy"]={			
				"FUNC spawnHL2buggy",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=500,
					[JMod.EZ_RESOURCE_TYPES.POWER]=50,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=300,
					[JMod.EZ_RESOURCE_TYPES.AMMO]=600
				},
				2,
				"Other",
				"Gordon, remember to bring back the scout car."
			},					
		},
		Recipes={
		    ["EZ Ammo"]={			
				"ent_jack_gmod_ezammo",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=30,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=40,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Resources",
				"General purpose bullets. Don't ask how we got so many types of ammo in one box."
			},
		    ["EZ Ballistic Mask"]={
		        "ent_jack_gmod_ezarmor_balmask",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"Face protection for the narcissists."
		    },
		    ["EZ Build Kit"]={
		        "ent_jack_gmod_ezbuildkit",
		        {
			        [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.GAS]=50,
					[JMod.EZ_RESOURCE_TYPES.POWER]=50
				},
				"Tools",
				"Build, Upgrade, Salvage. All you need to build the big machines."
			},
			["EZ Detpack"]={
				"ent_jack_gmod_ezdetpack",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=20
				},
				"Weapons",
				"A Versatile breaching tool."
			},
			["EZ Dynamite"]={
				"ent_jack_gmod_ezdynamite",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Weapons",
				"Good for blastmining and blasting idiots."
			},
			["EZ Explosives"]={
				"ent_jack_gmod_ezexplosives",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=150
				},
				"Resources",
				"No bomb is complete without explosives!"
			},
			["EZ Flashbang"]={
				"ent_jack_gmod_ezflashbang",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=2,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=2
				},
				"Weapons",
				"Look away unless you want to be blinded."
			},
			["EZ Fougasse Mine"]={
				"ent_jack_gmod_ezfougasse",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Weapons",
				"Focus fire on the flammable targets."
			},
			["EZ Fragmentation Grenade"]={
				"ent_jack_gmod_ezfragnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Weapons",
				"Frag nade, for sending hundreds of fragments into your enemy."
			},
			["EZ Fumigator"]={
				"ent_jack_gmod_ezfumigator",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=30,
					[JMod.EZ_RESOURCE_TYPES.GAS]=100,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=50
				},
				"Weapons",
				"Go ahead, tell your hitler jokes. we'll wait."
			},
			["EZ Gas Grenade"]={
				"ent_jack_gmod_ezgasnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.GAS]=20,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=15
				},
				"Weapons",
				"Portable way of gassing j- enemies."
			},
			["EZ Tear Gas Grenade"]={
				"ent_jack_gmod_ezcsnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.GAS]=20,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=15
				},
				"Weapons",
				"Effective area denial for those without gasmasks. Might be a warcrime."
			},
			["EZ Gas Mask"]={
				"ent_jack_gmod_ezarmor_gasmask",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=2
				},
				"Apparel",
				"Protect yourself against the enemies' warcrimes."
			},
			["EZ Gebalte Ladung"]={
				"ent_jack_gmod_ezsticknadebundle",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=50
				},
				"Weapons",
				"A very heavy and very explosive stick grenade."
			},
			["EZ Headset"]={
				"ent_jack_gmod_ezarmor_headset",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.POWER]=10
				},
				"Apparel",
				"A great way of communicating with your team. No one else can hear you."
			},
			["EZ Heavy Left Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_hlshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
				},
				"Apparel",
				"You must care about your shoulders if you wear this."
			},
			["EZ Heavy Right Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_hrshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
				},
				"Apparel",
				"You must care about your shoulders if you wear this."
			},
			["EZ Heavy Torso Armor"]={
				"ent_jack_gmod_ezarmor_htorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=30
				},
				"Apparel",
				"Turtle shell. Heavy defense."
			},
			["EZ Impact Grenade"]={
				"ent_jack_gmod_ezimpactnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Weapons",
				"For the aggressive type. Explodes on impact."
			},
			["EZ Incendiary Grenade"]={
				"ent_jack_gmod_ezfirenade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=30
				},
				"Weapons",
				"Portable fire bomb, try cooking it before throwing to spread it more."
			},
			["EZ Landmine"]={
				"ent_jack_gmod_ezlandmine",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Weapons",
				"Anti-personnel land mine. Try your best to match the color with the ground."
			},
			["EZ Light Helmet"]={
				"ent_jack_gmod_ezarmor_lhead",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
				},
				"Apparel",
				"Not so bad on your neck, but has low defense."
			},
			["EZ Respirator"]={
				"ent_jack_gmod_ezarmor_respirator",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=5
				},
				"Apparel",
				"You can wear goggles while protecting your lungs, but you'll have to retreat."
			},
			["EZ Riot Helmet"]={
				"ent_jack_gmod_ezarmor_riot",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
				},
				"Apparel",
				"Protect your entire head with one piece. No goggles though."
			},
			["EZ Heavy Riot Helmet"]={
				"ent_jack_gmod_ezarmor_rioth",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
				},
				"Apparel",
				"Heavier version of the riot helmet."
			},
			["EZ Ultra Heavy Helmet"]={
				"ent_jack_gmod_ezarmor_maska",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=40,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=20
				},
				"Apparel",
				"Turtle head. Heaviest helmet, and restricts your vision alot."
			},
			["EZ Light Left Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_llshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
				},
				"Apparel",
				"Some protection for your shoulders."
			},
			["EZ Light Right Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_lrshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
				},
				"Apparel",
				"Some protection for your shoulders."
			},
			["EZ Light Torso Armor"]={
				"ent_jack_gmod_ezarmor_ltorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
				},
				"Apparel",
				"Might help against buckshot and 22LR, but not much else."
			},
			["EZ Medical Supplies"]={
				"ent_jack_gmod_ezmedsupplies",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=50,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
				},
				"Resources",
				"Necessities to heal anyone."
			},
			["EZ Medium Helmet"]={
				"ent_jack_gmod_ezarmor_mhead",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
				},
				"Apparel",
				"Better than the light helmet, but worse than the heavy. Neck might hurt if you wear it too long."
			},
			["EZ Medium Torso Armor"]={
				"ent_jack_gmod_ezarmor_mtorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=20
				},
				"Apparel",
				"Medium protection for your chest."
			},
			["EZ Medium-Heavy Torso Armor"]={
				"ent_jack_gmod_ezarmor_mhtorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=25
				},
				"Apparel",
				"Slightly less heavy, slightly less protection than heavy."
			},
			["EZ Medium-Light Torso Armor"]={
				"ent_jack_gmod_ezarmor_mltorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=15
				},
				"Apparel",
				"it'll help a little more, and is slightly heavier."
			},
			["EZ Medkit"]={
				"ent_jack_gmod_ezmedkit",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.MEDSUPPLIES]=50
				},
				"Tools",
				"Go help em doc. Watch your head, you're gonna be a target."
			},
			["EZ Mini Bounding Mine"]={
				"ent_jack_gmod_ezboundingmine",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=5
				},
				"Weapons",
				"Bury this in the soil around your base, and you got a very hidden defense option."
			},
			["EZ Mini Claymore"]={
				"ent_jack_gmod_ezminimore",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Weapons",
				"Simple way to trap corners and the like."
			},
			["EZ Mini Impact Grenade"]={
				"ent_jack_gmod_eznade_impact",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=3
				},
				"Weapons",
				"You could throw it, but it's much better for making sure that bumping a bomb is a death sentence."
			},
			["EZ Mini Proximity Grenade"]={
				"ent_jack_gmod_eznade_proximity",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=3
				},
				"Weapons",
				"Useful for turning big bombs into traps. Very weak on its own however."
			},
			["EZ Mini Remote Grenade"]={
				"ent_jack_gmod_eznade_remote",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=3
				},
				"Weapons",
				"Set it on a bomb, and trigger it from afar. Good if you want to ensure you're out of blast range."
			},
		   	["EZ Mini Timed Grenade"]={
				"ent_jack_gmod_eznade_remote",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=3
				},
				"Weapons",
				"Arm it on a bomb, and run like hell. those ten seconds pass very quick."
			},
			["EZ Munitions"]={
				"ent_jack_gmod_ezmunitions",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=100
				},
				"Resources",
				"Ammo for your explosive toys."
			},
			["EZ Night Vision Goggles"]={
				"ent_jack_gmod_ezarmor_nvgs",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=30,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.POWER]=20
				},
				"Apparel",
				"See at night, be blinded by bright light."
			},
			["EZ Powder Keg"]={
				"ent_jack_gmod_ezpowderkeg",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=400
				},
				"Weapons",
				"Don't light a match. You're gonna blow up if it lands on this keg."
			},
			["EZ Propellant"]={
				"ent_jack_gmod_ezpropellant",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=2,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=80
				},
				"Resources",
				"Propellant for guns and other things."
			},
			["EZ SLAM"]={	
				"ent_jack_gmod_ezslam",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=15
				},
				"Weapons",
				"If anything other than your team touches that beam, it better be well armored."
			},
			["EZ Satchel Charge"]={
				"ent_jack_gmod_ezsatchelcharge",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=80
				},
				"Weapons",
				"FIRE IN THE HOLE! Be sure you're at a safe distance before pushing that detonator!"
			},
			["EZ Signal Grenade"]={
				"ent_jack_gmod_ezsignalnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=1,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10
				},
				"Weapons",
				"Send smoke signals to your team, and probably be ignored or brutally murdered by the enemy."
			},
			["EZ Smoke Grenade"]={
				"ent_jack_gmod_ezsmokenade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=1,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10
				},
				"Weapons",
				"Smokescreen so nobody knows who they're shooting."
			},
			["EZ Left Calf Armor"]={
		        "ent_jack_gmod_ezarmor_slcalf",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"For your legs."
		    },
			["EZ Left Forearm Armor"]={
		        "ent_jack_gmod_ezarmor_slforearm",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"For your arm."
		    },
			["EZ Light Left Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_llthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"Keep your thigh."
		    },
			["EZ Heavy Left Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_hlthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
		        },
		        "Apparel",
				"i'm not making that joke."
		    },
			["EZ Pelvis Armor"]={
		        "ent_jack_gmod_ezarmor_spelvis",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
		        },
		        "Apparel",
				"Keep your kiwis safe!"
		    },
			["EZ Right Calf Armor"]={
		        "ent_jack_gmod_ezarmor_srcalf",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"For your legs."
		    },
			["EZ Right Forearm Armor"]={
		        "ent_jack_gmod_ezarmor_srforearm",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"For your arm."
		    },
			["EZ Light Right Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_lrthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=5
		        },
		        "Apparel",
				"Keep your thigh."
		    },
			["EZ Heavy Right Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_hrthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
                    [JMod.EZ_RESOURCE_TYPES.ADVTEXTILES]=10
		        },
		        "Apparel",
				"I'm not making that joke."
		    },
			["EZ Stick Grenade"]={
				"ent_jack_gmod_ezsticknade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Weapons",
				"Use your good throwing arm for this. Goes very far. Can have a frag sleeve on it."
			},
			["EZ Sticky Bomb"]={
				"ent_jack_gmod_ezstickynade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10
				},
				"Weapons",
				"Don't get yourself stuck on it! Very good for sticking to vehicles and stationary objects."
			},
			["EZ TNT"]={
				"ent_jack_gmod_eztnt",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=60
				},
				"Weapons",
				"Simple breaching device. Reacts to powder from the powder keg."
			},
			["EZ Thermal Goggles"]={
				"ent_jack_gmod_ezarmor_thermals",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=30,
					[JMod.EZ_RESOURCE_TYPES.ADVPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.POWER]=20
				},
				"Apparel",
				"Good for seeing things you couldn't see before."
			},
			["EZ Time Bomb"]={
				"ent_jack_gmod_eztimebomb",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=30,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=150
				},
				"Weapons",
				"The longer you set the time, the harder it is to defuse. Big risk to take however."
			}
			
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