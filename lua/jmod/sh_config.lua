local function SetArmorPlayerModelModifications()
	JMod.LuaConfig.ArmorOffsets["models/player/urban.mdl"]={
		["GasMask"]={
			siz=Vector(1,1,1),
			pos=Vector(0,1.7,0),
			ang=Angle(100,180,90)
		}
	}
end
function JMod.InitGlobalConfig(forceNew)
	local NewConfig={
		Author="Jackarunda",
		Version=37,
		Note="radio packages must have all lower-case names, see http://wiki.garrysmod.com/page/Enums/IN for key numbers",
		Hints=true,
		AltFunctionKey=IN_WALK,
		SentryPerformanceMult=1,
		ToolboxDeconstructSpeedMult=1,
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
		ToolboxDeWeldSpeed=1,
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
			ResourceRichness=1,
			ExtractionSpeed=1
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
			StartingOutpostCount=1,
			AvailablePackages={
				["arms"]={
					"buncha random guns, good luck getting what you want.",
					{
						"RAND",
						"ent_jack_gmod_ezweapon_pistol",
						"ent_jack_gmod_ezweapon_ar",
						"ent_jack_gmod_ezweapon_bar",
						"ent_jack_gmod_ezweapon_br",
						"ent_jack_gmod_ezweapon_car",
						"ent_jack_gmod_ezweapon_dmr",
						"ent_jack_gmod_ezweapon_sr",
						"ent_jack_gmod_ezweapon_amsr",
						"ent_jack_gmod_ezweapon_sas",
						"ent_jack_gmod_ezweapon_pas",
						"ent_jack_gmod_ezweapon_bas",
						"ent_jack_gmod_ezweapon_pocketpistol",
						"ent_jack_gmod_ezweapon_plinkingpistol",
						"ent_jack_gmod_ezweapon_machinepistol",
						"ent_jack_gmod_ezweapon_smg",
						"ent_jack_gmod_ezweapon_lmg",
						"ent_jack_gmod_ezweapon_mmg",
						"ent_jack_gmod_ezweapon_magrevolver",
						"ent_jack_gmod_ezweapon_magpistol",
						"ent_jack_gmod_ezweapon_revolver",
						"ent_jack_gmod_ezweapon_shotrevolver",
						"ent_jack_gmod_ezweapon_lac",
						"ent_jack_gmod_ezweapon_ssr",
						"ent_jack_gmod_ezweapon_amr",
						"ent_jack_gmod_ezweapon_fas",
						"ent_jack_gmod_ezweapon_gl",
						"ent_jack_gmod_ezweapon_mgl",
						"ent_jack_gmod_ezweapon_rocketlauncher",
						"ent_jack_gmod_ezweapon_mrl",					
						3
					},
					{"ent_jack_gmod_ezammo",2},
					"ent_jack_gmod_ezmunitions"
				},
				["armor"]={
					"A random collection of armor*. *Jackarunda Industries outsources package sorting. We are not liable for any unusual items.",
					{
						"RAND",
						JMod.ArmorTable["GasMask"].ent,
						JMod.ArmorTable["BallisticMask"].ent,
						JMod.ArmorTable["NightVisionGoggles"].ent,
						JMod.ArmorTable["ThermalGoggles"].ent,
						JMod.ArmorTable["Respirator"].ent,
						JMod.ArmorTable["Light-Helmet"].ent,
						JMod.ArmorTable["Medium-Helmet"].ent,
						JMod.ArmorTable["Heavy-Helmet"].ent,
						JMod.ArmorTable["Riot-Helmet"].ent,
						JMod.ArmorTable["Heavy-Riot-Helmet"].ent,
						JMod.ArmorTable["Ultra-Heavy-Helmet"].ent,
						JMod.ArmorTable["Metal Bucket"].ent,
						JMod.ArmorTable["Metal Pot"].ent,
						JMod.ArmorTable["Ceramic Pot"].ent,
						JMod.ArmorTable["Traffic Cone"].ent,
						JMod.ArmorTable["Light-Vest"].ent,
						JMod.ArmorTable["Medium-Light-Vest"].ent,
						JMod.ArmorTable["Medium-Vest"].ent,
						JMod.ArmorTable["Medium-Heavy-Vest"].ent,
						JMod.ArmorTable["Heavy-Vest"].ent,
						JMod.ArmorTable["Pelvis-Panel"].ent,
						JMod.ArmorTable["Light-Left-Shoulder"].ent,
						JMod.ArmorTable["Heavy-Left-Shoulder"].ent,
						JMod.ArmorTable["Light-Right-Shoulder"].ent,
						JMod.ArmorTable["Heavy-Right-Shoulder"].ent,
						JMod.ArmorTable["Left-Forearm"].ent,
						JMod.ArmorTable["Right-Forearm"].ent,
						JMod.ArmorTable["Light-Left-Thigh"].ent,
						JMod.ArmorTable["Heavy-Left-Thigh"].ent,
						JMod.ArmorTable["Light-Right-Thigh"].ent,
						JMod.ArmorTable["Heavy-Right-Thigh"].ent,
						JMod.ArmorTable["Left-Calf"].ent,
						JMod.ArmorTable["Right-Calf"].ent,
						JMod.ArmorTable["Hazmat Suit"].ent,
						6
					}
				},
				["crossbow"]={
					"A crossbow and 2 boxes of arrows, enjoy.",
					{"ent_jack_gmod_ezammobox_a",2},
                    "ent_jack_gmod_ezweapon_crossbow"
				},
                ["black powder weaponry"]={
					"Beginner weaponry, the mucket, cap 'n ball revolver and blunderbuss, with some boxes of ammo.",
					{"ent_jack_gmod_ezammobox_bppc",3},
                    "ent_jack_gmod_ezweapon_flm",
                    "ent_jack_gmod_ezweapon_cabr",
                    "ent_jack_gmod_ezweapon_flb"
				},
                ["basic parts"]={
					"3 boxes of parts used for crafting and repairs.",
					{"ent_jack_gmod_ezbasicparts",3}
				},
				["advanced parts"]={
					"1 box of advparts used for crafting and upgrading.",
					{"ent_jack_gmod_ezadvparts",1,20}
				},
                ["precision parts"]={
					"1 box of precision parts used for advanced parts, advanced textiles, and weapons.",
					"ent_jack_gmod_ezprecparts"
				},
				["advanced textiles"]={
					"1 box of advtextiles used for armor.",
					"ent_jack_gmod_ezadvtextiles"
				},
				["batteries"]={
					"4 battery cells used for crafting and recharging electronics.",
					{"ent_jack_gmod_ezbattery",4}
				},
				["ammo"]={
					"3 boxes of ammo for crafting and resupplying weapons and entities.",
					{"ent_jack_gmod_ezammo",3}
				},
				["coolant"]={
					"5 bottles of coolant for preventing machines from overheating.",
					{"ent_jack_gmod_ezcoolant",5}
				},
				["munitions"]={
					"2 boxes of munitions used for crafting items and reloading explosive weapons and HE grenade sentries.",
					{"ent_jack_gmod_ezmunitions",2}
				},
				["explosives"]={
					"2 boxes of explosives used for crafting explosives.",
					{"ent_jack_gmod_ezexplosives",2}
				},
				["chemicals"]={
					"2 boxes of chemicals used for crafting items and reloading filters in HAZMAT suits, gasmasks, and respirators.",
					{"ent_jack_gmod_ezchemicals",2}
				},
				["fuel"]={
					"4 cans of fuel used for crafting items and running generators.",
					{"ent_jack_gmod_ezfuel",4}
				},
				["propellant"]={
					"4 cans of propellant used for crafting items.",
					{"ent_jack_gmod_ezpropellant",4}
				},
				["gas"]={
					"3 canisters of gas used for crafting items and powering the EZ Workbench",
					{"ent_jack_gmod_ezgas",3}
				},
				["toolboxes"]={
					"Two toolboxes for crafting, nailing, salvaging and packaging items. ",
					{"ent_jack_gmod_eztoolbox",2}
				},
				["rations"]={
					 "5 boxes of nutrients to be eaten by players. Can overcharge health.",
					{"ent_jack_gmod_eznutrients",5}
				},
				["medical supplies"]={
					 "Two boxes of medical supplies for resupplying the EZ Automated Field Hospital.",
					{"ent_jack_gmod_ezmedsupplies",2}
				},
				["resource crate"]={
					"A box used for exclusively storing EZ Resources.",
					"ent_jack_gmod_ezcrate"
				},
				["storage crate"]={
					"A box used exclusively for storing Jmod items. Can hold a volume of up to 100 units.",
					"ent_jack_gmod_ezcrate_uni"
				},
				["frag grenades"]={
					"10 frag grenades used for explosions.",
					{"ent_jack_gmod_ezfragnade",10}
				},
				["gas grenades"]={
					"6 gas grenades that can suffocate their victims.",
					{"ent_jack_gmod_ezgasnade",6}
				},
				["tear gas grenades"]={
					"Tear gas used to disperse riots.",
					{"ent_jack_gmod_ezcsnade",6}
				},
				["impact grenades"]={
					"10 grenades that explode upon impact.",
					{"ent_jack_gmod_ezimpactnade",10}
				},
				["incendiary grenades"]={
					"6 grenades that produce fire upon explosion.",
					{"ent_jack_gmod_ezfirenade",6}
				},
				["satchel charges"]={
					"4 explosives with comical detonator plungers used for making things go boom.",
					{"ent_jack_gmod_ezsatchelcharge",4}
				},
				["sticky bomb"]={
					"6 grenades that stick to things on contact.",
					{"ent_jack_gmod_ezstickynade",6}
				},
				["mini grenades"]={
					"5 impact, proximity, remote, and timed grenades. These can be attached to larger explosives to override their primary functions.",
					{"ent_jack_gmod_eznade_impact",5},
					{"ent_jack_gmod_eznade_proximity",5},
					{"ent_jack_gmod_eznade_remote",5},
					{"ent_jack_gmod_eznade_timed",5}
					
				},
				["timebombs"]={
					"Timed explosives with configurable timers. Can be defused with parts and Toolbox.",
					{"ent_jack_gmod_eztimebomb",3}
				},
				["hl2 ammo"]={
					"An assortment of ammunition for keeping your men going during battle.",
					"item_ammo_357","item_ammo_357_large","item_ammo_ar2","item_ammo_ar2_large",
					{"item_ammo_ar2_altfire",3},
					"item_ammo_crossbow","item_ammo_pistol","item_ammo_pistol_large",
					{"item_rpg_round",3},
					"item_box_buckshot","item_ammo_smg1","item_ammo_smg1_large",
					{"item_ammo_smg1_grenade",3},
					{"weapon_frag",3}
				},
				["sentry"]={
					"Shoots enemies so you don't have to! Just remember to refill the ammo and power.",
					"ent_jack_gmod_ezsentry"
				},
				["supply radio"]={
					"You're looking at one. No shame in having a backup radio.",
					"ent_jack_gmod_ezaidradio"
				},
				["medkits"]={
					"3 medical kits that use medical supplies to heal players.",
					{"ent_jack_gmod_ezmedkit",3}
				},
				["landmines"]={
					"10 landmines that trigger when an enemy steps near them.",
					{"ent_jack_gmod_ezlandmine",10}
				},
				["mini bounding mines"]={
					"8 landmines that can only be planted in soft surfaces.",
					{"ent_jack_gmod_ezboundingmine",8}
				},
				["fumigators"]={
					"2 fumigators that emit poison gas.",
					{"ent_jack_gmod_ezfumigator",2}
				},
				["fougasse mines"]={
					"4 fougasse mines. Blasts napalm at whoever triggers it.",
					{"ent_jack_gmod_ezfougasse",4}
				},
				["detpacks"]={
					"8 detpacks used for breaching doors and general explosive damage.",
					{"ent_jack_gmod_ezdetpack",8}
				},
				["slams"]={
					"5 SLAMs that can be planted on walls.",
					{"ent_jack_gmod_ezslam",5}
				},
				["antimatter"]={
					"A can of antimatter. Be careful with it, unless you want to evaporate everything within 20km!",
					"ent_jack_gmod_ezantimatter"
				},
				["fissile material"]={
					"A box filled with fissile material used to craft nuclear devices.",
					"ent_jack_gmod_ezfissilematerial"
				},
				["dynamite"]={
					"12 dynamite sticks for comical explosions.",
					{"ent_jack_gmod_ezdynamite",12}
				},
				["flashbangs"]={
					"8 flashbangs that stun targets.",
					{"ent_jack_gmod_ezflashbang",8}
				},
				["powder kegs"]={
					"4 powder kegs for funny explosions.",
					{"ent_jack_gmod_ezpowderkeg",4}
				},
				["smoke grenades"]={	
					"4 smoke grenades to signal smokes and 4 signal grenades which emit a colourable smoke to help signal positions.",
					{"ent_jack_gmod_ezsmokenade",4},
					{"ent_jack_gmod_ezsignalnade",4}
				},
				["stick grenades"]={
					"4 German stick grenades and one big bundle of sticks to make a fabulous explosion.",
					{"ent_jack_gmod_ezsticknade",4},
					"ent_jack_gmod_ezsticknadebundle"

				},
				["mini claymores"]={
					"4 small AP mines.",
					{"ent_jack_gmod_ezminimore",4}
				},
				["tnt"]={
					"WW2-era explosives with fuse.",
					{"ent_jack_gmod_eztnt", 3}
				},
				["thermal goggles"]={
					"2 thermal goggles that highlight heat-sources for the user. Consumes battery.",
					{"ent_jack_gmod_ezarmor_thermals",2}
				},
				["night vision goggles"]={
					"4 night-vision goggles to help players see in the dark. Consumes battery.",
					{"ent_jack_gmod_ezarmor_nvgs",4}
				},
				["headsets"]={
					"8 headsets for players to communicate and make orders from linked radios. Consumes battery.",
					{"ent_jack_gmod_ezarmor_headset",8}
				},
                ["steel"]={
					"Steel in a quantity of 200, used in basic parts and some weapons.",
					{"ent_jack_gmod_ezsteel",2}
				},
                ["copper"]={
					"Copper in a quantity of 100, used in basic parts.",
					"ent_jack_gmod_ezcopper"
				},
                ["aluminum"]={
					"Aluminum in a quantity of 200, used in basic parts.",
					{"ent_jack_gmod_ezaluminum",2}
				},
                ["lead"]={
					"Lead in a quantity of 200, very useful in ammo production for fending off other players.",
					{"ent_jack_gmod_ezlead",2}
				},
                ["silver"]={
					"Silver in a quantity of 50, used for high tier stuff.",
					{"ent_jack_gmod_ezsilver",1,50}
				},
                ["gold"]={
					"Gold in a quantity of 20, used in advanced parts.",
					{"ent_jack_gmod_ezgold",1,20}
				},
                ["titanium"]={
					"Titanium in a quantity of 50, used in high-tier weaponry.",
					{"ent_jack_gmod_eztitanium",1,50}
				},
                ["tungsten"]={
					"Tungsten in a quantity of 50, used in high-tier weaponry.",
					{"ent_jack_gmod_eztungsten",1,50}
				},
                ["platinum"]={
					"Platinum in a quantity of 10, used in advanced parts.",
					{"ent_jack_gmod_ezplatinum",1,10}
				},
                ["uranium"]={
					"Uranium in a quantity of 20, used in fissile material enrichment.",
					{"ent_jack_gmod_ezuranium",1,20}
				},
                ["diamond"]={
					"diamond in a quantity of 10, used in advanced parts.",
					{"ent_jack_gmod_ezdiamond",1,10}
				},
                ["water"]={
					"Water in a quantity of 300, used in coolant, chemicals, and nutrients.",
					{"ent_jack_gmod_ezwater",3}
				},
                ["wood"]={
					"Wood in a quantity of 200, used in paper and electricity production.",
					{"ent_jack_gmod_ezwood",2}
				},
                ["paper"]={
					"Paper in a quantity of 200, used in nutrients.",
					{"ent_jack_gmod_ezpaper",2}
				},
                ["plastic"]={
					"Plastic in a quantity of 200, used in basic parts.",
					{"ent_jack_gmod_ezplastic",2}
				},
                ["organics"]={
					"Organics in a quantity of 200, used in nutrients.",
					{"ent_jack_gmod_ezorganics",2,100}
				},
                ["oil"]={
					"Oil in a quantity of 100, used in plastic, fuel, and rubber.",
					"ent_jack_gmod_ezoil"
				},             
                ["cloth"]={
					"Cloth in a quantity of 200, used in advanced textiles.",
					{"ent_jack_gmod_ezcloth",2}
				},
                ["rubber"]={
					"Rubber in a quantity of 200, used in basic parts.",
					{"ent_jack_gmod_ezrubber",2}
				},
                ["glass"]={
					"Glass in a quantity of 200, used in basic parts.",
					{"ent_jack_gmod_ezglass",2}
				},
                
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
                    [JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50,
                    [JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES]=200
                },
				2,
				"Machines",
				"Heals players so you don't have to get more blood on you."
			},
			["EZ Big Bomb"]={
				"ent_jack_gmod_ezbigbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.STEEL]=190,
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=600
				},
				1.5,
				"Explosives",
				"Bigger than the EZ bomb, but smaller than the Mega."
			},	
			["EZ Bomb"]={			
				"ent_jack_gmod_ezbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.STEEL]=140,
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
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
					[JMod.EZ_RESOURCE_TYPES.WOOD]=50	
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
					[JMod.EZ_RESOURCE_TYPES.FUEL]=300,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=20
				},
				1,
				"Explosives",
				"Fire bomb. Detonates in the air to ensure max spread of napalm."
			},	
			["EZ Mega Bomb"]={			
				"ent_jack_gmod_ezmoab",		
				{
					[JMod.EZ_RESOURCE_TYPES.STEEL]=380,
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
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
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.POWER]=600,
					[JMod.EZ_RESOURCE_TYPES.ANTIMATTER]=25
				},
				1.5,
				"Machines",
				"Takes a couple minutes to spin up, and then creates an impossibly weak black hole."
			},	
			["EZ Micro Nuclear Bomb"]={			
				"ent_jack_gmod_eznuke",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=300,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=300,
					[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]=50
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
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=150,
					[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]=25
				},
				1,
				"Explosives",
				"as the Mega bomb, while also having radiation as a bonus."
			},
			["EZ Resource Crate"]={
				"ent_jack_gmod_ezcrate",
				{
					[JMod.EZ_RESOURCE_TYPES.WOOD]=100	
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
					[JMod.EZ_RESOURCE_TYPES.AMMO]=100,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
				},
				1,
				"Machines",
				"Shoots enemies so you don't have to! Just remember to refill the ammo and power."
			},	
			["EZ Small Bomb"]={			
				"ent_jack_gmod_ezsmallbomb",		
				{	
					[JMod.EZ_RESOURCE_TYPES.STEEL]=140,
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
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
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=25	
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
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=300
				},
				1,
				"Explosives",
				"Bunker buster, will cause more damage if you place it indoors."
			},	
			["EZ Thermonuclear Bomb"]={			
				"ent_jack_gmod_eznuke_big",		
				{	
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=400,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=600,
					[JMod.EZ_RESOURCE_TYPES.FISSILEMATERIAL]=200
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
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
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
					[JMod.EZ_RESOURCE_TYPES.STEEL]=300,
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=200,
					[JMod.EZ_RESOURCE_TYPES.POWER]=50,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=300,
					[JMod.EZ_RESOURCE_TYPES.AMMO]=200
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
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=50,
					[JMod.EZ_RESOURCE_TYPES.LEAD]=25
				},
				"Resources",
				"General purpose bullets. Don't ask how we got so many types of ammo in one box."
			},
		    ["EZ Black Powder Paper Cartridges"]={			
				"ent_jack_gmod_ezammobox_bppc",
				{	
					[JMod.EZ_RESOURCE_TYPES.PAPER]=20,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=25,
					[JMod.EZ_RESOURCE_TYPES.LEAD]=20
				},
				"Resources",
				"for ye olde black powder weapons so you can dispatch scoundrels rightly"
			},
		    ["EZ Arrows"]={			
				"ent_jack_gmod_ezammobox_a",
				{	
					[JMod.EZ_RESOURCE_TYPES.STEEL]=15,
					[JMod.EZ_RESOURCE_TYPES.PLASTIC]=15
				},
				"Resources",
				"modern broadhead hunting arrows for maximum yeeting"
			},
			["EZ Flintlock Musket"]={
                JMod.WeaponTable["Flintlock Musket"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.STEEL]=25,
                    [JMod.EZ_RESOURCE_TYPES.WOOD]=25
                },
                "Weapons",
                "Ol' fashioned musket, kinda inaccurate"
            },
			["EZ Cap and Ball Revolver"]={
                JMod.WeaponTable["Cap and Ball Revolver"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
                    [JMod.EZ_RESOURCE_TYPES.STEEL]=10,
                    [JMod.EZ_RESOURCE_TYPES.WOOD]=5
                },
                "Weapons",
                "A very inaccurate revolver. Fires 6 shots."
            },
			["EZ Break-Action Shotgun"]={
                JMod.WeaponTable["Break-Action Shotgun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
                    [JMod.EZ_RESOURCE_TYPES.WOOD]=25
                },
                "Weapons",
                "A double barrel O/U shotgun."
            },
			["EZ Revolver"]={
                JMod.WeaponTable["Revolver"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
                    [JMod.EZ_RESOURCE_TYPES.WOOD]=5
                },
                "Weapons",
                "A simple revolver. Fires 6 shots"
            },
			["EZ Single-Shot Rifle"]={
                JMod.WeaponTable["Single-Shot Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=75,
                    [JMod.EZ_RESOURCE_TYPES.WOOD]=25
                },
                "Weapons",
                "A simple rifle. Fires one bullet at a time."
            },
			["EZ Crossbow"]={
                JMod.WeaponTable["Crossbow"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
                },
                "Weapons",
                "A crossbow. Can be very efficient if you hit all your shots."
            },
			["EZ Bolt-Action Rifle"]={
                JMod.WeaponTable["Bolt-Action Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=125
                },
                "Weapons",
                "A bolt action rifle. First practical high-power repeating rifle."
            },
			["EZ Lever-Action Carbine"]={
                JMod.WeaponTable["Lever-Action Carbine"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.WOOD]=20
                },
                "Weapons",
                "A Lever action carbine, less power than bolt action rifle, but more ammo."
            },
			["EZ Magnum Revolver"]={
                JMod.WeaponTable["Magnum Revolver"].ent,
                {
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=75,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=10
                },
                "Weapons",
                "Revolver, but with a more powerful round."
            },
			["EZ Pump-action Shotgun"]={
                JMod.WeaponTable["Pump-Action Shotgun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=125,
                },
                "Weapons",
                "Pump action shotgun, More shotgun shells."
            },
			["EZ Shot Revolver"]={
                JMod.WeaponTable["Shot Revolver"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
                },
                "Weapons",
                "Small shotgun, ready to tear faces off at very close range."
            },
			["EZ Grenade Launcher"]={
                JMod.WeaponTable["Grenade Launcher"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=125,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=10
                },
                "Weapons",
                "First grenade launcher. A single grenade to turn shit into scrap."
            },
			["EZ Pistol"]={
                JMod.WeaponTable["Pistol"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=75,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=25
                },
                "Weapons",
                "A pistol. Great sidearm to have."
            },
			["EZ Plinking Pistol"]={
                JMod.WeaponTable["Plinking Pistol"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=10
                },
                "Weapons",
                "A plinking pistol. Great if you want to deal with that bird that's annoying you."
            },
			["EZ Sniper Rifle"]={
                JMod.WeaponTable["Sniper Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A sniper rifle. Pick off targets at long range."
            },
			["EZ Pocket Pistol"]={
                JMod.WeaponTable["Pocket Pistol"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=25
                },
                "Weapons",
                "A pocket pistol. It's concealable, allowing you to seem unarmed to others."
            },
			["EZ Anti-Materiel Sniper Rifle"]={
                JMod.WeaponTable["Anti-Materiel Sniper Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=200,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100
                },
                "Weapons",
                "An Anti-materiel sniper rifle. Use to obliterate your enemies and their property at long range."
            },                  
            ["EZ Assault Rifle"]={
                JMod.WeaponTable["Assault Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=125,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "An assault rifle. Reliable automatic rifle to dispatch assailants at medium range."
            },
            ["EZ Battle Rifle"]={
                JMod.WeaponTable["Battle Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A battle rifle. Powerful semi-auto rifle to dispatch assailants at medium range."
            },
            ["EZ Carbine"]={
                JMod.WeaponTable["Carbine"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A carbine. Like the assault rifle, but with a shorter barrel."
            },
            ["EZ Designated Marksman Rifle"]={
                JMod.WeaponTable["Designated Marksman Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=35
                },
                "Weapons",
                "A designated marksman rifle. Strong semi-auto rifle equipped with a scope for long range target removal."
            },
            ["EZ Machine Pistol"]={
                JMod.WeaponTable["Machine Pistol"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=75,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A machine pistol. Extremely fast automatic pistol for short range encounters."
            },
            ["EZ Magnum Pistol"]={
                JMod.WeaponTable["Magnum Pistol"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=75,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A magnum pistol. Strong semi-auto pistol."
            },
            ["EZ Submachine Gun"]={
                JMod.WeaponTable["Sub Machine Gun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=125,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A submachine gun. Fast automatic SMG for short-medium range engagements."
            },
            ["EZ Semiautomatic Shotgun"]={
                JMod.WeaponTable["Semi-Automatic Shotgun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A semi-automatic shotgun. Fast firing tube-fed shotgun for close range battle."
            },
            ["EZ Rocket Launcher"]={
                JMod.WeaponTable["Rocket Launcher"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=200,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50
                },
                "Weapons",
                "A rocket launcher. Launches rockets. What else did you think it did?"
            },
            ["EZ Fully-Automatic Shotgun"]={
                JMod.WeaponTable["Fully-Automatic Shotgun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=125,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=75
                },
                "Weapons",
                "A fully-automatic shotgun. Fast firing magazine-fed automatic shotgun for close range deletion."
            },
            ["EZ Light Machine Gun"]={
                JMod.WeaponTable["Light Machine Gun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
                    [JMod.EZ_RESOURCE_TYPES.TITANIUM]=25
                },
                "Weapons",
                "A light machine gun. Fast firing LMG capable of laying down suppressive fire at medium range."
            },
            ["EZ Medium Machine Gun"]={
                JMod.WeaponTable["Medium Machine Gun"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=200,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=125,
                    [JMod.EZ_RESOURCE_TYPES.TUNGSTEN]=25
                },
                "Weapons",
                "A medium machine gun. Powerful machine gun with decent fire rate for dealing serious damage."
            },
            ["EZ Anti-Materiel Rifle"]={
                JMod.WeaponTable["Anti-Materiel Rifle"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=250,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=150,
                    [JMod.EZ_RESOURCE_TYPES.TITANIUM]=50
                },
                "Weapons",
                "An Anti-materiel rifle. Use to obliterate your enemies and their property in quick succession."
            }, 
            ["EZ Multiple Grenade Launcher"]={
                JMod.WeaponTable["Multiple Grenade Launcher"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=150,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
                    [JMod.EZ_RESOURCE_TYPES.TITANIUM]=50
                },
                "Weapons",
                "A Multiple Grenade Launcher. Use wisely to wreak havoc at close-medium range."
            },
            ["EZ Multiple Rocket Launcher"]={
                JMod.WeaponTable["Multiple Rocket Launcher"].ent,
                {
                    [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=250,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=100,
                    [JMod.EZ_RESOURCE_TYPES.TUNGSTEN]=50
                },
                "Weapons",
                "A Multiple Rocket Launcher. The holy grail. Use this to strike down the deserving."
            },
		    ["EZ Ballistic Mask"]={
		        "ent_jack_gmod_ezarmor_balmask",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
                    [JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5
		        },
		        "Apparel",
				"Face protection for the narcissists."
		    },
		    ["EZ Toolbox"]={
		        "ent_jack_gmod_eztoolbox",
		        {
			        [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=25,
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
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=25
				},
				"Munitions",
				"A Versatile breaching tool."
			},
			["EZ Dynamite"]={
				"ent_jack_gmod_ezdynamite",
				{
					[JMod.EZ_RESOURCE_TYPES.PAPER]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Munitions",
				"Good for blastmining and blasting idiots."
			},
			["EZ Explosives"]={
				"ent_jack_gmod_ezexplosives",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=100
				},
				"Resources",
				"No bomb is complete without explosives!"
			},
			["EZ Flashbang"]={
				"ent_jack_gmod_ezflashbang",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=5
				},
				"Munitions",
				"Look away unless you want to be blinded."
			},
			["EZ Fougasse Mine"]={
				"ent_jack_gmod_ezfougasse",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Munitions",
				"Focus fire on the flammable targets."
			},
			["EZ Fragmentation Grenade"]={
				"ent_jack_gmod_ezfragnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Munitions",
				"Frag nade, for sending hundreds of fragments into your enemy."
			},
			["EZ Fumigator"]={
				"ent_jack_gmod_ezfumigator",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.GAS]=100,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=50
				},
				"Munitions",
				"Go ahead, tell your hitler jokes. We'll wait."
			},
			["EZ Gas Grenade"]={
				"ent_jack_gmod_ezgasnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.GAS]=20,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=15
				},
				"Munitions",
				"Portable way of gassing j- enemies."
			},
			["EZ Tear Gas Grenade"]={
				"ent_jack_gmod_ezcsnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.GAS]=20,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10
				},
				"Munitions",
				"Effective area denial for those without gasmasks. Might be a warcrime."
			},
			["EZ Gas Mask"]={
				"ent_jack_gmod_ezarmor_gasmask",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20
				},
				"Apparel",
				"Protect yourself against the enemies' warcrimes."
			},
			["EZ Gebalte Ladung"]={
				"ent_jack_gmod_ezsticknadebundle",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=50
				},
				"Munitions",
				"A very heavy and very explosive stick grenade."
			},
			["EZ Headset"]={
				"ent_jack_gmod_ezarmor_headset",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.POWER]=20
				},
				"Apparel",
				"A great way of communicating with your team. No one else can hear you."
			},
			["EZ Heavy Left Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_hlshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=20,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=10
				},
				"Apparel",
				"You must care about your shoulders if you wear this."
			},
			["EZ Heavy Right Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_hrshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=20,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=20,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20
				},
				"Apparel",
				"You must care about your shoulders if you wear this."
			},
			["EZ Heavy Torso Armor"]={
				"ent_jack_gmod_ezarmor_htorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=50,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=50
				},
				"Apparel",
				"Turtle shell. Heavy defense."
			},
			["EZ Impact Grenade"]={
				"ent_jack_gmod_ezimpactnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=15
				},
				"Munitions",
				"For the aggressive type. Explodes on impact."
			},
			["EZ Incendiary Grenade"]={
				"ent_jack_gmod_ezfirenade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10,
					[JMod.EZ_RESOURCE_TYPES.FUEL]=30
				},
				"Munitions",
				"Portable fire bomb, try cooking it before throwing to spread it more."
			},
			["EZ Landmine"]={
				"ent_jack_gmod_ezlandmine",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Munitions",
				"Anti-personnel land mine. Try your best to match the color with the ground."
			},
			["BUCKET"]={
				JMod.ArmorTable["Metal Bucket"].ent,
				{
					[JMod.EZ_RESOURCE_TYPES.STEEL]=20
				},
				"Apparel",
				"im am smart put buket on head for protecton"
			},
			["CONE"]={
				JMod.ArmorTable["Traffic Cone"].ent,
				{
					[JMod.EZ_RESOURCE_TYPES.RUBBER]=10,
					[JMod.EZ_RESOURCE_TYPES.PLASTIC]=10
				},
				"Apparel",
				"yo you ever played Garry's Mod?"
			},
			["CERAMIC POT"]={
				JMod.ArmorTable["Ceramic Pot"].ent,
				{
					[JMod.EZ_RESOURCE_TYPES.GLASS]=30,
				},
				"Apparel",
				"will stop a bullet once"
			},
			["COOKIN POT"]={
				JMod.ArmorTable["Metal Pot"].ent,
				{
					[JMod.EZ_RESOURCE_TYPES.STEEL]=30
				},
				"Apparel",
				"congrats you are now 5"
			},
			["EZ Light Helmet"]={
				"ent_jack_gmod_ezarmor_lhead",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=10
				},
				"Apparel",
				"Not so bad on your neck, but has low defense."
			},
			["EZ Respirator"]={
				"ent_jack_gmod_ezarmor_respirator",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
				},
				"Apparel",
				"You can wear goggles while protecting your lungs, but you'll have to retreat."
			},
			["EZ Riot Helmet"]={
				"ent_jack_gmod_ezarmor_riot",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10
				},
				"Apparel",
				"Protect your entire head with one piece. No goggles though."
			},
			["EZ Heavy Riot Helmet"]={
				"ent_jack_gmod_ezarmor_rioth",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=15
				},
				"Apparel",
				"Heavier version of the riot helmet."
			},
			["EZ Ultra Heavy Helmet"]={
				"ent_jack_gmod_ezarmor_maska",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=20,
					[JMod.EZ_RESOURCE_TYPES.TUNGSTEN]=10
				},
				"Apparel",
				"Turtle head. Heaviest helmet, and restricts your vision alot."
			},
			["EZ Light Left Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_llshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
				},
				"Apparel",
				"Some protection for your shoulders."
			},
			["EZ Light Right Shoulder Armor"]={
				"ent_jack_gmod_ezarmor_lrshoulder",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
				},
				"Apparel",
				"Some protection for your shoulders."
			},
			["EZ Light Torso Armor"]={
				"ent_jack_gmod_ezarmor_ltorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20
				},
				"Apparel",
				"Might help against buckshot and 22LR, but not much else."
			},
			["EZ Medical Supplies"]={
				"ent_jack_gmod_ezmedsupplies",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=25,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=50
				},
				"Resources",
				"Necessities to heal anyone."
			},
			["EZ Medium Helmet"]={
				"ent_jack_gmod_ezarmor_mhead",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=10
				},
				"Apparel",
				"Better than the light helmet, but worse than the heavy. Neck might hurt if you wear it too long."
			},
			["EZ Medium Torso Armor"]={
				"ent_jack_gmod_ezarmor_mtorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=25,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=25
				},
				"Apparel",
				"Medium protection for your chest."
			},
			["EZ Medium-Heavy Torso Armor"]={
				"ent_jack_gmod_ezarmor_mhtorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=25,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=25,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=25
				},
				"Apparel",
				"Slightly less heavy, slightly less protection than heavy armor."
			},
			["EZ Medium-Light Torso Armor"]={
				"ent_jack_gmod_ezarmor_mltorso",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=15,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20
				},
				"Apparel",
				"it'll help a little more than light armor, and is slightly heavier."
			},
			["EZ Medkit"]={
				"ent_jack_gmod_ezmedkit",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES]=100
				},
				"Tools",
				"Go help em doc. Watch your head, you're gonna be a target."
			},
			["EZ Mini Bounding Mine"]={
				"ent_jack_gmod_ezboundingmine",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=5
				},
				"Munitions",
				"Bury this in the soil around your base, and you got a very hidden defense option."
			},
			["EZ Mini Claymore"]={
				"ent_jack_gmod_ezminimore",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=10
				},
				"Munitions",
				"Simple way to trap corners and the like."
			},
			["EZ Mini Impact Grenade"]={
				"ent_jack_gmod_eznade_impact",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Munitions",
				"You could throw it, but it's much better for making sure that bumping a bomb is a death sentence."
			},
			["EZ Mini Proximity Grenade"]={
				"ent_jack_gmod_eznade_proximity",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Munitions",
				"Useful for turning big bombs into traps. Very weak on its own however."
			},
			["EZ Mini Remote Grenade"]={
				"ent_jack_gmod_eznade_remote",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Munitions",
				"Set it on a bomb, and trigger it from afar. Good if you want to ensure you're out of blast range."
			},
		   	["EZ Mini Timed Grenade"]={
				"ent_jack_gmod_eznade_remote",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=5,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=5
				},
				"Munitions",
				"Arm it on a bomb, and run like hell."
			},
			["EZ Munitions"]={
				"ent_jack_gmod_ezmunitions",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=100,
					[JMod.EZ_RESOURCE_TYPES.PROPELLANT]=100,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=50,
					[JMod.EZ_RESOURCE_TYPES.LEAD]=50
				},
				"Resources",
				"Ammo for your explosive toys."
			},
			["EZ Night Vision Goggles"]={
				"ent_jack_gmod_ezarmor_nvgs",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.POWER]=25
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
				"Munitions",
				"Become bugs bunny and kill yosemite sam with a black-powder line"
			},
			["EZ Propellant"]={
				"ent_jack_gmod_ezpropellant",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=25,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=50
				},
				"Resources",
				"Propellant for guns and other things."
			},
			["EZ Coolant"]={
				"ent_jack_gmod_ezcoolant",
				{
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10,
					[JMod.EZ_RESOURCE_TYPES.WATER]=90,
				},
				"Resources",
				"For cooling down machines. Do not drink."
			},
			["EZ Nutrients"]={
				"ent_jack_gmod_eznutrients",
				{
					[JMod.EZ_RESOURCE_TYPES.ORGANICS]=25,
					[JMod.EZ_RESOURCE_TYPES.WATER]=25,
					[JMod.EZ_RESOURCE_TYPES.PAPER]=50,
				},
				"Resources",
				"Tasty food! 99% Plastic Free!"
			},
			["EZ SLAM"]={	
				"ent_jack_gmod_ezslam",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=15
				},
				"Munitions",
				"Fires an armor-piercing mega bullet at any enemy vehicle to cross the laser beam."
			},
			["EZ Satchel Charge"]={
				"ent_jack_gmod_ezsatchelcharge",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=100
				},
				"Munitions",
				"we wile e coyote now, meep meep"
			},
			["EZ Signal Grenade"]={
				"ent_jack_gmod_ezsignalnade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=25
				},
				"Munitions",
				"Send smoke signals to your team, and probably be ignored or brutally murdered by the enemy."
			},
			["EZ Smoke Grenade"]={
				"ent_jack_gmod_ezsmokenade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=25
				},
				"Munitions",
				"Smokescreen so nobody knows who they're shooting."
			},
			["EZ Left Calf Armor"]={
		        "ent_jack_gmod_ezarmor_slcalf",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"For your legs."
		    },
			["EZ Left Forearm Armor"]={
		        "ent_jack_gmod_ezarmor_slforearm",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"For your arm."
		    },
			["EZ Light Left Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_llthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"Keep your thigh."
		    },
			["EZ Heavy Left Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_hlthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=10
		        },
		        "Apparel",
				"i'm not making that joke."
		    },
			["EZ Pelvis Armor"]={
		        "ent_jack_gmod_ezarmor_spelvis",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"Keep your kiwis safe!"
		    },
			["EZ Right Calf Armor"]={
		        "ent_jack_gmod_ezarmor_srcalf",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"For your legs."
		    },
			["EZ Right Forearm Armor"]={
		        "ent_jack_gmod_ezarmor_srforearm",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"For your arm."
		    },
			["EZ Light Right Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_lrthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=5,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=10
		        },
		        "Apparel",
				"Keep your thigh."
		    },
			["EZ Heavy Right Thigh Armor"]={
		        "ent_jack_gmod_ezarmor_hrthigh",
		        {   
		            [JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
					[JMod.EZ_RESOURCE_TYPES.ADVANCEDTEXTILES]=10,
					[JMod.EZ_RESOURCE_TYPES.CLOTH]=20,
					[JMod.EZ_RESOURCE_TYPES.CERAMIC]=10
		        },
		        "Apparel",
				"I'm not making that joke."
		    },
			["EZ Stick Grenade"]={
				"ent_jack_gmod_ezsticknade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=15,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=15
				},
				"Munitions",
				"Use your good throwing arm for this. Goes very far. Can have a frag sleeve on it."
			},
			["EZ Sticky Bomb"]={
				"ent_jack_gmod_ezstickynade",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=10,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=20,
					[JMod.EZ_RESOURCE_TYPES.CHEMICALS]=10
				},
				"Munitions",
				"Don't get yourself stuck on it! Very good for sticking to vehicles and stationary objects."
			},
			["EZ TNT"]={
				"ent_jack_gmod_eztnt",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=30
				},
				"Munitions",
				"Simple breaching device. Reacts to powder from the powder keg."
			},
			["EZ Thermal Goggles"]={
				"ent_jack_gmod_ezarmor_thermals",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=25,
					[JMod.EZ_RESOURCE_TYPES.PRECISIONPARTS]=50,
					[JMod.EZ_RESOURCE_TYPES.POWER]=25
				},
				"Apparel",
				"Good for seeing things you couldn't see before."
			},
			["EZ Time Bomb"]={
				"ent_jack_gmod_eztimebomb",
				{
					[JMod.EZ_RESOURCE_TYPES.BASICPARTS]=20,
                    [JMod.EZ_RESOURCE_TYPES.EXPLOSIVES]=100
				},
				"Munitions",
				"The longer you set the time, the harder it is to defuse."
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