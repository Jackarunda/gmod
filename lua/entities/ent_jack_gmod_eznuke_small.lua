-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Nano Nuclear Bomb"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.JModEZstorable = true
---
ENT.JModPreferredCarryAngles = Angle(0, 90, 0)
ENT.EZrackOffset = nil
ENT.EZrackAngles = nil
ENT.EZbombBaySize = 10
---
ENT.EZguidable = false
ENT.Model = "models/chappi/mininuq.mdl"
ENT.Mass = 100
ENT.DetSpeed = 700
ENT.DetType = "dualdet"
ENT.Durability = 120
ENT.SpawnHeight = 10

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:Break()
		if self:GetState() == STATE_BROKEN then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end

		for k = 1, 10 * JMod.Config.Particles.NuclearRadiationMult do
			local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
			Gas:SetPos(self:GetPos())
			JMod.SetEZowner(Gas, JMod.GetEZowner(self))
			Gas:Spawn()
			Gas:Activate()
			Gas.CurVel = (VectorRand() * math.random(1, 50) + Vector(0, 0, 10 * JMod.Config.Particles.NuclearRadiationMult))
		end

		SafeRemoveEntityDelayed(self, 10)
	end

	function ENT:JModEZremoteTriggerFunc(ply)
		if not (IsValid(ply) and ply:Alive() and (ply == self.EZowner)) then return end
		if not (self:GetState() == STATE_ARMED) then return end
		self:Detonate()
	end

	function ENT:Use(activator)
		local State, Alt = self:GetState(), activator:KeyDown(IN_WALK)
		if State < 0 then return end
		JMod.SetEZowner(self, activator)

		if not Alt then
			activator:PickupObject(self)
			JMod.Hint(activator, "arm")
		else
			if State == STATE_OFF then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/nuke_arm.ogg", 70, 140)
				self.EZdroppableBombArmedTime = CurTime()
				JMod.Hint(activator, "dualdet")
			elseif State == STATE_ARMED then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 70, 100)
				self.EZdroppableBombArmedTime = nil
			end
		end
	end

	local function SendClientNukeEffect(pos, range)
		net.Start("JMod_NuclearBlast")
		net.WriteVector(pos)
		net.WriteFloat(range)
		net.WriteFloat(1)
		net.Broadcast()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att, Power, Range = self:GetPos() + Vector(0, 0, 100), JMod.GetEZowner(self), JMod.Config.Explosives.Nuke.PowerMult, JMod.Config.Explosives.Nuke.RangeMult

		--JMod.Sploom(Att,SelfPos,500)
		timer.Simple(.1, function()
			JMod.BlastDamageIgnoreWorld(SelfPos, Att, nil, 600, 800)
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
		SendClientNukeEffect(SelfPos, 8000)
		---
		if (JMod.Config.QoL.NukeFlashLightEnabled) then
			local NukeFlash = ents.Create("ent_jack_gmod_nukeflash")
			NukeFlash:SetPos(SelfPos + Vector(0, 0, 32))
			NukeFlash.LifeDuration = 2
			NukeFlash.MaxAltitude = 1000
			NukeFlash:Spawn()
			NukeFlash:Activate()
		end

		for h = 1, 40 do
			timer.Simple(h / 10, function()
				local ThermalRadiation = DamageInfo()
				ThermalRadiation:SetDamageType(DMG_BURN)
				ThermalRadiation:SetDamage((50 / h) * Power)
				ThermalRadiation:SetAttacker(Att)
				ThermalRadiation:SetInflictor(game.GetWorld())
				util.BlastDamageInfo(ThermalRadiation, SelfPos, 12000)
			end)
		end

		---
		for k, ply in player.Iterator() do
			local Dist = ply:GetPos():Distance(SelfPos)

			if (Dist > 1000) and (Dist < 120000) then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.ogg", 55, 90)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
					util.ScreenShake(ply:GetPos(), 1000, 10, 5, 100)
				end)
			end
		end

		---
		for i = 1, 5 do
			timer.Simple(i / 5, function()
				util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 200 * i), 6000 * Range, 300 * Power)
			end)
		end

		---
		for k, ent in pairs(ents.FindInSphere(SelfPos, 2000)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 15)
		JMod.BlastDoors(self, SelfPos, 15)

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
			local Eff = EffectData()
			Eff:SetOrigin(SelfPos)
			util.Effect("eff_jack_gmod_tinynukeflash", Eff, true, true)
		end)

		---
		timer.Simple(5, function()
			for j = 1, 10 do
				timer.Simple(j / 10, function()
					for k = 1, 5 * JMod.Config.Particles.NuclearRadiationMult do
						local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
						Gas:SetPos(SelfPos)
						JMod.SetEZowner(Gas, Att)
						Gas:Spawn()
						Gas:Activate()
						Gas.CurVel = (VectorRand() * math.random(1, 250) + Vector(0, 0, 600 * JMod.Config.Particles.NuclearRadiationMult))
					end
				end)
			end
		end)
	end

	--
	function ENT:AeroDragThink()
		JMod.AeroDrag(self, self:GetRight(), .5)
	end

	function ENT:PostEntityPaste(ply, ent, createdEntities)
		if not(ent:GetPersistent()) and (ent.AdminOnly and ent.AdminOnly == true) and (JMod.IsAdmin(ply)) then
			JMod.SetEZowner(self, ply)
			if self.EZdroppableBombArmedTime then
				self.EZdroppableBombArmedTime = self.EZdroppableBombArmedTime - CurTime()
			end
		else
			SafeRemoveEntity(ent)
		end
	end

elseif CLIENT then
	function ENT:Initialize()
	end

	function ENT:Think()
	end

	--[[
		self.Mdl=ClientsideModel("models/thedoctor/fatman.mdl")
		self.Mdl:SetModelScale(.4,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		--]]
	function ENT:Draw()
		--local Pos,Ang=self:GetPos(),self:GetAngles()
		--Ang:RotateAroundAxis(Ang:Forward(),-90)
		self:DrawModel()
		--self.Mdl:SetRenderOrigin(Pos+Ang:Right()*7)
		--self.Mdl:SetRenderAngles(Ang)
		--self.Mdl:DrawModel()
	end

	language.Add("ent_jack_gmod_eznuke_small", "EZ Nano Nuclear Bomb")
end
