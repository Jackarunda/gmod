AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()

	--We need to init physics properties even though this entity isn't physically simulated
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:DrawShadow( false )
	self.Entity:SetNoDraw(true)
	
	self.Entity:SetCollisionBounds( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
	self.Entity:PhysicsInitBox( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
	
	local phys=self.Entity:GetPhysicsObject()
	if(phys:IsValid())then
		phys:EnableCollisions( false )		
	end

	self.Entity:SetNotSolid(true)
	
	self.Pos=self:GetPos()
	self.LifeTime=20*self.Power*math.Rand(.7,1.3)*JackieSplosivesFireMult
	self.BirthTime=CurTime()
	
	SafeRemoveEntityDelayed(self,self.LifeTime)
end

function ENT:Think()
	if(self.Parented)then self.Pos=self:GetPos() end
	if(math.random(1,7)==1)then self:EmitSound("snd_jack_fire.wav",90,math.Rand(90,110)) end
	local RemainingTime=self.LifeTime-(CurTime()-self.BirthTime)
	for key,thing in pairs(ents.FindInSphere(self.Pos,150*math.Rand(.8,1.2)*self.Power))do
		if(((IsValid(thing:GetPhysicsObject()))or(thing:IsPlayer())or(thing:IsNPC()))and not((thing==self)or(thing:GetClass()=="ent_jack_napalmpoint")or(thing:IsWorld())))then
			if not(thing:IsOnFire())then thing:Ignite(RemainingTime*3/JackieSplosivesFireMult) end
			local Ouch=DamageInfo()
			Ouch:SetDamage(math.Rand(3,9))
			Ouch:SetDamageType(DMG_BURN)
			Ouch:SetAttacker(self.Entity)
			Ouch:SetInflictor(self.Entity)
			thing:TakeDamageInfo(Ouch)
		end
	end
	Sploof=EffectData()
	Sploof:SetOrigin(self.Pos)
	Sploof:SetNormal(self:GetAngles():Forward())
	Sploof:SetScale(self.Power)
	util.Effect("eff_jack_napalmburn",Sploof,true,true)
	self:NextThink(CurTime()+math.Rand(.2,.3))
	return true
end