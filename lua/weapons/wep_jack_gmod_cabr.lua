SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Cap and Ball Revolver"

SWEP.Slot = 1

SWEP.ViewModel = "models/krazy/gtav/weapons/navyrevolver_v.mdl"
SWEP.WorldModel = "models/krazy/gtav/weapons/navyrevolver_w.mdl"
SWEP.ViewModelFOV = 75

SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90,90,-20)
SWEP.BodyHolsterAngL = Angle(90,90,-20)
SWEP.BodyHolsterPos = Vector(-5,17,-6.5)
SWEP.BodyHolsterPosL = Vector(-7,17,1.5)
SWEP.BodyHolsterScale = 1

SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"

SWEP.Damage = 30
SWEP.DamageMin = 10 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 75 -- in METERS
SWEP.Penetration = 10

SWEP.HipDispersion = 1100

SWEP.Primary.ClipSize = 6 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- revolver lol

SWEP.Recoil = 1.5

SWEP.Delay = 60 / 60 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
		PrintName = "SINGLE-ACTION"
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 15 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

SWEP.Primary.Ammo = "Black Powder Paper Cartridge" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/caplock_handgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/caplock_handgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_pistol"
SWEP.ExtraMuzzleLua = "eff_jack_gmod_bpmuzzle"
SWEP.ExtraMuzzleLuaScale = .5

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .25

SWEP.IronSightStruct = {
    Pos = Vector(-4.2, 5, 2),
    Ang = Angle(-.2, -.0, -2),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.minor,
    SwitchFromSound = JMod_GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 0, 0)
SWEP.ActiveAng = Angle(0, 0, 0)

SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4

SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)

SWEP.BarrelLength = 20

--[[
idle
idle_empty
draw
draw_empty
fire
iron_fire
fire_empty
dryfire
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
    ["draw"] = {
        Source = "draw",
        Time = 0.5,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.handgun, t = 0, v=60, p=110}},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["fire"] = {
        Source = "fire",
        Time = 1,
		Mult = 1
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 1,
		Mult = 1
    },
    ["reload"] = {
        Source = "reload",
        Time = 7,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			--[[
			{s = JMod_GunHandlingSounds.cloth.move, t = 0, v=55, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/open.wav", t = .25, v=60},
			{s = JMod_GunHandlingSounds.cloth.move, t = 1.1, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/out.wav", t = 1.5, v=55},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.6, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/revolver/in.wav", t = 2, v=60},
			{s = "snds_jack_gmod/ez_weapons/revolver/close.wav", t = 2.7, v=60},
			{s = JMod_GunHandlingSounds.grab, t = 3, v=55, p=110}
			--]]
		}
    }
}