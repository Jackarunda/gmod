SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Break-Action Shotgun"

SWEP.Slot = 2

SWEP.ViewModel = "models/viper/mw/weapons/725_mammaledition.mdl"
SWEP.WorldModel = "models/nmrih/weapons/fa_sv10/w_fa_sv10.mdl"
SWEP.ViewModelFOV = 68
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,170,0)
SWEP.BodyHolsterAngL = Angle(0,195,180)
SWEP.BodyHolsterPos = Vector(2,-11,-9)
SWEP.BodyHolsterPosL = Vector(1,-11,10)
SWEP.BodyHolsterScale = 1

SWEP.Damage = 15
SWEP.DamageMin = 2 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 75 -- in METERS
SWEP.DamageType = DMG_BUCKSHOT
SWEP.Penetration = 20
SWEP.DoorBreachPower = .2

SWEP.Primary.ClipSize = 2 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0

SWEP.Recoil = 3
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 200 -- 60 / RPM.
SWEP.Num = 9 -- number of projectiles per shot
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 30 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 500 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Shotgun Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/shotgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/shotgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1 -- fix calcview reload bob lol

SWEP.MuzzleEffect = "muzzleflash_m3"
SWEP.ShellModel = "models/jhells/shell_12gauge.mdl"
SWEP.ShellPitch = 90
if(ArcCW)then SWEP.ShellSounds = ArcCW.ShotgunShellSoundsTable end
SWEP.ShellScale = 3

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .55

SWEP.IronSightStruct = {
    Pos = Vector(-3.01, 3, 1.2),
    Ang = Angle(-.15, 0, -5),
    Magnification = 1.1,
    SwitchToSound = "", -- sound that plays when switching to this sight
}

SWEP.ActivePos = Vector(1, 1, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 38

--[[
Idle
Draw
Draw_First
Holster
Reload_Empty
Reload_Empty_fast
reload
reload_fast
fire
fire_ads
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "Idle",
        Time = 1
    },
    ["draw"] = {
        Source = "Draw",
        Time = 0.6,
        SoundTable = {{s = "snds_jack_gmod/ez_weapons/bas/draw.wav", t = 0, v=60, p=120}},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "Draw_First",
        Time = 1,
        SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bas/swing.wav", t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/bas/shut.wav", t = .2, v=60}
		},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 1,
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 1,
    },
    ["fire_empty"] = {
        Source = "fire",
        Time = 1,
    },
	["reload"] = {
        Source = "reload",
        Time = 3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		ShellEjectAt = 1,
		ShellEjectCount=1,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bas/open.wav", t = 0, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/tap.wav", t = 1, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/in.wav", t = 1.2, v=65, p=120},
			{s = "snds_jack_gmod/ez_weapons/bas/swing.wav", t = 1.4, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/shut.wav", t = 1.7, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/grab.wav", t = 1.9, v=65}
		}
    },
    ["reload_empty"] = {
        Source = "Reload_Empty",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		ShellEjectAt = 1,
		ShellEjectCount=2,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bas/open_empty.wav", t = .05, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/tap.wav", t = 1.3, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/in_double.wav", t = 1.8, v=65, p=120},
			{s = "snds_jack_gmod/ez_weapons/bas/swing.wav", t = 2, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/shut.wav", t = 2.3, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/grab.wav", t = 2.6, v=65}
		}
    }
}