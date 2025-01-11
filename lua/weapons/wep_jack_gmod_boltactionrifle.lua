SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Bolt-Action Rifle"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_bar", true)
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/v_cod4_r700.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_r700.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 0)
SWEP.BodyHolsterAngL = Angle(0, -75, 190)
SWEP.BodyHolsterPos = Vector(2.5, -10, -9)
SWEP.BodyHolsterPosL = Vector(3.5, -10, 9)
SWEP.BodyHolsterScale = .95
JMod.ApplyAmmoSpecs(SWEP, "Medium Rifle Round", 1.2)
SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.
SWEP.Recoil = 1.5
SWEP.ChamberSize = 0 -- this is so wrong, Arctic...
SWEP.Delay = 60 / 50 -- 60/RPM.

SWEP.Firemodes = {
	{
		PrintName = "BOLT-ACTION",
		Mode = 1,
	},
	{
		Mode = 0
	}
}

SWEP.ShotgunReload = true
SWEP.AccuracyMOA = 1 -- real bolt guns are more accurate than this, but whatever... gmod
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_g3"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 2
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .65
SWEP.SightTime = .6

SWEP.IronSightStruct = {
	Pos = Vector(-4.6, 0, 2.5),
	Ang = Angle(.5, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 48

SWEP.Attachments = {
	{
		PrintName = "Optic",
		DefaultAttName = "Iron Sights",
		Slot = {"ez_optic"},
		Bone = "tag_weapon",
		Offset = {
			vang = Angle(0, 0, 0),
			vpos = Vector(-3, 0, 2.6),
			wpos = Vector(10, .8, -6),
			wang = Angle(-10.393, 0, 180)
		},
		-- remove Slide because it ruins my life
		Installed = "optic_jack_scope_mediumlow"
	}
}

-- idle
-- reload_full
-- reload_start
-- reload_end
-- draw1
-- shoot1
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["draw"] = {
		Source = "draw1",
		Time = 1.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60
			}
		},
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "shoot1",
		Time = 1.1,
		ShellEjectAt = .4,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/bar/lift.wav",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/pull.ogg",
				t = .3,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/push.ogg",
				t = .5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/lock.ogg",
				t = .6,
				v = 60
			}
		}
	},
	["fire_iron"] = {
		Source = "shoot1",
		Time = 1.4,
		ShellEjectAt = .5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/bar/lift.wav",
				t = .15,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/pull.ogg",
				t = .4,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/push.ogg",
				t = .7,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/lock.ogg",
				t = .8,
				v = 60
			}
		}
	},
	["sgreload_start"] = {
		Source = "reload_start",
		Time = 1.1,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/lift.wav",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/pull.ogg",
				t = .55,
				v = 60
			}
		}
	},
	["sgreload_insert"] = {
		Source = "reload_full",
		Time = .9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		TPAnimStartTime = 0.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/bar/insert.ogg",
				t = .1,
				v = 60
			}
		}
	},
	["sgreload_finish"] = {
		Source = "reload_end",
		Time = 1.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.4,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/bar/push.ogg",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/lock.ogg",
				t = .45,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 1,
				v = 60
			}
		}
	},
	["sgreload_finish_empty"] = {
		Source = "reload_end",
		Time = 1.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 1,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/bar/push.ogg",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/bar/lock.ogg",
				t = .45,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 1,
				v = 60
			}
		}
	}
}
