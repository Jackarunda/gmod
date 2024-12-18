-- Jackarunda 2021 - AdventureBoots 2024
AddCSLuaFile()
SWEP.PrintName = "EZ Melee Base"
SWEP.Author = "AdventureBoots"
SWEP.Purpose = ""
--JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezaxe")
SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.EZdroppable = true
SWEP.ViewModel = ""
SWEP.WorldModel = ""
SWEP.BodyHolsterModel = ""
SWEP.ViewModelFOV = 50
SWEP.Slot = 0
SWEP.SlotPos = 5
SWEP.InstantPickup = true -- Fort Fights compatibility
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ShowWorldModel = false
SWEP.ShowViewModel = true

--
SWEP.VElements = {}

SWEP.WElements = {}

SWEP.DropEnt = ""
--
SWEP.HitDistance		= 50
SWEP.HitInclination		= 0.4
SWEP.HitSpace 			= 0
SWEP.HitAngle 			= 45
SWEP.HitPushback		= 2000
SWEP.StartSwingAngle 	= 0
SWEP.MaxSwingAngle		= 120
SWEP.SwingSpeed 		= 1
SWEP.SwingPullback 		= 0
SWEP.SwingOffset 		= Vector(12, 15, -5)
SWEP.PrimaryAttackSpeed = 1
SWEP.SecondaryAttackSpeed 	= 1
SWEP.DoorBreachPower 	= 1
--
SWEP.SprintCancel 	= true
SWEP.StrongSwing 	= false
SWEP.SecondaryPush	= true
--
SWEP.SwingSound 	= Sound( "Weapon_Crowbar.Single" )
SWEP.HitSoundWorld 	= Sound( "SolidMetal.ImpactHard" )
SWEP.HitSoundBody 	= Sound( "Flesh.ImpactHard" )
SWEP.PushSoundBody 	= Sound( "Flesh.ImpactSoft" )
--
SWEP.IdleHoldType 	= "melee2"
SWEP.SprintHoldType = "melee2"
SWEP.SwingSeq = "misscenter1"
SWEP.SwingVisualLowerAmount = -1
--

function SWEP:Initialize()
	self:SetHoldType(self.IdleHoldType)
	self:SCKInitialize()
	self.NextIdle = 0
	self.DistanceCompensation = 0
	self:Deploy()
	if self.CustomInit then
		self:CustomInit()
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Swinging")
	if self.CustomSetupDataTables then
		self:CustomSetupDataTables()
	end
end

