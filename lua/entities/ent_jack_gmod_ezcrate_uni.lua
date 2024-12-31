-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Misc."
ENT.Information = ""
ENT.PrintName = "EZ Storage Crate"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.KeepJModInv = true

---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ItemCount")
end

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

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		--self:SetModelScale(1.5)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:SetItemCount(0)

		self.MaxItems = JMod.EZsmallCrateSize or 100 * JMod.Config.QoL.InventorySizeMult
		self.NextLoad = 0
		--self.Items = self.Items or {}

		timer.Simple(.01, function()
			self:CalcWeight()
		end)
	end

	function ENT:CalcWeight()
		JMod.UpdateInv(self)
		--self:GetPhysicsObject():SetMass(50 + (self:GetItemCount() / self.MaxItems) * 250)
		self:GetPhysicsObject():SetMass(50 + self.JModInv.weight)
		self:GetPhysicsObject():Wake()
		self:SetItemCount(math.ceil(self.JModInv.volume / math.max(JMod.Config.QoL.InventorySizeMult, 0.01)))
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.DeltaTime > 0.2) and (data.Speed > 100) then
			self:EmitSound("Wood_Crate.ImpactHard")
			self:EmitSound("Wood_Box.ImpactHard")
		end

		if self.NextLoad > CurTime() then return end
		local ent = data.HitEntity

		local Vol = JMod.GetItemVolumeWeight(ent)
		if Vol ~= nil then
			if ent.JModEZstorable and ent:IsPlayerHolding() then
				self.NextLoad = CurTime() + 0.5
				timer.Simple(0, function()
					if IsValid(self) and IsValid(ent) then
						JMod.AddToInventory(self, ent)
						self:CalcWeight()
					end
				end)
				--self:SetItemCount(self:GetItemCount() + 1)
			end
			--[[local Class = ent:GetClass()
			local Vol = (self.Items[Class] and self.Items[Class][2]) or math.ceil(ent:GetPhysicsObject():GetVolume() / JMod.VOLUMEDIV)

			if ent.JModEZstorableVolume then
				Vol = ent.JModEZstorableVolume
			end

			if ent.JModEZstorable and ent:IsPlayerHolding() and (not ent.GetState or ent:GetState() == 0) and self:GetItemCount() + Vol <= self.MaxItems then
				self.NextLoad = CurTime() + 0.5

				self.Items[Class] = {(self.Items[Class] and self.Items[Class][1] or 0) + 1, Vol}

				self:SetItemCount(self:GetItemCount() + Vol)

				timer.Simple(0, function()
					SafeRemoveEntity(ent)
				end)
			end--]]
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() > self.DamageThreshold then
			local Pos = self:GetPos()
			sound.Play("Wood_Crate.Break", Pos)
			sound.Play("Wood_Box.Break", Pos)

			--[[for class, tbl in pairs(self.Items) do
				for i = 1, tbl[1] do
					local ent = ents.Create(class)
					ent:SetPos(self:GetPos() + VectorRand() * 10)
					ent:SetAngles(AngleRand())
					ent:Spawn()
					ent:Activate()
				end
			end--]]

			self:Remove()
		end
	end

	function ENT:Use(activator)
		self:CalcWeight()
		--if self:GetItemCount() <= 0 then return end
		JMod.OpenEntityInventory(self, activator)
	end

	function ENT:Think()
	end

	--pfahahaha
	function ENT:OnRemove()
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		if not(ent:GetPersistent()) and (ent.AdminOnly and ent.AdminOnly == true) and not(JMod.IsAdmin(ply)) then
			SafeRemoveEntity(ent)
		end
		ent.NextLoad = 0
	end
	--aw fuck you
elseif CLIENT then
	local TxtCol = Color(10, 10, 10, 220)

	function ENT:Draw()
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(Pos)
		local DetailDraw = Closeness < 45000 -- cutoff point is 500 units when the fov is 90 degrees
		self:DrawModel()

		if DetailDraw then
			local Up, Right, Forward, ItemCount = Ang:Up(), Ang:Right(), Ang:Forward(), tostring(self:GetItemCount())
			Ang:RotateAroundAxis(Ang:Right(), 90)
			Ang:RotateAroundAxis(Ang:Up(), -90)
			cam.Start3D2D(Pos + Up * 10 - Forward * 19.8 + Right, Ang, .15)
			draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil-S", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("STORAGE", "JMod-Stencil", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("Capacity: " .. ItemCount .. "/100", "JMod-Stencil-S", 0, 70, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(), 180)
			cam.Start3D2D(Pos + Up * 10 + Forward * 20.1 - Right, Ang, .15)
			draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil-S", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("STORAGE", "JMod-Stencil", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText("Capacity: " .. ItemCount .. "/100", "JMod-Stencil-S", 0, 70, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
end
