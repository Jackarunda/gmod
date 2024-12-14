-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Glow Stick"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModGUIcolorable = true
---
ENT.JModEZstorable = true
ENT.JModEZstorableVolume = .5
ENT.JModInvAllowedActive = true
ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
---
local STATE_OFF, STATE_BURNIN, STATE_BURNT = 0, 1, 2

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Int", 1, "Fuel")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/props/glowstick.mdl")
		self:SetMaterial("models/jmod/props/jlowstick_off")
		--self:SetModelScale(1.5,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)
		self:SetColor(Color(130, 200, 120))
		self:GetPhysicsObject():SetMass(6)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(6)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.NextStick = 0
		self.LastUse = 0
		self:SetState(STATE_OFF)
		self:SetFuel(math.random(540, 660))

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Light"}, {"Lights glowstick"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Light" and value > 0 then
			self:Light()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self:EmitSound("Drywall.ImpactHard")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 1, 30) then
			local Pos, State = self:GetPos(), self:GetState()

			sound.Play("Flesh.Break", Pos)
			self:Remove()
		else
			self:Light()
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local State = self:GetState()
		if State == STATE_BURNT then return end
		local Dude = activator or activatorAgain
		local Alt = JMod.IsAltUsing(Dude)
		JMod.SetEZowner(self, Dude)
		local Time = CurTime()

		if State == STATE_OFF then
			if tobool(onOff) then
				if Alt then
					JMod.SetEZowner(self, activator)
					net.Start("JMod_ColorAndArm")
					net.WriteEntity(self)
					net.Send(activator)
				else
					activator:PickupObject(self)
					JMod.Hint(activator, "arm")
				end
			end
		elseif State == STATE_BURNIN then
			if Alt and Dude:KeyDown(IN_SPEED) and tobool(onOff) then
				-- double sticks, it's rave time
				if Dude.EZequippables and Dude.EZequippables["glowsticks"] then
					JMod.SetEquippable(Dude, "glowsticks", "rave_glowsticks", self:GetColor(), Time + self:GetFuel())
				else
					JMod.SetEquippable(Dude, "glowsticks", "one_glowstick", self:GetColor(), Time + self:GetFuel())
				end

				self:Remove()
			else
				if tobool(onOff) then
					constraint.RemoveAll(self)
					self.StuckStick = nil
					self.StuckTo = nil
					Dude:PickupObject(self)
					self.NextStick = Time + .5
					JMod.Hint(Dude, "sticky")
				elseif (Time - self.LastUse) > .1 then
					if self:IsPlayerHolding() and (self.NextStick < Time) then
						local Tr = util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector() * 80, {self, Dude})

						if Tr.Hit and IsValid(Tr.Entity:GetPhysicsObject()) and not Tr.Entity:IsNPC() and not Tr.Entity:IsPlayer() then
							self.NextStick = Time + .5
							local Ang = Tr.HitNormal:Angle()
							--Ang:RotateAroundAxis(Ang:Right(), -90)
							--Ang:RotateAroundAxis(Ang:Up(), 90)
							self:SetAngles(Ang)
							self:SetPos(Tr.HitPos + Tr.HitNormal * .5)

							-- crash prevention
							if Tr.Entity:GetClass() == "func_breakable" then
								timer.Simple(0, function()
									self:GetPhysicsObject():Sleep()
								end)
							else
								local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 5000, false, false)
								self.StuckTo = Tr.Entity
								self.StuckStick = Weld
							end

							self:EmitSound("snd_jack_claythunk.ogg", 65, math.random(80, 120))
							Dude:DropObject()
							JMod.Hint(Dude, "stick to self")
						end
					end
				end

				self.LastUse = Time
			end
		end
	end

	function ENT:Light()
		if self:GetState() == STATE_BURNT then return end
		self:SetState(STATE_BURNIN)
		self:SetMaterial("models/jmod/props/jlowstick_on")
		self:DrawShadow(false)
		self:EmitSound("snds_jack_gmod/glowstick_start.ogg", 60, math.random(90, 110))
	end

	ENT.Arm = ENT.Light -- for compatibility with the ColorAndArm feature

	function ENT:Burnout()
		if self:GetState() == STATE_BURNT then return end
		self:SetState(STATE_BURNT)
		self:SetMaterial("models/jmod/props/jlowstick_off")
		SafeRemoveEntityDelayed(self, 20)
		self:DrawShadow(true)
	end

	function ENT:Think()
		if self:GetState() == STATE_BURNT then return end
		local State, Fuel, Time, Pos = self:GetState(), self:GetFuel(), CurTime(), self:GetPos()
		local Up, Right, Forward = self:GetUp(), self:GetRight(), self:GetForward()

		if State == STATE_BURNIN then
			if Fuel <= 0 then
				self:Burnout()

				return
			end

			self:SetFuel(Fuel - 1)
			self:NextThink(Time + 1)

			return true
		end
	end

	function ENT:OnRemove()
	end

	hook.Add("JMod_OnInventoryAdd", "JMod_GlowstickInventoryAdd", function(invEnt, target, jmodinv)
		if not(IsValid(invEnt) and IsValid(target)) then return end
		if (target:GetClass() == "ent_jack_gmod_ezglowstick") and (target:GetState() == STATE_BURNIN) then
			target:SetNoDraw(false)
		end
	end)
	--
