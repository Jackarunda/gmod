--mark eighty tew jenraal prrpus bawmb
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local PenetrationDistanceMultiplierTable={[MAT_VENT]=5,[MAT_GRATE]=10,[MAT_SLOSH]=5,[MAT_DIRT]=3,[MAT_FOLIAGE]=4,[MAT_FLESH]=1.3,[MAT_ALIENFLESH]=1.5,[MAT_ANTLION]=1.5,[MAT_SAND]=2.5,[MAT_PLASTIC]=1.5,[MAT_GLASS]=0.75,[MAT_TILE]=0.75,[MAT_WOOD]=1,[MAT_CONCRETE]=0.35,[MAT_METAL]=0.2,[MAT_COMPUTER]=0.4,[45]=1.7}

function ENT:SpawnFunction(ply,tr)

	//if not tr.Hit then return end

	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_heatbomb")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent:Spawn()
	ent:Activate()
	
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	
	return ent

end

function ENT:Initialize()
	self:SetAngles(Angle(0,0,0))
	self.Entity:SetModel("models/Mechanics/robotics/a1.mdl")

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Exploded=false

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(100)
	end
	
	self.NextUseTime=CurTime()
	self.Heat=0
	
	self.TailFins=ents.Create("prop_physics")
	self.TailFins:SetModel("models/props_junk/cardboard_box001a.mdl")
	self.TailFins:SetPos(self:GetPos()-self:GetForward()*50)
	self.TailFins.AreJackyTailFins=true
	self.TailFins:Spawn()
	self.TailFins:Activate()
	self.TailFins:GetPhysicsObject():SetMass(2)
	self.TailFins:SetNotSolid(true)
	self.TailFins:SetNoDraw(true)
	self:DeleteOnRemove(self.TailFins)
	constraint.Weld(self.Entity,self.TailFins,0,0,0,true)
	
	//HA GARRY I FUCKING BEAT YOU AND YOUR STUPID RULES
	local Settings=physenv.GetPerformanceSettings()
	if(Settings.MaxVelocity<5000)then Settings.MaxVelocity=5000 end
	physenv.SetPerformanceSettings(Settings)
	
	if not(WireAddon==nil)then self.Inputs=Wire_CreateInputs(self,{"Detonate"}) end
end

function ENT:TriggerInput(iname,value)
	if(value==1)then
		self:Detonate()
	end
end

function ENT:Detonate()
	if(self.Exploded)then return end
	self.Exploded=true
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	local Forward=self:GetForward()
	
	sound.Play("BaseExplosionEffect.Sound",SelfPos)
	sound.Play("weapons/explode4.wav",SelfPos,100,150)
	sound.Play("snd_jack_c4splodeclose.wav",SelfPos,110,100)
	sound.Play("snd_jack_c4splodefar.wav",SelfPos,160,100)
	sound.Play("weapons/explode3.wav",SelfPos,100,150)
	self.Entity:EmitSound("BaseExplosionEffect.Sound")

	local splad=EffectData()
	splad:SetOrigin(SelfPos)
	splad:SetScale(1)
	util.Effect("eff_jack_detonate",splad,true,true)
	
	util.BlastDamage(self.Entity,self.Entity,SelfPos,200,70)
	util.ScreenShake(SelfPos,10,10,.75,500)
	
	self:RockAndRollBitch(SelfPos,Forward)

	self:Remove()
end

