SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Break-Action Shotgun"

SWEP.Slot = 3

SWEP.ViewModel = "models/viper/mw/weapons/725_mammaledition.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_breakshotty.mdl"
SWEP.ViewModelFOV = 68
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,170,0)
SWEP.BodyHolsterAngL = Angle(0,195,180)
SWEP.BodyHolsterPos = Vector(2,-11,-9)
SWEP.BodyHolsterPosL = Vector(1,-11,10)
SWEP.BodyHolsterScale = 1

JMod_ApplyAmmoSpecs(SWEP,"Shotgun Round",1.2)

SWEP.Primary.ClipSize = 2 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0

SWEP.Recoil = 3
SWEP.VisualRecoilMult=1.5

SWEP.Delay = 60 / 200 -- 60 / RPM.
SWEP.Firemodes = {
    {
        Mode = 1,
		PrintName = "DOUBLE"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 20 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/shotgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/shotgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
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
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 1, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

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
        Time = 2,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=120}},
		Mult=.7,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "Draw_First",
        Time = 2.5,
        SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = .1, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/bas/swing.wav", t = .2, v=60},
			{s = "snds_jack_gmod/ez_weapons/bas/shut.wav", t = .5, v=60}
		},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 1,
    },
	["reload"] = {
        Source = "reload",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
		Mult=.9,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		ShellEjectAt = 1,
		ShellEjectCount=1,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bas/open.wav", t = .03, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1, v=60, p=140},
			{s = "snds_jack_gmod/ez_weapons/bas/tap.wav", t = 1.35, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/in.wav", t = 1.65, v=65, p=120},
			{s = "snds_jack_gmod/ez_weapons/bas/swing.wav", t = 2.05, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/shut.wav", t = 2.25, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/grab.wav", t = 2.65, v=65}
		}
    },
    ["reload_empty"] = {
        Source = "Reload_Empty",
        Time = 5,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=.9,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		ShellEjectAt = 1,
		ShellEjectCount=2,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/bas/open_empty.wav", t = .12, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/bas/tap.wav", t = 1.7, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/in_double.wav", t = 2.2, v=65, p=120},
			{s = "snds_jack_gmod/ez_weapons/bas/swing.wav", t = 2.4, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/shut.wav", t = 3, v=65},
			{s = "snds_jack_gmod/ez_weapons/bas/grab.wav", t = 3.45, v=65}
		}
    }
}