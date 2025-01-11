SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Sub Machine Gun"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_smg", true)
SWEP.Slot = 2
SWEP.ViewModel = "models/weapons/v_cod4_mp5_c.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_mp5.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 10)
SWEP.BodyHolsterAngL = Angle(10, -75, 180)
SWEP.BodyHolsterPos = Vector(.5, -11, -11)
SWEP.BodyHolsterPosL = Vector(.5, -11, 11)
SWEP.BodyHolsterScale = .9
JMod.ApplyAmmoSpecs(SWEP, "Pistol Round", 1.1)
SWEP.Primary.ClipSize = 35 -- DefaultClip is automatically set.
SWEP.Recoil = .3
SWEP.VisualRecoilMult = .5
SWEP.Delay = 60 / 1000 -- 60/RPM.

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

SWEP.AccuracyMOA = 5 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/pistol.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/pistol.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol"
SWEP.ShellModel = "models/jhells/shell_9mm.mdl"
SWEP.ShellPitch = 95
SWEP.ShellScale = 2
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .85
SWEP.SightTime = .35

SWEP.IronSightStruct = {
	Pos = Vector(-3.79, 0, 1.6),
	Ang = Angle(.5, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.Attachments = {
	{
		PrintName = "Optic",
		DefaultAttName = "Iron Sights",
		Slot = {"ez_optic"},
		Bone = "tag_weapon",
		Offset = {
			vang = Angle(0, 0, 0),
			vpos = Vector(-5.5, 0, 3.4),
			wpos = Vector(0, 0, 0),
			wang = Angle(0, 0, 0)
		},
		-- remove Slide because it ruins my life
		Installed = "optic_jack_reddot",
		InstalledEles = {"mount"}
	}
}

SWEP.AttachmentElements = {
	["mount"] = {
		VMElements = {
			{
				Model = "models/weapons/arccw/atts/mount_rail.mdl",
				Bone = "tag_weapon",
				Scale = Vector(1, 1, 1),
				Offset = {
					pos = Vector(-5, 0, 3.1),
					ang = Angle(0, 0, 0)
				}
			}
		},
	}
}

SWEP.ActivePos = Vector(0, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(4, -4, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 25

--[[
idle
reload_full
reload_empty
draw1
draw2
shoot1
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
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60,
				p = 120
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
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/smg/out.ogg",
				t = .2,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .7,
				v = 65,
				p = 110
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 1.3,
				v = 55,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/smg/in.ogg",
				t = 1.6,
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
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/smg/out.ogg",
				t = .1,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .7,
				v = 65,
				p = 110
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 1.45,
				v = 55,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/smg/in.ogg",
				t = 1.7,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/smg/pull.ogg",
				t = 2.15,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/smg/release.ogg",
				t = 2.35,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.65,
				v = 60
			}
		}
	},
}
