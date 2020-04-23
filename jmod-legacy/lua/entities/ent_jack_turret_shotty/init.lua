AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
ENT.TargetDrones=true
ENT.TrackRate=1.5
ENT.MaxTrackRange=900
ENT.FireRate=.5
ENT.ShotPower=15
ENT.ScanRate=3
ENT.ShotSpread=.06
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="ShotgunShellEject"
ENT.ProjectilesPerShot=10
ENT.TurretSkin="models/mat_jack_shottyturret"
ENT.ShotPitch=100
ENT.NearShotNoise="snd_jack_turretshootshot_close.wav"
ENT.FarShotNoise="snd_jack_turretshootshot_far.wav"
ENT.AmmoType="12GAshotshell"
ENT.MuzzEff="muzzleflash_M3"
ENT.BarrelSizeMod=Vector(2,2,1)
ENT.Autoloading=false
ENT.CycleSound="snd_jack_shottyturretcycle.wav"
ENT.MechanicsSizeMod=1
ENT.TargetOrganics=true
ENT.TargetSynthetics=false
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_shotty")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={0,1,3,6}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end