SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Pistol"

SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/c_bo2_b23r_1.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_b23r.mdl"
SWEP.ViewModelFOV = 75

SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90,90,-20)
SWEP.BodyHolsterAngL = Angle(90,90,-20)
SWEP.BodyHolsterPos = Vector(-5,17,-6)
SWEP.BodyHolsterPosL = Vector(-7,17,1.5)
SWEP.BodyHolsterScale = 1.1

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"

SWEP.Damage = 25
SWEP.DamageMin = 10 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 100 -- in METERS
SWEP.Penetration = 20

SWEP.Primary.ClipSize = 15 -- DefaultClip is automatically set.

SWEP.Recoil = .7
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 450 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 9 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

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
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .25

SWEP.IronSightStruct = {
    Pos = Vector(-2.4, 7, .5),
    Ang = Angle(-.1, 0, -2),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.minor,
    SwitchFromSound = JMod_GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(1, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)

SWEP.BarrelLength = 20

--[[
idle
draw
draw_first
reload_empty
reload_tac
fire
holster
sprint
idle_empty
holster_empty
draw_empty
fire_last
reload_fm_empty
reload_fm_tac
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
        Time = 0.25,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["draw_empty"] = {
        Source = "draw_empty",
        Time = 0.25,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120}},
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw_first",
		SoundTable = {
			{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/pistol/safety.wav", t = .25, v=60}
		},
        Time = 0.75,
		Mult=2,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["fire_empty"] = {
        Source = "fire_last",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["reload"] = {
        Source = "reload_tac",
        Time = 2,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = "snds_jack_gmod/ez_weapons/pistol/out.wav", t = 0, v=60},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .2, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/pistol/tap.wav", t = .7, v=60},
			{s = "snds_jack_gmod/ez_weapons/pistol/in.wav", t = .65, v=60}
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
			{s = "snds_jack_gmod/ez_weapons/pistol/out.wav", t = 0, v=60},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .2, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/pistol/tap.wav", t = .7, v=60},
			{s = "snds_jack_gmod/ez_weapons/pistol/in.wav", t = .75, v=60},
			{s = "snds_jack_gmod/ez_weapons/pistol/release.wav", t = 1.575, v=60, p=90}
		}
    }
}