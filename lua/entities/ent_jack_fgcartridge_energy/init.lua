AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.DoNotBangOnCartridges=true
ENT.PowerType="Self-Contained Micro Nuclear Fission Reactor"
ENT.HeatMul=1.2
ENT.ConsumptionMul=.8
ENT.Charge=1.01

function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_fgcartridge_energy")
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
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Entity:SetUseType(SIMPLE_USE)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	local phys=self.Entity:GetPhysicsObject()
	if(phys:IsValid())then
		phys:Wake()
		phys:SetMass(12)
	end

	if(self:GetDTBool(0))then
		self.Heat=1
		self.HasFallenInWater=false
		self.AllUsedUp=true
		self.Entity:SetMaterial("models/debug/debugwhite")
		--self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self.Entity:DrawShadow(false)
		SafeRemoveEntityDelayed(self,math.random(50,80))
	end
end

function ENT:Think()
	if not(self.AllUsedUp)then return end

	local Red=math.Clamp(self.Heat*463-69,0,255)
	local Green=math.Clamp(self.Heat*1275-1020,0,255)
	local Blue=math.Clamp(self.Heat*2550-2295,0,255)
	self:SetColor(Color(Red,Green,Blue,255))
	
	self.Heat=self.Heat-.0005
	
	if(self.Heat<.1)then self:DrawShadow(true) end
	
	if(math.Rand(.1,1)<self.Heat)then
		local Num=10
		if(self:WaterLevel()==3)then Num=1 end
		if(math.random(1,Num)==1)then
			local SelfPos=self:LocalToWorld(self:OBBCenter())
		
			local Exude=EffectData()
			Exude:SetOrigin(SelfPos)
			Exude:SetStart(self:GetVelocity())
			util.Effect("eff_jack_heatshimmer",Exude)
		end
	end
	
	if not(self.HasFallenInWater)then
		if(self:WaterLevel()==3)then
			self.HasFallenInWater=true
			sound.Play("snd_jack_fgc_water.wav",self:GetPos(),75,100)
			local Pwoof=EffectData()
			Pwoof:SetOrigin(self:GetPos())
			Pwoof:SetScale(5)
			util.Effect("watersplash",Pwoof)
		end
	end
	
	self:NextThink(CurTime()+.01)
	return true
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
	if(self.AllUsedUp)then return end
	
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
	if not(self.AllUsedUp)then return end
	if(self.Heat>.003)then
		if(math.random(1,6)==2)then
			if(ent.TakeDamageInfo)then
				local Dmg=DamageInfo()
				Dmg:SetDamageType(DMG_BURN)
				Dmg:SetDamage(self.Heat*1.3)
				Dmg:SetDamagePosition(self:GetPos())
				Dmg:SetDamageForce(Vector(0,0,0))
				Dmg:SetAttacker(self.Entity)
				Dmg:SetInflictor(self.Entity)
				ent:TakeDamageInfo(Dmg)
			end
		end
	else
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
end