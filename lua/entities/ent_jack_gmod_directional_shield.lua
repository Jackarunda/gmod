AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Directional Shield"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Model = "models/hunter/plates/plate2x2.mdl"  -- Flat model for flat shield
ENT.Material = "models/wireframe"
ENT.PhysgunDisabled = true
ENT.ShieldSizes = {
	[1] = {width = 240, height = 240, distance = 150},
	[2] = {width = 300, height = 300, distance = 180},
	[3] = {width = 375, height = 375, distance = 220},
	[4] = {width = 468, height = 468, distance = 280},
	[5] = {width = 585, height = 585, distance = 350}
}
ENT.mmRHAe = 1000 -- for ArcCW, hinders bullet penetration of the shield
ENT.DisableDuplicator = true
--
ENT.JMod_NapalmBounce = true

function ENT:GravGunPunt(ply)
	return false
end

function ENT:CanTool(ply, trace, mode, tool, button)
	if (mode == "remover") then return true end
	return false
end

hook.Add("ShouldCollide", "JMOD_DIRECTIONALSHIELDCOLLISION", function(ent1, ent2)
	local snc1 = ent1.ShouldNotCollide
	if snc1 and snc1(ent1, ent2) then return false end

	local snc2 = ent2.ShouldNotCollide
	if snc2 and snc2(ent2, ent1) then return false end
end)

function ENT:ShouldNotCollide(ent)
	if not IsValid(ent) then return true end
	if ent:IsPlayer() then return true end
	
	-- Check if entity is behind the shield (on protected side)
	if self:IsEntityBehindShield(ent:GetPos()) then return true end

	local Time = CurTime()
	if (ent.JMod_DirectionalShieldPassTime and ent.JMod_DirectionalShieldPassTime > Time) then return false end

	local TheirSpeed, TheirPhys, MaxSpeed = ent:GetVelocity():Length(), ent:GetPhysicsObject(), 500
	if (IsValid(TheirPhys) and TheirPhys.GetMass) then
		if (TheirPhys:GetMass() > 250) then MaxSpeed = 200 end
	end
	if (TheirSpeed < MaxSpeed) then return true end

	ent.JMod_DirectionalShieldPassTime = Time + 3
	return false
end

function ENT:IsEntityBehindShield(pos)
	local ShieldCenter = self:GetShieldCenter()
	local ShieldNormal = self:GetShieldDirection()
	
	-- Check if position is behind the shield plane
	local ToPos = pos - ShieldCenter
	local DotProduct = ToPos:Dot(ShieldNormal)
	
	-- If dot product is negative, entity is behind the shield
	return DotProduct < 0
end

function ENT:GetShieldCenter()
	if IsValid(self.Projector) then
		local ProjectorPos = self.Projector:GetPos()
		local ProjectorForward = self.Projector:GetAngles():Forward()
		
		-- Use custom distance if provided, otherwise use default distance
		local distance = self.CustomShieldDistance or 200
		
		-- Position shield at FIXED position relative to generator (always in front)
		-- Shield position is independent of which direction it faces
		return ProjectorPos + ProjectorForward * distance
	end
	return self:GetPos()
end

function ENT:IsPointOnShield(pos)
	local ShieldCenter = self:GetShieldCenter()
	local ShieldSize = self.ShieldSizes[self:GetSizeClass()] or self.ShieldSizes[1]
	local ShieldDir = self:GetShieldDirection()
	
	-- Get the up and right vectors for the shield plane
	local Up = Vector(0, 0, 1)
	if math.abs(ShieldDir:Dot(Up)) > 0.9 then
		Up = Vector(1, 0, 0) -- Use different up vector if shield is nearly vertical
	end
	local Right = ShieldDir:Cross(Up):GetNormalized()
	Up = Right:Cross(ShieldDir):GetNormalized()
	
	-- Project position onto shield plane
	local ToPos = pos - ShieldCenter
	local DistanceFromPlane = math.abs(ToPos:Dot(ShieldDir))
	
	-- Check if close enough to the plane (thickness tolerance)
	if DistanceFromPlane > 10 then return false end
	
	-- Check if within shield bounds
	local RightOffset = ToPos:Dot(Right)
	local UpOffset = ToPos:Dot(Up)
	
	return math.abs(RightOffset) <= ShieldSize.width/2 and math.abs(UpOffset) <= ShieldSize.height/2
end

