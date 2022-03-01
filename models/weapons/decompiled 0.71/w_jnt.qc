// Created by Crowbar 0.71

$ModelName "weapons\w_jnt.mdl"

$scale 1.5
$BodyGroup "studio"
{
	studio "w_tnt_reference.smd"
}


$SurfaceProp "weapon"

$Contents "solid"

$IllumPosition 0.494 -3.51 -0.004

$CDMaterials "models\weapons\w_models\jnt\"

$Attachment "wick" "wick" 0 0 0 rotate 0 0 0

$CBox 0 0 0 0 0 0

$BBox -6.094 -5.176 -1.936 12.859 5.826 1.936

$DefineBone "tnt" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$DefineBone "wick" "tnt" 3.897647 0.046361 12.706111 -36.451804 0 0 0 0 0 0 0 0


$Sequence "w_tnt_idle" {
	"w_jnt_anims\w_tnt_idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 10
}

$Sequence "w_tnt_wick" {
	"w_jnt_anims\w_tnt_wick.smd"
	fadein 0.2
	fadeout 0.2
	fps 1
}

$CollisionModel "w_jnt_physics.smd"
{
	$mass 5
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "

}
