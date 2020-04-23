AddCSLuaFile()
if(SERVER)then
	SWEP.Weight= 5
	SWEP.AutoSwitchTo=false
	SWEP.AutoSwitchFrom=false
	function SWEP:SetupWeaponHoldTypeForAI(t)
		self.ActivityTranslateAI={}
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_RIFLE
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_SMG1_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_SMG1_STIMULATED
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_SMG1_STIMULATED
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_SMG1
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_AR2
		self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SMG1
		self.ActivityTranslateAI [ ACT_WALK_AIM ] 					= ACT_WALK_AIM_RIFLE
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN_AIM_RIFLE
		self.ActivityTranslateAI [ ACT_GESTURE_RANGE_ATTACK1 ] 		= ACT_GESTURE_RANGE_ATTACK_AR2
		self.ActivityTranslateAI [ ACT_RELOAD_LOW ] 				= ACT_RELOAD_SMG1_LOW
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK_AR2_LOW
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_COVER_LOW
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ] 				= ACT_RANGE_AIM_LOW
		self.ActivityTranslateAI [ ACT_GESTURE_RELOAD ] 			= ACT_GESTURE_RELOAD_SMG1
		self.ActivityTranslateAI [ ACT_RUN ]						= ACT_RUN_RIFLE
		self.ActivityTranslateAI [ ACT_RUN_RELAXED ]				= ACT_RUN_RIFLE_RELAXED
		self.ActivityTranslateAI [ ACT_RUN_AGITATED ]			  =ACT_RUN_RIFLE_STIMULATED
		self.ActivityTranslateAI [ ACT_RUN_STIMULATED ]			=ACT_RUN_RIFLE_STIMULATED
		self.ActivityTranslateAI [ ACT_WALK ]					  =ACT_WALK_RIFLE
		self.ActivityTranslateAI [ ACT_WALK_AGITATED ]			 =ACT_WALK_RIFLE_STIMULATED
		self.ActivityTranslateAI [ ACT_WALK_STIMULATED ]			= ACT_WALK_RIFLE_STIMULATED
		self.ActivityTranslateAI [ ACT_WALK_RELAXED ]			  =ACT_WALK_RIFLE_RELAXED
	end
	SWEP.Weight=5
	SWEP.AutoSwitchTo=false
	SWEP.AutoSwitchFrom=false
	local NeedsHeightCorrectionTable={"npc_headcrab_black","npc_headcrab_poison","npc_pigeon","npc_crow","npc_seagull","npc_zombie","npc_zombine","player","npc_citizen","npc_hunter","npc_combine_s"}
	local HeightCorrectionTable={
		["npc_pigeon"]=-6,
		["npc_crow"]=-6,
		["npc_seagull"]=-6,
		["npc_zombie"]=10,
		["npc_zombine"]=7,
		["player"]=17,
		["npc_citizen"]=17,
		["npc_hunter"]=20,
		["npc_combine_s"]=10,
		["npc_headcrab_black"]=-5,
		["npc_headcrab_poison"]=-5
	}
	function SWEP:HeightCorrection()
		local Enemy=self.Owner:GetEnemy()
		local Class=Enemy:GetClass()
		if(table.HasValue(NeedsHeightCorrectionTable,Class))then
			return Vector(0,0,HeightCorrectionTable[Class])
		else
			return Vector(0,0,0)
		end
	end
	function SWEP:CanSee(Ent)
		local TressDet={}
		TressDet.start=self.Owner:GetShootPos()
		TressDet.endpos=Ent:LocalToWorld(Ent:OBBCenter())
		TressDet.filter={self.Owner,Ent}
		TressDet.mask=MASK_SHOT
		local Tress=util.TraceLine(TressDet)
		if(Tress.Hit)then
			return false
		else
			return true
		end
	end
	function SWEP:BadGuy()
		if(IsValid(self.Owner))then
			local Dude=self.Owner:GetEnemy()
			if(IsValid(Dude))then
				if(self:CanSee(Dude))then
					return Dude
				end
			end
		end
		return nil
	end
	function SWEP:ExtraThink()
		--[[
		for i=0,100 do
			if(self.Owner:IsCurrentSchedule(i))then
				JPrint(i)
			end
		end--]]
		if(IsValid(self.Owner))then
			if not(self.Reloading)then
				local Enemy=self.Owner:GetEnemy()
				local Act=self.Owner:GetActivity()
				if not(IsValid(Enemy))then
					if(IsValid(LastEnemy))then
						self.Owner:UpdateEnemyMemory(LastEnemy,LastEnemy:GetPos())
					else
						if not(self.Owner.BeingACombatLifeSaver)then
							if(math.random(1,20)==11)then
								for key,dude in pairs(ents.FindInSphere(self.Owner:GetPos(),1000))do
									if(dude.JackyUSSoldier)then
										if not(dude==self.Owner)then
											if(dude:Health()<49)then
												self.Owner.BeingACombatLifeSaver=true
												self.Owner.CLSPatient=dude
											end
										end
									end
								end
							end
						else
							if(IsValid(self.Owner.CLSPatient))then
								local Dist=(self.Owner:GetPos()-self.Owner.CLSPatient:GetPos()):Length()
								if(Dist>50)then
									if not(self.Owner:IsCurrentSchedule(SCHED_FORCED_GO_RUN))then
										self.Owner:SetLastPosition(self.Owner.CLSPatient:GetPos())
										self.Owner:SetSchedule(SCHED_FORCED_GO_RUN)
									end
								else
									JackyPlayNPCAnim(self.Owner,"Heal",true,1)
									self.Owner.CLSPatient:StopMoving()
									local Wut=self.Owner.CLSPatient
									timer.Simple(.5,function()
										if((IsValid(self))and(IsValid(Wut)))then
											--JackyPlayNPCAnim(Wut,"deathpose_back",true,3)
											Wut:SetHealth(50)
											Wut:RemoveAllDecals()
											Wut:EmitSound("snd_jack_bandage.wav",65,100)
										end
									end)
									self.Owner.BeingACombatLifeSaver=false
									self.Owner.CLSPatient=nil
								end
							else
								self.Owner.BeingACombatLifeSaver=false
							end
						end
						if(Act==ACT_IDLE)then
							if(self.RoundsInMag<30)then
								self:Reload()
							end
						end
					end
				else
					if(self.Owner:IsCurrentSchedule(SCHED_COMBAT_STAND))then
						-- get off your ass
						self.Owner:SetSchedule(SCHED_CHASE_ENEMY)
					end
					if not(self.LastEnemy==Enemy)then
						self.LastEnemy=Enemy
						self.NextShootTime=CurTime()+math.Rand(.1,.5)
					end
				end
			end
		end
		self:NextThink(CurTime()+.1)
	end
	function SWEP:NPCShoot_Secondary(ShootPos,ShootDir)
		--the fuck are you doing, son?
	end
	function SWEP:OnDrop()
		local wep=ents.Create("prop_physics")
		wep:SetModel(self.WorldModel)
		wep:SetPos(self:GetPos())
		wep:SetAngles(self:GetAngles())
		self:Remove()
		wep:Spawn()
		wep:Activate()
		SafeRemoveEntityDelayed(wep,30)
	end
	function SWEP:NPCShoot_Primary(ShootPos,ShootDir)
		if((self.NextShootTime<CurTime())and not(self.Reloading))then
			local Anim=self.Owner:GetSequenceName(self.Owner:GetSequence())
			self:Shoot(ShootPos,ShootDir)
			local Enem=self.Owner:GetEnemy()
			if((IsValid(Enem))and((Anim=="shoot_ar2")or(Anim=="ShootToIdleAngry")))then
				local Dist=(Enem:GetPos()-self.Owner:GetPos()):Length()
				local Chance=1.25-(Dist/2000)
				if(math.Rand(0,1)<Chance)then
					timer.Simple(.075,function()
						self.Owner:SetSchedule(SCHED_RANGE_ATTACK1)
						self.Owner:RestartGesture(279)
						self:NPCShoot_Primary(ShootPos,ShootDir)
					end)
				end
			end
		end
	end
	function SWEP:Shoot(ShootPos,ShootDir)
		if(self.NextShootTime>CurTime())then return end
		if(self.Reloading)then return end
		local Enemy=self.Owner:GetEnemy()
		if not(IsValid(Enemy))then return end
		if(self.RoundsInMag>0)then
			--self:EmitSound("snd_jack_npcrifleshoot_close.wav")
			sound.Play("snd_jack_npcrifleshoot_close.wav",ShootPos,75,100)
			sound.Play("snd_jack_npcrifleshoot_far.wav",ShootPos+Vector(0,0,1),100,100)
			sound.Play("snd_jack_npcrifleshoot_close.wav",ShootPos,85,100)
			sound.Play("snd_jack_npcrifleshoot_far.wav",ShootPos+Vector(0,0,1),130,75)
			local Fect=EffectData()
			Fect:SetStart(ShootPos+ShootDir*40-self.Owner:GetUp()*10)
			Fect:SetNormal(ShootDir)
			Fect:SetScale(1)
			util.Effect("eff_jack_gmod_noflashmuzzle",Fect,true,true)
			local PosAng=self:GetAttachment(2)
			local effectdata=EffectData()
			effectdata:SetOrigin(PosAng.Pos)
			effectdata:SetAngles(PosAng.Ang)
			util.Effect("RifleShellEject",effectdata)
			local ShootAng=ShootDir:Angle()
			local angpos=self:GetAttachment(self:LookupAttachment("muzzle"))
			local ShootOrigin=angpos.Pos+angpos.Ang:Forward()*19+angpos.Ang:Up()*5
			local Dist=(Enemy:GetPos()-self.Owner:GetPos()):Length()
			local Miss=50
			if not(self.Owner.USMilitaryRiflemanTraining)then Miss=5 end
			local EnemyPos=Enemy:LocalToWorld(Enemy:OBBCenter())+VectorRand()*math.Rand(0,Dist/Miss)+self:HeightCorrection()
			local Dir=(EnemyPos-ShootPos):GetNormalized()
			local EyeTraceData={}
			EyeTraceData.start=ShootPos
			EyeTraceData.endpos=ShootPos+Dir*99999
			EyeTraceData.filter=self.Owner
			EyeTraceData.mask=MASK_SHOT
			local EyeTrace=util.TraceLine(EyeTraceData)
			if(EyeTrace.Hit)then
				local Bewlat={}
				Bewlat.Num=1
				Bewlat.Damage=math.Rand(20,30)
				Bewlat.Force=500
				Bewlat.Src=ShootPos
				Bewlat.Dir=Dir
				Bewlat.Spread=Vector(0,0,0)
				Bewlat.Tracer=0
				self.Owner:FireBullets(Bewlat)
			end
			--JPrint(self.Owner:GetSequenceName(self.Owner:GetSequence()))
			self.RoundsInMag=self.RoundsInMag-1
		else
			self:Reload()
		end
	end
