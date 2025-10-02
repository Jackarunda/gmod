-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Fuel Lantern"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.JModGUIcolorable = true
---
ENT.JModEZstorable = true
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZconsumes={
    JMod.EZ_RESOURCE_TYPES.FUEL
}
ENT.NextRefillTime = 0
---
local STATE_OFF, STATE_ON = 0, 1
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Float", 1, "Fuel")
end
---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 3
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props/jigg/lamp.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)
		self:GetPhysicsObject():SetMass(6)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():SetDamping(1, 1)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.LastUse = 0
		self:SetState(STATE_OFF)
		self.MaxFuel = 10
		self:SetFuel(self.MaxFuel)
		self.Suffocated = 0
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self:EmitSound("Drywall.ImpactHard")
			end
			if data.Speed > 600 and not self:IsPlayerHolding() then
				local Pos, State = self:GetPos(), self:GetState()
				sound.Play("Metal_Box.Break", Pos)
				self:Remove()
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if ((dmginfo:IsDamageType(DMG_BURN)) or (dmginfo:IsDamageType(DMG_DIRECT))) then
			if (math.random(1, 10) == 2) then
				self:Light()
			end
		end

		if JMod.LinCh(dmginfo:GetDamage(), 1, 50) then
			local Pos, State = self:GetPos(), self:GetState()
			sound.Play("Metal_Box.Break", Pos)
			self:Remove()
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.SetEZowner(self, Dude)
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = JMod.IsAltUsing(Dude)

			if Alt then
				if State == STATE_OFF then
					if (self:GetFuel() <= 0) then
						JMod.Hint(activator, "fuel")
						return
					end
					self:Light()
					JMod.Hint(Dude, "hang on ceiling")
				else
					self:TurnOff()
				end
			else
				constraint.RemoveAll(self)
				self.StuckStick = nil
				self.StuckTo = nil
				Dude:PickupObject(self)
				self.NextStick = Time + .5
				JMod.Hint(Dude, "activate")
			end
		else
			if self:IsPlayerHolding() and (self.NextStick < Time) then
				local Tr = util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector() * 80, {self, Dude})

				if Tr.Hit and IsValid(Tr.Entity:GetPhysicsObject()) and not Tr.Entity:IsNPC() and not Tr.Entity:IsPlayer() then
					self.NextStick = Time + .5
					local Ang = Tr.HitNormal:Angle()
					Ang:RotateAroundAxis(Ang:Right(), 90)
					self:SetAngles(Ang)
					self:SetPos(Tr.HitPos + Tr.HitNormal * 27)

					-- crash prevention
					if Tr.Entity:GetClass() == "func_breakable" then
						timer.Simple(0, function()
							self:GetPhysicsObject():Sleep()
						end)
					else
						--local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 3000, false, false)
						local WorldPos = Tr.HitPos
						local RelPos = Tr.Entity:WorldToLocal(WorldPos)
						local Ball = constraint.Ballsocket(self, Tr.Entity, 0, Tr.PhysicsBone, RelPos, 3000, 3000, false )
						self.StuckTo = Tr.Entity
						self.StuckStick = Ball
						timer.Simple(0, function()
							if (IsValid(self)) then
								self:GetPhysicsObject():ApplyForceCenter(VectorRand() * 2000)
							end
						end)
					end

					self:EmitSound("snd_jack_claythunk.ogg", 65, math.random(80, 120))
					Dude:DropObject()
					JMod.Hint(Dude, "activate")
				end
			end
		end
	end

	function ENT:Light()
		if self:GetState() == STATE_ON then return end
		self:SetState(STATE_ON)
		self:EmitSound("snd_jack_littleignite.ogg", 50, 120)
		---[[
		self.ProjTexLight = ents.Create("ent_jack_projtexlight")
		self.ProjTexLight:SetPos(self:GetPos() + self:GetUp() * 9)
		self.ProjTexLight:SetAngles(self:GetAngles())
		self.ProjTexLight:SetParent(self)
		self.ProjTexLight:Spawn()
		self.ProjTexLight:Activate()
		self.ProjTexLight:SetActiveState(true)
		self.ProjTexLight:SetDrawSprite(true)
		self.ProjTexLight:SetShadows(true)
		self.ProjTexLight:SetBrightness(.5)
		self.ProjTexLight:SetFarZ(200)
		self.ProjTexLight:SetNearZ(1)
		self.ProjTexLight:SetLightColor(Vector(255, 180, 100))
		self.ProjTexLight:SetFlicker(true)
		--]]
	end

	function ENT:TurnOff()
		if (self:GetState() <= 0) then return end
		self:SetState(STATE_OFF)
		if (IsValid(self.ProjTexLight)) then self.ProjTexLight:Remove() end
	end

	function ENT:Think()
		if self:GetState() == STATE_OFF then return end
		local State, Fuel, Time, Pos = self:GetState(), self:GetFuel(), CurTime(), self:GetPos()
		local Up, Right, Forward = self:GetUp(), self:GetRight(), self:GetForward()

		if Fuel <= 0 then
			self:TurnOff()
			return
		end

		if ((self:GetVelocity():Length() >= 650) or (self:WaterLevel() >= 3)) then
			self:TurnOff()
			return
		end

		if (Up.z < .75) then -- we are too tilted
			self.Suffocated = self.Suffocated + 1
			if (self.Suffocated >= 2) then
				self:TurnOff()
				return
			end
		else
			self.Suffocated = 0
		end

		-- .0055 fuel per second
		-- 10 fuel total
		-- means about 30 minutes runtime
		-- (we only think every 5 seconds, so mult consumption by 5)

		self:SetFuel(Fuel - .0275)
		self:NextThink(Time + 5)

		return true
	end

	function ENT:OnRemove()
		--
	end
	--
	function ENT:TryLoadResource(typ, amt)
		if(amt <= 0)then return 0 end
		local Time = CurTime()
		if self.NextRefillTime > Time then return 0 end
		local Accepted = 0
		if(typ == JMod.EZ_RESOURCE_TYPES.FUEL)then
			local Fool = self:GetFuel()
			local Missing = self.MaxFuel - Fool
			if(Missing <= 0)then return 0 end
			Accepted=math.min(Missing, amt)
			self:SetFuel(Fool + Accepted)
			self:EmitSound("snds_jack_gmod/liquid_load.ogg", 60, math.random(120, 130))
		end
		self.NextRefillTime = Time + 1
		return math.ceil(Accepted)
	end
elseif CLIENT then
	function ENT:Initialize()
	end

	--
	function ENT:Think()
		local State, Fuel, Pos, Ang = self:GetState(), self:GetFuel(), self:GetPos(), self:GetAngles()

		if State == STATE_ON then
			local Up, Right, Forward = Ang:Up(), Ang:Right(), Ang:Forward()
			local DLight = DynamicLight(self:EntIndex())

			if DLight then
				DLight.Pos = Pos + Up * 10
				DLight.r = 50
				DLight.g = 30
				DLight.b = 20
				DLight.Brightness = .1
				DLight.Size = 300
				DLight.Decay = 15000
				DLight.DieTime = CurTime() + .3
				DLight.Style = 0
			end
		end
	end

	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezfuellantern", "EZ Fuel Lantern")
end
