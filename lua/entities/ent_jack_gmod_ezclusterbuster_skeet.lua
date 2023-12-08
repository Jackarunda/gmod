-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "AdventureBoots, Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The smart skeet submunition for the EZ Cluster Buster"
ENT.PrintName = "buster skeet"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.EZclusterBusterMunition = true

---
if SERVER then
	function ENT:Initialize()
		self:SetModel("models/props_phx/wheels/magnetic_small_base.mdl")
		self:SetMaterial("phoenix_storms/Future_vents")
		--self:SetModelScale(1.25,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)

		---
		timer.Simple(0, function()
			if not IsValid(self) then return end
			self:GetPhysicsObject():SetMass(40)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.EZowner = JMod.GetEZowner(self)
		self.NextSeek = CurTime() + math.Rand(1, 3)
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.DeltaTime > 0.2 and data.Speed > 25) and not(data.HitEntity.EZclusterBusterMunition) then
			self:Detonate()
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if self.Exploded then return end
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if JMod.LinCh(Dmg, 10, 50) then
			self:Detonate()
		end
	end

	function ENT:Detonate(dir)
		if self.Exploded then return end
		self.Exploded = true
		local Att = JMod.GetEZowner(self)
		local Pos = self:GetPos()
		JMod.Sploom(Att, Pos, 100)
		util.ScreenShake(Pos, 99999, 99999, .1, 1000)

		if dir then
			local Eff = EffectData()
			Eff:SetOrigin(Pos)
			Eff:SetScale(1)
			Eff:SetNormal(dir)
			util.Effect("eff_jack_gmod_efpburst", Eff, true, true)
			JMod.RicPenBullet(self, Pos, dir, 1100, true, true)
		end

		SafeRemoveEntityDelayed(self, 0.01)
	end

	local BlackList = {"prop_", "func_"}

	local function IsBlackListed(className)
		for k, v in pairs(BlackList) do
			if string.find(className, v) then return true end
		end

		return false
	end

	function ENT:Think()
		local Time = CurTime()

		if self.NextSeek < Time then
			local Pos, Targets = self:GetPos(), {}

			for k, v in pairs(ents.FindInCone(Pos, Vector(0, 0, -1), 1500, math.cos(math.rad(45)))) do
				local Phys, Class = v:GetPhysicsObject(), v:GetClass()
				
				if IsValid(Phys) and not (v == self) and not (Class == self.ClassName) and not IsBlackListed(Class) then
					if v:IsPlayer() or v:IsNPC() or v:IsVehicle() or v.LVS then
						if JMod.ClearLoS(self, v) and JMod.ShouldAttack(self, v, nil, true) then
							table.insert(Targets, v)
						end
					end
				end
			end

			if #Targets > 0 then
				local Target = table.Random(Targets)
				local SelfPos, Pos = self:GetPos(), Target:LocalToWorld(Target:OBBCenter())
				local Vec = Pos - SelfPos
				local Dir, Dist = Vec:GetNormalized(), Vec:Length()
				Dir = (Dir + VectorRand() * .05):GetNormalized() -- inaccuracy
				self:Detonate(Dir)
			end
		end

		self:NextThink(Time + .01)

		return true
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	---
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezclusterbuster_skeet", "EZ Smart EFP Submunition")
end
