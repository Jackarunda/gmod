SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Anti-Materiel Sniper Rifle"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_amsr", true)
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/c_mw2_intervention.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_intervention.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 0)
SWEP.BodyHolsterAngL = Angle(0, -75, 190)
SWEP.BodyHolsterPos = Vector(2.5, -10, -9)
SWEP.BodyHolsterPosL = Vector(3.5, -10, 9)
SWEP.BodyHolsterScale = 1
SWEP.DefaultBodygroups = "01000"
JMod.ApplyAmmoSpecs(SWEP, "Heavy Rifle Round", 1.1)
SWEP.Primary.ClipSize = 3 -- DefaultClip is automatically set.
SWEP.Recoil = 2
SWEP.VisualRecoilMult = 2
SWEP.BipodRecoil = 1
SWEP.ChamberSize = 1 -- this is so wrong, Arctic...
SWEP.Delay = 60 / 24 -- 60/RPM.

SWEP.Firemodes = {
	{
		PrintName = "BOLT-ACTION",
		Mode = 1,
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 1 -- real bolt guns are more accurate than this, but whatever... gmod
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/heavy_rifle.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/heavy_rifle.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.ogg"
SWEP.ShootSoundExtraMult = 2
SWEP.MuzzleEffect = "muzzle_center_M82"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 70
SWEP.ShellScale = 4
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.SpeedMult = .9
SWEP.SightedSpeedMult = .5
SWEP.SightTime = .75

SWEP.IronSightStruct = {
	Pos = Vector(-3.75, 0, .5),
	Ang = Angle(-.1, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(.5, -.8, 2)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, -6, 0)
SWEP.HolsterAng = Angle(-20, 60, 0)
SWEP.BarrelLength = 65

SWEP.Attachments = {
	{
		PrintName = "Optic",
		DefaultAttName = "Iron Sights",
		Slot = {"ez_optic"},
		Bone = "tag_weapon",
		Offset = {
			vang = Angle(0, 0, 0),
			vpos = Vector(4.3, 0, 3.1),
			wpos = Vector(10, .5, -7),
			wang = Angle(-10.393, 0, 180)
		},
		-- remove Slide because it ruins my life
		Installed = "optic_jack_scope_medium"
	},
	{
		PrintName = "Underbarrel",
		Slot = {"ez_bipod"},
		Bone = "tag_weapon",
		Offset = {
			vpos = Vector(16, 0, -2),
			vang = Angle(0, 0, 0),
			wpos = Vector(31, .6, -7),
			wang = Angle(170, 0, 0)
		},
		-- remove Slide because it ruins my life
		Installed = "underbarrel_jack_bipod"
	}
}

--idle
--reload_empty
--reload_tac
--draw
--fire
--holster
--sprint
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
				p = 80
			}
		},
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "fire",
		Time = 2.5,
		Mult = 1,
		ShellEjectAt = 1.1,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/amsr/up.ogg",
				t = .75,
				v = 60,
				p = 90
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/back.ogg",
				t = 0.8,
				v = 60,
				p = 90
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/forward.ogg",
				t = 1.6,
				v = 60,
				p = 90
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/down.ogg",
				t = 1.8,
				v = 60,
				p = 90
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.25,
				v = 55
			}
		}
	},
	["reload"] = {
		Source = "reload_tac",
		Time = 3,
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
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/out.ogg",
				t = .55,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.4,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/in.ogg",
				t = 2,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2.7,
				v = 60
			}
		}
	},
	["reload_empty"] = {
		Source = "reload_empty",
		Time = 6,
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
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/up.ogg",
				t = .7,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/back.ogg",
				t = .8,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 1.5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/out.ogg",
				t = 2.9,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 3.25,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/in.ogg",
				t = 4.45,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/forward.ogg",
				t = 5.3,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amsr/down.ogg",
				t = 5.4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 5.6,
				v = 60
			}
		}
	}
}
