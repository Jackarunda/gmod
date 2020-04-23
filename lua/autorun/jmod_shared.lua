AddCSLuaFile()
game.AddParticles("particles/muzzleflashes_test.pcf")
game.AddParticles("particles/muzzleflashes_test_b.pcf")
game.AddParticles("particles/pcfs_jack_explosions_large.pcf")
game.AddParticles("particles/pcfs_jack_explosions_medium.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small.pcf")
game.AddParticles("particles/pcfs_jack_nuclear_explosions.pcf")
game.AddParticles("particles/pcfs_jack_moab.pcf")
game.AddParticles("particles/gb5_large_explosion.pcf")
game.AddParticles("particles/gb5_500lb.pcf")
game.AddParticles("particles/gb5_100lb.pcf")
game.AddParticles("particles/gb5_50lb.pcf")
game.AddDecal("BigScorch",{"decals/big_scorch1","decals/big_scorch2","decals/big_scorch3"})
game.AddDecal("GiantScorch",{"decals/giant_scorch1","decals/giant_scorch2","decals/giant_scorch3"})
PrecacheParticleSystem("pcf_jack_nuke_ground")
PrecacheParticleSystem("pcf_jack_nuke_air")
PrecacheParticleSystem("pcf_jack_moab")
PrecacheParticleSystem("pcf_jack_moab_air")
PrecacheParticleSystem("cloudmaker_air")
PrecacheParticleSystem("cloudmaker_ground")
PrecacheParticleSystem("500lb_air")
PrecacheParticleSystem("500lb_ground")
PrecacheParticleSystem("100lb_air")
PrecacheParticleSystem("100lb_ground")
PrecacheParticleSystem("50lb_air")
--PrecacheParticleSystem("50lb_ground")
if(SERVER)then
	resource.AddWorkshop("1919689921")
	resource.AddWorkshop("1919703147")
	resource.AddWorkshop("1919692947")
	resource.AddWorkshop("1919694756")
end
---
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
	print("JMOD: lua config file loaded")
