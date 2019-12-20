-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Mini Bounding Mine"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.UsableMats={MAT_DIRT,MAT_FOLIAGE,MAT_SAND,MAT_SLOSH,MAT_GRASS}
ENT.BlacklistedNPCs={"bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground"}
ENT.WhitelistedNPCs={"npc_rollermine"}
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
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
		self:SetModel("models/grenades/bounding_mine.mdl")
		self:SetModelScale(1.5)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(10)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(JMOD_EZ_STATE_OFF)
	end
	
	function ENT:Bury(activator)
		local Tr=util.QuickTrace(activator:GetShootPos(),activator:GetAimVector()*100,{activator,self})
		if((Tr.Hit)and(table.HasValue(self.UsableMats,Tr.MatType))and(IsValid(Tr.Entity:GetPhysicsObject())))then
			local Ang=Tr.HitNormal:Angle()
			Ang:RotateAroundAxis(Ang:Right(),-90)
			local Pos=Tr.HitPos-Tr.HitNormal*10
			self:SetAngles(Ang)
			self:SetPos(Pos)
			constraint.Weld(self,Tr.Entity,0,0,100000,true)
			local Fff=EffectData()
			Fff:SetOrigin(Tr.HitPos)
			Fff:SetNormal(Tr.HitNormal)
			Fff:SetScale(1)
			util.Effect("eff_jack_sminebury",Fff,true,true)
			self:EmitSound("snd_jack_pinpull.wav")
			activator:EmitSound("Dirt.BulletImpact")
			self.ShootDir=Tr.HitNormal
			self:DrawShadow(false)
			self:Arm(activator)
			--JackaGenericUseEffect(activator)
		end
	end
	
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				if((self:GetState()==JMOD_EZ_STATE_ARMED)and(math.random(1,5)==3))then
					self:Detonate()
				else
					self:EmitSound("Weapon.ImpactHard")
				end
			end
		end
	end
	
	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=5)then
			local Pos,State=self:GetPos(),self:GetState()
			if((State==JMOD_EZ_STATE_ARMED)and(math.random(1,6)==3))then
				self:Detonate()
			elseif((math.random(1,6)==3)and not(State==JMOD_EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(JMOD_EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	
	function ENT:Use(activator)
		local State=self:GetState()
		if(State<0)then return end
		JMod_Hint(activator,"arm","bury","friends")
		local Alt=activator:KeyDown(IN_WALK)
		if(State==JMOD_EZ_STATE_OFF)then
			if(Alt)then
				self.Owner=activator
				self:Bury(activator)
			else
				activator:PickupObject(self)
			end
		else
			self:EmitSound("snd_jack_minearm.wav",60,70)
			self:SetState(JMOD_EZ_STATE_OFF)
			self.Owner=activator
			self:DrawShadow(true)
			constraint.RemoveAll(self)
			self:SetPos(self:GetPos()+self:GetUp()*20)
			activator:PickupObject(self)
		end
	end
	
	function ENT:Boom()
		local SelfPos=self:LocalToWorld(self:OBBCenter())
		local Up=Vector(0,0,1)
		local EffectType=1
		local Traec=util.QuickTrace(self:GetPos(),Vector(0,0,-5),self)
		if(Traec.Hit)then
			if((Traec.MatType==MAT_DIRT)or(Traec.MatType==MAT_SAND))then
				EffectType=1
			elseif((Traec.MatType==MAT_CONCRETE)or(Traec.MatType==MAT_TILE))then
				EffectType=2
			elseif((Traec.MatType==MAT_METAL)or(Traec.MatType==MAT_GRATE))then
				EffectType=3
			elseif(Traec.MatType==MAT_WOOD)then
				EffectType=4
			end
		else
			EffectType=5
		end
		local plooie=EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(1)
		plooie:SetRadius(EffectType)
		plooie:SetNormal(Up)
		util.Effect("eff_jack_minesplode",plooie,true,true)
		for key,playa in pairs(ents.FindInSphere(SelfPos,50))do
			local Clayus=playa:GetClass()
			if((playa:IsPlayer())or(playa:IsNPC())or(Clayuss=="prop_vehicle_jeep")or(Clayuss=="prop_vehicle_jeep")or(Clayus=="prop_vehicle_airboat"))then
				playa:SetVelocity(playa:GetVelocity()+Up*200)
			end
		end
		util.BlastDamage(self,self.Owner or self,SelfPos,120*JMOD_CONFIG.MinePower,30*JMOD_CONFIG.MinePower)
		util.ScreenShake(SelfPos,99999,99999,1,500)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		JMod_Sploom(self.Owner,SelfPos,math.random(10,20))
		for i=1,1000 do
			timer.Simple(i/10000+.01,function()
				if not(IsValid(self))then return end
				local Dir=VectorRand()
				Dir.z=Dir.z/5
				self:FireBullets({
					Attacker=self.Owner or game.GetWorld(),
					Damage=20,
					Force=50,
					Num=1,
					Src=SelfPos,
					Tracer=1,
					Dir=Dir:GetNormalized(),
					Spread=Spred
				})
				if(i==300)then
					-- delay the blast damage so that the bang can be heard
					util.BlastDamage(self,self.Owner or game.GetWorld(),SelfPos,700,20)
				elseif(i==1000)then
					self:Remove()
				end
			end)
		end
	end
	
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		
		local Tr=util.QuickTrace(self:LocalToWorld(self:OBBCenter())+self:GetUp()*20,-self:GetUp()*40,{self,toucher})
		if(Tr.Hit)then timer.Simple(.1,function() util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end) end
		constraint.RemoveAll(self)
		if(Tr.Hit)then self:SetPos(self:GetPos()+Tr.HitNormal*11) end
		self:GetPhysicsObject():ApplyForceCenter(self:GetUp()*3000)
		local Poof=EffectData()
		if(Tr.Hit)then
			Poof:SetOrigin(Tr.HitPos)
			Poof:SetNormal(Tr.HitNormal)
		else
			Poof:SetOrigin(self:GetPos())
			Poof:SetNormal(Vector(0,0,1))
		end
		Poof:SetScale(1)
		util.Effect("eff_jack_sminepop",Poof,true,true)
		--util.SpriteTrail(self,0,Color(50,50,50,255),false,8,20,.5,1/(15+1)*0.5,"trails/smoke.vmt")
		self:EmitSound("snd_jack_sminepop.wav")
		sound.Play("snd_jack_sminepop.wav",self:GetPos(),120,80)
		timer.Simple(math.Rand(.4,.5),function()
			if(IsValid(self))then
				self:Boom()
			end
		end)
		
		Tr=util.QuickTrace(self:GetPos()+self:GetUp()*20,self:GetUp()*30,{self})
		if(Tr.Hit)then
			if(Tr.Entity:IsPlayer() or Tr.Entity:IsNPC())then
				timer.Simple(.5,function()
					if((IsValid(Tr.Entity))and(IsValid(self)))then
						local Bam=DamageInfo()
						Bam:SetDamage(100)
						Bam:SetDamageType(DMG_BLAST)
						Bam:SetDamageForce(self:GetUp()*1000)
						Bam:SetDamagePosition(Tr.HitPos)
						Bam:SetAttacker(self)
						Bam:SetInflictor(self)
						Tr.Entity:TakeDamageInfo(Bam)
					end
				end)
			end
		end
		
	end
	
	function ENT:Arm(armer)
		local State=self:GetState()
		if(State~=JMOD_EZ_STATE_OFF)then return end
		self.Owner=armer
		self:SetState(JMOD_EZ_STATE_ARMING)
		self:SetBodygroup(2,1)
		self:EmitSound("snd_jack_minearm.wav",60,110)
		timer.Simple(3,function()
			if(IsValid(self))then
				if(self:GetState()==JMOD_EZ_STATE_ARMING)then
					self:SetState(JMOD_EZ_STATE_ARMED)
					self:DrawShadow(false)
				end
			end
		end)
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())+vector_up*5
		local Tr=util.TraceLine({
			start=SelfPos,
			endpos=TargPos,
			filter={self,ent},
			mask=MASK_SHOT+MASK_WATER
		})
		return not Tr.Hit
	end
	function ENT:ShouldAttack(ent)
		if not(IsValid(ent))then return false end
		if(ent:IsWorld())then return false end
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
		if(IsValid(PlayerToCheck))then
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
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(State==JMOD_EZ_STATE_ARMED)then
			for k,targ in pairs(ents.FindInSphere(self:GetPos(),100))do
				if(not(targ==self)and((targ:IsPlayer())or(targ:IsNPC())or(targ:IsVehicle())))then
					if((self:ShouldAttack(targ))and(self:CanSee(targ)))then
						self:SetState(JMOD_EZ_STATE_WARNING)
						sound.Play("snds_jack_gmod/mine_warn.wav",self:GetPos()+Vector(0,0,30),60,100)
						timer.Simple(math.Rand(.15,.4)*JMOD_CONFIG.MineDelay,function()
							if(IsValid(self))then
								if(self:GetState()==JMOD_EZ_STATE_WARNING)then self:Detonate() end
							end
						end)
					end
				end
			end
			self:NextThink(Time+.3)
			return true
		end
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		local pos = self:GetPos()+self:GetUp()*11+self:GetRight()*1.5
		if(State==JMOD_EZ_STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos,20,20,Color(255,0,0))
			render.DrawSprite(pos,10,10,Color(255,255,255))
		elseif(State==JMOD_EZ_STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos,30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(pos,15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezboundingmine","EZ Bounding Mine")
end