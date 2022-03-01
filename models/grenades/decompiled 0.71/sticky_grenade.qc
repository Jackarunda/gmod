// Created by Crowbar 0.71

$ModelName "grenades\sticky_grenade.mdl"

$scale 2.25
$BodyGroup "Body"
{
	studio "sticky_grenade.smd"
}
$BodyGroup "Body"
{
	studio "sticky_grenadeb.smd"
}
$BodyGroup "pin"
{
	studio "sticky_grenade_pinb.smd"
	blank
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0 0 1.019

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -1.77 -1.741 -2.514 1.741 1.816 4.581

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "pin" "j_gun" 0 0 0 0 89.999982 0 0 0 0 0 0 0
$DefineBone "ring" "pin" -0.012977 -0.591822 0.019699 0 0 0 0 0 0 0 0 0
$DefineBone "tab" "ring" -0.009153 -0.177925 -0.199864 0 0 0 0 0 0 0 0 0


$Sequence "Idle" {
	"sticky_grenade_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "sticky_grenade_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 3

}
