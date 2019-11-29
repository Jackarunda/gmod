--[[
	Jackarunda made this
	it's a target
	for shootin
	and it draws the attention of NPCs too
	included it in funguns for usefulness
--]]

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local GibModelTable={
	"models/props_debris/concrete_chunk05g.mdl",
	"models/cheeze/pcb2/pcb2.mdl"
}

function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_target")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()

	self.Entity:SetModel("models/hunter/misc/sphere025x025.mdl")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(75)
		phys:SetMaterial("metal")
	end
	
	self.Dying=false
	
	self.LittleFella=ents.Create("npc_bullseye")
	self.LittleFella:SetPos(self:LocalToWorld(self:OBBCenter()))
	self.LittleFella:SetParent(self)
	self.LittleFella:SetHealth(1)
	self.LittleFella:SetMaxHealth(1)
	self.LittleFella:SetKeyValue("spawnflags","65536")
	self.LittleFella:Spawn()
	self.LittleFella:Activate()
	
	self.DecoyOne=ents.Create("npc_bullseye")
	self.DecoyOne:SetPos(self:LocalToWorld(self:OBBCenter())+Vector(0,0,7))
	self.DecoyOne:SetParent(self)
	self.DecoyOne:SetKeyValue("spawnflags","196608")
	self.DecoyOne:Spawn()
	self.DecoyOne:Activate()
	
	self.DecoyTwo=ents.Create("npc_bullseye")
	self.DecoyTwo:SetPos(self:LocalToWorld(self:OBBCenter())+Vector(0,0,-7))
	self.DecoyTwo:SetParent(self)
	self.DecoyTwo:SetKeyValue("spawnflags","196608")
	self.DecoyTwo:Spawn()
	self.DecoyTwo:Activate()
	
	self.DecoyThree=ents.Create("npc_bullseye")
	self.DecoyThree:SetPos(self:LocalToWorld(self:OBBCenter())+Vector(7,0,0))
	self.DecoyThree:SetParent(self)
	self.DecoyThree:SetKeyValue("spawnflags","196608")
	self.DecoyThree:Spawn()
	self.DecoyThree:Activate()
	
	self.DecoyFour=ents.Create("npc_bullseye")
	self.DecoyFour:SetPos(self:LocalToWorld(self:OBBCenter())+Vector(-7,0,0))
	self.DecoyFour:SetParent(self)
	self.DecoyFour:SetKeyValue("spawnflags","196608")
	self.DecoyFour:Spawn()
	self.DecoyFour:Activate()
	
	self.DecoyFive=ents.Create("npc_bullseye")
	self.DecoyFive:SetPos(self:LocalToWorld(self:OBBCenter())+Vector(0,7,0))
	self.DecoyFive:SetParent(self)
	self.DecoyFive:SetKeyValue("spawnflags","196608")
	self.DecoyFive:Spawn()
	self.DecoyFive:Activate()
	
	self.DecoySix=ents.Create("npc_bullseye")
	self.DecoySix:SetPos(self:LocalToWorld(self:OBBCenter())+Vector(0,-7,0))
	self.DecoySix:SetParent(self)
	self.DecoySix:SetKeyValue("spawnflags","196608")
	self.DecoySix:Spawn()
	self.DecoySix:Activate()

end

function ENT:StartTouch(thing)
	if(self.Dying)then return end
	if(thing:GetClass()=="prop_combine_ball")then
		local dmg=DamageInfo()
		local owner=thing:GetOwner()
		if(IsValid(owner))then dmg:SetAttacker(owner) else dmg:SetAttacker(thing) end
		dmg:SetInflictor(thing)
		dmg:SetDamage(75)
		dmg:SetDamageType(DMG_DISSOLVE)
		dmg:SetDamagePosition(thing:GetPos())
		dmg:SetDamageForce(thing:GetVelocity()-self:GetPhysicsObject():GetVelocity())
		self:Die(dmg)
	end
end

