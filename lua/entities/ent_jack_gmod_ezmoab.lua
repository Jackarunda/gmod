-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Mega Bomb"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.EZrackOffset = nil
ENT.EZrackAngles = nil
ENT.EZbombBaySize = nil
ENT.EZguidable = false
---
ENT.Model = "models/hunter/blocks/cube075x6x075.mdl"
ENT.Mass = 600
ENT.DetSpeed = 1000
ENT.DetType = "dualdet"
ENT.Durability = 200

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

---
if SERVER then
	function ENT:JModEZremoteTriggerFunc(ply)
		if not (IsValid(ply) and ply:Alive() and (ply == self.EZowner)) then return end
		if not (self:GetState() == STATE_ARMED) then return end
		self:Detonate()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 100), JMod.GetEZowner(self)

		--JMod.Sploom(Att,SelfPos,500)
		timer.Simple(.1, function()
			JMod.BlastDamageIgnoreWorld(SelfPos, Att, nil, 600, 600)
		end)

		---
		util.ScreenShake(SelfPos, 1000, 10, 5, 8000)
		local Eff = "pcf_jack_moab"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "pcf_jack_moab_air"
		end

		for i = 1, 10 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 150, math.random(80, 110))
		end

		---
		for k, ply in player.Iterator() do
			local Dist = ply:GetPos():Distance(SelfPos)

			if (Dist > 1000) and (Dist < 15000) then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.ogg", 55, 100)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
					util.ScreenShake(ply:GetPos(), 1000, 10, 5, 100)
				end)
			end
		end

		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 300), 3000, 200)

		timer.Simple(.3, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 6000, 200)
		end)

		timer.Simple(.6, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 9000, 200)
		end)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 3000)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 20)
		JMod.BlastDoors(self, SelfPos, 20)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("GiantScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:AeroDragThink()
		JMod.AeroDrag(self, self:GetRight(), 10)
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/chappi/moab.mdl")
		self.Mdl:SetModelScale(.75, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end

	function ENT:Think()
	end

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Right(), 90)
		Ang:RotateAroundAxis(Ang:Right(), -90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos - Ang:Right() * 17 + Ang:Up() * 6 - Ang:Forward() * 6)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end

	language.Add("ent_jack_gmod_ezmoab", "EZ Mega Bomb")
end
