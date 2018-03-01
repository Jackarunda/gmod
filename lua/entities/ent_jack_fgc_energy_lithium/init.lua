AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.DoNotBangOnCartridges=true
ENT.PowerType="High-Density Rechargeable Lithium-Ion Battery"
ENT.HeatMul=.6
ENT.ConsumptionMul=17.5
ENT.Charge=1.01

function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_fgc_energy_lithium")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/mass_effect_3/weapons/misc/jeatsink.mdl")
	self.Entity:SetMaterial("models/mat_jack_fgc_energy_lithium")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	local phys=self.Entity:GetPhysicsObject()
	if(phys:IsValid())then
		phys:Wake()
		phys:SetMass(10)
	end

	if(self.Charge<=0)then self:SetCollisionGroup(COLLISION_GROUP_WEAPON);SafeRemoveEntityDelayed(self,20) end
end

function ENT:Think()
end

function ENT:PhysicsCollide(data,physobj)
	if not(data.HitEntity.DoNotBangOnCartridges)then
		if(data.DeltaTime>.2)then
			local Traiss=util.QuickTrace(self:GetPos()-data.OurOldVelocity,data.OurOldVelocity*20,self.Entity)
			if(Traiss.Hit)then
				if((Traiss.MatType==MAT_DIRT)or(Traiss.MatType==MAT_SAND))then
					sound.Play("snd_jack_fgc_dirt_"..tostring(math.random(1,2))..".wav",self:GetPos(),70,math.Rand(90,110))
				else
					sound.Play("snd_jack_fgc_concrete_"..tostring(math.random(1,3))..".wav",self:GetPos(),70,math.Rand(90,110))
				end
			end
		end
	end
	local Impulse=-data.Speed*data.HitNormal*2+(data.OurOldVelocity*-2)
	self:GetPhysicsObject():ApplyForceCenter(Impulse)
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator)
	if(self.Charge<=0)then return end
	if(activator:IsPlayer())then
		local Wep=activator:GetActiveWeapon()
		if(IsValid(Wep))then
			if(Wep.IsAJackyFunGun)then
				Wep:LoadEnergyCartridge(self,self.PowerType,self.HeatMul,self.ConsumptionMul,self.Charge)
				umsg.Start("JackyFGEnergyLoad")
				umsg.Entity(Wep)
				umsg.Entity(self)
				umsg.End()
			end
		end
	end
end

function ENT:Touch(ent)
end