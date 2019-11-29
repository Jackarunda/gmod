-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Sentry"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.EZconsumes={"ammo","power","parts"}
ENT.EZupgrades={
	rate=2,
	grades={
		{parts=40,advparts=20},
		{parts=60,advparts=40},
		{parts=80,advparts=80},
		{parts=100,advparts=160}
	}
}
ENT.JModPreferredCarryAngles=Angle(0,0,0)
-- config --
ENT.StaticPerfSpecs={
	MaxElectricity=100,
	SearchTime=7,
	TargetLockTime=5,
	ImmuneDamageTypes={DMG_POISON,DMG_NERVEGAS,DMG_RADIATION,DMG_DROWN,DMG_DROWNRECOVER},
	ResistantDamageTypes={DMG_BURN,DMG_SLASH,DMG_SONIC,DMG_ACID,DMG_SLOWBURN,DMG_PLASMA,DMG_DIRECT},
	BlacklistedNPCs={"npc_enemyfinder","bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground","npc_bullseye"},
	WhitelistedNPCs={"npc_rollermine"},
	SpecialTargetingHeights={["npc_rollermine"]=15},
	MaxDurability=100,
	ThinkSpeed=1,
	Efficiency=.8
}
ENT.DynamicPerfSpecs={
	MaxAmmo=300,
	TurnSpeed=60,
	TargetingRadius=20,
	Armor=8,
	ResistantArmor=16,
	FireRate=10,
	MinDamage=5,
	MaxDamage=15,
	Accuracy=1,
	SearchSpeed=.5
}
function ENT:InitPerfSpecs()
	local PerfMult=self:GetPerfMult() or 1
	local Grade=self:GetGrade()
	for specName,value in pairs(self.StaticPerfSpecs)do self[specName]=value end
	for specName,value in pairs(self.DynamicPerfSpecs)do self[specName]=value*EZ_GRADE_BUFFS[Grade]*PerfMult end
	self.TargetingRadius=self.TargetingRadius*52.493 -- convert meters to source units
end
function ENT:Upgrade(level)
	if not(level)then level=self:GetGrade()+1 end
	if(level>5)then return end
	self:SetGrade(level)
	self:InitPerfSpecs()
	self.UpgradeProgress={}
end
----
local STATE_BROKEN,STATE_OFF,STATE_WATCHING,STATE_SEARCHING,STATE_ENGAGING,STATE_WHINING=-1,0,1,2,3,4
function ENT:SetupDataTables()
	self:NetworkVar("Float",0,"AimPitch")
	self:NetworkVar("Float",1,"AimYaw")
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Float",2,"Electricity")
	self:NetworkVar("Int",1,"Ammo")
	self:NetworkVar("Int",2,"Grade")
	self:NetworkVar("Float",3,"PerfMult")
