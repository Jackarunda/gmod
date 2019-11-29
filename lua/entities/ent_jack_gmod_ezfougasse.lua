-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Fougasse Mine"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(90,0,0)
ENT.BlacklistedNPCs={"bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground"}
ENT.WhitelistedNPCs={"npc_rollermine"}
---
local STATE_BROKEN,STATE_OFF,STATE_ARMING,STATE_ARMED,STATE_WARNING=-1,0,1,2,3
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
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
		self.Entity:SetModel("models/props_c17/oildrum001.mdl")
		self.Entity:SetMaterial("models/mat_jack_gmod_ezfougasse")
		self:SetModelScale(.6,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():SetDamping(.01,3)
		end)
		---
		self:SetState(STATE_OFF)
		self.NextArmTime=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				if((self:GetState()==STATE_ARMED)and(math.random(1,5)==3))then
					self:Detonate()
				else
					self.Entity:EmitSound("Canister.ImpactHard")
				end
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=20)then
			local Pos,State=self:GetPos(),self:GetState()
			if((State==STATE_ARMED)and(math.random(1,6)==3))then
				self:Detonate()
			elseif((math.random(1,6)==3)and not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator)
		local State=self:GetState()
		if(State<0)then return end
		JMod_Hint(activator,"arm","friends")
		local Alt=activator:KeyDown(IN_WALK)
		if(State==STATE_OFF)then
			if(Alt)then
				self:Arm(activator)
			else
				activator:PickupObject(self)
			end
		else
			self:EmitSound("snd_jack_minearm.wav",60,70)
			self:SetState(STATE_OFF)
			self.Owner=activator
		end
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:LocalToWorld(self:OBBCenter())
		local Sploom=EffectData()
		Sploom:SetOrigin(SelfPos)
		util.Effect("Explosion",Sploom,true,true)
		util.BlastDamage(self,self.Owner or self,SelfPos,150*JMOD_CONFIG.MinePower,math.random(50,100)*JMOD_CONFIG.MinePower)
		util.ScreenShake(SelfPos,99999,99999,1,500)
		self.Entity:EmitSound("BaseExplosionEffect.Sound")
		--self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Pos=self:GetPos()
		if(self)then self:Remove() end
		timer.Simple(.1,function()
			local Tr=util.QuickTrace(Pos+Vector(0,0,10),Vector(0,0,-20))
			if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		for i=1,50 do
			local FireAng=(self:GetUp()+VectorRand()*.2+Vector(0,0,.1)):Angle()
			local Flame=ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(SelfPos)
			Flame:SetAngles(FireAng)
			Flame:SetOwner(self.Owner or game.GetWorld())
			Flame.Owner=self.Owner or self
			Flame:Spawn()
			Flame:Activate()
		end
	end
	function ENT:Arm(armer)
		local State=self:GetState()
		if(State~=STATE_OFF)then return end
		self.Owner=armer
		self:SetState(STATE_ARMING)
		self:EmitSound("snd_jack_minearm.wav",60,110)
		timer.Simple(3,function()
			if(IsValid(self))then
				if(self:GetState()==STATE_ARMING)then
					self:SetState(STATE_ARMED)
				end
			end
		end)
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())
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
		if(State==STATE_ARMED)then
			local SearchPos=self:GetPos()+self:GetUp()*250
			for k,targ in pairs(ents.FindInSphere(SearchPos,200))do
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
		local State,Vary,Pos=self:GetState(),math.sin(CurTime()*50)/2+.5,self:GetPos()+self:GetUp()*28
		if(State==STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(Pos,20,20,Color(255,0,0))
			render.DrawSprite(Pos,10,10,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(Pos,30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(Pos,15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezfougasse","EZ Fougasse Mine")
end