elseif(CLIENT)then
	SWEP.PrintName="AI Assault Rifle/GL"
	SWEP.Slot=1
	SWEP.SlotPos=3
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=true
	SWEP.ViewModelFOV=90
	SWEP.ViewModelFlip=false
	SWEP.RenderGroup=RENDERGROUP_OPAQUE
	function SWEP:DrawHUD()
		--
	end
	function SWEP:TranslateFOV(current_fov)
		return current_fov
	end
	function SWEP:DrawWorldModel()
		self.Weapon:DrawModel()
	end
	function SWEP:DrawWorldModelTranslucent()
		self.Weapon:DrawModel()
	end
	function SWEP:AdjustMouseSensitivity()
		return nil
	end
end
function SWEP:Reload()
	if(self.Reloading)then return end
	self.Reloading=true
	self.RoundsInMag=0
	self.Owner:SetSchedule(SCHED_RELOAD)
	JackyPlayNPCAnim(self.Owner,"reload_smg1",true,3)
	self.Owner:EmitSound("snd_jack_npcriflereload.wav")
	timer.Simple(3,function()
		if(IsValid(self))then
			self.Reloading=false
			self.RoundsInMag=30
		end
	end)
	return true
end
SWEP.Author="Jackarunda"
SWEP.Contact=""
SWEP.Purpose=""
SWEP.Instructions=""
SWEP.Category="AI Weapons"
SWEP.Spawnable=false
SWEP.AdminSpawnable=false
SWEP.ViewModel="models/weapons/v_pistol.mdl"
SWEP.WorldModel="models/weapons/w_JRifle.mdl" ----w_IRifle if you want combine muzzle flash
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 30
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "smg"
AccessorFunc(SWEP,"fNPCMinBurst","NPCMinBurst")
AccessorFunc(SWEP,"fNPCMaxBurst","NPCMaxBurst")
AccessorFunc(SWEP,"fNPCFireRate","NPCFireRate")
AccessorFunc(SWEP,"fNPCMinRestTime","NPCMinRest")
AccessorFunc(SWEP,"fNPCMaxRestTime","NPCMaxRest")
function SWEP:Initialize()
	self:SetWeaponHoldType("ar2")
	if(SERVER)then
		self:SetNPCMinBurst(4000)
		self:SetNPCMaxBurst(8000)
		self:SetNPCFireRate(5)
		local TName="JackyRifleThink"..tostring(self:EntIndex())
		timer.Create(TName,.1,0,function()
			if(IsValid(self))then
				self:ExtraThink()
			else
				timer.Destroy(TName)
			end
		end)
	end
	self.RoundsInMag=30
	self.Reloading=false
	self.NextShootTime=CurTime()+0.1
	self.LastEnemy=nil
end
function SWEP:PrimaryAttack()
	--
end
function SWEP:GetCapabilities()
	return bit.bor(CAP_WEAPON_RANGE_ATTACK1,CAP_INNATE_RANGE_ATTACK1)
end
function SWEP:SecondaryAttack()
	--
end