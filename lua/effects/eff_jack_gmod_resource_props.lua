﻿local ModelPool = {
	[JMod.EZ_RESOURCE_TYPES.AMMO] = {"models/weapons/shotgun_shell.mdl", "models/weapons/shell.mdl", "models/weapons/rifleshell.mdl"},
	[JMod.EZ_RESOURCE_TYPES.COAL] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.IRONORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.LEADORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUMORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.COPPERORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTENORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.TITANIUMORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.SILVERORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.GOLDORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.URANIUMORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.PLATINUMORE] = {"models/props_debris/concrete_spawnchunk001g.mdl", "models/props_debris/concrete_spawnchunk001k.mdl", "models/props_debris/concrete_chunk04a.mdl", "models/props_debris/concrete_chunk05g.mdl", "models/props_debris/concrete_spawnchunk001d.mdl"},
	[JMod.EZ_RESOURCE_TYPES.STEEL] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.LEAD] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.ALUMINUM] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.COPPER] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.TUNGSTEN] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.TITANIUM] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.SILVER] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.GOLD] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.URANIUM] = {"models/props_mining/ingot001.mdl"},
	[JMod.EZ_RESOURCE_TYPES.PLATINUM] = {"models/props_mining/ingot001.mdl"}
}
function EFFECT:Init(data)
	self.ResourceType = JMod.IndexToResource[data:GetFlags()]
	self.Origin = data:GetOrigin()
	self.Spread = data:GetMagnitude()
	self.Scale = data:GetScale()
	local SurfaceProp = data:GetSurfaceProp()

	if SurfaceProp == 0 then
		self.Target = nil -- directionless explosion
	elseif SurfaceProp == 1 then
		self.Target = data:GetStart() -- we have a destination
	end

	local LifeTime = .9
	self.DieTime = CurTime() + LifeTime

	local MyMdl = table.Random(ModelPool[self.ResourceType])
	self:SetPos(self.Origin + VectorRand() * math.random(1, 5 * self.Spread))
	self:SetModel(MyMdl)
	self:SetModelScale(self.Scale * math.Rand(.75, 1.25), 0)
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
		phys:SetVelocity(MyFlightVec)
		phys:EnableGravity(false)
		phys:AddAngleVelocity(VectorRand() * math.random(1, 800))
	end
end

function EFFECT:PhysicsCollide()
	-- stub
end

-- sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 65, self.HitPitch, 1)
function EFFECT:Think()
	local Time = CurTime()
	if self.DieTime < Time then return false end
	local Vec = self.Target - self:GetPos()
	local Phys = self:GetPhysicsObject()

	if IsValid(Phys) then
		Phys:ApplyForceCenter(Vec:GetNormalized() * 50 - Phys:GetVelocity() / 3)
	end

	return true
end

function EFFECT:Render()
	if not IsValid(self) then return end
	self:DrawModel()
end