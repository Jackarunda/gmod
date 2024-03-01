-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ Egg"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = true

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props_phx/misc/egg.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		--
		self:PrecacheGibs()
		--
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(5)
				Phys:Wake()
			end
		end)
	end

	function ENT:PhysicsCollide(data, physobj)
		--
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		if JMod.LinCh(dmginfo:GetDamage(), 5, 10) then
			self:Break()
		end
	end

	local Goodies = {
		"nutrition",
		"Pistol Round",
		"Shotgun Round"
	}

	function ENT:Use(activator)
		if not IsValid(activator) then return end
		local Goodie = table.Random(Goodies)
		if Goodie == "nutrition" then
			if JMod.ConsumeNutrients(activator, math.random(1, 5)) then
				sound.Play("snds_jack_gmod/nom" .. math.random(1, 5) .. ".wav", self:GetPos(), 60, math.random(90, 110))
				self:Break()
			end
		else
			activator:GiveAmmo(math.random(1, 5), Goodie, false)
			self:Break()
		end
	end

	function ENT:Break()
		self:EmitSound("physics/body/body_medium_break4.wav", 100, math.random(80, 120), .5, CHAN_AUTO)
		self:GibBreakServer(Vector(0, 0, 0))
		self:Remove()
	end

	function ENT:Think()
		--
	end

	function ENT:OnRemove()
		--
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
	end
	
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezanomaly_egg", "EZ Egg")
end
