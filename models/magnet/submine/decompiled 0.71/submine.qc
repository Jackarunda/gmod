// Created by Crowbar 0.71

$ModelName "submine.mdl"

$scale 0.75
$BodyGroup "Body"
{
	studio "submine_r.smd"
}


$SurfaceProp "floating_metal_barrel"

$Contents "solid"

$IllumPosition -0.267 0.004 -3.517

$CDMaterials "models\\magnet\submine\"

$CBox 0 0 0 0 0 0

$BBox -25.308 -25.505 -30.599 25.301 25.104 25.323

$DefineBone "submine" "" 0 0 0 0 0 0 0 0 0 0 0 0


$Sequence "Idle" {
	"submine_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "submine_physics.smd"
{
	$mass 200
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 1

}

$KeyValues
{
	prop_data 
	{
		"base"		metal.medium
	}
}
