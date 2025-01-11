SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Magnum Trapdoor Revolver"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_bigiron", true)
SWEP.Slot = 1
SWEP.ViewModel = "models/weapons/v_reichsrevolver_verdun.mdl"
SWEP.WorldModel = "models/weapons/w_reichsrevolver_verdun2.mdl"
SWEP.ViewModelFOV = 70
SWEP.BodyHolsterSlot = "thighs"
SWEP.BodyHolsterAng = Angle(90, 90, -20)
SWEP.BodyHolsterAngL = Angle(90, 90, -20)
SWEP.BodyHolsterPos = Vector(-5, 17, -6.5)
SWEP.BodyHolsterPosL = Vector(-7, 17, 1.5)
SWEP.BodyHolsterScale = 1
SWEP.HoldtypeHolstered = "normal"
SWEP.HoldtypeActive = "pistol"
SWEP.HoldtypeSights = "revolver"
JMod.ApplyAmmoSpecs(SWEP, "Black Powder Metallic Cartridge", .4)
SWEP.HipDispersion = 600 -- TEXAS RED HAD NOT CLEARED LEATHER
SWEP.Primary.ClipSize = 5 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0 -- revolver lol
SWEP.Recoil = 3
SWEP.VisualRecoilMult = 2
SWEP.ShotgunReload = true
SWEP.Delay = 60 / 50 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SINGLE-ACTION"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 10 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/small_shotgun.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/small_shotgun.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/pistol_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_pistol_rbull"
SWEP.ExtraMuzzleLua = "eff_jack_gmod_bpmuzzle"
SWEP.ExtraMuzzleLuaScale = .8
SWEP.ShellModel = "models/jhells/shell_12gauge.mdl"
SWEP.ShellSounds = JMod.ShellSounds.metal
SWEP.ShellPitch = 80
SWEP.ShellScale = 1.5
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .9
SWEP.SightTime = .35

SWEP.IronSightStruct = {
	Pos = Vector(-2.23, 14, .1),
	Ang = Angle(-.7, -.15, -2),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.minor,
	SwitchFromSound = JMod.GunHandlingSounds.aim.minor
}

SWEP.ActivePos = Vector(0, 1, -1)
SWEP.ActiveAng = Angle(1.8, 1.5, -2.5)
SWEP.MeleePitch = 1.1
SWEP.MeleeDamage = 7
SWEP.MeleeTime = .4
SWEP.HolsterPos = Vector(0, 0, 0)
SWEP.HolsterAng = Angle(-45, 0, 0)
SWEP.RevolverReload = true
SWEP.BarrelLength = 20