end
JMod_ArmorTable={
	Face={
		["GasMask"]={
			mdl="models/splinks/kf2/cosmetics/gas_mask.mdl", -- kf2
			siz=Vector(1,1,1),
			pos=Vector(0,.1,0),
			ang=Angle(100,180,90),
			wgt=5,
			dur=50,
			mskmat=Material("mats_jack_gmod_sprites/vignette.png"),
			spcdef={[DMG_NERVEGAS]=100,[DMG_RADIATION]=50},
			sndlop="snds_jack_gmod/mask_breathe.wav",
			ent="ent_jack_gmod_ezarmor_gasmask"
		},
		["BallisticMask"]={
			mdl="models/arachnit/csgoheavyphoenix/items/mask.mdl", -- csgo misc
			siz=Vector(1,1,1),
			pos=Vector(14.5,-68,0),
			ang=Angle(100,180,90),
			wgt=5,
			def=100,
			dur=150,
			mskmat=Material("mats_jack_gmod_sprites/hard_vignette.png"),
			ent="ent_jack_gmod_ezarmor_balmask",
			gayPhysics=true
		},
		["NightVisionGoggles"]={
			mdl="models/nvg.mdl", -- scp something
			siz=Vector(1.05,1.05,1.05),
			pos=Vector(6.5,2.75,0),
			ang=Angle(-100,0,90),
			wgt=5,
			dur=50,
			mskmat=Material("mats_jack_gmod_sprites/vignette.png"),
			eqsnd="snds_jack_gmod/tinycapcharge.wav",
			ent="ent_jack_gmod_ezarmor_nvgs",
			eff={"nightVision"}
		},
		["ThermalGoggles"]={
			mdl="models/nvg.mdl", -- scp something
			siz=Vector(1.05,1.05,1.05),
			pos=Vector(6.5,2.75,0),
			ang=Angle(-100,0,90),
			wgt=5,
			dur=50,
			mskmat=Material("mats_jack_gmod_sprites/vignette.png"),
			eqsnd="snds_jack_gmod/tinycapcharge.wav",
			ent="ent_jack_gmod_ezarmor_thermals",
			eff={"thermalVision"}
		}
	},
	Ears={
		["Headset"]={
			mdl="models/lt_c/sci_fi/headset_2.mdl", -- sci fi lt
			siz=Vector(1.2,1.05,1.1),
			pos=Vector(.5,3,.1),
			ang=Angle(130,0,90),
			wgt=5,
			dur=50,
			ent="ent_jack_gmod_ezarmor_headset",
			eff={"teamComms"}
		}
	},
	Head={
		["Light"]={
			mdl="models/player/helmet_achhc_black/achhc_black.mdl", -- tarkov
			siz=Vector(1.07,1,1.1),
			pos=Vector(1,-2,0),
			ang=Angle(-90,0,-90),
			wgt=10,
			def=40,
			dur=100,
			ent="ent_jack_gmod_ezarmor_lhead"
		},
		["Medium"]={
			mdl="models/player/helmet_ulach_black/ulach.mdl", -- tarkov
			siz=Vector(1.05,1,1.05),
			pos=Vector(1,-2,0),
			ang=Angle(-90,0,-90),
			wgt=15,
			def=70,
			dur=150,
			ent="ent_jack_gmod_ezarmor_mhead"
		},
		["Heavy"]={
			mdl="models/player/helmet_psh97_jeta/jeta.mdl", -- tarkov
			siz=Vector(1.1,1,1.1),
			pos=Vector(1,-3,0),
			ang=Angle(-90,0,-90),
			wgt=20,
			def=100,
			dur=200,
			ent="ent_jack_gmod_ezarmor_hhead"
		}
	},
	Torso={
		["Light"]={
			mdl="models/player/armor_trooper/trooper.mdl", -- tarkov
			siz=Vector(1,1.05,.9),
			pos=Vector(-2.5,-4.5,0),
			ang=Angle(-90,0,90),
			wgt=5,
			def=20,
			dur=300,
			ent="ent_jack_gmod_ezarmor_ltorso",
			gayPhysics=true
		},
		["Medium-Light"]={
			mdl="models/player/armor_paca/paca.mdl", -- tarkov
			siz=Vector(1.05,1.05,.95),
			pos=Vector(-3,-4.5,0),
			ang=Angle(-90,0,90),
			wgt=10,
			def=35,
			dur=400,
			ent="ent_jack_gmod_ezarmor_mltorso",
			gayPhysics=true
		},
		["Medium"]={
			mdl="models/player/armor_gjel/gjel.mdl", -- tarkov
			siz=Vector(1.05,1.05,1),
			pos=Vector(-3,-6.5,0),
			ang=Angle(-90,0,90),
			wgt=20,
			def=50,
			dur=500,
			ent="ent_jack_gmod_ezarmor_mtorso",
			gayPhysics=true
		},
		["Medium-Heavy"]={
			mdl="models/player/armor_6b13_killa/6b13_killa.mdl", -- tarkov
			siz=Vector(1.05,1.05,1),
			pos=Vector(-4.5,-12,0),
			ang=Angle(-85,0,90),
			wgt=40,
			def=65,
			dur=550,
			ent="ent_jack_gmod_ezarmor_mhtorso",
			gayPhysics=true
		},
		["Heavy"]={
			mdl="models/arachnit/csgo/ctm_heavy/items/ctm_heavy_vest.mdl", -- csgo hydra
			siz=Vector(.9,.9,1),
			pos=Vector(-10.5,-53.5,0),
			ang=Angle(-85,0,90),
			wgt=80,
			def=80,
			dur=600,
			ent="ent_jack_gmod_ezarmor_htorso",
			gayPhysics=true
		}
	},
	Pelvis={
		["Standard"]={
			mdl="models/arachnit/csgoheavyphoenix/items/pelviscover.mdl", -- csgo misc
			siz=Vector(1.5,1.4,1.8),
			pos=Vector(71,0,-2),
			ang=Angle(90,-90,0),
			wgt=10,
			def=20,
			dur=300,
			ent="ent_jack_gmod_ezarmor_spelvis",
			gayPhysics=true
		}
	},
	LeftShoulder={
		["Light"]={
			mdl="models/snowzgmod/payday2/armour/armourlbicep.mdl", -- aegis
			siz=Vector(1,1,1),
			pos=Vector(0,0,-.5),
			ang=Angle(-90,-90,-90),
			wgt=5,
			def=30,
			dur=150,
			ent="ent_jack_gmod_ezarmor_llshoulder"
		},
		["Heavy"]={
			mdl="models/arachnit/csgo/ctm_heavy/items/ctm_heavy_left_armor_pad.mdl", -- csgo hydra
			siz=Vector(1,1,1),
			pos=Vector(-6,60,-31),
			ang=Angle(90,-20,110),
			wgt=15,
			def=60,
			dur=250,
			ent="ent_jack_gmod_ezarmor_hlshoulder",
			gayPhysics=true
		}
	},
	RightShoulder={
		["Light"]={
			mdl="models/snowzgmod/payday2/armour/armourrbicep.mdl", -- aegis
			siz=Vector(1,1,1),
			pos=Vector(0,0,.5),
			ang=Angle(-90,-90,-90),
			wgt=5,
			def=30,
			dur=150,
			ent="ent_jack_gmod_ezarmor_lrshoulder"
		},
		["Heavy"]={
			mdl="models/arachnit/csgo/ctm_heavy/items/ctm_heavy_right_armor_pad.mdl", -- csgo hydra
			siz=Vector(1,1,1),
			pos=Vector(-32,55,25),
			ang=Angle(90,30,30),
			wgt=15,
			def=60,
			dur=250,
			ent="ent_jack_gmod_ezarmor_hrshoulder",
			gayPhysics=true
		}
	},
	LeftForearm={
		["Standard"]={
			mdl="models/snowzgmod/payday2/armour/armourlforearm.mdl", -- aegis
			siz=Vector(1.1,1,1),
			pos=Vector(0,0,-.5),
			ang=Angle(0,-90,-50),
			wgt=10,
			def=40,
			dur=150,
			ent="ent_jack_gmod_ezarmor_slforearm",
			gayPhysics=true
		}
	},
	RightForearm={
		["Standard"]={
			mdl="models/snowzgmod/payday2/armour/armourrforearm.mdl", -- aegis
			siz=Vector(1.1,1,1),
			pos=Vector(-.5,0,.5),
			ang=Angle(0,-90,50),
			wgt=10,
			def=40,
			dur=150,
			ent="ent_jack_gmod_ezarmor_srforearm",
			gayPhysics=true
		}
	},
	LeftThigh={
		["Standard"]={
			mdl="models/snowzgmod/payday2/armour/armourlthigh.mdl", -- aegis
			siz=Vector(.9,1,1.05),
			pos=Vector(-.5,0,-1.5),
			ang=Angle(90,-85,110),
			wgt=15,
			def=60,
			dur=250,
			ent="ent_jack_gmod_ezarmor_slthigh",
			gayPhysics=true
		}
	},
	RightThigh={
		["Standard"]={
			mdl="models/snowzgmod/payday2/armour/armourrthigh.mdl", -- aegis
			siz=Vector(.9,1,1.05),
			pos=Vector(.5,0,1),
			ang=Angle(90,-95,80),
			wgt=15,
			def=60,
			dur=250,
			ent="ent_jack_gmod_ezarmor_srthigh",
			gayPhysics=true
		}
	},
	LeftCalf={
		["Standard"]={
			mdl="models/snowzgmod/payday2/armour/armourlcalf.mdl", -- aegis
			siz=Vector(1,1,1),
			pos=Vector(-1.5,-1,-.5),
			ang=Angle(-180,-83,-180),
			wgt=15,
			def=40,
			dur=250,
			ent="ent_jack_gmod_ezarmor_slcalf"
		}
	},
	RightCalf={
		["Standard"]={
			mdl="models/snowzgmod/payday2/armour/armourrcalf.mdl", -- aegis
			siz=Vector(1,1,1),
			pos=Vector(-1.5,-1,.5),
			ang=Angle(-180,-83,-180),
			wgt=15,
			def=40,
			dur=250,
			ent="ent_jack_gmod_ezarmor_srcalf"
		}
	}
}

