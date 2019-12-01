-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZminiNade-Proximity"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,-140,0)
ENT.BlacklistedNPCs={"bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground"}
ENT.WhitelistedNPCs={"npc_rollermine"}
ENT.JModEZstorable=true
---
local STATE_BROKEN,STATE_OFF,STATE_PRIMED,STATE_ARMING,STATE_ARMED,STATE_WARNING=-1,0,1,2,3,4
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
		self.Entity:SetModel("models/weapons/w_fragjade.mdl")
		self.Entity:SetMaterial("models/mats_jack_nades/gnd_red")
		self.Entity:SetModelScale(1.25,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
	end
	function ENT:PhysicsCollide(data,physobj)
		if((not(IsValid(self.AttachedBomb)))and(self:IsPlayerHolding())and(data.HitEntity.EZdetonateOverride))then
			self.Entity:EmitSound("Grenade.ImpactHard")
			self:SetPos(data.HitPos-data.HitNormal)
			self.AttachedBomb=data.HitEntity
			timer.Simple(0,function() self:SetParent(data.HitEntity) end)
			return
		end
		if(data.DeltaTime>0.2 and data.Speed>30)then
			self.Entity:EmitSound("Grenade.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(dmginfo:IsDamageType(DMG_BLAST))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
			if((math.random(1,10)==3)and not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		self.Owner=Dude
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(IN_WALK)
			if(State==STATE_OFF and Alt)then
				self:SetState(STATE_PRIMED)
				self:EmitSound("weapons/pinpull.wav",60,100)
				self:SetBodygroup(1,1)
			end
			JMod_Hint(activator,"grenade","friends","mininade")
			JMod_ThrowablePickup(Dude,self)
		end
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())+vector_up
		local Tr=util.TraceLine({
			start=SelfPos,
			endpos=TargPos,
			filter={self,ent,self.AttachedBomb},
			mask=MASK_SHOT+MASK_WATER
		})
		return not Tr.Hit
	end
	function ENT:ShouldAttack(ent)
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
		if(State==STATE_PRIMED)then
			if not(self:IsPlayerHolding())then
				self:SetState(STATE_ARMING)
				local Spewn=ents.Create("ent_jack_spoon")
				Spewn:SetPos(self:GetPos())
				Spewn:Spawn()
				Spewn:Activate()
				Spewn:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*750)
				self.Entity:EmitSound("snd_jack_spoonfling.wav",60,math.random(90,110))
				self:EmitSound("snd_jack_minearm.wav",60,110)
				self:SetBodygroup(2,1)
				timer.Simple(1,function()
					if(IsValid(self))then self:SetState(STATE_ARMED) end
				end)
			end
			self:NextThink(Time+.1)
			return true
		elseif(State==STATE_ARMED)then
			local Range=80
			if(IsValid(self.AttachedBomb))then Range=120 end
			for k,targ in pairs(ents.FindInSphere(self:GetPos(),Range))do
				if(not(targ==self)and((targ:IsPlayer())or(targ:IsNPC())or(targ:IsVehicle())))then
					if((self:ShouldAttack(targ))and(self:CanSee(targ)))then
						self:SetState(STATE_WARNING)
						sound.Play("snds_jack_gmod/mine_warn.wav",self:GetPos()+Vector(0,0,30),60,100)
						timer.Simple(math.Rand(.15,.4)*JMOD_CONFIG.MineDelay,function()
							if(IsValid(self))then
								if(self:GetState()==STATE_WARNING)then self:Detonate() end
							end
						end)
					end
				end
			end
			self:NextThink(Time+.3)
			return true
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		if(IsValid(self.AttachedBomb))then
			self.AttachedBomb:EZdetonateOverride(self)
			JMod_Sploom(self.Owner,SelfPos,3)
			self:Remove()
			return
		end
		JMod_Sploom(self.Owner,SelfPos,math.random(50,80))
		util.ScreenShake(SelfPos,20,20,1,500)
		self:Remove()
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+self:GetUp()*2,10,10,Color(255,0,0))
			render.DrawSprite(self:GetPos()+self:GetUp()*2,5,5,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+self:GetUp()*2,15*Vary,15*Vary,Color(255,0,0))
			render.DrawSprite(self:GetPos()+self:GetUp()*2,7*Vary,7*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_eznade_proximity","EZminiNade-Proximity")
end