function ENT:GetShieldDirection()
	if IsValid(self.Projector) then
		-- Shield always faces back toward the projector (fixed direction)
		return -self.Projector:GetAngles():Right()
	end
	-- Default to backward direction if no projector
	return -self:GetAngles():Up()
end

function ENT:TestCollision(startpos, delta, isbox, extents, mask)
	local ShieldCenter = self:GetShieldCenter()
	local ShieldDir = self:GetShieldDirection()
	local EndPos = startpos + delta

	if isbox then
		local PointsToCheck = {
			startpos,
			startpos + extents,
			startpos - extents,
			startpos + Vector(extents.x, extents.y, -extents.z),
			startpos + Vector(extents.x, -extents.y, extents.z),
			startpos + Vector(-extents.x, extents.y, -extents.z),
			startpos + Vector(-extents.x, -extents.y, extents.z)
		}
		for i, point in ipairs(PointsToCheck) do
			if self:IsPointOnShield(point) then
				return false
			end
		end
	else
		if self:IsPointOnShield(startpos) then
			return false
		end
	end

	if (bit.band(mask, MASK_SHOT) == MASK_SHOT) then
		-- Ray-plane intersection
		local PlaneNormal = ShieldDir
		local RayDirection = delta:GetNormalized()
		
		-- Check if ray is parallel to plane
		local dotProduct = RayDirection:Dot(PlaneNormal)
		if math.abs(dotProduct) < 0.0001 then return true end -- Parallel, no intersection
		
		-- Calculate intersection point
		local ToPlane = ShieldCenter - startpos
		local t = ToPlane:Dot(PlaneNormal) / dotProduct
		
		-- Check if intersection is within ray bounds
		if t < 0 or t > 1 then return true end -- Outside ray bounds
		
		local HitPos = startpos + delta * t
		
		-- Check if hit position is within shield bounds
		if self:IsPointOnShield(HitPos) then
			return {
				HitPos = HitPos,
				Fraction = t,
				Normal = PlaneNormal
			}
		end
	end

	return true
end

local STATE_BREAKING, STATE_COLLAPSING, STATE_IDLING, STATE_GROWING = -2, -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 1, "SizeClass")
	self:NetworkVar("Int", 2, "State")
	self:NetworkVar("Bool", 0, "AmInnerShield")
	self:NetworkVar("Float", 0, "Strength")
	self:NetworkVar("Float", 1, "MaxStrength")
end

function ENT:ImpactTrace(tr, dmgType)
	return true
end