function ENT:PhysicsCollide(data,physobj)
	if(data.Speed>700)then
		if(self.Armed)then
			self:Detonate()
		end
	elseif((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
end

function ENT:OnTakeDamage(dmginfo)
	local hitter=dmginfo:GetAttacker()
	if((dmginfo:IsExplosionDamage())and(dmginfo:GetDamage()>110))then
		self:Detonate()
	end
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if not(self.NextUseTime<CurTime())then return end
		self.NextUseTime=CurTime()+.5
		if not(self.Armed)then
			local Num=activator:GetNetworkedInt("JackyDetGearCount")
			if(Num>0)then
				JackySimpleOrdnanceArm(self,activator,"Set: Impact")
				self.Armed=true
			end
		else
			JackyOrdnanceDisarm(self,activator,"")
			self.Armed=false
			local Wap=activator:GetActiveWeapon()
			if(IsValid(Wap))then Wap:SendWeaponAnim(ACT_VM_DRAW) end
		end
	end
end

function ENT:Think()
	if(self:IsOnFire())then
		self.Heat=self.Heat+1
		if(self.Heat>100)then
			self:Detonate()
		end
	else
		self.Heat=self.Heat-1
	end
end

function ENT:RockAndRollBitch(pos,dir)
	local PreTraceData={
		start=pos,
		endpos=pos+dir*50,
		filter={self},
	}
	local PreTrace=util.TraceLine(PreTraceData)
	if(PreTrace.Hit)then
		util.Decal("Scorch",PreTrace.HitPos+PreTrace.HitNormal,PreTrace.HitPos-PreTrace.HitNormal)
		local Target=PreTrace.Entity
		local MaxDepth=PenetrationDistanceMultiplierTable[PreTrace.MatType]*350
		local StartPos=PreTrace.HitPos+dir*.1
		local CheckPos=StartPos
		local Clear=false
		local ExitPoint=nil
		local PenetratedDepth=.1
		while not((Clear)or(PenetratedDepth>MaxDepth))do
			local CheckTraceData={
				start=CheckPos,
				endpos=CheckPos-dir*6,
				filter={self}
			}
			local CheckTrace=util.TraceLine(CheckTraceData)
			if(CheckTrace.StartSolid)then
				CheckPos=CheckPos+dir*5
				PenetratedDepth=PenetratedDepth+5
			else
				Clear=true
				ExitPoint=CheckPos
				if(CheckTrace.Hit)then util.Decal("Scorch",CheckTrace.HitPos+CheckTrace.HitNormal,CheckTrace.HitPos-CheckTrace.HitNormal) end
			end
		end
		if(Clear)then
			local PowerFraction=1-(PenetratedDepth/MaxDepth)
			self:WhoopAss(ExitPoint,dir,PowerFraction,Target,PreTrace.HitTexture)
		else
			local Phys=Target:GetPhysicsObject()
			if(IsValid(Phys))then Phys:ApplyForceCenter(dir*5e7) end
		end
	else
		self:WhoopAss(pos,dir,1,nil,nil)
	end
end

function ENT:WhoopAss(pos,dir,pow,tgt,tex)
	util.BlastDamage(self.Entity,self.Entity,pos,350,120)
	local splad=EffectData()
	splad:SetOrigin(pos+dir)
	splad:SetNormal(dir)
	splad:SetScale(3*pow^.7)
	util.Effect("eff_jack_penetrate",splad,true,true)
	local Dmg=pow*75
	for i=0,40 do
		local DmgTraceDat={
			start=pos,
			endpos=pos+dir*900*(1-(i/40))+VectorRand()*350*(i/40),
			filter={self}
		}
		local DmgTrace=util.TraceLine(DmgTraceDat)
		if(DmgTrace.Hit)then
			util.Decal("FadingScorch",DmgTrace.HitPos+DmgTrace.HitNormal,DmgTrace.HitPos-DmgTrace.HitNormal)
			local Ouch=DamageInfo()
			Ouch:SetInflictor(self.Entity)
			Ouch:SetAttacker(self.Entity)
			Ouch:SetDamage(Dmg)
			Ouch:SetDamageType(DMG_BLAST)
			Ouch:SetDamagePosition(pos)
			if(IsValid(tgt))then
				if(DmgTrace.Entity==tgt)then
					Ouch:SetDamageForce(Vector(0,0,0))
				else
					Ouch:SetDamageForce(dir*Dmg*500)
				end
			else
				Ouch:SetDamageForce(dir*Dmg*500)
			end
			if(i<10)then
				local Phys=DmgTrace.Entity:GetPhysicsObject()
				if(IsValid(Phys))then
					if(Phys:GetVolume()<50000)then
						constraint.RemoveAll(DmgTrace.Entity)
						DmgTrace.Entity:Fire("enablemotion","",0)
					end
				end
			end
			if(IsValid(DmgTrace.Entity))then DmgTrace.Entity:TakeDamageInfo(Ouch) end
			util.BlastDamage(self.Entity,self.Entity,DmgTrace.HitPos,120,60)
		end
	end
	if(IsValid(tgt))then
		local Ouch=DamageInfo()
		Ouch:SetInflictor(self.Entity)
		Ouch:SetAttacker(self.Entity)
		Ouch:SetDamage(Dmg*5)
		Ouch:SetDamageType(DMG_BLAST)
		Ouch:SetDamagePosition(pos)
		Ouch:SetDamageForce(dir*Dmg)
		local Phys=tgt:GetPhysicsObject()
		if(IsValid(Phys))then
			if(Phys:GetVolume()<500000)then
				constraint.RemoveAll(tgt)
				tgt:Fire("enablemotion","",0)
			end
			if(Phys:GetMass()<1500)then
				SafeRemoveEntity(tgt)
			end
		end
		if(IsValid(tgt))then tgt:TakeDamageInfo(Ouch) end
	end
end

function ENT:OnRemove()
end