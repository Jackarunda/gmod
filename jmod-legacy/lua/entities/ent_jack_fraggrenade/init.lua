AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local BounceTable={
	[MAT_METAL]=0.3,
	[MAT_CONCRETE]=0.25,
	[MAT_WOOD]=0.1,
	[MAT_DIRT]=-4,
	[MAT_SAND]=-6,
	[MAT_SLOSH]=-8
}

/*---------------------------------------------------------
	Spawnfunction
---------------------------------------------------------*/
function ENT:SpawnFunction(ply, tr)

	local SpawnPos=tr.HitPos+tr.HitNormal*20
	local ent=ents.Create("ent_jack_fraggrenade")
	ent:SetPos(SpawnPos)
	ent.Owner=ply
	ent.SpoonOff=false
	ent.PinOut=false
	ent:Spawn()
	ent:Activate()
	
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	
	return ent

end

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_eq_fraggrenade.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	if(self.PinOut)then
		self.NextExplodeTime=CurTime()+self.FuzeTime
		
		if not(self.SpoonOff)then
			local Spewn=ents.Create("ent_jack_spoon")
			Spewn:SetPos(self:GetPos())
			Spewn:Spawn()
			Spewn:Activate()
			Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*750)
			self.Entity:EmitSound("snd_jack_spoonfling.wav")
			self.SpoonOff=true
		end
	end

	if(self.SpoonOff)then self:SetDTBool(0,true) end

	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.Exploded=false
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Heat=0
	
	local phys=self.Entity:GetPhysicsObject()
	if(phys:IsValid())then
		phys:Wake()
		phys:SetMass(7)
	end
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
	if(self.PinOut)then
		if(self.SpoonOff)then
			if(self.NextExplodeTime<CurTime())then
				self:Explode()
			end
		end
	end
	if(self:IsOnFire())then
		if(self.Heat>15)then
			self:Explode()
		else
			self.Heat=self.Heat+.1
		end
	else
		if(self.Heat>0)then
			self.Heat=self.Heat-.1
		end
	end
	self:NextThink(CurTime()+.1)
	return true
end

/*---------------------------------------------------------
   Name: ENT:Explode()
---------------------------------------------------------*/
function ENT:Explode()
	if(self.Exploded)then return end
	self.Exploded=true
	local Pos=self:GetPos()
	local Owner=self.Owner
	self:Remove()

	local Blamo=ents.Create("ent_jack_fragsplosion")
	Blamo:SetPos(Pos+Vector(0,0,1))
	Blamo.Owner=Owner
	Blamo:Spawn()
	Blamo:Activate()
end

/*---------------------------------------------------------
	Use
---------------------------------------------------------*/
function ENT:Use(activator,caller)
	if not(self.PinOut)then
		if not(activator:HasWeapon("wep_jack_fraggrenade"))then
			activator:Give("wep_jack_fraggrenade")
			activator:GetWeapon("wep_jack_fraggrenade").PreviousWeapon=activator:GetActiveWeapon():GetClass()
			activator:SelectWeapon("wep_jack_fraggrenade")
			self:Remove()
		end
	end
end

/*--------------------------------------------------------------
	Thop
---------------------------------------------------------------*/
function ENT:PhysicsCollide(data,physobj)
	if(data.DeltaTime>0.2)then
		if(data.Speed>50)then
			self.Entity:EmitSound("Grenade.ImpactHard")
		end
	end
end