function ENT:PhysicsCollide(data,physobj)
	if(self.Dying)then return end
	if(data.Speed>400)then
		local dmg=DamageInfo()
		local owner=data.HitEntity:GetOwner()
		if(IsValid(owner))then dmg:SetAttacker(owner) else dmg:SetAttacker(data.HitEntity) end
		local atker=data.HitEntity:GetPhysicsAttacker()
		if(IsValid(atker))then dmg:SetAttacker(atker) end
		dmg:SetInflictor(data.HitEntity)
		dmg:SetDamage(50)
		dmg:SetDamageType(DMG_CRUSH)
		dmg:SetDamagePosition(data.HitEntity:GetPos())
		dmg:SetDamageForce(data.HitEntity:GetPhysicsObject():GetVelocity()-self:GetPhysicsObject():GetVelocity())
		self:Die(dmg)
	elseif((data.Speed>80)and(data.DeltaTime>.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
end

function ENT:OnTakeDamage(dmginfo)
	if(self.Dying)then return end
	if(dmginfo:GetDamage()>0)then
		self:Die(dmginfo)
	end
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator, caller)
	//lol
end

function ENT:Think()
	if(self.Dying)then return end
	for key,found in pairs(ents.GetAll())do
		if(found:IsNPC())then
			if not(found:GetClass()=="npc_bullseye")then
				found:AddEntityRelationship(self.LittleFella,D_HT,99)
				found:AddEntityRelationship(self.DecoyOne,D_HT,99)
				found:AddEntityRelationship(self.DecoyTwo,D_HT,99)
				found:AddEntityRelationship(self.DecoyThree,D_HT,99)
				found:AddEntityRelationship(self.DecoyFour,D_HT,99)
				found:AddEntityRelationship(self.DecoyFive,D_HT,99)
				found:AddEntityRelationship(self.DecoySix,D_HT,99)
			end
		end
	end
	self:NextThink(CurTime()+.5)
	return true
end

function ENT:OnRemove()
	//lol
end

function ENT:Die(dmginfo)
	if(self.Dying)then return end
	self.Dying=true
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())

	local Factor=(math.Rand(0,dmginfo:GetDamage())^.5+150)

	local Cake=EffectData()
	Cake:SetOrigin(SelfPos)
	Cake:SetScale(1)
	Cake:SetNormal(dmginfo:GetDamageForce())
	util.Effect("eff_jack_targetbust",Cake)
	
	sound.Play("snd_jack_targetbust.wav",SelfPos,70,math.Rand(90,110))
	local pitch=math.Rand(100,130)
	sound.Play("snd_jack_ding_close.wav",SelfPos,100,Pitch)
	sound.Play("snd_jack_ding_medium.wav",SelfPos,130,Pitch)
	sound.Play("snd_jack_ding_far.wav",SelfPos,160,Pitch)
	
	for i=0,math.random(5,9)do
		local Gib=ents.Create("prop_physics")
		Gib:SetModel(GibModelTable[math.random(1,2)])
		local randum=VectorRand()
		Gib:SetPos(SelfPos+randum*math.Rand(0,10))
		Gib:SetAngles(randum:Angle())
		Gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		Gib:Spawn()
		Gib:Activate()
		Gib:SetMaterial("Models/Debug/debugwhite")
		Gib:GetPhysicsObject():SetMaterial("default_silent")
		local Brightness=math.Rand(175,245)
		if(math.random(1,2)==2)then
			Gib:SetColor(Color(Brightness,0,0,255))
		else
			Gib:SetColor(Color(Brightness,Brightness,Brightness,255))
		end
		local Phys=Gib:GetPhysicsObject()
		Phys:SetMaterial("gmod_silent")
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*Factor+dmginfo:GetDamageForce())
		Phys:AddAngleVelocity((VectorRand()*Factor)*3)
		SafeRemoveEntityDelayed(Gib,math.random(7,14))
	end
	
	self.LittleFella:TakeDamageInfo(dmginfo)
	
	self.DecoyOne:Remove()
	self.DecoyTwo:Remove()
	self.DecoyThree:Remove()
	self.DecoyFour:Remove()
	self.DecoyFive:Remove()
	self.DecoySix:Remove()
	
	self:Remove()
end