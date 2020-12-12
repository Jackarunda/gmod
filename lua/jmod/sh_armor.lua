--[[ ArmorSlots

	-- if damage is locational (bullets):

	HITGROUP_HEAD
		eyes (1/2 of hit if hit is from front)
		mouthnose (1/2 of hit if hit is from front)
		ears (nonprotective: receives damage but doesn't protect, 1/4)
		head (if hit angle isn't from front)
	HITGROUP_CHEST
		chest (all of HITGROUP_CHEST)
		back (nonprotective: receives damage but doesn't protect, 1/4)
	HITGROUP_STOMACH
		abdomen (all of HITGROUP_STOMACH)
	HITGROUP_LEFTLEG
		leftthigh (1/2)
		leftcalf (1/2)
	HITGROUP_RIGHTLEG
		rightthigh (1/2)
		rightcalf (1/2)
	HITGROUP_RIGHTARM
		rightbicep (1/2)
		rightforearm (1/2)
	HITGROUP_LEFTARM
		leftbicep (1/2)
		leftforearm (1/2)
	
--]]
-- support third-party backup armor repair recipes
JMod_BackupArmorRepairRecipes = JMod_BackupArmorRepairRecipes or {}

JMod_LocationalDmgTypes = {DMG_BULLET, DMG_BUCKSHOT, DMG_AIRBOAT, DMG_SNIPER}
JMod_FullBodyDmgTypes = {DMG_CRUSH, DMG_SLASH, DMG_BURN, DMG_VEHICLE, DMG_BLAST, DMG_CLUB, DMG_ACID, DMG_PLASMA}
JMod_BiologicalDmgTypes = {DMG_NERVEGAS, DMG_RADIATION}

JMod_BodyPartHealthMults = {
	-- HITGROUP_HEAD
	eyes = .05,
	mouthnose = .05,
	ears = 0,
	head = .18,
	-- HITGROUP_CHEST
	chest = .25,
	back = 0,
	-- HITGROUP_STOMACH
	abdomen = .1,
	pelvis = .05,
	-- HITGROUP_LEFTLEG
	leftthigh = .04,
	leftcalf = .04,
	-- HITGROUP_RIGHTLEG
	rightthigh = .04,
	rightcalf = .04,
	-- HITGROUP_RIGHTARM
	rightshoulder = .04,
	rightforearm = .04,
	-- HITGROUP_LEFTARM
	leftshoulder = .04,
	leftforearm = .04
}
JMod_ArmorSlotNiceNames={
	eyes="Eyes",
	mouthnose="Mouth & Nose",
	ears="Ears",
	head="Head",
	chest="Chest",
	back="Back",
	abdomen="Abdomen",
	pelvis="Pelvis",
	leftthigh="Left Thigh",
	leftcalf="Left Calf",
	rightthigh="Right Thigh",
	rightcalf="Right Calf",
	rightshoulder="Right Shoulder",
	rightforearm="Right Forearm",
	leftshoulder="Left Shoulder",
	leftforearm="Left Forearm"
}
JMod_BodyPartDamageMults={ -- only used if JMOD_CONFIG.QoL.RealisticLocationalDamage is true
	[HITGROUP_HEAD]=10,
	[HITGROUP_CHEST]=1,
	[HITGROUP_GENERIC]=1,
	[HITGROUP_STOMACH]=.5,
	[HITGROUP_GEAR]=.5,
	[HITGROUP_LEFTARM]=.2,
	[HITGROUP_RIGHTARM]=.2,
	[HITGROUP_LEFTLEG]=.2,
	[HITGROUP_RIGHTLEG]=.2
}
local BasicArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .999,
	[DMG_CLUB] = .99,
	[DMG_SLASH] = .99,
	[DMG_BULLET] = .98,
	[DMG_BLAST] = .95,
	[DMG_SNIPER] = .9,
	[DMG_AIRBOAT] = .85,
	[DMG_CRUSH] = .75,
	[DMG_VEHICLE] = .65,
	[DMG_BURN] = .65,
	[DMG_PLASMA] = .65,
	[DMG_ACID] = .55
}

local NonArmorProtectionProfile = {
	[DMG_BUCKSHOT] = .05,
	[DMG_BLAST] = .05,
	[DMG_BULLET] = .05,
	[DMG_SNIPER] = .05,
	[DMG_AIRBOAT] = .05,
	[DMG_CLUB] = .05,
	[DMG_SLASH] = .05,
	[DMG_CRUSH] = .05,
	[DMG_VEHICLE] = .05,
	[DMG_BURN] = .05,
	[DMG_PLASMA] = .05,
	[DMG_ACID] = .05
}

JMod_ArmorTable = {
	["GasMask"] = {
		PrintName = "Gas Mask",
		mdl = "models/splinks/kf2/cosmetics/gas_mask.mdl", -- kf2
		slots = {
			eyes = 1,
			mouthnose = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = 1,
			[DMG_RADIATION] = .5
		}, NonArmorProtectionProfile),
		dur = 2,
		chrg = {
			chemicals = 25
		},
		eff = {
			csprot = 1
		},
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(0, .1, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		mskmat = "mats_jack_gmod_sprites/vignette_gray.png",
		sndlop = "snds_jack_gmod/mask_breathe.wav",
		ent = "ent_jack_gmod_ezarmor_gasmask",
		tgl = {
			pos = Vector(3, 3, 0),
			ang = Angle(190, 180, 90),
			eff = {},
			mskmat = "",
			sndlop = "",
			def = NonArmorProtectionProfile,
			slots = {
				eyes = 0,
				mouthnose = 0
			}
		}
	},
	["BallisticMask"] = {
		PrintName = "Ballistic Mask",
		mdl = "models/jmod/ballistic_mask.mdl", -- csgo misc
		slots = {
			eyes = 1,
			mouthnose = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(100, 180, 90),
		wgt = 5,
		dur = 200,
		mskmat = "mats_jack_gmod_sprites/hard_vignette.png",
		ent = "ent_jack_gmod_ezarmor_balmask",
		tgl = {
			pos = Vector(-2, 4, 0),
			ang = Angle(170, 180, 90),
			mskmat = "",
			slots = {
				eyes = 0,
				mouthnose = 0
			}
		}
	},
	["NightVisionGoggles"] = {
		PrintName = "Goggles - Night Vision",
		mdl = "models/nvg.mdl", -- scp something
		slots = {
			eyes = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		entsiz = 1.5,
		pos = Vector(6.5, 2, 0),
		ang = Angle(-100, 0, 90),
		wgt = 5,
		dur = 2,
		chrg = {
			power = 25
		},
		mskmat = "mats_jack_gmod_sprites/vignette.png",
		eqsnd = "snds_jack_gmod/tinycapcharge.wav",
		ent = "ent_jack_gmod_ezarmor_nvgs",
		eff = {
			nightVision = true
		},
		blackvisionwhendead=true,
		tgl = {
			blackvisionwhendead=false,
			pos = Vector(6, 6, 0),
			ang = Angle(-130, 0, 90),
			mskmat = "",
			eff = {},
			slots = {
				eyes = 0
			}
		}
	},
	["ThermalGoggles"] = {
		PrintName = "Goggles - Thermal",
		mdl = "models/nvg.mdl", -- scp something
		slots = {
			eyes = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		entsiz = 1.5,
		pos = Vector(6.5, 2, 0),
		ang = Angle(-100, 0, 90),
		wgt = 5,
		dur = 2,
		chrg = {
			power = 25
		},
		mskmat = "mats_jack_gmod_sprites/vignette.png",
		eqsnd = "snds_jack_gmod/tinycapcharge.wav",
		ent = "ent_jack_gmod_ezarmor_thermals",
		eff = {
			thermalVision = true
		},
		blackvisionwhendead=true,
		tgl = {
			blackvisionwhendead=false,
			pos = Vector(6, 6, 0),
			ang = Angle(-130, 0, 90),
			mskmat = "",
			eff = {},
			slots = {
				eyes = 0
			}
		}
	},
	["Respirator"] = {
		PrintName = "Respirator",
		mdl = "models/jmod/respirator.mdl", -- MGSV
		slots = {
			mouthnose = 1
		},
		def = table.Inherit({
			[DMG_NERVEGAS] = .25,
			[DMG_RADIATION] = .5
		}, NonArmorProtectionProfile),
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1),
		pos = Vector(3.25, 1, 0),
		ang = Angle(100, 180, 90),
		chrg = {
			chemicals = 10
		},
		eff = {
			csprot = 0.5
		},
		wgt = 5,
		dur = 2,
		sndlop = "snds_jack_gmod/mask_breathe.wav",
		ent = "ent_jack_gmod_ezarmor_respirator",
		tgl = {
			def = NonArmorProtectionProfile,
			eff = {},
			slots = {
				mouthnose = 0
			},
			pos = Vector(3.25, -4, 0),
			ang = Angle(110, 180, 90),
			sndlop = ""
		}
	},
	["Headset"] = {
		PrintName = "Headset",
		mdl = "models/lt_c/sci_fi/headset_2.mdl", -- sci fi lt
		slots = {
			ears = 1
		},
		def = NonArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.2, 1.05, 1.1),
		pos = Vector(.5, 3, .1),
		ang = Angle(130, 0, 90),
		wgt = 5,
		dur = 2,
		chrg = {
			power = 10
		},
		ent = "ent_jack_gmod_ezarmor_headset",
		eff = {
			teamComms = true
		},
		tgl = {
			eff = {},
			slots = {
				ears = 0
			},
			pos = Vector(1.5, -2.5, .1),
			ang = Angle(100, 0, 90)
		}
	},
	["Light-Helmet"] = {
		PrintName = "Helmet - Light",
		mdl = "models/player/helmet_achhc_black/achhc_black.mdl", -- tarkov
		slots = {
			head = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.07, 1, 1.1),
		pos = Vector(1, -2, 0),
		ang = Angle(-90, 0, -90),
		wgt = 10,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_lhead"
	},
	["Medium-Helmet"] = {
		PrintName = "Helmet - Medium",
		mdl = "models/player/helmet_ulach_black/ulach.mdl", -- tarkov
		slots = {
			head = .9
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1, 1.05),
		pos = Vector(1, -2, 0),
		ang = Angle(-90, 0, -90),
		wgt = 15,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_mhead"
	},
	["Heavy-Helmet"] = {
		PrintName = "Helmet - Heavy",
		mdl = "models/player/helmet_psh97_jeta/jeta.mdl", -- tarkov
		slots = {
			head = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.1, 1, 1.1),
		pos = Vector(1, -3, 0),
		ang = Angle(-90, 0, -90),
		wgt = 20,
		dur = 300,
		ent = "ent_jack_gmod_ezarmor_hhead"
	},
	["Riot-Helmet"] = {
		PrintName = "Helmet - Riot",
		mdl = "models/jmod/helmet_riot_heavy.mdl", -- csgo
		slots = {
			head = 0.8,
			eyes = .9,
			mouthnose = .9
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1, 1, 1.1),
		pos = Vector(1, 3.5, 0),
		ang = Angle(-70, 0, -90),
		mskmat = "mats_jack_gmod_sprites/gray_translucent.png",
		wgt = 15,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_riot",
		bdg = {
			[0] = 0
		},
		tgl = {
			mskmat = "",
			slots = {
				head = 0.8,
				eyes=0,
				mouthnose=0
			},
			bdg = {
				[0] = 1
			}
		}
	},
	["Heavy-Riot-Helmet"] = {
		PrintName = "Helmet - Heavy Riot",
		mdl = "models/jmod/helmet_riot.mdl",
		slots = {
			head = 0.9,
			eyes = 1,
			mouthnose = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		mskmat = "mats_jack_gmod_sprites/gray_translucent.png",
		siz = Vector(1.1, 1, 1.1),
		pos = Vector(0, 1, 0),
		ang = Angle(-90, 0, -90),
		wgt = 25,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_rioth",
		bdg = {
			[1] = 0
		},
		tgl = {
			mskmat = "",
			slots = {
				head = 0.9,
				eyes=0,
				mouthnose=0
			},
			bdg = {
				[1] = 1
			}
		}
	},
	["Ultra-Heavy-Helmet"] = {
		PrintName = "Helmet - UltraHeavy",
		mdl = "models/jmod/helmet_maska.mdl", -- tarkov
		slots = {
			head = 1,
			eyes = 1,
			mouthnose = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Head1",
		siz = Vector(1.05, 1.05, 1.05),
		pos = Vector(1.5, -2, 0),
		ang = Angle(-80, 0, -90),
		wgt = 35,
		dur = 400,
		mskmat = "mats_jack_gmod_sprites/slit_vignette.png",
		ent = "ent_jack_gmod_ezarmor_maska",
		bdg = {
			[1] = 0
		},
		tgl = {
			slots = {
				head = 1,
				eyes=0,
				mouthnose=0
			},
			bdg = {
				[1] = 1
			},
			mskmat = ""
		}
	},
	["Light-Vest"] = {
		PrintName = "Vest - Light",
		mdl = "models/player/armor_paca/paca.mdl", -- tarkov
		slots = {
			chest = .8,
			abdomen = .5
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1, 1.05, .9),
		pos = Vector(-2.5, -4.5, 0),
		ang = Angle(-90, 0, 90),
		wgt = 5,
		dur = 350,
		ent = "ent_jack_gmod_ezarmor_ltorso",
		gayPhysics = true
	},
	["Medium-Light-Vest"] = {
		PrintName = "Vest - Medium-Light",
		mdl = "models/player/armor_trooper/trooper.mdl", -- tarkov
		slots = {
			chest = .85,
			abdomen = .6
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, .95),
		pos = Vector(-3, -4.5, 0),
		ang = Angle(-90, 0, 90),
		wgt = 10,
		dur = 450,
		ent = "ent_jack_gmod_ezarmor_mltorso",
		gayPhysics = true
	},
	["Medium-Vest"] = {
		PrintName = "Vest - Medium",
		mdl = "models/player/armor_gjel/gjel.mdl", -- tarkov
		slots = {
			chest = .9,
			abdomen = .7
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, 1),
		pos = Vector(-2.5, -7, 0),
		ang = Angle(-90, 0, 90),
		wgt = 20,
		dur = 575,
		ent = "ent_jack_gmod_ezarmor_mtorso",
		gayPhysics = true
	},
	["Medium-Heavy-Vest"] = {
		PrintName = "Vest - Medium-Heavy",
		mdl = "models/player/armor_6b13_killa/6b13_killa.mdl", -- tarkov
		slots = {
			chest = .95,
			abdomen = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(1.05, 1.05, 1),
		pos = Vector(-4.5, -12, 0),
		ang = Angle(-85, 0, 90),
		wgt = 40,
		dur = 650,
		ent = "ent_jack_gmod_ezarmor_mhtorso",
		gayPhysics = true
	},
	["Heavy-Vest"] = {
		PrintName = "Vest - Heavy",
		mdl = "models/jmod/heavy_armor.mdl", -- csgo hydra
		slots = {
			chest = 1,
			abdomen = .9
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Spine2",
		siz = Vector(.9, .9, 1),
		pos = Vector(-3, 2.5, 0),
		ang = Angle(-85, 0, 90),
		wgt = 80,
		dur = 700,
		ent = "ent_jack_gmod_ezarmor_htorso"
	},
	["Pelvis-Panel"] = {
		PrintName = "Pelvis Panel",
		mdl = "models/jmod/pelviscover.mdl", -- csgo misc
		slots = {
			pelvis = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_Pelvis",
		siz = Vector(1.5, 1.4, 1.8),
		pos = Vector(6, 0, 5),
		ang = Angle(90, -90, 0),
		wgt = 10,
		dur = 350,
		ent = "ent_jack_gmod_ezarmor_spelvis"
	},
	["Light-Left-Shoulder"] = {
		PrintName = "Shoulder - Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlbicep.mdl", -- aegis
		slots = {
			leftshoulder = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 0, -.5),
		ang = Angle(-90, -90, -90),
		wgt = 5,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_llshoulder"
	},
	["Heavy-Left-Shoulder"] = {
		PrintName = "Shoulder - Heavy (L)",
		mdl = "models/jmod/heavy_left_armor_pad.mdl", -- csgo hydra
		slots = {
			leftshoulder = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(90, -20, 90),
		wgt = 15,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_hlshoulder"
	},
	["Light-Right-Shoulder"] = {
		PrintName = "Shoulder - Light (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrbicep.mdl", -- aegis
		slots = {
			rightshoulder = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 0, .5),
		ang = Angle(-90, -90, -90),
		wgt = 5,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_lrshoulder"
	},
	["Heavy-Right-Shoulder"] = {
		PrintName = "Shoulder - Heavy (R)",
		mdl = "models/jmod/heavy_right_armor_pad.mdl", -- csgo hydra
		slots = {
			rightshoulder = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_UpperArm",
		siz = Vector(1, 1, 1),
		pos = Vector(0, 4, 0),
		ang = Angle(90, 20, 90),
		wgt = 15,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_hrshoulder"
	},
	["Left-Forearm"] = {
		PrintName = "Forearm (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlforearm.mdl", -- aegis
		slots = {
			leftforearm = .95
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Forearm",
		siz = Vector(1.1, 1, 1),
		pos = Vector(0, 0, -.5),
		ang = Angle(0, -90, -50),
		wgt = 10,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_slforearm",
		gayPhysics = true
	},
	["Right-Forearm"] = {
		PrintName = "Forearm (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrforearm.mdl", -- aegis
		slots = {
			rightforearm = .95
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Forearm",
		siz = Vector(1.1, 1, 1),
		pos = Vector(-.5, 0, .5),
		ang = Angle(0, -90, 50),
		wgt = 10,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_srforearm",
		gayPhysics = true
	},
	["Light-Left-Thigh"] = {
		PrintName = "Thigh - Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlthigh.mdl", -- aegis
		slots = {
			leftthigh = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Thigh",
		siz = Vector(.9, 1, 1.05),
		pos = Vector(-.5, 0, -1.5),
		ang = Angle(90, -85, 110),
		wgt = 10,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_llthigh",
		gayPhysics = true
	},
	["Heavy-Left-Thigh"] = {
		PrintName = "Thigh - Heavy (L)",
		mdl = "models/jmod/heavy_left_thigh_armor.mdl", -- csgo hydra
		slots = {
			leftthigh = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Thigh",
		siz = Vector(0.9, 1, 1),
		pos = Vector(2, 10, 0),
		ang = Angle(-90, 180, 0),
		wgt = 25,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_hlthigh"
	},
	["Light-Right-Thigh"] = {
		PrintName = "Thigh - Light (L)",
		mdl = "models/snowzgmod/payday2/armour/armourrthigh.mdl", -- aegis
		slots = {
			rightthigh = .8
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Thigh",
		siz = Vector(.9, 1, 1.05),
		pos = Vector(.5, 0, 1),
		ang = Angle(90, -95, 80),
		wgt = 10,
		dur = 150,
		ent = "ent_jack_gmod_ezarmor_lrthigh",
		gayPhysics = true
	},
	["Heavy-Right-Thigh"] = {
		PrintName = "Thigh - Heavy (R)",
		mdl = "models/jmod/heavy_right_thigh_armor.mdl", -- csgo hydra
		slots = {
			rightthigh = 1
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Thigh",
		siz = Vector(0.9, 1, 1),
		pos = Vector(2, 10, 0),
		ang = Angle(-90, 180, 0),
		wgt = 25,
		dur = 200,
		ent = "ent_jack_gmod_ezarmor_hrthigh"
	},
	["Left-Calf"] = {
		PrintName = "Calf (L)",
		mdl = "models/snowzgmod/payday2/armour/armourlcalf.mdl", -- aegis
		slots = {
			leftcalf = .95
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_L_Calf",
		siz = Vector(1, 1, 1),
		pos = Vector(-1.5, -1, -.5),
		ang = Angle(-180, -83, -180),
		wgt = 15,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_slcalf"
	},
	["Right-Calf"] = {
		PrintName = "Calf (R)",
		mdl = "models/snowzgmod/payday2/armour/armourrcalf.mdl", -- aegis
		slots = {
			rightcalf = .95
		},
		def = BasicArmorProtectionProfile,
		bon = "ValveBiped.Bip01_R_Calf",
		siz = Vector(1, 1, 1),
		pos = Vector(-1.5, -1, .5),
		ang = Angle(-180, -83, -180),
		wgt = 15,
		dur = 250,
		ent = "ent_jack_gmod_ezarmor_srcalf"
	}
}

-- Dynamically generate armor ents
function JMod_GenerateArmorEntities(tbl)
	for class, info in pairs(tbl) do
		if info.noent then continue end
		local armorent = {}
		armorent.Base = "ent_jack_gmod_ezarmor"
		armorent.PrintName = info.PrintName or class
		armorent.Spawnable = info.Spawnable or true
		armorent.AdminOnly = info.AdminOnly or false
		armorent.Category = info.Category or "JMod - EZ Armor"
		armorent.ArmorName = class
		armorent.ModelScale = info.gayPhysics and nil or (info.entsiz or math.max(info.siz.x, info.siz.y, info.siz.z))
		scripted_ents.Register( armorent, info.ent )
	end
end
JMod_GenerateArmorEntities(JMod_ArmorTable)

-- support third-party additions to the jmod armor table
local function LoadAdditionalArmor()
	if JMod_AdditionalArmorTable then
		table.Merge(JMod_ArmorTable, JMod_AdditionalArmorTable)
		JMod_GenerateArmorEntities(JMod_AdditionalArmorTable)
	end
end
hook.Add("Initialize","JMod_LoadAdditionalArmor", LoadAdditionalArmor)

hook.Add("SetupMove", "JMOD_ARMOR_MOVE", function(ply, mv, cmd)
	if (ply.EZarmor and ply.EZarmor.speedfrac and ply.EZarmor.speedfrac ~= 1) then
		local origSpeed = (cmd:KeyDown(IN_SPEED) and ply:GetRunSpeed()) or ply:GetWalkSpeed()
		mv:SetMaxClientSpeed(origSpeed * ply.EZarmor.speedfrac)
	end
end)

-- Debug
for _, ply in pairs(player.GetAll()) do
	ply.NextEZarmorTableCopy = 0
end
LoadAdditionalArmor()