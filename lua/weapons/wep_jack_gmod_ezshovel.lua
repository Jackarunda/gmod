-- AdventureBoots 2023
AddCSLuaFile()
SWEP.PrintName = "EZ Shovel"
SWEP.Author = "Jackarunda"
SWEP.Purpose = ""
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_ezshovel")
SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.EZdroppable = true
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

SWEP.VElements = {
	--[[["pickaxe"] = {
		type = "Model",
		model = "models/props_mining/pickaxe01.mdl",
		bone = "ValveBiped.Bip01_R_Hand",
		rel = "",
		pos = Vector(3, 1.5, 6),
		angle = Angle(0, 180, 180),
		size = Vector(.5, .5, .5),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},--]]
	--[[["shovel"] = {
		type = "Model",
		model = "models/props_junk/shovel01a.mdl",
		bone = "ValveBiped.Bip01_L_Hand",
		rel = "",
		pos = Vector(3.5, 1, 6),
		angle = Angle(0, 180, 180),
		size = Vector(.5, .5, .5),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	}--]]
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
	},
	--[[["axe"] = {
		type = "Model",
		model = "models/props_forest/axe.mdl",
		bone = "ValveBiped.Bip01_Spine4",
		rel = "",
		pos = Vector(-7.792, 2, 4),
		angle = Angle(118.052, 87.662, 180),
		size = Vector(1, 1, 1),
		color = Color(255, 255, 255, 255),
		surpresslightning = false,
		material = "",
		skin = 0,
		bodygroup = {}
	},--]]
}

--
SWEP.HitDistance		= 64
SWEP.HitInclination		= 0.2
SWEP.HitPushback		= 2000

local SwingSound = Sound( "Weapon_Crowbar.Single" )
local HitSoundWorld = Sound( "Canister.ImpactHard" )
local HitSoundBody = Sound( "Flesh.ImpactHard" )
local PushSoundBody = Sound( "Flesh.ImpactSoft" )
--
SWEP.WhitelistedResources = {JMod.EZ_RESOURCE_TYPES.SAND, JMod.EZ_RESOURCE_TYPES.CLAY, JMod.EZ_RESOURCE_TYPES.WATER}

function SWEP:Initialize()
	self:SetHoldType("melee2")
	self:SCKInitialize()
	self.NextIdle = 0
	self:Deploy()
	self:SetTaskProgress(0)
	self:SetResourceType("")
	self.TaskEntity = nil
	self.NextTaskProgress = 0
	self.CurTask = nil
	self.CurrentBuildSize = 1
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	--vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

function SWEP:ViewModelDrawn()
	--self:SCKViewModelDrawn()
end

function SWEP:DrawWorldModel()
	self:SCKDrawWorldModel()
end

local Downness = 0

function SWEP:GetViewModelPosition(pos, ang)
	local FT = FrameTime()

	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		Downness = Lerp(FT * 2, Downness, 0)
	else
		Downness = Lerp(FT * 2, Downness, -2)
	end

	ang:RotateAroundAxis(ang:Right(), -Downness * 5)

	return pos, ang
end--]]

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 1, "TaskProgress")
	self:NetworkVar("String", 0, "ResourceType")
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self.NextIdle = CurTime() + vm:SequenceDuration()
end


function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_SPEED) then return end
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + .8)

	if (self:GetOwner():IsPlayer()) then
		self:GetOwner():LagCompensation(true)
	end

	local Hit = self:Hitscan()
	self:Pawnch(Hit)

	if (self:GetOwner():IsPlayer()) then
		self:GetOwner():LagCompensation(false)
	end

	--sound.Play("weapon/crowbar/crowbar_swing1.ogg", self:GetPos(), 75, 100, 1)
	timer.Simple(0.1, function()
		if IsValid(self) then
			self:EmitSound( SwingSound )
		end
	end)
end

local DirtTypes = {
	MAT_DIRT,
	MAT_SAND
}

