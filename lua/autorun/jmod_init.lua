AddCSLuaFile()
JMod=JMod or {}

-- EZ radio stations
JMod.EZ_RADIO_STATIONS={}
JMod.EZ_STATION_STATE_READY=1
JMod.EZ_STATION_STATE_DELIVERING=2
JMod.EZ_STATION_STATE_BUSY=3

-- resource definitions --
JMod.EZ_RESOURCE_TYPES={
	WATER="water",
	WOOD="wood",
	ORGANICS="organics",
	ORE="ore",
	OIL="oil",
	GAS="gas",
	--
	METAL="metal",
	FUEL="fuel",
	PLASTIC="plastic",
	RUBBER="rubber",
	GLASS="glass",
	CLOTH="cloth",
	CERAMIC="ceramic",
	PAPER="paper",
	--
	AMMO="ammo",
	MUNITIONS="munitions",
	PROPELLANT="propellant",
	EXPLOSIVES="explosives",
	MEDSUPPLIES="medsupplies",
	CHEMICALS="chemicals",
	NUTRIENTS="nutrients",
	COOLANT="coolant",
	--
	BASICPARTS="basicparts",
	PRECISIONPARTS="precisionparts",
	ADVTEXTILES="advtextiles",
	--
	ADVPARTS="advparts",
	FISSILEMATERIAL="fissilematerial",
	ANTIMATTER="antimatter"
}

-- EZ item quality grade (upgrade level) definitions
JMod.EZ_GRADE_BASIC=1
JMod.EZ_GRADE_COPPER=2
JMod.EZ_GRADE_SILVER=3
JMod.EZ_GRADE_GOLD=4
JMod.EZ_GRADE_PLATINUM=5
JMod.EZ_GRADE_BUFFS={1,1.25,1.5,1.75,2}
JMod.EZ_GRADE_NAMES={"basic","copper","silver","gold","platinum"}
JMod.EZ_GRADE_UPGRADE_COSTS={.5,1,1.5,2}
JMod.EZ_UPGRADE_RESOURCE_BLACKLIST={}

-- Resource enums
JMod.EZammoBoxSize=300
JMod.EZbasicResourceBoxSize=100
JMod.EZsmallCrateSize=100
JMod.EZsuperRareResourceSize=10
JMod.EZadvPartBoxSize=20
JMod.EZmedSupplyBoxSize=50
JMod.EZcrateSize=15
JMod.EZpartsCrateSize=15
JMod.EZnutrientsCrateSize=15

-- State enums
JMod.EZ_STATE_BROKEN 	= -1
JMod.EZ_STATE_OFF 		= 0
JMod.EZ_STATE_ON        = 1
JMod.EZ_STATE_PRIMED 	= 2
JMod.EZ_STATE_ARMING 	= 3
JMod.EZ_STATE_ARMED		= 4
JMod.EZ_STATE_WARNING	= 5

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
-- moab drogue chute
-- bounding mine unbury
-- if the json cant be read then print an error
-- fuggin like let BK and WB draw from resource crates
-- func for packages to read more info from ez entities
-- clasnames to friendlist
-- craftable keypad entity you can install on anything to lock it with a PIN
-- weapon crate
-- weps spawn with full ammo
-- - fix dropdown in turret customize menu
-- make sentries prioritize targets
-- - make laser sentries do DMG_DIRECT to zombies when they are on fire
-- - config to change the prop spam use effect
-- JIT crashes with sentry terminal
-- black hole, add blacklist st_*
-- armor crate issues
-- todo: implement:
		--	InjurySlowdownMult=0,
		--	InjuryVisionMult=0,
		--	BlastConsussionMult=0,
		--	InjurySwayMult=0,
		--	ArmShotSwayMult=0,
		--	ArmShotDisarmChance=0,
		--	LegShotSlowdownMult=0
--[[
[JMod] lua/jmod/sv_hint.lua:3: Tried to use a NULL entity!
1. __newindex - [C]:-1
2. JMod.Hint - lua/jmod/sv_hint.lua:3
3. unknown - lua/entities/ent_jack_gmod_ezweapon.lua:78
Timer Failed! [Simple][@lua/entities/ent_jack_gmod_ezweapon.lua (line 77)]
-- make each outpost, when established, have a random position outside the map
-- so that drop bearings can be predicted
-- fuckin, like, or something
-- add language translation ability for all the JMod Hints
-- and melee weps
-- healing kit -1 suplies
-- nextbot support
-- add recoil halving back
-- recoil viewpunch has been reduced what in the fuck
-- make breath control time a bit longer
-- make defusal faster with kit
-- make API sentries do more vehicle damage
-- sentries vs doors
-- BP muzzle effect
-- dirty bomb
-- add upgrade level to display
-- add merge func for resources
-- add white phosphorous weapon
-- ALT SHIFT E to split resource crates
-- ez air sensor
-- ez add abilities to make radio outposts
-- make hl2 ammo work for ez guns
-- make fucking uh the sewage infection be gated in QoL
-- add revival in QoL
-- criticality bomb?
-- EMP generator?
-- make the EMP also have a chance at deactivating mines and other small items
-- make mines de-weld themselves on disarm
-- why the fuck does the dropwep concommand fire when someone's typing chat WTF
-- add niggers
-- the fucking levergun is fucked up, move it forward and add a front sight post
--]]
--[[
hook.Add( "OnDamagedByExplosion", "DisableSound", function()
    return true
end )
--]]

for i, f in pairs(file.Find("jmod/*.lua", "LUA")) do
	if string.Left(f, 3) == "sv_" then
		if SERVER then include("jmod/" .. f) end
	elseif string.Left(f, 3) == "cl_" then
		if CLIENT then
			include("jmod/" .. f)
		else
			AddCSLuaFile("jmod/" .. f)
		end
	elseif string.Left(f, 3) == "sh_" then
		AddCSLuaFile("jmod/" .. f)
		include("jmod/" .. f)
	else
		print("JMod detected unaccounted for lua file '" .. f .. "' - check prefixes!")
	end
end
