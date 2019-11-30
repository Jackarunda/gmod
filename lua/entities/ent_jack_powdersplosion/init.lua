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
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	local Radius=self.BlastRadius
	local Parent=self.ParentEntity
	local Power=self.BasePower
	
	util.ScreenShake(SelfPos,99999,99999,self.BasePower/200,self.BlastRadius*1.5)
	util.BlastDamage(self,self,SelfPos,Radius,self.BasePower*.7)
	
	--[[====================================================
	====		Jackarunda's proprietary system for		====
	====		simulating the force-behavior of a		====
	====		rapidly-expanding volume of gas in		====
	====		a confined space. From scratch.			====
	====		You are all jelly. Year 2013 A.D.		====
	====================================================--]]

	--hittrace structure: {HitAir=bool,HitObject=bool,HitCreature=bool,HitWater=bool,HitWorld=bool,HitEnt=entity,HitPhys=entity,HitMass=number,ObjConstrained=bool,ObjFrozen=bool,HitPos=vector,Vec=vector,Dir=normvector,Dist=number}
	local Hits=0
	local HitTraces={}
	for i=1,400 do
		local Vec=VectorRand()*math.Rand(2,50)*self.BasePower
		local HitTraceData={
			start=SelfPos,
			endpos=SelfPos+Vec,
			filter={self},
			mask=-1
		}
		local HitTrace=util.TraceLine(HitTraceData)
		HitTraces[i]={}
		if not(HitTrace.Hit)then
			HitTraces[i].HitAir=true
			HitTraces[i].HitMass=5
		else
			Hits=Hits+1
			HitTraces[i].HitAir=false
			HitTraces[i].HitPos=HitTrace.HitPos
			if(HitTrace.MatType==MAT_SLOSH)then
				HitTraces[i].HitWater=true
				HitTraces[i].HitMass=100
			elseif((HitTrace.Entity:IsPlayer())or(HitTrace.Entity:IsNPC()))then
				HitTraces[i].HitWater=false
				HitTraces[i].HitCreature=true
				HitTraces[i].HitMass=30
			elseif(HitTrace.HitWorld)then
				HitTraces[i].HitCreature=false
				HitTraces[i].HitWorld=true
				HitTraces[i].HitMass=200
			else HitTraces[i].HitWorld=false end
			local Phys=HitTrace.Entity:GetPhysicsObject()
			if(IsValid(Phys))then
				HitTraces[i].HitObject=true
				HitTraces[i].HitEnt=HitTrace.Entity
				HitTraces[i].HitPhys=Phys
				if not(HitTrace.HitWorld)then
					HitTraces[i].HitMass=Phys:GetMass()
					if not((Phys:IsMoveable())or(Phys:IsMotionEnabled()))then
						HitTraces[i].HitMass=HitTraces[i].HitMass*6
						HitTraces[i].ObjFrozen=true
					elseif(table.Count(constraint.GetAllConstrainedEntities(HitTrace.Entity))>1)then
						if not(HitTrace.Entity.TailFins)then
							HitTraces[i].HitMass=HitTraces[i].HitMass*3
							HitTraces[i].ObjConstrained=true
						end
					end
				end
			else
				HitTraces[i].HitObject=false
			end
			HitTraces[i].Vec=Vec
			HitTraces[i].Dir=Vec:GetNormalized()
			HitTraces[i].Dist=(SelfPos-HitTrace.HitPos):Length()
		end
		HitTraces[i].HitMass=HitTraces[i].HitMass^1.5
	end
	local HitFrac=Hits/400

	local TotalMass=0
	for key,tab in pairs(HitTraces)do TotalMass=TotalMass+tab.HitMass end
	
	local Div=35
	if(HitFrac==1)then Div=20 end --perfect seal, like a boss

	for key,tab in pairs(HitTraces)do
		if(tab.HitObject)then
			local MassFrac=tab.HitMass/TotalMass
			local InvMassFrac=1/MassFrac
			tab.HitPhys:ApplyForceOffset(tab.Dir*self.BasePower*InvMassFrac/Div,tab.HitPos)
			if not((tab.ObjConstrained)or(tab.ObjFrozen))then self:TrailIgnite(tab.HitEnt,tab.HitPhys) end
			--if not(tab.HitEnt:IsWorld())then print(tab.HitEnt:GetModel(),5*self.BasePower*InvMassFrac) end
		end
	end
	
	local Ploom=EffectData()
	Ploom:SetOrigin(SelfPos)
	Ploom:SetScale((self.BasePower/75)*(1-HitFrac)+.1)
	Ploom:SetStart(self.Velocity)
	util.Effect("eff_jack_powdersplode",Ploom,true,true)

	timer.Simple(0.1,function()
		if(IsValid(self))then
			for i=0,Radius/30 do
				local Trayuss=util.QuickTrace(SelfPos,VectorRand()*Radius/1.75,{self.Entity,self.ParentEntity})
				if(Trayuss.Hit)then
					if(self.BasePower>50)then
						util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
					else
						util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
					end
				end
			end
		end
	end)
end

function ENT:TrailIgnite(obj,phys)
	if(obj.JackyPowderSplosionTrailed)then return end
	obj.JackyPowderSplosionTrailed=true
	local Time=10
	if(self.Small)then Time=4 end
	if(math.Rand(0,1)>.2)then obj:Ignite(Time) end
	local vol=phys:GetVolume()
	local Small=0
	local Large=40
	local tr1=util.SpriteTrail(obj,1,Color(255,230,200),true,Large,Small,.1,256,"trails/smoke.vmt")
	local tr2=util.SpriteTrail(obj,2,Color(255,200,100),true,Large,Small,.5,256,"trails/smoke.vmt")
	local tr3=util.SpriteTrail(obj,3,Color(100,100,100),false,Small,Large*1.5,1.5,256,"trails/smoke.vmt")
	SafeRemoveEntityDelayed(tr1,1)
	SafeRemoveEntityDelayed(tr2,2)
	SafeRemoveEntityDelayed(tr3,5)
	timer.Simple(6,function() if(IsValid(obj))then obj.JackyPowderSplosionTrailed=false end end)
end