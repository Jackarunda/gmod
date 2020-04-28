-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Detpack"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
--- func_breakable
ENT.JModPreferredCarryAngles=Angle(90,0,180)
ENT.JModEZdetPack=true
ENT.JModEZstorable=true
ENT.JModRemoteTrigger=true
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED=-1,0,1
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
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_misc/tobacco_box-1.mdl")
		self.Entity:SetMaterial("models/entities/mat_jack_c4")
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
		self.NextStick=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("snd_jack_claythunk.wav",55,math.random(80,120))
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
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
		JMod_Owner(self,Dude)
		
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMOD_CONFIG.AltFunctionKey)
			if(State==STATE_OFF)then
				if(Alt)then
					self:SetState(STATE_ARMED)
					self:EmitSound("snd_jack_minearm.wav",60,100)
                    JMod_Hint(Dude, "trigger", self)
				else
					constraint.RemoveAll(self)
					self.StuckStick=nil
					self.StuckTo=nil
					Dude:PickupObject(self)
					self.NextStick=Time+.5
                    JMod_Hint(Dude, "sticky", self)
				end
			else
				self:EmitSound("snd_jack_minearm.wav",60,70)
				self:SetState(STATE_OFF)
			end
		else
			
			if((self:IsPlayerHolding())and(self.NextStick<Time))then
				local Tr=util.QuickTrace(Dude:GetShootPos(),Dude:GetAimVector()*80,{self,Dude})
				if(Tr.Hit)then
					if((IsValid(Tr.Entity:GetPhysicsObject()))and not(Tr.Entity:IsNPC())and not(Tr.Entity:IsPlayer()))then
						self.NextStick=Time+.5
						local Ang=Tr.HitNormal:Angle()
						Ang:RotateAroundAxis(Ang:Right(),90)
						self:SetAngles(Ang)
						self:SetPos(Tr.HitPos+Tr.HitNormal*2.35)
						if(Tr.Entity:GetClass()=="func_breakable")then -- crash prevention
							timer.Simple(0,function() self:GetPhysicsObject():Sleep() end)
						else
							local Weld=constraint.Weld(self,Tr.Entity,0,Tr.PhysicsBone,10000,false,false)
							self.StuckTo=Tr.Entity
							self.StuckStick=Weld
						end
						self.Entity:EmitSound("snd_jack_claythunk.wav",65,math.random(80,120))
						Dude:DropObject()
                        JMod_Hint(Dude, "arm", self)
					end
				end
			end
		end
	end
	function ENT:IncludeSympatheticDetpacks(origin)
		local Powa,FilterEnts,Points=1,ents.FindByClass("ent_jack_gmod_ezdetpack"),{origin}
		for k,pack in pairs(ents.FindInSphere(origin,100))do
			if((pack~=self)and(pack.JModEZdetPack))then
				local PackPos=pack:LocalToWorld(pack:OBBCenter())
				if not(util.TraceLine({start=origin,endpos=PackPos,filter=FilterEnts}).Hit)then
					Powa=Powa+1
					table.insert(Points,PackPos)
					pack.SympatheticDetonated=true
					pack:Remove()
				end
			end
		end
		local Cumulative=Vector(0,0,0)
		for k,point in pairs(Points)do
			Cumulative=Cumulative+point
		end
		return Cumulative/Powa,Powa
	end
	function ENT:JModEZremoteTriggerFunc(ply)
		if not((IsValid(ply))and(ply:Alive())and(ply==self.Owner))then return end
		if not(self:GetState()==STATE_ARMED)then return end
        JMod_Hint(ply, "detpack combo", self:GetPos())
		self:Detonate()
	end
	function ENT:Detonate()
		if(self.SympatheticDetonated)then return end
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(math.Rand(0,.1),function()
			if(IsValid(self))then
				if(self.SympatheticDetonated)then return end
				local SelfPos,PowerMult=self:IncludeSympatheticDetpacks(self:LocalToWorld(self:OBBCenter()))
				PowerMult=(PowerMult^.75)*JMOD_CONFIG.DetpackPowerMult
				--
				local Blam=EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult)
				util.Effect("eff_jack_plastisplosion",Blam,true,true)
				JMod_Sploom(self.Owner or self or game.GetWorld(),SelfPos,20)
				util.ScreenShake(SelfPos,99999,99999,1,750*PowerMult)
				for i=1,PowerMult do sound.Play("BaseExplosionEffect.Sound",SelfPos,120,math.random(90,110)) end
				if(PowerMult>1)then
					for i=1,PowerMult do sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,140,math.random(90,110)) end
				end
				self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
				timer.Simple(.1,function()
					for i=1,5 do
						local Tr=util.QuickTrace(SelfPos,VectorRand()*20)
						if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
					end
				end)
				JMod_WreckBuildings(self,SelfPos,PowerMult)
				JMod_BlastDoors(self,SelfPos,PowerMult)
				timer.Simple(0,function()
					local ZaWarudo=game.GetWorld()
					local Infl,Att=(IsValid(self) and self) or ZaWarudo,(IsValid(self) and IsValid(self.Owner) and self.Owner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl,Att,SelfPos,300*PowerMult,200*PowerMult)
					-- do a lot of damage point blank, mostly for breaching
					util.BlastDamage(Infl,Att,SelfPos,20*PowerMult,1700*PowerMult)
					self:Remove()
				end)
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
	function ENT:Think()
		--
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
		if(State==STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),20,20,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),10,10,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezdetpack","EZ Detpack")
end