if SERVER then
	function ENT:Initialize()
		if self:GetSizeClass() < 1 then self:SetSizeClass(1) end
		local ShieldGrade = self:GetSizeClass()
		local ShieldSize = self.ShieldSizes[ShieldGrade]
		self.ShieldSize = ShieldSize

		self:SetModel(self.Model)
		self:SetMaterial(self.Material)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:DrawShadow(false)
		self:SetRenderMode(RENDERMODE_GLOW)
		self:AddEFlags(EFL_NO_DISSOLVE)

		local phys = self:GetPhysicsObject()

		if not (IsValid(phys)) then self:Remove() return end

		phys:Wake()
		phys:SetMass(9e9)
		phys:EnableMotion(false)
		phys:SetMaterial("solidmetal")

		self:EnableCustomCollisions(true)

		-- Position shield at correct distance from projector
		timer.Simple(0.1, function()
			if IsValid(self) then
				self:PositionShield()
			end
		end)

		self:SetState(STATE_GROWING)
		timer.Simple(2, function()
			if (IsValid(self)) then self:SetState(STATE_IDLING) end
		end)

		if not(IsValid(self.Projector)) then -- for debugging
			local Strength = 1000
			self:SetMaxStrength(Strength)
			self:SetStrength(Strength)
		end
	end
	
	function ENT:PositionShield()
		if IsValid(self.Projector) then
			local ShieldCenter = self:GetShieldCenter()
			local ShieldDir = self:GetShieldDirection()
			
			-- Convert shield direction to proper model orientation
			local ShieldAngles = ShieldDir:Angle()
			ShieldAngles:RotateAroundAxis(ShieldAngles:Right(), 90) -- Rotate 90 degrees to make it upright
			ShieldAngles:RotateAroundAxis(ShieldAngles:Up(), 90) -- Rotate 90 degrees to face properly away from generator
			
			-- Set shield position and orientation
			self:SetPos(ShieldCenter)
			self:SetAngles(ShieldAngles)
			
			-- Update physics object immediately
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetPos(ShieldCenter)
				phys:SetAngles(ShieldAngles)
				phys:Wake()
			end
			
			-- Scale the model to match shield size
			local Scale = Vector(
				self.ShieldSize.width / 120,  -- Base plate is ~120 units
				self.ShieldSize.height / 120,
				0.1  -- Keep it thin
			)
			self:SetModelScale(Scale.x, 0) -- Use the larger dimension for uniform scaling
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		local HitEnt = data.HitEntity
		if not(IsValid(HitEnt)) then return end
		if (HitEnt:GetClass() == "player") then return end
		if (HitEnt:IsWorld()) then return end
		if (data.Speed < 250) then return end
		if (data.DeltaTime < .15) then return end
		if (self.NextHit and self.NextHit > CurTime()) then return end

		local HitVel, HitDir = data.OurOldVelocity, data.OurOldVelocity:GetNormalized()
		local DamageAmt = data.Speed * 0.0003 * HitEnt:GetPhysicsObject():GetMass()
		local HitPos = data.HitPos
		local HitNorm = self:GetShieldDirection() -- Use shield normal

		-- Only process hits on the shield surface
		if self:IsPointOnShield(HitPos) then
			self:TakeDamage(DamageAmt, data.HitEntity, data.HitEntity, HitPos, HitNorm, 1)
		end
	end

	function ENT:TakeDamage(dmg, attacker, inflictor, hitPos, hitNorm, scale)
		local CurStrength = self:GetStrength()
		if (CurStrength <= 0) then return end

		local NewStrength = math.max(CurStrength - dmg, 0)
		self:SetStrength(NewStrength)

		self.NextHit = CurTime() + .1

		if (IsValid(self.Projector)) then
			local Atk = (IsValid(attacker) and attacker) or game.GetWorld()
			JMod.DamageSpark(self.Projector, hitPos or self:GetPos(), 10)
		end

		self:DoHitEffect(hitPos or self:GetPos(), scale or 1, hitNorm or Vector(0, 0, 1))

		if (NewStrength <= 0) then
			self:Break()
		end
	end

	function ENT:AcceptRecharge(amt)
		local CurStr, MaxStr = self:GetStrength(), self:GetMaxStrength()
		if (CurStr >= MaxStr) then return 0 end
		local Accepted = math.min(amt, MaxStr - CurStr)
		self:SetStrength(CurStr + Accepted)
		return Accepted
	end

	function ENT:Break()
		self:SetState(STATE_BREAKING)
		self:EmitSound("snds_jack_gmod/ez_bubbleshield_break.ogg", 100, 100)
		local Eff = EffectData()
		Eff:SetOrigin(self:GetPos())
		Eff:SetScale(self:GetSizeClass())
		util.Effect("eff_jack_gmod_shielddestroy", Eff, true, true)

		timer.Simple(.5, function()
			if (IsValid(self)) then
				self:SetState(STATE_COLLAPSING)
				timer.Simple(3, function()
					if (IsValid(self)) then
						self:Remove()
					end
				end)
			end
		end)
	end

	function ENT:Think()
		-- Server-side think to follow projector
		self:FollowProjector()
		self:NextThink(CurTime() + 0.1)
		return true
	end
	
	function ENT:FollowProjector()
		if not IsValid(self.Projector) then return end
		
		-- Calculate shield position relative to projector
		local ShieldCenter = self:GetShieldCenter()
		local ShieldDir = self:GetShieldDirection()
		
		-- Convert shield direction to proper model orientation
		local ShieldAngles = ShieldDir:Angle()
		ShieldAngles:RotateAroundAxis(ShieldAngles:Right(), 90) -- Rotate 90 degrees to make it upright
		ShieldAngles:RotateAroundAxis(ShieldAngles:Up(), 90) -- Rotate 90 degrees to face properly away from generator
		
		-- Update shield position and orientation to follow projector
		self:SetPos(ShieldCenter)
		self:SetAngles(ShieldAngles)
		
		-- Update physics object if it exists
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetPos(ShieldCenter)
			phys:SetAngles(ShieldAngles)
			phys:Wake()
		end
	end

	function ENT:OnRemove()
		if IsValid(self.Projector) then
			self.Projector:ShieldBreak()
		end
	end

	function ENT:DoHitEffect(pos, scale, normal)
		local Ripple = EffectData()
		Ripple:SetEntity(self)
		Ripple:SetOrigin(pos)
		Ripple:SetScale(scale)
		Ripple:SetNormal(normal)
		util.Effect("eff_jack_gmod_refractripple", Ripple, true, true)
		---
		local snd = "snds_jack_gmod/ez_bubbleshield_hits/light_"..math.random(1, 3)..".ogg"
		local pitch = math.random(90, 110)
		local lvl = 65
		if (scale >= 1.5) then
			snd = "snds_jack_gmod/ez_bubbleshield_hits/heavy_"..math.random(1, 3)..".ogg"
			lvl = 75
		end
		sound.Play(snd, pos, lvl, pitch)
		sound.Play(snd, self:GetPos() + Vector(0, 0, 30), lvl, pitch)
	end
