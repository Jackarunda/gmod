SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Fully-Automatic Shotgun"

SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/c_mw2_aa12_6.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_fullautoshotty.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 0)
SWEP.BodyHolsterAngL = Angle(0,-75,170)
SWEP.BodyHolsterPos = Vector(.5,-16,-10)
SWEP.BodyHolsterPosL = Vector(-1,-15,12)
SWEP.BodyHolsterScale = 1

SWEP.Damage = 12
SWEP.DamageMin = 2 -- damage done at maximum range
SWEP.DamageRand = .35
SWEP.Range = 75 -- in METERS
SWEP.DamageType = DMG_BUCKSHOT
SWEP.Penetration = 15
SWEP.DoorBreachPower = .2

SWEP.Primary.ClipSize = 12 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- lol open bolt

SWEP.Recoil = 2.8
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6


SWEP.Delay = 60 / 400 -- 60 / RPM.
SWEP.Num = 9 -- number of projectiles per shot
SWEP.Firemodes = {
    {
        Mode = 2,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 40 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Shotgun Round" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/auto_shotgun.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/auto_shotgun.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_m3"
SWEP.ShellModel = "models/jhells/shell_12gauge.mdl"
SWEP.ShellPitch = 90
if(ArcCW)then SWEP.ShellSounds = ArcCW.ShotgunShellSoundsTable end
SWEP.ShellScale = 3

SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .55

SWEP.IronSightStruct = {
    Pos = Vector(-3.1, .5, .42),
    Ang = Angle(0, 0, -5),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 35

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
        Source = "draw",
        Time = 0.6,
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60}},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.3,
        ShellEjectAt = .05,
    },
    ["fire_iron"] = {
        Source = "fire",
        Time = 0.3,
        ShellEjectAt = .05,
    },
    ["fire_empty"] = {
        Source = "fire",
        Time = 0.3,
		ShellEjectAt = .05
    },
    ["reload"] = {
        Source = "reload_tac",
        Time = 3,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/fas/out.wav", t = .6, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.3, v=65},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 1.95, v=65},
			{s = "snds_jack_gmod/ez_weapons/fas/in.wav", t = 2.15, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 2.55, v=65}
		}
    },
    ["reload_empty"] = {
        Source = "reload_empty",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=60},
			{s = "snds_jack_gmod/ez_weapons/fas/out.wav", t = .6, v=65},
			{s = JMod_GunHandlingSounds.cloth.magpull, t = 1.3, v=65},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 1.95, v=65},
			{s = "snds_jack_gmod/ez_weapons/fas/in.wav", t = 2.15, v=65},
			{s = JMod_GunHandlingSounds.tap.magwell, t = 2.75, v=60, p=110},
			{s = "snds_jack_gmod/ez_weapons/fas/pull.wav", t = 2.85, v=65},
			{s = JMod_GunHandlingSounds.cloth.loud, t = 2.8, v=55},
			{s = JMod_GunHandlingSounds.grab, t = 3.55, v=65}
		}
    }
}