function SWEP:Hitscan()
	if not SERVER then return end
	--This function calculate the trajectory
	local HitSomething = false 
	
	for i = 0, 170 do
		timer.Simple(i * (0.45/170), function() 
			if not(IsValid(self)) or not(IsValid(self.Owner)) or HitSomething or HitSomething or (i % 5 ~= 0) then return end

			local tr = util.TraceLine( {
				start = (self.Owner:GetShootPos() - (self.Owner:EyeAngles():Up() * 10)),
				endpos = (self.Owner:GetShootPos() - (self.Owner:EyeAngles():Up() * 10)) + ( self.Owner:EyeAngles():Up() * ( self.HitDistance * 0.7 * math.cos(math.rad(i)) ) ) + ( self.Owner:EyeAngles():Forward() * ( self.HitDistance * 1.5 * math.sin(math.rad(i)) ) ) + ( self.Owner:EyeAngles():Right() * self.HitInclination * self.HitDistance * math.cos(math.rad(i)) ),
				filter = self.Owner,
				mask = MASK_SHOT_HULL
			} )
			debugoverlay.Line(tr.StartPos, tr.HitPos, 2, Color(255, 38, 0), false)

			if (tr.Hit) then
				debugoverlay.Cross(tr.HitPos, 10, 2, Color(255, 38, 0), true)
				local StrikeVector = ( self.Owner:EyeAngles():Up() * ( self.HitDistance * 0.5 * math.cos(math.rad(i)) ) ) + ( self.Owner:EyeAngles():Forward() * ( self.HitDistance * 1.5 * math.sin(math.rad(i)) ) ) + ( self.Owner:EyeAngles():Right() * self.HitInclination * self.HitDistance * math.cos(math.rad(i)) )
				local StrikePos = (self.Owner:GetShootPos() - (self.Owner:EyeAngles():Up() * 15))
				HitSomething = true 

				if IsValid(tr.Entity) then
					local PickDam = DamageInfo()
					PickDam:SetAttacker(self.Owner)
					PickDam:SetInflictor(self)
					PickDam:SetDamagePosition(StrikePos)
					PickDam:SetDamageType(DMG_GENERIC)
					PickDam:SetDamage(math.random(30, 50))
					PickDam:SetDamageForce(StrikeVector:GetNormalized() * 30)
					tr.Entity:TakeDamageInfo(PickDam)
				end

				sound.Play(util.GetSurfaceData(tr.SurfaceProps).impactHardSound, tr.HitPos, 75, 100, 1)

				if tr.Entity:IsPlayer() or tr.Entity:IsNPC() or string.find(tr.Entity:GetClass(),"prop_ragdoll") then
					sound.Play(HitSoundBody, tr.HitPos, 75, 100, 1)
					tr.Entity:SetVelocity( self.Owner:GetAimVector() * Vector( 1, 1, 0 ) * self.HitPushback )
					self:SetTaskProgress(0)
					if tr.Entity.IsEZcorpse then
						local GravePos = tr.Entity:GetPos()
						timer.Simple(0.2, function()
							--if IsValid(tr.Entity) then
								local GraveStone = ents.Create("prop_physics")
								GraveStone:SetModel("models/props_c17/gravestone002a.mdl")
								GraveStone:SetPos(GravePos)
								GraveStone:SetAngles(Angle(0, 0, 0))
								GraveStone:Spawn()
								GraveStone:Activate()
								local WeldTr = util.QuickTrace(GravePos + Vector(0, 0, 20), Vector(0, 0, -40), {GraveStone, tr.Entity, self.Owner})
								if WeldTr.Hit then
									GraveStone:SetPos(WeldTr.HitPos)
									local StoneAng = WeldTr.HitNormal:Angle()
									StoneAng:RotateAroundAxis(StoneAng:Right(), -90)
									GraveStone:SetAngles(StoneAng)
									GraveStone:SetPos(GravePos + StoneAng:Up() * 25)
									constraint.Weld(WeldTr.Entity, GraveStone, 0, 0, 10000, false, false)
								end
							--end
						end)
						SafeRemoveEntityDelayed(tr.Entity, 0.1)
					end
				elseif tr.Entity:IsWorld() and (table.HasValue(DirtTypes, util.GetSurfaceData(tr.SurfaceProps).material)) then
					local Message = JMod.EZprogressTask(self, tr.HitPos, self.Owner, "mining", JMod.GetPlayerStrength(self.Owner) ^ .25)

					if Message then
						if (tr.MatType == MAT_SAND) or (tr.MatType == MAT_DIRT) then
							self:SetResourceType(JMod.EZ_RESOURCE_TYPES.SAND)
							self:SetTaskProgress(100)
							JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.SAND, math.random(5, 10), self:WorldToLocal(tr.HitPos + Vector(0, 0, 8)), Angle(0, 0, 0), nil, 200)
						else
							self:Msg(Message)
							self:SetTaskProgress(0)
							self:SetResourceType("")
						end
					else
						sound.Play("Dirt.Impact", tr.HitPos + VectorRand(), 75, math.random(50, 70))
						self:SetTaskProgress(self:GetNW2Float("EZminingProgress", 0))
					end

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
				end
			end
		end)
	end
