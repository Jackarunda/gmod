-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Thermonuclear Bomb"
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
		local SpawnPos=tr.HitPos+tr.HitNormal*280
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
		self.Entity:SetModel("models/hunter/blocks/cube1x4x1.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(250)
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
			if(data.Speed>1500)then
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
		for k=1,10*JMOD_CONFIG.NuclearRadiationMult do
			local Gas=ents.Create("ent_jack_gmod_ezfalloutparticle")
			Gas:SetPos(self:GetPos())
			JMod_Owner(Gas,self.Owner or game.GetWorld())
			Gas:Spawn()
			Gas:Activate()
			Gas:GetPhysicsObject():SetVelocity(VectorRand()*math.random(1,50)+Vector(0,0,10*JMOD_CONFIG.NuclearRadiationMult))
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
			if(math.random(1,5)==1)then
				self:Break()
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
		JMod_Hint(activator,"nuke det","detpack det","bomb drop")
		if(State==STATE_OFF)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/nuke_arm.wav",70,100)
				self.EZdroppableBombArmedTime=CurTime()
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to arm")
			end
			self.LastUse=Time
		elseif(State==STATE_ARMED)then
			JMod_Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/nuke_disarm.wav",70,100)
				self.EZdroppableBombArmedTime=nil
			else
				activator:PrintMessage(HUD_PRINTCENTER,"double tap E to disarm")
			end
			self.LastUse=Time
		end
	end
	local function SendClientNukeEffect(pos,range)
		net.Start("JMod_NuclearBlast")
		net.WriteVector(pos)
		net.WriteFloat(range)
		net.WriteFloat(1.5)
		net.Broadcast()
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Att,Power=self:GetPos()+Vector(0,0,100),self.Owner or game.GetWorld()
		---
		SendClientNukeEffect(SelfPos,9e9)
		util.ScreenShake(SelfPos,1000,15,15,50000)
		---
		for i=0,100 do
			timer.Simple(i/10,function()
				for k,playa in pairs(player.GetAll())do
					playa:EmitSound("ambient/explosions/explode_"..math.random(1,9)..".wav",60,80-i/2)
				end
			end)
		end
		for i=1,10 do
			timer.Simple(i,function()
				if(i>8)then JMod_DecalSplosion(SelfPos+Vector(0,0,i*100),"GiantScorch",20000,5) end
				SendClientNukeEffect(SelfPos,9e9)
			end)
		end
		for i=7,17 do
			timer.Simple(i,function()
				local Pof=EffectData()
				Pof:SetOrigin(SelfPos)
				util.Effect("eff_jack_gmod_ezthermonuke",Pof,true,true)
			end)
		end
		---
		for i=0,5 do
			if(i==1)then game.CleanUpMap() end
			timer.Simple(i,function()
				for k,ply in pairs(player.GetAll())do
					local Dmg=DamageInfo()
					Dmg:SetDamagePosition(SelfPos)
					Dmg:SetDamageType(DMG_BLAST)
					Dmg:SetDamage(2000)
					Dmg:SetAttacker(Att)
					Dmg:SetInflictor(((IsValid(self))and self) or game.GetWorld())
					Dmg:SetDamageForce((ply:GetPos()-SelfPos):GetNormalized()*9e9)
					ply:TakeDamageInfo(Dmg)
				end
			end)
		end
		---
		if(IsValid(self))then self:Remove() end
	end
	function ENT:OnRemove()
		--
	end
	function ENT:Think()
		JMod_AeroDrag(self,self:GetRight(),8)
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/thedoctor/tsar.mdl")
		self.Mdl:SetModelScale(.6,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	function ENT:Draw()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos-Ang:Right()*80-Ang:Up()*13)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_eznuke_big","EZ Thermonuclear Bomb")
end