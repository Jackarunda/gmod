AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
ENT.TargetDrones=true
ENT.TrackRate=1.75
ENT.MaxTrackRange=1000
ENT.FireRate=3.75
ENT.ShotPower=10
ENT.ScanRate=2.25
ENT.ShotSpread=.035
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="ShellEject"
ENT.ProjectilesPerShot=1
ENT.TurretSkin="models/mat_jack_plinkerturret"
ENT.ShotPitch=125
ENT.NearShotNoise="snd_jack_turretshootshort_close.wav"
ENT.FarShotNoise="snd_jack_turretshootshort_far.wav"
ENT.AmmoType=".22 Long Rifle"
ENT.MuzzEff="muzzleflash_suppressed"
ENT.BarrelSizeMod=Vector(.8,.8,.8)
ENT.Autoloading=true
ENT.MechanicsSizeMod=.5
ENT.TargetOrganics=true
ENT.TargetSynthetics=false
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_plinker")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={1,3,6}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end