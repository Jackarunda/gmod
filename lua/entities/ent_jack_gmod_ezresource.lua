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
ENT.EZstorageSpace = 0
--ENT.JModHighlyFlammableFunc = "DoCookoff"
---
local LoadOnSpawn = CreateConVar("jmod_debug_loadresourceonspawn", "0", FCVAR_NONE, "Attempts to load spawned resources directly into entities you are looking at")
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Resource")
end

function ENT:GetEZsupplies(typ)
	local Supplies = {[self.EZsupplies] = self:GetResource()}
	if typ then
		if Supplies[typ] and Supplies[typ] > 0 then
			return Supplies[typ]
		else
			return nil
		end
	else
		return Supplies
	end
end

function ENT:SetEZsupplies(typ, amt, setter)
	if not SERVER then return end -- Important because this is shared as well
	if typ ~= self.EZsupplies then return end -- Type doesn't matter because we only have one type, but we have it here because of uniformness
	self:SetResource(amt) -- Set our resource to the new value
	if amt < 1 then self:Remove() end -- We be empty, therefore, useless
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
		ent:SetEZsupplies(self.EZsupplies, ent.MaxResource)
		local HitEnt = tr.Entity
		if IsValid(HitEnt) and HitEnt.TryLoadResource then
			local Accepted = HitEnt:TryLoadResource(self.EZsupplies, ent.MaxResource)
			if Accepted > 0 then
				JMod.ResourceEffect(self.EZsupplies, ent:LocalToWorld(ent:OBBCenter()), HitEnt:LocalToWorld(HitEnt:OBBCenter()), Accepted, 1, 1, 1)
				ent:SetEZsupplies(self.EZsupplies, ent.MaxResource - Accepted, HitEnt)
			end
		end
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

		if self.PhysBox then
			self:PhysicsInitBox(
				Vector(self.PhysBox.Mins.x, self.PhysBox.Mins.y, self.PhysBox.Mins.z), 
				Vector(self.PhysBox.Maxs.x, self.PhysBox.Maxs.y, self.PhysBox.Maxs.z)
			)
		else
			self:PhysicsInit(SOLID_VPHYSICS)
		end
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		self.MaxResource = 100 * JMod.Config.ResourceEconomy.MaxResourceMult
		self:SetResource(100)
		---
		self.NextLoad = 0
		self.Loaded = false
		self.NextCombine = 0
		self.NextFireThink = 0

		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				if self.PhysMat then
					Phys:SetMaterial(self.PhysMat)
				end
				Phys:SetMass(self.Mass or 30)
				Phys:Wake()
				if self.EZbuoyancy then
					Phys:SetBuoyancyRatio(self.EZbuoyancy)
				end
			end
		end)

		if (self.CustomInit) then
			self:CustomInit()
		end
	end

	function ENT:UpdateConfig()
		self.MaxResource = 100 * JMod.Config.ResourceEconomy.MaxResourceMult
		self:SetEZsupplies(self.EZsupplies, math.min(self:GetResource(), self.MaxResource))
	end

	function ENT:PhysicsCollide(data, physobj)
		if self.Loaded then return end

		if data.DeltaTime > 0.2 then
			local Time = CurTime()

			if (data.HitEntity.ClassName == self.ClassName) and (self.NextCombine < Time) and (data.HitEntity.NextCombine < Time) then
				-- determine a priority, favor the item that has existed longer
				if self:EntIndex() < data.HitEntity:EntIndex() then
					-- don't run twice on every collision
					-- try to combine
					local Sum = self:GetResource() + data.HitEntity:GetResource()

					if Sum <= self.MaxResource then
						self:SetEZsupplies(self.EZsupplies, Sum)
						data.HitEntity:Remove()
						JMod.ResourceEffect(self.EZsupplies, data.HitPos, data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()))

						return
					end
				end
			end

			if data.HitEntity.EZconsumes and table.HasValue(data.HitEntity.EZconsumes, self.EZsupplies) and (self.NextLoad < Time) and (self:IsPlayerHolding() or JMod.Config.ResourceEconomy.ForceLoadAllResources) then
				if self:GetResource() <= 0 then
					self:Remove()

					return
				end

				local Resource = self:GetResource()
				local Used = data.HitEntity:TryLoadResource(self.EZsupplies, Resource)

				if Used > 0 then
					self:SetEZsupplies(self.EZsupplies, Resource - Used)

					JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), data.HitEntity:LocalToWorld(data.HitEntity:OBBCenter()), Used / self.MaxResource, 1, 1)

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
				self:EmitSound(self.ImpactNoise1)

				if self.ImpactNoise2 then
					self:EmitSound(self.ImpactNoise2)
				end
			end

			if self.ImpactSensitivity then
				if data.Speed > self.ImpactSensitivity then
					local Pos = self:GetPos()
					sound.Play(self.BreakNoise, Pos)

					JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, self:GetResource() / self.MaxResource, 1, 1)
					if self.UseEffect then
						self:UseEffect(Pos, game.GetWorld(), true)
					end
					SafeRemoveEntity(self)
				end
			end

			if self.CustomImpact then self:CustomImpact(data, physobj) end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		local Dam = dmginfo:GetDamage()
		if Dam > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play(self.BreakNoise, Pos)

			JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, self:GetResource() / self.MaxResource, 1, 1)
			if self.UseEffect then
				for i = 1, self:GetResource() / 10 do			
					self:UseEffect(Pos, game.GetWorld(), true)
				end
			end

			self:Remove()
		end

		if (dmginfo:GetAttacker() == self) or (dmginfo:GetInflictor() == self) then return end
		if self.Cookoff and JMod.LinCh(Dam, 0, self.DamageThreshold) and ((dmginfo:IsExplosionDamage() and self.Explosive) or (dmginfo:IsDamageType(DMG_BURN) and self.Flammable)) then
			self:DoCookoff()
		elseif self.Flammable and (self.Flammable >= 0.5) and not(self:IsOnFire()) and JMod.LinCh(Dam, 0, self.Flammable) and dmginfo:IsDamageType(DMG_BURN) then
			self:Ignite(math.random(self.Flammable * 3, self.Flammable * 5), 0)
		end

		if self.CustomOnTakeDamage then self:CustomOnTakeDamage(dmginfo) end
	end

	function ENT:Use(activator)
		local AltPressed, Count = JMod.IsAltUsing(activator), self:GetResource()

		if AltPressed and activator:KeyDown(IN_SPEED) then
			-- split resource entity in half
			if Count > 1 then
				local NewCountOne, NewCountTwo = math.ceil(Count / 2), math.floor(Count / 2)
				local Box = ents.Create(self.ClassName)
				Box:SetPos(self:GetPos() + self:GetUp() * 5)
				Box:SetAngles(self:GetAngles())
				Box:Spawn()
				Box:Activate()
				Box:SetEZsupplies(self.EZsupplies, NewCountOne)
				--
				timer.Simple(0.1, function()
					if IsValid(Box) and IsValid(activator) and activator:Alive() then
						activator:PickupObject(Box)
					end
				end)
				Box.NextCombine = CurTime() + 2
				self.NextCombine = CurTime() + 2
				self:SetEZsupplies(self.EZsupplies, NewCountTwo)
				JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, 1, self:GetResource() / self.MaxResource, 1)
			end
		elseif AltPressed then
			local Wep = activator:GetActiveWeapon()
			local Used = 0
			if IsValid(Wep) and Wep.TryLoadResource then
				Used = Wep:TryLoadResource(self.EZsupplies, self:GetResource())
				self:SetEZsupplies(self.EZsupplies, self:GetResource() - Used, activator)

				if Used > 0 then
					JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), activator:LocalToWorld(activator:OBBCenter()), Used / self.MaxResource, 1, 1)
				end
			end
			if (Used <= 0) and (self.AltUse) then
				self:AltUse(activator)
			end
		else
			JMod.Hint(activator, "resource manage")
			activator:PickupObject(self)

			if JMod.Hints[self:GetClass() .. " use"] then
				JMod.Hint(activator, self:GetClass() .. " use")
			end
		end

		if (self.CustomUse) then
			self:CustomUse()
		end
	end

	function ENT:Think()
		local Time = CurTime()
		if (self.NextFireThink < Time) and self:IsOnFire() then
			self.NextFireThink = Time + .5
			local FuelLeft = self:GetResource()
			if self.Flammable then
				if FuelLeft <= 2 * self.Flammable then
					JMod.ResourceEffect(self.EZsupplies, self:LocalToWorld(self:OBBCenter()), nil, FuelLeft / self.MaxResource, 1, 1)
					self:Remove()
				else
					self:SetEZsupplies(self.EZsupplies, FuelLeft - math.random(0, 2 * self.Flammable), self)
				end
			end
			if self.Cookoff and JMod.LinCh(FuelLeft, 0, self.MaxResource * 10) then
				self:DoCookoff()
			end
		end
		if self.CustomThink then return self:CustomThink() end
	end

	function ENT:DoCookoff()
		if not(self.Cookoff) then return end
		self.Cookoff = false
		local FuelLeft = self:GetResource()
		timer.Simple(math.Rand(0, 1), function()
			if not(IsValid(self)) then return end
			local Explodes, Boolets, Flames = 0, 0, 0
			if self.Explosive then Explodes = math.max(FuelLeft * self.Explosive * 0.05, 1) end
			if self.IsBoolet then Boolets = math.max(FuelLeft * self.IsBoolet * 1, 1) end
			if self.Flammable and (self.Flammable > 0.5) then Flames = math.max(FuelLeft * self.Flammable * 0.05, 1) end
			JMod.EnergeticsCookoff(self:GetPos(), self, FuelLeft / self.MaxResource, Explodes, Boolets, Flames)
			if self.Fumigate then
				for i = 1, FuelLeft * 0.2 do
					timer.Simple(i / 200, function()
						local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
						Gas:SetPos(SelfPos)
						JMod.SetEZowner(Gas, Owner)
						Gas:Spawn()
						Gas:Activate()
						Gas.Canister = self
						Gas.CurVel = self:GetVelocity() + VectorRand()
					end)
				end
			end
			self:SetEZsupplies(self.EZsupplies, 0)
			SafeRemoveEntityDelayed(self, 1)
		end)
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		if not(ent:GetPersistent()) and (ent.AdminOnly and ent.AdminOnly == true) and not(JMod.IsAdmin(ply)) then
			SafeRemoveEntity(ent)

			return
		end
		local Time = CurTime()
		JMod.SetEZowner(self, ply)
		ent.NextLoad = Time + math.random(1, 5)
		ent.NextCombine = Time + math.random(1, 5)
		self.NextFireThink = Time + 1
	end

	function ENT:OnRemove()
		--
	end
elseif CLIENT then
	function ENT:Initialize()
		if self.Color then
			self:SetColor(self.Color)
		end
	end--]]
end
