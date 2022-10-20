local RockModels = {"models/jmod/resources/rock01a.mdl", "models/jmod/resources/rock02a.mdl", "models/jmod/resources/rock03a.mdl", "models/jmod/resources/rock04a.mdl", "models/jmod/resources/rock05a.mdl"}

local ElectronicsModels = {"models/props_lab/reciever01d.mdl", "models/props/cs_office/computer_caseb_p2a.mdl", "models/props/cs_office/computer_caseb_p3a.mdl", "models/props/cs_office/computer_caseb_p4a.mdl", "models/props/cs_office/computer_caseb_p5a.mdl", "models/props/cs_office/computer_caseb_p5b.mdl", "models/props/cs_office/computer_caseb_p6a.mdl", "models/props/cs_office/computer_caseb_p6b.mdl", "models/props/cs_office/computer_caseb_p7a.mdl", "models/props/cs_office/computer_caseb_p8a.mdl", "models/props/cs_office/computer_caseb_p9a.mdl"}

local PropConfig = {
	[JMod.EZ_RESOURCE_TYPES.ADVANCEDPARTS] = {
		mdls = ElectronicsModels
	},
	[JMod.EZ_RESOURCE_TYPES.AMMO] = {
		mdls = {"models/jhells/shell_9mm.mdl", "models/jhells/shell_762nato.mdl", "models/jhells/shell_57.mdl", "models/jhells/shell_556.mdl", "models/jhells/shell_338mag.mdl", "models/jhells/shell_12gauge.mdl", "models/weapons/shotgun_shell.mdl", "models/weapons/shell.mdl", "models/weapons/rifleshell.mdl"},
		scl = 1.5
	},
	[JMod.EZ_RESOURCE_TYPES.COAL] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_coal"
	},
	[JMod.EZ_RESOURCE_TYPES.IRONORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_ironore"
	},
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_leadore"
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_aluminumore"
	},
	[JMod.EZ_RESOURCE_TYPES.COPPERORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_copperore"
	},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTENORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_tungstenore"
	},
	[JMod.EZ_RESOURCE_TYPES.TITANIUMORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_titaniumore"
	},
	[JMod.EZ_RESOURCE_TYPES.SILVERORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_silverore"
	},
	[JMod.EZ_RESOURCE_TYPES.GOLDORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_goldore"
	},
	[JMod.EZ_RESOURCE_TYPES.URANIUMORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_uraniumore"
	},
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = {
		mdls = RockModels,
		mat = "models/mat_jack_gmod_platinumore"
	},
	[JMod.EZ_RESOURCE_TYPES.STEEL] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_steel",
		col = Color(50, 50, 50),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.LEAD] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_lead",
		col = Color(50, 50, 50),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_aluminum",
		col = Color(180, 180, 180),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.COPPER] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_copper",
		col = Color(150, 100, 80),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_tungsten",
		col = Color(150, 150, 170),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.TITANIUM] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_titanium",
		col = Color(160, 160, 160),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.SILVER] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_silver",
		col = Color(150, 150, 150),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.GOLD] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_gold",
		col = Color(150, 120, 50),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.URANIUM] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_uranium",
		col = Color(50, 55, 50),
		scl = .5
	},
	[JMod.EZ_RESOURCE_TYPES.PLATINUM] = {
		mdls = RockModels,
		mat = "models/props_mining/ingot_jack_platinum",
		col = Color(170, 160, 165),
		scl = .5
	}
}

local TotalParticleCount = 0

function EFFECT:Init(data)
	if TotalParticleCount >= 500 then
		self:Remove()

		return
	end

	TotalParticleCount = math.Clamp(TotalParticleCount + 1, 0, 9e9)

	timer.Simple(5, function()
		TotalParticleCount = math.Clamp(TotalParticleCount - 1, 0, 9e9)
	end)

	self.ResourceType = JMod.IndexToResource[data:GetFlags()]
	self.Origin = data:GetOrigin()
	self.Spread = data:GetMagnitude()
	self.Scale = data:GetScale()
	local SurfaceProp = data:GetSurfaceProp()
	self.Speed = math.Rand(.75, 1.5)

	if SurfaceProp == 0 then
		self.Target = nil -- directionless explosion
	elseif SurfaceProp == 1 then
		self.Target = data:GetStart() -- we have a destination
		local Dist = self.Target:Distance(self.Origin)
		self.Speed = self.Speed * Dist / 100
	end

	self.Data = PropConfig[self.ResourceType]
	local MyMdl = table.Random(self.Data.mdls)
	self:SetPos(self.Origin + VectorRand() * math.random(1, 5 * self.Spread))
	self:SetModel(MyMdl)

	if self.Data.mat then
		self:SetMaterial(self.Data.mat)
	end

	self:SetModelScale(self.Scale * math.Rand(.75, 1.25) * (self.Data.scl or 1), 0)
	local Col = self.Data.col or Color(255, 255, 255)
	local ColFrac = math.Rand(1.1, .9)
	self:SetColor(Color(math.Clamp(Col.r * ColFrac, 0, 255), math.Clamp(Col.g * ColFrac, 0, 255), math.Clamp(Col.b * ColFrac, 0, 255)))
	self:DrawShadow(true)
	self:SetAngles(AngleRand())
	local pb_vert = 2 * self.Scale
	local pb_hor = 2 * self.Scale
	self:PhysicsInitBox(Vector(-pb_vert, -pb_hor, -pb_hor), Vector(pb_vert, pb_hor, pb_hor))
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	local MyFlightDir = VectorRand()
	local MyFlightSpeed = math.random(1, 400)
	local MyFlightVec = MyFlightDir * MyFlightSpeed

	if IsValid(phys) then
		phys:Wake()
		phys:SetDamping(0, 0)
		phys:SetMass(10)
		phys:SetMaterial("gmod_silent")
		phys:SetVelocity(MyFlightVec * self.Spread)

		if self.Target then
			phys:EnableGravity(false)
		end

		phys:AddAngleVelocity(VectorRand() * math.random(1, 600))
	end

	self.DieTime = CurTime() + 5
end

function EFFECT:PhysicsCollide()
end

-- stub
-- sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 65, self.HitPitch, 1)
function EFFECT:Think()
	local Vec = self.Target - self:GetPos()
	local Phys = self:GetPhysicsObject()
	local Dist = Vec:Length()
	if self.DieTime < CurTime() then return false end

	if Dist < 5 then
		Phys:EnableMotion(false)

		return false
	end

	if IsValid(Phys) then
		Phys:ApplyForceCenter(Vec:GetNormalized() * 30 * self.Speed - Phys:GetVelocity() / 4)
	end

	return true
end

function EFFECT:Render()
	if not IsValid(self) then return end
	local Phys = self:GetPhysicsObject()
	if not IsValid(Phys) then return end

	if Phys:IsMotionEnabled() then
		self:DrawModel()
	end
end