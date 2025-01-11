SWEP.Base = "wep_jack_gmod_gunbase"
SWEP.PrintName = "Flintlock Blunderbuss"
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezweapon_flb", true)
SWEP.Slot = 3
SWEP.ViewModel = "models/weapons/blunder/c_blunder.mdl"
SWEP.WorldModel = "models/weapons/blunder/blunder.mdl"
SWEP.ViewModelFOV = 75
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(0, -15, 0)
SWEP.BodyHolsterAngL = Angle(0, 15, 180)
SWEP.BodyHolsterPos = Vector(-.5, -18, -4)
SWEP.BodyHolsterPosL = Vector(1, -17, 6)
SWEP.BodyHolsterScale = 1
JMod.ApplyAmmoSpecs(SWEP, "Black Powder Paper Cartridge", .9)
SWEP.Damage = SWEP.Damage / 35
SWEP.Num = 40
SWEP.Range = 10
SWEP.Penetration = 20
SWEP.AmmoPerShot = 3
SWEP.DoorBreachPower = 7
SWEP.Primary.ClipSize = 3 -- DefaultClip is automatically set.
SWEP.ChamberSize = 0
SWEP.Recoil = 6
SWEP.RecoilDamage = 1
SWEP.Delay = 60 / 100 -- 60/RPM.

SWEP.Firemodes = {
	{
		Mode = 1,
		PrintName = "SINGLE"
	},
	{
		Mode = 0
	}
}

SWEP.AccuracyMOA = 160 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.
SWEP.FirstShootSound = "snds_jack_gmod/ez_weapons/flintlock_musketoon.ogg"
SWEP.ShootSound = "snds_jack_gmod/ez_weapons/flintlock_musketoon.ogg"
SWEP.DistantShootSound = "snds_jack_gmod/ez_weapons/shotgun_far.ogg"
SWEP.ShootSoundExtraMult = 1
SWEP.MuzzleEffect = "muzzleflash_M3"
SWEP.ExtraMuzzleLua = "eff_jack_gmod_bphmuzzle"
SWEP.ExtraMuzzleLuaScale = 1
SWEP.SpeedMult = 1
SWEP.SightedSpeedMult = .7
SWEP.SightTime = .6

