-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezbomb"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Thermonuclear Bomb"
ENT.Spawnable = true
ENT.AdminOnly = true
---
ENT.JModPreferredCarryAngles = Angle(90, 0, 0)
ENT.EZrackOffset = nil
ENT.EZrackAngles = nil
ENT.EZbombBaySize = nil
---
ENT.EZguidable = false
ENT.Model = "models/hunter/blocks/cube1x4x1.mdl"
ENT.Mass = 400
ENT.DetSpeed = 1000
ENT.DetType = "dualdet"
ENT.Durability = 200

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

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
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/nuke_arm.ogg", 70, 80)
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
		net.WriteFloat(1.1)
		net.Broadcast()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 100), JMod.GetEZowner(self)
		---
		SendClientNukeEffect(SelfPos, 9e9)
		util.ScreenShake(SelfPos, 1000, 15, 15, 50000)

		---
		for i = 0, 100 do
			timer.Simple(i / 10, function()
				for k, playa in player.Iterator() do
					playa:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", 60, 80 - i / 2)
				end
			end)
		end

		for i = 1, 5 do
			timer.Simple(i * 2, function()
				if i > 6 then
					JMod.DecalSplosion(SelfPos + Vector(0, 0, i * 350), "GiantScorch", 40000, 20)
				end

				SendClientNukeEffect(SelfPos, 9e9)
			end)
		end

		for i = 7, 17 do
			timer.Simple(i, function()
				local Pof = EffectData()
				Pof:SetOrigin(SelfPos)
				util.Effect("eff_jack_gmod_ezthermonuke", Pof, true, true)

				if i == 10 then
					--[[for j = 1, 10 do
						timer.Simple(j / 5, function()
							for k = 1, 30 * JMod.Config.Particles.NuclearRadiationMult do
								local Gas = ents.Create("ent_jack_gmod_ezfalloutparticle")
								Gas:SetPos(SelfPos)
								JMod.SetEZowner(Gas, Att)
								Gas:Spawn()
								Gas:Activate()
								Gas.CurVel = (VectorRand() * math.random(1, 1000) + Vector(0, 0, 2000 * JMod.Config.Particles.NuclearRadiationMult))
							end
						end)
					end]]--
				end
			end)
		end

		---
		for i = 0, 5 do
			timer.Simple(i * 1.5, function()
				if i == 4 then
					game.CleanUpMap()
					-- It's weird having all Things sitting around like normal after a nuke wipes the map.
					for _, v in ipairs(ents.FindByClass("func_breakable_surf")) do
						v:Fire("Break")
					end
					for _, v in ipairs(ents.FindByClass("prop_physics")) do
						local Phys = v:GetPhysicsObject()
						if IsValid(Phys) then
							Phys:ApplyForceOffset((SelfPos - v:GetPos()) * 10000, v:GetPos() + VectorRand() * 100)
						end
					end
				else
					for k, ply in player.Iterator() do
						local Dmg = DamageInfo()
						Dmg:SetDamagePosition(SelfPos)
						Dmg:SetDamageType(DMG_BLAST)
						Dmg:SetDamage(2000)
						Dmg:SetAttacker(Att)
						Dmg:SetInflictor((IsValid(self) and self) or game.GetWorld())
						Dmg:SetDamageForce((ply:GetPos() - SelfPos):GetNormalized() * 9e9)
						ply:TakeDamageInfo(Dmg)
					end
				end
			end)
		end

		---
		if IsValid(self) then
			self:Remove()
		end
	end

	function ENT:OnRemove()
	end

	--
	function ENT:AeroDragThink()
		JMod.AeroDrag(self, self:GetRight(), 8)
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
		self.Mdl = ClientsideModel("models/thedoctor/tsar.mdl")
		self.Mdl:SetModelScale(.6, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end

	local Trefoil = Material("png_jack_gmod_radiation.png")

	local Verses = {"And I saw when he opened the sixth seal, and there was a great earthquake; and the sun became black as sackcloth of hair, and the whole moon became as blood;", "and the stars of the heaven fell unto the earth, as a fig tree casteth her unripe figs when she is shaken of a great wind.", "And the heaven was removed as a scroll when it is rolled up; and every mountain and island were moved out of their places.", "And the kings of the earth, and the princes, and the chief captains, and the rich, and the strong, and every bondman and freeman, hid themselves in the caves and in the rocks of the mountains;", "and they say to the mountains and to the rocks, Fall on us, and hide us from the face of him that sitteth on the throne, and from the wrath of the Lamb:", "for the great day of their wrath is come; and who is able to stand?"}

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos - Ang:Right() * 80 - Ang:Up() * 13)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
		---
		local Ang, Pos = self:GetAngles(), self:GetPos()
		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(Pos)
		local DetailDraw = Closeness < 21000

		if DetailDraw then
			local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
			Ang:RotateAroundAxis(Ang:Right(), 90)
			Ang:RotateAroundAxis(Ang:Up(), -90)
			cam.Start3D2D(Pos + Up * 17 + Right * 35 - Forward * 25, Ang, .05)
			surface.SetDrawColor(255, 255, 255, 120)
			surface.SetMaterial(Trefoil)
			surface.DrawTexturedRect(-128, 160, 256, 256)

			for k, v in pairs(Verses) do
				draw.SimpleText(v, "JMod-Stencil-XS", 0, 420 + k * 20, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			cam.End3D2D()
			---\
			Ang:RotateAroundAxis(Ang:Right(), 180)
			cam.Start3D2D(Pos + Up * 17 + Right * 35 + Forward * 26, Ang, .05)
			surface.SetDrawColor(255, 255, 255, 120)
			surface.SetMaterial(Trefoil)
			surface.DrawTexturedRect(-128, 160, 256, 256)

			for k, v in pairs(Verses) do
				draw.SimpleText(v, "JMod-Stencil-XS", 0, 420 + k * 20, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

			cam.End3D2D()
		end
	end

	language.Add("ent_jack_gmod_eznuke_big", "EZ Thermonuclear Bomb")
end
