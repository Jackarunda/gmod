--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_clusterminebomb")
	ent:SetPos(SpawnPos)
	ent.Undoer=ply
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/Jailure/WWII/wwii.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Entity:SetColor(Color(150,150,150))
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(135)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Triggered=false
	self.Fuze=5
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(self.Triggered)then return end
	self.Triggered=true
	self:EmitSound("snd_jack_metallicclick.wav",75,80)
	self:EmitSound("snd_jack_metallicclick.wav")
	JackaGenericUseEffect(activator)
end
function ENT:Think()
	if(self.Triggered)then
		self.Fuze=self.Fuze-1
		self:EmitSound("snd_jack_metallicclick.wav")
		self:EmitSound("snd_jack_metallicclick.wav")
		if(self.Fuze<=0)then
			self:Detonate()
		end
	end
	self:NextThink(CurTime()+1)
	return true
end
function ENT:Detonate()
	self:MakeSide(self:GetRight())
	self:MakeSide(-self:GetRight())
	self:MakeSide(self:GetForward())
	self:MakeSide(-self:GetForward())
	local Spl=EffectData()
	Spl:SetOrigin(self:GetPos())
	Spl:SetScale(1)
	util.Effect("Explosion",Spl,true,true)
	if(self.Undoer)then
		undo.Create("ClusterMineBomb")
		undo.SetCustomUndoText("Undone Cluster Mines")
	end
	for i=1,75 do
		local Dir=self:GetAngles()
		Dir:RotateAroundAxis(Dir:Up(),90)
		Dir:RotateAroundAxis(Dir:Right(),math.Rand(0,360))
		local maan=self:MakeMine(Dir:Forward())
		if(self.Undoer)then
			undo.AddEntity(maan)
		end
	end
	if(self.Undoer)then
		undo.SetPlayer(self.Undoer)
		undo.Finish()
	end
	self:Remove()
end
function ENT:MakeMine(dir)
	local Mine=ents.Create("ent_jack_landmine_sml")
	Mine:SetPos(self:LocalToWorld(self:OBBCenter()))
	Mine:SetDTBool(0,true)
	Mine:Spawn()
	Mine:Activate()
	Mine:SetColor(self:GetColor())
	Mine:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+dir*math.Rand(200,1000)+VectorRand()*math.Rand(0,100))
	Mine:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	timer.Simple(math.random(20,30),function()
		if(IsValid(Mine))then
			Mine.Armed=true
		end
	end)
	return Mine
end
function ENT:MakeSide(dir)
	local Case1=ents.Create("prop_physics")
	Case1:SetModel("models/props_c17/oildrumchunk01d.mdl")
	Case1:SetPos(self:GetPos())
	Case1:SetAngles(dir:Angle())
	Case1:Spawn()
	Case1:Activate()
	Case1:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+dir*100)
	Case1:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	SafeRemoveEntityDelayed(Case1,20)
end
function ENT:OnRemove()
	--aw fuck you
end