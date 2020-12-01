SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Revolver"

SWEP.Slot = 1

SWEP.ViewModel = "models/weapons/c_bo1_python.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_revolver.mdl"
SWEP.ViewModelFOV = 70

SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90,90,-20)
SWEP.BodyHolsterAngL = Angle(90,90,-20)
SWEP.BodyHolsterPos = Vector(-5,17,-6.5)
SWEP.BodyHolsterPosL = Vector(-7,17,1.5)
SWEP.BodyHolsterScale = 1

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"

SWEP.Damage = 26
SWEP.DamageMin = 10 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 100 -- in METERS
SWEP.Penetration = 20

SWEP.HipDispersion = 1100

SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- revolver lol

SWEP.Recoil = .7

SWEP.Delay = 60 / 300 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
		PrintName = "DOUBLE-ACTION"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 6 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

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
    Pos = Vector(-2.21, 6, 1.05),
    Ang = Angle(-.7, -.15, -2),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.minor,
    SwitchFromSound = JMod_GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)

SWEP.RevolverReload=true

SWEP.BarrelLength = 20

--[[
idle
reload_tac
draw
draw_first
fire
holster
sprint
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw",
        Time = 0.3,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=110}},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw_first",
		SoundTable = {
			{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/open.wav", t = .3, v=55, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/fidget.wav", t = .4, v=55, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/close.wav", t = .6, v=50, p=110}
		},
        Time = 2.5,
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.4
    },
    ["reload"] = {
        Source = "reload_tac",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		ShellEjectAt = 2,
		ShellEjectCount=6,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.move, t = 0, v=55, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/open.wav", t = .4, v=60},
			{s = JMod_GunHandlingSounds.cloth.move, t = 1.3, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/out.wav", t = 1.7, v=55},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.8, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/in.wav", t = 2.45, v=60},
			{s = "snds_jack_gmod/ez_weapons/revolver/close.wav", t = 3.25, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 3.8, v=55, p=110}
		}
    }
}