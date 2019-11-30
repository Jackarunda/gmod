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
	local Radius=2500
	local Parent=nil
	local Power=10
	
	//util.BlastDamage(self,self,SelfPos,Radius,Power)
	util.ScreenShake(SelfPos,99999,99999,Power/15,Radius*1.5)
	
	local Blam=EffectData()
	Blam:SetOrigin(SelfPos)
	Blam:SetScale(2)
	util.Effect("eff_jack_shrapnelsplosion",Blam,true,true)
	
	self:EmitSound("snd_jack_fragsplodeclose.wav",80,105)
	self:EmitSound("snd_jack_fragsplodeclose.wav",80,95)
	self:EmitSound("snd_jack_fragsplodeclose.wav",90,90)
	self:EmitSound("snd_jack_fragsplodeclose.wav",80,110)
	self:EmitSound("snd_jack_impulse.wav",80,100)
	self:EmitSound("snd_jack_fragsplodefar.wav",130,100)
	
	for key,object in pairs(ents.FindInSphere(SelfPos,100))do
		local Phys=object:GetPhysicsObject()
		if(IsValid(Phys))then
			if(Phys:GetMass()<700)then constraint.RemoveAll(object);object:Fire("enablemotion","",0) end
		end
	end
	
	timer.Simple(.075,function()
		for key,object in pairs(ents.FindInSphere(SelfPos,Radius))do
			if(((IsValid(object:GetPhysicsObject()))or(object:IsPlayer())or(object:IsNPC()))and not((object:IsWorld())or(object==self)))then
				self:FireShrapnel((object:LocalToWorld(object:OBBCenter())-SelfPos):GetNormalized())
			end
		end
		
		for i=1,5 do
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

	timer.Simple(0.1,function()
		if(IsValid(self))then
			for i=0,Radius/25 do
				local Trayuss=util.QuickTrace(SelfPos,VectorRand()*Radius/2,{self.Entity,self.ParentEntity})
				if(Trayuss.Hit)then
					if(Power>150)then
						util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
					else
						util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
					end
				end
			end
		end
	end)
end

function ENT:FireShrapnel(dir)
	local SelfPos=self:GetPos()
	local Spread=Vector(.17,.17,.17)
	local Bellit={
		Attacker=self.Owner,
		Damage=150,
		Force=150,
		Num=40,
		Tracer=0,
		Dir=dir,
		Spread=Spread,
		Src=SelfPos
	}
	self:FireBullets(Bellit)
end