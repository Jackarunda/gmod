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
ENT.JModPreferredCarryAngles = Angle(180, 0, 0)
ENT.Model = "models/jmod/ezhook01.mdl"
ENT.EZhookType = nil

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
		self.NextStick = self.NextStick or CurTime() + 1
		self.EZhookType = self.EZhookType or "Hook"
	end

	function ENT:PhysicsCollide(data, physobj)
		local Time = CurTime()
		if Time > self.NextStick and data.DeltaTime > 0.2 and data.Speed > 50 then
			self:EmitSound("snd_jack_claythunk.ogg", 55, math.random(80, 120))
			if self:IsPlayerHolding() then
				local Ent = data.HitEntity
				if (IsValid(Ent) and not(Ent:IsPlayer() or Ent:IsNPC() or Ent:IsNextBot() or Ent == self.EZconnector)) then
					timer.Simple(0, function()
						if self.EZhookType == "Plugin" then
							local ConnectionRange = self.EZconnector.MaxConnectionRange or 1000
							local PlayerHolding = nil
							local NearbyPlayers = ents.FindInSphere(self:GetPos(), 100)
							for i = 1, #NearbyPlayers do
								local ply = NearbyPlayers[i]
								if ply:IsPlayer() then--and (JMod.GetPlayerHeldEntity(ply) == self) then
									PlayerHolding = ply
								end
							end
							if IsValid(PlayerHolding) and PlayerHolding:KeyDown(JMod.Config.General.AltFunctionKey) then
								local PluginPos = Ent.EZpowerSocket or Ent:OBBCenter()
								local DistanceBetween = (self.EZconnector:GetPos() - Ent:LocalToWorld(PluginPos)):Length()
								ConnectionRange = math.min(ConnectionRange, DistanceBetween + 10)
							end
							local Connected = JMod.CreateConnection(self.EZconnector, Ent, JMod.EZ_RESOURCE_TYPES.POWER, Ent:WorldToLocal(data.HitPos), ConnectionRange)
							if Connected then SafeRemoveEntity(self) end
						else
							self.NextStick = Time + 1
							local Ang = data.HitNormal:Angle()
							Ang:RotateAroundAxis(Ang:Right(), 90)
							self:SetAngles(Ang)
							self:SetPos(data.HitPos)
			
							-- crash prevention
							if data.HitEntity:GetClass() == "func_breakable" then
								timer.Simple(0, function()
									self:GetPhysicsObject():Sleep()
								end)
							end
							timer.Simple(0, function()
								local Weld = constraint.Weld(self, data.HitEntity, 0, 0, 8000, true, false)
								self.StuckTo = data.HitEntity
								self.StuckStick = Weld
							end)
			
							self:EmitSound("snd_jack_claythunk.ogg", 65, math.random(80, 120))
							self:SetState(STATE_HOOKED)
							self:SetBodygroup(0, 0)
							DropEntityIfHeld(self)
						end
					end)
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if dmginfo:GetInflictor() == self then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()

		if not(self:GetState() == STATE_BROKEN) and JMod.LinCh(Dmg, 30, 100) then
			sound.Play("Metal_Box.Break", self:GetPos())
			self:SetState(STATE_BROKEN)
			SafeRemoveEntityDelayed(self, 10)
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
			self:SetBodygroup(1, 1)

			if State == STATE_UNHOOKED then
				self.NextStick = Time + .5
				Dude:PickupObject(self)
				--JMod.Hint(Dude, "sticky")
			elseif State == STATE_HOOKED then
				if self.StuckStick then SafeRemoveEntity(self.StuckStick) end
				self.StuckStick = nil
				self.StuckTo = nil
				Dude:PickupObject(self)
				self:EmitSound("snd_jack_claythunk.ogg", 60, 70)
				self:SetState(STATE_UNHOOKED)
			end
		else
			self:SetBodygroup(1, 0)
		end
	end

	function ENT:Think()
		if not(IsValid(self.Chain)) then SafeRemoveEntity(self) end
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
	--local GlowSprite = Material("sprites/mat_jack_basicglow")

	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezhook", "EZ Hook")
end
