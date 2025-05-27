-- AdventureBoots 2023
AddCSLuaFile()
SWEP.Base = "wep_jack_gmod_ezmeleebase"
SWEP.PrintName = "EZ Shovel"
SWEP.Author = "Jackarunda"
SWEP.Purpose = ""
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezshovel")
SWEP.ViewModel = "models/weapons/hl2meleepack/v_shovel.mdl"
SWEP.WorldModel = "models/props_junk/shovel01a.mdl"
SWEP.BodyHolsterModel = "models/props_junk/shovel01a.mdl"
SWEP.BodyHolsterSlot = "back"
SWEP.BodyHolsterAng = Angle(-85, 0, 90)
SWEP.BodyHolsterAngL = Angle(-93, 0, 90)
SWEP.BodyHolsterPos = Vector(3, -10, -3)
SWEP.BodyHolsterPosL = Vector(4, -10, 3)
SWEP.BodyHolsterScale = .75
SWEP.ViewModelFOV = 50
SWEP.Slot = 1
SWEP.SlotPos = 6

SWEP.VElements = {
}

SWEP.WElements = {
	["shovel"] = {
		type = "Model",
		model = "models/props_junk/shovel01a.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(5, 2.3, -12),
		angle = Angle(0, 180, 5),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}
}

--
SWEP.DropEnt = "ent_jack_gmod_ezshovel"
SWEP.HitDistance		= 64
SWEP.HitInclination		= 0.4
SWEP.HitPushback		= 500
SWEP.MaxSwingAngle		= 120
SWEP.SwingSpeed 		= 1
SWEP.SwingPullback 		= 70
SWEP.PrimaryAttackSpeed = 1
SWEP.SecondaryAttackSpeed 	= 1
SWEP.DoorBreachPower 	= 1
--
SWEP.SprintCancel 	= true
SWEP.StrongSwing 	= true
--
SWEP.SwingSound 	= Sound( "Weapon_Crowbar.Single" )
SWEP.HitSoundWorld 	= Sound( "Canister.ImpactHard" )
SWEP.HitSoundBody 	= Sound( "Flesh.ImpactHard" )
SWEP.PushSoundBody 	= Sound( "Flesh.ImpactSoft" )
--
SWEP.IdleHoldType 	= "melee2"
SWEP.SprintHoldType = "melee2"
--
SWEP.WhitelistedResources = {JMod.EZ_RESOURCE_TYPES.SAND, JMod.EZ_RESOURCE_TYPES.CLAY, JMod.EZ_RESOURCE_TYPES.WATER}

function SWEP:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "TaskProgress")
	self:NetworkVar("String", 0, "ResourceType")
end

function SWEP:CustomInit()
	self:SetHoldType("melee2")
	self:SetTaskProgress(0)
	self:SetResourceType("")
	self.NextTaskTime = 0
end

function SWEP:CustomThink()
	local Time = CurTime()
	if self.NextTaskTime < Time then
		self:SetTaskProgress(0)
		self.NextTaskTime = Time + 1.5
	end

	if CLIENT then
		if self.ScanResults then
			self.LastScanTime = self.LastScanTime or Time
			if self.LastScanTime < (Time - 30) then
				self.ScanResults = nil
				self.LastScanTime = nil
			end
		end
	end
end

local DirtTypes = {
	[MAT_DIRT] = 1,
	[MAT_SAND] = 1.5,
	[MAT_SNOW] = 1
}

