SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Magnum Pistol"

SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/c_mw2_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_deagle.mdl"
SWEP.ViewModelFOV = 70

SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90,90,-20)
SWEP.BodyHolsterAngL = Angle(90,90,-20)
SWEP.BodyHolsterPos = Vector(-5,17,-6)
SWEP.BodyHolsterPosL = Vector(-7,17,2.25)
SWEP.BodyHolsterScale = 1.2

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"

SWEP.Damage = 41
SWEP.DamageMin = 10 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 150 -- in METERS
SWEP.Penetration = 30

SWEP.Primary.ClipSize = 9 -- DefaultClip is automatically set.

SWEP.Recoil = 1.8
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 325 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 7 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Magnum Pistol Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/magnum_pistol.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/magnum_pistol.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_pistol_deagle"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 3.5

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .5

SWEP.IronSightStruct = {
    Pos = Vector(-1.71, 5, .94),
    Ang = Angle(-.1, 0, -2),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.minor,
    SwitchFromSound = JMod_GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 20

--[[
idle
reload_empty
reload_tac
draw
fire
holster
sprint
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["idle_empty"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw",
        Time = 0.5,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["draw_empty"] = {
        Source = "draw",
        Time = 0.5,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw",
		SoundTable = {
			{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}
		},
        Time = 0.5,
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["fire_empty"] = {
        Source = "fire",
        Time = 0.4,
        ShellEjectAt = 0,
    },
    ["reload"] = {
        Source = "reload_tac",
        Time = 3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.move, t = .05, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/magnumpistol/out.wav", t = .3, v=60},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1, v=60, p=110},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 1.6, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/magnumpistol/in.wav", t = 1.85, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 2.3, v=55, p=110}
		}
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.move, t = .05, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/magnumpistol/out.wav", t = .4, v=60},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.1, v=60, p=110},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 2.1, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/magnumpistol/in.wav", t = 2.4, v=60},
			{s = "snds_jack_gmod/ez_weapons/magnumpistol/release.wav", t = 2.75, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 3.15, v=55, p=110}
		}
    }
}