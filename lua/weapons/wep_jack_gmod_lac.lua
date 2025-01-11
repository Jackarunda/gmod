SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Lever-Action Carbine"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_lac", true)
SWEP.Slot = 2
SWEP.ViewModel = "models/weapons/v_win73.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_levergun.mdl"
SWEP.ViewModelFOV = 60
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(30, 75, -30)
SWEP.BodyHolsterAngL = Angle(150, 75, 30)
SWEP.BodyHolsterPos = Vector(4, 1, -5)
SWEP.BodyHolsterPosL = Vector(5, 1, 5)
SWEP.BodyHolsterScale = .85
JMod.ApplyAmmoSpecs(SWEP, "Magnum Pistol Round", 1.2)
SWEP.Primary.ClipSize = 9 -- DefaultClip is automatically set.
SWEP.Recoil = 1.2
SWEP.ShotgunReload = true
SWEP.Delay = 60 / 60 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "LEVER-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 5 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/magnum_revolver.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/magnum_revolver.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1 -- fix calcview reload bob lol
SWEP.MuzzleEffect = "muzzleflash_ak47"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 3.5
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .8
SWEP.SightTime = .45

SWEP.IronSightStruct = {
	Pos = Vector(-3.138, .5, 1.3),
	Ang = Angle(.5, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 0, 0)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 35

--[[
idle
fire1
dryfire
draw
holster
reload_start
reload
reload_end
Walk
--]]
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 100
	},
	["draw"] = {
		Source = "draw",
		Time = 1.2,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "fire1",
		Time = 1.1,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/lac/back.ogg",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/lac/forward.ogg",
				t = .5,
				v = 60
			}
		},
		ShellEjectAt = .45,
	},
	["sgreload_start"] = {
		Source = "reload_start",
		Time = 0.6,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 0,
				v = 65
			}
		}
	},
	["sgreload_start_empty"] = {
		Source = "reload_start",
		Time = .6,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		RestoreAmmo = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 0,
				v = 65
			}
		}
	},
	["sgreload_insert"] = {
		Source = "reload",
		Time = .9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		TPAnimStartTime = 0.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.shotshell,
				t = .2,
				v = 60,
				p = 130
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .8,
				v = 65,
				p = 120
			}
		}
	},
	["sgreload_finish"] = {
		Source = "reload_end",
		Time = .6,
		LHIK = true,
		LHIKIn = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.grab,
				t = 0.3,
				v = 65
			}
		},
		LHIKOut = 0.4,
	}
}
