AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local MaximumRicochetAngleTable={[MAT_VENT]=0,[MAT_GRATE]=0,[MAT_SLOSH]=0,[MAT_DIRT]=5,[MAT_GRASS]=5,[MAT_FOLIAGE]=4,[MAT_FLESH]=3,[MAT_ALIENFLESH]=3,[MAT_ANTLION]=3,[MAT_SAND]=4,[MAT_PLASTIC]=7,[MAT_GLASS]=15,[MAT_TILE]=20,[MAT_WOOD]=15,[MAT_CONCRETE]=25,[MAT_METAL]=35,[MAT_COMPUTER]=30,[45]=3}
local PenetrationDistanceMultiplierTable={[MAT_VENT]=5,[MAT_GRATE]=10,[MAT_SLOSH]=5,[MAT_DIRT]=4,[MAT_GRASS]=4,[MAT_FOLIAGE]=4,[MAT_FLESH]=1.3,[MAT_ALIENFLESH]=1.5,[MAT_ANTLION]=1.5,[MAT_SAND]=3.75,[MAT_PLASTIC]=2,[MAT_GLASS]=0.75,[MAT_TILE]=0.75,[MAT_WOOD]=1,[MAT_CONCRETE]=0.35,[MAT_METAL]=0.2,[MAT_COMPUTER]=0.9,[45]=2}

function ENT:Initialize()
	self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
	self.Entity:SetMaterial("models/debug/debugwhite")
	if not(self:GetDTBool(0))then self.Entity:SetMaterial("phoenix_storms/iron_rails") end
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON) --don't want to shoot yourself in the back of the head
	self.Entity:DrawShadow(true)
	
	local phys=self.Entity:GetPhysicsObject()
	if(phys:IsValid())then
		phys:Wake()
		phys:SetMass(10)
	end
	
	if(self:GetDTBool(0))then
		local SmokeTrail=ents.Create("env_spritetrail")
		SmokeTrail:SetKeyValue("lifetime",".1")
		SmokeTrail:SetKeyValue("startwidth","0")
		SmokeTrail:SetKeyValue("endwidth","10")
		SmokeTrail:SetKeyValue("spritename","trails/smoke.vmt")
		SmokeTrail:SetKeyValue("rendermode","5")
		SmokeTrail:SetKeyValue("rendercolor","255 255 255")
		SmokeTrail:SetPos(self.Entity:GetPos())
		SmokeTrail:SetParent(self.Entity)
		SmokeTrail:Spawn()
		SmokeTrail:Activate()
		self.Trail=SmokeTrail
	end
	
	self.HasEnteredWater=false

	if not(self.Owner)then self:Remove() return end
	if not(self.Weapon)then self:Remove() return end
	if not(self.InitialFlightDirection)then self:Remove() return end
	if not(self.InitialFlightSpeed)then self:Remove() return end
	
	self.CurrentFlightSpeed=self.InitialFlightSpeed
	self.CurrentFlightDirection=self.InitialFlightDirection
	
	self:SetAngles(self.InitialFlightDirection:Angle())
	
	self.Heat=1
	
	self:Think()
end

function ENT:Think()
	if(self.Trail)then
		local Heat=self.Heat
		local Red=math.Clamp(Heat*463-69,0,255)
		local Green=math.Clamp(Heat*1275-1020,0,255)
		local Blue=math.Clamp(Heat*2550-2295,0,255)
		self.Trail:SetKeyValue("rendercolor",tostring(Red).." "..tostring(Green).." "..tostring(Blue))
		self.Heat=self.Heat-.005
	end
	
	local SelfPos=self:GetPos()
	
	local NoseTraceData={}
	NoseTraceData.start=SelfPos
	NoseTraceData.endpos=SelfPos+self.CurrentFlightDirection*self.CurrentFlightSpeed*1.25
	NoseTraceData.filter={self,self.Owner}
	NoseTraceData.mask=MASK_SHOT
	local NoseTrace=util.TraceLine(NoseTraceData)
	
	if(NoseTrace.Hit)then
		if(NoseTrace.HitSky)then self:Remove() return end
		self:SetPos(NoseTrace.HitPos+NoseTrace.HitNormal)
		self:Impact(NoseTrace)
	else
		self:SetPos(SelfPos+self.CurrentFlightDirection*self.CurrentFlightSpeed)
	end
	self:SetAngles(self.CurrentFlightDirection:Angle())
	self.CurrentFlightDirection=(self.CurrentFlightDirection+Vector(0,0,-.002)):GetNormalized()
	self.CurrentFlightSpeed=self.CurrentFlightSpeed*.99
	
	if(self.Entity:WaterLevel()>0)then
		if not(self.HasEnteredWater)then
			self.HasEnteredWater=true
			self:WaterSurfaceSplash(NoseTrace.HitPos)
		end
		self.CurrentFlightSpeed=self.CurrentFlightSpeed*.1 --slow down like a bitch
	end
	
	self:NextThink(CurTime()+.01)
	return true
end

