AddCSLuaFile()
if(SERVER)then
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	function SWEP:SetupWeaponHoldTypeForAI(t)
		self.ActivityTranslateAI={}
		self.ActivityTranslateAI [ ACT_IDLE ] 						= ACT_IDLE_PISTOL
		self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= ACT_IDLE_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= ACT_IDLE_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= ACT_IDLE_RELAXED
		self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= ACT_IDLE_ANGRY_PISTOL
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_PISTOL
		self.ActivityTranslateAI [ ACT_WALK_AIM ] 					= ACT_WALK_AIM_PISTOL
		self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= ACT_RUN_AIM_PISTOL
		self.ActivityTranslateAI [ ACT_GESTURE_RANGE_ATTACK1 ] 		= ACT_GESTURE_RANGE_ATTACK_PISTOL
		self.ActivityTranslateAI [ ACT_RELOAD_LOW ] 				= ACT_RELOAD_PISTOL_LOW
		self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK_PISTOL_LOW
		self.ActivityTranslateAI [ ACT_COVER_LOW ] 					= ACT_COVER_PISTOL_LOW
		self.ActivityTranslateAI [ ACT_RANGE_AIM_LOW ] 				= ACT_RANGE_AIM_PISTOL_LOW
		self.ActivityTranslateAI [ ACT_GESTURE_RELOAD ] 			= ACT_GESTURE_RELOAD_PISTOL
	end
	SWEP.Weight=5
	SWEP.AutoSwitchTo=false
	SWEP.AutoSwitchFrom=false 
	function SWEP:NPCShoot_Secondary(ShootPos,ShootDir)
		--the fuck are you doing, son?
	end
	function SWEP:OnDrop()
		local wep=ents.Create("weapon_pistol")
		wep:SetPos(self:GetPos())
		wep:SetAngles(self:GetAngles())
		self:Remove()
		wep:Spawn()
		wep:Activate()
	end
	function SWEP:NPCShoot_Primary(ShootPos,ShootDir)
		if(self.Reloading)then return end
		if(self.NextFire>CurTime())then return end
		local Enem=self.Owner:GetEnemy()
		if(IsValid(Enem))then
			local EnemPos=Enem:LocalToWorld(Enem:OBBCenter())
			local Vec=(EnemPos-ShootPos):GetNormalized()
			self:Shoot(ShootPos,Vec)
		end
	end
	function SWEP:Shoot(ShootPos,ShootDir)
		if(self.RoundsInPulseMag>0)then
			self.Owner:SetAnimation(ACT_RANGE_ATTACK_PISTOL)
			local posang=self:GetAttachment(self:LookupAttachment("muzzle"))
			--local Kabang=EffectData()
			--Kabang:SetStart(posang.Pos+posang.Ang:Forward()*3)
			--Kabang:SetNormal(ShootDir)
			--Kabang:SetScale(1)
			--util.Effect("eff_jack_combinemuzzle",Kabang)
			self.Weapon:EmitSound("weapons/pistol/pistol_fire3.wav")
			--sound.Play("weapons/irifle/irifle_fire2.wav",self:GetPos(),75,160)
			local Bam={}
			Bam.Src=ShootPos
			Bam.Dir=ShootDir
			Bam.Num=1
			Bam.Damage=5
			Bam.Tracer=1
			Bam.Spread=Vector(.035,.035,.035)
			Bam.Attacker=self.Owner
			Bam.Inflictor=self.Weapon
			self:FireBullets(Bam)
		else
			self:Reload()
		end
	end
	function SWEP:Reload()
		if(self.Reloading)then return end
		self.Reloading=true
		self.Owner:EmitSound("weapons/pistol/pistol_reload1.wav")
		self.RoundsInPulseMag=10
		self.Owner:SetSchedule(SCHED_RELOAD)
		timer.Simple(1.5,function()
			if(IsValid(self))then
				self.Reloading=false
			end
		end)
		return true
	end
	function SWEP:DeployBlade()
		self.NoSetNoDraw=true
		self:SetNoDraw(false)
		self:SetDTBool(0,true)
		self:SetDTBool(1,true)
		timer.Simple(.75,function()
			if(IsValid(self))then
				self.NoSetNoDraw=false
				self:SetDTBool(1,false)
				self:SetDTBool(0,false)
			end
		end)
	end
elseif(CLIENT)then
	language.Add("wep_jack_npcstalkerpistol","Pistol")
	SWEP.PrintName="AI Stalker Pistol"
	SWEP.Slot=1
	SWEP.SlotPos=3
	SWEP.DrawAmmo=false
	SWEP.DrawCrosshair=true
	SWEP.ViewModelFOV=90
	SWEP.ViewModelFlip=false
	SWEP.RenderGroup=RENDERGROUP_OPAQUE
	function SWEP:DrawHUD()
	end
	function SWEP:TranslateFOV(current_fov)
		return current_fov
	end
	function SWEP:DrawWorldModel()
		if not(self:GetDTBool(0))then
			render.SetColorModulation(.1,.1,.1)
			self.Weapon:DrawModel()
			render.SetColorModulation(1,1,1)
		end
		if(self:GetDTBool(1))then
			local Pos,Ang=self.Owner:GetBonePosition(11) -- Right Hand
			self.Blade:SetRenderOrigin(Pos+Ang:Forward()*15)
			self.Blade:SetAngles(Ang)
			self.Blade:DrawModel()
		end
	end
	function SWEP:DrawWorldModelTranslucent()
		self.Weapon:DrawModel()
	end
	function SWEP:AdjustMouseSensitivity()
		return nil
	end
end
SWEP.Author="Jackarunda"
SWEP.Contact=""
SWEP.Purpose=""
SWEP.Instructions=""
SWEP.Category="AI Weapons"
SWEP.Spawnable=false
SWEP.AdminSpawnable=false
SWEP.ViewModel="models/weapons/v_pistol.mdl"
SWEP.WorldModel="models/weapons/w_pistol.mdl"
SWEP.Primary.ClipSize		= 9000
SWEP.Primary.DefaultClip	= 9000
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "pistol"
function SWEP:Initialize()
	self:SetWeaponHoldType("pistol")
	if(SERVER)then
		self:SetNPCMinBurst(9000)
		self:SetNPCMaxBurst(9000)
		self:SetNPCFireRate(0.25)
	end
	self.RoundsInPulseMag=10
	self.NextFire=CurTime()
	if(CLIENT)then
		self.Blade=ClientsideModel("models/Gibs/wood_gib01e.mdl")
		self.Blade:SetPos(self:GetPos())
		self.Blade:SetParent(self)
		self.Blade:SetNoDraw(true)
		local Mat=Matrix()
		Mat:Scale(Vector(2,1,1))
		self.Blade:EnableMatrix("RenderMultiply",Mat)
		self.Blade:SetMaterial("models/alyx/emptool_glow")
	end
end
/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
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