elseif CLIENT then
	local GlowSprite = Material("sprites/mat_jack_basicglow")
	local ShieldMat = Material("models/wireframe")
	local MASK_COLOR = Color(0, 0, 0, 0)

	function ENT:Initialize()
		local ShieldGrade = self:GetSizeClass()
		local ShieldSize = self.ShieldSizes[ShieldGrade]

		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		self.Mat = ShieldMat
		-- Initializing some values
		self.ShieldGrow = 0
		self.ShieldSize = ShieldSize
		--
		self:EnableCustomCollisions(true)
		self.BeamScroll = 0
	end

	function ENT:Think()
		local FT, State = FrameTime(), self:GetState()
		if (State == STATE_GROWING) then
			self.ShieldGrow = Lerp(FT * 4, self.ShieldGrow, 1)
		elseif (State == STATE_COLLAPSING) then
			self.ShieldGrow = Lerp(FT * 6, self.ShieldGrow, .01)
		else
			self.ShieldGrow = 1
		end
		self.BeamScroll = (self.BeamScroll - FT * 2) % 1
		
		-- Client-side continuous following for smooth visuals
		if IsValid(self.Projector) then
			local ShieldCenter = self:GetShieldCenter()
			local ShieldDir = self:GetShieldDirection()
			
			-- Convert shield direction to proper model orientation
			local ShieldAngles = ShieldDir:Angle()
			ShieldAngles:RotateAroundAxis(ShieldAngles:Right(), 90) -- Rotate 90 degrees to make it upright
			ShieldAngles:RotateAroundAxis(ShieldAngles:Up(), 90) -- Rotate 90 degrees to face properly away from generator
			
			self:SetPos(ShieldCenter)
			self:SetAngles(ShieldAngles)
		end
	end

	function ENT:Draw()
		local State = self:GetState()
		if State == STATE_BREAKING or State == STATE_COLLAPSING then return end
		
		-- Set material properties
		render.SetMaterial(self.Mat)
		
		-- Set color with transparency based on strength
		local strength = self:GetStrength() or 1000
		local maxStrength = self:GetMaxStrength() or 1000
		local alpha = math.max(50, 150 * (strength / maxStrength)) * self.ShieldGrow
		
		-- Blue tint for the shield
		render.SetColorModulation(0.3, 0.6, 1.0)
		local oldColor = self:GetColor()
		self:SetColor(Color(255, 255, 255, alpha))
		
		-- Draw the flat shield
		self:DrawModel()
		
		-- Reset color
		self:SetColor(oldColor)
		render.SetColorModulation(1, 1, 1)
		
		-- Draw border glow effect
		if alpha > 100 then
			self:DrawShieldGlow()
		end
	end
	
	function ENT:DrawShieldGlow()
		local ShieldCenter = self:GetShieldCenter()
		local ShieldSize = self.ShieldSize
		
		-- Draw glow sprites at shield corners for visibility
		render.SetMaterial(GlowSprite)
		
		local corners = {
			ShieldCenter + self:GetRight() * ShieldSize.width/2 + self:GetUp() * ShieldSize.height/2,
			ShieldCenter + self:GetRight() * ShieldSize.width/2 - self:GetUp() * ShieldSize.height/2,
			ShieldCenter - self:GetRight() * ShieldSize.width/2 + self:GetUp() * ShieldSize.height/2,
			ShieldCenter - self:GetRight() * ShieldSize.width/2 - self:GetUp() * ShieldSize.height/2,
		}
		
		for _, corner in ipairs(corners) do
			render.DrawSprite(corner, 20, 20, Color(100, 150, 255, 100))
		end
	end
	
	language.Add("ent_jack_gmod_directional_shield", "Directional Shield")
end
