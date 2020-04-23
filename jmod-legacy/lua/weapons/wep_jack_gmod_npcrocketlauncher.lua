AddCSLuaFile()
if(SERVER)then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	function SWEP:SetupWeaponHoldTypeForAI(t)
		self.ActivityTranslateAI={}
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_RPG
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_RPG_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_RPG_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_RPG_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_RPG
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_RPG
		self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_GESTURE_RELOAD
		self.ActivityTranslateAI [ ACT_WALK_AIM ] 					= ACT_WALK_RPG
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN_RPG
		self.ActivityTranslateAI [ ACT_GESTURE_RANGE_ATTACK1 ] 		= ACT_GESTURE_RANGE_ATTACK1
		self.ActivityTranslateAI [ ACT_RELOAD_LOW ] 				= ACT_RELOAD_LOW
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK1_LOW
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_COVER_LOW_RPG
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ] 				= ACT_RANGE_AIM_LOW
		self.ActivityTranslateAI [ ACT_GESTURE_RELOAD ] 			= ACT_GESTURE_RELOAD
	end
	SWEP.Weight=5
	SWEP.AutoSwitchTo=false
	SWEP.AutoSwitchFrom=false 
	function SWEP:NPCShoot_Secondary(ShootPos,ShootDir)
		--the fuck are you doing, son?
	end
	function SWEP:OnDrop()
		local rpg=ents.Create("weapon_rpg")
		rpg:SetPos(self:GetPos())
		rpg:SetAngles(self:GetAngles())
		self:Remove()
		rpg:Spawn()
		rpg:Activate()
	end
	function SWEP:NPCShoot_Primary(ShootPos,ShootDir)
		if(self.Owner.IsTrainedWithRocketLaunchers)then --we do these simple safety checks
			local Enemy=self.Owner:GetEnemy()
			local enemypos=Enemy:GetPos()
			for key,enpeesee in pairs(ents.FindInSphere(enemypos,200))do
				if(enpeesee:IsNPC())then
					if(enpeesee:GetClass()=="npc_citizen")then --MOVE!!
						local WarningTable={"vo/npc/male01/getdown02.wav","vo/npc/male01/headsup01.wav","vo/npc/male01/headsup02.wav","vo/npc/male01/watchout.wav"}
						self.Owner:EmitSound(WarningTable[math.random(1,4)])
						return
					end
				end
			end
		end
		if(self.NextFireTime<CurTime())then
			self.Reloading=false
			local GoDirection=ShootDir
			if(self.Owner.IsTrainedWithRocketLaunchers)then --he knows to shoot at an enemy's feet, and to adjust for the drop of the rocket.
				local dist=(self.Owner:GetEnemy():GetPos()-self.Owner:GetPos()):Length()
				local DropCompensation=dist^2.022*0.000027
				local Inaccuracy=VectorRand()*math.Rand(0,40)
				local MovingTargetTravelTimeCompensation=(self.Owner:GetEnemy():GetVelocity())*(dist/1650)
				GoDirection=(self.Owner:GetEnemy():GetPos()+Vector(0,0,DropCompensation)+MovingTargetTravelTimeCompensation+Inaccuracy-ShootPos):GetNormalized()
			end
			JackyPlayNPCAnim(self.Owner,"shoot_rpg",true,.4)
			if not(self.FiredRocket)then
				self.FiredRocket=true
				timer.Simple(.5,function()
					if(IsValid(self))then
						self.Owner:EmitSound("weapons/rpg/rocketfire1.wav")
						local rockit=ents.Create("ent_jack_gmod_npcrocket")
						rockit:SetPos(ShootPos+ShootDir)
						rockit:SetOwner(self.Owner)
						rockit:SetAngles(GoDirection:Angle())
						rockit.Owner=self.Owner
						rockit:Spawn()
						rockit:Activate()
						self.NextFireTime=CurTime()+5
						self.Owner:StopMoving()
						self.Owner:RestartGesture(self.Owner:GetSequenceInfo(self.Owner:LookupSequence("shoot_rpg")).activity)
					end
				end)
			end
		else
			self.FiredRocket=false
			if not(self.Reloading)then
				if(self.Owner.IsTrainedWithRocketLaunchers)then
					local chance=math.random(1,3)
					if(chance==1)then
						self.Owner:EmitSound("vo/npc/male01/gottareload01.wav")
					elseif(chance==2)then
						self.Owner:EmitSound("vo/npc/male01/coverwhilereload01.wav")
					elseif(chance==3)then
						self.Owner:EmitSound("vo/npc/male01/coverwhilereload02.wav")
					end
				end
				self.Reloading=true
			end
		end
	end
elseif(CLIENT)then
	language.Add("wep_jack_rocketlauncher","RPG")
	--killicon.Add("wep_jack_rocketlauncher","HUD/killicons/weapon_rpg",Color(255,80,0,255))
	SWEP.PrintName="AI Rocket Launcher"
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

SWEP.Author="Silverlan & Jackarunda"
SWEP.Contact=""
SWEP.Purpose=""
SWEP.Instructions=""
SWEP.Category="AI Weapons"

SWEP.Spawnable=false
SWEP.AdminSpawnable=false

SWEP.ViewModel="models/weapons/v_rpg.mdl"
SWEP.WorldModel="models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "RPG_Round"

/*---------------------------------------------------------
---------------------------------------------------------*/
function SWEP:Initialize()
	self:SetWeaponHoldType("rpg")
	if(SERVER)then
		self:SetNPCMinBurst(4000)
		self:SetNPCMaxBurst(8000)
		self:SetNPCFireRate(5)
	end
	self.NextFireTime=CurTime()
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
end

/*------------------------------------
	Reload
------------------------------------*/
function SWEP:Reload()
	return true
end 

/*---------------------------------------------------------
   Name: GetCapabilities
   Desc: For NPCs, returns what they should try to do with it.
---------------------------------------------------------*/
function SWEP:GetCapabilities()
	return CAP_WEAPON_RANGE_ATTACK1
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end
