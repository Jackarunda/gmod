SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Flintlock Musket"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/v_jmod_musket.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_musket.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(185,15,180)
SWEP.BodyHolsterAngL = Angle(0,195,170)
SWEP.BodyHolsterPos = Vector(2,-11,-11)
SWEP.BodyHolsterPosL = Vector(1,-11,11)
SWEP.BodyHolsterScale = .9

SWEP.Damage = 90
SWEP.DamageMin = 20 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 200 -- in METERS
SWEP.Penetration = 20

SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.

SWEP.Recoil = 2.5
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 100 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SINGLE"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 15 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Black Powder Paper Cartridge" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/flintlock_longgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/flintlock_longgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_M3"
SWEP.ExtraMuzzleLua = "eff_jack_gmod_bpmuzzle"
SWEP.ExtraMuzzleLuaScale = 1

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .6

SWEP.IronSightStruct = {
	Pos = Vector(-6.2, -1, 3.75),
	Ang = Angle(-.2, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod_GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.HolsterPos = Vector(11, 1, -6)
SWEP.HolsterAng = Angle(0, 60, -15)

SWEP.ReloadActivePos = Vector(0,-2,-9)
SWEP.ReloadActiveAng = Angle(20,0,0)

SWEP.BarrelLength = 55

--[[
idle
idle_empty
draw
draw_empty
fire
fire_empty
dryfire
iron_fire
iron_fire_empty
iron_dryfire
reload
reload_empty
holster
holster_empty
sprint
sprint_empty
--]]
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["idle_empty"] = {
		Source = "idle_empty",
		Time = 1
	},
	["draw"] = {
		Source = "draw",
		Time = 0.6,
		SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=2.5,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["draw_empty"] = {
		Source = "draw_empty",
		Time = 0.6,
		SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=2.5,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["ready"] = {
		Source = "draw_empty",
		Time = 0.6,
		SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60}
		},
		Mult=2.5,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.25,
	},
	["fire"] = {
		Source = "fire_empty",
		Time = 0.5
	},
	["fire_iron"] = {
		Source = "fire_empty",
		Time = 0.5
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult=1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = .2, v=60, p=100},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.1, v=60, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/rip.wav", t = 2.1, v=65},
			{s = "snds_jack_gmod/ez_weapons/flm/pour.wav", t = 3.1, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 4.8, v=60, p=130},
			{s = "snds_jack_gmod/ez_weapons/flm/drop.wav", t = 6.1, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/halfcock.wav", t = 7.6, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/openfrizzen.wav", t = 7.9, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/primepan.wav", t = 8.2, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/closefrizzen.wav", t = 8.5, v=65, p=100},
			{s = "snds_jack_gmod/ez_weapons/flm/fullcock.wav", t = 8.8, v=65, p=100},
			{s = JMod_GunHandlingSounds.cloth.loud, t = 9, v=60, p=100}
		},
		ViewPunchTable = {
			{t = 2, p = Angle(0,5,0)},
			{t = 7.5, p = Angle(1,0,0)},
			{t = 7.8, p = Angle(1,0,0)},
			{t = 8.1, p = Angle(1,0,0)},
			{t = 8.4, p = Angle(1,0,0)},
			{t = 8.7, p = Angle(2,0,0)}
		}
	},
}