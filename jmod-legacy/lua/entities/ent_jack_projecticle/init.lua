AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local StickTable={MAT_FLESH,MAT_ALIENFLESH,MAT_BLOODYFLESH,MAT_DIRT,MAT_SAND,MAT_WOOD,MAT_ANTLION,MAT_PLASTIC}

function ENT:Initialize()	
	self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
	self.Entity:SetMaterial("models/mat_jack_ice")
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
	
	self.HasFallenInWater=false
	self.Impacted=false
	
	if not(self:GetDTFloat(0))then self:Remove() return end
	if not(self.Owner)then self:Remove() return end
	if not(self.Weapon)then self:Remove() return end
	if not(self.InitialFlightDirection)then self:Remove() return end
	if not(self.InitialFlightSpeed)then self:Remove() return end
	
	self.CurrentFlightSpeed=self.InitialFlightSpeed
	self.CurrentFlightDirection=self.InitialFlightDirection
	
	local SmokeTrail=ents.Create("env_spritetrail")
	SmokeTrail:SetKeyValue("lifetime",".03")
	SmokeTrail:SetKeyValue("startwidth","0")
	SmokeTrail:SetKeyValue("endwidth","10")
	SmokeTrail:SetKeyValue("spritename","trails/smoke.vmt")
	SmokeTrail:SetKeyValue("rendermode","5")
	SmokeTrail:SetKeyValue("rendercolor","180 185 200")
	SmokeTrail:SetPos(self.Entity:GetPos())
	SmokeTrail:SetParent(self.Entity)
	SmokeTrail:Spawn()
	SmokeTrail:Activate()
	
	self:SetAngles(self.InitialFlightDirection:Angle())
	self:Think()
end

function ENT:Think()
	if not(self.HasFallenInWater)then
		if(self:WaterLevel()==3)then
			self.HasFallenInWater=true
			local Pwoof=EffectData()
			Pwoof:SetOrigin(self:GetPos())
			Pwoof:SetScale(5)
			util.Effect("watersplash",Pwoof,true,true)
		end
	end
	
	local SelfPos=self:GetPos()
	
	local Chance=3
	if not(self.Impacted)then Chance=1 end
	if(math.random(1,Chance)==1)then
		local Scayul=self:GetDTFloat(0)/30
		local Shh=EffectData()
		Shh:SetOrigin(SelfPos+VectorRand()*math.Rand(0,4)*Scayul)
		Shh:SetStart(self:GetVelocity()+VectorRand()*math.Rand(0,5))
		Shh:SetScale(Scayul)
		util.Effect("eff_jack_cold",Shh,true,true)
	end
	
	if(self.Impacted)then
		if(IsValid(self.StuckEntity))then
			local Health=self.StuckEntity:Health()
			if((self.StuckEntity:IsPlayer())or(self.StuckEntity:IsNPC()))then
				if(Health)then
					if(Health<=0)then
						self:Remove()
						return
					end
				end
			end
		end
		self:NextThink(CurTime()+.01)
		return true
	end
	
	local NoseTraceData={}
	NoseTraceData.start=SelfPos
	NoseTraceData.endpos=SelfPos+self.CurrentFlightDirection*self.CurrentFlightSpeed*1.25
	NoseTraceData.filter={self,self.Owner}
	NoseTraceData.mask=MASK_SHOT
	local NoseTrace=util.TraceLine(NoseTraceData)
	
	if(NoseTrace.Hit)then
		self:SetPos(NoseTrace.HitPos+NoseTrace.HitNormal*.1)
		self:Impact(NoseTrace)
	else
		self:SetPos(SelfPos+self.CurrentFlightDirection*self.CurrentFlightSpeed)
	end
	self:SetAngles(self.CurrentFlightDirection:Angle())
	self.CurrentFlightDirection=(self.CurrentFlightDirection+Vector(0,0,-.003)):GetNormalized()
	self.CurrentFlightSpeed=self.CurrentFlightSpeed*.99
	
	self:NextThink(CurTime()+.01)
	return true
end

function ENT:Impact(trace)
	if(self.Impacted)then return end
	self.Impacted=true
	
	self.StuckEntity=trace.Entity

	local SelfPos=self:GetPos()
	local Magnitude=self:GetDTFloat(0)
	local Speed=self.CurrentFlightSpeed
	local Severity=((Magnitude*Speed^2)/2)/3500
	local Forward=self:GetForward()
	local BulletNum=math.ceil(Severity/15)
	local DamMod=.75
	
	if(trace.HitGroup==HITGROUP_HEAD)then
		DamMod=10
	elseif((trace.HitGroup==HITGROUP_LEFTLEG)or(trace.HitGroup==HITGROUP_RIGHTLEG)or(trace.HitGroup==HITGROUP_LEFTARM)or(trace.HitGroup==HITGROUP_RIGHTARM))then
		DamMod=.5
	end
	
	local Damage=DamageInfo()
	Damage:SetDamage(Severity*DamMod)
	Damage:SetDamageType(DMG_BULLET)
	Damage:SetDamagePosition(trace.HitPos)
	Damage:SetAttacker(self.Owner)
	Damage:SetInflictor(self.Weapon)
	Damage:SetDamageForce(Forward*Severity*300)
	
	local EffectBullet={Damage=1,Src=SelfPos,Dir=self:GetForward(),Num=BulletNum,Tracer=0,Spread=Vector(0,0,0),Force=Severity*3}
	self:FireBullets(EffectBullet)

	trace.Entity:TakeDamageInfo(Damage)

	if(table.HasValue(StickTable,trace.MatType))then
		if((trace.Entity:IsNPC())or(trace.Entity:IsPlayer()))then
			self:SetPos(trace.HitPos+trace.Normal*Magnitude/15)
			self:SetParent(trace.Entity)
			trace.Entity:DeleteOnRemove(self)
		elseif not(trace.Entity:IsWorld())then
			self:SetPos(trace.HitPos+trace.HitNormal/2)
			self.Entity:SetParent(trace.Entity)
			trace.Entity:DeleteOnRemove(self)
		else
			//derp
		end
		SafeRemoveEntityDelayed(self,30)
	else
		local Shatter=EffectData()
		Shatter:SetOrigin(trace.HitPos)
		Shatter:SetNormal(trace.HitNormal)
		Shatter:SetScale(Magnitude)
		util.Effect("eff_jack_iceimpact",Shatter,true,true)
		
		SafeRemoveEntity(self)
		local Snd=math.Rand(80,120)
		sound.Play("snd_jack_iceimpact.wav",SelfPos,75,Snd)
		util.Decal("impact.glass",trace.HitPos+trace.HitNormal,trace.HitPos-trace.HitNormal)
		sound.Play("snd_jack_iceimpact.wav",SelfPos,90,Snd)
		
		for key,victim in pairs(ents.FindInSphere(trace.HitPos+trace.HitNormal,Severity/1.8))do
			if(victim.TakeDamageInfo)then
				local Damage=DamageInfo()
				Damage:SetDamage(Severity/4)
				Damage:SetDamageType(DMG_SLASH)
				Damage:SetDamagePosition(trace.HitPos)
				Damage:SetAttacker(self.Owner)
				Damage:SetInflictor(self.Weapon)
				Damage:SetDamageForce((victim:GetPos()-trace.HitPos):GetNormalized()*30000)
				victim:TakeDamageInfo(Damage)
			end
		end
	end
end