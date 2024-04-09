-- Jackarunda 2021
AddCSLuaFile()
SWEP.PrintName = "EZ Flamethrower"
SWEP.Author = "Jackarunda, AdventureBoots"
SWEP.Purpose = ""
JMod.SetWepSelectIcon(SWEP, "entities/ent_jack_gmod_eztoolbox")
SWEP.Spawnable = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.EZdroppable = false -- If this is to be attached to an armor piece
SWEP.ViewModel = "models/weapons/sanic/c_m2.mdl"
SWEP.WorldModel = "models/weapons/sanic/w_m2f2.mdl"
SWEP.BodyHolsterModel = "models/weapons/w_models/w_tooljox.mdl"
SWEP.BodyHolsterSlot = "hips"
SWEP.BodyHolsterAng = Angle(-70, 0, 200)
SWEP.BodyHolsterAngL = Angle(-70, -10, -30)
SWEP.BodyHolsterPos = Vector(0, -15, 10)
SWEP.BodyHolsterPosL = Vector(0, -15, -11)
SWEP.BodyHolsterScale = .4
SWEP.ViewModelFOV = 52
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
SWEP.ShowWorldModel = true

SWEP.EZaccepts = {JMod.EZ_RESOURCE_TYPES.FUEL, JMod.EZ_RESOURCE_TYPES.GAS}
SWEP.MaxFuel = 100
SWEP.MaxGas = 100

SWEP.VElements = {
	--
}

SWEP.WElements = {
	--
}

SWEP.LastSalvageAttempt = 0
SWEP.NextSwitch = 0

SWEP.NextIgnite = 0
SWEP.Ignitin = false
SWEP.Flamin = false
SWEP.NextIgniteTry = 0

function SWEP:Initialize()
	self:SetHoldType("smg")
	self:SCKInitialize()
	self.NextIdle = 0
	self.NextSparkTime = 0
	self:Deploy()

	self:SetGas(0)
	self:SetFuel(0)
end

function SWEP:PreDrawViewModel(vm, wep, ply)
	--vm:SetMaterial("engine/occlusionproxy") -- Hide that view model with hacky material
end

local GlowSprite = Material("mat_jack_gmod_glowsprite")

function SWEP:ViewModelDrawn()
	self:SCKViewModelDrawn()
	if (self:GetIsFlamin()) then
		render.SetMaterial(GlowSprite)
		local Dir = self.Owner:GetAimVector()
		local Pos = self.Owner:GetShootPos() + self.Owner:GetRight() * 18 - self.Owner:GetUp() * 18
		for i = 1, 10 do
			local Inv = 10 - i
			render.DrawSprite(Pos + Dir * (i * 20 + math.random(100, 130)), 4 * Inv, 4 * Inv, Color(255, 150, 100, 255))
		end
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.pos = Pos + Dir * 50
			dlight.r = 255
			dlight.g = 150
			dlight.b = 100
			dlight.brightness = 4
			dlight.Decay = 200
			dlight.Size = 400
			dlight.DieTime = CurTime() + .5
		end
	end
end

function SWEP:DrawWorldModel()
	self:SCKDrawWorldModel()
	if (self:GetIsFlamin()) then
		render.SetMaterial(GlowSprite)
		local Dir = self.Owner:GetAimVector()
		--local Pos = self.Owner:GetShootPos() + self.Owner:GetRight() * 10 - self.Owner:GetUp() * 17 - Dir * 60
		local Pos = self:GetAttachment(1).Pos
		for i = 1, 20 do
			local Inv = 20 - i
			render.DrawSprite(Pos + Dir * (i * 2 + math.random(0, 30)), 1 * Inv, 1 * Inv, Color(255, 150, 100, 255))
		end
		local dlight = DynamicLight(self:EntIndex())
		if dlight then
			dlight.pos = Pos + Dir * 1
			dlight.r = 255
			dlight.g = 150
			dlight.b = 100
			dlight.brightness = 4
			dlight.Decay = 200
			dlight.Size = 400
			dlight.DieTime = CurTime() + .5
		end
	end
