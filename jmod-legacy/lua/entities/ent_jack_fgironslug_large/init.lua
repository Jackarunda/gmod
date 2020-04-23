AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.DoNotBangOnCartridges=true

function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_fgironslug_large")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/cheeze/pcb2/pcb1.mdl")
	self.Entity:SetMaterial("models/shiny")
	self.Entity:SetColor(Color(100,100,100))
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
end

function ENT:Think()
	//nothin
end

function ENT:PhysicsCollide(data,physobj)
	if not(data.HitEntity.DoNotBangOnCartridges)then
		if(data.DeltaTime>.2)then
			local Traiss=util.QuickTrace(self:GetPos()-data.OurOldVelocity,data.OurOldVelocity*20,self.Entity)
			if(Traiss.Hit)then
				if((Traiss.MatType==MAT_DIRT)or(Traiss.MatType==MAT_SAND))then
					sound.Play("snd_jack_fgc_dirt_"..tostring(math.random(1,2))..".wav",self:GetPos(),70,math.Rand(100,120))
				else
					sound.Play("snd_jack_fgc_concrete_"..tostring(math.random(1,3))..".wav",self:GetPos(),70,math.Rand(100,120))
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
	if(activator:IsPlayer())then
		local Wep=activator:GetActiveWeapon()
		if(IsValid(Wep))then
			if(Wep.IsAJackyFunGun)then
				if(Wep.LoadIronSlug)then
					if(Wep.TakesLargeIron)then
						Wep:LoadIronSlug(self)
						umsg.Start("JackyFGIronLoad")
						umsg.Entity(Wep)
						umsg.Entity(self)
						umsg.End()
					end
				end
			end
		end
	end
end