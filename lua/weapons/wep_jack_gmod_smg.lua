SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Sub Machine Gun"

SWEP.Slot = 2

SWEP.ViewModel = "models/weapons/v_cod4_mp5_c.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_mp5.mdl"
SWEP.ViewModelFOV = 65
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-105,10)
SWEP.BodyHolsterAngL = Angle(10,-75,180)
SWEP.BodyHolsterPos = Vector(.5,-11,-11)
SWEP.BodyHolsterPosL = Vector(.5,-11,11)
SWEP.BodyHolsterScale = .9

SWEP.Damage = 27
SWEP.DamageMin = 10 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 100 -- in METERS
SWEP.Penetration = 10

SWEP.Primary.ClipSize = 35 -- DefaultClip is automatically set.

SWEP.Recoil = .4
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 1000 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 5 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 750 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 250

SWEP.Primary.Ammo = "Pistol Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/pistol.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/pistol.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_pistol"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 95
SWEP.ShellScale = 2

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .85
SWEP.SightTime = .35

SWEP.IronSightStruct = {
    Pos = Vector(-3.79, 0, 1.6),
    Ang = Angle(.5, 0, -5),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, 0, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(4, -4, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 25

--[[
idle
reload_full
reload_empty
draw1
draw2
shoot1
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw1",
        Time = 0.45,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw2",
        Time = 0.45,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "shoot1",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["fire_iron"] = {
        Source = "shoot1",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["reload"] = {
        Source = "reload_full",
        Time = 2.5,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.move, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/smg/out.wav", t = .2, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .7, v=65, p=110},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 1.3, v=55, p=120},
			{s = "snds_jack_gmod/ez_weapons/smg/in.wav", t = 1.6, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 2.15, v=60}
		}
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 3.1,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.move, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/smg/out.wav", t = .1, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .7, v=65, p=110},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 1.45, v=55, p=120},
			{s = "snds_jack_gmod/ez_weapons/smg/in.wav", t = 1.7, v=65},
			{s = "snds_jack_gmod/ez_weapons/smg/pull.wav", t = 2.15, v=65},
			{s = "snds_jack_gmod/ez_weapons/smg/release.wav", t = 2.35, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 2.65, v=60}
		}
    },
}