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
	local Radius=self.BlastRadius
	local Parent=self.ParentEntity
	local Power=self.BasePower
	//self.BasePower=50
	//self.BlastRadius=400
	//self.ParentEntity=nil

	local Mod=1.2
	local DoorDist=.1
	local KnockDownMod=1
	if(self.Thermobaric)then DoorDist=.3;KnockDownMod=3 end
	local Att,Infl=(self or game.GetWorld()),((self and self.GetOwner and IsValid(self:GetOwner()) and self:GetOwner()) or self) or game.GetWorld()
	util.BlastDamage(Att,Infl,SelfPos,self.BlastRadius,self.BasePower*Mod)
	util.ScreenShake(SelfPos,99999,99999,self.BasePower/250,self.BlastRadius*1.75)
	
	for key,object in pairs(ents.FindInSphere(SelfPos,self.BlastRadius))do
		local class=object:GetClass()
		if((class=="func_door_rotating")or(class=="prop_door_rotating")or(class=="func_door"))then
			if not(object:GetNoDraw())then
				local PhysObj=object:GetPhysicsObject()
				local ObjPos=object:LocalToWorld(object:OBBCenter())
				local Direction=(ObjPos-SelfPos):GetNormalized()
				local LoSTraceData={}
				LoSTraceData.start=SelfPos
				LoSTraceData.endpos=ObjPos
				LoSTraceData.filter={object,self,self.ParentEntity}
				local LoSTrace=util.TraceLine(LoSTraceData)
				if not(LoSTrace.Hit)then
					if((LoSTrace.HitPos-SelfPos):Length()<Radius*DoorDist)then
						object:SetNoDraw(true)
						object:SetNotSolid(true)
						local Moddel=object:GetModel()
						local Pozishun=object:GetPos()
						local Ayngul=object:GetAngles()
						local Muteeriul=object:GetMaterial()
						local Skin=object:GetSkin()
						if((Moddel)and(Pozishun)and(Ayngul))then
							local Replacement=ents.Create("prop_physics")
							Replacement:SetModel(Moddel)
							Replacement:SetPos(Pozishun)
							Replacement:SetAngles(Ayngul)
							if(Muteeriul)then
								Replacement:SetMaterial(Muteeriul)
							end
							if(Skin)then
								Replacement:SetSkin(Skin)
							end
							Replacement:Spawn()
							Replacement:Activate()
						end
					end
				end
			end
		elseif(IsValid(object:GetPhysicsObject()))then
			if not((object==self.ParentEntity)or(object==self.Entity)or(object:IsPlayer()))then
				local PhysObj=object:GetPhysicsObject()
				local ObjPos=object:LocalToWorld(object:OBBCenter())
				local Direction=(ObjPos-SelfPos):GetNormalized()
				local LoSTraceData={}
				LoSTraceData.start=SelfPos
				LoSTraceData.endpos=ObjPos
				LoSTraceData.filter={object,self,self.ParentEntity}
				local LoSTrace=util.TraceLine(LoSTraceData)
				if not(LoSTrace.Hit)then
					local Distance=(ObjPos-SelfPos):Length()^1.5
					local Frakshun=1-(Distance/self.BlastRadius^1.5)
					local ObjectDensity=PhysObj:GetMass()^1.2/PhysObj:GetVolume()
					local PropensityToDestroy=(Frakshun*self.BasePower^1.1/100)*KnockDownMod
					local PropensityToResist=ObjectDensity*130
					if(PropensityToDestroy>PropensityToResist)then
						if(IsValid(object))then constraint.RemoveAll(object) end
						object:Fire("enablemotion","",0)
						if(PropensityToDestroy>PropensityToResist*7)then
							SafeRemoveEntity(object)
						end
					end
				end
			end
		else
			//lol
		end
	end
	
	local Boost=.7
	if(self.FromDynamite)then Boost=.4 end
	if(self.Thermobaric)then Boost=1 end
	if(self.FromNavalMine)then Boost=.9 end
	
	timer.Simple(0.075,function()
		for key,object in pairs(ents.FindInSphere(SelfPos,Radius*1.5))do
			if(IsValid(object:GetPhysicsObject()))then
				if not((object==Parent)or(object==self.Entity))then
					local PhysObj=object:GetPhysicsObject()
					local ObjPos=object:LocalToWorld(object:OBBCenter())
					local Direction=(ObjPos-SelfPos):GetNormalized()
					local LoSTraceData={}
					LoSTraceData.start=SelfPos
					LoSTraceData.endpos=ObjPos
					LoSTraceData.filter={object,self,self.ParentEntity,PhysObj}
					local LoSTrace=util.TraceLine(LoSTraceData)
					if not(LoSTrace.Hit)then
						local Distance=(ObjPos-SelfPos):Length()^2
						local Frakshun=1-(Distance/(Radius*1.5)^2)
						PhysObj:ApplyForceCenter(Direction*Frakshun*Power*2500*Boost)
					elseif(IsValid(LoSTrace.Entity:GetPhysicsObject()))then --if the object is small, we can still force the object behind it
						if(LoSTrace.Entity:GetPhysicsObject():GetVolume()<1500)then
							local Distance=(ObjPos-SelfPos):Length()
							local Frakshun=1-(Distance/(Radius*1.5))
							PhysObj:ApplyForceCenter(Direction*Frakshun*Power*2500*Boost)
						end
					end
				end
			end
		end
	end)

	timer.Simple(0.1,function()
		if(IsValid(self))then
			for i=0,Radius/50 do
				local Trayuss=util.QuickTrace(SelfPos,VectorRand()*Radius/2,{self.Entity,self.ParentEntity})
				if(Trayuss.Hit)then
					if(self.BasePower>150)then
						util.Decal("Scorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
					else
						util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
					end
				end
			end
		end
	end)

end