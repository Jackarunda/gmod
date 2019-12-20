AddCSLuaFile()
player_manager.AddValidModel("JackaFireSuit","models/DPFilms/jetropolice/Playermodels/pm_policetrench.mdl")
player_manager.AddValidHands("JackaFireSuit","models/DPFilms/jeapons/v_arms_metropolice.mdl",0,"00000000")
player_manager.AddValidModel("JackaHazmatSuit","models/DPFilms/jetropolice/Playermodels/pm_police_bt.mdl")
player_manager.AddValidHands("JackaHazmatSuit","models/DPFilms/jeapons/v_arms_metropolice.mdl",0,"00000000")
player_manager.AddValidModel("JackyEODSuit","models/juggerjaut_player.mdl")
player_manager.AddValidHands("JackyEODSuit","models/DPFilms/jeapons/v_arms_metropolice.mdl",0,"00000000")
game.AddParticles("particles/muzzleflashes_test.pcf")
game.AddParticles("particles/muzzleflashes_test_b.pcf")
game.AddParticles( "particles/pcfs_jack_explosions_large.pcf")
game.AddParticles( "particles/pcfs_jack_explosions_medium.pcf")
game.AddParticles( "particles/pcfs_jack_explosions_small.pcf")
if(SERVER)then
	resource.AddWorkshop("1919689921")
	resource.AddWorkshop("1919703147")
	resource.AddWorkshop("1919692947")
	resource.AddWorkshop("1919694756")
