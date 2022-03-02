// Created by Crowbar 0.71

$ModelName "powderkeg.mdl"

$scale 0.25
$StaticProp

$BodyGroup "Body"
{
	studio "distillery_barrel001_reference.smd"
}


$SurfaceProp "wood"

$Contents "solid"

$IllumPosition 0 0 0

$CDMaterials "models\props_trainyard\"

$CBox 0 0 0 0 0 0

$BBox -35 -35.378 -45.25 35 35.378 45.25

$DefineBone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$Sequence "idle" {
	"distillery_barrel001_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "distillery_barrel001_physics.smd"
{
	$mass 2
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 1

}
