-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="BLU 108/B submunition"
ENT.NoSitAllowed=true
ENT.Spawnable=false
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
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/XQM/cylinderx1.mdl")
		--self:SetModelScale(1.25,0)
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
		self:SetState(JMod.EZ_STATE_OFF)
		self.NextStick=0
		self.Damage=500
		---
		JMod.Colorify(self)
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"if value > 0, this will detonate", "Arms bomb when > 0"})
			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed \n 0 is not \n -1 is broken"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			if self:GetState() == JMod.EZ_STATE_OFF then
				self:SetState(JMod.EZ_STATE_ARMING)
				self:SetBodygroup(0,1)
				self:EmitSound("snd_jack_minearm.wav",60,100)
				timer.Simple(3,function()
					if(IsValid(self))then
						if(self:GetState()==JMod.EZ_STATE_ARMING)then
							local pos = self:GetAttachment(1).Pos
							local trace = util.QuickTrace(pos, self:GetUp() * 1000, self)
							self.BeamFrac = trace.Fraction
							self:SetState(JMod.EZ_STATE_ARMED)
						end
					end
				end)
			end
		end
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
		if(JMod.LinCh(Dmg,20,100))then
			local Pos,State=self:GetPos(),self:GetState()
			if(State==JMod.EZ_STATE_ARMED)then
				self:Detonate()
			elseif(not(State==JMod.EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		JMod.Owner(self,Dude)
		if(IsValid(self.Owner))then
			JMod.Colorify(self)
		end
		
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMod.Config.AltFunctionKey)
			if(State==JMod.EZ_STATE_OFF)then
				if(Alt)then
					self:SetState(JMod.EZ_STATE_ARMING)
					self:SetBodygroup(0,1)
					self:EmitSound("snd_jack_minearm.wav",60,100)
					timer.Simple(3,function()
						if(IsValid(self))then
							if(self:GetState()==JMod.EZ_STATE_ARMING)then
								local pos = self:GetAttachment(1).Pos
								local trace = util.QuickTrace(pos, self:GetUp() * 1000, selfg)
								self.BeamFrac = trace.Fraction
								self:SetState(JMod.EZ_STATE_ARMED)
							end
						end
					end)
					JMod.Hint(Dude, "mine friends", selfg)
				end
			else
				self:SetState(JMod.EZ_STATE_OFF)
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
					JMod.Sploom(self.Owner,SelfPos,3)
					self:Remove()
					return
				end
				JMod.Sploom(self.Owner,SelfPos,math.random(50,80))
				util.ScreenShake(SelfPos,99999,99999,.3,500)
				local Dir=(self:GetUp()+VectorRand()*.01):GetNormalized()
				JMod.RicPenBullet(self,SelfPos,Dir,(dmg or 500)*JMod.Config.MinePower,true,true)
				self:Remove()
			end
		end)
	end
	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end
		local Time=CurTime()
		local state = self:GetState()
		if(state==JMod.EZ_STATE_ARMED)then
			local pos=self:GetAttachment(1).Pos
			local trace=util.QuickTrace(pos,self:GetUp()*1000,self)
			if((math.abs(self.BeamFrac-trace.Fraction)>=.001)and(JMod.EnemiesNearPoint(self,trace.HitPos,200)))then
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
	language.Add("ent_jack_gmod_blusub","BLU 108/B Submunition")
end