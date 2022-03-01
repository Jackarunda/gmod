// Created by Crowbar 0.71

$ModelName "weapons\w_minifragjade.mdl"

$scale 1.25
$BodyGroup "studio"
{
	studio "p_m67_1.smd"
}
$BodyGroup "pin"
{
	studio "pin.smd"
	blank
}
$BodyGroup "spoon"
{
	studio "spoon.smd"
	blank
}


$SurfaceProp "weapon"

$Contents "solid"

$IllumPosition -0.51 3.159 1.518

$CDMaterials "models\weapons\w_models\"

$Attachment "fas_Weapon_Belt01" "Weapon_Belt01" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Belt02" "Weapon_Belt02" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Belt03" "Weapon_Belt03" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Belt04" "Weapon_Belt04" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Belt05" "Weapon_Belt05" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Bolt" "Weapon_Bolt" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Bolt_End" "Weapon_Bolt_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Casing" "Weapon_Casing" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Casing_End" "Weapon_Casing_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Grip" "Weapon_Grip" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Grip_End" "Weapon_Grip_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_HK_Handle1" "Weapon_HK_Handle1" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_HK_Handle2" "Weapon_HK_Handle2" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_HK_Handle_End" "Weapon_HK_Handle_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Magazine" "Weapon_Magazine" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Magazine_End" "Weapon_Magazine_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Misc" "Weapon_Misc" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Misc_End" "Weapon_Misc_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Muzzle" "Weapon_Muzzle" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Muzzle_End" "Weapon_Muzzle_End" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Trigger" "Weapon_Trigger" 0 0 0 rotate 0 0 0
$Attachment "fas_Weapon_Trigger_End" "Weapon_Trigger_End" 0 0 0 rotate 0 0 0

$CBox 0 0 0 0 0 0

$BBox -8.017 -2.453 -1.628 1.698 1.433 4.665

$HBoxSet "default"

$DefineBone "Weapon_Grip" "" 0 0 0 0 89.999982 89.999982 0 0 0 0 0 0
$DefineBone "Weapon_Magazine" "Weapon_Grip" 5.18667 0.019576 0 0 0 0.000057 0 0 0 0 0 0
$DefineBone "Weapon_Magazine_End" "Weapon_Magazine" 0 -1.647436 0.000002 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Belt01" "Weapon_Magazine" 0.019771 1.352835 -2.452979 -45.000049 -89.999982 89.999982 0 0 0 0 0 0
$DefineBone "Weapon_Belt02" "Weapon_Belt01" 0 0.351617 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Belt03" "Weapon_Belt02" 0 0.374191 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Belt04" "Weapon_Belt03" 0 0.361788 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Belt05" "Weapon_Belt04" 0 0.372698 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Trigger" "Weapon_Grip" 2.284173 1.891014 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Trigger_End" "Weapon_Trigger" 0 -0.989732 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Misc" "Weapon_Grip" 6.585266 2.630651 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Misc_End" "Weapon_Misc" 1.033857 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_HK_Handle1" "Weapon_Grip" 5.955614 4.664553 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_HK_Handle2" "Weapon_HK_Handle1" 1.032243 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_HK_Handle_End" "Weapon_HK_Handle2" 1.028899 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Muzzle" "Weapon_Grip" -0.094144 3.792605 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Muzzle_End" "Weapon_Muzzle" 1.032243 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Casing" "Weapon_Grip" 4.946103 4.124418 1.288599 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Casing_End" "Weapon_Casing" 1.032243 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Bolt" "Weapon_Grip" 2.794364 4.077009 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Bolt_End" "Weapon_Bolt" 0.863692 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "Weapon_Grip_End" "Weapon_Grip" 1.371147 1.778537 0 0 0 0 0 0 0 0 0 0

$BoneMerge "Weapon_Grip"
$BoneMerge "Weapon_Magazine"
$BoneMerge "Weapon_Magazine_End"
$BoneMerge "Weapon_Belt01"
$BoneMerge "Weapon_Belt02"
$BoneMerge "Weapon_Belt03"
$BoneMerge "Weapon_Belt04"
$BoneMerge "Weapon_Belt05"
$BoneMerge "Weapon_Trigger"
$BoneMerge "Weapon_Trigger_End"
$BoneMerge "Weapon_Misc"
$BoneMerge "Weapon_Misc_End"
$BoneMerge "Weapon_HK_Handle1"
$BoneMerge "Weapon_HK_Handle2"
$BoneMerge "Weapon_HK_Handle_End"
$BoneMerge "Weapon_Muzzle"
$BoneMerge "Weapon_Muzzle_End"
$BoneMerge "Weapon_Casing"
$BoneMerge "Weapon_Casing_End"
$BoneMerge "Weapon_Bolt"
$BoneMerge "Weapon_Bolt_End"
$BoneMerge "Weapon_Grip_End"


$Sequence "idle" {
	"w_fragjade_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "w_fragjade_physics.smd"
{
	$mass 2
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
