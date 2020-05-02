-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Mega Bomb"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(90,0,0)
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
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/hunter/blocks/cube075x6x075.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(500)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		self:SetState(STATE_OFF)
		self.LastUse=0
		self.DetTime=0
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
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
	function ENT:JModEZremoteTriggerFunc(ply)
		if not((IsValid(ply))and(ply:Alive())and(ply==self.Owner))then return end
		if not(self:GetState()==STATE_ARMED)then return end
		self:Detonate()
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
		--JMod_Sploom(Att,SelfPos,500)
		timer.Simple(.1,function() JMod_BlastDamageIgnoreWorld(SelfPos,Att,nil,600,600) end)
		---
		util.ScreenShake(SelfPos,1000,10,5,8000)
		local Eff="pcf_jack_moab"
		if not(util.QuickTrace(SelfPos,Vector(0,0,-300),{self}).HitWorld)then Eff="pcf_jack_moab_air" end
		for i=1,10 do
			sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,150,math.random(80,110))
		end
		---
		for k,ply in pairs(player.GetAll())do
			local Dist=ply:GetPos():Distance(SelfPos)
			if((Dist>1000)and(Dist<15000))then
				timer.Simple(Dist/6000,function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.wav",55,100)
					sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",ply:GetPos(),60,70)
					util.ScreenShake(ply:GetPos(),1000,10,5,100)
				end)
			end
		end
		---
		util.BlastDamage(game.GetWorld(),Att,SelfPos+Vector(0,0,300),3000,200)
		timer.Simple(.3,function() util.BlastDamage(game.GetWorld(),Att,SelfPos,6000,200) end)
		timer.Simple(.6,function() util.BlastDamage(game.GetWorld(),Att,SelfPos,9000,200) end)
		for k,ent in pairs(ents.FindInSphere(SelfPos,3000))do
			if(ent:GetClass()=="npc_helicopter")then ent:Fire("selfdestruct","",math.Rand(0,2)) end
		end
		---
		JMod_WreckBuildings(self,SelfPos,20)
		JMod_BlastDoors(self,SelfPos,20)
		---
		timer.Simple(.2,function()
			local Tr=util.QuickTrace(SelfPos+Vector(0,0,100),Vector(0,0,-400))
			if(Tr.Hit)then util.Decal("GiantScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		---
		self:Remove()
		timer.Simple(.1,function() ParticleEffect(Eff,SelfPos,Angle(0,0,0)) end)
	end
	function ENT:OnRemove()
		--
	end
	function ENT:Think()
		JMod_AeroDrag(self,self:GetRight(),10)
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/chappi/moab.mdl")
		self.Mdl:SetModelScale(.75,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	function ENT:Draw()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		Ang:RotateAroundAxis(Ang:Right(),90)
		Ang:RotateAroundAxis(Ang:Right(),-90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos-Ang:Right()*17+Ang:Up()*6-Ang:Forward()*6)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_ezmoab","EZ Mega Bomb")
end