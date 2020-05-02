-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Big Bomb"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(90,0,0)
ENT.EZguidable=true
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Bool",0,"Guided")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(180,0,0))
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
		self.Entity:SetModel("models/hunter/blocks/cube05x4x05.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(300)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		self:SetState(STATE_OFF)
		self.LastUse=0
		self.DetTime=0
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.DeltaTime>0.2)then
			if(data.Speed>50)then
				self:EmitSound("Canister.ImpactHard")
			end
			if((data.Speed>1000)and(self:GetState()==STATE_ARMED))then
				self:Detonate()
				return
			end
			if(data.Speed>2000)then
				self:Break()
			end
		end
	end
	function ENT:Break()
		if(self:GetState()==STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do
			self:DamageSpark()
		end
		SafeRemoveEntityDelayed(self,10)
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*10+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=100)then
			if(math.random(1,20)==1)then
				self:Break()
			elseif(dmginfo:IsDamageType(DMG_BLAST))then
				JMod_Owner(self,dmginfo:GetAttacker())
				self:Detonate()
			end
		end
	end
	function ENT:Use(activator)
		local State,Time=self:GetState(),CurTime()
		if(State<0)then return end
		
		if(State==STATE_OFF)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav",70,100)
				self.EZdroppableBombArmedTime=CurTime()
                JMod_Hint(activator, "impactdet", self)
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to arm")
			end
			self.LastUse=Time
		elseif(State==STATE_ARMED)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav",70,100)
				self.EZdroppableBombArmedTime=nil
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to disarm")
			end
			self.LastUse=Time
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Att=self:GetPos()+Vector(0,0,100),self.Owner or game.GetWorld()
		---
		util.ScreenShake(SelfPos,1000,3,2,8000)
		local Eff="cloudmaker_ground"
		if not(util.QuickTrace(SelfPos,Vector(0,0,-300),{self}).HitWorld)then Eff="cloudmaker_air" end
		for i=1,10 do
			sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,160,math.random(80,110))
		end
		---
		for k,ply in pairs(player.GetAll())do
			local Dist=ply:GetPos():Distance(SelfPos)
			if((Dist>500)and(Dist<8000))then
				timer.Simple(Dist/6000,function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.wav",55,110)
					sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",ply:GetPos(),60,70)
					util.ScreenShake(ply:GetPos(),1000,3,2,100)
				end)
			end
		end
		---
		util.BlastDamage(game.GetWorld(),Att,SelfPos+Vector(0,0,300),2250,150)
		timer.Simple(.25,function() util.BlastDamage(game.GetWorld(),Att,SelfPos,4500,150) end)
		for k,ent in pairs(ents.FindInSphere(SelfPos,1000))do
			if(ent:GetClass()=="npc_helicopter")then ent:Fire("selfdestruct","",math.Rand(0,2)) end
		end
		---
		JMod_WreckBuildings(self,SelfPos,10)
		JMod_BlastDoors(self,SelfPos,10)
		---
		timer.Simple(.2,function()
			local Tr=util.QuickTrace(SelfPos+Vector(0,0,100),Vector(0,0,-400))
			if(Tr.Hit)then util.Decal("GiantScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		---
		JMod_FragSplosion(self,SelfPos,20000,400,8000,self.Owner or game.GetWorld())
		---
		self:Remove()
		timer.Simple(.1,function() ParticleEffect(Eff,SelfPos,Angle(0,0,0)) end)
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
		local Phys,UseAeroDrag=self:GetPhysicsObject(),true
		--if((self:GetState()==STATE_ARMED)and(self:GetGuided())and not(constraint.HasConstraints(self)))then
			--for k,designator in pairs(ents.FindByClass("wep_jack_gmod_ezdesignator"))do
				--if((designator:GetLasing())and(designator.Owner)and(JMod_ShouldAllowControl(self,designator.Owner)))then
					--[[
					local TargPos,SelfPos=ents.FindByClass("npc_*")[1]:GetPos(),self:GetPos()--designator.Owner:GetEyeTrace().HitPos
					local TargVec=TargPos-SelfPos
					local Dist,Dir,Vel=TargVec:Length(),TargVec:GetNormalized(),Phys:GetVelocity()
					local Speed=Vel:Length()
					if(Speed<=0)then return end
					local ETA=Dist/Speed
					jprint(ETA)
					TargPos=TargPos--Vel*ETA/2
					JMod_Sploom(self,TargPos,1)
					JMod_AeroGuide(self,-self:GetRight(),TargPos,1,1,.2,10)
					--]]
				--end
			--end
		--end
		JMod_AeroDrag(self,-self:GetRight(),4)
		self:NextThink(CurTime()+.1)
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/jmod/mk82_gbu.mdl")
		self.Mdl:SetModelScale(1.5,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.Guided=false
	end
	function ENT:Think()
		if((not(self.Guided))and(self:GetGuided()))then
			self.Guided=true
			self.Mdl:SetBodygroup(0,1)
		end
	end
	function ENT:Draw()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(),90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos-Ang:Up()*15)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_ezbigbomb","EZ Big Bomb")
end