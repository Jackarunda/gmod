-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ IFAK"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
---

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Pop")
end

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
		self:SetModel("models/jmod/props/ifak_packet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(10)
				Phys:Wake()
			end
		end)
		---
		self:SetPop(2)
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos = self:GetPos()

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			sound.Play("Wood_Solid.Break", Pos)
			SafeRemoveEntityDelayed(self, 1)
		end
	end

	function ENT:Use(activator)
		local Alt = JMod.IsAltUsing(activator)

		if Alt then
			local Used = false
			local Helf, Max = activator:Health(), activator:GetMaxHealth()
			activator.EZhealth = activator.EZhealth or 0
			local Missing = Max - (Helf + activator.EZhealth)
			if Missing > 0 then
				local AddAmt = math.min(Missing, 5 * JMod.Config.Tools.Medkit.HealMult)
				activator.EZhealth = activator.EZhealth + AddAmt
				JMod.ResourceEffect(JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES, self:LocalToWorld(self:OBBCenter()), nil, 1)
				--
				--self:Remove()
				Used = true
			end
			if activator.EZbleeding and (activator.EZbleeding > 0) then
				activator:PrintMessage(HUD_PRINTCENTER, "stopping bleeding")
				activator.EZbleeding = math.Clamp(activator.EZbleeding - JMod.Config.Tools.Medkit.HealMult * 50, 0, 9e9)
				activator:ViewPunch(Angle(math.Rand(-2, 2), math.Rand(-2, 2), math.Rand(-2, 2)))
				--self:Remove()
				Used = true
			end
			if Used then
				self:SetPop(self:GetPop() - 1)
			end
			if self:GetPop() <= 0 then
				self:Remove()
			end
		else
			JMod.Hint(activator, "ifak")
			activator:PickupObject(self)
		end
	end

	function ENT:Think()
		if self:GetPop() <= 0 then
			self:Remove()
		end
	end

	function ENT:OnRemove()
		--
	end
	
elseif CLIENT then
	function ENT:Initialize()
		--
	end

	function ENT:Draw()
		local Matricks = Matrix()
		Matricks:Scale(Vector(1*(self:GetPop()/1), 1, 1))
		self:EnableMatrix("RenderMultiply", Matricks)
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezifakpacket", "EZ IFAK Packet")
end