end

function SWEP:Msg(msg)
	self.Owner:PrintMessage(HUD_PRINTCENTER, msg)
end

function SWEP:Pawnch(hit)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence("misscenter1"))
	self:UpdateNextIdle()
end

function SWEP:Reload()
	--
end

function SWEP:WhomIlookinAt()
	local Filter = {self.Owner}

	for k, v in pairs(ents.FindByClass("npc_bullseye")) do
		table.insert(Filter, v)
	end

	local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 100 * math.Clamp(self.CurrentBuildSize, .5, 100), Filter)

	return Tr.Entity, Tr.HitPos, Tr.HitNormal
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + .8)
	self:SetNextSecondaryFire(CurTime() + .8)

	--self:EmitSound( SwingSound )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( vm:LookupSequence( "pushback" ) )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 1.5 * 40,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if ( tr.Hit ) then
		local PushVector = self.Owner:GetAimVector() * 1000
		self:EmitSound( PushSoundBody )
		if tr.Entity:IsPlayer() or string.find(tr.Entity:GetClass(),"npc") or string.find(tr.Entity:GetClass(),"prop_ragdoll") or string.find(tr.Entity:GetClass(),"prop_physics") then
			tr.Entity:SetVelocity(PushVector * Vector( 1, 1, 0 ))
		elseif IsValid(tr.Entity) and IsValid(tr.Entity:GetPhysicsObject()) then
			tr.Entity:GetPhysicsObject():ApplyForceOffset(PushVector, tr.HitPos)
		end
		self.Owner:SetVelocity( -PushVector * .25 * Vector( 1, 1, 0 ))
		self.Owner:SetAnimation(PLAYER_RELOAD)
	end
	self:UpdateNextIdle()
end

--
function SWEP:OnDrop()
	local Pick = ents.Create("ent_jack_gmod_ezshovel")
	Pick:SetPos(self:GetPos())
	Pick:SetAngles(self:GetAngles())
	Pick:Spawn()
	Pick:Activate()

	local Phys = Pick:GetPhysicsObject()

	if Phys then
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() / 2)
	end

	self:Remove()
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
	end

	self:SetNextPrimaryFire(CurTime() + .7)
	self:SetNextSecondaryFire(CurTime() + .7)

	return true
end

function SWEP:Think()
	local Time = CurTime()
	local vm = self.Owner:GetViewModel()
	local idletime = self.NextIdle

	if idletime > 0 and Time > idletime then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("idle0"))
		self:UpdateNextIdle()
	end

	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		self:SetHoldType("normal")
	else
		self:SetHoldType("melee2")

		if self.Owner:KeyDown(IN_ATTACK2) then
			if self.NextTaskProgress < Time then
				self.NextTaskProgress = Time + .8
				local Alt = self.Owner:KeyDown(JMod.Config.General.AltFunctionKey)
				local Task = "mining"
				local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 100, {self.Owner})
				local Ent, Pos = Tr.Entity, Tr.HitPos
			end
		elseif not self.Owner:KeyDown(IN_ATTACK) then
			self:SetTaskProgress(0)
		end
	end
end

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
