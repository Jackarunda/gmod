--Heavy Shaped Bomb
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_fougassekit")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_c4.mdl")
	self.Entity:SetColor(Color(255,255,255))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(50)
	end
	self.Entity:SetUseType(SIMPLE_USE)
end
function ENT:PhysicsCollide(data, physobj)
	if(data.Speed>80 and data.DeltaTime>0.2)then
		self:EmitSound("Plastic_Box.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	activator:PickupObject(self)
end
function ENT:Think()
	--fack
end
function ENT:OnRemove()
	--no
end
function ENT:NotifySetup(ply)
	self.Activator=ply
	umsg.Start("JackaClaymoreNotify",ply)
	umsg.Entity(ply)
	umsg.End()
	numpad.OnDown(ply,KEY_PAD_0,"JackaFougasseDet")
	ply.JackaFougassesCanFire=true
end
local NextTime=0
local function DetonateFougasses(ply)
	if not(ply.JackaFougassesCanFire)then return end
	local Time=CurTime()
	if(NextTime>Time)then return end
	NextTime=Time+1
	local FoundEm=false
	for key,lel in pairs(ents.FindByClass("ent_jack_aidfuel_diesel"))do
		if((lel.Fougasstivator)and(lel.Fougasstivator==ply)and(lel.Fougassed))then
			FoundEm=true
			timer.Simple(.7,function()
				if(IsValid(lel))then
					lel:Fougassplode()
				end
			end)
		end
	end
	if(FoundEm)then
		JackaGenericUseEffect(ply)
		ply:EmitSound("snd_jack_detonator.wav",70,100)
	end
end
numpad.Register("JackaFougasseDet",DetonateFougasses)
local function CmdDetFoug(...)
	local args={...}
	local ply=args[1]
	DetonateFougasses(ply)
end
concommand.Add("jacky_fougasse_det",CmdDetFoug)
local function Ded(ply)
	ply.JackaFougassesCanFire=false
end
hook.Add("DoPlayerDeath","JackaFougassesDed",Ded)