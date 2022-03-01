// Created by Crowbar 0.71

$ModelName "grenades\bounding_mine.mdl"

$scale 1.5
$BodyGroup "Body"
{
	studio "s-mine 44_ger_smi44_bouncing_betty_base.smd"
}
$BodyGroup "Body"
{
	studio "s-mine 44_ger_smi44_bouncing_betty_baseb.smd"
}
$BodyGroup "pin"
{
	studio "s-mine 44_ger_smi44_bouncing_betty_pinb.smd"
	blank
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0 0 2.657

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -2.25 -2.25 -2.707 2.25 2.25 8.011

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "pin" "j_gun" 0.002248 -0.709478 5.834301 0 89.999982 0 0 0 0 0 0 0
$DefineBone "ring" "pin" 0.455074 0.024673 -0.035701 0 -89.999982 0 0 0 0 0 0 0


$Sequence "Idle" {
	"bounding_mine_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "bounding_mine_physics.smd"
{
	$mass 3
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 5

}
