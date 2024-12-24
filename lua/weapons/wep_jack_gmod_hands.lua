if SERVER then
	AddCSLuaFile()
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
else
	SWEP.PrintName = "Jmod Hands"
	SWEP.Slot = 0
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.ViewModelFOV = 45
	JMod.SetWepSelectIcon(SWEP, "entities/wep_jack_gmod_hands")
	SWEP.BounceWeaponIcon = false
	local HandTex, ClosedTex = surface.GetTextureID("vgui/hud/gmod_hand"), surface.GetTextureID("vgui/hud/gmod_closedhand")

	function SWEP:DrawHUD()
		if GetConVar("cl_drawhud"):GetBool() == false then return end
		if not (GetViewEntity() == LocalPlayer()) then return end
		if LocalPlayer():InVehicle() then return end
		local Ply = self.Owner
		local W, H, Build = ScrW(), ScrH()

		if not self:GetFists() then
			local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * self.ReachDistance, {self.Owner})

			if Tr.Hit then
				if self:CanPickup(Tr.Entity) then
					local Size = math.Clamp(1 - ((Tr.HitPos - self.Owner:GetShootPos()):Length() / self.ReachDistance) ^ 2, .2, 1)

					if self.Owner:KeyDown(IN_ATTACK2) then
						surface.SetTexture(ClosedTex)
					else
						surface.SetTexture(HandTex)
					end

					surface.SetDrawColor(Color(255, 255, 255, 255 * Size))
					surface.DrawTexturedRect(ScrW() / 2 - (64 * Size), ScrH() / 2 - (64 * Size), 128 * Size, 128 * Size)
				end
			end
		end
		local ToolBox = Ply:GetWeapon("wep_jack_gmod_eztoolbox")
		if IsValid(ToolBox) and ToolBox:GetNW2Bool("EZoneHandedBuild", false) then
			draw.SimpleTextOutlined("ALT+LMB: use toolbox onehanded: "..ToolBox:GetSelectedBuild(), "Trebuchet24", W * .4, H * .7 + 60, Color(255, 255, 255, 30), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 10))
		end
	end
end

SWEP.SwayScale = 3
SWEP.BobScale = 3
SWEP.InstantPickup = true -- FF compat
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = "Grab and move stuff with your friends!"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HoldType = "normal"
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/props_junk/cardboard_box004a.mdl"
SWEP.UseHands = true
SWEP.AttackSlowDown = .5
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ReachDistance = 60
SWEP.HomicideSWEP = true

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextIdle")
	self:NetworkVar("Bool", 2, "Fists")
	self:NetworkVar("Float", 1, "NextDown")
	self:NetworkVar("Bool", 3, "Blocking")
	self:NetworkVar("Bool", 4, "IsCarrying")
	self:NetworkVar("Float", 2, "TaskProgress")
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:Initialize()
	self:SetNextIdle(CurTime() + 5)
	self:SetNextDown(CurTime() + 5)
	self:SetHoldType(self.HoldType)
	self:SetFists(false)
	self:SetBlocking(false)
end

function SWEP:Deploy()
	if not IsFirstTimePredicted() then
		self:DoBFSAnimation("fists_draw")
		self.Owner:GetViewModel():SetPlaybackRate(.1)

		return
	end

	self:SetNextPrimaryFire(CurTime() + .1)
	self:SetFists(false)
	self:SetNextDown(CurTime())
	self:DoBFSAnimation("fists_draw")

	return true
end

function SWEP:Holster()
	self:OnRemove()

	return true
end

function SWEP:CanPrimaryAttack()
	return true
end

