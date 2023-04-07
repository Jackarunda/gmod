-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Weapons"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Weapon"
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
		ent.HasSpawnAmmo = true
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self.Specs = JMod.WeaponTable[self.WeaponName]
		self:SetModel(self.Specs.mdl)
		self:SetMaterial(self.Specs.mat or "")

		if self.Specs.size then
			self:SetModelScale(self.Specs.size, 0)
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(20)
				Phys:Wake()
			end
		end)

		---
		self.EZID = self.EZID or JMod.GenerateGUID()
		---
		self.MagRounds = self.MagRounds or 0
		self:Activate()
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.1 then
			if data.Speed > 50 then
				self:EmitSound("weapon.ImpactHard")
			elseif data.Speed > 5 then
				self:EmitSound("weapon.ImpactSoft")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)

		if dmginfo:GetDamage() >= 120 then
			self:Remove()
		end
	end

	function ENT:Use(activator)
		local Alt = activator:KeyDown(JMod.Config.AltFunctionKey)

		if Alt then
			activator:PickupObject(self)
		else
			if ArcCW then
				if not activator:HasWeapon(self.Specs.swep) then
					activator:Give(self.Specs.swep)
					local GivenWep = activator:GetWeapon(self.Specs.swep)

					if self.HasSpawnAmmo then
						GivenWep:SetClip1(GivenWep.Primary.ClipSize)
						self.HasSpawnAmmo = false
					else
						GivenWep:SetClip1(self.MagRounds)
					end

					activator:SelectWeapon(self.Specs.swep)
					JMod.Hint(activator, self.Specs.swep)

					if GivenWep.Primary.Ammo == "Arrow" then
						JMod.Hint(activator, "weapon arrows")
					elseif GivenWep.Primary.Ammo == "Black Powder Paper Cartridge" then
						JMod.Hint(activator, "weapon black powder paper cartridges")
					elseif GivenWep.Primary.Ammo == "40mm Grenade" or GivenWep.Primary.Ammo == "Mini Rocket" then
						JMod.Hint(activator, "weapon munitions")
					else
						JMod.Hint(activator, "weapon ammo")
					end

					for k, v in pairs({"weapon drop", "weapon steadiness", "weapon firemodes", "weapon ammotypes"}) do
						timer.Simple(k * 6, function()
							JMod.Hint(activator, v)
						end)
					end
					--print(activator:GetWeapon(self.Specs.swep).Owner)

					self:Remove()
				else
					activator:PickupObject(self)
				end
			else
				activator:PickupObject(self)
				activator:PrintMessage(HUD_PRINTCENTER, "ArcCW Base is missing!")
			end
		end
	end
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezweapon", "EZ Weapon")
end
