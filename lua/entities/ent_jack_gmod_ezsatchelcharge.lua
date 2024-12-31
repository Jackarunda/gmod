-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ Explosives"
ENT.PrintName = "EZ Satchel Charge"
ENT.Spawnable = true
ENT.Model = "models/jmod/explosives/grenades/satchelcharge/satchel_charge.mdl"
ENT.SpoonEnt = nil
--ENT.ModelScale=2.5
ENT.Mass = 20
ENT.HardThrowStr = 250
ENT.SoftThrowStr = 125
ENT.EZinvPrime = false

ENT.Hints = {"arm"}

ENT.UsableMats = {MAT_DIRT, MAT_FOLIAGE, MAT_SAND, MAT_SLOSH, MAT_GRASS, MAT_SNOW}
ENT.BlacklistedResources = {JMod.EZ_RESOURCE_TYPES.WATER, JMod.EZ_RESOURCE_TYPES.OIL, JMod.EZ_RESOURCE_TYPES.SAND, "geothermal"}

DEFINE_BASECLASS(ENT.Base)

if SERVER then
	function ENT:Initialize()
		BaseClass.Initialize(self)
		local plunger = ents.Create("ent_jack_gmod_ezblastingmachine")
		plunger:SetPos(self:GetPos() + self:GetForward() * 5)
		plunger:SetAngles(self:GetAngles())
		plunger:Spawn()
		plunger.Satchel = self
		plunger.EZowner = self.EZowner
		self.Plunger = plunger

		timer.Simple(0, function()
			plunger:SetParent(self)
		end)
		
		self.NextStick = 0

		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate"}, {"This will directly detonate the bomb"})

			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"Off \n Primed \n Armed"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Prime" and value > 0 then
			self:Prime()
		end
	end

	function ENT:Prime()
		if (self:GetState() == JMod.EZ_STATE_ARMED) or (self:GetState() == JMod.EZ_STATE_PRIMED) then return end
		self:EmitSound("weapons/c4/c4_plant.wav", 60, 80)
		self:SetState(JMod.EZ_STATE_PRIMED)
		self.Plunger:SetParent(nil)
		local NoCollide = constraint.NoCollide(self, self.Plunger, 0, 0, true)
		timer.Simple(.5, function()
			if IsValid(NoCollide) then NoCollide:Remove() end
		end)
		self.DetCable = constraint.Rope(self, self.Plunger, 0, 0, Vector(0, 0, 0), Vector(0, 0, 0), 2000, 0, 0, .5, "cable/cable", false)
		self.Plunger.DetCable = self.DetCable
		
		timer.Simple(0, function()
			self.Plunger:SetPos(self:GetPos() + Vector(0, 0, 20))
		end)
	end

	function ENT:Arm()
		if (self:GetState() == JMod.EZ_STATE_ARMED) then return end
		--self:EmitSound("buttons/button5.wav",60,150)
		self:SetState(JMod.EZ_STATE_ARMED)
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = JMod.IsAltUsing(Dude)

			if State == JMod.EZ_STATE_OFF and Alt then
				self:Prime()
				activator:DropObject()
				activator:PickupObject(self.Plunger)
				self.NextStick = Time + .5
				JMod.Hint(Dude, "arm satchelcharge", self.Plunger)
			else
				constraint.RemoveConstraints(self, "Weld")
				self.StuckStick = nil
				self.StuckTo = nil
				activator:DropObject()
				activator:PickupObject(self)
				self.NextStick = Time + .5
				JMod.Hint(Dude, "arm")
			end
		else
			if self:IsPlayerHolding() and (self.NextStick < Time) then
				self:Plant(Dude)
			end
		end
	end

	function ENT:Plant(ply)
		local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 100, {self, ply, self.Plunger})
		local Time = CurTime()

		if Tr.Hit and IsValid(Tr.Entity:GetPhysicsObject()) and not Tr.Entity:IsNPC() and not Tr.Entity:IsPlayer() then
			self.NextStick = Time + .5

			if table.HasValue(self.UsableMats, Tr.MatType) then
				local Ang = Tr.HitNormal:Angle()
				Ang:RotateAroundAxis(Ang:Right(), -90)
				Ang:RotateAroundAxis(Ang:Up(), 180)
				self:SetAngles(Ang)
				self:SetPos(Tr.HitPos + Tr.HitNormal * 3)

				local Fff = EffectData()
				Fff:SetOrigin(Tr.HitPos)
				Fff:SetNormal(Tr.HitNormal)
				Fff:SetScale(1)
				util.Effect("eff_jack_sminebury", Fff, true, true)
			else
				local Ang = Tr.HitNormal:Angle()
				Ang:RotateAroundAxis(Ang:Up(), -90)
				Ang:RotateAroundAxis(Ang:Right(), 90)
				self:SetAngles(Ang)
				self:SetPos(Tr.HitPos + Tr.HitNormal * 4)
			end

			-- crash prevention
			if Tr.Entity:GetClass() == "func_breakable" then
				timer.Simple(0, function()
					self:GetPhysicsObject():Sleep()
				end)
			else
				local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 3000, false, false)
				self.StuckTo = Tr.Entity
				self.StuckStick = Weld
			end

			self:EmitSound("snd_jack_claythunk.ogg", 65, math.random(80, 120))
			ply:DropObject()
			JMod.Hint(ply, "arm")
		end
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true

		if IsValid(self.Plunger) then
			JMod.SetEZowner(self, self.Plunger.EZowner)
		end
		local Blaster = JMod.GetEZowner(self)

		timer.Simple(0, function()
			if IsValid(self) then
				local SelfPos, PowerMult = self:GetPos(), 5
				--
				local Blam = EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult / 1.5)
				util.Effect("eff_jack_plastisplosion", Blam, true, true)
				util.ScreenShake(SelfPos, 99999, 99999, 1, 750 * PowerMult)

				for i = 1, 2 do
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 140, math.random(80, 110))
				end

				for i = 1, PowerMult do
					sound.Play("BaseExplosionEffect.Sound", SelfPos, 120, math.random(90, 110))
				end

				self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 100)

				timer.Simple(.1, function()
					for i = 1, 5 do
						local Tr = util.QuickTrace(SelfPos, VectorRand() * 20)

						if Tr.Hit then
							util.Decal("Scorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
						end
					end
				end)

				JMod.WreckBuildings(self, SelfPos, PowerMult)
				JMod.BlastDoors(self, SelfPos, PowerMult)

				if self.StuckTo and self.StuckTo == game.GetWorld() then
					-- Find what deposit we are over
					local DepositKey = JMod.GetDepositAtPos(self, SelfPos, 1)

					if DepositKey then
						local DepositTable = JMod.NaturalResourceTable[DepositKey]
						local AmountToBlast = math.min(math.random(math.floor(DepositTable.amt * .05), math.ceil(DepositTable.amt * .10)), 400)
						local ChunkNumber = math.ceil(AmountToBlast/(25 * JMod.Config.ResourceEconomy.MaxResourceMult))

						for i = 1, ChunkNumber do
							timer.Simple(.1 * i, function()
								local Ore = ents.Create(JMod.EZ_RESOURCE_ENTITIES[DepositTable.typ])
								Ore:SetPos(SelfPos)
								Ore:SetAngles(AngleRand())
								Ore:Spawn()
								JMod.SetEZowner(Ore, Blaster)
								Ore:SetEZsupplies(DepositTable.typ, math.floor(AmountToBlast / ChunkNumber))
								Ore:Activate()
								timer.Simple(0, function()
									if IsValid(Ore) and IsValid(Ore:GetPhysicsObject()) then
										Ore:GetPhysicsObject():AddVelocity((vector_up + VectorRand() * .5) * 500)
									end
								end)
							end)
						end

						JMod.DepleteNaturalResource(DepositKey, AmountToBlast)
					end
				end

				timer.Simple(0, function()
					local ZaWarudo = game.GetWorld()
					local Infl, Att = (IsValid(self) and self) or ZaWarudo, (IsValid(self) and IsValid(self.EZowner) and self.EZowner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl, Att, SelfPos, 100 * PowerMult, 160 * PowerMult)
					self:Remove()
				end)
			end
		end)
	end

	function ENT:OnRemove()
		if IsValid(self.Plunger) then
			SafeRemoveEntityDelayed(self.Plunger, 3)
		end
	end
elseif CLIENT then
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
		--[[local State = self:GetState()
		local pos = self:GetPos() + self:GetUp() * 3.5 + self:GetRight() * -2.5 + self:GetForward() * -4.5
		local ViewDir = (LocalPlayer():GetShootPos() - pos):GetNormalized()

		if State == JMod.EZ_STATE_ARMING then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos + ViewDir, 10, 10, Color(255, 0, 0))
			render.DrawSprite(pos + ViewDir, 5, 5, Color(255, 255, 255))
		elseif State == JMod.EZ_STATE_ARMED then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos + ViewDir, 5, 5, Color(255, 100, 0))
			render.DrawSprite(pos + ViewDir, 2, 2, Color(255, 255, 255))
		end--]]
	end

	language.Add("ent_jack_gmod_ezsatchelcharge", "EZ Satchel Charge")
end
