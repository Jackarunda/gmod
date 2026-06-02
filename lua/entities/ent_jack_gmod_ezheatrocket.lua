-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezherocket"
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ HEAT Rocket"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZrackOffset = Vector(0, -1.5, 0)
ENT.EZrackAngles = Angle(0, 0, 0)
ENT.EZrocket = true
---
-- Inherits the HE rocket motion controller. Only the differences below.
ENT.PhysMaterial = "metal"
ENT.ClientModelSkin = 2
ENT.ThrustJitter = 0
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED, STATE_LAUNCHED = -1, 0, 1, 2

if SERVER then
	function ENT:Detonate()
		if self.NextDet > CurTime() then return end
		if self.Exploded then return end
		self.Exploded = true
		local Dir = -self:GetRight()
		local SelfPos, Att = self:GetPos(), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 10)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 1500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)

		---
		local BlastDmg = DamageInfo()
		BlastDmg:SetDamageType(DMG_BLAST)
		BlastDmg:SetDamage(100)
		BlastDmg:SetAttacker(Att)
		BlastDmg:SetInflictor(self)
		BlastDmg:SetDamageForce(Dir * 100)
		util.BlastDamageInfo(BlastDmg, SelfPos + Dir * 30, 200)

		local BlastTr = util.QuickTrace(SelfPos + Dir * 20, Dir * 100, self)

		if BlastTr.Hit and (BlastTr.HitWorld or IsValid(BlastTr.Entity)) then
			JMod.RicPenBullet(self, SelfPos, Dir, 5000, true, false, 1, .5)
		end

		for k, ent in pairs(ents.FindInSphere(SelfPos, 200)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 2)
		JMod.BlastDoors(self, SelfPos, 2)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos - Dir * 100, Dir * 300)

			if Tr.Hit then
				util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		self:Remove()
		local Ang = self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(), -90)

		timer.Simple(.1, function()
			ParticleEffect("50lb_air", SelfPos + Dir * 130, Ang)
			ParticleEffect("50lb_air", SelfPos, Ang)
			ParticleEffect("50lb_air", SelfPos - Dir * 50, Ang)
		end)
	end

	-- HEAT traces its backblast so it only damages things actually behind it.
	function ENT:Backblast()
		local Owner, Behind = JMod.GetEZowner(self), -self:GetNoseDir()
		for i = 1, 4 do
			local Tr = util.QuickTrace(self:GetPos(), Behind * i * 40, {self, self.DropOwner})
			if Tr.Hit then
				util.BlastDamage(self, Owner, Tr.HitPos, 50, 50)
			end
		end
	end
elseif CLIENT then
	language.Add("ent_jack_gmod_ezheatrocket", "EZ HEAT Rocket")
end
