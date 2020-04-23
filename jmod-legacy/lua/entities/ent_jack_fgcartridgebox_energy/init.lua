AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.DoNotBangOnCartridges=true

function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_fgcartridgebox_energy")
	ent:SetPos(SpawnPos)
	ent.Spawner=ply
	ent:Spawn()
	ent:Activate()
	
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/mass_effect_3/weapons/misc/ammojox smaller.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self:SetDTBool(0,true)
	
	local phys=self.Entity:GetPhysicsObject()
	if(phys:IsValid())then
		phys:Wake()
		phys:SetMass(100)
		phys:SetMaterial("metal")
	end
end

function ENT:Think()
end

function ENT:PhysicsCollide(data,physobj)
	if(data.DeltaTime>.1)then
		if(data.Speed>200)then
			self.Entity:EmitSound("Canister.ImpactHard")
		elseif(data.Speed>20)then
			self.Entity:EmitSound("Canister.ImpactSoft")
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator)
	if(self.Used)then return end
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	undo.Create("Cartridges")
	undo.SetPlayer(self.Spawner)
	undo.SetCustomUndoText("Undone Cartridges")
	sound.Play("snd_jack_boxopen.wav",self:GetPos(),70,105)
	for i=1,4 do
		local Cartridge=ents.Create("ent_jack_fgc_energy_lithium")
		Cartridge:SetPos(SelfPos+VectorRand()*math.Rand(0,10))
		Cartridge:SetAngles(VectorRand():Angle())
		Cartridge:Spawn()
		Cartridge:Activate()
		Cartridge:GetPhysicsObject():SetVelocity(self:GetVelocity()+self:GetUp()*100)
		undo.AddEntity(Cartridge)
	end
	local Cartridge=ents.Create("ent_jack_fgc_energy_rite")
	Cartridge:SetPos(SelfPos+VectorRand()*math.Rand(0,10))
	Cartridge:SetAngles(VectorRand():Angle())
	Cartridge:Spawn()
	Cartridge:Activate()
	Cartridge:GetPhysicsObject():SetVelocity(self:GetVelocity()+self:GetUp()*100)
	undo.AddEntity(Cartridge)
	Cartridge=ents.Create("ent_jack_fgcartridge_energy")
	Cartridge:SetPos(SelfPos+VectorRand()*math.Rand(0,10))
	Cartridge:SetAngles(VectorRand():Angle())
	Cartridge:Spawn()
	Cartridge:Activate()
	Cartridge:GetPhysicsObject():SetVelocity(self:GetVelocity()+self:GetUp()*100)
	undo.AddEntity(Cartridge)
	undo.Finish()
	self:SetBodygroup(1,1)
	self.Used=true
	SafeRemoveEntityDelayed(self,30)
	self:SetDTBool(0,false)
	self.Entity:SetUseType(nil)
end