--[[
    models/weapons/v_reichsrevolver_verdun.mdl
    models/weapons/w_reichsrevolver_verdun2.mdl
    anim	0	Melee_Empty
    anim	1	Melee_2_Empty
    anim	2	Melee_3_Empty
    anim	3	Melee
    anim	4	Melee_2
    anim	5	Melee_3
    anim	6	Idle
    anim	7	Idle_Empty
    anim	8	Fire
    anim	9	Fire_Last
    anim	10	insert
    anim	11	reload_start
    anim	12	reload_end
    anim	13	draw
    anim	14	inspect
    ---------------------
    bone	0	Body
    bone	1	Hammer
    bone	2	Cylinder
    bone	3	Bullet
    bone	4	Bullet.004
    bone	5	Bullet.001
    bone	6	Bullet.002
    bone	7	Bullet.003
    bone	8	Cover
    bone	9	Trigger
    bone	10	Stick
    bone	11	Spine
    bone	12	r_upperarm
    bone	13	ValveBiped.Bip01_R_UpperArm
    bone	14	r_forearm
    bone	15	ValveBiped.Bip01_R_Forearm
    bone	16	ValveBiped.Bip01_R_Ulna
    bone	17	ValveBiped.Bip01_R_Wrist
    bone	18	r_wrist
    bone	19	ValveBiped.Bip01_R_Hand
    bone	20	r_middle_low
    bone	21	ValveBiped.Bip01_R_Finger2
    bone	22	r_middle_mid
    bone	23	ValveBiped.Bip01_R_Finger21
    bone	24	r_middle_tip
    bone	25	ValveBiped.Bip01_R_Finger22
    bone	26	r_ring_low
    bone	27	ValveBiped.Bip01_R_Finger3
    bone	28	r_ring_mid
    bone	29	ValveBiped.Bip01_R_Finger31
    bone	30	r_ring_tip
    bone	31	ValveBiped.Bip01_R_Finger32
    bone	32	r_index_low
    bone	33	ValveBiped.Bip01_R_Finger1
    bone	34	r_index_mid
    bone	35	ValveBiped.Bip01_R_Finger11
    bone	36	r_index_tip
    bone	37	ValveBiped.Bip01_R_Finger12
    bone	38	r_pinky_low
    bone	39	ValveBiped.Bip01_R_Finger4
    bone	40	r_pinky_mid
    bone	41	ValveBiped.Bip01_R_Finger41
    bone	42	r_pinky_tip
    bone	43	ValveBiped.Bip01_R_Finger42
    bone	44	r_thumb_low
    bone	45	ValveBiped.Bip01_R_Finger0
    bone	46	r_thumb_mid
    bone	47	ValveBiped.Bip01_R_Finger01
    bone	48	r_thumb_tip
    bone	49	ValveBiped.Bip01_R_Finger02
    bone	50	l_upperarm
    bone	51	ValveBiped.Bip01_L_UpperArm
    bone	52	l_forearm
    bone	53	ValveBiped.Bip01_L_Forearm
    bone	54	ValveBiped.Bip01_L_Ulna
    bone	55	ValveBiped.Bip01_L_Wrist
    bone	56	l_wrist
    bone	57	ValveBiped.Bip01_L_Hand
    bone	58	l_middle_low
    bone	59	ValveBiped.Bip01_L_Finger2
    bone	60	l_middle_mid
    bone	61	ValveBiped.Bip01_L_Finger21
    bone	62	l_middle_tip
    bone	63	ValveBiped.Bip01_L_Finger22
    bone	64	l_ring_low
    bone	65	ValveBiped.Bip01_L_Finger3
    bone	66	l_ring_mid
    bone	67	ValveBiped.Bip01_L_Finger31
    bone	68	l_ring_tip
    bone	69	ValveBiped.Bip01_L_Finger32
    bone	70	l_index_low
    bone	71	ValveBiped.Bip01_L_Finger1
    bone	72	l_index_mid
    bone	73	ValveBiped.Bip01_L_Finger11
    bone	74	l_index_tip
    bone	75	ValveBiped.Bip01_L_Finger12
    bone	76	l_pinky_low
    bone	77	ValveBiped.Bip01_L_Finger4
    bone	78	l_pinky_mid
    bone	79	ValveBiped.Bip01_L_Finger41
    bone	80	l_pinky_tip
    bone	81	ValveBiped.Bip01_L_Finger42
    bone	82	l_thumb_low
    bone	83	ValveBiped.Bip01_L_Finger0
    bone	84	l_thumb_mid
    bone	85	ValveBiped.Bip01_L_Finger01
    bone	86	l_thumb_tip
    bone	87	ValveBiped.Bip01_L_Finger02
    bone	88	__INVALIDBONE__
    bone	89	__INVALIDBONE__
    bone	90	__INVALIDBONE__
    bone	91	__INVALIDBONE__
    bone	92	__INVALIDBONE__
    bone	93	__INVALIDBONE__
    bone	94	__INVALIDBONE__
    bone	95	__INVALIDBONE__
    bone	96	__INVALIDBONE__
    bone	97	__INVALIDBONE__
    bone	98	__INVALIDBONE__
    bone	99	__INVALIDBONE__
    bone	100	__INVALIDBONE__
    ---------------------
    1:
            id	=	0
            name	=	studio
            num	=	1
            submodels:
                    0	=	Reichsrevolver.000.smd
    ---------------------
    1:
            id	=	1
            name	=	1
]]
-- todo: extra dmg against texas red
SWEP.Animations = {
	["idle"] = {
		Source = "Idle",
		Time = 10
	},
	["draw"] = {
		Source = "draw",
		Time = 0.3,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
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
	["ready"] = {
		Source = "draw",
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.draw.handgun,
				t = 0,
				v = 60,
				p = 110
			}
		},
		Time = .4,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0.25,
	},
	["fire"] = {
		Source = "Fire",
		Time = 1.5,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
	},
	["sgreload_start"] = {
		Source = "reload_start",
		Time = 2,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		ShellEjectAt = 1.2,
		ShellEjectDynamic = true,
		RestoreAmmo = 1,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/open.ogg",
				t = .5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/eject.ogg",
				t = 1.1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/out.ogg",
				t = 1.4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.9,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/in.ogg",
				t = 2.3,
				v = 60
			}
		}
	},
	["sgreload_start_empty"] = {
		Source = "reload_start",
		Time = 2,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0,
		ShellEjectAt = 1.2,
		ShellEjectCount = 5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.move,
				t = 0,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/open.ogg",
				t = .5,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/eject.ogg",
				t = 1.1,
				v = 60
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/out.ogg",
				t = 1.4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.9,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/in.ogg",
				t = 2.3,
				v = 60
			}
		}
	},
	["sgreload_insert"] = {
		Source = "insert",
		Time = 3,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
		TPAnimStartTime = 0.3,
		LHIK = true,
		LHIKIn = 0,
		LHIKOut = 0,
		HardResetAnim = "reload_end",
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = .3,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/in.ogg",
				t = .8,
				v = 60
			}
		}
	},
	["sgreload_finish"] = {
		Source = "reload_end",
		Time = 2.5,
		LHIK = true,
		LHIKIn = 0,
		SoundTable = {
			{
				s = "snds_jack_gmod/ez_weapons/shotrevolver/close.ogg",
				t = .4,
				v = 60
			},
			{
				s = JMod.GunHandlingSounds.grab,
				t = 1,
				v = 55
			}
		},
		LHIKOut = 0.4,
	}
}
