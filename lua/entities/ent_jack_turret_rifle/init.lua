AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.Base="ent_jack_turret_base"
ENT.TargetDrones=true
ENT.TrackRate=.5
ENT.MaxTrackRange=3500
ENT.FireRate=6
ENT.ShotPower=85
ENT.ScanRate=1
ENT.ShotSpread=.0175
ENT.RoundsOnBelt=0
ENT.RoundInChamber=false
ENT.MaxCharge=3000
ENT.ShellEffect="RifleShellEject"
ENT.ProjectilesPerShot=1
ENT.TurretSkin="models/mat_jack_rifleturret"
ENT.ShotPitch=110
ENT.NearShotNoise="snd_jack_turretshoot_close.wav"
ENT.FarShotNoise="snd_jack_turretshoot_far.wav"
ENT.AmmoType="5.56x45mm"
ENT.MuzzEff="muzzleflash_smg"
ENT.BarrelSizeMod=Vector(1,1,2)
ENT.Autoloading=true
ENT.MechanicsSizeMod=1
ENT.TargetOrganics=true
ENT.TargetSynthetics=false
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_turret_rifle")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.TargetingGroup={0}
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end