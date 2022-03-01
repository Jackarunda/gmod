// Created by Crowbar 0.71

$ModelName "grenades\incendiary_grenade.mdl"

$scale 1.5
$BodyGroup "Body"
{
	studio "m14 incendiary grenade_vm_usa_thermite_base.smd"
}
$BodyGroup "Body"
{
	studio "m14 incendiary grenade_vm_usa_thermite_baseb.smd"
}
$BodyGroup "spoon"
{
	studio "m14 incendiary grenade_vm_usa_thermite_spoonb.smd"
	blank
}
$BodyGroup "pin"
{
	studio "m14 incendiary grenade_vm_usa_thermite_pinb.smd"
	blank
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0.003 -0.005 0.036

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -1.577 -1.611 -3.528 1.837 1.594 3.518

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "grenade_jnt" "j_gun" 0 0 0 0 89.999982 0 0 0 0 0 0 0
$DefineBone "handle_jnt" "grenade_jnt" -0.00057 -0.759516 3.185198 0 0 0 0 0 0 0 0 0
$DefineBone "pin_jnt" "grenade_jnt" -0.076869 0.493967 2.728164 0 0 0 0 0 0 0 0 0
$DefineBone "ring" "pin_jnt" 0.605294 0.003848 0.042359 0 0 0 0 0 0 0 0 0


$Sequence "Idle" {
	"incendiary_grenade_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "incendiary_grenade_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 4

}