function ENT:Impact(trace)
	if(self.Impacted)then return end
	self.Impacted=true
	
	if(self.CurrentFlightSpeed<100)then self:Remove() return end

	local SelfPos=self:GetPos()
	local Magnitude=self.OverallSize
	local Speed=self.CurrentFlightSpeed
	local Severity=((Magnitude*Speed^2)/2)/3500
	local Forward=self:GetForward()
	local BulletNum=math.ceil(Severity/10)
	local DamMod=1.5
	
	if(trace.HitGroup==HITGROUP_HEAD)then
		DamMod=DamMod*2
	elseif((trace.HitGroup==HITGROUP_LEFTLEG)or(trace.HitGroup==HITGROUP_RIGHTLEG)or(trace.HitGroup==HITGROUP_LEFTARM)or(trace.HitGroup==HITGROUP_RIGHTARM))then
		DamMod=DamMod/3
	end
	
	local Inflictor=self.Weapon
	if not(IsValid(self.Weapon))then Inflictor=self.Entity end
	
	local Damage=DamageInfo()
	Damage:SetDamage(Severity*DamMod)
	Damage:SetDamageType(DMG_BULLET)
	Damage:SetDamagePosition(trace.HitPos)
	Damage:SetAttacker(self.Owner)
	Damage:SetInflictor(Inflictor)
	Damage:SetDamageForce(Forward*Severity*3000)
	
	self:MakeImpactEffect(trace.HitPos+trace.HitNormal,Forward,BulletNum)

	trace.Entity:TakeDamageInfo(Damage)

	local ApproachVector=self.CurrentFlightDirection
	local DotProduct=ApproachVector:DotProduct(trace.HitNormal)
	local ApproachAngle=(-math.deg(math.asin(DotProduct)))
	if(ApproachAngle<=MaximumRicochetAngleTable[trace.MatType])then
		-- we'll ricochet
		local ApproachVecAng=self.CurrentFlightDirection:Angle()
		ApproachVecAng:RotateAroundAxis(trace.HitNormal,180)
		self.CurrentFlightDirection=-ApproachVecAng:Forward()
		self.Impacted=false
		self.CurrentFlightSpeed=self.CurrentFlightSpeed*.75
		sound.Play("snd_jack_ricochet_"..tostring(math.random(1,2))..".wav",trace.HitPos+trace.HitNormal,80,math.Rand(85,115))
	else
		-- let's try to penetrate
		local InitialPos=trace.HitPos
		local PenetrationDistance=.05*self.CurrentFlightSpeed*PenetrationDistanceMultiplierTable[trace.MatType]
		local WillPenetrate=false
		local CheckDistance=1
		local Vectah=self.CurrentFlightDirection
		while((not(WillPenetrate))and(CheckDistance<=PenetrationDistance))do --it's a more costly way of doing penetration checks, but it's much more reliable
			if(CheckDistance>=1000)then break end
			local TraceData={}
			TraceData.start=InitialPos+Vectah*CheckDistance
			TraceData.endpos=InitialPos
			TraceData.filter=self.Entity
			local Trace=util.TraceLine(TraceData)
			if(Trace.StartSolid)then
				CheckDistance=CheckDistance+1
			else
				WillPenetrate=true
			end
		end
		if(WillPenetrate)then
			self:SetPos(InitialPos+self.CurrentFlightDirection*CheckDistance)
			self.Impacted=false
			self.CurrentFlightSpeed=self.CurrentFlightSpeed*.75
			self:MakeImpactEffect(InitialPos+self.CurrentFlightDirection*CheckDistance,-self.CurrentFlightDirection,1)
		else
			SafeRemoveEntity(self)
		end
	end
end

function ENT:MakeImpactEffect(pos,dir,num)
	local Tr={start=pos,endpos=pos+dir*1000}
	local T=util.TraceLine(Tr)
	if((T.Entity==self.Owner)or(T.Entity==NULL))then return end
	local EffectBullet={}
	EffectBullet.Num=math.ceil(num)
	EffectBullet.Src=pos
	EffectBullet.Dir=dir
	EffectBullet.Spread=Vector(0,0,0)
	EffectBullet.Tracer=0
	EffectBullet.Damage=1
	EffectBullet.Force=1
	self.Entity:FireBullets(EffectBullet)
end

function ENT:WaterSurfaceSplash(InitialCheckPos) --jackarunda is clever
	local NormVec=self.CurrentFlightDirection
	local HasSplashed=false
	local CheckPos=InitialCheckPos
	while(HasSplashed==false)do
		local Contents=util.PointContents(CheckPos)
		if not((Contents==CONTENTS_WATER)or(Contents==CONTENTS_TRANSLUCENT)or(Contents==CONTENTS_TRANSLUCENT+CONTENTS_WATER))then
			local EffectPower=(self.CurrentFlightSpeed)/25
			local effectdata=EffectData()
			effectdata:SetOrigin(CheckPos)
			effectdata:SetNormal(Vector(0,0,1))
			effectdata:SetRadius(EffectPower)
			effectdata:SetScale(EffectPower)
			util.Effect("watersplash",effectdata)
			HasSplashed=true
		else
			CheckPos=CheckPos-NormVec*5
		end
	end
end