end

local Downness = 0
local Backness = 0

function SWEP:GetViewModelPosition(pos, ang)
	local FT = FrameTime()

	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		Downness = Lerp(FT * 2, Downness, 10)
	else
		Downness = Lerp(FT * 2, Downness, 0)
	end

	local Flamin = self:GetIsFlamin()

	if (Flamin) then
		Backness = Lerp(FT * 2, Backness, 10)
	else
		Backness = Lerp(FT * 2, Backness, 0)
	end

	ang:RotateAroundAxis(ang:Right(), -Downness * 5)
	pos = pos - ang:Forward() * Backness
	if (Flamin) then pos = pos + VectorRand() * .1 end

	return pos, ang
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Fuel")
	self:NetworkVar("Int", 1, "Gas")
	self:NetworkVar("Bool", 0, "IsFlamin")
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self.NextIdle = CurTime() + vm:SequenceDuration()
end

function SWEP:GetEZsupplies(resourceType)
	local AvaliableResources = {
		[JMod.EZ_RESOURCE_TYPES.FUEL] = self:GetFuel(),
		[JMod.EZ_RESOURCE_TYPES.GAS] = self:GetGas()
	}
	if resourceType then
		if AvaliableResources[resourceType] and AvaliableResources[resourceType] > 0 then
			return AvaliableResources[resourceType]
		else
			return nil
		end
	else
		return AvaliableResources
	end
end

function SWEP:SetEZsupplies(typ, amt, setter)
	if not SERVER then  return end
	local ResourceSetMethod = self["Set"..JMod.EZ_RESOURCE_TYPE_METHODS[typ]]
	if ResourceSetMethod then
		ResourceSetMethod(self, amt)
	end
	if self.Owner.EZarmor and self.Owner.EZarmor.items[self.EZarmorID] then
		local ArmorItem = self.Owner.EZarmor.items[self.EZarmorID]
		if ArmorItem.chrg and ArmorItem.chrg[typ] then
			ArmorItem.chrg[typ] = amt
		end
	end
end

function SWEP:Cease()
	self.Flamin = false
	self.Throwin = false
	self:SetIsFlamin(false)
	if (self.SoundLoop) then self.SoundLoop:Stop() end
end

function SWEP:GetNozzle()
	local AimVec = self.Owner:GetAimVector()
	local FireAng = (AimVec + VectorRand(0, .1)):GetNormalized():Angle()
	local FirePos = self.Owner:GetShootPos() + self.Owner:GetVelocity() * 0.1 + (FireAng:Forward() * 15 + FireAng:Right() * 4 + FireAng:Up() * -4)
	
	return FirePos, FireAng, AimVec
end