end
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		ent.Owner=ply
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_phx/oildrum001_explosive.mdl")
		self.Entity:SetMaterial("models/mat_jack_gmod_ezsentry")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		local phys=self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:Wake()
			phys:SetMass(200)
			phys:SetBuoyancyRatio(.3)
		end
		---
		self:SetGrade(EZ_GRADE_BASIC)
		if(IsValid(self.Owner))then
			local Tem=self.Owner:Team()
			if(Tem)then
				local Col=team.GetColor(Tem)
				if(Col)then self:SetColor(Col) end
			end
		end
		self:SetPerfMult(JMOD_CONFIG.SentryPerformanceMult)
		self:InitPerfSpecs()
		---
		self:Point(0,0)
		self.SearchStageTime=self.SearchTime/2
		self:SetAmmo(self.MaxAmmo)
		self:SetElectricity(self.MaxElectricity)
		self:SetState(STATE_OFF)
		self.Durability=self.MaxDurability
		self.NextWhine=0
		self.UpgradeProgress={}
		self.EZbuildCost=JMOD_CONFIG.Blueprints["EZ Sentry"][2]
		---
		self:ResetMemory()
	end
	function ENT:ResetMemory()
		self.NextFire=0
		self.NextRealThink=0
		self.Firing=false
		self.NextTargetSearch=0
		self.Target=nil
		self.NextTargetReSearch=0
		self.NextFixTime=0
		self.NextUseTime=0
		self.SearchData={
			LastKnownTarg=nil,
			LastKnownPos=nil,
			LastKnownVel=nil,
			NextDeEsc=0, -- next de-escalation to the watching state
			NextSearchChange=0, -- time to move on to the next phase of searching
			State=0 -- 0=not searching, 1=aiming at last known point, 2=aiming at predicted point
		}
	end
	function ENT:PhysicsCollide(data,physobj)
		if((data.Speed>80)and(data.DeltaTime>0.2))then
			self.Entity:EmitSound("Canister.ImpactHard")
			if(data.Speed>1000)then
				local Dam,World=DamageInfo(),game.GetWorld()
				Dam:SetDamage(data.Speed/3)
				Dam:SetAttacker(data.HitEntity or World)
				Dam:SetInflictor(data.HitEntity or World)
				Dam:SetDamageType(DMG_CRUSH)
				Dam:SetDamagePosition(data.HitPos)
				Dam:SetDamageForce(data.TheirOldVelocity)
				self:DamageSpark()
				self:TakeDamageInfo(Dam)
			end
		end
	end
	function ENT:ConsumeElectricity(amt)
		amt=(amt or .04)/self.Efficiency
		local NewAmt=math.Clamp(self:GetElectricity()-amt,0,self.MaxElectricity)
		self:SetElectricity(NewAmt)
		if(NewAmt<=0)then self:TurnOff() end
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*30+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
		self:ConsumeElectricity(.2)
	end
	function ENT:DetermineDmgResistance(dmg)
		for k,typ in pairs(self.ImmuneDamageTypes)do
			if(dmg:IsDamageType(typ))then return 1000 end
		end
		for k,typ in pairs(self.ResistantDamageTypes)do
			if(dmg:IsDamageType(typ))then return self.ResistantArmor end
		end
		return self.Armor
	end
	function ENT:OnTakeDamage(dmginfo) -- todo: less damage from front
		if(self)then
			self:TakePhysicsDamage(dmginfo)
			local Armor=self:DetermineDmgResistance(dmginfo)
			if(Armor>=1000)then return end
			self.Durability=self.Durability-dmginfo:GetDamage()/Armor
			if(self.Durability<=0)then self:Break(dmginfo) end
			if(self.Durability<=-100)then self:Destroy(dmginfo) end
		end
	end
	function ENT:FlingProp(mdl,force)
		local Prop=ents.Create("prop_physics")
		Prop:SetPos(self:GetPos()+self:GetUp()*25+VectorRand()*math.Rand(1,25))
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:Spawn()
		Prop:Activate()
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*math.Rand(1,300)+self:GetUp()*100)
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
		if(force)then Phys:ApplyForceCenter(force/7) end
		SafeRemoveEntityDelayed(Prop,math.random(20,40))
	end
	function ENT:Break(dmginfo)
		if(self:GetState()==STATE_BROKEN)then return end
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,10 do self:DamageSpark() end
		self.Durability=0
		self:SetState(STATE_BROKEN)
		local Force=dmginfo:GetDamageForce()
		for i=1,4 do
			self:FlingProp("models/mechanics/gears/gear12x6_small.mdl",Force)
		end
	end
	function ENT:Destroy(dmginfo)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,10 do self:DamageSpark() end
		local Force=dmginfo:GetDamageForce()
		self:FlingProp("models/weapons/w_mach_m249para.mdl",Force)
		for i=1,3 do
			self:FlingProp("models/gibs/scanner_gib02.mdl",Force)
			self:FlingProp("models/props_c17/oildrumchunk01d.mdl",Force)
			self:FlingProp("models/props_c17/oildrumchunk01e.mdl",Force)
			self:FlingProp("models/gibs/scanner_gib02.mdl",Force)
		end
		self:Remove()
	end
	function ENT:Use(activator)
		if(activator:IsPlayer())then
			local State=self:GetState()
			if(State==STATE_BROKEN)then JMod_Hint(activator,"fix");return end
			JMod_Hint(activator,"supplies","friends","upgrade")
			if(State>0)then
				self:TurnOff()
			else
				if(self:GetElectricity()>0)then self:TurnOn(activator) end
			end
		end
	end
	function ENT:TurnOff()
		local State=self:GetState()
		if((State==STATE_OFF)or(State==STATE_BROKEN))then return end
		self:SetState(STATE_OFF)
		self:EmitSound("snds_jack_gmod/ezsentry_shutdown.wav",65,100)
		self:ResetMemory()
	end
	function ENT:TurnOn(activator)
		local OldOwner=self.Owner
		self.Owner=activator
		if(IsValid(self.Owner))then
			if(OldOwner~=self.Owner)then -- if owner changed then reset team color
				local Tem=self.Owner:Team()
				if(Tem)then
					local Col=team.GetColor(Tem)
					if(Col)then self:SetColor(Col) end
				end
			end
		end
		self:SetState(STATE_WATCHING)
		self:EmitSound("snds_jack_gmod/ezsentry_startup.wav",65,100)
		self:ResetMemory()
	end
	function ENT:DetermineTargetAimPoint(ent)
		if not(IsValid(ent))then return nil end
		if(ent:IsPlayer())then
			if(ent:Crouching())then
				return ent:GetShootPos()-Vector(0,0,5)
			else
				return ent:GetShootPos()-Vector(0,0,15)
			end
		elseif(ent:IsNPC())then
			local Class,Height=ent:GetClass(),0
			local SpecialTargetingHeight=self.SpecialTargetingHeights[Class]
			if(SpecialTargetingHeight)then
				Height=SpecialTargetingHeight
			else
				Height=ent:OBBMaxs().z-ent:OBBMins().z
			end
			return ent:GetPos()+Vector(0,0,Height*.5)
		else
			return ent:LocalToWorld(ent:OBBCenter())
		end
	end
	function ENT:GetVel(ent)
		if not(IsValid(ent))then return Vector(0,0,0) end
		local Phys=(ent.GetPhysicsObject and ent:GetPhysicsObject()) or nil
		if(IsValid(Phys))then
			return Phys:GetVelocity()
		else
			return ent:GetVelocity()
		end
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=self:DetermineTargetAimPoint(ent),self:GetPos()+self:GetUp()*35
		local Dist=TargPos:Distance(SelfPos)
		if(Dist>self.TargetingRadius)then return false end
		local Tr=util.TraceLine({
			start=SelfPos,
			endpos=TargPos,
			filter={self,ent},
			mask=MASK_SHOT+MASK_WATER
		})
		return not Tr.Hit
	end
	function ENT:ShouldShoot(ent)
		if not(IsValid(ent))then return false end
		local Gaymode,PlayerToCheck=engine.ActiveGamemode(),nil
		if(ent:IsPlayer())then
			PlayerToCheck=ent
		elseif(ent:IsNPC())then
			local Class=ent:GetClass()
			if(table.HasValue(self.WhitelistedNPCs,Class))then return true end
			if(table.HasValue(self.BlacklistedNPCs,Class))then return false end
			return ent:Health()>0
		elseif(ent:IsVehicle())then
			PlayerToCheck=ent:GetDriver()
		end
		if((IsValid(PlayerToCheck))and(PlayerToCheck.Alive))then
			if(PlayerToCheck.EZkillme)then return true end -- for testing
			if((self.Owner)and(PlayerToCheck==self.Owner))then return false end
			local Allies=(self.Owner and self.Owner.JModFriends)or {}
			if(table.HasValue(Allies,PlayerToCheck))then return false end
			local OurTeam=nil
			if(IsValid(self.Owner))then OurTeam=self.Owner:Team() end
			if(Gaymode=="sandbox")then return PlayerToCheck:Alive() end
			if(OurTeam)then return PlayerToCheck:Alive() and PlayerToCheck:Team()~=OurTeam end
			return PlayerToCheck:Alive()
		end
		return false
	end
	function ENT:CanEngage(ent)
		if not(IsValid(ent))then return false end
		return self:ShouldShoot(ent) and self:CanSee(ent)
	end
	function ENT:TryFindTarget()
		local Time=CurTime()
		if(self.NextTargetSearch>Time)then
			if(self:CanEngage(self.Target))then return self.Target end
			if(self:CanEngage(self.SearchData.LastKnownTarg))then return self.SearchData.LastKnownTarg end
			return nil
		end
		self:ConsumeElectricity(.02)
		self.NextTargetSearch=Time+(.5/self.SearchSpeed^2) -- limit searching cause it's expensive
		local SelfPos=self:GetPos()
		local Objects,PotentialTargets=ents.FindInSphere(SelfPos,self.TargetingRadius),{}
		for k,PotentialTarget in pairs(Objects)do
			if(self:CanEngage(PotentialTarget))then table.insert(PotentialTargets,PotentialTarget) end
		end
		if(#PotentialTargets>0)then
			table.sort(PotentialTargets,function(a,b)
				local DistA,DistB=a:GetPos():Distance(SelfPos),b:GetPos():Distance(SelfPos)
				return DistA<DistB
			end)
			return PotentialTargets[1]
		end
		return nil
	end
	function ENT:Engage(target)
		self.Target=target
		self.SearchData.LastKnownTarg=self.Target
		self.SearchData.LastKnownVel=self:GetVel(self.Target)
		self.SearchData.LastKnownPos=self:DetermineTargetAimPoint(self.Target)
		self.NextTargetReSearch=CurTime()+self.TargetLockTime
		self.SearchData.State=0
		self:SetState(STATE_ENGAGING)
		self:EmitSound("snds_jack_gmod/ezsentry_engage.wav",65,100)
	end
	function ENT:Disengage()
		local Time=CurTime()
		self.SearchData.State=1
		self.SearchData.NextSearchChange=Time+self.SearchStageTime
		self.SearchData.NextDeEsc=Time+self.SearchTime
		self:SetState(STATE_SEARCHING)
		self:EmitSound("snds_jack_gmod/ezsentry_disengage.wav",65,100)
	end
	function ENT:StandDown()
		self.Target=nil
		self.SearchData.State=0
		self:SetState(STATE_WATCHING)
		self:EmitSound("snds_jack_gmod/ezsentry_standdown.wav",65,100)
	end
	function ENT:Think()
		local Time=CurTime()
		if(self.NextRealThink<Time)then
			local Electricity,Ammo=self:GetElectricity(),self:GetAmmo()
			self.NextRealThink=Time+.25/self.ThinkSpeed
			self.Firing=false
			local State=self:GetState()
			if(State>0)then
				if((Ammo<=0)or not(self:AmClearToMove()))then
					if(State~=STATE_WHINING)then self:SetState(STATE_WHINING) end
				elseif(State==STATE_WHINING)then
					self:SetState(STATE_WATCHING)
				end
			end
			if(State==STATE_WATCHING)then
				local Target=self:TryFindTarget()
				if(Target)then
					self:Engage(Target)
				else
					self:ReturnToForward()
				end
			elseif(State==STATE_SEARCHING)then
				if(self:CanEngage(self.Target))then
					self:Engage(self.Target)
				else
					local Target=self:TryFindTarget()
					if(IsValid(Target))then
						self:Engage(Target)
					else -- use search behavior
						local SearchState=self.SearchData.State
						if(SearchState==0)then
							self:StandDown()
						elseif(SearchState==1)then -- aim at last known point
							local NeedTurnPitch,NeedTurnYaw=self:GetTargetAimOffset(self.SearchData.LastKnownPos)
							if((math.abs(NeedTurnPitch)>0)or(math.abs(NeedTurnYaw)>0))then
								self:Turn(NeedTurnPitch,NeedTurnYaw)
							end
						elseif(SearchState==2)then -- aim at last known predicted point
							local PredictedPos=self.SearchData.LastKnownPos+self.SearchData.LastKnownVel*self.SearchStageTime
							local NeedTurnPitch,NeedTurnYaw=self:GetTargetAimOffset(PredictedPos)
							if((math.abs(NeedTurnPitch)>0)or(math.abs(NeedTurnYaw)>0))then
								self:Turn(NeedTurnPitch,NeedTurnYaw)
							end
						end
						if(self.SearchData.NextSearchChange<Time)then
							self.SearchData.NextSearchChange=Time+self.SearchStageTime
							self.SearchData.State=self.SearchData.State+1
							if(self.SearchData.State==3)then self:StandDown() end
						end
						if(self.SearchData.NextDeEsc<Time)then self:StandDown() end
					end
				end
			elseif(State==STATE_ENGAGING)then
				if(self:CanEngage(self.Target))then
					if(self.NextTargetReSearch<Time)then
						self.NextTargetReSearch=Time+self.TargetLockTime
						local NewTarget=self:TryFindTarget()
						if((NewTarget)and(NewTarget~=self.Target))then self:Engage(NewTarget) end
					else
						local TargPos=self:DetermineTargetAimPoint(self.Target)
						self.SearchData.LastKnownTarg=self.Target
						self.SearchData.LastKnownVel=self:GetVel(self.Target)
						self.SearchData.LastKnownPos=TargPos
						local NeedTurnPitch,NeedTurnYaw=self:GetTargetAimOffset(TargPos)
						local GottaTurnP,GottaTurnY=math.abs(NeedTurnPitch),math.abs(NeedTurnYaw)
						if((GottaTurnP>0)or(GottaTurnY>0))then
							self:Turn(NeedTurnPitch,NeedTurnYaw)
						end
						if((GottaTurnP<5)and(GottaTurnY<5))then self.Firing=true end
					end
				else
					local Target=self:TryFindTarget()
					if(Target)then
						self:Engage(Target)
					else
						self:Disengage()
					end
				end
			elseif(State==STATE_BROKEN)then
				if(Electricity>0)then
					if(math.random(1,4)==2)then self:DamageSpark() end
				end
			elseif(State==STATE_WHINING)then
				self:Whine(true)
			end
			if(((Electricity<self.MaxElectricity*.1)or(Ammo<self.MaxAmmo*.1))and(State>0))then self:Whine() end
			if(self.NextFixTime<Time)then
				self.NextFixTime=Time+10
				self:GetPhysicsObject():SetBuoyancyRatio(.3)
			end
		end
		if(self.Firing)then
			if(self.NextFire<Time)then
				self.NextFire=Time+1/self.FireRate
				self:FireAtPoint(self.SearchData.LastKnownPos)
			end
		end
		self:NextThink(Time+.05)
		return true
	end
	function ENT:AmClearToMove()
		return true -- todo
	end
	function ENT:Whine(serious)
		if(serious)then self:ReturnToForward() end
		local Time=CurTime()
		if(self.NextWhine<Time)then
			self.NextWhine=Time+4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.wav",70,100)
			self:ConsumeElectricity(.02)
		end
	end
	function ENT:FireAtPoint(point)
		if not(point)then return end
		local Ammo=self:GetAmmo()
		if(Ammo<=0)then return end
		local SelfPos,Up,Right,Forward=self:GetPos(),self:GetUp(),self:GetRight(),self:GetForward()
		local AimAng=self:GetAngles()
		AimAng:RotateAroundAxis(Right,self:GetAimPitch())
		AimAng:RotateAroundAxis(Up,self:GetAimYaw())
		local AimForward=AimAng:Forward()
		local ShootPos=SelfPos+Up*38+AimForward*29
		---
		ParticleEffect("muzzleflash_smg",ShootPos,AimAng,self)
		local ShellAng=AimAng:GetCopy()
		ShellAng:RotateAroundAxis(ShellAng:Up(),-90)
		local Eff=EffectData()
		Eff:SetOrigin(SelfPos+Up*36+AimForward*5)
		Eff:SetAngles(ShellAng)
		Eff:SetEntity(self)
		util.Effect("RifleShellEject",Eff,true,true)
		sound.Play("snds_jack_gmod/ezsentry_fire_close.wav",SelfPos,70,math.random(90,110))
		sound.Play("snds_jack_gmod/ezsentry_fire_far.wav",SelfPos+Up,100,math.random(90,110))
		---
		local Dmg=(math.Rand(self.MinDamage,self.MaxDamage)^2)/10
		local ShootDir=(point-ShootPos):GetNormalized()
		local Inacc=.08/self.Accuracy
		ShootDir=(ShootDir+VectorRand()*math.Rand(0,Inacc)):GetNormalized()
		local Ballut={
			Attacker=self.Owner or self,
			Callback=nil,
			Damage=Dmg,
			Force=Dmg/5,
			Distance=nil,
			HullSize=nil,
			Num=1,
			Tracer=5,
			TracerName="eff_jack_gmod_smallarmstracer",
			Dir=ShootDir,
			Spread=Vector(0,0,0),
			Src=ShootPos,
			IgnoreEntity=nil
		}
		self:FireBullets(Ballut)
		---
		self:SetAmmo(Ammo-1)
		self:ConsumeElectricity()
	end
	function ENT:GetTargetAimOffset(point)
		if not(point)then return nil,nil end
		local SelfPos=self:GetPos()+self:GetUp()*35
		local TargAng=self:WorldToLocalAngles((point-SelfPos):Angle())
		local GoalPitch,GoalYaw=-TargAng.p,TargAng.y
		local CurPitchOffset,CurYawOffset=self:GetAimPitch(),self:GetAimYaw()
		return -(CurPitchOffset-GoalPitch),CurYawOffset-GoalYaw
	end
	function ENT:RandomMove()
		local X,Y=self:GetAimYaw(),self:GetAimPitch()
		self:Point(Y+math.Rand(-1,1)*self.TurnSpeed/8,X+math.Rand(-1,1)*self.TurnSpeed/4)
		self:ConsumeElectricity()
		-- todo: sound
	end
	function ENT:ReturnToForward()
		local X,Y=self:GetAimYaw(),self:GetAimPitch()
		if((X==0)and(Y==0))then return end
		local TurnAmtPitch=math.Clamp(-Y,-self.TurnSpeed/8,self.TurnSpeed/8)
		local TurnAmtYaw=math.Clamp(X,-self.TurnSpeed/4,self.TurnSpeed/4)
		self:Point(Y+TurnAmtPitch,X-TurnAmtYaw)
		if((math.abs(TurnAmtPitch)>.5)or(math.abs(TurnAmtYaw)>.5))then
			sound.Play("snds_jack_gmod/ezsentry_turn.wav",self:GetPos(),60,math.random(95,105))
		end
		self:ConsumeElectricity()
	end
	function ENT:Turn(pitch,yaw)
		local X,Y=self:GetAimYaw(),self:GetAimPitch()
		local TurnAmtPitch=math.Clamp(pitch,-self.TurnSpeed/8,self.TurnSpeed/8)
		local TurnAmtYaw=math.Clamp(yaw,-self.TurnSpeed/4,self.TurnSpeed/4)
		self:Point(Y+TurnAmtPitch,X-TurnAmtYaw)
		if((math.abs(TurnAmtPitch)>.5)or(math.abs(TurnAmtYaw)>.5))then
			sound.Play("snds_jack_gmod/ezsentry_turn.wav",self:GetPos(),60,math.random(95,105))
		end
		self:ConsumeElectricity()
	end
	function ENT:Point(pitch,yaw)
		if(pitch~=nil)then
			if(pitch>90)then pitch=90 end
			if(pitch<-45)then pitch=-45 end
			self:SetAimPitch(pitch)
		end
		if(yaw~=nil)then
			if(yaw>180)then yaw=yaw-360 end
			if(yaw<-180)then yaw=yaw+360 end
			self:SetAimYaw(yaw)
		end
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZsalvage()
		if(self.Salvaged)then return end
		self.Salvaged=true
		local scale,pos=1,self:GetPos()+self:GetUp()*20
		---
		local effectdata=EffectData()
		effectdata:SetOrigin(pos+VectorRand())
		effectdata:SetNormal((VectorRand()+Vector(0,0,1)):GetNormalized())
		effectdata:SetMagnitude(math.Rand(1,2)*scale*4) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)*scale*4) --length of strands
		effectdata:SetRadius(math.Rand(2,4)*scale*4) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		---
		sound.Play("snds_jack_gmod/ez_tools/hit.wav",pos+VectorRand(),60,math.random(80,120))
		sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",pos,60,math.random(80,120))
		---
		local eff=EffectData()
		eff:SetOrigin(pos+VectorRand())
		eff:SetScale(scale)
		util.Effect("eff_jack_gmod_ezbuildsmoke",eff,true,true)
		---
		for i=1,20 do
			timer.Simple(i/100,function()
				if(IsValid(self))then
					if(i<20)then
						sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",pos,60,math.random(80,120))
					else
						local PartsFrac=(self.Durability+self.MaxDurability)/(self.MaxDurability*2)
						local Box=ents.Create("ent_jack_gmod_ezparts")
						Box:SetPos(pos+VectorRand()*10)
						Box:Spawn()
						Box:Activate()
						Box:SetResource(PartsFrac*self.EZbuildCost.parts*.75)
						local Amm=self:GetAmmo()
						if(Amm>0)then
							local Box=ents.Create("ent_jack_gmod_ezammo")
							Box:SetPos(pos+VectorRand()*10)
							Box:Spawn()
							Box:Activate()
							Box:SetResource(Amm)
						end
						local Powa=self:GetElectricity()
						if(Powa>1)then
							local Batt=ents.Create("ent_jack_gmod_ezbattery")
							Batt:SetPos(pos+VectorRand()*10)
							Batt:Spawn()
							Batt:Activate()
							Batt:SetResource(math.floor(Powa))
						end
						self:Remove()
					end
				end
			end)
		end
	end
	function ENT:TryLoadResource(typ,amt)
		if(amt<=0)then return 0 end
		if(typ=="ammo")then
			local Ammo=self:GetAmmo()
			local Missing=self.MaxAmmo-Ammo
			if(Missing<=0)then return 0 end
			local Accepted=math.min(Missing,amt)
			self:SetAmmo(Ammo+Accepted)
			self:EmitSound("snd_jack_turretammoload.wav",65,math.random(90,110))
			return Accepted
		elseif(typ=="power")then
			local Powa=self:GetElectricity()
			local Missing=self.MaxElectricity-Powa
			if(Missing<=0)then return 0 end
			if(Missing<self.MaxElectricity*.1)then return 0 end
			local Accepted=math.min(Missing,amt)
			self:SetElectricity(Powa+Accepted)
			self:EmitSound("snd_jack_turretbatteryload.wav",65,math.random(90,110))
			return math.ceil(Accepted)
		elseif(typ=="parts")then
			local Missing=self.MaxDurability-self.Durability
			if(Missing<=self.MaxDurability*.25)then return 0 end
			local Accepted=math.min(Missing,amt)
			self.Durability=self.Durability+Accepted
			if(self.Durability>=self.MaxDurability)then self:RemoveAllDecals() end
			self:EmitSound("snd_jack_turretrepair.wav",65,math.random(90,110))
			if(self.Durability>0)then
				if(self:GetState()==STATE_BROKEN)then self:SetState(STATE_OFF) end
			end
			return math.ceil(Accepted)
		end
		return 0
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self:InitPerfSpecs()
		---
		self.BaseGear=JMod_MakeModel(self,"models/props_phx/gears/spur36.mdl",nil,.25)
		self.VertGear=JMod_MakeModel(self,"models/props_phx/gears/spur36.mdl",nil,.15)
		self.MiniBaseGear=JMod_MakeModel(self,"models/props_phx/gears/spur12.mdl",nil,.25)
		self.MiniVertGear=JMod_MakeModel(self,"models/props_phx/gears/spur12.mdl",nil,.15)
		self.MachineGun=JMod_MakeModel(self,"models/weapons/w_mach_m249para.mdl")
		self.MainPost=JMod_MakeModel(self,"models/mechanics/solid_steel/box_beam_12.mdl",nil,.2)
		self.ElevationMotor=JMod_MakeModel(self,"models/xqm/hydcontrolbox.mdl",nil,.35)
		self.TriggerMotor=JMod_MakeModel(self,"models/xqm/hydcontrolbox.mdl",nil,.3)
		self.Shield=JMod_MakeModel(self,"models/hunter/tubes/circle2x2b.mdl","phoenix_storms/gear",.3)
		self.Light=JMod_MakeModel(self,"models/props_wasteland/light_spotlight02_lamp.mdl",nil,.3)
		self.Lens=JMod_MakeModel(self,"models/hunter/misc/sphere025x025.mdl","debug/env_cubemap_model",.3)
		self.OmniLens=JMod_MakeModel(self,"models/hunter/misc/sphere025x025.mdl","debug/env_cubemap_model",.3)
		self.Camera=JMod_MakeModel(self,"models/mechanics/robotics/b2.mdl","phoenix_storms/metal",.4)
		self.LeftHandle=JMod_MakeModel(self,"models/props_wasteland/panel_leverhandle001a.mdl","phoenix_storms/metal")
		self.RightHandle=JMod_MakeModel(self,"models/props_wasteland/panel_leverhandle001a.mdl","phoenix_storms/metal")
		---
		self.CurAimPitch=0
		self.CurAimYaw=0
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	local GradeColors={Vector(.3,.3,.3),Vector(.2,.2,.2),Vector(.2,.2,.2),Vector(.2,.2,.2),Vector(.2,.2,.2)}
	local GradeMats={Material("phoenix_storms/metal"),Material("models/mat_jack_gmod_copper"),Material("models/mat_jack_gmod_silver"),Material("models/mat_jack_gmod_gold"),Material("models/mat_jack_gmod_platinum")}
	function ENT:Draw()
		local SelfPos,SelfAng,AimPitch,AimYaw,State,Grade=self:GetPos(),self:GetAngles(),self:GetAimPitch(),self:GetAimYaw(),self:GetState(),self:GetGrade()
		local Up,Right,Forward,FT=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward(),FrameTime()
		self.CurAimPitch=Lerp(FT*3,self.CurAimPitch,AimPitch)
		self.CurAimYaw=Lerp(FT*3,self.CurAimYaw,AimYaw)
		-- no snap-swing resets
		if(math.abs(self.CurAimPitch-AimPitch)>45)then self.CurAimPitch=AimPitch end
		if(math.abs(self.CurAimYaw-AimYaw)>90)then self.CurAimYaw=AimYaw end
		---
		local BasePos=SelfPos+Up*32
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		---
		local Matricks=Matrix()
		Matricks:Scale(Vector(1,1,.5))
		self:EnableMatrix("RenderMultiply",Matricks)
		self:DrawModel()
		---
		local BaseGearAngle=SelfAng:GetCopy()
		BaseGearAngle:RotateAroundAxis(Up,self.CurAimYaw)
		if(DetailDraw)then JMod_RenderModel(self.BaseGear,SelfPos+Up*22,BaseGearAngle,nil,Vector(.7,.7,.7)) end
		---
		local PostAngle=BaseGearAngle:GetCopy()
		PostAngle:RotateAroundAxis(PostAngle:Forward(),90)
		JMod_RenderModel(self.MainPost,SelfPos+Up*20+PostAngle:Up()*2.1,PostAngle,nil,Vector(.2,.2,.2))
		---
		if(DetailDraw)then
			local MiniGearAngle=BaseGearAngle:GetCopy()
			MiniGearAngle:RotateAroundAxis(Up,-self.CurAimYaw*4+15)
			JMod_RenderModel(self.MiniBaseGear,SelfPos+Up*22-Forward*8.8,MiniGearAngle,nil,Vector(.7,.7,.7))
			---
			local LeftHandleAng=SelfAng:GetCopy()
			LeftHandleAng:RotateAroundAxis(LeftHandleAng:Up(),90)
			LeftHandleAng:RotateAroundAxis(LeftHandleAng:Right(),173)
			JMod_RenderModel(self.LeftHandle,SelfPos+Up*20+Right*13.7,LeftHandleAng)
			---
			local RightHandleAng=SelfAng:GetCopy()
			RightHandleAng:RotateAroundAxis(RightHandleAng:Up(),-90)
			RightHandleAng:RotateAroundAxis(RightHandleAng:Right(),173)
			JMod_RenderModel(self.RightHandle,SelfPos+Up*20-Right*13.7,RightHandleAng)
		end
		---
		local VertGearAngle=SelfAng:GetCopy()
		VertGearAngle:RotateAroundAxis(VertGearAngle:Up(),self.CurAimYaw)
		VertGearAngle:RotateAroundAxis(VertGearAngle:Right(),self.CurAimPitch)
		VertGearAngle:RotateAroundAxis(VertGearAngle:Forward(),90)
		if(DetailDraw)then JMod_RenderModel(self.VertGear,BasePos,VertGearAngle,nil,Vector(.7,.7,.7)) end
		---
		if(DetailDraw)then
			local MiniVertGearAngle=SelfAng:GetCopy()
			MiniVertGearAngle:RotateAroundAxis(MiniVertGearAngle:Up(),self.CurAimYaw)
			MiniVertGearAngle:RotateAroundAxis(MiniVertGearAngle:Right(),-self.CurAimPitch*3+15)
			MiniVertGearAngle:RotateAroundAxis(MiniVertGearAngle:Forward(),90)
			JMod_RenderModel(self.MiniVertGear,SelfPos+Up*26.7,MiniVertGearAngle,nil,Vector(.7,.7,.7))
			---
			local MiniVertMotorAngle=SelfAng:GetCopy()
			MiniVertMotorAngle:RotateAroundAxis(MiniVertMotorAngle:Up(),self.CurAimYaw)
			MiniVertMotorAngle:RotateAroundAxis(MiniVertMotorAngle:Forward(),90)
			MiniVertMotorAngle:RotateAroundAxis(MiniVertMotorAngle:Up(),180)
			JMod_RenderModel(self.ElevationMotor,SelfPos+Up*26.7+MiniVertMotorAngle:Up()*2-MiniVertMotorAngle:Forward()*.8,MiniVertMotorAngle,nil,Vector(.5,.5,.5))
		end
		-- immobile gun group --
		local AimAngle=VertGearAngle:GetCopy()
		AimAngle:RotateAroundAxis(AimAngle:Forward(),-90)
		local AimUp,AimRight,AimForward=AimAngle:Up(),AimAngle:Right(),AimAngle:Forward()
		JMod_RenderModel(self.MachineGun,BasePos-AimUp*4+AimForward*7.5-AimRight*.5,AimAngle)
		---
		local ShieldAngle=AimAngle:GetCopy()
		ShieldAngle:RotateAroundAxis(ShieldAngle:Right(),130)
		ShieldAngle:RotateAroundAxis(ShieldAngle:Up(),45)
		JMod_RenderModel(self.Shield,BasePos+AimForward*17.5+AimUp*3.3-AimRight*.7,ShieldAngle,nil,Vector(.1,.1,.1))
		---
		if(DetailDraw)then
			local CamAngle=AimAngle:GetCopy()
			CamAngle:RotateAroundAxis(CamAngle:Forward(),-90)
			CamAngle:RotateAroundAxis(CamAngle:Up(),180)
			JMod_RenderModel(self.Camera,BasePos+AimUp*8.5-AimForward-AimRight*.65,CamAngle,nil,GradeColors[Grade],GradeMats[Grade])
			---
			local TriggerAngle=AimAngle:GetCopy()
			TriggerAngle:RotateAroundAxis(TriggerAngle:Forward(),90)
			JMod_RenderModel(self.TriggerMotor,BasePos+AimUp*2+AimForward*1-AimRight*3.5,TriggerAngle,nil,Vector(.5,.5,.5))
			---
			JMod_RenderModel(self.Lens,BasePos+AimUp*8.6+AimForward*8.4-AimRight*.65,AimAngle)
			---
			JMod_RenderModel(self.OmniLens,BasePos+AimUp*8-AimForward*8-AimRight*.65,AimAngle)
			---
			JMod_RenderModel(self.Light,BasePos+AimUp*10-AimRight*3.5+AimForward*6.8,AimAngle,nil,Vector(.5,.5,.5))
			---
			if((Closeness<20000)and(State>0))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(),70)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),-90)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*28-Right*7.5-Forward*8,DisplayAng,.075)
				draw.SimpleTextOutlined("POWER","JMod-Display",200,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac=self:GetElectricity()/self.MaxElectricity
				local R,G,B=JMod_GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",200,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local Ammo=self:GetAmmo()
				local AmmoFrac=Ammo/self.MaxAmmo
				local R,G,B=JMod_GoodBadColor(AmmoFrac)
				draw.SimpleTextOutlined("AMMO","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				draw.SimpleTextOutlined(tostring(Ammo),"JMod-Display",0,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
		---
		local LightColor=nil
		if(State==STATE_WATCHING)then
			LightColor=Color(0,255,0)
		elseif(State==STATE_SEARCHING)then
			LightColor=Color(255,255,0)
		elseif(State==STATE_ENGAGING)then
			LightColor=Color(255,0,0)
		elseif(State==STATE_WHINING)then
			local Mul=(math.sin(CurTime()*5))/2+.5
			LightColor=Color(255*Mul,255*Mul,0)
		end
		if(LightColor)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(BasePos+AimUp*10+AimForward*9-AimRight*3.5,7,7,LightColor)
		end
	end
	language.Add("ent_jack_gmod_ezsentry","EZ Sentry")
end