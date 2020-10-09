SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Plinking Pistol"

SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/v_jmod_usp.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_usp.mdl"
SWEP.ViewModelFOV = 75

--[[ -- pocket pistol goes in pocket ^:)
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90,90,-20)
SWEP.BodyHolsterAngL = Angle(90,90,-20)
SWEP.BodyHolsterPos = Vector(-5,17,-6)
SWEP.BodyHolsterPosL = Vector(-7,17,2.25)
SWEP.BodyHolsterScale = 1.1
--]]

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"

SWEP.Damage = 10
SWEP.DamageMin = 2 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 50 -- in METERS
SWEP.Penetration = 10

SWEP.Primary.ClipSize = 10 -- DefaultClip is automatically set.

SWEP.Recoil = .1
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 500 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 10 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Plinking Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/plinker.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/plinker.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_suppressed"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 120
SWEP.ShellScale = 1

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .25

SWEP.IronSightStruct = {
    Pos = Vector(-2.89, 4, 2.1),
    Ang = Angle(-1, 0, 0),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.minor,
    SwitchFromSound = JMod_GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(1, 1, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)

SWEP.BarrelLength = 20

--[[
idle
reload_full
reload_empty
draw2
shoot1
dry
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
        Source = "draw2",
        Time = 0.15,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["draw_empty"] = {
        Source = "draw2",
        Time = 0.15,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw2",
        Time = 0.15,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["fire"] = {
        Source = "shoot1",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["fire_iron"] = {
        Source = "shoot1",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["fire_empty"] = {
        Source = "dry",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["reload"] = {
        Source = "reload_full",
        Time = 2,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/pistol/out.wav", t = 0, v=60, p=120},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .4, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/pistol/tap.wav", t = .85, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/pistol/in.wav", t = .85, v=60, p=120}
		}

    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 2.5,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/pistol/out.wav", t = 0, v=60, p=120},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .4, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/pistol/tap.wav", t = .95, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/pistol/in.wav", t = 1, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/pistol/release.wav", t = 1.75, v=60, p=120}
		}
    }
}