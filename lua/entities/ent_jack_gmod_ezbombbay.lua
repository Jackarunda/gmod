--Jackarunda 2022
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "EZ method for loading bombs"
ENT.PrintName = "EZ Bomb Bay"
ENT.Spawnable = true
ENT.AdminSpawnable = false
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZlowFragPlease = true
ENT.EZbuoyancy = .3
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
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/bomb_bay/bomb_bay_exterior.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		---
		local phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(phys) then
				phys:SetMass(300)
				phys:Wake()
				phys:EnableDrag(false)
				phys:SetBuoyancyRatio(self.EZbuoyancy)
			end
		end)

		self.Bombs = {}

		---
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Drop [NORMAL]", "DropDud [NORMAL]"}, {"Drops the specified bomb, input -1 to drop them all", "Drops bomb unarmed"})

			self.Outputs = WireLib.CreateOutputs(self, {"LastBomb [STRING]", "Amount [NORMAL]"}, {"The last loaded bomb", "How many bombs are contained in the bay"})
		end
	end

	function ENT:UpdateWireOutputs()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "Amount", #self.Bombs)

			if #self.Bombs > 0 then
				WireLib.TriggerOutput(self, "LastBomb", tostring(self.Bombs[#self.Bombs][1]))
			else
				WireLib.TriggerOutput(self, "LastBomb", "")
			end
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "Drop" and value > 0 then
			self:BombRelease(value, true)
		elseif iname == "Drop" and value == -1 then
			if #self.Bombs > 0 then
				for i = 1, #self.Bombs do
					timer.Simple(1 * i, function()
						if IsValid(self) then
							self:BombRelease(i, true)
						end
					end)
				end
			end
		elseif iname == "DropDud" and value > 0 then
			self:BombRelease(value, false)
		elseif iname == "DropDud" and value == -1 then
			if #self.Bombs > 0 then
				for i = 1, #self.Bombs do
					timer.Simple(1 * i, function()
						if IsValid(self) then
							self:BombRelease(i, false)
						end
					end)
				end
			end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end
		local ent = data.HitEntity

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Metal_Box.ImpactHard")
			end

			if self.Destroyed then return end

			if data.Speed > 1500 then
				self:Destroy()
			end

			if ent.EZbombBaySize then
				self:LoadBomb(ent)
			end
		end
	end

	function ENT:LoadBomb(bomb)
		if not (IsValid(bomb) and bomb:IsPlayerHolding() or JMod.Config.ResourceEconomy.ForceLoadAllResources) then return end
		local RoomLeft = 100

		for k, bombInfo in pairs(self.Bombs) do
			RoomLeft = RoomLeft - bombInfo[2]
		end

		local BombClass = bomb:GetClass()

		if RoomLeft >= bomb.EZbombBaySize then
			table.insert(self.Bombs, {BombClass, bomb.EZbombBaySize})

			self:EmitSound("snd_jack_metallicload.ogg", 65, 90)

			timer.Simple(0.1, function()
				SafeRemoveEntity(bomb)
			end)
		end

		self.EZdroppableBombLoadTime = CurTime()
		self:UpdateWireOutputs()
	end

	function ENT:BombRelease(slotNum, arm, ply)
		local Time = CurTime()
		if self.NextDropTime and (self.NextDropTime > Time) then return end
		self.NextDropTime = Time + .9
		local NumOBombs = #self.Bombs
		slotNum = slotNum or NumOBombs
		ply = ply or JMod.GetEZowner(self)
		if NumOBombs <= 0 then return end
		if slotNum == 0 or slotNum > NumOBombs then return end

		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		local DroppedBomb = ents.Create(self.Bombs[slotNum][1])
		DroppedBomb:SetPos(Pos + Up * -20 + Forward * -6 + Right * 6)
		DroppedBomb:SetAngles(Ang + DroppedBomb.JModPreferredCarryAngles or Angle(0, 0, 0))
		JMod.SetEZowner(DroppedBomb, ply)
		if arm then
			DroppedBomb.DropOwner = ply
		end
		DroppedBomb:Spawn()
		DroppedBomb:Activate()

		local Nocollide = constraint.NoCollide(self, DroppedBomb, 0, 0)
		if IsValid(Nocollide) then
			Nocollide:Spawn()
			Nocollide:Activate()
			timer.Simple(1, function() 
				if IsValid(Nocollide) then
					Nocollide:Remove()
				end
			end)
		end

		timer.Simple(0, function()
			if IsValid(DroppedBomb) then
				DroppedBomb:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity())
			end

			if arm then
				DroppedBomb:SetState(1)
				if DroppedBomb.Launch then
					timer.Simple(0.2, function()
						if IsValid(DroppedBomb) then
							DroppedBomb:Launch(ply)
						end
					end)
				end
			else
				DroppedBomb:SetState(0)
			end
		end)

		self:EmitSound("snd_jack_metallicclick.ogg", 65, 90)

		table.remove(self.Bombs, slotNum)

		if #self.Bombs <= 0 then
			self.EZdroppableBombLoadTime = nil
		end

		self:UpdateWireOutputs()
	end

	function ENT:OnTakeDamage(dmginfo)
		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), 160, 300) then
			self:Destroy(dmginfo)
		end
	end

	function ENT:Destroy(dmginfo)
		if self.Destroyed then return end
		self.Destroyed = true
		self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end

		for i = 1, #self.Bombs do
			timer.Simple(0.2, function()
				if IsValid(self) then
					self:BombRelease(i, false, self.EZowner)
				end
			end)
		end

		timer.Simple(2, function()
			SafeRemoveEntity(self)
		end)
	end

	function ENT:Use(activator)
		JMod.Hint(activator, "bomb bay")
		self:BombRelease(#self.Bombs, false)
	end

	function ENT:PostEntityCopy()
		self.Bombs = table.FullCopy(self.Bombs)
	end

	function ENT:PostEntityPaste(ply, ent)
		local Time = CurTime()
		self.NextDropTime = Time + 1
		if self.Bombs and #self.Bombs > 0 then
			self.EZdroppableBombLoadTime = Time
		else
			self.EZdroppableBombLoadTime = nil
		end
	end
elseif CLIENT then
end
--