SWEP.IronSightStruct = {
	Pos = Vector(-8, 5, 4),
	Ang = Angle(-3, -8, 0),
	Magnification = 1.1,
	SwitchToSound = JMod.GunHandlingSounds.aim.inn,
	SwitchFromSound = JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos = Vector(-3, 5, 4)
SWEP.ActiveAng = Angle(-10, -10, 0)
SWEP.HolsterPos = Vector(8, 1, -6)
SWEP.HolsterAng = Angle(0, 60, -15)
SWEP.ReloadPos = Vector(0, 0, -10)
SWEP.ReloadAng = Angle(0, 0, 0)
SWEP.BarrelLength = 30
SWEP.ProceduralViewBobIntensity = .3

--[[
models/weapons/blunder/c_blunder.mdl
models/weapons/blunder/blunder.mdl
anim	0	idle01
anim	1	draw
anim	2	misscenter1
anim	3	holster
anim	4	reload
anim	5	dryFire
---------------------
bone	0	ValveBiped.Bip01
bone	1	ValveBiped.Bip01_Spine
bone	2	ValveBiped.Bip01_Spine1
bone	3	ValveBiped.Bip01_Spine2
bone	4	ValveBiped.Bip01_Spine4
bone	5	ValveBiped.Bip01_L_Clavicle
bone	6	ValveBiped.Bip01_L_UpperArm
bone	7	ValveBiped.Bip01_L_Forearm
bone	8	ValveBiped.Bip01_L_Hand
bone	9	ValveBiped.Bip01_L_Finger4
bone	10	ValveBiped.Bip01_L_Finger41
bone	11	ValveBiped.Bip01_L_Finger42
bone	12	ValveBiped.Bip01_L_Finger3
bone	13	ValveBiped.Bip01_L_Finger31
bone	14	ValveBiped.Bip01_L_Finger32
bone	15	ValveBiped.Bip01_L_Finger2
bone	16	ValveBiped.Bip01_L_Finger21
bone	17	ValveBiped.Bip01_L_Finger22
bone	18	ValveBiped.Bip01_L_Finger1
bone	19	ValveBiped.Bip01_L_Finger11
bone	20	ValveBiped.Bip01_L_Finger12
bone	21	ValveBiped.Bip01_L_Finger0
bone	22	ValveBiped.Bip01_L_Finger01
bone	23	ValveBiped.Bip01_L_Finger02
bone	24	ValveBiped.Bip01_R_Clavicle
bone	25	ValveBiped.Bip01_R_UpperArm
bone	26	ValveBiped.Bip01_R_Forearm
bone	27	ValveBiped.Bip01_R_Hand
bone	28	ValveBiped.Bip01_R_Finger4
bone	29	ValveBiped.Bip01_R_Finger41
bone	30	ValveBiped.Bip01_R_Finger42
bone	31	ValveBiped.Bip01_R_Finger3
bone	32	ValveBiped.Bip01_R_Finger31
bone	33	ValveBiped.Bip01_R_Finger32
bone	34	ValveBiped.Bip01_R_Finger2
bone	35	ValveBiped.Bip01_R_Finger21
bone	36	ValveBiped.Bip01_R_Finger22
bone	37	ValveBiped.Bip01_R_Finger1
bone	38	ValveBiped.Bip01_R_Finger11
bone	39	ValveBiped.Bip01_R_Finger12
bone	40	ValveBiped.Bip01_R_Finger0
bone	41	ValveBiped.Bip01_R_Finger01
bone	42	ValveBiped.Bip01_R_Finger02
bone	43	dummy
---------------------
1:
		id	=	0
		name	=	studio
		num	=	1
		submodels:
				0	=	v_blunder_ref.smd
---------------------
1:
		id	=	1
		name	=	muzzle
2:
		id	=	2
		name	=	breach

--]]
SWEP.Animations = {
	["idle"] = {
		Source = "idle01",
		Time = 1
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
		LHIKOut = 0.35
	},
	["fire"] = {
		Source = "misscenter1",
		Time = .75,
		TPAnim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
	},
	["reload"] = {
		Source = "reload",
		Time = 9,
		TPAnim = ACT_HL2MP_GESTURE_RELOAD_AR2,
		Checkpoints = {24, 42, 59, 71, 89},
		FrameRate = 20,
		Mult = 1,
		LHIK = true,
		LHIKIn = 0.5,
		LHIKOut = 0.5,
		SoundTable = {
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = .2,
				v = 60,
				p = 100
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 1.1,
				v = 60,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/rip.ogg",
				t = 1.2,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/pour.ogg",
				t = 1.6,
				v = 65
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/halfcock.ogg",
				t = 3.6,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/openfrizzen.ogg",
				t = 3.9,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/primepan.ogg",
				t = 4.1,
				v = 65,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/closefrizzen.ogg",
				t = 4.2,
				v = 65,
				p = 100
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/fullcock.ogg",
				t = 4.3,
				v = 65,
				p = 100
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 5.8,
				v = 60,
				p = 130
			},
			{
				s = "snds_jack_gmod/ez_weapons/flb/shot_pour.ogg",
				t = 6.5,
				v = 65,
				p = 100
			},
			{
				s = JMod.GunHandlingSounds.cloth.magpull,
				t = 7.5,
				v = 60,
				p = 120
			},
			{
				s = "snds_jack_gmod/ez_weapons/flm/drop.ogg",
				t = 8,
				v = 65,
				p = 70
			},
			{
				s = JMod.GunHandlingSounds.cloth.loud,
				t = 8.5,
				v = 60,
				p = 100
			}
		},
		ViewPunchTable = {
			{
				t = 1.2,
				p = Angle(0, 5, 0)
			},
			{
				t = 3.6,
				p = Angle(1, 0, 0)
			},
			{
				t = 3.9,
				p = Angle(1, 0, 0)
			},
			{
				t = 4.2,
				p = Angle(1, 0, 0)
			},
			{
				t = 4.3,
				p = Angle(1, 0, 0)
			},
			{
				t = 4.8,
				p = Angle(-1, 0, 0)
			},
			{
				t = 6.1,
				p = Angle(2, 0, 0)
			},
			{
				t = 7.2,
				p = Angle(1, 0, 0)
			},
			{
				t = 8,
				p = Angle(2, 0, 0)
			}
		}
	},
}
