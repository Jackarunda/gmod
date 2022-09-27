SWEP.Base="wep_jack_gmod_gunbase"

SWEP.PrintName="Battle Rifle"

JMod.SetWepSelectIcon(SWEP,"entities/ent_jack_gmod_ezweapon_br",true)

SWEP.Slot=2

SWEP.ViewModel="models/weapons/v_cod4_g3_new.mdl"
SWEP.WorldModel="models/weapons/w_jmod_g3.mdl"
SWEP.ViewModelFOV=65
SWEP.BodyHolsterSlot="back"
SWEP.BodyHolsterAng=Angle(185,15,180)
SWEP.BodyHolsterAngL=Angle(0,195,170)
SWEP.BodyHolsterPos=Vector(2,-11,-11)
SWEP.BodyHolsterPosL=Vector(1,-11,11)
SWEP.BodyHolsterScale=.9

JMod.ApplyAmmoSpecs(SWEP,"Medium Rifle Round",.9)

SWEP.Primary.ClipSize=20 -- DefaultClip is automatically set.

SWEP.Recoil=1.5
SWEP.RecoilPunchBackMax=3
SWEP.RecoilPunchBackMaxSights=2

SWEP.Delay=60/550 -- 60/RPM.
SWEP.Firemodes={
    {
        Mode=1,
		PrintName="SEMI-AUTO"
    },
    {
        Mode=0
    }
}

SWEP.AccuracyMOA=3 -- accuracy in Minutes of Angle. There are 60 MOA in a degree.

SWEP.FirstShootSound="snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.ShootSound="snds_jack_gmod/ez_weapons/medium_rifle.wav"
SWEP.DistantShootSound="snds_jack_gmod/ez_weapons/rifle_far.wav"
SWEP.ShootSoundExtraMult=1

SWEP.MuzzleEffect="muzzleflash_g3"
SWEP.ShellModel="models/jhells/shell_762nato.mdl"
SWEP.ShellPitch=80
SWEP.ShellScale=2

SWEP.SpeedMult=1
SWEP.SightedSpeedMult=.6
SWEP.SightTime=.6

SWEP.IronSightStruct={
    Pos=Vector(-2.57, -1, 1),
    Ang=Angle(-.1, 0, -5),
    Magnification=1.1,
    SwitchToSound=JMod.GunHandlingSounds.aim.inn,
    SwitchFromSound=JMod.GunHandlingSounds.aim.out
}

SWEP.ActivePos=Vector(1, 2, 1)
SWEP.ActiveAng=Angle(1.8, 1.5, -2.5)

SWEP.HolsterPos=Vector(6, -1, 0)
SWEP.HolsterAng=Angle(-20, 50, 0)

SWEP.BarrelLength=42

SWEP.Animations={
    ["idle"]={
        Source="idle",
        Time=1
    },
    ["draw"]={
        Source="draw1",
        Time=1.3,
        SoundTable={{s=JMod.GunHandlingSounds.draw.longgun, t=0, v=60}},
        LHIK=true,
        LHIKIn=0,
        LHIKOut=0.35,
    },
    ["fire"]={
        Source="shoot1",
        Time=0.4,
        ShellEjectAt=0,
    },
    ["reload"]={
        Source="reload_full",
        Time=3.5,
        TPAnim=ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK=true,
        LHIKIn=0.5,
        LHIKOut=0.5,
		SoundTable={
			{s=JMod.GunHandlingSounds.cloth.loud, t=0, v=60, p=120},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/mag_out.wav", t=.35, v=65},
			{s=JMod.GunHandlingSounds.cloth.magpull, t=1.1, v=65},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/mag_in.wav", t=2.05, v=65},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/mag_tap.wav", t=2.55, v=65},
			{s=JMod.GunHandlingSounds.grab, t=3, v=65}
		}
    },
    ["reload_empty"]={
        Source="reload_empty",
        Time=5.5,
        TPAnim=ACT_HL2MP_GESTURE_RELOAD_AR2,
        LHIK=true,
        LHIKIn=0.5,
        LHIKOut=0.5,
		SoundTable={
			{s="snds_jack_gmod/ez_weapons/battle_rifle/pull_bolt.wav", t=.15, v=65},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/mag_out.wav", t=1.1, v=65},
			{s=JMod.GunHandlingSounds.cloth.magpull, t=2.1, v=65},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/mag_in.wav", t=3.2, v=50},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/mag_tap.wav", t=3.8, v=65},
			{s=JMod.GunHandlingSounds.grab, t=4.5, v=55, p=130},
			{s="snds_jack_gmod/ez_weapons/battle_rifle/bolt_release.wav", t=4.8, v=65},
			{s=JMod.GunHandlingSounds.grab, t=5.4, v=65}
		}
    }
}