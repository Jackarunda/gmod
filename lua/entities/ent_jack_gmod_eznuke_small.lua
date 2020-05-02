-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Nano Nuclear Bomb"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.JModEZstorable=true
---
ENT.JModPreferredCarryAngles=Angle(0,90,0)
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
		self.Entity:SetModel("models/chappi/mininuq.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		self:SetState(STATE_OFF)
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.DeltaTime>0.2)then
			if(data.Speed>50)then
				self:EmitSound("Canister.ImpactHard")
			end
			if((data.Speed>700)and(self:GetState()==STATE_ARMED))then
				self:Detonate()
				return
			end
			if(data.Speed>1200)then
				self:Break()
			end
		end
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
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
			self:Break()
		end
	end
	function ENT:JModEZremoteTriggerFunc(ply)
		if not((IsValid(ply))and(ply:Alive())and(ply==self.Owner))then return end
		if not(self:GetState()==STATE_ARMED)then return end
		self:Detonate()
	end
	function ENT:Use(activator)
		local State,Alt=self:GetState(),activator:KeyDown(IN_WALK)
		if(State<0)then return end
		
		JMod_Owner(self,activator)
		if not(Alt)then
			activator:PickupObject(self)
            JMod_Hint(activator, "arm", self)
		else
			if(State==STATE_OFF)then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/nuke_arm.wav",70,140)
				self.EZdroppableBombArmedTime=CurTime()
                JMod_Hint(activator, "dualdet", self)
			elseif(State==STATE_ARMED)then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav",70,100)
				self.EZdroppableBombArmedTime=nil
			end
		end
	end
	local function SendClientNukeEffect(pos,range)
		net.Start("JMod_NuclearBlast")
		net.WriteVector(pos)
		net.WriteFloat(range)
		net.WriteFloat(1)
		net.Broadcast()
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
		local ThermalRadiation=DamageInfo()
		ThermalRadiation:SetDamageType(DMG_BURN)
		ThermalRadiation:SetDamage(100)
		ThermalRadiation:SetAttacker(Att)
		ThermalRadiation:SetInflictor(game.GetWorld())
		util.BlastDamageInfo(ThermalRadiation,SelfPos,12000)
		---
		for k,ply in pairs(player.GetAll())do
			local Dist=ply:GetPos():Distance(SelfPos)
			if((Dist>1000)and(Dist<15000))then
				timer.Simple(Dist/6000,function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.wav",55,90)
					sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",ply:GetPos(),60,70)
					util.ScreenShake(ply:GetPos(),1000,10,5,100)
				end)
			end
		end
		---
		timer.Simple(.5,function() util.BlastDamage(game.GetWorld(),Att,SelfPos,5000,500) end)
		---
		for k,ent in pairs(ents.FindInSphere(SelfPos,2000))do
			if(ent:GetClass()=="npc_helicopter")then ent:Fire("selfdestruct","",math.Rand(0,2)) end
		end
		---
		JMod_WreckBuildings(self,SelfPos,15)
		JMod_BlastDoors(self,SelfPos,15)
		---
		timer.Simple(.2,function()
			local Tr=util.QuickTrace(SelfPos+Vector(0,0,100),Vector(0,0,-400))
			if(Tr.Hit)then util.Decal("GiantScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		---
		self:Remove()
		timer.Simple(.1,function()
			ParticleEffect(Eff,SelfPos,Angle(0,0,0))
			local Eff=EffectData()
			Eff:SetOrigin(SelfPos)
			util.Effect("eff_jack_gmod_tinynukeflash",Eff,true,true)
		end)
		---
		timer.Simple(5,function()
			for j=1,10 do
				timer.Simple(j/10,function()
					for k=1,10*JMOD_CONFIG.NuclearRadiationMult do
						local Gas=ents.Create("ent_jack_gmod_ezfalloutparticle")
						Gas:SetPos(SelfPos)
						JMod_Owner(Gas,Att)
						Gas:Spawn()
						Gas:Activate()
						Gas:GetPhysicsObject():SetVelocity(VectorRand()*math.random(1,250)+Vector(0,0,500*JMOD_CONFIG.NuclearRadiationMult))
					end
				end)
			end
		end)
	end
	function ENT:OnRemove()
		--
	end
	function ENT:Think()
		JMod_AeroDrag(self,self:GetRight(),.5)
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--[[
		self.Mdl=ClientsideModel("models/thedoctor/fatman.mdl")
		self.Mdl:SetModelScale(.4,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		--]]
	end
	function ENT:Draw()
		--local Pos,Ang=self:GetPos(),self:GetAngles()
		--Ang:RotateAroundAxis(Ang:Forward(),-90)
		self:DrawModel()
		--self.Mdl:SetRenderOrigin(Pos+Ang:Right()*7)
		--self.Mdl:SetRenderAngles(Ang)
		--self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_eznuke_small","EZ Nano Nuclear Bomb")
end