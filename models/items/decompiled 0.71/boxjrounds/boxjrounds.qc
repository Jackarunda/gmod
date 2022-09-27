// Created by Crowbar 0.71

$ModelName "items\boxjmunitions.mdl"

$StaticProp

$Scale 1.25

$BodyGroup "body"
{
	studio "boxsrounds_reference.smd"
}


$SurfaceProp "item"

$Contents "solid"

$IllumPosition 0 0 5.757

$CDMaterials "models\items\"

$CBox 0 0 0 0 0 0

$BBox -3.131 -9.379 -0.28 3.131 9.476 11.515

$DefineBone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0


$Sequence "idle" {
	"boxjrounds_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 5
	loop
}

$CollisionModel "boxjrounds_physics.smd"
{
	$mass 5
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
		"base"		"Item.Small"
	}
}
