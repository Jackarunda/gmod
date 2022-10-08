EFFECT.Sounds = {}
EFFECT.Pitch = 90
EFFECT.Scale = 1.5
EFFECT.PhysScale = 1
EFFECT.Model = "models/shells/shell_57.mdl"
EFFECT.Material = nil
EFFECT.JustOnce = true
EFFECT.AlreadyPlayedSound = false
EFFECT.LifeTime = .9
EFFECT.SpawnTime = 0

local ModelPool = {
	[JMod.EZ_RESOURCE_TYPES.AMMO] = {
		"models/weapons/shotgun_shell.mdl",
		"models/weapons/shell.mdl",
		"models/weapons/rifleshell.mdl"
	}
}

function EFFECT:Init(data)
	self.Origin = data:GetOrigin()
	self.Target = data:GetStart()
	self.Type = data:GetFlags()

	local MyMdl = table.Random(ModelPool[JMod.EZ_RESOURCE_TYPES.AMMO])

	self:SetPos(self.Origin + VectorRand() * math.random(1,5))
	self:SetModel(MyMdl)
	--self:SetModelScale(1,0)
	self:DrawShadow(true)
	self:SetAngles(AngleRand())

	local pb_vert = 2 * 1
	local pb_hor = .5 * 1
	self:PhysicsInitBox(Vector(-pb_vert, -pb_hor, -pb_hor), Vector(pb_vert, pb_hor, pb_hor))
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()

	local MyFlightDir = VectorRand()
	local MyFlightSpeed = math.random(1, 400)
	local MyFlightVec = MyFlightDir * MyFlightSpeed

	--timer.Simple(0,function()
		if(IsValid(phys))then
			phys:Wake()
			phys:SetDamping(0, 0)
			phys:SetMass(10)
			phys:SetMaterial("gmod_silent")
			phys:SetVelocity(MyFlightVec)
			phys:EnableGravity(false)
			phys:AddAngleVelocity(VectorRand() * math.random(1,800))
		end
	--end)
	--[[
	local emitter = ParticleEmitter(Origin)

	for i = 1, 3 do
		local particle = emitter:Add("particles/smokey", origin + (dir * 2))

		if particle then
			particle:SetVelocity(VectorRand() * 10 + (dir * i * math.Rand(48, 64)) + plyvel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.05, 0.15))
			particle:SetStartAlpha(math.Rand(40, 60))
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(math.Rand(18, 24))
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetLighting(true)
			particle:SetAirResistance(96)
			particle:SetGravity(Vector(-7, 3, 20))
			particle:SetColor(150, 150, 150)
		end
	end
	--]]

	self.SpawnTime = CurTime()
	self.DieTime = self.SpawnTime + self.LifeTime
end

function EFFECT:PhysicsCollide()
	-- sound.Play(self.Sounds[math.random(#self.Sounds)], self:GetPos(), 65, self.HitPitch, 1)
end

function EFFECT:Think()
	local Time = CurTime()

	if (self.DieTime < Time) then return false end

	local Vec = self.Target - self:GetPos()
	local Phys = self:GetPhysicsObject()
	if (IsValid(Phys))then
		Phys:ApplyForceCenter(Vec:GetNormalized() * 50 - Phys:GetVelocity()/3)
	end

	return true
end

function EFFECT:Render()
	if not IsValid(self) then return end
	self:DrawModel()
end