elseif CLIENT then
	local GlowstickSlots = {
		[1] = {
			mdl = "models/jmod/props/glowstick.mdl",
			mat = "models/jmod/props/jlowstick_on",
			scl = 1,
			bon = "ValveBiped.Bip01_Spine4",
			pos = Vector(-12, -10, -3),
			ang = Angle(-70, 0, 90)
		},
		[2] = {
			mdl = "models/holograms/hq_torus_thin.mdl",
			mat = "models/debug/debugwhite",
			fb = true,
			scl = 1,
			bon = "ValveBiped.Bip01_Spine4",
			col = Color(200, 50, 50),
			pos = Vector(-4, 4, 1),
			ang = Angle(90, 20, 0)
		},
		[3] = {
			mdl = "models/holograms/hq_torus_thin.mdl",
			mat = "models/debug/debugwhite",
			fb = true,
			scl = .6,
			bon = "ValveBiped.Bip01_R_Hand",
			col = Color(50, 200, 50),
			pos = Vector(0, 0, 0),
			ang = Angle(60, 0, 0)
		},
		[4] = {
			mdl = "models/holograms/hq_torus_thin.mdl",
			mat = "models/debug/debugwhite",
			fb = true,
			scl = .6,
			bon = "ValveBiped.Bip01_L_Hand",
			col = Color(50, 50, 200),
			pos = Vector(0, 0, 0),
			ang = Angle(130, 0, 0)
		}
	}

	function ENT:Initialize()
		self.AttachedToPlayer = false
	end

	local OffsetVec, OffsetAng = Vector(-12, -3, -10), Angle(-70, 0, 90)
	--
	function ENT:Think()
		local State, Fuel, Pos, Ang = self:GetState(), self:GetFuel(), self:GetPos(), self:GetAngles()

		if State == STATE_BURNIN then
			local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
			local InventoryEnt = self:GetNW2Entity("EZInvOwner", NULL)

			if IsValid(InventoryEnt) then
				local BoneIndex = InventoryEnt:LookupBone("ValveBiped.Bip01_Spine4")
				if BoneIndex then
					Pos, Ang = InventoryEnt:GetBonePosition(BoneIndex)
					local BoneUp, BoneRight, BoneForward = Ang:Up(), Ang:Right(), Ang:Forward()
					Pos = Pos + BoneRight * OffsetVec.x + BoneUp * OffsetVec.y + BoneForward * OffsetVec.z
					Ang:RotateAroundAxis(BoneRight, OffsetAng.p)
					Ang:RotateAroundAxis(BoneUp, OffsetAng.y)
					Ang:RotateAroundAxis(BoneForward, OffsetAng.r)

					self:SetRenderOrigin(Pos)
					self:SetRenderAngles(Ang)
					self.AttachedToPlayer = true
				else
					self:SetRenderOrigin(nil)
					self:SetRenderAngles(nil)
					self.AttachedToPlayer = false
				end
			else
				self:SetRenderOrigin(nil)
				self:SetRenderAngles(nil)
				self.AttachedToPlayer = false
			end
			local Mult, Col = (Fuel > 30 and 1) or .5, self:GetColor()
			local R, G, B = math.Clamp(Col.r + 20, 0, 255), math.Clamp(Col.g + 20, 0, 255), math.Clamp(Col.b + 20, 0, 255)
			local DLight = DynamicLight(self:EntIndex())

			if DLight then
				DLight.Pos = Pos + Up * 10
				DLight.r = R
				DLight.g = G
				DLight.b = B
				DLight.Brightness = .8 * Mult ^ 2
				DLight.Size = 180 * Mult ^ 2
				DLight.Decay = 15000
				DLight.DieTime = CurTime() + .3
				DLight.Style = 0
			end
		end
	end

	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		local Client = LocalPlayer()
		local InventoryEnt = self:GetNW2Entity("EZInvOwner", NULL)

		if self.AttachedToPlayer and (Client == InventoryEnt) and not Client:ShouldDrawLocalPlayer() then
			return
		end

		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezglowstick", "EZ Glow Stick")
end
