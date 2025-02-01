-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Micro Nuclear Bomb"
ENT.Spawnable = true
ENT.AdminOnly = true
---
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.EZrackOffset = Vector(0, 0, 10)
ENT.EZrackAngles = Angle(0, 0, 90)
ENT.EZbombBaySize = 50
---
ENT.EZguidable = false
ENT.Model = "models/props_junk/TrashBin01a.mdl"
ENT.Mass = 200
ENT.DetSpeed = 1000
ENT.DetType = "dualdet"
ENT.Durability = 200

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:JModEZremoteTriggerFunc(ply)
		if not (IsValid(ply) and ply:Alive() and (ply == self.EZowner)) then return end
		if not (self:GetState() == STATE_ARMED) then return end
		self:Detonate()
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/nuke_arm.ogg", 70, 100)
				self.EZdroppableBombArmedTime = CurTime()
				JMod.Hint(activator, "dualdet")
			else
				JMod.Hint(activator, "double tap to arm")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 70, 100)
				self.EZdroppableBombArmedTime = nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
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
			JMod.BlastDamageIgnoreWorld(SelfPos, Att, nil, 1500 * Power, 3000 * Range)
		end)

		---
		SendClientNukeEffect(SelfPos, 12000)
		util.ScreenShake(SelfPos, 1000, 10, 10, 2000 * Range)
		local Eff = "pcf_jack_nuke_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "pcf_jack_nuke_air"
		end

		for i = 1, 19 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 150, math.random(80, 110))
		end

		---
		if (JMod.Config.QoL.NukeFlashLightEnabled) then
			local NukeFlash = ents.Create("ent_jack_gmod_nukeflash")
			NukeFlash:SetPos(SelfPos + Vector(0, 0, 32))
			NukeFlash.LifeDuration = 10
			NukeFlash:Spawn()
			NukeFlash:Activate()
		end

		---
		for k, ply in player.Iterator() do
			local Dist = ply:GetPos():Distance(SelfPos)

			if Dist > 1000 then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/nuke_far.ogg", 55, 100)
					util.ScreenShake(ply:GetPos(), 1000, 10, 10, 100)
				end)
			end
		end

		---
		for h = 1, 80 do
			timer.Simple(h / 10, function()
				local ThermalRadiation = DamageInfo()
				ThermalRadiation:SetDamageType(DMG_BURN)
				ThermalRadiation:SetDamage((50 / h) * Power)
				ThermalRadiation:SetAttacker(Att)
				ThermalRadiation:SetInflictor(game.GetWorld())
				util.BlastDamageInfo(ThermalRadiation, SelfPos, 20000 * Range)
			end)
		end

		for i = 1, 20 do
			timer.Simple(i / 4, function()
				SelfPos = SelfPos + Vector(0, 0, 100)
				---
				local powa, renj = 10 + i * 2.5 * Power, 1 + i / 10 * Range

				---
				if i == 1 then
					JMod.EMP(SelfPos, renj * 20000)

					for k, ent in pairs(ents.FindInSphere(SelfPos, renj)) do
						if ent:GetClass() == "npc_helicopter" then
							ent:Fire("selfdestruct", "", math.Rand(0, 2))
						end
					end
				end

				---
				util.BlastDamage(game.GetWorld(), Att, SelfPos, 1600 * i * Range, 300 / i * Power)

				---
				JMod.WreckBuildings(nil, SelfPos, powa, renj, i < 3)
				JMod.BlastDoors(nil, SelfPos, powa, renj, i < 3)
				---
				SendClientNukeEffect(SelfPos, 2000 * renj)

				---
				if i == 10 then
					JMod.DecalSplosion(SelfPos + Vector(0, 0, 500) + Vector(0, 0, 1000), "GiantScorch", 8000, 40)
				end

				---
				if i == 20 then
					for j = 1, 10 do
						timer.Simple(j / 10, function()
							for k = 1, 15 * JMod.Config.Particles.NuclearRadiationMult do
								local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
								Gas:SetPos(SelfPos + Vector(math.random(-500, 500), math.random(-500, 500), math.random(0, 200)))
								JMod.SetEZowner(Gas, Att)
								Gas:Spawn()
								Gas:Activate()
								Gas.CurVel = (Vector(math.random(-500, 500), math.random(-500, 500), math.random(800, 1200)) * JMod.Config.Particles.NuclearRadiationMult)
							end
						end)
					end
				end
			end)
		end

		self:Remove()

		timer.Simple(0, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:AeroDragThink()
		JMod.AeroDrag(self, self:GetUp())
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
		self.Mdl = ClientsideModel("models/thedoctor/fatman.mdl")
		self.Mdl:SetModelScale(.3, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end

	function ENT:Think()
	end

	local Trefoil = Material("png_jack_gmod_radiation.png")

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Forward(), -90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos + Ang:Right() * 7)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
		---
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(Pos)
		local DetailDraw = Closeness < 21000

		if DetailDraw then
			local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
			Ang:RotateAroundAxis(Ang:Forward(), -90)
			cam.Start3D2D(Pos - Up * 23.7 - Right * 9.6 + Forward * 0, Ang, .025)
			surface.SetDrawColor(255, 255, 255, 120)
			surface.SetMaterial(Trefoil)
			surface.DrawTexturedRect(-128, 160, 256, 256)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Forward(), 180)
			cam.Start3D2D(Pos - Up * 9.4 + Right * 9.9 + Forward * 0, Ang, .025)
			surface.SetDrawColor(255, 255, 255, 120)
			surface.SetMaterial(Trefoil)
			surface.DrawTexturedRect(-128, 160, 256, 256)
			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_eznuke", "EZ Micro Nuclear Bomb")
end