function SWEP:PrimaryAttack()
	local Time = CurTime()
	self:Pawnch()
	self:SetNextPrimaryFire(Time + .05)

	if SERVER then
		local Fuel, Gas = self:GetFuel(), self:GetGas()
		if (Fuel > 0) and (Gas > 0) then

			self.Owner:ViewPunch(AngleRand() * .002)

			if not(self.Throwin) then
				if self.SoundLoop then self.SoundLoop:Stop() end
				self.SoundLoop = CreateSound(self, "ambient/gas/cannister_loop.wav")
				self.SoundLoop:SetSoundLevel(75)
				self.SoundLoop:Play()
			end
			self.Throwin = true

			if self.Ignitin and not(self.Flamin) then
				if (self.NextIgnite < Time) then
					if self.SoundLoop then self.SoundLoop:Stop() end
					self.SoundLoop = CreateSound(self, "snds_jack_gmod/flamethrower_loop.wav")
					self.SoundLoop:SetSoundLevel(75)
					self.SoundLoop:Play()
					self.Ignitin = false
					self.Flamin = true
					self:SetIsFlamin(true)
				end
			end
			
			local FirePos, FireAng, AimVec = self:GetNozzle()
			if self.Flamin then
				self.Owner:MuzzleFlash()
				local Foof = EffectData()
				Foof:SetNormal(FireAng:Forward())
				Foof:SetScale(2)
				Foof:SetStart(FireAng:Forward() * 1200)
				Foof:SetEntity(self)
				Foof:SetAttachment(1)
				util.Effect("eff_jack_gmod_ezflamethrowerfire", Foof, true, true)
				--
			else
				local Foof = EffectData()
				Foof:SetOrigin(FirePos)
				Foof:SetScale(1)
				Foof:SetStart(FireAng:Forward() * 3)
				util.Effect("eff_jack_gmod_spranklerspray", Foof, true, true)
			end

			if (math.Rand(0, 1) > .3) then
				local FlameTr = util.QuickTrace(FirePos, FireAng:Forward() * 200, self.Owner)
				FirePos = FlameTr.HitPos
				local Flame = ents.Create("ent_jack_gmod_eznapalm")
				Flame:SetPos(FirePos)
				local FlyAng = (FireAng:Forward() + VectorRand() * .1):Angle()
				Flame:SetAngles(FlyAng)
				Flame:SetOwner(JMod.GetEZowner(self))
				Flame.HighVisuals = (math.random(1, 2) == 1)
				Flame.SpeedMul = math.Rand(.9, 1.1)
				Flame.Creator = self.Owner
				Flame.Burnin = self.Flamin
				JMod.SetEZowner(Flame, self.Owner)
				Flame:Spawn()
				Flame:Activate()
				--self:SetEZsupplies(JMod.EZ_RESOURCE_TYPES.FUEL, math.Clamp(Fuel - 1, 0, 100))
				--self:SetEZsupplies(JMod.EZ_RESOURCE_TYPES.GAS, math.Clamp(Gas - 1, 0, 100))
			end
		else
			self:Cease()
		end
	end
end

function SWEP:SecondaryAttack()
	local Time = CurTime()
	if (self.Owner:KeyDown(IN_SPEED) or self.Owner:KeyDown(IN_RELOAD)) then self.Ignitin = false return end
	if self.Flamin then 
		self.Ignitin = false
		self.NextIgnite = Time + 1

		return 
	end
	self:SetNextSecondaryFire(CurTime() + .05)
	
	if SERVER then
		local Fuel, Gas = self:GetFuel(), self:GetGas()
		if (Fuel > 0) and (Gas > 0) then
			if (self.NextIgniteTry < Time) then
				self.NextIgniteTry = Time + 1
				if not self.Ignitin then
					self.Ignitin = true
					if self.SoundLoop then self.SoundLoop:Stop() end
					self.SoundLoop = CreateSound(self, "snds_jack_gmod/flareburn.wav")
					self.SoundLoop:SetSoundLevel(75)
					self.SoundLoop:Play()
				end
			end
		end
	end
end

function SWEP:Msg(msg)
	self.Owner:PrintMessage(HUD_PRINTCENTER, msg)
end

function SWEP:Pawnch()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:UpdateNextIdle()
end

function SWEP:Reload()
	if SERVER then
		local Time = CurTime()
		local Ent = self:WhomIlookinAt()
		
		if IsValid(Ent) and Ent.GetEZsupplies then
			for typ, amt in pairs(Ent:GetEZsupplies()) do
				if table.HasValue(self.EZaccepts, typ) and (amt > 0) then
					local CurAmt = self:GetEZsupplies(typ) or 0
					local Take = math.min(amt, 100 - CurAmt)
					
					if Take > 0 then
						Ent:SetEZsupplies(typ, amt - Take, self.Owner)
						self:SetEZsupplies(typ, CurAmt + Take)
						sound.Play("items/ammo_pickup.wav", self:GetPos(), 65, math.random(90, 110))
						JMod.ResourceEffect(typ, Ent:LocalToWorld(Ent:OBBCenter()), self:GetPos(), amt, 1, 1, 2)
					end
				end
			end
		end
	end
