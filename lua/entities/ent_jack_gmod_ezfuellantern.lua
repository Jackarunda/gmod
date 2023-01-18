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
		JMod.SetOwner(ent, ply)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self.Entity:SetModel("models/props/jigg/lamp.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(6)

		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)

		---
		self.LastUse = 0
		self:SetState(STATE_OFF)
		self.MaxFuel = 10
		self:SetFuel(self.MaxFuel)
	end

	function ENT:PhysicsCollide(data, physobj)
		if data.DeltaTime > 0.2 then
			if data.Speed > 25 then
				self.Entity:EmitSound("Drywall.ImpactHard")
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)

		if ((dmginfo:IsDamageType(DMG_BURN)) or (dmginfo:IsDamageType(DMG_DIRECT))) then
			if (math.random(1, 10 == 2)) then
				self:Light()
			end
		end

		if JMod.LinCh(dmginfo:GetDamage(), 1, 50) then
			local Pos, State = self:GetPos(), self:GetState()
			sound.Play("Metal_Box.Break", Pos)
			self:Remove()
		end
	end

	function ENT:Use(activator)
		local State = self:GetState()
		local Dude = activator
		local Alt = Dude:KeyDown(JMod.Config.AltFunctionKey)
		JMod.SetOwner(self, Dude)
		local Time = CurTime()

		if State == STATE_OFF then
			if Alt then
				if (self:GetFuel() <= 0) then
					JMod.Hint(activator, "fuel")
					return
				end
				self:Light()
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "activate")
			end
		elseif State == STATE_ON then
			if Alt then
				self:TurnOff()
			else
				activator:PickupObject(self)
			end
		end
	end

	function ENT:Light()
		if self:GetState() == STATE_ON then return end
		self:SetState(STATE_ON)
		self:EmitSound("snd_jack_littleignite.wav", 50, 120)
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
		if self:GetState() == STATE_OFF then return end
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

		-- .017 fuel per second
		-- 10 fuel total
		-- = 10 minutes runtime

		self:SetFuel(Fuel - .083)
		self:NextThink(Time + 5)

		return true
	end

	function ENT:OnRemove()
	end
	--
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
