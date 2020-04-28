-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ SLAM"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(90,0,180)
ENT.JModEZstorable=true
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---

if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*15
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/weapons/w_jlam.mdl")
		self:SetModelScale(1.25,0)
		self:SetBodygroup(0,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(JMOD_EZ_STATE_OFF)
		self.NextStick=0
		self.Damage=500
		---
		JMod_Colorify(self)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(State==JMOD_EZ_STATE_ARMED)then DetChance=DetChance+.3 end
			if(dmginfo:IsDamageType(DMG_BLAST))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
			if((math.random(1,10)==3)and not(State==JMOD_EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(JMOD_EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		JMod_Owner(self,Dude)
		if(IsValid(self.Owner))then
			JMod_Colorify(self)
		end
		
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMOD_CONFIG.AltFunctionKey)
			if(State==JMOD_EZ_STATE_OFF)then
				if(Alt)then
					self:SetState(JMOD_EZ_STATE_ARMING)
					self:SetBodygroup(0,1)
					self:EmitSound("snd_jack_minearm.wav",60,100)
					timer.Simple(3,function()
						if(IsValid(self))then
							if(self:GetState()==JMOD_EZ_STATE_ARMING)then
								local pos = self:GetAttachment(1).Pos
								local trace = util.QuickTrace(pos, self:GetUp() * 1000, self)
								self.BeamFrac = trace.Fraction
								self:SetState(JMOD_EZ_STATE_ARMED)
							end
						end
					end)
                    JMod_Hint(Dude, "friends", self)
				else
					if !IsValid(self.AttachedBomb) then
						constraint.RemoveAll(self)
						self.StuckStick=nil
						self.StuckTo=nil
						Dude:PickupObject(self)
						self.NextStick=Time+.5
					else
						self.AttachedBomb = nil
						timer.Simple(0, function() self:SetParent(nil);Dude:PickupObject(self) end)
						self.NextStick=Time+.5
					end
                    JMod_Hint(Dude, "sticky", self)
				end
			else
				self:EmitSound("snd_jack_minearm.wav",60,70)
				self:SetState(JMOD_EZ_STATE_OFF)
				self:SetBodygroup(0,0)
			end
		else -- player just released the USE key
			
			if((self:IsPlayerHolding())and(self.NextStick<Time) and !IsValid(self.AttachedBomb))then
				local Tr=util.QuickTrace(Dude:GetShootPos(),Dude:GetAimVector()*80,{self,Dude})
				if(Tr.Hit)then
					if((IsValid(Tr.Entity:GetPhysicsObject()))and not(Tr.Entity:IsNPC())and not(Tr.Entity:IsPlayer()))then
						self.NextStick=Time+.5
						local Ang=Tr.HitNormal:Angle()
						Ang:RotateAroundAxis(Ang:Right(),-90)
						self:SetAngles(Ang)
						self:SetPos(Tr.HitPos+Tr.HitNormal*2.35)
						
						if Tr.Entity.EZdetonateOverride then
							self.AttachedBomb=Tr.Entity
							timer.Simple(0,function() self:SetParent(Tr.Entity) end)
						else
							if(Tr.Entity:GetClass()=="func_breakable")then -- crash prevention
								timer.Simple(0,function() self:GetPhysicsObject():Sleep() end)
							else
								local Weld=constraint.Weld(self,Tr.Entity,0,Tr.PhysicsBone,10000,false,false)
								self.StuckTo=Tr.Entity
								self.StuckStick=Weld
							end
						end
						
						self:EmitSound("snd_jack_claythunk.wav",65,math.random(80,120))
						Dude:DropObject()
                        if not JMod_Hint(Dude, "arm", self) then JMod_Hint(Dude, "slam stick", self) end
					end
				end
			end
		end
	end
	function ENT:Detonate(delay,dmg)
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(delay or 0,function()
			if(IsValid(self))then
				local SelfPos=self:GetPos()-self:GetUp()
				if(IsValid(self.AttachedBomb))then
					self.AttachedBomb:EZdetonateOverride(self)
					JMod_Sploom(self.Owner,SelfPos,3)
					self:Remove()
					return
				end
				JMod_Sploom(self.Owner,SelfPos,math.random(50,80))
				util.ScreenShake(SelfPos,99999,99999,.3,500)
				local Dir=(self:GetUp()+VectorRand()*.01):GetNormalized()
				JMod_RicPenBullet(self,SelfPos,Dir,(dmg or 500)*JMOD_CONFIG.MinePower,true,true)
				self:Remove()
			end
		end)
	end
	function ENT:Think()
		local Time=CurTime()
		local state = self:GetState()
		if(state==JMOD_EZ_STATE_ARMED)then
			local pos=self:GetAttachment(1).Pos
			local trace=util.QuickTrace(pos,self:GetUp()*1000,self)
			if((math.abs(self.BeamFrac-trace.Fraction)>=.001)and(JMod_EnemiesNearPoint(self,trace.HitPos,200)))then
				if((trace.Entity:IsPlayer())or(trace.Entity:IsNPC()))then
					self:Detonate()
				else
					if((trace.Entity.GetMaxHealth)and(tonumber(trace.Entity:GetMaxHealth()))and(trace.Entity:GetMaxHealth()>=2000))then
						self:Detonate(.1,600)
					else
						self:Detonate(.1)
					end
				end
			end
			self:NextThink(Time+.1)
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
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezslam","EZ Selectable Lightweight Attack Munition")
end