function SWEP:Swing(secondary)
	local Owner = self:GetOwner()
	if self.SprintCancel and Owner:KeyDown(IN_SPEED) then return end
	if self:GetSwinging() then return end

	local Tr = util.QuickTrace(Owner:GetShootPos(), Owner:GetAimVector() * self.HitDistance, Owner)

	if Tr.Hit then
		--self.DistanceCompensation = math.min(Tr.Fraction, .3) * self.HitDistance
	else
		self.DistanceCompensation = 0
	end

	if secondary then
		self:SetNextPrimaryFire(CurTime() + self.SecondaryAttackSpeed)
		self:SetNextSecondaryFire(CurTime() + self.SecondaryAttackSpeed)
	else
		self:SetNextPrimaryFire(CurTime() + self.PrimaryAttackSpeed)
		self:SetNextSecondaryFire(CurTime() + self.PrimaryAttackSpeed)
	end
	
	local IsPlaya = Owner:IsPlayer()
	if (IsPlaya) then
		Owner:LagCompensation(true)
	end

	local SwingSound = self.SwingSound
	if SwingSound then
		if istable(SwingSound) then
			SwingSound = SwingSound[math.random(#SwingSound)]
		end
		self:EmitSound(SwingSound)
	end
	self:Pawnch()
	self:SetSwinging(true)
	self.WasSecondarySwing = secondary
	self.SwingProgress = -self.SwingPullback

	if (IsPlaya) then
		Owner:LagCompensation(false)
	end
end

function SWEP:PrimaryAttack()
	self:Swing(false)
end

function SWEP:SecondaryAttack()
	local Owner = self:GetOwner()

	if self.SecondaryPush then
		self:SetNextPrimaryFire(CurTime() + self.SecondaryAttackSpeed)
		self:SetNextSecondaryFire(CurTime() + self.SecondaryAttackSpeed)

		local vm = Owner:GetViewModel()
		vm:SendViewModelMatchingSequence(vm:LookupSequence( "pushback" ))

		local tr = util.TraceLine( {
			start = Owner:GetShootPos(),
			endpos = Owner:GetShootPos() + Owner:GetAimVector() * 1.5 * 40,
			filter = Owner,
			mask = MASK_SHOT_HULL
		} )

		if ( tr.Hit ) then
			local PushVector = Owner:GetAimVector() * 1000
			if tr.Entity:IsPlayer() or string.find(tr.Entity:GetClass(),"npc") or string.find(tr.Entity:GetClass(),"prop_ragdoll") or string.find(tr.Entity:GetClass(),"prop_physics") then
				tr.Entity:SetVelocity(PushVector * Vector( 1, 1, 0 ))
			elseif IsValid(tr.Entity) and IsValid(tr.Entity:GetPhysicsObject()) then
				tr.Entity:GetPhysicsObject():ApplyForceOffset(PushVector, tr.HitPos)
			end
			Owner:SetVelocity( -PushVector * .25 * Vector( 1, 1, 0 ))
			Owner:SetAnimation(PLAYER_RELOAD)

			local PushSound = self.PushSoundBody
			if istable(PushSound) then
				PushSound = PushSound[math.random(#PushSound)]
			end
			self:EmitSound(PushSound)
		end
	else
		self:Swing(true)
	end
	self:UpdateNextIdle()
end

function SWEP:Pawnch()
	if not IsFirstTimePredicted() then return end
	local Owner = self:GetOwner()
	Owner:SetAnimation(PLAYER_ATTACK1)
	local vm = Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(self.SwingSeq))
	--Owner:ViewPunch(Angle(math.random(-10, -5), math.random(-5, 0), 0))
	self:UpdateNextIdle()
end

function SWEP:Think()
	local Time = CurTime()
	local vm = self.Owner:GetViewModel()
	local idletime = self.NextIdle
	local Swing = self:GetSwinging()
	local Owner = self:GetOwner()

	if idletime > 0 and Time > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("idle0"))
		self:UpdateNextIdle()
	end

	if self.CustomThink then
		self:CustomThink()
	end

	if (self.SprintCancel and not self.StrongSwing) and (Owner:KeyDown(IN_SPEED)) or (Owner:KeyDown(IN_ZOOM)) then
		self.SwingProgress = 0
		self:SetSwinging(false)
		self:SetHoldType(self.SprintHoldType)
	else
		self:SetHoldType(self.IdleHoldType)
		if Swing and IsFirstTimePredicted() then
			if self.SwingProgress < self.MaxSwingAngle then
				self.SwingProgress = self.SwingProgress + (self.MaxSwingAngle * self.SwingSpeed * 0.05)

				if SERVER and self.SwingProgress >= 0 then
					local p = self.SwingProgress
					local SwingCos = math.cos(math.rad(p))
					local SwingSin = math.sin(math.rad(p))

					local SwingPos = Owner:GetShootPos()
					local SwingAng = Owner:EyeAngles()
					SwingAng:RotateAroundAxis(SwingAng:Forward(), self.HitAngle)
					SwingAng:RotateAroundAxis(SwingAng:Right(), math.deg(SwingCos))
					SwingAng:RotateAroundAxis(SwingAng:Up(), 8)

					local SwingUp, SwingForward, SwingRight = SwingAng:Up(), SwingAng:Forward(), SwingAng:Right()
					
					local Offset = SwingRight * self.SwingOffset.x + SwingForward * SwingSin * self.SwingOffset.y + SwingUp * self.SwingOffset.z
					local StartPos = (SwingPos + Offset) + SwingForward * -self.DistanceCompensation
					local EndVector = SwingForward * self.HitDistance + SwingRight * -self.HitInclination + SwingUp * self.HitSpace - SwingUp * self.StartSwingAngle
					
					local tr = util.TraceLine( {
						start = StartPos,
						endpos = StartPos + EndVector,
						filter = Owner,
						mask = MASK_SHOT_HULL
					})

					debugoverlay.Line(tr.StartPos, tr.HitPos, 2, Color(255, 38, 0), false)

					if ( tr.Hit ) then
						self:SetSwinging(false)
						debugoverlay.Cross(tr.HitPos, 10, 2, Color(255, 38, 0), true)

						if self.FinishSwing then
							self:FinishSwing(self.SwingProgress)
						end

						if self.OnHit then
							self:OnHit(p, tr, self.WasSecondarySwing)
						end

						if tr.Entity:IsPlayer() or string.find(tr.Entity:GetClass(), "npc") then
							local BodySound = self.HitSoundBody
							if BodySound then
								if istable(BodySound) then
									BodySound = BodySound[math.random(#BodySound)]
								end
								sound.Play(BodySound, tr.HitPos, 10, math.random(75, 100), 1)
							end
							tr.Entity:SetVelocity( self.Owner:GetAimVector() * Vector( 1, 1, 0 ) * self.HitPushback )
							--
							if self.SetTaskProgress then self:SetTaskProgress(0) end
							--
							local vPoint = (tr.HitPos)
							local effectdata = EffectData()
							effectdata:SetOrigin( vPoint )
							util.Effect( "BloodImpact", effectdata )
							--
						else
							local WorldSound = self.HitSoundWorld
							if WorldSound then
								if istable(WorldSound) then
									WorldSound = WorldSound[math.random(#WorldSound)]
								end
								sound.Play(WorldSound, tr.HitPos, 10, math.random(75, 100), 1)
							end
						end
						
						local Surface = util.GetSurfaceData(tr.SurfaceProps)
						if Surface and (Surface.impactHardSound) then
							sound.Play(Surface.impactHardSound, tr.HitPos, 75, 100, 1)
						end
					end
				end
			else
				if self.FinishSwing then
					self:FinishSwing(self.SwingProgress)
				end
				self:SetSwinging(false)
				self.SwingProgress = 0
			end
		elseif IsFirstTimePredicted() then
			self.SwingProgress = 0
		end
	end
end

function SWEP:TryBustDoor(ent, dmg, pos)
	if not self.DoorBreachPower then return end
	self.NextDoorShot = self.NextDoorShot or 0
	if self.NextDoorShot > CurTime() then return end
	local ArccWDoorBust = GetConVar("arccw_doorbust")
	if (ArccWDoorBust and ArccWDoorBust:GetInt() == 0) or not(IsValid(ent)) or not(JMod.IsDoor(ent)) then return end
	if ent:GetNoDraw() or ent.ArcCW_NoBust or ent.ArcCW_DoorBusted then return end
	if ent:GetPos():Distance(self:GetPos()) > 150 then return end -- ugh, arctic, lol
	self.NextDoorShot = CurTime() + .05 -- we only want this to run once per shot
	-- Magic number: 119.506 is the size of door01_left
	-- The bigger the door is, the harder it is to bust
	local threshold = ((ArccWDoorBust and GetConVar("arccw_doorbust_threshold"):GetInt()) or 1) * math.pow((ent:OBBMaxs() - ent:OBBMins()):Length() / 119.506, 2)
	JMod.Hint(self.Owner, "shotgun breach")
	local WorkSpread = JMod.CalcWorkSpreadMult(ent, pos) ^ 1.1
	local Amt = dmg * self.DoorBreachPower * WorkSpread
	ent.ArcCW_BustDamage = (ent.ArcCW_BustDamage or 0) + Amt
	if ent.ArcCW_BustDamage > threshold then
		JMod.BlastThatDoor(ent, (ent:LocalToWorld(ent:OBBCenter()) - self:GetPos()):GetNormalized() * 100)
		ent.ArcCW_BustDamage = nil

		-- Double doors are usually linked to the same areaportal. We must destroy the second half of the double door no matter what
		for _, otherDoor in pairs(ents.FindInSphere(ent:GetPos(), 64)) do
			if ent ~= otherDoor and otherDoor:GetClass() == ent:GetClass() and not otherDoor:GetNoDraw() then
				JMod.BlastThatDoor(otherDoor, (ent:LocalToWorld(ent:OBBCenter()) - self:GetPos()):GetNormalized() * 100)
				otherDoor.ArcCW_BustDamage = nil
				break
			end
		end
	end
end

function SWEP:Msg(msg)
	self.Owner:PrintMessage(HUD_PRINTCENTER, msg)
end

function SWEP:UpdateNextIdle()
	local vm = self:GetOwner():GetViewModel()
	self.NextIdle = CurTime() + vm:SequenceDuration()
end

function SWEP:Reload()
	--
end

--
function SWEP:OnDrop()
	local Ent = ents.Create(self.DropEnt)
	Ent:SetPos(self:GetPos())
	Ent:SetAngles(self:GetAngles())
	Ent:Spawn()
	Ent:Activate()

	local Phys = Ent:GetPhysicsObject()

	if Phys then
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() / 2)
	end

	self:Remove()
end

function SWEP:Holster(wep)
	-- Not calling OnRemove to keep the models
	self:SCKHolster()

	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end

	return true
end

function SWEP:Deploy()
	if not IsValid(self.Owner) then return end
	local vm = self.Owner:GetViewModel()

	if IsValid(vm) and vm.LookupSequence then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("draw"))
		self:UpdateNextIdle()
		--self:EmitSound("snds_jack_gmod/toolbox" .. math.random(1, 7) .. ".ogg", 65, math.random(90, 110))
		local Delay = vm:SequenceDuration(vm:LookupSequence("draw"))
		self:SetNextPrimaryFire(CurTime() + Delay)
		self:SetNextSecondaryFire(CurTime() + Delay)
	end

	return true
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	if not self.ShowViewModel then
		vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
	end
end

function SWEP:ViewModelDrawn()
	self:SCKViewModelDrawn()
end

function SWEP:DrawWorldModel()
	self:SCKDrawWorldModel()
end

local Downness = 0

function SWEP:GetViewModelPosition(pos, ang)
	local FT = FrameTime()

	if (self.SprintCancel and self.Owner:KeyDown(IN_SPEED)) or self.Owner:KeyDown(IN_ZOOM) then
		Downness = Lerp(FT * 2, Downness, 5)
	elseif (self:GetSwinging()) then
		Downness = Lerp(FT * 2, Downness, self.SwingVisualLowerAmount)
	else
		Downness = Lerp(FT * 2, Downness, -2)
	end

	ang:RotateAroundAxis(ang:Right(), -Downness * 5)

	return pos, ang
end--]]

function SWEP:DrawHUD()
	if GetConVar("cl_drawhud"):GetBool() == false then return end
	local Ply = self.Owner
	if Ply:ShouldDrawLocalPlayer() then return end
end

function SWEP:OnRemove()
	self:SCKHolster()

	if IsValid(self.Owner) and CLIENT and self.Owner:IsPlayer() then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			vm:SetMaterial("")
		end
	end

	-- ADDED :
	if CLIENT then
		-- Removes V Models
		for k, v in pairs(self.VElements) do
			local model = v.modelEnt

			if v.type == "Model" and IsValid(model) then
				model:Remove()
			end
		end

		-- Removes W Models
		for k, v in pairs(self.WElements) do
			local model = v.modelEnt

			if v.type == "Model" and IsValid(model) then
				model:Remove()
			end
		end
	end
end

----------------- sck -------------------
function SWEP:SCKHolster()
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()

		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
end

function SWEP:SCKInitialize()
	if CLIENT then
		-- Create a new table for every weapon instance
		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)
		self:CreateModels(self.VElements) -- create viewmodels
		self:CreateModels(self.WElements) -- create worldmodels

		-- init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()

			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end

			-- Init viewmodel visibility
			if self.ShowViewModel == nil or self.ShowViewModel then
				if IsValid(vm) then
					vm:SetColor(Color(255, 255, 255, 255))
				end
			else
				-- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
				vm:SetColor(Color(255, 255, 255, 1))
				-- ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
				-- however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
				vm:SetMaterial("Debug/hsv")
			end
		end
	end
end

if CLIENT then
	SWEP.vRenderOrder = nil

	function SWEP:SCKViewModelDrawn()
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		if not self.VElements then return end
		self:UpdateBonePositions(vm)

		if not self.vRenderOrder then
			-- we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if v.type == "Model" then
					table.insert(self.vRenderOrder, 1, k)
				elseif v.type == "Sprite" or v.type == "Quad" then
					table.insert(self.vRenderOrder, k)
				end
			end
		end

		for k, name in ipairs(self.vRenderOrder) do
			local v = self.VElements[name]

			if not v then
				self.vRenderOrder = nil
				break
			end

			if v.hide then continue end
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			if not v.bone then continue end
			local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)
			if not pos then continue end

			if v.type == "Model" and IsValid(model) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end

				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end

				if v.bodygroup then
					for k, v in pairs(v.bodygroup) do
						if model:GetBodygroup(k) ~= v then
							model:SetBodygroup(k, v)
						end
					end
				end

				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
			elseif v.type == "Sprite" and sprite then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	SWEP.wRenderOrder = nil

	function SWEP:SCKDrawWorldModel()
		if self.ShowWorldModel == nil or self.ShowWorldModel then
			self:DrawModel()
		end

		if not self.WElements then return end

		if not self.wRenderOrder then
			self.wRenderOrder = {}

			for k, v in pairs(self.WElements) do
				if v.type == "Model" then
					table.insert(self.wRenderOrder, 1, k)
				elseif v.type == "Sprite" or v.type == "Quad" then
					table.insert(self.wRenderOrder, k)
				end
			end
		end

		local bone_ent

		if IsValid(self.Owner) then
			bone_ent = self.Owner
		else
			-- when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs(self.wRenderOrder) do
			local v = self.WElements[name]

			if not v then
				self.wRenderOrder = nil
				break
			end

			if v.hide then continue end
			local pos, ang

			if v.bone then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end

			if not pos then continue end
			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if v.type == "Model" and IsValid(model) then
				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				model:SetAngles(ang)
				--model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)

				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end

				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end

				if v.bodygroup then
					for k, v in pairs(v.bodygroup) do
						if model:GetBodygroup(k) ~= v then
							model:SetBodygroup(k, v)
						end
					end
				end

				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
			elseif v.type == "Sprite" and sprite then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
			elseif v.type == "Quad" and v.draw_func then
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
				cam.End3D2D()
			end
		end
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		local bone, pos, ang

		if tab.rel and tab.rel ~= "" then
			local v = basetab[tab.rel]
			if not v then return end
			-- Technically, if there exists an element with the same name as a bone
			-- you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation(basetab, v, ent)
			if not pos then return end
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
		else
			bone = ent:LookupBone(bone_override or tab.bone)
			if not bone then return end
			pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
			local m = ent:GetBoneMatrix(bone)

			if m then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if IsValid(self.Owner) and self.Owner:IsPlayer() and ent == self.Owner:GetViewModel() and self.ViewModelFlip then
				ang.r = -ang.r -- Fixes mirrored models
			end
		end

		return pos, ang
	end

	function SWEP:CreateModels(tab)
		if not tab then return end

		-- Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs(tab) do
			if v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model) and string.find(v.model, ".mdl") and file.Exists(v.model, "GAME") then
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)

				if IsValid(v.modelEnt) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/" .. v.sprite .. ".vmt", "GAME") then
				local name = v.sprite .. "-"

				local params = {
					["$basetexture"] = v.sprite
				}

				-- make sure we create a unique name based on the selected options
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}

				for i, j in pairs(tocheck) do
					if v[j] then
						params["$" .. j] = 1
						name = name .. "1"
					else
						name = name .. "0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
			end
		end
	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		if self.ViewModelBoneMods then
			if not vm:GetBoneCount() then return end
			local loopthrough = self.ViewModelBoneMods

			if not hasGarryFixedBoneScalingYet then
				allbones = {}

				for i = 0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)

					if self.ViewModelBoneMods[bonename] then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1, 1, 1),
							pos = Vector(0, 0, 0),
							angle = Angle(0, 0, 0)
						}
					end
				end

				loopthrough = allbones
			end

			for k, v in pairs(loopthrough) do
				local bone = vm:LookupBone(k)
				if not bone then continue end
				local s = Vector(v.scale.x, v.scale.y, v.scale.z)
				local p = Vector(v.pos.x, v.pos.y, v.pos.z)
				local ms = Vector(1, 1, 1)

				if not hasGarryFixedBoneScalingYet then
					local cur = vm:GetBoneParent(bone)

					while cur >= 0 do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				if vm:GetManipulateBoneScale(bone) ~= s then
					vm:ManipulateBoneScale(bone, s)
				end

				if vm:GetManipulateBoneAngles(bone) ~= v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end

				if vm:GetManipulateBonePosition(bone) ~= p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
	end

	function SWEP:ResetBonePositions(vm)
		if not vm:GetBoneCount() then return end

		for i = 0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1, 1, 1))
			vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
			vm:ManipulateBonePosition(i, Vector(0, 0, 0))
		end
	end
end
