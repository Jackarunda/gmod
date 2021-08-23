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
	OIL="oil",
	GAS="gas",
	POWER="power",
	DIAMOND="diamond",
	COAL="coal",
	--
	IRONORE="iron ore",
	LEADORE="lead ore",
	ALUMINUMORE="aluminum ore",
	COPPERORE="copper ore",
	TUNGSTENORE="tungsten ore",
	TITANIUMORE="titanium ore",
	SILVERORE="silver ore",
	GOLDORE="gold ore",
	URANIUMORE="uranium ore",
	PLATINUMORE="platinum ore",
	--
	STEEL="steel",
	LEAD="lead",
	ALUMINUM="aluminum",
	COPPER="copper",
	TUNGSTEN="tungsten",
	TITANIUM="titanium",
	SILVER="silver",
	GOLD="gold",
	URANIUM="uranium",
	PLATINUM="platinum",
	--
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
	MEDICALSUPPLIES="medical supplies",
	CHEMICALS="chemicals",
	NUTRIENTS="nutrients",
	COOLANT="coolant",
	--
	BASICPARTS="basic parts",
	PRECISIONPARTS="precision parts",
	ADVANCEDTEXTILES="advanced textiles",
	ADVANCEDPARTS="advanced parts",
	FISSILEMATERIAL="fissile material",
	--
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

-- State enums
JMod.EZ_STATE_BROKEN 	= -1
JMod.EZ_STATE_OFF 		= 0
JMod.EZ_STATE_ON        = 1
JMod.EZ_STATE_PRIMED 	= 2
JMod.EZ_STATE_ARMING 	= 3
JMod.EZ_STATE_ARMED		= 4
JMod.EZ_STATE_WARNING	= 5

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
hook.Add("Think","penis",function()
	local ply=player.GetAll()[1]
	if(ply)then jprint(ply:GetPos().z) end
end)
--]]