hook.Add("Initialize","JMOD_Initialize",function()
	if(SERVER)then JMod_InitGlobalConfig() end
end)
hook.Add("SetupMove","JMOD_ARMOR_MOVE",function(ply,mv,cmd)
	---[[
	if((ply.EZarmor)and(ply.EZarmor.speedfrac)and not(ply.EZarmor.speedfrac==1))then
		local origSpeed=(cmd:KeyDown(IN_SPEED) and ply:GetRunSpeed()) or ply:GetWalkSpeed()
		mv:SetMaxClientSpeed(origSpeed*ply.EZarmor.speedfrac)
	end
	--]]
end)
local ANGLE=FindMetaTable("Angle")
function ANGLE:GetCopy()
	return Angle(self.p,self.y,self.r)
end
function table.FullCopy(tab)
	if(!tab)then return nil end
	local res={}
	for k, v in pairs(tab) do
		if(type(v)=="table")then
			res[k]=table.FullCopy(v) -- we need to go derper
		elseif(type(v)=="Vector")then
			res[k]=Vector(v.x, v.y, v.z)
		elseif(type(v)=="Angle")then
			res[k]=Angle(v.p, v.y, v.r)
		else
			res[k]=v
		end
	end
	return res
end
function jprint(...)
	local items,printstr={...},""
	for k,v in pairs(items)do
		-- todo: tables
		printstr=printstr..tostring(v)..", "
	end
	print(printstr)
	if(SERVER)then
		player.GetAll()[1]:PrintMessage(HUD_PRINTTALK,printstr)
		player.GetAll()[1]:PrintMessage(HUD_PRINTCENTER,printstr)
	elseif(CLIENT)then
		LocalPlayer():ChatPrint(printstr)
	end
