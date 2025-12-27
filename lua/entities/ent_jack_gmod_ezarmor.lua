-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Armor"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
---
ENT.JModEZstorable = true

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()
		JMod.Hint(ply, self.ClassName)
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self.Specs = JMod.ArmorTable[self.ArmorName]
		
		-- Warn if armor definition is missing
		if not self.Specs then
			print("[JMod] WARNING: Armor entity spawned with ArmorName '" .. tostring(self.ArmorName) .. "' but no definition exists in JMod.ArmorTable!")

			-- Remove self to prevent errors
			SafeRemoveEntity(self)
			
			return
		end
		
		self:SetModel(self.entmdl or self.Specs.mdl)
		self:SetMaterial(self.Specs.mat or "")

		if self.Specs.lbl then
			self:SetDTString(0, self.Specs.lbl)
		end

		if self.Specs.clr then
			self:SetColor(Color(self.Specs.clr.r, self.Specs.clr.g, self.Specs.clr.b))
		end

		--self:PhysicsInitBox(Vector(-10,-10,-10),Vector(10,10,10))
		if self.ModelScale and not self.Specs.gayPhysics then
			self:SetModelScale(self.ModelScale)
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(10)
		self.Durability = self.Durability or self.Specs.dur or 1

		if self.Specs.chrg then
			self.ArmorCharges = self.ArmorCharges or table.FullCopy(self.Specs.chrg)
		end

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.EZID = self.EZID or JMod.GenerateGUID()
	end

	--[[function ENT:TryLoadResource(typ, amt)
		if (amt <= 0) then return 0 end
		if self.ArmorCharges then
			for k, v in pairs(self.ArmorCharges) do
				if typ == v.typ then
					local CurAmt = v.amt or 0
					local Take = math.min(amt, v.max - CurAmt)

					if Take > 0 then
						v.amt = CurAmt + Take
						amt = amt - Take

						return Take
					end
				end
			end
		end

		return 0
	end--]]

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self:EmitSound(util.GetSurfaceData(data.OurSurfaceProps).impactSoftSound)
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() >= 5 then
			self.Durability = self.Durability - dmginfo:GetDamage() / 2

			if self.Durability <= 0 then
				if self.Specs.eff and self.Specs.eff.explosive and not(self.exploded) then
					self.exploded = true
					local FireAmt = 2--((Info.chrg and Info.chrg.fuel) or 1) / 10
					JMod.EnergeticsCookoff(self:GetPos(), dmginfo:GetAttacker(), 1, 1, 0, FireAmt)
				end
				self:Remove()
			end
		end
	end

	function ENT:Use(activator)
		local Alt = JMod.IsAltUsing(activator)

		if Alt then
			if activator.JackyArmor and (#table.GetKeys(activator.JackyArmor) > 0) then
				activator:PrintMessage(HUD_PRINTTALK, "Legacy armor already equipped")

				return 
			end

			-- Validate that this armor has a valid ArmorTable entry before equipping
			if not JMod.ArmorTable[self.ArmorName] then
				if activator:IsPlayer() then
					activator:PrintMessage(HUD_PRINTTALK, "ERROR: Cannot equip '" .. tostring(self.ArmorName) .. "' - armor definition not found!")
				end
				
				return
			end

			if self.Specs.clrForced then
				JMod.EZ_Equip_Armor(activator, self)
			else
				net.Start("JMod_ArmorColor")
				net.WriteEntity(self)
				net.WriteBool(false)
				net.WriteFloat(self.Durability)
				net.WriteFloat(self.Specs.dur)
				net.Send(activator)
			end

			if self.ArmorName == "Headset" then
				JMod.Hint(activator, "armor friends")
			else
				JMod.Hint(activator, "inventory")
			end
			if self.Specs.effects and self.Specs.effects.parachute then
				JMod.Hint(activator, "parachute")
			end
		else
			activator:PickupObject(self)
			JMod.Hint(activator, "armor wear")
		end
		--activator:EmitSound("snd_jack_clothequip.ogg",70,100)
		--activator:EmitSound("snd_jack_gmod/armorstep1.ogg",70,100)--5
		--activator:EmitSound("snd_jack_gear1.ogg",70,100)--6
	end
elseif CLIENT then
	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(Pos)
		local DetailDraw = Closeness < 18000 -- cutoff point is 200 units when the fov is 90 degrees
		self:DrawModel()
		local Label = self:GetDTString(0)

		if DetailDraw and Label and Label ~= "" then
			local Up, Right, Forward, TxtCol = Ang:Up(), Ang:Right(), Ang:Forward(), Color(0, 0, 0, 220)
			Ang:RotateAroundAxis(Ang:Up(), 90)
			cam.Start3D2D(Pos + Up * 4.3 - Right * 2 + Forward * 6, Ang, .03)
			draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(Label, "JMod-Stencil", 0, 100, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_ezarmor", "EZ Armor")
end
