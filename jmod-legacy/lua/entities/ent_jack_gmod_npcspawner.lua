AddCSLuaFile()
ENT.Type 			= "anim"
ENT.PrintName		= "Zombie Spawner"
ENT.Author			= "Jackarunda"
ENT.Category			= "JMod - LEGACY NPCs"
ENT.Information		=""

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
if(SERVER)then
	local SkinTable={
		"bla_bla_bla","bla_bla_blu","bla_bla_whi","bla_blu_bla","bla_blu_blu","bla_blu_whi",
		"bla_pla_bla","bla_pla_blu","bla_pla_whi","bla_whi_bla","bla_whi_blu","bla_whi_whi",
		"blo_bla_bla","blo_bla_blu","blo_bla_whi","blo_blu_bla","blo_blu_blu","blo_blu_whi",
		"blo_pla_bla","blo_pla_blu","blo_pla_whi","blo_whi_bla","blo_whi_blu","blo_whi_whi",
		"bro_bla_bla","bro_bla_blu","bro_bla_whi","bro_blu_bla","bro_blu_blu","bro_blu_whi",
		"bro_pla_bla","bro_pla_blu","bro_pla_whi","bro_whi_bla","bro_whi_blu","bro_whi_whi",
		"red_bla_bla","red_bla_blu","red_bla_whi","red_blu_bla","red_blu_blu","red_blu_whi",
		"red_pla_bla","red_pla_blu","red_pla_whi","red_whi_bla","red_whi_blu","red_whi_whi.vmt"
	}
	local GoodieTable={
		"item_ammo_ar2","item_ammo_ar2_altfire","item_box_buckshot","item_ammo_crossbow","item_ammo_pistol",
		"item_ammo_smg1","item_rpg_round","weapon_frag","item_ammo_smg1_grenade","item_ammo_357",
		"weapon_slam","weapon_crowbar","weapon_pistol","weapon_shotgun","weapon_smg1","weapon_ar2","weapon_357",
		"weapon_crossbow","weapon_rpg","item_healthkit","item_healthvial","item_battery"
	}
	local SquadName="JackyClassicZombieOpSquad"
	local function RayClear(posOne,posTwo,ent)
		local TrDat={
			start=posOne,
			endpos=posTwo,
			filter={ent}
		}
		local Tr=util.TraceLine(TrDat)
		return !Tr.Hit
	end
	local function GetRandomZombieEnemy(npc)
		local Targs={}
		if not(GetConVar("ai_ignoreplayers"))then
			Targs=player.GetAll()
		end
		for key,dude in pairs(ents.FindByClass("npc_*"))do
			local Disp=npc:Disposition(dude)
			if((Disp==D_HT)or(Disp==D_FR))then
				table.insert(Targs,dude)
			end
		end
		return Targs[math.random(1,#Targs)]
	end
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*16
		local ent=ents.Create("ent_jack_gmod_npcspawner")
		ent:SetPos(SpawnPos)
		ent:SetNetworkedEntity("Owenur",ply)
		ent:Spawn()
		ent:Activate()
		local effectdata=EffectData()
		effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_phx/construct/metal_angle360.mdl")
		self.Entity:SetColor(Color(100,100,100,255))
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		local phys=self.Entity:GetPhysicsObject()
		if(phys:IsValid())then
			phys:Wake()
			phys:SetMass(1000)
			phys:SetDamping(0,3)
		end
		self.Stage="Off"
		self.SpawnDelay=3
		self.MaxNPCs=25
		self.SpawnRadius=500
		self.NextSpawnTime=CurTime()
		self:SetDTBool(0,self.Stage=="On")
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(true)
		self.NextUseTime=CurTime()
	end
	function ENT:PhysicsCollide(data, physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>300)then
				self.Entity:EmitSound("SolidMetal.ImpactHard")
			elseif(data.Speed>100)then
				self.Entity:EmitSound("SolidMetal.ImpactSoft")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
	end
	function ENT:Use(activator,caller)
		if(self.NextUseTime>CurTime())then return end
		self.NextUseTime=CurTime()+1
		local Ang=self:GetAngles()
		if not((Ang.r<20)and(Ang.r>-20))then
			return
		end
		if(self.Stage=="Off")then
			self.Stage="On"
			self:SetDTBool(0,self.Stage=="On")
			self:EmitSound("snd_jack_spawnerstart.wav")
			self.NextSpawnTime=CurTime()+5
		else
			self.Stage="Off"
			self:SetDTBool(0,self.Stage=="On")
			self:EmitSound("snd_jack_spawnershutdown.wav")
		end
	end
	function ENT:Think()
		local Time=CurTime()
		local Ang=self:GetAngles()
		if((self.Stage=="On")and not((Ang.r<20)and(Ang.r>-20)))then
			self.Stage="Off"
			self:SetDTBool(0,self.Stage=="On")
			self:EmitSound("snd_jack_spawnershutdown.wav")
		end
		if((self.Stage=="On")and(self.NextSpawnTime<Time))then
			local Num=0
			for key,found in pairs(ents.FindByClass("npc_zombie"))do
				if(found:GetOwner()==self)then
					if(math.random(1,7)==5)then
						if not(IsValid(found:GetEnemy()))then
							if(IsValid(found.JackyWanderTarget))then
								found:SetLastPosition(found.JackyWanderTarget:GetPos()+VectorRand()*math.Rand(0,1000))
								found:SetSchedule(SCHED_FORCED_GO)
							else
								found.JackyWanderTarget=GetRandomZombieEnemy(found)
							end
						end
					end
					Num=Num+1
				end
			end
			if(Num>=self.MaxNPCs)then return end
			local SelfPos=self:LocalToWorld(self:OBBCenter())
			--[[local PotentialPos=SelfPos+VectorRand()*math.Rand(50,self.SpawnRadius)
			local Spawned=false
			local FAILSAFE=0
			while not((Spawned)or(FAILSAFE>1000))do
				if(RayClear(SelfPos,PotentialPos,self))then
					local Success=self:BeginSpawning(PotentialPos)
					Spawned=true
				else
					PotentialPos=SelfPos+VectorRand()*math.Rand(50,self.SpawnRadius)
				end
				FAILSAFE=FAILSAFE+1
			end
			if(FAILSAFE>=1000)then
				print("\n\nALERT! JackieZombieSpawner "..tostring(self:EntIndex()).." can't find anywhere to spawn after 1000 attempts!\nIs something clipping with the spawner?\n")
			end--]]
			self:BeginSpawning(SelfPos+Vector(0,0,20))
			self.NextSpawnTime=CurTime()+self.SpawnDelay
		end
		self:NextThink(CurTime()+.1)
		return true
	end
	function ENT:OnRemove()
		for key,found in pairs(ents.FindByClass("npc_*"))do
			if(found:GetOwner()==self)then
				SafeRemoveEntity(found)
			end
		end
	end
	function ENT:BeginSpawning(pos)
		local PortalOpen=EffectData()
		PortalOpen:SetOrigin(self:GetPos()+Vector(0,0,40))
		self:EmitSound("snd_jack_wormhole.wav")
		util.Effect("eff_jack_gmod_portalopen",PortalOpen,true,true)
		timer.Simple(.625,function()
			if(IsValid(self))then
				for key,blocker in pairs(ents.FindInSphere(pos+Vector(0,0,50),50))do
					local MType=blocker:GetMoveType()
					local Phys=blocker:GetPhysicsObject()
					if(blocker:IsPlayer())then
						--blocker:SetPos(Vector(0,0,50000))
						blocker:KillSilent()
					elseif((IsValid(Phys))and not(blocker:IsWorld())and not(blocker==self)and not(MType==MOVETYPE_NONE)and not(MType==MOVETYPE_ISOMETRIC)and not(MType==MOVETYPE_CUSTOM)and not(MType==MOVETYPE_OBSERVER))then
						local Vol=Phys:GetVolume()
						if(Vol)then
							if(Vol<150000)then
								SafeRemoveEntity(blocker)
							else
								self.Stage="Off"
								self:SetDTBool(0,self.Stage=="On")
								self:EmitSound("snd_jack_spawnershutdown.wav")
							end
						end
					end
				end
			end
		end)
		timer.Simple(.65,function()
			if(IsValid(self))then
				self:SpawnDatNPC(pos)
				--self:EmitSound("snd_jack_wormholesoundburst.wav",70,100)
				--self:EmitSound("snd_jack_wormholesoundburst_far.wav",90,100)
			end
		end)
		timer.Simple(.75,function()
			if(IsValid(self))then
				local PortalClose=EffectData()
				PortalClose:SetOrigin(self:GetPos()+Vector(0,0,40))
				util.Effect("eff_jack_gmod_portalclose",PortalClose,true,true)
			end
		end)
	end
	function ENT:SpawnDatNPC(pos)
		local Skin=true
		local Thing="npc_zombie"
		if(math.random(1,6)==2)then
			Thing="npc_zombie_torso"
		end
		if(math.random(1,6)==5)then
			Thing="npc_fastzombie_torso"
			Skin=false
		end
		if(math.random(1,50)==49)then
			Thing="npc_zombine"
			Skin=false
		end
		if(math.random(1,30)==20)then
			Thing="npc_fastzombie"
			Skin=false
		end
		local npc=ents.Create(Thing)
		npc:SetPos(pos)
		npc:SetAngles(Angle(0,math.Rand(0,360),0))
		npc:Spawn()
		npc:Activate()
		npc.JackyFirePowerMult=math.Rand(.5,2)
		local Health=math.random(20,90)
		npc:SetMaxHealth(Health)
		npc:SetHealth(Health)
		local Col=math.random(190,255)
		npc:SetColor(Color(Col,Col,Col))
		if(math.random(1,13)==4)then
			npc.JackyOpSquadDrop={GoodieTable[math.random(1,#GoodieTable)]}
			if(math.random(1,8)==7)then
				table.insert(npc.JackyOpSquadDrop,GoodieTable[math.random(1,#GoodieTable)])
			end
		end
		if(math.random(1,2)==1)then
			npc:SetModelScale(math.Rand(.8,1.2),.1)
		end
		npc:SetBloodColor(BLOOD_COLOR_RED)
		if(Skin)then
			npc:SetMaterial("models/mats_jack_zombies/"..SkinTable[math.random(1,#SkinTable)])
		elseif(Thing=="npc_zombine")then
			npc.JackyOpSquadDrop={"weapon_frag","weapon_frag","weapon_frag","weapon_frag","weapon_frag","weapon_frag"}
		end
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc.OpSquadNoHeadcrab=true
		umsg.Start("JackySetClientBoolean")
			umsg.Entity(npc)
			umsg.String("OpSquadNoHeadcrab")
			umsg.Bool(true)
		umsg.End()
		npc:SetOwner(self)
		npc.JackyFaction="ClassicZombies"
		npc:AddRelationship("npc_headcrab D_HT 72")
		npc:AddRelationship("npc_headcrab_fast D_HT 72")
		npc:AddRelationship("npc_headcrab_black D_HT 72")
		npc:AddRelationship("npc_headcrab_poison D_HT 72")
		JackyOpSquadSpawnEvent(npc)
		npc:SetBodygroup(1,0)
		if(math.random(1,75)==42)then
			npc:SetMaterial("models/flesh")
			npc.OpSquadUltraMegaSuperPowerDeathZombie=true
			npc:SetMaxHealth(400)
			npc:SetHealth(400)
			npc:SetModelScale(1.75,.1)
			for i=0,50 do
				local Name=string.lower(npc:GetBoneName(i))
				if not(npc:GetBoneName(i)=="__INVALIDBONE__")then
					if((string.find(Name,"arm"))or(string.find(Name,"hand")))then
						npc:ManipulateBoneScale(i,Vector(1.5,2.5,2.5))
					end
				end
			end
		end
		if(npc:GetPhysicsObject():IsPenetrating())then
			print("Spawned zombie "..npc:EntIndex().." got stuck in something. Removed.")
			npc:Remove()
			return
		end
		timer.Simple(.2,function()
			if(IsValid(npc))then
				if not(IsValid(npc:GetEnemy()))then
					npc:SetLastPosition(pos+Vector(math.Rand(-750,750),math.Rand(-750,750),10))
					npc:SetSchedule(SCHED_FORCED_GO_RUN)
				end
			end
		end)
	end
	JackieNPCSpawningTable.Enhanced["Classic Zombie"]=function(selfpos)
		local Skin=true
		local Thing="npc_zombie"
		if(math.random(1,6)==2)then
			Thing="npc_zombie_torso"
		end
		if(math.random(1,6)==5)then
			Thing="npc_fastzombie_torso"
			Skin=false
		end
		if(math.random(1,50)==49)then
			Thing="npc_zombine"
			Skin=false
		end
		if(math.random(1,30)==20)then
			Thing="npc_fastzombie"
			Skin=false
		end
		local npc=ents.Create(Thing)
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,math.Rand(0,360),0))
		npc:Spawn()
		npc:Activate()
		npc.JackyFaction="ClassicZombies"
		npc:AddRelationship("npc_headcrab D_HT 72")
		npc:AddRelationship("npc_headcrab_fast D_HT 72")
		npc:AddRelationship("npc_headcrab_black D_HT 72")
		npc:AddRelationship("npc_headcrab_poison D_HT 72")
		npc.JackyFirePowerMult=math.Rand(.5,2)
		local Health=math.random(20,90)
		npc:SetMaxHealth(Health)
		npc:SetHealth(Health)
		local Col=math.random(190,255)
		npc:SetColor(Color(Col,Col,Col))
		if(math.random(1,13)==4)then
			npc.JackyOpSquadDrop={GoodieTable[math.random(1,#GoodieTable)]}
			if(math.random(1,8)==7)then
				table.insert(npc.JackyOpSquadDrop,GoodieTable[math.random(1,#GoodieTable)])
			end
		end
		if(math.random(1,2)==1)then
			npc:SetModelScale(math.Rand(.8,1.2),.1)
		end
		npc:SetBloodColor(BLOOD_COLOR_RED)
		if(Skin)then
			npc:SetMaterial("models/mats_jack_zombies/"..SkinTable[math.random(1,#SkinTable)])
		elseif(Thing=="npc_zombine")then
			npc.JackyOpSquadDrop={"weapon_frag","weapon_frag","weapon_frag","weapon_frag","weapon_frag","weapon_frag"}
		end
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc.OpSquadNoHeadcrab=true
		umsg.Start("JackySetClientBoolean")
			umsg.Entity(npc)
			umsg.String("OpSquadNoHeadcrab")
			umsg.Bool(true)
		umsg.End()
		JackyOpSquadSpawnEvent(npc)
		npc:SetBodygroup(1,0)
		return npc
	end
	JackieNPCSpawningTable.Modified["DeathZombie"]=function(selfpos)
		local Skin=true
		local Thing="npc_zombie"
		if(math.random(1,6)==2)then
			Thing="npc_zombie_torso"
		end
		if(math.random(1,6)==5)then
			Thing="npc_fastzombie_torso"
			Skin=false
		end
		if(math.random(1,50)==49)then
			Thing="npc_zombine"
			Skin=false
		end
		if(math.random(1,30)==20)then
			Thing="npc_fastzombie"
			Skin=false
		end
		local npc=ents.Create(Thing)
		npc:SetPos(selfpos)
		npc:SetAngles(Angle(0,math.Rand(0,360),0))
		npc:Spawn()
		npc:Activate()
		npc.JackyFaction="ClassicZombies"
		npc:AddRelationship("npc_headcrab D_HT 72")
		npc:AddRelationship("npc_headcrab_fast D_HT 72")
		npc:AddRelationship("npc_headcrab_black D_HT 72")
		npc:AddRelationship("npc_headcrab_poison D_HT 72")
		npc.JackyFirePowerMult=math.Rand(.5,2)
		local Health=math.random(20,90)
		npc:SetMaxHealth(Health)
		npc:SetHealth(Health)
		local Col=math.random(190,255)
		npc:SetColor(Color(Col,Col,Col))
		if(math.random(1,13)==4)then
			npc.JackyOpSquadDrop={GoodieTable[math.random(1,#GoodieTable)]}
			if(math.random(1,8)==7)then
				table.insert(npc.JackyOpSquadDrop,GoodieTable[math.random(1,#GoodieTable)])
			end
		end
		if(math.random(1,2)==1)then
			npc:SetModelScale(math.Rand(.8,1.2),.1)
		end
		npc:SetBloodColor(BLOOD_COLOR_RED)
		if(Skin)then
			npc:SetMaterial("models/mats_jack_zombies/"..SkinTable[math.random(1,#SkinTable)])
		elseif(Thing=="npc_zombine")then
			npc.JackyOpSquadDrop={"weapon_frag","weapon_frag","weapon_frag","weapon_frag","weapon_frag","weapon_frag"}
		end
		npc:SetKeyValue("SquadName",SquadName)
		npc.JackyDamageGroup=SquadName
		npc.OpSquadNoHeadcrab=true
		umsg.Start("JackySetClientBoolean")
			umsg.Entity(npc)
			umsg.String("OpSquadNoHeadcrab")
			umsg.Bool(true)
		umsg.End()
		npc:SetOwner(self)
		JackyOpSquadSpawnEvent(npc)
		npc:SetBodygroup(1,0)
		if(true)then -- you are going to die
			npc:SetMaterial("models/flesh")
			npc.OpSquadUltraMegaSuperPowerDeathZombie=true
			npc:SetMaxHealth(400)
			npc:SetHealth(400)
			npc:SetModelScale(1.75,.1)
			for i=0,50 do
				local Name=string.lower(npc:GetBoneName(i))
				if not(npc:GetBoneName(i)=="__INVALIDBONE__")then
					if((string.find(Name,"arm"))or(string.find(Name,"hand")))then
						npc:ManipulateBoneScale(i,Vector(1.5,2.5,2.5))
					end
				end
			end
		end
		return npc
	end
elseif(CLIENT)then
	language.Add("ent_jack_zombiespawner","Zombie Spawner")
	local ApertureOff=surface.GetTextureID("models/mat_jack_spawner_off")
	local ApertureOn=surface.GetTextureID("models/mat_jack_spawner_on")
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self.Entity:DrawModel()
		local Pos=self:GetPos()+self:GetUp()*3.5-self:GetForward()*45-self:GetRight()*45
		local Col=render.GetLightColor(Pos)
		Col=Color(math.Clamp(Col.r*255*1.8,0,255),math.Clamp(Col.g*255*1.8,0,255),math.Clamp(Col.b*255*1.8,0,255)) -- wow gary, just wow.
		local Pic=ApertureOff
		if(self:GetDTBool(0))then
			Col=Color(255,255,255)
			Pic=ApertureOn
		end
		cam.Start3D2D(Pos,self:GetAngles(),1)
			draw.TexturedQuad({
				texture=Pic,
				color=Col,
				x=0,
				y=0,
				w=90,
				h=90
			})
		cam.End3D2D()
	end
	function ENT:OnRemove()
		--
	end
end