// Created by Crowbar 0.71

$ModelName "conviction/flashbang.mdl"

$scale 1.5
$BodyGroup "body"
{
	studio "flashbang.smd"
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

$IllumPosition -0.072 0.446 1.042

$CDMaterials "models\gadgets\"

$CBox 0 0 0 0 0 0

$BBox -2.309 -1.619 -2.864 1.416 1.476 4.949

$DefineBone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$Sequence "Idle" {
	"flashbang_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "flashbang_physics.smd"
{
	$mass 5
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 6

}
