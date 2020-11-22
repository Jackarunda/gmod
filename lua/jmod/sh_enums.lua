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

-- Resource enums
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

-- State enums
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
-- bounding mine unbury
-- fakken like OnDamagedByExplosion tinnitus
-- if the json cant be read then print an error
-- fuggin like let BK and WB draw from resource crates
-- func for packages to read more info from ez entities
-- clasnames to friendlist
-- craftable keypad entity you can install on anything to lock it with a PIN
-- link sentry power consumption to perf mult
-- armordegredation mult doesnt work
--[[
hook.Add( "OnDamagedByExplosion", "DisableSound", function()
    return true
end )
--]]