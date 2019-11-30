AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
ENT.TargetDrones=true
ENT.TrackRate=2.25
ENT.MaxTrackRange=1125
ENT.FireRate=2
ENT.ShotPower=40
ENT.ScanRate=3
ENT.ShotSpread=.035
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="ShellEject"
ENT.ProjectilesPerShot=1
ENT.TurretSkin="models/mat_jack_pistolturret"
ENT.ShotPitch=110
ENT.NearShotNoise="snd_jack_turretshootshort_close.wav"
ENT.FarShotNoise="snd_jack_turretshootshort_far.wav"
ENT.AmmoType="9x19mm"
ENT.MuzzEff="muzzleflash_pistol"
ENT.BarrelSizeMod=Vector(.9,.9,.9)
ENT.Autoloading=true
ENT.MechanicsSizeMod=1
ENT.TargetOrganics=true
ENT.TargetSynthetics=false
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_pistol")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={0,1,6}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end