function SWEP:OnHit(swingProgress, tr)
	local Owner = self:GetOwner()
	--local SwingCos = math.cos(math.rad(swingProgress))
	--local SwingSin = math.sin(math.rad(swingProgress))
	local SwingAng = Owner:EyeAngles()
	local SwingPos = Owner:GetShootPos()
	local StrikeVector = tr.HitNormal
	local StrikePos = (SwingPos - (SwingAng:Up() * 15))

	if IsValid(tr.Entity) then
		local PickDam = DamageInfo()
		PickDam:SetAttacker(self.Owner)
		PickDam:SetInflictor(self)
		PickDam:SetDamagePosition(StrikePos)
		PickDam:SetDamageType(DMG_CLUB)
		PickDam:SetDamage(math.random(20, 50))
		PickDam:SetDamageForce(StrikeVector:GetNormalized() * 30)
		tr.Entity:TakeDamageInfo(PickDam)
	end

	if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or string.find(tr.Entity:GetClass(),"prop_ragdoll") then
		tr.Entity:SetVelocity( self.Owner:GetAimVector() * Vector( 1, 1, 0 ) * self.HitPushback )
		self:SetTaskProgress(0)
		if tr.Entity.IsEZcorpse and IsValid(tr.Entity.EZcorpseEntity) then
			tr.Entity.EZcorpseEntity:Bury()
		end
	elseif tr.Entity:IsWorld() then
		local DirtTypeModifier = DirtTypes[util.GetSurfaceData(tr.SurfaceProps).material]
		local Message = JMod.EZprogressTask(self, tr.HitPos, self.Owner, "mining", (JMod.GetPlayerStrength(self.Owner) ^ 1.5) * (DirtTypeModifier or 1))

		if Message then
			local OldAmount = self:GetTaskProgress()
			print(OldAmount)

			if (DirtTypeModifier) then
				self:SetResourceType(JMod.EZ_RESOURCE_TYPES.SAND)
				self:SetTaskProgress(100)
				JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.SAND, 25, self:WorldToLocal(tr.HitPos + Vector(0, 0, 8)), Angle(0, 0, 0), self:WorldToLocal(tr.HitPos), 200)
				--sound.Play("physics/concrete/boulder_impact_hard" .. math.random(1, 3) .. ".wav", tr.HitPos + VectorRand(), 75, math.random(50, 70))
				self:Msg(Message)
			end
			
			
		else
			sound.Play("Dirt.Impact", tr.HitPos + VectorRand(), 75, math.random(50, 70))
			self:SetTaskProgress(self:GetNW2Float("EZminingProgress", 0))
		end

		local Dirt = EffectData()
		Dirt:SetOrigin(tr.HitPos)
		Dirt:SetNormal(tr.HitNormal)
		Dirt:SetScale(2)
		util.Effect("eff_jack_sminebury", Dirt, true, true)

		if (math.random(1, 1000) == 1) then 
			local Deposit = JMod.GetDepositAtPos(nil, tr.HitPos, 1.5) 
			if ((tr.MatType == MAT_SAND) or (JMod.NaturalResourceTable[Deposit] and JMod.NaturalResourceTable[Deposit].typ == JMod.EZ_RESOURCE_TYPES.SAND)) then
				timer.Simple(math.Rand(1, 2), function() 
					local npc = ents.Create("npc_antlion")
					npc:SetPos(tr.HitPos + Vector(0, 0, 30))
					npc:SetAngles(Angle(0, math.random(0, 360), 0))
					npc:SetKeyValue("startburrowed","1")
					npc:Spawn()
					npc:Activate()
					npc:Fire("unburrow", "", 0)
				end)
			end
		end
	else
		sound.Play("Canister.ImpactHard", tr.HitPos, 10, math.random(75, 100), 1)
		self:SetTaskProgress(0)
	end
end

function SWEP:FinishSwing(swingProgress)
	if swingProgress >= self.MaxSwingAngle then
		self:SetTaskProgress(0)
	else
		self.NextTaskTime = CurTime() + self.PrimaryAttackSpeed + 1
	end
end

if CLIENT then
	local LastProg = 0

	function SWEP:DrawHUD()
		if GetConVar("cl_drawhud"):GetBool() == false then return end
		local Ply = self.Owner
		if Ply:ShouldDrawLocalPlayer() then return end
		local W, H = ScrW(), ScrH()

		local Prog = self:GetTaskProgress()

		if Prog > 0 then
			draw.SimpleTextOutlined("Digging... "..self:GetResourceType(), "Trebuchet24", W * .5, H * .45, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
			draw.RoundedBox(10, W * .3, H * .5, W * .4, H * .05, Color(0, 0, 0, 100))
			draw.RoundedBox(10, W * .3 + 5, H * .5 + 5, W * .4 * LastProg / 100 - 10, H * .05 - 10, Color(255, 255, 255, 100))
		end

		LastProg = Lerp(FrameTime() * 5, LastProg, Prog)
	end
end