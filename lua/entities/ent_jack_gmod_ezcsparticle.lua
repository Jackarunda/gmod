﻿-- Based off of JMOD EZ Gas Particle, created by Freaking Fission, uses some code from GChem
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgasparticle"
ENT.PrintName = "EZ CS Gas"
ENT.Author = "Jackarunda, Freaking Fission"
ENT.NoSitAllowed = true
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--
ENT.EZgasParticle = true
ENT.ThinkRate = 1
--

if SERVER then
	function ENT:Initialize()
		local Time = CurTime()
		self:SetMoveType(MOVETYPE_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableCollisions(false)
			phys:EnableGravity(false)
		end
		self.LifeTime = math.random(50, 100) * JMod.Config.Particles.PoisonGasLingerTime
		self.DieTime = Time + self.LifeTime
		self.NextDmg = Time + 2.5
		self.CurVel = self.CurVel or VectorRand()
	end

	function ENT:DamageObj(obj)
		if obj:IsPlayer() then
			
			net.Start("JMod_VisionBlur")
			net.WriteFloat(5 * math.Clamp(1 - faceProt, 0, 1))
			net.Send(obj)
			JMod.Hint(obj, "tear gas")
		elseif obj:IsNPC() then
			obj.EZNPCincapacitate = Time + math.Rand(2, 5)
		end

		JMod.TryCough(obj)

		if math.random(1, 20) == 1 then
			local Dmg, Helf = DamageInfo(), obj:Health()
			Dmg:SetDamageType(DMG_NERVEGAS)
			Dmg:SetDamage(math.random(1, 4) * JMod.Config.Particles.PoisonGasDamage * RespiratorMultiplier)
			Dmg:SetInflictor(self)
			Dmg:SetAttacker(self.EZowner or self)
			Dmg:SetDamagePosition(obj:GetPos())
			obj:TakeDamageInfo(Dmg)
		end
	end

elseif CLIENT then
	local Mat = Material("effects/smoke_b")

	function ENT:Initialize()
		self.Col = Color(255, 255, 255)
		self.Visible = true
		self.Show = true
		self.siz = 1

		timer.Simple(2, function()
			if IsValid(self) then
				self.Visible = math.random(1, 2) == 2
			end
		end)

		self.NextVisCheck = CurTime() + 6
		self.DebugShow = LocalPlayer().EZshowGasParticles

		if self.DebugShow then
			self:SetModelScale(2)
		end
	end

	function ENT:DrawTranslucent()
		if self.DebugShow then
			self:DrawModel()
		end

		local Time = CurTime()

		if self.NextVisCheck < Time then
			self.NextVisCheck = Time + 1
			self.Show = self.Visible and 1 / FrameTime() > 50
		end

		if self.Show then
			local SelfPos = self:GetPos()
			render.SetMaterial(Mat)
			render.DrawSprite(SelfPos, self.siz, self.siz, Color(self.Col.r, self.Col.g, self.Col.b, 10))
			self.siz = math.Clamp(self.siz + FrameTime() * 200, 0, 500)
		end
	end
end
