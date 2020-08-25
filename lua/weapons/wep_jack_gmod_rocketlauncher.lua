SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Rocket Launcher"

SWEP.Slot = 4

SWEP.ViewModel = "models/weapons/v_mw2_at4_new.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_at4.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-105,0)
SWEP.BodyHolsterAngL = Angle(0,-75,160)
SWEP.BodyHolsterPos = Vector(-.5,-22,-13)
SWEP.BodyHolsterPosL = Vector(-3,-24,11)
SWEP.BodyHolsterScale = 1.1

SWEP.Damage = 300
SWEP.BlastRadius = 220
SWEP.DamageRand = .1
SWEP.BlastRadiusRand = .1
SWEP.ShootEntity = "ent_jack_gmod_ezminirocket"
SWEP.MuzzleVelocity = 2000
SWEP.ShootEntityAngle = Angle(0,-90,0)
SWEP.BackBlast = 1

SWEP.Primary.ClipSize = 1 -- DefaultClip is automatically set.

SWEP.Recoil = 1
SWEP.RecoilSide = 0.5
SWEP.RecoilRise = 0.6

SWEP.Delay = 60 / 100 -- 60 / RPM.
SWEP.Num = 1 -- number of shots per trigger pull.
SWEP.Firemodes = {
    {
        Mode = 1,
    },
    {
        Mode = 0
    }
}

SWEP.AccuracyMOA = 15 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.HipDispersion = 600 -- inaccuracy added by hip firing.
SWEP.MoveDispersion = 200

SWEP.Primary.Ammo = "Mini Rocket" -- what ammo type the gun uses

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/rocket_fire.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/rocket_fire.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1
SWEP.ShakeOnShoot = 1

SWEP.HoldtypeActive = "rpg"
SWEP.HoldtypeSights = "rpg"

SWEP.MuzzleEffect = "muzzleflash_m79"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 50
SWEP.ShellScale = 7

SWEP.SpeedMult = .95
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .7

SWEP.IronSightStruct = {
    Pos = Vector(-1.7, -3, -.6),
    Ang = Angle(13.4, -10.1, -10),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, -2, 0)
SWEP.ActiveAng = Angle(13, -10, 0)

SWEP.HolsterPos = Vector(6, -1, -4)
SWEP.HolsterAng = Angle(0, 50, 0)

SWEP.MeleeAttackTime=.35

SWEP.BarrelLength = 40

--[[
idle
reload_tac
draw1
fire
holster
--]]
SWEP.Animations = {
    ["idle"] = {
        Source = "idle",
        Time = 1
    },
    ["draw"] = {
        Source = "draw1",
        Time = 1,
        SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=90},
			{s = JMod_GunHandlingSounds.cloth.quiet, t = .05, v=65, p=90},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/open.wav", t = .15, v=65},
			{s = JMod_GunHandlingSounds.grab, t = .4, v=60},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/press.wav", t = .55, v=65},
			{s = JMod_GunHandlingSounds.cloth.move, t = .8, v=60}
		},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["ready"] = {
        Source = "draw1",
        Time = 1,
        SoundTable = {
			{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=90},
			{s = JMod_GunHandlingSounds.cloth.quiet, t = .05, v=65, p=90},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/open.wav", t = .15, v=65},
			{s = JMod_GunHandlingSounds.grab, t = .4, v=60},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/press.wav", t = .55, v=65},
			{s = JMod_GunHandlingSounds.cloth.move, t = .8, v=60}
		},
		Mult=2.5,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.25,
    },
    ["fire"] = {
        Source = "",
        Time = 2
    },
    ["fire_iron"] = {
        Source = "",
        Time = 2
    },
    ["reload_empty"] = {
        Source = "reload_tac",
        Time = 4,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71, 89},
        FrameRate = 37,
		Mult=1.2,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = .05, v=60},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/move1.wav", t = .05, v=65},
			{s = JMod_GunHandlingSounds.cloth.quiet, t = 1, v=60},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/move2.wav", t = 1, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 2, v=65},
			{s = JMod_GunHandlingSounds.cloth.loud, t = 2.5, v=60},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/open.wav", t = 2.6, v=65},
			{s = "snds_jack_gmod/ez_weapons/rocketlauncher/press.wav", t = 3, v=65},
			{s = JMod_GunHandlingSounds.cloth.move, t = 3.7, v=60},
		}
    },
}