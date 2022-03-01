// Created by Crowbar 0.71

$ModelName "grenades\impact_grenade.mdl"

$scale 1.5
$BodyGroup "Body"
{
	studio "impact_grenade_base.smd"
}
$BodyGroup "Body"
{
	studio "impact_grenade_baseb.smd"
}
$BodyGroup "cap"
{
	studio "impact_grenade_capb.smd"
	blank
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0 0 0.536

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -1.691 -1.679 -2.533 1.691 1.695 3.464

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "jnt_cap" "j_gun" -0.000036 0.000158 2.493154 0 89.999982 0 0 0 0 0 0 0


$Sequence "Idle" {
	"impact_grenade_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "impact_grenade_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 7

}
