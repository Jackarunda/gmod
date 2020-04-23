AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
ENT.TargetDrones=true
ENT.TrackRate=.45
ENT.MaxTrackRange=3500
ENT.FireRate=7
ENT.ShotPower=120
ENT.ScanRate=.9
ENT.ShotSpread=.028
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="RifleShellEject"
ENT.ProjectilesPerShot=1
ENT.TurretSkin="models/mat_jack_sniperturret"
ENT.ShotPitch=83
ENT.NearShotNoise="snd_jack_turretshoot_close.wav"
ENT.FarShotNoise="snd_jack_turretshoot_far.wav"
ENT.AmmoType="7.62x51mm"
ENT.MuzzEff="muzzleflash_sr25"
ENT.Automatic=true
ENT.BarrelSizeMod=Vector(1,1,2)
ENT.Autoloading=true
ENT.MechanicsSizeMod=2
ENT.TargetOrganics=true
ENT.TargetSynthetics=true
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_mg")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={0,4,2,5,9}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end