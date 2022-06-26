SWEP.Base="wep_jack_gmod_meleebase"
SWEP.Spawnable=false

SWEP.PrintName="Combat Knife"

JMod.SetWepSelectIcon(SWEP,"entities/ent_jack_gmod_ezweapon_combatknife",true)

SWEP.Slot=0

SWEP.ViewModel="models/weapons/yurie_cod/iw7/tactical_knife_iw7_vm.mdl"
SWEP.WorldModel="models/weapons/w_jmod_combatknife.mdl"
SWEP.ViewModelFOV=62
SWEP.MeleeRange=5
SWEP.MeleeDamage=20
-- VMBoneMods
-- VMElement
-- WMElement

SWEP.Firemodes={
	{
		Mode=1,
		PrintName="MELEE"
	},
	{
		Mode=0,
		PrintName="SAFE"
	}
}

SWEP.HoldtypeHolstered="normal"
SWEP.HoldtypeActive="knife"

SWEP.MeleeSwingSound={"snds_jack_gmod/ez_weapons/knives/swing1.wav","snds_jack_gmod/ez_weapons/knives/swing1.wav"}
SWEP.MeleeHitSound={"snds_jack_gmod/ez_weapons/knives/hit1.wav","snds_jack_gmod/ez_weapons/knives/hit2.wav","snds_jack_gmod/ez_weapons/knives/hit3.wav"}
SWEP.MeleeHitNPCSound={"snds_jack_gmod/ez_weapons/knives/slice1.wav","snds_jack_gmod/ez_weapons/knives/slice1.wav","snds_jack_gmod/ez_weapons/knives/slice1.wav","snds_jack_gmod/ez_weapons/knives/slice2.wav","snds_jack_gmod/ez_weapons/knives/slice2.wav","snds_jack_gmod/ez_weapons/knives/slice2.wav"}
SWEP.MeleeViewMovements={
	{t=0, ang=Angle(0,-5,0)},
	{t=.02, ang=Angle(0,30,0)}
}
SWEP.MeleeForceDir=Angle(0,60,0)

--[[
idle
hitcenter1
hitcenter2
hitcenter3
draw
holster
sprint
--]]
SWEP.Animations={
	["draw"]={
		Source="draw",
		Time=.8,
		SoundTable={{s="snds_jack_gmod/ez_weapons/knives/draw", t=0, v=60}}
	},
	["ready"]={
		Source="draw",
		Time=1,
	},
	["idle"]={
		Source="idle",
		Time=10,
	},
	["bash"]={
		Source="hitcenter1",
		SoundTable={
			{s={"snds_jack_gmod/ez_weapons/knives/swing1.wav","snds_jack_gmod/ez_weapons/knives/swing2.wav"}, t=0, v=60}
		},
		Time=0.7
	}
}

SWEP.IronSightStruct=false

SWEP.BashPreparePos=Vector(0, 0, 0)
SWEP.BashPrepareAng=Angle(0, 5, 0)

SWEP.BashPos=Vector(0, 0, 0)
SWEP.BashAng=Angle(10, -10, 0)

SWEP.HolsterPos=Vector(0, 0, 0)
SWEP.HolsterAng=Angle(-30, 0, 0)