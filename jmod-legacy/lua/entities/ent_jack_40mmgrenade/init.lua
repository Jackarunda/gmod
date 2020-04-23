include("shared.lua")
local PenetrationDistanceMultiplierTable={[MAT_VENT]=5,[MAT_GRATE]=10,[MAT_SLOSH]=5,[MAT_DIRT]=4,[MAT_FOLIAGE]=4,[MAT_FLESH]=1.3,[MAT_ALIENFLESH]=1.5,[MAT_ANTLION]=1.5,[MAT_SAND]=3.75,[MAT_PLASTIC]=2,[MAT_GLASS]=0.75,[MAT_TILE]=0.75,[MAT_WOOD]=1,[MAT_CONCRETE]=0.35,[MAT_METAL]=0.2,[MAT_COMPUTER]=0.4,[45]=1.7}
function ENT:Initialize()
	self.Entity:SetModel("models/hunter/plates/plate.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(7)
	end
	self:Fire("enableshadow","",0)
	self.Exploded=false
	self.ExplosiveMul=0.5
end
function ENT:PhysicsCollide(data, physobj)
	if(data.Speed>80 and data.DeltaTime>0.2)then
		self:Detonate()
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Think()
	if not(self.Exploded)then
		if((self.Type=="HEDP")or(self.Type=="Dummy"))then
			local vel=self:GetPhysicsObject():GetVelocity()
			if(vel:Length()>200)then
				self:SetAngles(vel:GetNormalized():Angle())
				self:GetPhysicsObject():SetVelocity(vel)
			end
			self:NextThink(CurTime()+0.01)
			return true
		end
	end
end
function ENT:OnRemove()
	--pff
end
function ENT:Detonate()
	if(self.Exploding)then return end
	self.Exploding=true
	local SelfPos=self:GetPos()
	local Pos=SelfPos
	if(true)then
		/*-  EFFECTS  -*/
		util.ScreenShake(SelfPos,99999,99999,1,750)
		
		if(self.Type=="HE")then
			JMod_Sploom(self:GetOwner() or self:GetNetworkedEntity("Owenur"),self:GetPos(),190)
		end
		for i=0,30 do
			local Trayuss=util.QuickTrace(SelfPos,VectorRand()*200,{self.Entity})
			if(Trayuss.Hit)then
				util.Decal("FadingScorch",Trayuss.HitPos+Trayuss.HitNormal,Trayuss.HitPos-Trayuss.HitNormal)
			end
		end
		self.Entity:Remove()
	end
end
function ENT:Use(activator,caller)
	--lol dude
end