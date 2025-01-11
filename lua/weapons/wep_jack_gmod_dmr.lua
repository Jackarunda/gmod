SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Designated Marksman Rifle"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_dmr", true)
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/c_mw2_m21ebr.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m21.mdl"
SWEP.ViewModelFOV = 73
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 0)
SWEP.BodyHolsterAngL = Angle(0, -75, 190)
SWEP.BodyHolsterPos = Vector(3, -10, -9)
SWEP.BodyHolsterPosL = Vector(4, -10, 9)
SWEP.BodyHolsterScale = .95
SWEP.DefaultBodygroups = "01000"
JMod.ApplyAmmoSpecs(SWEP, "Medium Rifle Round")
SWEP.Primary.ClipSize = 15 -- DefaultClip is automatically set.
SWEP.Recoil = 1.2
SWEP.Delay = 60 / 550 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 2 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
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
SWEP.SightedSpeedMult = .6
SWEP.SightTime = .6

SWEP.IronSightStruct = {
	Pos = Vector(-3.75, 0, .5),
	Ang = Angle(-.1, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(.5, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 46

SWEP.Attachments = {
	{
		PrintName = "Optic",
		DefaultAttName = "Iron Sights",
		Slot = {"ez_optic"},
		Bone = "tag_weapon",
		Offset = {
			vang = Angle(0, 0, 0),
			vpos = Vector(10, 0, 3.8),
			wpos = Vector(10, .8, -7),
			wang = Angle(-10.393, 0, 180)
		},
		-- remove Slide because it ruins my life
		Installed = "optic_jack_scope_low"
	}
}

-- extra anims: holster, sprint
SWEP.Animations = {
	["idle"] = {
		Source = "idle",
		Time = 1
	},
	["draw"] = {
		Source = "draw",
		Time = 2,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60,
				p = 90
			}
		},
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "fire",
		Time = 0.4,
		ShellEjectAt = 0,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
	},
	["reload"] = {
		Source = "reload_tac",
		Time = 3.2,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71},
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/dmr/magout.ogg",
				t = .65,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.2,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/dmr/magin.ogg",
				t = 2,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.8,
				v = 60
			}
		}
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 4.2,
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
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/dmr/magout.ogg",
				t = .65,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.2,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/dmr/magin.ogg",
				t = 2.05,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.75,
				v = 50
			},
			{
				s = "snds_jack_gmod/ez_weapons/dmr/boltpull.ogg",
				t = 3.25,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/dmr/boltrelease.ogg",
				t = 3.5,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 3.95,
				v = 50,
				p = 120
			}
		}
	},
}
