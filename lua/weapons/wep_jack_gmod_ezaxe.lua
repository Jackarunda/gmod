-- Jackarunda 2021 - AdventureBoots 2023
AddCSLuaFile()
SWEP.Base = "wep_jack_gmod_ezmeleebase"
SWEP.PrintName = "EZ Axe"
SWEP.Author = "Jackarunda"
SWEP.Purpose = ""
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezaxe")
SWEP.ViewModel = "models/weapons/HL2meleepack/v_axe.mdl"
SWEP.WorldModel = "models/props_forest/axe.mdl"
SWEP.BodyHolsterModel = "models/props_forest/axe.mdl"
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(-93, -90, 0)
SWEP.BodyHolsterAngL = Angle(-93, -90, 0)
SWEP.BodyHolsterPos = Vector(3, -10, -3)
SWEP.BodyHolsterPosL = Vector(4, -10, 3)
SWEP.BodyHolsterScale = 1
SWEP.ViewModelFOV = 50
SWEP.Slot = 1
SWEP.SlotPos = 5

SWEP.VElements = {
	["axe"] = {
		type = "Model",
		model = "models/props_forest/axe.mdl",
		bone = "ValveBiped.Bip01_L_Hand",
		rel = "",
		pos = Vector(3, 2, 10),
		angle = Angle(0, 0, -85),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
}

SWEP.WElements = {
	["axe"] = {
		type = "Model",
		model = "models/props_forest/axe.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(3, 1, -8),
		angle = Angle(0, -10, 90),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
}

SWEP.DropEnt = "ent_jack_gmod_ezaxe"
--
SWEP.HitDistance		= 60
SWEP.HitInclination		= 0.4
SWEP.HitPushback		= 500
SWEP.MaxSwingAngle		= 120
SWEP.SwingSpeed 		= 1
SWEP.SwingPullback 		= 90
SWEP.PrimaryAttackSpeed = 1
SWEP.SecondaryAttackSpeed 	= 1
SWEP.DoorBreachPower 	= 2
--
SWEP.SprintCancel 	= true
SWEP.StrongSwing 	= true
--
SWEP.SwingSound 	= Sound( "Weapon_Crowbar.Single" )
SWEP.HitSoundWorld 	= Sound( "SolidMetal.ImpactHard" )
SWEP.HitSoundBody 	= Sound( "Flesh.ImpactHard" )
SWEP.PushSoundBody 	= Sound( "Flesh.ImpactSoft" )
--
SWEP.IdleHoldType 	= "melee2"
SWEP.SprintHoldType = "melee2"
--

function SWEP:CustomInit()
	self:SetTaskProgress(0)
	self.NextTaskTime = 0
	self:SetSwinging(false)
	self.SwingProgress = 1
end

function SWEP:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "TaskProgress")
end

function SWEP:CustomThink()
	local Time = CurTime()
	if self.NextTaskTime < Time then
		self:SetTaskProgress(0)
		self.NextTaskTime = Time + 1.5
	end
end

local FleshTypes = {
	MAT_ANTLION,
	MAT_FLESH,
	MAT_BLOODYFLESH,
	MAT_FLESH,
	MAT_ALIENFLESH
}

function SWEP:OnHit(swingProgress, tr)
	local Owner = self:GetOwner()
	--local SwingCos = math.cos(math.rad(swingProgress))
	--local SwingSin = math.sin(math.rad(swingProgress))
	local SwingAng = Owner:EyeAngles()
	local SwingPos = Owner:GetShootPos()
	local StrikeVector = tr.HitNormal
	local StrikePos = (SwingPos - (SwingAng:Up() * 15))

	local AxeDam = DamageInfo()
	AxeDam:SetAttacker(Owner)
	AxeDam:SetInflictor(self)
	AxeDam:SetDamagePosition(tr.HitPos)
	AxeDam:SetDamageType(DMG_SLASH)
	AxeDam:SetDamage(math.random(35, 50))
	AxeDam:SetDamageForce(StrikeVector:GetNormalized() * 2000)

	if ((table.HasValue(FleshTypes, util.GetSurfaceData(tr.SurfaceProps).material)) and (string.find(tr.Entity:GetClass(), "prop_ragdoll"))) or ((util.GetSurfaceData(tr.SurfaceProps).material == MAT_WOOD) and (string.find(tr.Entity:GetClass(), "prop_physics"))) then
		local Mesg = JMod.EZprogressTask(tr.Entity, tr.HitPos, Owner, "salvage")
		if Mesg then
			Owner:PrintMessage(HUD_PRINTCENTER, Mesg)
			self:SetTaskProgress(0)
		else
			self:SetTaskProgress(tr.Entity:GetNW2Float("EZsalvageProgress", 0))
			AxeDam:SetDamage(0)
		end
	elseif JMod.IsDoor(tr.Entity) then
		self:TryBustDoor(tr.Entity, math.random(35, 50), tr.HitPos)
		self:SetTaskProgress(0)
	else
		self:SetTaskProgress(0)
	end

	tr.Entity:TakeDamageInfo(AxeDam)

	sound.Play(util.GetSurfaceData(tr.SurfaceProps).impactHardSound, tr.HitPos, 75, 100, 1)
	util.Decal("ManhackCut", tr.HitPos + tr.HitNormal * 10, tr.HitPos - tr.HitNormal * 10, {self, Owner})
end

function SWEP:FinishSwing(swingProgress)
	self:SetTaskProgress(0)
end

local Downness = 0

function SWEP:GetViewModelPosition(pos, ang)
	local FT = FrameTime()

	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		Downness = Lerp(FT * 2, Downness, 5)
	else
		Downness = Lerp(FT * 2, Downness, -2)
	end

	ang:RotateAroundAxis(ang:Right(), -Downness * 5)

	return pos, ang
end

local LastProg = 0

function SWEP:DrawHUD()
	if GetConVar("cl_drawhud"):GetBool() == false then return end
	local Ply = self.Owner
	if Ply:ShouldDrawLocalPlayer() then return end
	local W, H = ScrW(), ScrH()

	local Prog = self:GetTaskProgress()

	if Prog > 0 then
		draw.SimpleTextOutlined("Hacking... ", "Trebuchet24", W * .5, H * .45, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
		draw.RoundedBox(10, W * .3, H * .5, W * .4, H * .05, Color(0, 0, 0, 100))
		draw.RoundedBox(10, W * .3 + 5, H * .5 + 5, W * .4 * LastProg / 100 - 10, H * .05 - 10, Color(255, 255, 255, 100))
	end

	LastProg = Lerp(FrameTime() * 5, LastProg, Prog)
end