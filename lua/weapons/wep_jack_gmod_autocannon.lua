SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Autocannon"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_autocannon", true)
SWEP.Slot = 4
SWEP.ViewModel = "models/weapons/jautocannon_v.mdl"
SWEP.WorldModel = "models/weapons/jautocannon_w.mdl"
SWEP.ViewModelFOV = 80
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 0)
SWEP.BodyHolsterAngL = Angle(20, -75, 180)
SWEP.BodyHolsterPos = Vector(2, -15, -13)
SWEP.BodyHolsterPosL = Vector(0, -15, 14)
SWEP.BodyHolsterScale = .8
JMod.ApplyAmmoSpecs(SWEP, "Autocannon Round", 1)
SWEP.DamageRand = .1
SWEP.ShootEntity = "ent_jack_gmod_ezautocannonshot"
SWEP.MuzzleVelocity = 20000
SWEP.ShootEntityAngle = Angle(0, -90, 0)
SWEP.ShootEntityOffset = Vector(10, 0, 0)
SWEP.ShootEntityAngleCorrection = Angle(0, -90, 0)
SWEP.Primary.ClipSize = 10 -- DefaultClip is automatically set.
SWEP.ChamberSize = 1 -- sigh arctic
SWEP.Recoil = 4
SWEP.VisualRecoilMult = 2
SWEP.Delay = .3
SWEP.ShotgunReload = false

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 2,
		PrintName = "FULL-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 5 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/autocannon/shoot.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/autocannon/shoot.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/autocannon/shoot_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.ShakeOnShoot = .5
SWEP.HoldtypeActive = "rpg"
SWEP.HoldtypeSights = "rpg"
SWEP.MuzzleEffect = "muzzle_center_M82"
SWEP.ShellModel = "models/weapons/jautocannonshell.mdl"
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.ShellPitch = 60
SWEP.ShellScale = 1.5
SWEP.SpeedMult = .8
SWEP.SightedSpeedMult = .6
SWEP.SightTime = .9

SWEP.IronSightStruct = {
	Pos = Vector(0, 0, 0),
	Ang = Angle(0, 0, 0),
	Magnification = 1.2,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(2, -5, 3)
SWEP.ActiveAng = Angle(0, 0, 15)
SWEP.HolsterPos = Vector(2, -5, -2)
SWEP.HolsterAng = Angle(-30, 60, 0)
SWEP.BarrelLength = 50

--[[
idle
shoot
reload
reload2
deploy
--]]
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["draw"] = {
		Source = "deploy",
		Time = 2,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = .01,
				v = 60,
				p = 90
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = .425,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .5,
				v = 65
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "shoot",
		Time = .3,
		ShellEjectAt = .05,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG
	},
	["reload"] = {
		Source = "reload",
		Time = 3,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .01,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = .1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_draw.ogg",
				t = .5,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .6,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_load.ogg",
				t = .7,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 2,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.8,
				v = 60
			}
		}
	},
	["reload_empty"] = {
		Source = "reload2",
		Time = 5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .01,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = .1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_draw.ogg",
				t = .5,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .6,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_load.ogg",
				t = .7,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = .9,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/cycle.ogg",
				t = 1.8,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_draw.ogg",
				t = 2.6,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 2.8,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_load.ogg",
				t = 3,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 3.5,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 4.8,
				v = 60
			}
		}
	},
	["sgreload_start"] = {
		RestoreAmmo = 5,
		Source = "reload",
		Time = 3,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .01,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = .1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_draw.ogg",
				t = .5,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .6,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_load.ogg",
				t = .7,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 2,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.8,
				v = 60
			}
		}
	},
	["sgreload_insert"] = {
		RestoreAmmo = 5,
		Source = "reload",
		Time = 3,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .01,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = .1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_draw.ogg",
				t = .5,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = .6,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/autocannon/clip_load.ogg",
				t = .7,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 2,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.8,
				v = 60
			}
		}
	}
}
