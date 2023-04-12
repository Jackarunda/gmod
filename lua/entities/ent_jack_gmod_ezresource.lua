-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Resources"
ENT.Information = "glhfggwpezpznore"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
---
ENT.IsJackyEZresource = true
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Resource")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * (self.SpawnHeight or 20) * (self.ModelScale or 1)
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(self.SpawnAngle or Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		ent:SetResource(ent.MaxResources)
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		if self.Models then
			self:SetModal(table.Random(self.Models))
		else
			self:SetModel(self.Model)
		end

		self:SetMaterial(self.Material)

		if self.ModelScale then
			self:SetModelScale(self.ModelScale, 0)
		end

		if self.Color then
			self:SetColor(self.Color)
		end

		if self.Skin then
			self:SetSkin(self.Skin)
		end

		if self.RandomSkins then
			self:SetSkin(table.Random(self.RandomSkins))
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		self.MaxResources = 100 * JMod.Config.ResourceEconomy.MaxResourceMult
		self:SetResource(100)
		---
		self.NextLoad = 0
		self.Loaded = false
		self.NextCombine = 0

		---
		timer.Simple(.01, function()
			if IsValid(self) then
				self:CalcWeight()
			end
		end)
	end

	function ENT:CalcWeight()
		local Frac = self:GetResource() / self.MaxResources
		self:GetPhysicsObject():SetMass(math.max(self.Mass * Frac, 1))
		self:GetPhysicsObject():Wake()
	end

	-- I'm commenting this out to make sure we've tied up all of hte loose ends
	--[[function ENT:FlingProp(mdl)
		if not util.IsValidModel(mdl) then return end
		local Prop = ents.Create("prop_physics")
		Prop:SetPos(self:GetPos())
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:SetModelScale(.5, 0)
		Prop:Spawn()
		Prop:Activate()
		Prop.JModNoPickup = true

		if math.random(1, 2) == 1 then
			if Prop.SetHealth then
				Prop:SetHealth(100)
			end
		end

		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop, self, 0, 0)
		local Phys = Prop:GetPhysicsObject()
		Phys:SetVelocity((VectorRand() + Vector(0, 0, 1)):GetNormalized() * math.Rand(100, 300))
		Phys:AddAngleVelocity(VectorRand() * math.Rand(1, 10000))
		SafeRemoveEntityDelayed(Prop, math.Rand(5, 10))
	end]]--

	function ENT:PhysicsCollide(data, physobj)
		if self.Loaded then return end

		if data.DeltaTime > 0.2 then
			local Time = CurTime()

			if data.HitEntity.ClassName == self.ClassName and self.NextCombine < Time and data.HitEntity.NextCombine < Time then
				-- determine a priority, favor the item that has existed longer
				if self:EntIndex() < data.HitEntity:EntIndex() then
					-- don't run twice on every collision
					-- try to combine
					local Sum = self:GetResource() + data.HitEntity:GetResource()

					if Sum <= self.MaxResources then
						self:SetResource(Sum)
						self:CalcWeight()
						data.HitEntity:Remove()
						JMod.ResourceEffect(self.EZsupplies, data.HitPos, data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()))

						return
					end
				end
			end

			if data.HitEntity.EZconsumes and table.HasValue(data.HitEntity.EZconsumes, self.EZsupplies) and (self.NextLoad < Time) and self:IsPlayerHolding() then
				if self:GetResource() <= 0 then
					self:Remove()

					return
				end

				local Resource = self:GetResource()
				local Used = data.HitEntity:TryLoadResource(self.EZsupplies, Resource)

				if Used > 0 then
					self:SetResource(Resource - Used)
					self:CalcWeight()

					JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()), 1, 1, 1)

					if Used >= Resource then
						self.Loaded = true

						timer.Simple(.1, function()
							if IsValid(self) then
								self:Remove()
							end
						end)
					end

					return
				end
			end

			if (data.Speed > 80) and self and self.ImpactNoise1 then
				self.Entity:EmitSound(self.ImpactNoise1)

				if self.ImpactNoise2 then
					self.Entity:EmitSound(self.ImpactNoise2)
				end
			end

			if self.ImpactSensitivity then
				if data.Speed > self.ImpactSensitivity then
					local Pos = self:GetPos()
					sound.Play(self.BreakNoise, Pos)

					JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, self:GetResource() / self.MaxResources, 1, 1)
					if self.UseEffect then
						self:UseEffect(Pos, game.GetWorld(), true)
					end
					SafeRemoveEntity(self)
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play(self.BreakNoise, Pos)

			JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, self:GetResource() / self.MaxResources, 1, 1)
			if self.UseEffect then
				for i = 1, self:GetResource() / 10 do			
					self:UseEffect(Pos, game.GetWorld(), true)
				end
			end

			self:Remove()
		end
	end

	function ENT:Use(activator)
		local AltPressed, Count = activator:KeyDown(JMod.Config.General.AltFunctionKey), self:GetResource()

		if AltPressed and activator:KeyDown(IN_SPEED) then
			-- split resource entity in half
			if Count > 1 then
				local NewCountOne, NewCountTwo = math.ceil(Count / 2), math.floor(Count / 2)
				local Box = ents.Create(self.ClassName)
				Box:SetPos(self:GetPos() + self:GetUp() * 5)
				Box:SetAngles(self:GetAngles())
				Box:Spawn()
				Box:Activate()
				Box:SetResource(NewCountOne)
				Box:CalcWeight()
				activator:PickupObject(Box)
				Box.NextCombine = CurTime() + 2
				self.NextCombine = CurTime() + 2
				self:SetResource(NewCountTwo)
				self:CalcWeight()
				JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, 1, self:GetResource() / self.MaxResources, 1)
			end
		elseif self.AltUse and AltPressed then
			self:AltUse(activator)
		else
			JMod.Hint(activator, "resource manage")
			activator:PickupObject(self)

			if JMod.Hints[self:GetClass() .. " use"] then
				JMod.Hint(activator, self:GetClass() .. " use")
			end
		end
	end

	function ENT:Think()
		if self.CustomThink then return self:CustomThink() end
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply)
		ent.NextLoad = Time + math.random(1, 5)
		ent.NextCombine = Time + math.random(1, 5)
	end

	function ENT:OnRemove()
	end
	--aw fuck you
end