end
---
function JMod_InitGlobalConfig()
	local NewConfig={
		Author="Jackarunda",
		Version=16,
		Note="radio packages must have all lower-case names",
		Hints=true,
		SentryPerformanceMult=1,
		MineDelay=1,
		MinePower=1,
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
				["explosives"]={
					{"ent_jack_gmod_ezexplosives",3}
				},
				["chemicals"]={
					{"ent_jack_gmod_ezchemicals",3}
				},
				["fuel"]={
					{"ent_jack_gmod_ezfuel",4}
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
				["general purpose crate"]={
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
				["stick grenades"]={
					{"ent_jack_gmod_ezsticknade",10}
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
				["bounding mines"]={
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
					"ent_jack_gmod_ezarmor_srforearm","ent_jack_gmod_ezarmor_srthigh"
				}
			},
			RestrictedPackages={"antimatter"},
			RestrictedPackageShipTime=600,
			RestrictedPackagesAllowed=true
		},
		Blueprints={
			["EZ Sentry"]={"ent_jack_gmod_ezsentry",{parts=200,power=100,ammo=300,advparts=20}},
			["EZ Supply Radio"]={"ent_jack_gmod_ezaidradio",{parts=100, power=100,advparts=20}},
			["EZ Automated Field Hospital"]={"ent_jack_gmod_ezfieldhospital",{parts=400,power=100,advparts=80,medsupplies=50},2},
			["EZ Resource Crate"]={"ent_jack_gmod_ezcrate",{parts=100},1.5},
			["EZ General Purpose Crate"]={"ent_jack_gmod_ezcrate_uni",{parts=50},1},
			["EZ Micro Black Hole Generator"]={"ent_jack_gmod_ezmbhg",{parts=300,advparts=120,power=600,antimatter=10},1.5},
			["EZ Workbench"]={"ent_jack_gmod_ezworkbench",{parts=500,advparts=40,power=100,gas=100},1.5},
			["HL2 Buggy"]={"FUNC spawnHL2buggy",{parts=500,power=50,advparts=10,fuel=300,ammo=600},2}
		},
		Recipes={
			["EZ Medkit"]={"ent_jack_gmod_ezmedkit",{parts=20,medsupplies=200}},
			["EZ Build Kit"]={"ent_jack_gmod_ezbuildkit",{parts=100,advparts=20,gas=50,power=50}},
			["EZ Ammo"]={"ent_jack_gmod_ezammo",{parts=30,chemicals=30,explosives=5}},
			["EZ Explosives"]={"ent_jack_gmod_ezexplosives",{parts=5,chemicals=150}},
			["EZ Landmine"]={"ent_jack_gmod_ezlandmine",{parts=10,explosives=5}},
			["EZ Bounding Mine"]={"ent_jack_gmod_ezboundingmine",{parts=20,explosives=5}},
			["EZ Fumigator"]={"ent_jack_gmod_ezfumigator",{parts=30,gas=100,chemicals=50}},
			["EZ Fougasse Mine"]={"ent_jack_gmod_ezfougasse",{parts=20,fuel=100,explosives=5}},
			["EZ Detpack"]={"ent_jack_gmod_ezdetpack",{parts=5,explosives=20}},
			["EZ Time Bomb"]={"ent_jack_gmod_eztimebomb",{parts=30,explosives=180}},
			["EZ SLAM"]={"ent_jack_gmod_ezslam",{parts=20,explosives=15}},
			["EZ Medical Supplies"]={"ent_jack_gmod_ezmedsupplies",{parts=20,chemicals=50,advparts=10,advtextiles=10}},
			["EZ Fragmentation Grenade"]={"ent_jack_gmod_ezfragnade",{parts=10,explosives=5}},
			["EZ Mini Impact Grenade"]={"ent_jack_gmod_eznade_impact",{parts=5,explosives=3}},
			["EZ Mini Proximity Grenade"]={"ent_jack_gmod_eznade_proximity",{parts=5,explosives=3}},
			["EZ Mini Timed Grenade"]={"ent_jack_gmod_eznade_timed",{parts=5,explosives=3}},
			["EZ Mini Remote Grenade"]={"ent_jack_gmod_eznade_remote",{parts=5,explosives=3}},
			["EZ Gas Grenade"]={"ent_jack_gmod_ezgasnade",{parts=5,gas=20,chemicals=15}},
			["EZ Impact Grenade"]={"ent_jack_gmod_ezimpactnade",{parts=5,explosives=10}},
			["EZ Incendiary Grenade"]={"ent_jack_gmod_ezfirenade",{parts=5,explosives=5,fuel=30}},
			["EZ Satchel Charge"]={"ent_jack_gmod_ezsatchelcharge",{parts=10,explosives=30}},
			["EZ Stick Grenade"]={"ent_jack_gmod_ezsticknade",{parts=15,explosives=5}},
			["EZ Sticky Bomb"]={"ent_jack_gmod_ezstickynade",{parts=10,explosives=10,chemicals=10}},
			["EZ Ballistic Mask"]={"ent_jack_gmod_ezarmor_balmask",{parts=10,advtextiles=5}},
			["EZ Gas Mask"]={"ent_jack_gmod_ezarmor_gasmask",{parts=10,chemicals=10,advtextiles=2}},
			["EZ Heavy Left Shoulder Armor"]={"ent_jack_gmod_ezarmor_hlshoulder",{parts=15,advtextiles=10}},
			["EZ Heavy Right Shoulder Armor"]={"ent_jack_gmod_ezarmor_hrshoulder",{parts=15,advtextiles=10}},
			["EZ Heavy Torso Armor"]={"ent_jack_gmod_ezarmor_htorso",{parts=20,advtextiles=30}},
			["EZ Light Helmet"]={"ent_jack_gmod_ezarmor_lhead",{parts=15,advtextiles=5}},
			["EZ Light Left Shoulder Armor"]={"ent_jack_gmod_ezarmor_llshoulder",{parts=10,advtextiles=5}},
			["EZ Light Right Shoulder Armor"]={"ent_jack_gmod_ezarmor_lrshoulder",{parts=10,advtextiles=5}},
			["EZ Light Torso Armor"]={"ent_jack_gmod_ezarmor_ltorso",{parts=15,advtextiles=10}},
			["EZ Medium Helmet"]={"ent_jack_gmod_ezarmor_mhead",{parts=20,advtextiles=10}},
			["EZ Medium-Heavy Torso Armor"]={"ent_jack_gmod_ezarmor_mhtorso",{parts=15,advtextiles=25}},
			["EZ Medium-Light Torso Armor"]={"ent_jack_gmod_ezarmor_mltorso",{parts=15,advtextiles=15}},
			["EZ Medium Torso Armor"]={"ent_jack_gmod_ezarmor_mtorso",{parts=15,advtextiles=20}},
			["EZ Standard Left Calf Armor"]={"ent_jack_gmod_ezarmor_slcalf",{parts=10,advtextiles=5}},
			["EZ Standard Left Forearm Armor"]={"ent_jack_gmod_ezarmor_slforearm",{parts=10,advtextiles=5}},
			["EZ Standard Left Thigh Armor"]={"ent_jack_gmod_ezarmor_slthigh",{parts=10,advtextiles=5}},
			["EZ Standard Pelvis Armor"]={"ent_jack_gmod_ezarmor_spelvis",{parts=10,advtextiles=10}},
			["EZ Standard Right Calf Armor"]={"ent_jack_gmod_ezarmor_srcalf",{parts=10,advtextiles=5}},
			["EZ Standard Right Forearm Armor"]={"ent_jack_gmod_ezarmor_srforearm",{parts=10,advtextiles=5}},
			["EZ Standard Right Thigh Armor"]={"ent_jack_gmod_ezarmor_srthigh",{parts=10,advtextiles=5}}
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
	if not(JMOD_CONFIG)then
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
		Ent.Owner=playa
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

	JMOD_LUA_CONFIG.ArmorOffsets["models/player/phoenix.mdl"] = CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/guerilla.mdl"] = CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/leet.mdl"] = CSSTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/arctic.mdl"] = CSSTTable

	JMOD_LUA_CONFIG.ArmorOffsets["models/player/swat.mdl"] = CSSCTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/urban.mdl"] = CSSCTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/gasmask.mdl"] = CSSCTTable
	JMOD_LUA_CONFIG.ArmorOffsets["models/player/riot.mdl"] = CSSCTTable
	
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
			dur=100,
			mskmat=Material("mats_jack_gmod_sprites/hard_vignette.png"),
			ent="ent_jack_gmod_ezarmor_balmask",
			gayPhysics=true
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
	if((ply.EZarmor)and(ply.EZarmor.speedfrac)and not(ply.EZarmor.speedfrac==1))then
		local origSpeed=(cmd:KeyDown(IN_SPEED) and ply:GetRunSpeed()) or ply:GetWalkSpeed()
		mv:SetMaxClientSpeed(origSpeed*ply.EZarmor.speedfrac)
	end
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
--- OLD FUNGUNS CODE ---
local PowerTypeToEntClassTable={
	["High-Density Rechargeable Lithium-Ion Battery"]="ent_jack_fgc_energy_lithium",
	["Self-Contained Micro Nuclear Fission Reactor"]="ent_jack_fgcartridge_energy",
	["Radiosotope Thermoelectric Generator/Battery Module"]="ent_jack_fgc_energy_rite"
}

if(CLIENT)then
	/*-local fr=1
	local avg=0
	local Length=1
	local function GiveFrameRate()
		avg=avg+FrameTime()
		fr=fr+1
		if(fr==51)then
			avg=avg/50
			fr=1
			Length=(1/avg)*5
		end
		draw.RoundedBox(10,0,0,Length,100,Color(0,0,0,180));
		draw.DrawText(tostring(math.Round(Length/5)),"default",50,40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	hook.Add("HUDPaint","JackysFrameRateChecker",GiveFrameRate)-*/
	
	local function LoadWeapon(data)
		data:ReadEntity():LoadEnergyCartridge(data:ReadEntity())
	end
	usermessage.Hook("JackyFGEnergyLoad",LoadWeapon)
	
	local function LoadWeaponAgain(data)
		data:ReadEntity():LoadIronSlug(data:ReadEntity())
	end
	usermessage.Hook("JackyFGIronLoad",LoadWeaponAgain)

	function FG_Scope()
		local Ply=LocalPlayer()
		local Wep=Ply:GetActiveWeapon()
		if(IsValid(Wep))then
			if(Wep.Jack_FG_Scoped)then
				Wep.rtmat:SetTexture("$basetexture",Wep.FGScope)
				old=render.GetRenderTarget()
				local CamData={}
				CamData.angles=Ply:GetAimVector():Angle()
				CamData.origin=Ply:GetShootPos()
				CamData.x=0
				CamData.y=0
				CamData.w=400
				CamData.h=400
				CamData.fov=8
				CamData.drawviewmodel=false
				CamData.drawhud=false
				render.SetRenderTarget(Wep.FGScope)
				render.SetViewPort(0,0,400,400)
				cam.Start2D()
				render.RenderView(CamData)
				cam.End2D()
				render.SetViewPort(0,0,ScrW(),ScrH())
				render.SetRenderTarget(old)
			end
		end
	end
	hook.Add("RenderScene","Jacky_FG_Scope",FG_Scope)
	
	local function Adjust(default)
		local Ply=LocalPlayer()
		local Wep=Ply:GetActiveWeapon()
		if(IsValid(Wep))then
			if(Wep.IsAJackyFunGun)then
				if(Wep.MouseAdjust)then
					if(Ply:KeyDown(IN_ATTACK2))then return Wep.MouseAdjust end
				end
			end
		end
	end
	hook.Add("AdjustMouseSensitivity","JackysFunGunMouseSensitivity",Adjust)

	local function ChangeMovement(data)
		local Wep=data:ReadEntity()
		local Num=data:ReadFloat()
		if((Wep)and(Num))then
			Wep.BobScale=Num
			Wep.SwayScale=Num
		end
	end
	usermessage.Hook("JackysDynamicFGBobSwayScaling",ChangeMovement)

	local function MakeMagHot(data)
		local self=data:ReadEntity()
		local Type=data:ReadString()
		if(Type=="Self-Contained Micro Nuclear Fission Reactor")then
			self.VElements["herp"].surpresslightning=true
			self.VElements["herp"].material="models/debug/debugwhite"
		elseif(Type=="High-Density Rechargeable Lithium-Ion Battery")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_lithium"
		elseif(Type=="Radiosotope Thermoelectric Generator/Battery Module")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_rite"
		end
	end
	usermessage.Hook("JackysFGMagHot",MakeMagHot)

	local function MakeMagCool(data)
		local self=data:ReadEntity()
		local Type=data:ReadString()
		if(Type=="Self-Contained Micro Nuclear Fission Reactor")then
			self.VElements["herp"].surpresslightning=false
			self.VElements["herp"].material=nil
		elseif(Type=="High-Density Rechargeable Lithium-Ion Battery")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_lithium"
		elseif(Type=="Radiosotope Thermoelectric Generator/Battery Module")then
			self.VElements["herp"].material="models/mat_jack_fgc_energy_rite"
		end
	end
	usermessage.Hook("JackysFGMagCool",MakeMagCool)
	
	function JackIndFunGunAmmoDisplay(self)
		if not(self.DisplaysOn)then return end
		local Flicker=math.Rand(.5,1)
		local Ammo
		if(self.dt.Ammo)then Ammo=self.dt.Ammo else Ammo=self.dt.Energy end
		if(Ammo<.01)then Flicker=math.Rand(0,.5) end
		local Frac=1-Ammo
		surface.SetDrawColor((4*Frac-1)*255,(-2*Frac+2)*255,(-4*Frac+1)*255,75*Flicker)
		for i=0,16 do
			surface.DrawLine(-5,i,19,i)
		end
		surface.SetDrawColor(255,255,255,200*Flicker)
		surface.DrawOutlinedRect(-5,0,25,17)
		surface.SetTextColor(255,255,255,200*Flicker)
		surface.SetTextPos(0,2)
		surface.SetFont("Default")
		surface.DrawText(tostring(math.Clamp(math.floor(Ammo*100),0,100)))
	end

	local function JackIndFontSet()
		surface.CreateFont("JackIndFunGunLargeFont",{font="coolvetica",size=20,weight=200})
		surface.CreateFont("JackIndFunGunSmallFont",{font="coolvetica",size=6,weight=150})
		surface.CreateFont("JackIndFunGunSemiSmallFont",{font="coolvetica",size=7,weight=150})
	end
	hook.Add("Initialize","JackIndFontCreation",JackIndFontSet)

	function JackIndFunGunIronDisplay(self)
		if not(self.DisplaysOn)then return end
		local Flicker=math.Rand(.5,1)
		local Ammo=self.dt.Mass
		local Frac=1-Ammo/self.MaxRoundCapacity
		if(self.dt.Energy<.01)then Flicker=math.Rand(0,.5) end
		surface.SetDrawColor(255,255,255,200*Flicker)
		for i=0,24 do
			surface.DrawLine(-15,i,19,i)
		end
		surface.SetDrawColor((4*Frac-1)*255,(-2*Frac+2)*255,(-4*Frac+1)*255,75*Flicker)
		for i=25,38 do
			surface.DrawLine(-15,i,19,i)
		end
		surface.SetDrawColor(255,255,255,200*Flicker)
		surface.DrawOutlinedRect(-15,0,35,40)
		surface.SetTextColor(0,0,0,240*Flicker)
		surface.SetTextPos(-13,1)
		surface.SetFont("JackIndFunGunSemiSmallFont")
		surface.DrawText("26")
		surface.SetTextPos(5,1)
		surface.DrawText("55.85")
		surface.SetTextPos(-5,5)
		surface.SetFont("JackIndFunGunLargeFont")
		surface.DrawText("Fe")
		surface.SetTextColor(255,255,255,200*Flicker)
		surface.SetTextPos(-4,26)
		surface.SetFont("Default")
		surface.DrawText(tostring(self.dt.Mass))
	end
	
	local Tab={
		{4,5},{4,5},{4,6},{4,6},
		{3,7},{3,7},{3,7},{2,8},
		{2,8},{2,8},{2,8},{2,8},
		{2,8},{2,8},{2,8},{2,8},
		{2,8},{2,8},{2,8},{2,8},
		{2,8},{2,9}
	}
	function JackIndFunGunIronChamberDisplay(self)
		if not(self.DisplaysOn)then return end
		local Flicker=math.Rand(.5,1)
		if(self.dt.Energy<.01)then Flicker=math.Rand(0,.5) end
		surface.SetDrawColor(255,255,255,200*Flicker)
		surface.DrawLine(5,8,8,15)
		surface.DrawLine(5,8,2,15)
		surface.DrawLine(8,15,9,20)
		surface.DrawLine(2,15,1,20)
		surface.DrawLine(9,20,9,30)
		surface.DrawLine(1,20,1,30)
		surface.DrawLine(1,30,9,30)
		if not(self.RoundChambered)then
			local Opacity=((math.sin(CurTime()*6)+1)/2)*100
			surface.SetDrawColor(255,0,0,Opacity*Flicker)
		end
		for k,v in pairs(Tab) do
			surface.DrawLine(v[1],8+k,v[2],8+k)
		end
	end
	
	local function ChangeInteger(data)
		data:ReadEntity()[data:ReadString()]=data:ReadInt()
	end
	usermessage.Hook("JackysFGIntChange",ChangeInteger)
	
	local function ChangeBool(data)
		data:ReadEntity()[data:ReadString()]=data:ReadBool()
	end
	usermessage.Hook("JackysFGBoolChange",ChangeBool)
	
	local function ChangeFloat(data)
		local Wep=data:ReadEntity()
		local Field=data:ReadString()
		local Value=data:ReadFloat()
		Wep[Field]=Value
		if((Field=="CurrentCapacitorCharge")and(Value==0))then if(Wep.ChargingSound)then Wep.ChargingSound:Stop() end end
	end
	usermessage.Hook("JackysFGFloatChange",ChangeFloat)
	
	local LastViewAng=false
	local function SimilarizeAngles(ang1, ang2)
		ang1.y=math.fmod (ang1.y, 360)
		ang2.y=math.fmod (ang2.y, 360)
		if math.abs (ang1.y - ang2.y)>180 then
			if ang1.y - ang2.y<0 then
				ang1.y=ang1.y+360
			else
				ang1.y=ang1.y - 360
			end
		end
	end
	local staggerdir=VectorRand()
	local function Stagger(uCmd)
		local ply=LocalPlayer()
		if not(ply)then return end
		local Wep=ply:GetActiveWeapon()
		if(IsValid(Wep))then
			if not(Wep.IsAJackyFunGun)then return end
			local newAng=uCmd:GetViewAngles()
			if LastViewAng then
				SimilarizeAngles (LastViewAng, newAng)
				local ft=FrameTime()*5
				local argh=.2
				if(ply:Crouching())then argh=argh-.05 end
				if(ply:KeyDown(IN_ATTACK2))then argh=argh-.05 end
				staggerdir =((staggerdir+ft*VectorRand()):GetNormalized())*argh
				local diff=newAng - LastViewAng
				diff=diff*((LocalPlayer():GetFOV())/75)
				local DerNeuAngle=LastViewAng+diff
				local addpitch=staggerdir.z*ft
				local addyaw=staggerdir.x*ft
				DerNeuAngle.pitch=DerNeuAngle.pitch+addpitch
				DerNeuAngle.yaw=DerNeuAngle.yaw+addyaw
				uCmd:SetViewAngles(DerNeuAngle)
			end
		end
		LastViewAng=uCmd:GetViewAngles()
	end 
	hook.Add("CreateMove","JackyFGStagger",Stagger)
	
	local function RemoveExplodoCrabRagdollClient(data)
		local Pos=data:ReadVector()
		for key,rag in pairs(ents.FindInSphere(Pos,50))do
			if(rag:GetClass()=="class C_ClientRagdoll")then
				if(rag:GetModel()=="models/headcrabclassic.mdl")then
					rag:Remove()
				end
			end
		end
	end
	usermessage.Hook("JackysExplodoRagdollCrabClient",RemoveExplodoCrabRagdollClient)
end

if(SERVER)then
	local NextGoTime=CurTime()
	local function Energy()
		local Time=CurTime()
		if(NextGoTime<Time)then
			NextGoTime=Time+.1
			local Guns=ents.FindByClass("wep_jack_fungun_*")
			local Carts=ents.FindByClass("ent_jack_fgc_energy_rite")
			for key,wep in pairs(Guns)do
				if(wep.DisplaysOn)then
					if(wep.dt.Ammo)then
						wep.dt.Ammo=wep.dt.Ammo-.000001*wep.ConsumptionMul
					elseif(wep.dt.Energy)then
						wep.dt.Energy=wep.dt.Energy-.000001*wep.ConsumptionMul
					end
				end
				if(wep.PowerType=="Radiosotope Thermoelectric Generator/Battery Module")then
					if(wep.dt.Ammo)then
						wep.dt.Ammo=math.Clamp(wep.dt.Ammo+.0035,0,1)
					elseif(wep.dt.Energy)then
						wep.dt.Energy=math.Clamp(wep.dt.Energy+.0035,0,1)
					end
				end
			end
			for key,cart in pairs(Carts)do
				cart.Charge=math.Clamp(cart.Charge+.0035,0,1)
			end
		end
	end
	hook.Add("Think","JackysFunGunGlobalEnergy",Energy)
	
	local function AllahuAckbar(victim,dmginfo) -- not really. The God of the book FTW
		local Attacker=dmginfo:GetAttacker()
		if(Attacker.ShouldRandomlyExplode)then
			if not(dmginfo:GetDamageType()==DMG_BLAST)then
				local Pos=dmginfo:GetDamagePosition()
				local SplooTable={}
				for i=0,10 do
					SplooTable[i]=ents.Create("env_explosion")
					SplooTable[i]:SetPos(Pos+VectorRand()*math.Rand(0,100))
					SplooTable[i]:SetKeyValue("iMagnitude","40")
					SplooTable[i]:SetOwner(Attacker)
					SplooTable[i]:Spawn()
					SplooTable[i]:Activate()
				end
				Attacker:Remove()
				for key,sploo in pairs(SplooTable) do
					sploo:Fire("explode","",0)
				end
				timer.Simple(.02,function()
					umsg.Start("JackysExplodoRagdollCrabClient")
					umsg.Vector(Pos)
					umsg.End()
				end)
			end
		end
	end
	hook.Add("EntityTakeDamage","JackysLolExplodoAttacks",AllahuAckbar)
	
	local function AwShitIDied(npc,attacker,inflictor)
		if(npc.ShouldRandomlyExplode)then
			if not(attacker==npc)then
				local Pos=npc:GetPos()
				JMod_Sploom(npc,Pos+VectorRand()*math.Rand(0,100),50)
				npc:Remove()
				Sploo:Fire("explode","",0)
				timer.Simple(.02,function()
					umsg.Start("JackysExplodoRagdollCrabClient")
					umsg.Vector(Pos)
					umsg.End()
				end)
			end
		end
	end
	hook.Add("OnNPCKilled","JackysLolExplodoDeaths",AwShitIDied)
	
	--[[local function MakeExplodoCrab(ply,npc)
		if(npc:GetClass()=="npc_headcrab")then
			npc.ShouldRandomlyExplode=true
			npc:SetMaterial("models/mat_jack_explodocrab")
		end
	end
	hook.Add("PlayerSpawnedNPC","JackysLolExplodoCrabs",MakeExplodoCrab)--]]
	
	local function MakeExplodoCrabsCommand(args)
		for key,found in pairs(ents.FindByClass("npc_headcrab")) do
			found.ShouldRandomlyExplode=true
			found:SetMaterial("models/mat_jack_explodocrab")
		end
	end
	concommand.Add("ExplodoCrabs",MakeExplodoCrabsCommand)
end

function GlobalJackyFGHGDeploy(self)
	self.dt.State=1
	timer.Simple(.6,function()
		if(IsValid(self))then
			self:EmitSound("snd_jack_fgpistoldraw.wav",65,100)
		end
	end)
	if(self.NewCartridge)then
		timer.Simple(.7,function()
			if(IsValid(self))then
				self:EmitSound("snd_jack_smallcharge.wav",65,100)
				self.NewCartridge=false
				if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
				self.DisplaysOn=true
				if(SERVER)then
					umsg.Start("JackysFGBoolChange")
					umsg.Entity(self)
					umsg.String("DisplaysOn")
					umsg.Bool(self.DisplaysOn)
					umsg.End()
				end
			end
		end)
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	self.Owner:GetViewModel():SetPlaybackRate(1.3)
	timer.Simple(1,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function GlobalJackyFGLGDeploy(self)
	if(self.dt.State==1)then return end
	self.dt.State=1
 	if(SERVER)then self.Owner:EmitSound("snd_jack_fglonggundraw.wav") end
	if(self.NewCartridge)then
		timer.Simple(1.4,function()
			if(IsValid(self))then
				self:EmitSound("snd_jack_smallcharge.wav",65,100)
				self.NewCartridge=false
				if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
				self.DisplaysOn=true
				if(SERVER)then
					umsg.Start("JackysFGBoolChange")
					umsg.Entity(self)
					umsg.String("DisplaysOn")
					umsg.Bool(self.DisplaysOn)
					umsg.End()
				end
			end
		end)
	end
	self.Weapon:SendWeaponAnim(ACT_VM_DEPLOY)
	self.Owner:GetViewModel():SetPlaybackRate(.5)
	timer.Simple(2,function()
		if(IsValid(self))then
			self.dt.State=2
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
end

function GlobalJackyFGDisplayToggle(self)
	if(CLIENT)then return end
	if(self.Owner:KeyDown(IN_USE))then
		if(self.DisplaysOn)then
			self.DisplaysOn=false
			umsg.Start("JackysFGBoolChange")
			umsg.Entity(self)
			umsg.String("DisplaysOn")
			umsg.Bool(self.DisplaysOn)
			umsg.End()
			self:EmitSound("snd_jack_displaysoff.wav",60,100)
		else
			self.DisplaysOn=true
			umsg.Start("JackysFGBoolChange")
			umsg.Entity(self)
			umsg.String("DisplaysOn")
			umsg.Bool(self.DisplaysOn)
			umsg.End()
			self:EmitSound("snd_jack_displayson.wav",60,100)
		end
	end
end

function GlobalJackyFGReloadKey(self)
	if not(self.dt.State==2)then return end
	if(self.dt.Heat>.15)then
		self:BurstCool()
		return
	end
end

function GlobalJackyFGLongReloadKey(self)
	if not(self.dt.State==2)then return end
	if(self.dt.Heat>.15)then
		self:BurstCool()
		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
end

function GlobalJackyLoadIronSlug(self,cartridge)
	if not(self.dt.State==2)then return end
	local InitialMassRemaining=self.dt.Mass
	if(InitialMassRemaining<self.MaxRoundCapacity)then
		self.dt.State=5
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.Owner:SetAnimation(PLAYER_RELOAD)
		self.Weapon:EmitSound("snd_jack_massload.wav",70,130)
		self.Owner:ViewPunch(Angle(1,0,0))
		timer.Simple(.2,function()
			if(IsValid(self))then
				self.Owner:ViewPunch(Angle(1,0,0))
				self.Weapon:EmitSound("snd_jack_load_iron.wav",70,130)
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			end
		end)
		timer.Simple(.4,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
				self.Owner:GetViewModel():SetPlaybackRate(1.4)
			end
		end)
		timer.Simple(.8,function()
			if(IsValid(self))then
				if(SERVER)then self.dt.Mass=self.dt.Mass+1 end
			end
		end)
		timer.Simple(1.1,function()
			if(IsValid(self))then
				self.dt.State=2
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end

function GlobalJackyFGHGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge)
	if not(self.dt.State==2)then return end
	local NewType=cartridge.PowerType
	local InitialRemaining=self.dt.Ammo
	if(((InitialRemaining<=.01)and(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor"))or(self.PowerType=="High-Density Rechargeable Lithium-Ion Battery")or(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module"))then
		self.dt.State=5
		local Orig=self.DisplaysOn
		if(SERVER)then
			umsg.Start("JackysFGMagHot",self.Owner)
			umsg.Entity(self.Weapon)
			umsg.String(self.PowerType)
			umsg.End()
		end
		local TimeToStart=0.001
		if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then if(SERVER)then self.Weapon:EmitSound("snd_jack_nuclearfgc_end.wav") end;TimeToStart=2 end
		timer.Simple(TimeToStart,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:GetViewModel():SetPlaybackRate(.8)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self.Weapon:EmitSound(self.ReloadNoise[1],self.ReloadNoise[2],self.ReloadNoise[3])
				timer.Simple(.4,function()
					if(IsValid(self))then
						if(SERVER)then
							local Empty=ents.Create(PowerTypeToEntClassTable[self.PowerType])
							local LolAng=self.Owner:EyeAngles()
							local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
							Empty:SetPos((Pos+Ang:Up()*10-Ang:Forward()*10)+self.Owner:GetAimVector()*10)
							LolAng:RotateAroundAxis(LolAng:Forward(),90)
							LolAng:RotateAroundAxis(LolAng:Up(),180)
							Empty:SetAngles(LolAng)
							if(InitialRemaining<=.02)then Empty:SetDTBool(0,true) end
							Empty.Charge=InitialRemaining
							Empty:Spawn()
							Empty:Activate()
							Empty:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
						end
						self.dt.Ammo=0
						
						self.DisplaysOn=false
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
					end
				end)
				timer.Simple(.6,function()
					if(IsValid(self))then
						if(SERVER)then
							umsg.Start("JackysFGMagCool",self.Owner)
							umsg.Entity(self.Weapon)
							umsg.String(NewType)
							umsg.End()
						end
					end
				end)
				timer.Simple(1.5,function()
					if(IsValid(self))then
						self.DisplaysOn=Orig
						if(SERVER)then
							self.dt.Ammo=charge
							self.PowerType=powerType
							self.ConsumptionMul=consumptionMul
							self.HeatMul=heatMul
						end
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
						if(NewType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
						self:EmitSound("snd_jack_smallcharge.wav",65,100)
					end
				end)
				timer.Simple(2,function()
					if(IsValid(self))then
						self.dt.State=2
					end
				end)
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end

function GlobalJackyFGHGLoadEnCartNoPrim(self,cartridge,powerType,heatMul,consumptionMul,charge)
	if not(self.dt.State==2)then return end
	local NewType=cartridge.PowerType
	local InitialRemaining=self.dt.Energy
	if(((InitialRemaining<=.01)and(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor"))or(self.PowerType=="High-Density Rechargeable Lithium-Ion Battery")or(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module"))then
		self.dt.State=5
		local Orig=self.DisplaysOn
		if(SERVER)then
			umsg.Start("JackysFGMagHot",self.Owner)
			umsg.Entity(self.Weapon)
			umsg.String(self.PowerType)
			umsg.End()
		end
		local TimeToStart=0.001
		if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then if(SERVER)then self.Weapon:EmitSound("snd_jack_nuclearfgc_end.wav") end;TimeToStart=2 end
		timer.Simple(TimeToStart,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:GetViewModel():SetPlaybackRate(.8)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				self.Weapon:EmitSound(self.ReloadNoise[1],self.ReloadNoise[2],self.ReloadNoise[3])
				timer.Simple(.4,function()
					if(IsValid(self))then
						if(SERVER)then
							local Empty=ents.Create(PowerTypeToEntClassTable[self.PowerType])
							local LolAng=self.Owner:EyeAngles()
							local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
							Empty:SetPos((Pos+Ang:Up()*10-Ang:Forward()*10)+self.Owner:GetAimVector()*10)
							LolAng:RotateAroundAxis(LolAng:Forward(),90)
							LolAng:RotateAroundAxis(LolAng:Up(),180)
							Empty:SetAngles(LolAng)
							if(InitialRemaining<=.02)then Empty:SetDTBool(0,true) end
							Empty.Charge=InitialRemaining
							Empty:Spawn()
							Empty:Activate()
							Empty:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
						end
						self.dt.Energy=0
						
						self.DisplaysOn=false
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
					end
				end)
				timer.Simple(.6,function()
					if(IsValid(self))then
						if(SERVER)then
							umsg.Start("JackysFGMagCool",self.Owner)
							umsg.Entity(self.Weapon)
							umsg.String(NewType)
							umsg.End()
						end
					end
				end)
				timer.Simple(1.5,function()
					if(IsValid(self))then
						self.DisplaysOn=Orig
						if(SERVER)then
							self.dt.Energy=charge
							self.PowerType=powerType
							self.ConsumptionMul=consumptionMul
							self.HeatMul=heatMul
						end
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
						if(NewType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
						self:EmitSound("snd_jack_smallcharge.wav",65,100)
					end
				end)
				timer.Simple(2,function()
					if(IsValid(self))then
						self.dt.State=2
					end
				end)
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end

function GlobalJackyFGLGLoadEnCart(self,cartridge,powerType,heatMul,consumptionMul,charge,rate)
	if not(self.dt.State==2)then return end
	local NewType=cartridge.PowerType
	local InitialRemaining=self.dt.Ammo
	if(((InitialRemaining<=.01)and(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor"))or(self.PowerType=="High-Density Rechargeable Lithium-Ion Battery")or(self.PowerType=="Radiosotope Thermoelectric Generator/Battery Module"))then
		self.dt.State=5
		local Orig=self.DisplaysOn
		if(SERVER)then
			umsg.Start("JackysFGMagHot",self.Owner)
			umsg.Entity(self.Weapon)
			umsg.String(self.PowerType)
			umsg.End()
		end
		local TimeToStart=0.001
		if(self.PowerType=="Self-Contained Micro Nuclear Fission Reactor")then if(SERVER)then self.Weapon:EmitSound("snd_jack_nuclearfgc_end.wav") end;TimeToStart=2 end
		timer.Simple(TimeToStart,function()
			if(IsValid(self))then
				self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
				self.Owner:GetViewModel():SetPlaybackRate(.6*rate)
				self.Owner:SetAnimation(PLAYER_RELOAD)
				if(SERVER)then self.Weapon:EmitSound(self.ReloadNoise[1],self.ReloadNoise[2],self.ReloadNoise[3]) end
				timer.Simple(1.5,function()
					if(IsValid(self))then
						if(SERVER)then
							local Empty=ents.Create(PowerTypeToEntClassTable[self.PowerType])
							local LolAng=self.Owner:EyeAngles()
							local Pos,Ang=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"))
							Empty:SetPos(Pos+Ang:Up()*10-Ang:Forward()*10)
							LolAng:RotateAroundAxis(LolAng:Forward(),90)
							LolAng:RotateAroundAxis(LolAng:Up(),180)
							Empty:SetAngles(LolAng)
							if(InitialRemaining<=.02)then Empty:SetDTBool(0,true) end
							Empty.Charge=InitialRemaining
							Empty:Spawn()
							Empty:Activate()
							Empty:GetPhysicsObject():SetVelocity(self.Owner:GetVelocity())
						end
						self.dt.Ammo=0
						
						self.DisplaysOn=false
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
					end
				end)
				timer.Simple(2/rate,function()
					if(IsValid(self))then
						if(SERVER)then
							umsg.Start("JackysFGMagCool",self.Owner)
							umsg.Entity(self.Weapon)
							umsg.String(self.PowerType)
							umsg.End()
						end
					end
				end)
				timer.Simple(5.6/rate,function()
					if(IsValid(self))then
						self.DisplaysOn=Orig
						if(SERVER)then
							self.dt.Ammo=charge
							self.PowerType=powerType
							self.ConsumptionMul=consumptionMul
							self.HeatMul=heatMul
						end
						if(SERVER)then
							umsg.Start("JackysFGBoolChange")
							umsg.Entity(self)
							umsg.String("DisplaysOn")
							umsg.Bool(self.DisplaysOn)
							umsg.End()
						end
						if(NewType=="Self-Contained Micro Nuclear Fission Reactor")then self.Weapon:EmitSound("snd_jack_nuclearfgc_start.wav") end
						self:EmitSound("snd_jack_smallcharge.wav",65,100)
					end
				end)
				timer.Simple(6/rate,function()
					if(IsValid(self))then
						self.dt.State=2
					end
				end)
			end
		end)
		if(SERVER)then cartridge:Remove() end
	end
end
--- END OLD FUNGUNS CODE ---
--- OLD JACKY EXPLOSIVES CODE ---
local function Initialize()
	if(CLIENT)then
		local FontTable={
			font="DefaultFixedOutline",
			size=30,
			weight=1500,
			outline=true,
			antialias=true
		}
		surface.CreateFont("JackyDetGearFont",FontTable)
		FontTable.size=20
		surface.CreateFont("JackyDetGearFontSmall",FontTable)
	end
	JackieSplosivesFireMult=1
end
hook.Add("Initialize","JackySplosivesInitialize",Initialize)

local function Think()
	if(SERVER)then
		for key,playah in pairs(player.GetAll())do
			if(playah.JackyDetonatingOrdnance)then
				local Wap=playah:GetActiveWeapon()
				if(IsValid(Wap))then Wap:SendWeaponAnim(ACT_VM_DRAW) end
				if(math.random(1,15)==8)then playah:ViewPunch(Angle(math.Rand(-1,1),math.Rand(-.5,.5),math.Rand(-.1,.1))) end
			end
		end 
	end
end
hook.Add("Think","JackySplosivesThink",Think)

if(SERVER)then
	function JackyOrdnanceArm(item,playah,armType)
		local Num=playah:GetNetworkedInt("JackyDetGearCount")
		if(Num>0)then
			playah:SetNetworkedInt("JackyDetGearCount",Num-1)
			if(armType=="Remote")then
				numpad.OnDown(playah,KEY_PAD_0,"JackarundasRemoteOrdnanceDetonation")
			end
			item:EmitSound("snd_jack_ordnancearm.wav")
			JackyDetGearNotify(playah,"Set: "..armType)
			item.Armed=true
			if not(item.Owner)then item.Owner=playah end
		end
	end
	
	function JackyOrdnanceDisarm(item,playah,armType)
		if(item.Armed)then
			item:EmitSound("snd_jack_ordnancedisarm.wav")
			playah:SetNetworkedInt("JackyDetGearCount",math.Clamp(playah:GetNetworkedInt("JackyDetGearCount")+1,0,5))
			JackyDetGearNotify(playah,"")
		end
	end
	
	function JackySimpleOrdnanceArm(item,playah,message)
		playah:SetNetworkedInt("JackyDetGearCount",playah:GetNetworkedInt("JackyDetGearCount")-1)
		JackyDetGearNotify(playah,message)
		item:EmitSound("snd_jack_ordnancearm.wav")
		local Wap=playah:GetActiveWeapon()
		if(IsValid(Wap))then Wap:SendWeaponAnim(ACT_VM_DRAW) end
	end
	
	local function SetMult(ply,cmd,args)
		local Num=tonumber(args[1])
		if(Num)then
			print(args[1])
			JackieSplosivesFireMult=args[1]
			umsg.Start("JackieSplosivesFireMult")
			umsg.Short(args[1])
			umsg.End()
		end
	end
	concommand.Add("jackie_firemult",SetMult)

	local function RemoteOrdnanceDet(playah,cmd)
		if(playah.JackyDetonatingOrdnance)then return end
		local RemoteDetonatableItemTable={}
		for key,obj in pairs(ents.FindByClass("ent_jack_claymore"))do table.ForceInsert(RemoteDetonatableItemTable,obj) end
		for key,obj in pairs(ents.FindByClass("ent_jack_c4block"))do table.ForceInsert(RemoteDetonatableItemTable,obj) end
		--for key,obj in pairs(ents.FindByClass("ent_jack_firebomb"))do table.ForceInsert(RemoteDetonatableItemTable,obj) end
		local Items=0
		for key,item in pairs(RemoteDetonatableItemTable)do
			if not(item.Triggered)then
				if(item.Armed)then
					if(item.Owner==playah)then
						playah.JackyDetonatingOrdnance=true
						timer.Simple(1,function()
							if(IsValid(item))then
								item:Detonate()
								item.Triggered=true
							end
							timer.Simple(.65,function()
								if(IsValid(playah))then
									playah.JackyDetonatingOrdnance=false
								end
							end)
						end)
						Items=Items+1
					end
				end
			end
		end
		if(Items>0)then
			playah:EmitSound("snd_jack_detonator.wav")
			if(cmd)then
				umsg.Start("JackyDetSound",playah)
				umsg.End()
			end
		end
	end
	
	local function NumPadDet(ply) RemoteOrdnanceDet(ply,false) end
	numpad.Register("JackarundasRemoteOrdnanceDetonation",NumPadDet)
	
	local function ComDet(ply,cmd,args) RemoteOrdnanceDet(ply,true) end
	concommand.Add("jackie_rdet",ComDet)

	local function Remove(ply)
		ply:SetNetworkedInt("JackyDetGearCount",0)
	end
	hook.Add("DoPlayerDeath","JackyRemoveDetGearOnDeath",Remove)
	
	function JackyDetGearNotify(playah,message)
		umsg.Start("JackyDetGearNotify",playah)
		umsg.String(message)
		umsg.End()
	end
	
	local function Damage(target,dmginfo)
		if(target.AreJackyTailFins)then
			dmginfo:SetDamage(0)
			if(target:IsOnFire())then 
				timer.Simple(.1,function()
					if(IsValid(target))then target:Extinguish() end
				end)
			end
		end
	end
	hook.Add("EntityTakeDamage","JackySplosivesDamageHook",Damage)
elseif(CLIENT)then
	local function DetSound(data) surface.PlaySound("snd_jack_detonator.wav") end
	usermessage.Hook("JackyDetSound",DetSound)
	
	local function SetMult(data) JackieSplosivesFireMult=data:ReadShort() end
	usermessage.Hook("JackieSplosivesFireMult",SetMult)

	local JackyDetGearDraw=0
	local Pic=surface.GetTextureID("mat_jack_detgear_hud")
	local JackyDetGearMessage=""
	local NumberWordTable={}
	NumberWordTable[0]="Zero"
	NumberWordTable[1]="One"
	NumberWordTable[2]="Two"
	NumberWordTable[3]="Three"
	NumberWordTable[4]="Four"
	NumberWordTable[5]="Five"
	NumberWordTable[6]="Six"
	NumberWordTable[7]="Seven"
	NumberWordTable[8]="Eight"
	NumberWordTable[9]="Nine"
	NumberWordTable[10]="Ten"
	
	local function DetGearNotifyTrigger(data)
		JackyDetGearMessage=data:ReadString()
		JackyDetGearDraw=500
	end
	usermessage.Hook("JackyDetGearNotify",DetGearNotifyTrigger)
	
	local function DetGearNotify()
		if(JackyDetGearDraw>0)then
			local playah=LocalPlayer()
			local num=playah:GetNetworkedInt("JackyDetGearCount")
			if(num)then
				if(type(num)=="number")then --weird-ass-shit, bro
					if(LocalPlayer():Alive())then
						local Height=ScrH()
						local Width=ScrW()
						surface.SetTextColor(255,255,255,math.Clamp(JackyDetGearDraw,0,255))
						surface.SetFont("JackyDetGearFontSmall")
						surface.SetTextPos(Width*.81,Height*.36)
						surface.DrawText(JackyDetGearMessage)
						surface.SetDrawColor(255,255,255,math.Clamp(JackyDetGearDraw,0,255))
						surface.SetTexture(Pic)
						surface.DrawTexturedRect(Width*.75,Height*.4,256,256)
						surface.SetTextColor(255,255,255,math.Clamp(JackyDetGearDraw,0,255))
						surface.SetFont("JackyDetGearFont")
						surface.SetTextPos(Width*.82,Height*.75)
						surface.DrawText(NumberWordTable[num])
						JackyDetGearDraw=JackyDetGearDraw-1.5
					end
				end
			end
		end
	end
	hook.Add("HUDPaint","JackyDetGearNotifyPaint",DetGearNotify)
end
--- END OLD JACKY EXPLOSIVES CODE ---
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
	return ((Class=="prop_door")or(Class=="prop_door_rotating")or(Class=="func_door")or(Class=="func_door_rotating")or(Class=="func_breakable"))
end
--
local Hints={
	["crate"]="tap resource against to store \n press E to retrieve resource",
	["item crate"]="tap item against to store \n press E to retrieve item",
	["arm"]="alt+E to arm",
	["detpack det"]="chat *trigger* \n or concommand jmod_ez_trigger",
	["binding"]="remember, console commands can be bound to a key",
	["detpack stick"]="hold E on detpack then release E to stick the detpack",
	["slam stick"]="hold E on SLAM then release E to stick the SLAM",
	["timebomb stick"]="hold E on timebomb then release E to stick the timebomb",
	["detpack combo"]="detpacks can destroy props \n multiple combine for more power",
	["afh"]="E to enter and get healed",
	["fix"]="tap parts box against to repair",
	["supplies"]="tap supplies against to refill, tap parts against to repair",
	["ammobox"]="alt+E to refill ammo of any weapon",
	["antimatter"]="CAUTION EXTREMELY DANGEROUS VERY FRAGILE HANDLE WITH CARE",
	["eat"]="alt+E to consume",
	["friends"]="concommand jmod_friends to specify allies",
	["radio comm"]="radio needs to see sky",
	["upgrade"]="use Build Kit to upgrade",
	["jmod hands grab"]="RMB to grab objects",
	["jmod hands drag"]="move slowly to drag heavier objects (crouch/alt)",
	["jmod hands"]="RMB to block, R to put hands down",
	["jmod hands move"]="punches also can move you (jump boost/climbing)",
	["unpackage"]="double tap alt+E to unpackage",
	["crafting"]="set resources near workbench in order to use them",
	["building"]="stand near resources in order to use them",
	["grenade"]="ALT+E to pick up and arm grenade. LMB for hard throw, RMB for soft throw",
	["grenade remote"]="chat *trigger* \n or concommand jmod_ez_trigger",
	["disarm"]="tap E to disarm",
	["mininade"]="mininades can be stuck to larger explosives to trigger them",
	["armor"]="ALT+E to select color and wear armor",
	["armor remove"]="type *armor* or concommand jmod_ez_armor to unequip all armor",
	["mask"]="type *mask* or concommand jmod_ez_mask to toggle face equipment",
	["headset"]="type *headset* or concommand jmod_ez_headset to toggle ear equipment",
	["blasting machine"]="alt+E on the blasting machine to detonate the satchel charge",
	["bury"]="can only be buried in grass, dirt, snow or mud",
	["customize"]="To customize JMod, or to disable these hints, check out garrysmod/data/jmod_config.txt"
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

-- TODO
-- yeet a wrench easter egg
-- frickin like ADD npc factions to the whitelist yo, gosh damn
-- add the crate smoke flare