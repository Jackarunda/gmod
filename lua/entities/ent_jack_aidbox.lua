﻿AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Aid Package"
ENT.Author = "Jackarunda"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.JModPreferredCarryAngles = Angle(-90, 90, 0)

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "PackageName")
end

if SERVER then
	function ENT:Initialize()
		self.Chrimsas = JMod.GetHoliday() == "Christmas"
		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetMaterial((self.Chrimsas and "models/mat_jack_aidbox_Christmas") or "models/mat_jack_aidbox")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self.InitialVel = self.InitialVel or Vector(0, 0, 0)
		local Phys = self:GetPhysicsObject()

		if IsValid(Phys) then
			Phys:Wake()
			Phys:SetMass(200)
			Phys:EnableDrag(false)
			Phys:SetMaterial("metal")
		end

		timer.Simple(.1, function()
			if IsValid(self) then
				self:GetPhysicsObject():SetVelocity(self.InitialVel + VectorRand() * math.Rand(0, 200))
				--self:GetPhysicsObject():AddAngleVelocity(VectorRand() * math.Rand(0, 3000))
			end
		end)

		self.Opacity = self.NoFadeIn and 1 or 0
		self:SetDTFloat(0, self.Opacity)
		self.Parachuted = self:GetDTBool(0)

		if self.Parachuted then
			--self:GetPhysicsObject():SetAngleDragCoefficient(40)
			local Chute = ents.Create("ent_jack_gmod_ezparachute")
			Chute:SetPos(self:LocalToWorld(self:OBBCenter()))
			Chute:SetNW2Entity("Owner", self)
			--Chute.ParachuteName = "Parachute"
			Chute.ParachuteMdl = "models/jessev92/rnl/items/parachute_deployed.mdl"
			Chute.Drag = JMod.Config.RadioSpecs.ParachuteDragMult
			Chute.MdlOffset = 50
			Chute.ChuteColor = Color(255, 255, 255)
			Chute:Spawn()
			Chute:Activate()
			Chute:SetNW2Float("ChuteProg", 2)
			self:SetNW2Bool("EZparachuting", true)
			self.EZparachute = Chute
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.Speed > 2000 and data.DeltaTime > .2 then
			self:EmitSound("Boulder.ImpactHard")
			self:EmitSound("Canister.ImpactHard")
			self:EmitSound("Boulder.ImpactHard")
			self:EmitSound("Canister.ImpactHard")
			self:EmitSound("Boulder.ImpactHard")
			util.ScreenShake(data.HitPos, 99999, 99999, .5, 500)
			local Poof = EffectData()
			Poof:SetOrigin(data.HitPos)
			Poof:SetScale(5)
			Poof:SetNormal(data.HitNormal)
			util.Effect("eff_jack_aidimpact", Poof, true, true)

			local Tr = util.QuickTrace(data.HitPos - data.OurOldVelocity, data.OurOldVelocity * 50, {self})

			if Tr.Hit then
				util.Decal("Rollermine.Crater", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		elseif data.Speed > 80 and data.DeltaTime > .2 then
			self:EmitSound("Canister.ImpactHard")
		end

		--[[if data.DeltaTime > .1 then
			local Phys = self:GetPhysicsObject()
			Phys:SetVelocity(Phys:GetVelocity() / 1.5)
			Phys:AddAngleVelocity(-Phys:GetAngleVelocity() / 1.30)
		end--]]
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)
	end

	local function SpawnItem(itemClass, pos, owner, resourceAmt)
		local ItemNameParts = string.Explode(" ", itemClass)

		if ItemNameParts and ItemNameParts[1] == "FUNC" then
			if ItemNameParts[2] and JMod.LuaConfig.BuildFuncs[ItemNameParts[2]] then
				JMod.LuaConfig.BuildFuncs[ItemNameParts[2]](owner, pos + Vector(0, 0, 5), Angle(0, 0, 0))
			end
		else
			local Yay = ents.Create(itemClass)
			Yay:SetPos(pos + VectorRand() * math.Rand(0, 30))
			Yay:SetAngles(VectorRand():Angle())
			Yay:Spawn()
			Yay:Activate()

			if resourceAmt then
				Yay:SetResource(resourceAmt)
			end

			if IsValid(Yay) then
				local YayPhys = Yay:GetPhysicsObject()
				JMod.SetEZowner(Yay, owner)

				-- this arrests overlap-ejection velocity so items don't thwack players
				timer.Simple(.025, function()
					if IsValid(YayPhys) then
						YayPhys:SetVelocity(Vector(0, 0, 0))
					end
				end)

				timer.Simple(.05, function()
					if IsValid(YayPhys) then
						YayPhys:SetVelocity(Vector(0, 0, 0))
					end
				end)

				timer.Simple(.1, function()
					if IsValid(YayPhys) then
						YayPhys:SetVelocity(Vector(0, 0, 0))
					end
				end)
			end
		end
	end

	local function SpawnContents(contents, pos, owner)
		local typ = type(contents)

		if typ == "string" then
			SpawnItem(contents, pos, owner)

			return
		end

		if typ == "table" then
			for k, v in pairs(contents) do
				typ = type(v)

				if typ == "string" then
					SpawnItem(v, pos, owner)
				elseif typ == "table" then
					-- special case, this is a randomized table
					if v[1] == "RAND" then
						local Amt = v[#v]
						local Items = {}

						for i = 2, #v - 1 do
							table.insert(Items, v[i])
						end

						for i = 1, Amt do
							SpawnItem(table.Random(Items), pos, owner)
						end
					else -- the only other supported table contains a count as [2] and potentially a resourceAmt as [3]
						for i = 1, v[2] or 1 do
							SpawnItem(v[1], pos, owner, v[3] or nil)
						end
					end
				end
			end
		end
	end

	function ENT:Use(activator, caller)
		--if true then return end
		local Time = CurTime()
		if not((activator.NextAidBoxOpenTime or 0) < Time) then activator:PrintMessage(HUD_PRINTCENTER, "No opening in rapid sucession") return end
		local Pos = self:LocalToWorld(self:OBBCenter() + Vector(0, 0, 10))
		local Up = self:GetUp()
		local Right = self:GetRight()
		local Forward = self:GetForward()
		local Ang = self:GetAngles()
		local AngLat = self:GetAngles()
		AngLat:RotateAroundAxis(AngLat:Forward(), 90)
		local AngLin = self:GetAngles()
		AngLin:RotateAroundAxis(AngLin:Right(), 90)
		self:MakeSide(Pos + Up * 15, Ang, Up)
		self:MakeSide(Pos - Up * 15, Ang, -Up)
		self:MakeSide(Pos + Right * 15, AngLat, Right)
		self:MakeSide(Pos - Right * 15, AngLat, -Right)
		self:MakeSide(Pos + Forward * 15, AngLin, Forward)
		self:MakeSide(Pos - Forward * 15, AngLin, -Forward)
		local Poof = EffectData()
		Poof:SetOrigin(Pos)
		Poof:SetScale(2)
		util.Effect("eff_jack_aidopen", Poof, true, true)
		local Snd = (self.Chrimsas and "snds_jack_gmod/rapid_present_unwrap.wav") or "snd_jack_aidboxopen.wav"
		self:EmitSound(Snd, 75, 100)

		SpawnContents(self.Contents or {
			{"item_ammo_pistol", 1}
		}, Pos, activator)

		--JackaGenericUseEffect(activator)
		if activator:IsPlayer() then
			local Wep = activator:GetActiveWeapon()

			if IsValid(Wep) then
				Wep:SendWeaponAnim(ACT_VM_DRAW)
			end

			activator:ViewPunch(Angle(1, 0, 0))
			activator:SetAnimation(PLAYER_ATTACK1)
		end

		local Snd = (self.Chrimsas and "snds_jack_gmod/merry_Christmas_group_shout.wav") or "snd_jack_itemsget.wav"

		timer.Simple(2, function()
			sound.Play(Snd, Pos, 75, 100)
		end)

		activator.NextAidBoxOpenTime = Time + 2
		self:Remove()
	end

	function ENT:MakeSide(pos, ang, dir)
		local Side = ents.Create("prop_physics")
		Side:SetModel("models/hunter/plates/plate1x1.mdl")
		Side:SetMaterial(self:GetMaterial())
		Side:SetColor(Color(200, 200, 200, 255))
		Side:SetPos(pos)
		Side:SetAngles(ang)
		Side:Spawn()
		Side:Activate()
		Side:GetPhysicsObject():SetMaterial("Default_silent")
		Side:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity())
		Side:GetPhysicsObject():ApplyForceCenter(dir * 2000)
		Side:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		SafeRemoveEntityDelayed(Side, math.random(8, 16))
	end

	function ENT:Think()
		local Time = CurTime()

		if not self:GetNW2Bool("EZparachuting", false) then
			self:GetPhysicsObject():SetAngleDragCoefficient(1)
			self.SignalStopTime = self.SignalStopTime or Time + 60

			if true then
				if not self.last_sound or self.last_sound <= Time then
					self.last_sound = Time + 2
					if (self.Chrimsas) then
						self:EmitSound("snds_jack_gmod/2-sec-jinglebell.wav", 75, 100, 0.5)
					else
						self:EmitSound("snds_jack_gmod/ezsentry_disengage.wav", 75, 70, 0.5)
					end
				end

				local Foof = EffectData()
				Foof:SetOrigin(self:LocalToWorld(self:OBBCenter()))
				Foof:SetNormal(vector_up)
				local Col = (self.Chrimsas and math.random(1, 3) == 1 and Angle(255, 50, 50)) or Angle(50, 150, 50)
				Foof:SetAngles(Col)
				Foof:SetStart(self:GetVelocity())
				util.Effect("eff_jack_gmod_aidboxsignal", Foof, true, true)
				self:NextThink(Time + .1)

				return true
			end
		end

		if not self.NoFadeIn then
			self.Opacity = (self.Opacity or 0) + .01

			if self.Opacity > 1 then
				self.Opacity = 1
			end

			self:SetDTFloat(0, self.Opacity)
			self:NextThink(Time + .01)

			return true
		end
	end
end

if CLIENT then

	local TxtCol = Color(255, 240, 150, 80)
	function ENT:Draw()
		local Pos = self:GetPos()

		self:DrawModel()
		local Name = self:GetPackageName()

		JMod.HoloGraphicDisplay(self, Vector(20, -2, 0), Angle(90, 90, 0), .05, 300, function()
			draw.SimpleText(Name, "JMod-Stencil", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end)

		JMod.HoloGraphicDisplay(self, Vector(-20, 2, 0), Angle(0, -90, -90), .05, 300, function()
			draw.SimpleText(Name, "JMod-Stencil", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end)
	end

	language.Add("ent_jack_aidbox", "Aid Package")
end