end
function JMod_GoodBadColor(frac)
	-- color tech from bfs2114
	local r,g,b=math.Clamp(3-frac*4,0,1),math.Clamp(frac*2,0,1),math.Clamp(-3+frac*4,0,1)
	return r*255,g*255,b*255
end
function JMOD_WhomILookinAt(ply,cone,dist)
	local CreatureTr,ObjTr,OtherTr=nil,nil,nil
	for i=1,(150*cone) do
		local Vec=(ply:GetAimVector()+VectorRand()*cone):GetNormalized()
		local Tr=util.QuickTrace(ply:GetShootPos(),Vec*dist,{ply})
		if((Tr.Hit)and not(Tr.HitSky)and(Tr.Entity))then
			local Ent,Class=Tr.Entity,Tr.Entity:GetClass()
			if((Ent:IsPlayer())or(Ent:IsNPC()))then
				CreatureTr=Tr
			elseif((Class=="prop_physics")or(Class=="prop_physics_multiplayer")or(Class=="prop_ragdoll"))then
				ObjTr=Tr
			else
				OtherTr=Tr
			end
		end
	end
	if(CreatureTr)then return CreatureTr.Entity,CreatureTr.HitPos,CreatureTr.HitNormal end
	if(ObjTr)then return ObjTr.Entity,ObjTr.HitPos,ObjTr.HitNormal end
	if(OtherTr)then return OtherTr.Entity,OtherTr.HitPos,OtherTr.HitNormal end
	return nil,nil,nil
