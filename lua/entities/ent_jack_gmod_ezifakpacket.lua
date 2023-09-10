-- Jackarunda 2023
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.PrintName = "EZ IFAK"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.JModEZstorable = true
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
		self:SetModel("models/jmod/props/ifak_packet.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(8)
				Phys:Wake()
			end
		end)
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
		local Pos, State = self:GetPos(), self:GetState()

		if JMod.LinCh(dmginfo:GetDamage(), 30, 100) then
			sound.Play("Wood_Solid.Break", Pos)
			SafeRemoveEntityDelayed(self, 1)
		end
	end

	function ENT:Use(activator)
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

		if Alt then
			if activator.EZbleeding > 0 then
				activator:PrintMessage(HUD_PRINTCENTER, "stopping bleeding")
				activator.EZbleeding = math.Clamp(activator.EZbleeding - JMod.Config.Tools.Medkit.HealMult * 15, 0, 9e9)
				activator:ViewPunch(Angle(math.Rand(-2, 2), math.Rand(-2, 2), math.Rand(-2, 2)))
				--
				local Helf, Max = Ent:Health(), Ent:GetMaxHealth()
				Ent.EZhealth = Ent.EZhealth or 0
				local Missing = Max - (Helf + Ent.EZhealth)
				local AddAmt = math.min(Missing, 5 * JMod.Config.Tools.Medkit.HealMult)
				Ent.EZhealth = Ent.EZhealth + AddAmt

				self:Remove()

				return
			else
				JMod.Hint(activator, "ifak")
			end
		else
			activator:PickupObject(self)
		end
	end

	function ENT:Think()
		-- Haha
	end

	function ENT:OnRemove()
		--
	end
	
elseif CLIENT then

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezifakpacket", "EZ IFAK Packet")
end
