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

	self.Entity:SetNotSolid( true )

	self.Entity:Fire("kill","",0.25)

	/*-------------- Here we go, boy --------------*/
	
	local SelfPos=self:GetPos()
	local Radius=3200
	local Parent=nil
	local Power=10
	
	//util.BlastDamage(self,self,SelfPos,Radius,Power)
	util.ScreenShake(SelfPos,99999,99999,Power/15,Radius*1.5)
	
	timer.Simple(.075,function()
		for key,object in pairs(ents.FindInSphere(SelfPos,Radius))do
			local Class=object:GetClass()
			if(((IsValid(object:GetPhysicsObject()))or(object:IsPlayer())or(object:IsNPC()))and not((object:IsWorld())or(Class=="ent_jack_spoon")or(object==self)or(Class=="ent_jack_fraggrenade")or(Class=="ent_jack_plastisplosion")))then
				self:FireShrapnel((object:LocalToWorld(object:OBBCenter())-SelfPos):GetNormalized())
			end
		end
		
		for i=1,20 do
			local Spray={
				Attacker=self.Owner,
				Damage=10,
				Force=10,
				Num=10,
				Tracer=0,
				Dir=VectorRand(),
				Spread=Vector(2,2,2),
				Src=self:GetPos()
			}
			self:FireBullets(Spray)
		end
	end)
end

function ENT:FireShrapnel(dir)
	local SelfPos=self:GetPos()
	local Spread=Vector(.048,.048,.048)
	local Bellit={
		Attacker=self.Owner,
		Damage=40,
		Force=40,
		Num=17,
		Tracer=0,
		Dir=dir,
		Spread=Spread,
		Src=SelfPos
	}
	self:FireBullets(Bellit)
end