end
--
function JMod_IsDoor(ent)
	local Class=ent:GetClass()
	return ((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating"))
end
--
local Hints={
	["afh"]="E to enter and get healed",
	["airburst det"]="detonates in midair automatically",
	["ammobox"]="ALT+E to refill ammo of any weapon",
	["antimatter"]="CAUTION EXTREMELY DANGEROUS VERY FRAGILE HANDLE WITH CARE",
	["arm"]="ALT+E to arm",
	["armor remove"]="type *armor* or concommand jmod_ez_armor to unequip all armor",
	["armor"]="ALT+E to select color and wear armor",
	["auto anchor"]="bomb will automatially anchor itself below the surface of the water",
	["binding"]="remember, console commands can be bound to a key",
	["black powder pile"]="ALT+E to ignite black powder, E to sweep away",
	["black powder ignite"]="black powder can ignite powder kegs and anything with a pyro fuze, like dynamite",
	["blasting machine"]="ALT+E on the blasting machine to detonate the satchel charge",
	["bomb drop"]="weld/nail bomb to vehicle, then type *bomb* or cmd jmod_ez_bombdrop to detach",
	["bomb guidable"]="use a guidance kit to turn into a guided bomb",
	["building"]="stand near resources in order to use them",
	["bury"]="can only be buried in grass, dirt, snow or mud",
	["crafting"]="set resources near workbench in order to use them",
	["crate"]="tap resource against to store \n press E to retrieve resource",
	["contact det"]="when armed, bomb will detonate on contact",
	["customize"]="To customize JMod, or to disable these hints, check out garrysmod/data/jmod_config.txt",
	["decontaminate"]="can also remove radioactive fallout from a person",
	["detpack combo"]="detpacks can destroy props \n multiple combine for more power",
	["detpack stick"]="hold E on detpack then release E to stick the detpack",
	["disarm"]="tap E to disarm",
	["eat"]="ALT+E to consume",
	["fix"]="tap parts box against to repair",
	["friends"]="concommand jmod_friends to specify allies",
	["grenade"]="ALT+E to pick up and arm grenade. LMB for hard throw, RMB for soft throw",
	["guidance kit"]="tap against an EZ Bomb or EZ Big Bomb to create a guided bomb",
	["headset"]="type *headset* or concommand jmod_ez_headset to toggle ear equipment",
	["headset comms"]="with a headset, only friends and teammates can hear your voip and see your chat",
	["item crate"]="tap item against to store \n press E to retrieve item",
	["impact det"]="when armed, bomb will detonate upon impact",
	["jmod hands drag"]="move slowly to drag heavier objects (crouch/alt)",
	["jmod hands grab"]="RMB to grab objects",
	["jmod hands move"]="punches also can move you (jump boost/climbing)",
	["jmod hands"]="RMB to block, R to put hands down",
	["launch"]="weld/nail weapon to vehicle, then type *launch* or cmd jmod_ez_launch to launch",
	["mask"]="type *mask* or concommand jmod_ez_mask to toggle face equipment",
	["mininade"]="mininades can be stuck to larger explosives to trigger them",
	["modify"]="use the build kit to modify",
	["powder keg"]="ALT+E to open and pour a line of black powder",
	["radsickness"]="taking damage from radiation sickness, decontaminate in field hospital",
	["remote det"]="chat *trigger* \n or concommand jmod_ez_trigger",
	["slam stick"]="hold E on SLAM then release E to stick SLAM",
	["slam trigger"]="SLAMs can be stuck to larger explosives to trigger them",
	["radio comm"]="radio needs to see sky",
	["slam stick"]="hold E on SLAM then release E to stick the SLAM",
	["splitterring"]="SHIFT+ALT+E to toggle fragmentation sleeve",
	["supplies"]="tap supplies against to refill, tap parts against to repair",
	["timebomb stick"]="hold E on timebomb then release E to stick the timebomb",
	["unpackage"]="double tap ALT+E to unpackage",
	["upgrade"]="use Build Kit to upgrade",
	["water arm"]="arm bomb and drop in water",
	["water det"]="bomb must be in water to detonate"
}
function JMod_Hint(ply,...)
	if(CLIENT)then return end
	if not(JMOD_CONFIG.Hints)then return end
	local HintKeys={...}
	ply.NextJModHint=ply.NextJModHint or 0
	ply.JModHintsGiven=ply.JModHintsGiven or {}
	local Time=CurTime()
	if(ply.NextJModHint>Time)then return end
	for k,key in pairs(HintKeys)do
		if not(table.HasValue(ply.JModHintsGiven,key))then
			table.insert(ply.JModHintsGiven,key)
			ply.NextJModHint=Time+1
			net.Start("JMod_Hint")
			net.WriteString(Hints[key])
			net.Send(ply)
			break
		end
	end
end
if(SERVER)then
	concommand.Add("jmod_resethints",function(ply,cmd,args)
		ply.JModHintsGiven={}
		print("hints for "..ply:Nick().." reset")
	end)
end
function JMod_PlayersCanComm(listener,talker)
	if(listener==talker)then return true end
	if(engine.ActiveGamemode()=="sandbox")then
		return ((talker.JModFriends)and(table.HasValue(talker.JModFriends,listener)))
	else
		if((talker.JModFriends)and(table.HasValue(talker.JModFriends,listener)))then return true end
		return listener:Team()==talker:Team()
	end
end
--
hook.Add("EntityFireBullets","JMOD_ENTFIREBULLETS",function(ent,data)
	if(IsValid(JMOD_BLACK_HOLE))then
		local BHpos=JMOD_BLACK_HOLE:GetPos()
		local Bsrc,Bdir=data.Src,data.Dir
		local Vec=BHpos-Bsrc
		local Dist=Vec:Length()
		if(Dist<10000)then
			local ToBHdir=Vec:GetNormalized()
			local NewDir=(Bdir+ToBHdir*JMOD_BLACK_HOLE:GetAge()/Dist*20):GetNormalized()
			data.Dir=NewDir
			return true
		end
	end
end)
-- EZ radio stations
EZ_RADIO_STATIONS={}
EZ_STATION_STATE_READY=1
EZ_STATION_STATE_DELIVERING=2
EZ_STATION_STATE_BUSY=3
-- EZ item quality grade (upgrade level) definitions
EZ_GRADE_BASIC=1
EZ_GRADE_COPPER=2
EZ_GRADE_SILVER=3
EZ_GRADE_GOLD=4
EZ_GRADE_PLATINUM=5
EZ_GRADE_BUFFS={1,1.25,1.5,1.75,2}
EZ_GRADE_NAMES={"basic","copper","silver","gold","platinum"}
---
JMod_EZammoBoxSize=300
JMod_EZfuelCanSize=100
JMod_EZbatterySize=100
JMod_EZpartBoxSize=100
JMod_EZsmallCrateSize=100
JMod_EZsuperRareResourceSize=10
JMod_EZexplosivesBoxSize=100
JMod_EZchemicalsSize=100
JMod_EZadvPartBoxSize=20
JMod_EZmedSupplyBoxSize=50
JMod_EZnutrientBoxSize=100
JMod_EZcrateSize=15
JMod_EZpartsCrateSize=15
JMod_EZnutrientsCrateSize=15

JMOD_EZ_STATE_BROKEN 	= -1
JMOD_EZ_STATE_OFF 		= 0
JMOD_EZ_STATE_PRIMED 	= 1
JMOD_EZ_STATE_ARMING 	= 2
JMOD_EZ_STATE_ARMED		= 3
JMOD_EZ_STATE_WARNING	= 4

--[[
muzzleflash_g3
muzzleflash_m14
muzzleflash_ak47
muzzleflash_ak74
muzzleflash_6
muzzleflash_pistol_rbull
muzzleflash_pistol
muzzleflash_suppressed
muzzleflash_pistol_deagle
muzzleflash_OTS
muzzleflash_M3
muzzleflash_smg
muzzleflash_SR25
muzzleflash_shotgun
muzzle_center_M82
muzzleflash_m79
--]]

-- TODO
-- yeet a wrench easter egg
-- frickin like ADD npc factions to the whitelist yo, gosh damn
-- add the crate smoke flare
-- santa sleigh aid radio
-- make sentry upgrading part of the mod point system
-- make thermals work with smoke
-- hide hand icon when in seat or vehicle
-- make nuke do flashbang
-- add combustible lemons
-- check armor headgear compat with act3, cull models that are too close to the camera
-- models/thedoctor/mani/dave_the_dummy_on_stand_phys.mdl damage reading mannequin
-- the Mk.8Z
-- armor refactor and radsuit
-- wiremod support
-- sentries shoot dead things
-- moab drogue chute
-- command to make gas and fallout visible