AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
ENT.TargetDrones=true
ENT.TrackRate=.1
ENT.MaxTrackRange=30000
ENT.FireRate=.15
ENT.ShotPower=300
ENT.ScanRate=.75
ENT.ShotSpread=.0008
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="RifleShellEject"
ENT.ProjectilesPerShot=1
ENT.TurretSkin="models/mat_jack_amaterielturret"
ENT.ShotPitch=70
ENT.NearShotNoise="snd_jack_turretshoot_close.wav"
ENT.FarShotNoise="snd_jack_turretshoot_far.wav"
ENT.AmmoType=".338 Lapua Magnum"
ENT.MuzzEff="muzzleflash_pistol_rbull"
ENT.BarrelSizeMod=Vector(1.5,1.5,3.5)
ENT.Autoloading=false
ENT.CycleSound="snd_jack_amatturretcycle.wav"
ENT.MechanicsSizeMod=1.1
ENT.TargetOrganics=true
ENT.TargetSynthetics=true
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_amateriel")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={5,9,7,8}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end