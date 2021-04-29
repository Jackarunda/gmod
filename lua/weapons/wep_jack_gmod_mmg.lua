SWEP.Base = "wep_jack_gmod_gunbase"

SWEP.PrintName = "Medium Machine Gun"

SWEP.Slot = 2

SWEP.ViewModel = "models/weapons/c_mw2_m240.mdl"
SWEP.WorldModel = "models/weapons/w_jmod_m240.mdl"
SWEP.ViewModelFOV = 70

SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0,-100,10)
SWEP.BodyHolsterAngL = Angle(180,-100,-10)
SWEP.BodyHolsterPos = Vector(1,-11,-11)
SWEP.BodyHolsterPosL = Vector(.5,-11,11)
SWEP.BodyHolsterScale = .8

--[[
2:
		id	=	1
		name	=	sights
		num	=	2
		submodels:
				0	=	c_mw2_m240_sights_bg.smd
				1	=	
--]]

JMod_ApplyAmmoSpecs(SWEP,"Medium Rifle Round")

SWEP.Primary.ClipSize = 100 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- open-bolt firearm lol

SWEP.Recoil = .7 -- hevy gun

SWEP.Delay = 60 / 550 -- 60 / RPM.
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

SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect = "muzzleflash_g3"
SWEP.ShellModel = "models/jhells/shell_762nato.mdl"
SWEP.ShellPitch = 80
SWEP.ShellScale = 2

SWEP.SpeedMult = .7
SWEP.SightedSpeedMult = .5
SWEP.SightTime = .9

SWEP.IronSightStruct = {
    Pos = Vector(-3.77, 1, .5),
    Ang = Angle(.14, 0, -5),
    Magnification = 1.1,
    SwitchToSound = JMod_GunHandlingSounds.aim.inn,
    SwitchFromSound = JMod_GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(1, 1, 1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos = Vector(6, 0, 0)
SWEP.HolsterAng = Angle(-20, 50, 0)

SWEP.ReloadPos = Vector(0,-1,0)
SWEP.ReloadAng = Angle(5, 0, 0)

SWEP.BarrelLength = 38

SWEP.BulletBones = { -- arctic, no
    [13] = "j_ammo_013",
    [12] = "j_ammo_012",
    [11] = "j_ammo_011",
    [10] = "j_ammo_010",
    [9] = "j_ammo_09",
    [8] = "j_ammo_08",
    [7] = "j_ammo_07",
    [6] = "j_ammo_06",
    [5] = "j_ammo_05",
    [4] = "j_ammo_04",
    [3] = "j_ammo_03",
    [2] = "j_ammo_02",
    [1] = "j_ammo_01"
}

SWEP.Attachments = {
	{
        PrintName = "Underbarrel",
        Slot = {"ez_tripod"},
        Bone = "tag_weapon",
        Offset = {
			vpos = Vector(18, 0, 0),
            vang = Angle(0, 0, 0),
			wpos = Vector(33.5, 1, -8.8),
            wang = Angle(170, 0, 0)
        },
        -- remove Slide because it ruins my life
		Installed = "underbarrel_jack_tripod"
    }
}

--[[
idle
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
        SoundTable = {{s = JMod_GunHandlingSounds.draw.longgun, t = 0, v=60, p=90}},
		Mult=1,
        LHIK = true,
        LHIKIn = 0,
        LHIKOut = 0.35,
    },
    ["fire"] = {
        Source = "fire",
        Time = 0.2,
        ShellEjectAt = 0,
    },
    ["reload"] = {
        Source = "reload_tac",
        Time = 10,
        TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        Checkpoints = {24, 42, 59, 71}, -- wat the fuck is this
        FrameRate = 37,
		Mult=1,
        LHIK = true,
        LHIKIn = 0.5,
        LHIKOut = 0.5,
		SoundTable = {
			{s = JMod_GunHandlingSounds.cloth.loud, t = 0, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/back.wav", t = .4, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/forward.wav", t = .7, v=65},
			{s = JMod_GunHandlingSounds.grab, t = 1.2, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/moving.wav", t = 1.3, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/open.wav", t = 2.5, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/out.wav", t = 3.3, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/boxdraw.wav", t = 4.1, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/in.wav", t = 4.9, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/chain.wav", t = 5.85, v=65},
			{s = JMod_GunHandlingSounds.tap.metallic, t = 6.4, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/close.wav", t = 6.85, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/bang.wav", t = 7.45, v=65},
			{s = "snds_jack_gmod/ez_weapons/mmg/shoulder.wav", t = 8.35, v=65, p=80},
			{s = JMod_GunHandlingSounds.grab, t = 8.5, v=65}
		}
    },
}