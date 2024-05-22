SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Light Machine Gun"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_lmg", true)
SWEP.Slot = 2
SWEP.ViewModel = "models/weapons/v_cod4_m249saw.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m249.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -100, 10)
SWEP.BodyHolsterAngL = Angle(180, -100, -10)
SWEP.BodyHolsterPos = Vector(1, -11, -11)
SWEP.BodyHolsterPosL = Vector(.5, -11, 11)
SWEP.BodyHolsterScale = .8
JMod.ApplyAmmoSpecs(SWEP, "Light Rifle Round", .9)
SWEP.Primary.ClipSize = 150 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- open-bolt firearm lol
SWEP.Recoil = .3
SWEP.Delay = 60 / 750 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 2,
		PrintName = "FULL-AUTO"
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
SWEP.SpeedMult = .8
SWEP.SightedSpeedMult = .55
SWEP.SightTime = .8

SWEP.IronSightStruct = {
	Pos = Vector(-3.47, 1, 2.38),
	Ang = Angle(.5, 0, -5),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(0, -1, 2)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.HolsterPos = Vector(6, 0, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)
SWEP.ReloadPos = Vector(0, -1, 2)
SWEP.ReloadAng = Angle(15, 0, 0)
SWEP.BarrelLength = 38

-- arctic please just stop writing descriptions
SWEP.BulletBones = {
	[15] = "j_chain_bullets14",
	[14] = "j_chain_bullets13",
	[13] = "j_chain_bullets12",
	[12] = "j_chain_bullets11",
	[11] = "j_chain_bullets10",
	[10] = "j_chain_bullets9",
	[9] = "j_chain_bullets8",
	[8] = "j_chain_bullets7",
	[7] = "j_chain_bullets6",
	[6] = "j_chain_bullets5",
	[5] = "j_chain_bullets4",
	[4] = "j_chain_bullets3",
	[3] = "j_chain_bullets2",
	[2] = "j_chain_bullets1",
	[1] = "j_chain_bullets0"
}

SWEP.Attachments = {
	{
		PrintName = "Underbarrel",
		Slot = {"ez_tripod"},
		Bone = "tag_weapon",
		Offset = {
			vpos = Vector(15, 0, 0),
			vang = Angle(0, 0, 0),
			wpos = Vector(25, .6, -7.5),
			wang = Angle(170, 0, 0)
		},
		-- remove Slide because it ruins my life
		Installed = "underbarrel_jack_tripod"
	}
}

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
		Source = "shoot1",
		Time = 0.2,
		ShellEjectAt = 0,
	},
	["reload"] = {
		Source = "reload_full",
		Time = 9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71}, -- wat the fuck is this
		FrameRate = 37,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 0,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/back.ogg",
				t = .6,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/forward.ogg",
				t = 1,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 1.5,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/open.ogg",
				t = 2.2,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/out.ogg",
				t = 3.3,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 4.4,
				v = 65,
				p = 80
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/in.ogg",
				t = 5.4,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/chain.ogg",
				t = 6.1,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.tap.metallic,
				t = 6.7,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/lmg/close.ogg",
				t = 7.45,
				v = 65
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 8.5,
				v = 65
			}
		}
	}
}
