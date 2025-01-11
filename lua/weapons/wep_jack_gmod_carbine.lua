SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Carbine"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_car", true)
SWEP.Slot = 2
SWEP.ViewModel = "models/weapons/v_cod4_g36.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_g36.mdl"
SWEP.ViewModelFOV = 65
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 10)
SWEP.BodyHolsterAngL = Angle(10, -75, 180)
SWEP.BodyHolsterPos = Vector(.5, -11, -11)
SWEP.BodyHolsterPosL = Vector(.5, -11, 11)
SWEP.BodyHolsterScale = .8
JMod.ApplyAmmoSpecs(SWEP, "Light Rifle Round", .8)
SWEP.Primary.ClipSize = 30 -- DefaultClip is automatically set.
SWEP.Recoil = .4
SWEP.Delay = 60 / 800 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 2,
		PrintName = "FULL-AUTO"
	},
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 4 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/light_rifle.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/light_rifle.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_4"
SWEP.ShellModel = "models/jhells/shell_556.mdl"
SWEP.ShellPitch = 95
SWEP.ShellScale = 1.75
SWEP.ShellOffsetFix = Vector(0, 0, -3)
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .8
SWEP.SightTime = .4

SWEP.IronSightStruct = {
	Pos = Vector(-3.55, -1, .4),
	Ang = Angle(-.5, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1.5, 0, .5)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(4, -4, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 28

SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["draw"] = {
		Source = "draw1",
		Time = 1,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60,
				p = 110
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "shoot1",
		Time = 0.4,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
	},
	["reload"] = {
		Source = "reload_full",
		Time = 2.5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/carbine/mag_out.ogg",
				t = .3,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .4,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 1.3,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/carbine/mag_in.ogg",
				t = 1.5,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.15,
				v = 60
			}
		}
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 3.1,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/carbine/mag_out.ogg",
				t = .3,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .4,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 1.1,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/carbine/mag_in.ogg",
				t = 1.25,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/carbine/bolt_pull.ogg",
				t = 1.95,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/carbine/bolt_release.ogg",
				t = 2.2,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.6,
				v = 60
			}
		}
	},
}
