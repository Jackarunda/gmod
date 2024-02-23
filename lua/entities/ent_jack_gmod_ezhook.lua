-- AdventureBoots 2024
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Hook"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = true
--- func_breakable
ENT.JModPreferredCarryAngles = Angle(0, -90, 90)
ENT.Model = "models/jmod/ezhook01.mdl"
ENT.EZhookType = "Hook"

local STATE_BROKEN, STATE_UNHOOKED, STATE_HOOKED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
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
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)

		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end

		---
		self:SetState(STATE_UNHOOKED)
		self.NextStick = 0
	end

	function ENT:PhysicsCollide(data, physobj)
		local Time = CurTime()
		if data.DeltaTime > 0.2 and data.Speed > 25 then
			self:EmitSound("snd_jack_claythunk.wav", 55, math.random(80, 120))
			if self:IsPlayerHolding() then
				timer.Simple(0, function()
					if self.EZhookType == "Plugin" then
						local Ent = data.HitEntity
						local Connected = JMod.CreateConnection(self.EZconnector, Ent, self.EZconnector.MaxConnectionRange or 1000)
						if Connected then SafeRemoveEntity(self) end
					else
						self.NextStick = Time + .5
						local Ang = data.HitNormal:Angle()
						Ang:RotateAroundAxis(Ang:Right(), 90)
						self:SetAngles(Ang)
						self:SetPos(data.HitPos)
		
						-- crash prevention
						if data.HitEntity:GetClass() == "func_breakable" then
							timer.Simple(0, function()
								self:GetPhysicsObject():Sleep()
							end)
						else
							local Weld = constraint.Weld(self, data.HitEntity, 0, 0, 5000, true, false)
							self.StuckTo = data.HitEntity
							self.StuckStick = Weld
						end
		
						self:EmitSound("snd_jack_claythunk.wav", 65, math.random(80, 120))
						self:SetState(STATE_HOOKED)
						self:SetBodygroup(0, 0)
						DropEntityIfHeld(self)
						JMod.Hint(Dude, "arm")
					end
				end)
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if not(self:GetState() == STATE_BROKEN) and JMod.LinCh(Dmg, 30, 100) then
			sound.Play("Metal_Box.Break", Pos)
			self:SetState(STATE_BROKEN)
			SafeRemoveEntityDelayed(self, 10)
		end
	end

	function ENT:OnHook(Dude)
		local Time = CurTime()
		local Tr = util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector() * 80, {self, Dude})

		if Tr.Hit and IsValid(Tr.Entity:GetPhysicsObject()) and not(Tr.Entity:IsNPC()) and not(Tr.Entity:IsPlayer()) then
			if self.EZhookType == "Plugin" then
				local Ent = Tr.Entity
				local Connected = JMod.CreateConnection(self.EZconnector, Ent, self.EZconnector.MaxConnectionRange or 1000)
				if Connected then SafeRemoveEntity(self) end
			else
				self.NextStick = Time + .5
				local Ang = Tr.HitNormal:Angle()
				Ang:RotateAroundAxis(Ang:Right(), -90)
				Ang:RotateAroundAxis(Ang:Up(), 90)
				self:SetAngles(Ang)
				self:SetPos(Tr.HitPos)

				-- crash prevention
				if Tr.Entity:GetClass() == "func_breakable" then
					timer.Simple(0, function()
						self:GetPhysicsObject():Sleep()
					end)
				else
					local Weld = constraint.Weld(self, Tr.Entity, 0, Tr.PhysicsBone, 5000, true, false)
					self.StuckTo = Tr.Entity
					self.StuckStick = Weld
				end

				self:EmitSound("snd_jack_claythunk.wav", 65, math.random(80, 120))
				self:SetState(STATE_HOOKED)
				self:SetBodygroup(0, 0)
				Dude:DropObject()
				JMod.Hint(Dude, "arm")
			end
		end
	end

	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		if not IsValid(Dude) then return end
		JMod.SetEZowner(self, Dude)
		local Time = CurTime()

		if tobool(onOff) then
			local State = self:GetState()
			if State < 0 then return end
			local Alt = Dude:KeyDown(JMod.Config.General.AltFunctionKey)
			self:SetBodygroup(0, 1)

			if State == STATE_UNHOOKED then
				if self.StuckStick then SafeRemoveEntity(self.StuckStick) end
				self.StuckStick = nil
				self.StuckTo = nil
				Dude:PickupObject(self)
				self.NextStick = Time + .5
				JMod.Hint(Dude, "sticky")
			else
				self:EmitSound("snd_jack_minearm.wav", 60, 70)
				self:SetState(STATE_UNHOOKED)
			end
		else
			self:SetBodygroup(0, 0)
		end
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end
	end

	function ENT:OnRemove()
	end

elseif CLIENT then
	function ENT:Initialize()
	end

	--
	local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezhook", "EZ Hook")
end
