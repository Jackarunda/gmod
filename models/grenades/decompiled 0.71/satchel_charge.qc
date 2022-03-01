// Created by Crowbar 0.71

$ModelName "grenades/satchel_charge.mdl"

$scale 2.5
$BodyGroup "Body"
{
	studio "satchel charge_vm_gen_satchel_charge_dynamite.smd"
}
$BodyGroup "Body"
{
	studio "satchel charge_vm_gen_satchel_charge_dynamiteb.smd"
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0.024 0.201 0.575

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -2.63 -2.939 -4.25 2.229 3.387 5.331

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "explosive" "j_gun" 0 0 0 0 0 0 0 0 0 0 0 0


$Sequence "Idle" {
	"satchel_charge_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "satchel_charge_physics.smd"
{
	$mass 20
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 11

}
