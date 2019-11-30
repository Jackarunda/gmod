-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ SLAM"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(90,0,180)
ENT.JModEZstorable=true
---
local STATE_BROKEN,STATE_OFF,STATE_ARMING,STATE_ARMED=-1,0,1,2
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
		ent.Owner=ply
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/weapons/w_jlam.mdl")
		self:SetColor(Color(217,208,157))
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
		self:SetState(STATE_OFF)
		self.NextStick=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(State==STATE_ARMED)then DetChance=DetChance+.3 end
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
		JMod_Hint(activator,"arm")
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(IN_WALK)
			if(State==STATE_OFF)then
				if(Alt)then
					self:SetState(STATE_ARMING)
					self:SetBodygroup(0,1)
					self:EmitSound("snd_jack_minearm.wav",60,100)
					timer.Simple(3,function()
						if(IsValid(self))then
							if(self:GetState()==STATE_ARMING)then
								local pos = self:GetAttachment(1).Pos
								local trace = util.QuickTrace(pos, self:GetUp() * 1000, self)
								self.BeamFrac = trace.Fraction
								self:SetState(STATE_ARMED)
							end
						end
					end)
				else
					if !IsValid(self.AttachedBomb) then
						constraint.RemoveAll(self)
						self.StuckStick=nil
						self.StuckTo=nil
						Dude:PickupObject(self)
						self.NextStick=Time+.5
					else
						self.AttachedBomb = nil
						timer.Simple(0, function() self:SetParent(nil) end)
						Dude:PickupObject(self)
						self.NextStick=Time+.5
					end
				end
			else
				self:EmitSound("snd_jack_minearm.wav",60,70)
				self:SetState(STATE_OFF)
				self:SetBodygroup(0,0)
			end
		else -- player just released the USE key
			JMod_Hint(Dude,"detpack stick")
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
							local Weld=constraint.Weld(self,Tr.Entity,0,Tr.PhysicsBone,10000,false,false)
							self.StuckTo=Tr.Entity
							self.StuckStick=Weld
						end
						
						self:EmitSound("snd_jack_claythunk.wav",65,math.random(80,120))
						Dude:DropObject()
					end
				end
			end
		end
	end
	function ENT:Detonate()
		if(self.SympatheticDetonated)then return end
		if(self.Exploded)then return end
		self.Exploded=true
		
		local SelfPos = self:GetPos()
		
		if(IsValid(self.AttachedBomb))then
			self.AttachedBomb:EZdetonateOverride(self)
			JMod_Sploom(self.Owner,SelfPos,3)
			self:Remove()
			return
		end
		JMod_Sploom(self.Owner,SelfPos,math.random(50,80))
			
		
		for i = 1, 40 do
			timer.Simple(i/400, function()
				self:FireBullets({
					Attacker = self.Owner,
					Inflictor = self,
					Damage = math.random(150, 200),
					Force = math.random(500, 1000),
					Distance = 1200,
					HullSize = 10,
					Src = SelfPos,
					Dir = self:GetUp(),
					Spread = Vector(0.1, 0.1, 0),
					IgnoreEntity = self,
					Callback = function(attacker, tr, dmginfo)
						
					end
				})
				if i == 40 then self:Remove() end
			end)
		end
		
		
	end
	function ENT:Think()
		local Time=CurTime()
		local state = self:GetState()
		if(state==STATE_ARMED)then
			local pos = self:GetAttachment(1).Pos
			local trace = util.QuickTrace(pos, self:GetUp() * 1000, self)
			if math.abs(self.BeamFrac - trace.Fraction) >= 0.001 then
				self:Detonate()
			end
			self:NextThink(Time+.1)
			return true
		end
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then


	JMod_SLAMBeam = JMod_SLAMBeam or CreateMaterial("xeno/beamgauss", "UnlitGeneric",{
		[ "$basetexture" ]    = "sprites/spotlight",
		[ "$additive" ]        = "1",
		[ "$vertexcolor" ]    = "1",
		[ "$vertexalpha" ]    = "1",
	})


	function ENT:Initialize()
		--
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local pos = self:GetAttachment(1).Pos
		local trace = util.QuickTrace(pos, self:GetUp() * 1000, self)
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==STATE_ARMING)then
			render.SetMaterial(JMod_SLAMBeam)
			render.DrawBeam(pos, trace.HitPos, 0.2, 0, 255, Color(0,0,255,50))
			render.SetMaterial(GlowSprite)
			if trace.Hit then
				render.DrawSprite(trace.HitPos,10,10,Color(0,0,255,100))
				render.DrawSprite(trace.HitPos,5,5,Color(255,255,255,100))
				render.DrawQuadEasy(trace.HitPos,trace.HitNormal,10,10,Color(0,0,255,100),0)
				render.DrawQuadEasy(trace.HitPos,trace.HitNormal,5,5,Color(255,255,255,100),0)
			end
			--render.DrawSprite(pos,10,10,Color(0,0,255))
			--render.DrawSprite(pos,5,5,Color(255,255,255))
		elseif State == STATE_ARMED then
			render.SetMaterial(JMod_SLAMBeam)
			render.DrawBeam(pos, trace.HitPos, 0.2, 0, 255, Color(255,0,0, 50))
			if trace.Hit then
				render.SetMaterial(GlowSprite)
				render.DrawSprite(trace.HitPos,10,10,Color(255,0,0,100))
				render.DrawSprite(trace.HitPos,5,5,Color(255,255,255,100))
				render.DrawQuadEasy(trace.HitPos,trace.HitNormal,10,10,Color(255,0,0,100),0)
				render.DrawQuadEasy(trace.HitPos,trace.HitNormal,5,5,Color(255,255,255,100),0)
			end
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos,30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(pos,15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezdetpack","EZ Detpack")
end