-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Mini Claymore"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.EZscannerDanger = true
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)

ENT.BlacklistedNPCs = {"bullseye_strider_focus", "npc_turret_floor", "npc_turret_ceiling", "npc_turret_ground"}

ENT.WhitelistedNPCs = {"npc_rollermine"}

---
local STATE_BROKEN, STATE_OFF, STATE_ARMING, STATE_ARMED, STATE_WARNING = -1, 0, 1, 2, 3

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 8
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(ply:GetAngles() + Angle(0, -90, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/claymore.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end

		self:SetState(STATE_OFF)
		JMod.Colorify(self)

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"-1 broken \n 0 off \n 1 arming \n 2 armed \n 3 warning"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMING)
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 and data.Speed > 25 then
			if (self:GetState() == STATE_ARMED) and (math.random(1, 5) == 3) then
				self:Detonate()
			else
				self:EmitSound("Drywall.ImpactHard")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 20, 80) then
			local Pos, State = self:GetPos(), self:GetState()

			if State == STATE_ARMED then
				self:Detonate()
			elseif not (State == STATE_BROKEN) then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		if State < 0 then return end
		local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)
		JMod.SetEZowner(self, activator)
		JMod.Colorify(self)

		if State == STATE_OFF then
			if Alt then
				self:Arm(activator)
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		else
			self:EmitSound("snd_jack_minearm.ogg", 60, 70)
			self:SetState(STATE_OFF)
			self:DrawShadow(true)
			JMod.BlockPhysgunPickup(self, false)
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos = self:LocalToWorld(self:OBBCenter())
		local Up = (-self:GetRight() + self:GetUp() * .2):GetNormalized()
		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(.75)
		plooie:SetRadius(2)
		plooie:SetNormal(Up)
		util.Effect("eff_jack_minesplode", plooie, true, true)
		util.ScreenShake(SelfPos, 99999, 99999, 1, 500)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)
		JMod.Sploom(self.EZowner, SelfPos, math.random(10, 20))

		if JMod.Config.Explosives.FragExplosions then
			JMod.FragSplosion(self, SelfPos, 1000, 10, 5000, JMod.GetEZowner(self), Up, .9)
		else
			util.BlastDamage(self, JMod.GetEZowner(self), SelfPos + Up * 350, 350, 110)
		end

		self:Remove()
	end

	function ENT:Arm(armer)
		local State = self:GetState()
		if State ~= STATE_OFF then return end

		local tr = util.TraceLine({
			start = self:GetPos(),
			endpos = self:GetPos() - self:GetUp() * 100,
		})

		if not tr.Hit or tr.HitNormal.z <= 0.6 then
			JMod.Hint(armer, "horizontal surface")
			self:EmitSound("buttons/button18.wav", 60, 110)

			return
		end

		JMod.SetEZowner(self, armer)
		JMod.Hint(armer, "mine friends")
		self:SetState(STATE_ARMING)
		self:EmitSound("snd_jack_minearm.ogg", 60, 110)
		local ang = tr.HitNormal:Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		ang:RotateAroundAxis(ang:Up(), self:GetAngles().yaw - ang.yaw)
		self:SetPos(tr.HitPos)
		self:SetAngles(ang)
		JMod.BlockPhysgunPickup(self, true)

		timer.Simple(3, function()
			if IsValid(self) and self:GetState() == STATE_ARMING then
				self:SetState(STATE_ARMED)
				self:DrawShadow(false)
			end
		end)
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end

		local State, Time, Dir = self:GetState(), CurTime(), (-self:GetRight() + self:GetUp() * .2):GetNormalized()

		if State == STATE_ARMED then
			for k, targ in pairs(ents.FindInSphere(self:GetPos() + Dir * 200, 150)) do
				if (not (targ == self) and (targ:IsPlayer() or targ:IsNPC() or targ:IsVehicle())) and JMod.ShouldAttack(self, targ) and JMod.ClearLoS(self, targ) then
					self:SetState(STATE_WARNING)
					sound.Play("snds_jack_gmod/mine_warn.ogg", self:GetPos() + Vector(0, 0, 30), 60, 100)

					timer.Simple(math.Rand(.15, .4) * JMod.Config.Explosives.Mine.Delay, function()
						if IsValid(self) then
							if self:GetState() == STATE_WARNING then
								self:Detonate()
							end
						end
					end)
				end
			end

			self:NextThink(Time + .3)

			return true
		end
	end

	function ENT:OnRemove()
	end
	--aw fuck you
elseif CLIENT then
	function ENT:Initialize()
	end

	--[[
		self.Mdl=ClientsideModel("models/Weapons/w_clayjore.mdl")
		self.Mdl:SetMaterial("models/mat_jack_claymore")
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetModelScale(.8,0)
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		]]
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		--[[
		local Pos, Up, Right, Forward, Ang=self:GetPos(), self:GetUp(), self:GetRight(), self:GetForward(), self:GetAngles()
		self.Mdl:SetRenderOrigin(Pos-Up*5)
		Ang:RotateAroundAxis(Right, -15)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
		]]
		local State, Vary, Pos = self:GetState(), math.sin(CurTime() * 50) / 2 + .5, self:GetPos() + self:GetUp() * 12

		if State == STATE_ARMING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(Pos, 20, 20, Color(255, 0, 0))
			render.DrawSprite(Pos, 10, 10, Color(255, 255, 255))
		elseif State == STATE_WARNING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(Pos, 30 * Vary, 30 * Vary, Color(255, 0, 0))
			render.DrawSprite(Pos, 15 * Vary, 15 * Vary, Color(255, 255, 255))
		end
	end

	language.Add("ent_jack_gmod_ezminimore", "EZ Mini Claymore")
end