end

function SWEP:WhomIlookinAt()
	local Filter = {self.Owner}

	for k, v in pairs(ents.FindByClass("npc_bullseye")) do
		table.insert(Filter, v)
	end

	local Tr = util.QuickTrace(self.Owner:GetShootPos(), self.Owner:GetAimVector() * 100, Filter)

	return Tr.Entity, Tr.HitPos, Tr.HitNormal
end

--
function SWEP:OnDrop()
	--[[local Pack = ents.Create("ent_jack_gmod_ezflamethrower")
	Pack:SetPos(self:GetPos())
	Pack:SetAngles(self:GetAngles())
	Pack:Spawn()
	Pack:Activate()

	Pack:SetFuel(self:GetFuel())
	Pack:SetGas(self:GetGas())

	local Phys = Pack:GetPhysicsObject()

	if Phys then
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity() / 2)
	end--]]

	if IsValid(self.Owner) then
		if self.Owner.EZarmor and self.Owner.EZarmor.items[self.EZarmorID] then
			--JMod.RemoveArmorByID(self.Owner, self.EZarmorID)
		end
	end

	self:Remove()
end

function SWEP:OnRemove()
	self:SCKHolster()

	self:Cease()

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

	self:Cease()

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
		Downness = 10
		self:UpdateNextIdle()
		self:EmitSound("snds_jack_gmod/toolbox" .. math.random(1, 7) .. ".wav", 65, math.random(90, 110))
	end

	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)

	return true
end

function SWEP:Think()
	local Time = CurTime()
	local idletime = self.NextIdle

	if idletime > 0 and Time > idletime then
		self:UpdateNextIdle()
	end

	if (self.Owner:KeyDown(IN_SPEED) or self.Owner:KeyDown(IN_RELOAD)) then 
		self:Cease() 
		self.NextIgnite = Time + 1 
	end

	if not(self.Owner:KeyDown(IN_ATTACK)) then
		self.Throwin = false
		self.Flamin = false
		self:SetIsFlamin(false)
	end

	if not(self.Owner:KeyDown(IN_ATTACK2)) then
		self.Ignitin = false
		self.NextIgnite = Time + 1
	end

	if not(self.Throwin) and not(self.Ignitin) then
		self:Cease()
	end

	if self.NextSparkTime < Time then
		self.NextSparkTime = Time + 0.1
		if self.Ignitin then
			local FirePos, FireAng, AimVec = self:GetNozzle()
			local Fsh = EffectData()
			Fsh:SetOrigin(FirePos)
			Fsh:SetScale(.5)
			Fsh:SetNormal(AimVec)
			Fsh:SetStart(self.Owner:GetVelocity())
			Fsh:SetEntity(self)
			Fsh:SetAttachment(1)
			util.Effect("eff_jack_gmod_flareburn", Fsh, true, true)
		end
	end
	
	if (self.Owner:KeyDown(IN_SPEED)) or (self.Owner:KeyDown(IN_ZOOM)) then
		self:SetHoldType("normal")
		self:Cease()
	else
		self:SetHoldType("smg")
	end

	if SERVER then
		if self.Owner.EZarmor and self.Owner.EZarmor.items[self.EZarmorID] then
			local ArmorItem = self.Owner.EZarmor.items[self.EZarmorID]
			self:SetFuel(ArmorItem.chrg.fuel)
			self:SetGas(ArmorItem.chrg.gas)
		end
	end
end

function SWEP:DrawHUD()
	if GetConVar("cl_drawhud"):GetBool() == false then return end
	local Ply = self.Owner
	if Ply:ShouldDrawLocalPlayer() then return end
	local W, H = ScrW(), ScrH()

	draw.SimpleTextOutlined("Fuel: "..math.floor(self:GetFuel()), "Trebuchet24", W * .1, H * .5, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
	draw.SimpleTextOutlined("Gas: "..math.floor(self:GetGas()), "Trebuchet24", W * .1, H * .5 + 30, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, 50))
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
