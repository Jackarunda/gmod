SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Single-Shot Rifle"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/c_snip_blast_martini-henry_arccw.mdl"
SWEP.WorldModel = "models/weapons/w_snip_blast_martini-henry_arccw.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(185,15,180)
SWEP.BodyHolsterAngL = Angle(0,195,170)
SWEP.BodyHolsterPos = Vector(2,-11,-11)
SWEP.BodyHolsterPosL = Vector(1,-11,11)
SWEP.BodyHolsterScale = .9

SWEP.Damage = 84
SWEP.DamageMin = 15 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 300 -- in METERS
SWEP.Penetration = 55

SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.

SWEP.Recoil = 1.3
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 550 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 3 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Medium Rifle Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_m14"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 2

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .6

SWEP.IronSightStruct = {
    Pos = Vector(-4.4, 1, 1.35),
    Ang = Angle(.1, 0, -5),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, -4)
SWEP.HolsterAng = Angle(0, 50, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 44

--[[
idle
draw
draw_e
holster
shoot
shoot_i
reload
bash
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
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
    ["ready"] = {
        Source = "draw_e",
        Time = 0.6,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "shoot",
        Time = 0.5
    },
    ["fire_iron"] = {
        Source = "shoot",
        Time = 0.5
    },
    ["reload_empty"] = {
        Source = "reload",
        Time = 3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		ShellEjectAt = .8,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=65},
			{s = "snds_jack_gmod/ez_weapons/ssr/open.wav", t = .4, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = .75, v=60, p=120},
			{s = "snds_jack_gmod/ez_weapons/ssr/align.wav", t = 1.15, v=60},
			{s = "snds_jack_gmod/ez_weapons/ssr/in.wav", t = 1.45, v=65},
			{s = "snds_jack_gmod/ez_weapons/ssr/close.wav", t = 2, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 2.6, v=60}
		}
    },
}