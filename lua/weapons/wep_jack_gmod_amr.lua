SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Anti-Materiel Rifle"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_amr", true)

if CLIENT then
	killicon.Add("wep_jack_gmod_amr", "entities/ent_jack_gmod_ezweapon_amr", Color(255, 0, 0))
end

SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/c_mw2_barrett50cal.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m107.mdl"
SWEP.ViewModelFOV = 60
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -105, 0)
SWEP.BodyHolsterAngL = Angle(15, -77, 180)
SWEP.BodyHolsterPos = Vector(2, -12, -10)
SWEP.BodyHolsterPosL = Vector(0, -10, 11)
SWEP.BodyHolsterScale = .9
SWEP.DefaultBodygroups = "01000"
JMod.ApplyAmmoSpecs(SWEP, "Heavy Rifle Round")
SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.
SWEP.Recoil = 2
SWEP.VisualRecoilMult = 2
SWEP.Delay = 60 / 200 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SEMI-AUTO"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 4 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/heavy_autoloader.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/heavy_autoloader.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzle_center_M82"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 70
SWEP.ShellScale = 4
SWEP.SpeedMult = .8
SWEP.SightedSpeedMult = .4
SWEP.SightTime = .9

SWEP.IronSightStruct = {
	Pos = Vector(-2.57, -1, 1),
	Ang = Angle(-.1, 0, -5),
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
			vpos = Vector(3.6, 0, 4.5),
			wpos = Vector(8, .8, -7.5),
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
			vpos = Vector(16, 0, 1.3),
			vang = Angle(0, 0, 0),
			wpos = Vector(31, .6, -8.5),
			wang = Angle(170, 0, 0)
		},
		-- remove Slide because it ruins my life
		Installed = "underbarrel_jack_bipod"
	}
}

SWEP.ActivePos = Vector(1, 0, -.5)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, -1, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.BarrelLength = 50

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
		Time = 2.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.longgun,
				t = 0,
				v = 60,
				p = 90
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/bigmove.wav",
				t = .2,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 2,
				v = 60
			}
		},
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.35,
	},
	["fire"] = {
		Source = "fire",
		Time = 0.6,
		ShellEjectAt = .05,
	},
	["reload"] = {
		Source = "reload_tac",
		Time = 5,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		-- Checkpoints={128}, -- checkpoints don't work in ArcCW so don't even bother
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 0,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/move.wav",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/magrelease.wav",
				t = 1.2,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/magtoss.wav",
				t = 1.1,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 2,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/magmove.wav",
				t = 2,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 2.7,
				v = 65,
				p = 80
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/in.wav",
				t = 3.35,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 3.8,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 4,
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
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 0,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/move.wav",
				t = .2,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/magrelease.wav",
				t = 1.3,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/magtoss.wav",
				t = 1.4,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 2.3,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/magmove.wav",
				t = 2.2,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.tap.magwell,
				t = 3.1,
				v = 65,
				p = 80
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/in.wav",
				t = 3.7,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.quiet,
				t = 4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 4.1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/pull.wav",
				t = 5,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/amr/release.wav",
				t = 5.3,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 5.8,
				v = 60
			}
		}
	},
}
