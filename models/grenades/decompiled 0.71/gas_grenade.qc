// Created by Crowbar 0.71

$ModelName "grenades\gas_grenade.mdl"

$scale 1.5
$BodyGroup "Body"
{
	studio "mk,v cn gas grenade_vm_usa_tabun_gas_base.smd"
}
$BodyGroup "Body"
{
	studio "mk,v cn gas grenade_vm_usa_tabun_gas_baseb.smd"
}
$BodyGroup "spoon"
{
	studio "mk,v cn gas grenade_vm_usa_tabun_gas_spoonb.smd"
	blank
}
$BodyGroup "pin"
{
	studio "mk,v cn gas grenade_vm_usa_tabun_gas_pinb.smd"
	blank
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0.054 0.692 -0.307

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -3.053 -1.686 -4.418 1.675 1.622 3.553

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "tag_clip" "j_gun" -0.519695 0 2.961105 -12.798157 0 0 0 0 0 0 0 0
$DefineBone "jnt_pin" "j_gun" -0.709902 0.181378 2.712448 0.271983 89.975059 -0.079183 0 0 0 0 0 0
$DefineBone "jnt_pin_loop" "jnt_pin" 0.632651 0.000272 0.003017 0 0 0 0 0 0 0 0 0


$Sequence "Idle" {
	"gas_grenade_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "gas_grenade_physics.smd"
{
	$mass 3
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 8

}