local pickupWhiteList = {
	["prop_ragdoll"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

function SWEP:CanPickup(ent)
	if ent:IsNPC() then return false end
	if ent:IsPlayer() then return false end
	if ent:IsWorld() then return false end
	--if ent:GetParent() then return false end
	local class = ent:GetClass()
	--if pickupWhiteList[class] then return true end
	if CLIENT then return true end
	if ent:IsPlayerHolding() then return false end
	if IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject():IsMotionEnabled() then return true end

	return false
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then return end
	if self:GetFists() then return end

	if SERVER then
		JMod.Hint(self.Owner, "hands grab")
		self:SetCarrying()
		local tr = self.Owner:GetEyeTraceNoCursor()

		if IsValid(tr.Entity) and self:CanPickup(tr.Entity) and not tr.Entity:IsPlayer() then
			local Dist = (self.Owner:GetShootPos() - tr.HitPos):Length()

			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", self.Owner:GetShootPos(), 65, math.random(90, 110))
				self:SetCarrying(tr.Entity, tr.PhysicsBone, tr.HitPos, Dist)
				tr.Entity.Touched = true
				self:ApplyForce()
			end
		elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
			local Dist = (self.Owner:GetShootPos() - tr.HitPos):Length()

			if Dist < self.ReachDistance then
				sound.Play("Flesh.ImpactSoft", self.Owner:GetShootPos(), 65, math.random(90, 110))
				self.Owner:SetVelocity(self.Owner:GetAimVector() * 20)
				tr.Entity:SetVelocity(-self.Owner:GetAimVector() * 50)
				self:SetNextSecondaryFire(CurTime() + .25)
			end
		end
	end
end

function SWEP:ApplyForce()
	local target = self.Owner:GetAimVector() * self.CarryDist + self.Owner:GetShootPos() + Vector(0, 0, 5)
	local phys = self.CarryEnt:GetPhysicsObjectNum(self.CarryBone)

	if IsValid(phys) then
		local TargetPos = phys:GetPos()

		if self.CarryPos then
			TargetPos = self.CarryEnt:LocalToWorld(self.CarryPos)
		end

		local vec = target - TargetPos
		local len, mul = vec:Length(), self.CarryEnt:GetPhysicsObject():GetMass()

		local StandingEnt = self.Owner:GetGroundEntity()
		local StandingOn = IsValid(StandingEnt) and ((StandingEnt == self.CarryEnt) or (StandingEnt:IsConstrained() and table.HasValue(constraint.GetAllConstrainedEntities(StandingEnt), self.CarryEnt)))
		local PlyIn = (self.CarryEnt == self.Owner:GetVehicle())
		if len > self.ReachDistance or StandingOn or PlyIn then
			self:SetCarrying()

			return
		end

		if self.CarryEnt:GetClass() == "prop_ragdoll" then
			mul = mul * 10
		end

		vec:Normalize()
		local plyVel = self.Owner:GetVelocity()
		local avec, velo = vec * len^1.5, phys:GetVelocity() - (plyVel * 2)
		local Force = (avec - velo / 2) * mul
		local ForceNormal = Force:GetNormalized()
		local ForceMagnitude = Force:Length()
		ForceMagnitude = math.Clamp(ForceMagnitude, 0, 2000 * JMod.GetPlayerStrength(self.Owner))
		Force = ForceNormal * ForceMagnitude

		local CounterDir, CounterAmt = velo:GetNormalized(), velo:Length()

		if self.CarryPos then
			phys:ApplyForceOffset(Force, self.CarryEnt:LocalToWorld(self.CarryPos))
		else
			phys:ApplyForceCenter(Force)
		end

		phys:ApplyForceCenter(Vector(0, 0, mul))
		phys:AddAngleVelocity(-phys:GetAngleVelocity() / 10)
	end
end

function SWEP:OnRemove()
	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end
end

function SWEP:GetCarrying()
	return self.CarryEnt
end

function SWEP:SetCarrying(ent, bone, pos, dist)
	if not SERVER then return end
	if IsValid(ent) then
		self.CarryEnt = ent
		self.CarryBone = bone
		self.CarryDist = dist

		if not (ent:GetClass() == "prop_ragdoll") then
			self.CarryPos = ent:WorldToLocal(pos)
			--self.CarryAng = ent:GetAngles()
		else
			self.CarryPos = nil
		end
	else
		self.CarryEnt = nil
		self.CarryBone = nil
		self.CarryPos = nil
		self.CarryDist = nil
		--self.CarryAng = nil
	end
end

function SWEP:Think()
	if IsValid(self.Owner) and self.Owner:KeyDown(IN_ATTACK2) and not self:GetFists() then
		if IsValid(self.CarryEnt) then
			self:ApplyForce()
		end
	elseif self.CarryEnt then
		self:SetCarrying()
	end

	if self:GetFists() and self.Owner:KeyDown(IN_ATTACK2) then
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetBlocking(true)
	else
		self:SetBlocking(false)
	end

	local HoldType = "fist"

	if self:GetFists() then
		HoldType = "fist"
		local Time = CurTime()

		if self:GetNextIdle() < Time then
			self:DoBFSAnimation("fists_idle_0" .. math.random(1, 2))
			self:UpdateNextIdle()
		end

		if self:GetBlocking() then
			self:SetNextDown(Time + 1)
			HoldType = "normal"
		end

		if (self:GetNextDown() < Time) or self.Owner:KeyDown(IN_SPEED) then
			self:SetNextDown(Time + 1)
			self:SetFists(false)
			self:SetBlocking(false)
		end
	else
		HoldType = "normal"
		self:DoBFSAnimation("fists_draw")
	end

	if IsValid(self.CarryEnt) or self.CarryEnt then
		HoldType = "magic"
	end

	if self.Owner:KeyDown(IN_SPEED) then
		HoldType = "normal"
	end

	if SERVER then
		self:SetHoldType(HoldType)
	end
end

function SWEP:PrimaryAttack()
	if SERVER then
		local Alt = self.Owner:KeyDown(JMod.Config.General.AltFunctionKey)

		if Alt and self.Owner:HasWeapon("wep_jack_gmod_eztoolbox") and IsFirstTimePredicted() then
			local ToolBox = self.Owner:GetWeapon("wep_jack_gmod_eztoolbox")
			local SelectedBuild = ToolBox:GetSelectedBuild()
			local BuildInfo = JMod.Config.Craftables[SelectedBuild]
			if BuildInfo and BuildInfo.oneHanded then
				ToolBox:BuildItem(SelectedBuild)
				self:SetNextPrimaryFire(CurTime() + .6)

				return
			end
		end
	end

	local side = "fists_left"

	if math.random(1, 2) == 1 then
		side = "fists_right"
	end

	self:SetNextDown(CurTime() + 5)

	if not self:GetFists() then
		self:SetFists(true)
		self:DoBFSAnimation("fists_draw")
		self:SetNextPrimaryFire(CurTime() + .35)

		return
	end

	if self:GetBlocking() then return end
	if self.Owner:KeyDown(IN_SPEED) then return end

	if not IsFirstTimePredicted() then
		self:DoBFSAnimation(side)
		self.Owner:GetViewModel():SetPlaybackRate(1.25)

		return
	end

	self.Owner:ViewPunch(Angle(0, 0, math.random(-2, 2)))
	self:DoBFSAnimation(side)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:GetViewModel():SetPlaybackRate(1.25)
	self:UpdateNextIdle()

	if SERVER then
		sound.Play("weapons/slam/throw.wav", self:GetPos(), 65, math.random(90, 110))
		self.Owner:ViewPunch(Angle(0, 0, math.random(-2, 2)))

		timer.Simple(.075, function()
			if IsValid(self) and IsValid(self.Owner) then
				self:AttackFront()
			end
		end)
	end

	self:SetNextPrimaryFire(CurTime() + .35)
	self:SetNextSecondaryFire(CurTime() + .35)
end

function SWEP:AttackFront()
	if CLIENT then return end
	self.Owner:LagCompensation(true)
	local Ent, HitPos = JMod.WhomILookinAt(self.Owner, .3, 55)
	local AimVec = self.Owner:GetAimVector()

	if IsValid(Ent) or (Ent and Ent.IsWorld and Ent:IsWorld()) then
		local SelfForce, Mul = 125, (JMod.GetPlayerStrength(self.Owner) or 1)

		if self:IsEntSoft(Ent) then
			SelfForce = 25

			if Ent:IsPlayer() and IsValid(Ent:GetActiveWeapon()) and Ent:GetActiveWeapon().GetBlocking and Ent:GetActiveWeapon():GetBlocking() then
				sound.Play("Flesh.ImpactSoft", HitPos, 65, math.random(90, 110))
			else
				sound.Play("Flesh.ImpactHard", HitPos, 65, math.random(90, 110))
			end
		else
			sound.Play("Flesh.ImpactSoft", HitPos, 65, math.random(90, 110))
		end

		local DamageAmt = math.random(2, 4)
		local Dam = DamageInfo()
		Dam:SetAttacker(self.Owner)
		Dam:SetInflictor(self.Weapon)
		Dam:SetDamage(DamageAmt * Mul)
		Dam:SetDamageForce(AimVec * Mul ^ 3)
		Dam:SetDamageType(DMG_CLUB)
		Dam:SetDamagePosition(HitPos)
		Ent:TakeDamageInfo(Dam)
		local Phys = Ent:GetPhysicsObject()

		if IsValid(Phys) then
			if Ent:IsPlayer() then
				Ent:SetVelocity(AimVec * SelfForce * 1.5)
			end

			Phys:ApplyForceOffset(AimVec * 5000 * Mul, HitPos)
			self.Owner:SetVelocity(-AimVec * SelfForce * .8)
		end

		if Ent:GetClass() == "func_breakable_surf" then
			if math.random(1, 20) == 10 then
				Ent:Fire("break", "", 0)
			end
		end
	end

	self.Owner:LagCompensation(false)
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end
	local Time = CurTime()
	local Alt = self.Owner:KeyDown(JMod.Config.General.AltFunctionKey)

	if not(self:GetFists()) then -- Pick up to inv
		if IsValid(self:GetCarrying()) then
			local Tar = self:GetCarrying()
			local ply = self.Owner
			
			JMod.EZ_GrabItem(ply, nil, {Tar:EntIndex()})
		else
			--[[if self.Owner:HasWeapon("wep_jack_gmod_eztoolbox") then
				local ToolBox = self.Owner:GetWeapon("wep_jack_gmod_eztoolbox")
				ToolBox:Reload()
			end--]]
		end
	end
	
	self:SetFists(false)
	self:SetBlocking(false)
	self:SetCarrying()
end

function SWEP:DrawWorldModel()
end

-- no, do nothing
function SWEP:DoBFSAnimation(anim)
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration())
end

function SWEP:IsEntSoft(ent)
	return ent:IsNPC() or ent:IsPlayer()
end

if CLIENT then
	local BlockAmt = 0

	function SWEP:GetViewModelPosition(pos, ang)
		if self:GetBlocking() then
			BlockAmt = math.Clamp(BlockAmt + FrameTime() * 1.5, 0, 1)
		else
			BlockAmt = math.Clamp(BlockAmt - FrameTime() * 1.5, 0, 1)
		end

		pos = pos - ang:Up() * 15 * BlockAmt
		ang:RotateAroundAxis(ang:Right(), BlockAmt * 60)

		return pos, ang
	end
end

-- Stop carry entity from damaging the player
hook.Add("EntityTakeDamage", "CancelDamageFromCarryEnt", function(target, dmginfo)
	if target:IsPlayer() then 
		local Weppy = target:GetActiveWeapon() 
		if IsValid(Weppy) and IsValid(Weppy.CarryEnt) then
			if (dmginfo:GetInflictor() == Weppy.CarryEnt) and (dmginfo:GetDamageType() == DMG_CRUSH) then
				return true
			end
		end
	end
end)