--[[
Physics Sounds

ArmorFlesh.BulletImpact
BaseEntity.EnterWater
BaseEntity.ExitWater
Boulder.ImpactHard
Boulder.ImpactSoft
Boulder.ScrapeRough
Boulder.ScrapeSmooth
Bounce.Concrete
Bounce.Flesh
Bounce.Glass
Bounce.Metal
Bounce.Shell
Bounce.ShotgunShell
Bounce.Shrapnel
Bounce.Wood
Breakable.Ceiling
Breakable.Computer
Breakable.Concrete
Breakable.Crate
Breakable.Flesh
Breakable.Glass
Breakable.MatConcrete
Breakable.MatFlesh
Breakable.MatGlass
Breakable.MatMetal
Breakable.MatWood
Breakable.Metal
Breakable.Spark
Canister.ImpactHard
Canister.ImpactSoft
Canister.Roll
Canister.ScrapeRough
Canister.ScrapeSmooth
Cardboard.Break
Cardboard.BulletImpact
Cardboard.ImpactHard
Cardboard.ImpactSoft
Cardboard.ScrapeRough
Cardboard.ScrapeSmooth
Cardboard.Shake
Cardboard.StepLeft
Cardboard.StepRight
Cardboard.Strain
Carpet.BulletImpact
Carpet.Impact
Carpet.Scrape
ceiling_tile.Break
ceiling_tile.BulletImpact
ceiling_tile.ImpactHard
ceiling_tile.ImpactSoft
ceiling_tile.ScrapeRough
ceiling_tile.ScrapeSmooth
ceiling_tile.StepLeft
ceiling_tile.StepRight
Chain.BulletImpact
Chain.ImpactHard
Chain.ImpactSoft
Chain.ScrapeRough
Chain.ScrapeSmooth
ChainLink.BulletImpact
ChainLink.ImpactHard
ChainLink.ImpactSoft
ChainLink.ScrapeRough
ChainLink.ScrapeSmooth
ChainLink.StepLeft
ChainLink.StepRight
Computer.BulletImpact
Computer.ImpactHard
Computer.ImpactSoft
Concrete.BulletImpact
Concrete.ImpactHard
Concrete.ImpactSoft
Concrete.ScrapeRough
Concrete.ScrapeSmooth
Concrete.StepLeft
Concrete.StepRight
Concrete_Block.ImpactHard
Default.BulletImpact
Default.ImpactHard
Default.ImpactSoft
Default.ScrapeRough
Default.ScrapeSmooth
Default.StepLeft
Default.StepRight
Dirt.BulletImpact
Dirt.Impact
Dirt.Scrape
Dirt.StepLeft
Dirt.StepRight
drywall.ImpactHard
drywall.ImpactSoft
drywall.StepLeft
drywall.StepRight
Flesh.Break
Flesh.BulletImpact
Flesh.ImpactHard
Flesh.ImpactSoft
Flesh.ScrapeRough
Flesh.ScrapeSmooth
Flesh.StepLeft
Flesh.StepRight
Flesh.Strain
Flesh_Bloody.ImpactHard
Glass.Break
Glass.BulletImpact
Glass.ImpactHard
Glass.ImpactSoft
Glass.ScrapeRough
Glass.ScrapeSmooth
Glass.StepLeft
Glass.StepRight
Glass.Strain
GlassBottle.Break
GlassBottle.BulletImpact
GlassBottle.ImpactHard
GlassBottle.ImpactSoft
GlassBottle.ScrapeRough
GlassBottle.ScrapeSmooth
GlassBottle.StepLeft
GlassBottle.StepRight
Grass.StepLeft
Grass.StepRight
Gravel.StepLeft
Gravel.StepRight
Grenade.ImpactHard
Grenade.ImpactSoft
Grenade.Roll
Grenade.ScrapeRough
Grenade.ScrapeSmooth
Grenade.StepLeft
Grenade.StepRight
Gunship.Impact
Gunship.Scrape
ItemSoda.Bounce
Ladder.StepLeft
Ladder.StepRight
Metal.SawbladeStick
Metal_Barrel.BulletImpact
Metal_Barrel.ImpactHard
Metal_Barrel.ImpactSoft
Metal_Barrel.Roll
Metal_Box.Break
Metal_Box.BulletImpact
Metal_Box.ImpactHard
Metal_Box.ImpactSoft
Metal_Box.ScrapeRough
Metal_Box.ScrapeSmooth
Metal_Box.StepLeft
Metal_Box.StepRight
Metal_Box.Strain
Metal_SeafloorCar.BulletImpact
MetalGrate.BulletImpact
MetalGrate.ImpactHard
MetalGrate.ImpactSoft
MetalGrate.ScrapeRough
MetalGrate.ScrapeSmooth
MetalGrate.StepLeft
MetalGrate.StepRight
MetalVehicle.ImpactHard
MetalVehicle.ImpactSoft
MetalVehicle.ScrapeRough
MetalVehicle.ScrapeSmooth
MetalVent.ImpactHard
MetalVent.StepLeft
MetalVent.StepRight
Mud.StepLeft
Mud.StepRight
Paintcan.ImpactHard
Paintcan.ImpactSoft
Paintcan.Roll
Papercup.Impact
Papercup.Scrape
Physics.WaterSplash
Plastic_Barrel.Break
Plastic_Barrel.BulletImpact
Plastic_Barrel.ImpactHard
Plastic_Barrel.ImpactSoft
Plastic_Barrel.Roll
Plastic_Barrel.ScrapeRough
Plastic_Barrel.ScrapeSmooth
Plastic_Barrel.StepLeft
Plastic_Barrel.StepRight
Plastic_Barrel.Strain
Plastic_Box.Break
Plastic_Box.BulletImpact
Plastic_Box.ImpactHard
Plastic_Box.ImpactSoft
Plastic_Box.ScrapeRough
Plastic_Box.ScrapeSmooth
Plastic_Box.StepLeft
Plastic_Box.StepRight
Plastic_Box.Strain
Popcan.BulletImpact
Popcan.ImpactHard
Popcan.ImpactSoft
Popcan.ScrapeRough
Popcan.ScrapeSmooth
Pottery.Break
Pottery.BulletImpact
Pottery.ImpactHard
Pottery.ImpactSoft
Rock.ImpactHard
Rock.ImpactSoft
Roller.Impact
Rubber.BulletImpact
Rubber.ImpactHard
Rubber.ImpactSoft
Rubber.StepLeft
Rubber.StepRight
Rubber_Tire.BulletImpact
Rubber_Tire.ImpactHard
Rubber_Tire.ImpactSoft
Rubber_Tire.Strain
Sand.BulletImpact
Sand.StepLeft
Sand.StepRight
SlipperySlime.StepLeft
SlipperySlime.StepRight
SolidMetal.BulletImpact
SolidMetal.ImpactHard
SolidMetal.ImpactSoft
SolidMetal.ScrapeRough
SolidMetal.ScrapeSmooth
SolidMetal.StepLeft
SolidMetal.StepRight
SolidMetal.Strain
Strider.Impact
Strider.Scrape
Tile.BulletImpact
Tile.StepLeft
Tile.StepRight
Tst11
Tst22
Tst44
Tst448
TstADPCM
TstMusic
Tstpitch11
Tstpitch22
Tstpitch44
Tstpitch448
Tstpitch44l
TstPitchADPCM
TstPitchADPCMl
TstPitchMusic
TstPitchMusicl
Underwater.BulletImpact
Wade.StepLeft
Wade.StepRight
Water.BulletImpact
Water.StepLeft
Water.StepRight
Watermelon.BulletImpact
Watermelon.Impact
Watermelon.Scrape
weapon.BulletImpact
weapon.ImpactHard
weapon.ImpactSoft
weapon.ScrapeRough
weapon.ScrapeSmooth
weapon.StepLeft
weapon.StepRight
Wood.Break
Wood.BulletImpact
Wood.ImpactHard
Wood.ImpactSoft
Wood.ScrapeRough
Wood.ScrapeSmooth
Wood.StepLeft
Wood.StepRight
Wood.Strain
Wood_Box.Break
Wood_Box.BulletImpact
Wood_Box.ImpactHard
Wood_Box.ImpactSoft
Wood_Box.ScrapeRough
Wood_Box.ScrapeSmooth
Wood_Box.StepLeft
Wood_Box.StepRight
Wood_Box.Strain
Wood_Crate.Break
Wood_Crate.ImpactHard
Wood_Crate.ImpactSoft
Wood_Crate.ScrapeRough
Wood_Crate.ScrapeSmooth
Wood_Crate.StepLeft
Wood_Crate.StepRight
Wood_Crate.Strain
Wood_Furniture.Break
Wood_Furniture.ImpactSoft
Wood_Furniture.Strain
Wood_Panel.Break
Wood_Panel.BulletImpact
Wood_Panel.ImpactHard
Wood_Panel.ImpactSoft
Wood_Panel.ScrapeRough
Wood_Panel.ScrapeSmooth
Wood_Panel.StepLeft
Wood_Panel.StepRight
Wood_Panel.Strain
Wood_Plank.Break
Wood_Plank.BulletImpact
Wood_Plank.ImpactHard
Wood_Plank.ImpactSoft
Wood_Plank.ScrapeRough
Wood_Plank.ScrapeSmooth
Wood_Plank.Strain
Wood_Solid.Break
Wood_Solid.BulletImpact
Wood_Solid.ImpactHard
Wood_Solid.ImpactSoft
Wood_Solid.ScrapeRough
Wood_Solid.ScrapeSmooth
Wood_Solid.Strain
--]]