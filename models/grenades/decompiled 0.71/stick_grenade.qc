// Created by Crowbar 0.71

$ModelName "grenades\stick_grenade.mdl"

$scale 1.25
$BodyGroup "Body"
{
	studio "model 24 stielhandgranate with frag sleeve_vm_ger_frag_01_base.smd"
}
$BodyGroup "Body"
{
	studio "model 24 stielhandgranate with frag sleeve_vm_ger_frag_01_baseb.smd"
}
$BodyGroup "Body"
{
	studio "model 24 stielhandgranate with frag sleeve_vm_ger_frag_01_cord.smd"
}
$BodyGroup "Body"
{
	studio "model 24 stielhandgranate with frag sleeve_vm_ger_frag_01_cordb.smd"
}
$BodyGroup "pin"
{
	studio "model 24 stielhandgranate with frag sleeve_vm_ger_frag_01_capb.smd"
	blank
}


$SurfaceProp "grenade"

$Contents "solid"

$IllumPosition 0 0 3.017

$AmbientBoost

$MostlyOpaque

$CDMaterials "models\mats_jack_nades\"

$CBox 0 0 0 0 0 0

$BBox -1.983 -1.983 -6.039 1.983 1.983 12.121

$DefineBone "Joints" "" 0 0 0 0 -89.999982 0 0 0 0 0 0 0
$DefineBone "j_gun" "Joints" 0 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "ball" "j_gun" -0.034533 0 -4.093531 0 89.999982 0 0 0 0 0 0 0
$DefineBone "chord01" "ball" -0.095345 0.010472 0.287393 -89.999982 0 0 0 0 0 0 0 0
$DefineBone "chord02" "chord01" 0.463457 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "chord03" "chord02" 0.760309 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "chord04" "chord03" 0.760732 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "chord05" "chord04" 0.760954 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "chord06" "chord05" 0.762002 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "chord07" "chord06" 0.762089 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "chord08" "chord07" 0.757436 0 0 0 0 0 0 0 0 0 0 0
$DefineBone "cap" "j_gun" 0 0 -5.285967 0 89.999982 0 0 0 0 0 0 0


$Sequence "Idle" {
	"stick_grenade_anims\Idle.smd"
	activity "ACT_IDLE" 1
	fadein 0.2
	fadeout 0.2
	fps 30
}

$CollisionModel "stick_grenade_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$rootbone " "
	$concave
	$maxconvexpieces 5

}
