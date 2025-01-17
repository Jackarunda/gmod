--Jackarunda 2022
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "EZ method for loading rockets"
ENT.PrintName = "EZ Rocket Pod"
ENT.Spawnable = true
ENT.AdminSpawnable = false
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZcolorable = true
ENT.EZlowFragPlease = true
ENT.EZbuoyancy = .3
ENT.RocketDisplaySpecs = {
	["ent_jack_gmod_ezbigrocket"] = {
		mdl = "models/jmod/explosives/ez_hrocket.mdl",
		siz = 1,
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	["ent_jack_gmod_ezfirework"] = {
		mdl = "models/jmod/explosives/ez_fireworks.mdl",
		siz = 1.1,
		pos = Vector(0, 25, 0),
		ang = Angle(-90, 0, 0),
		mat = 1,
		bg = { [1] = 1 } -- todo
	},
	["ent_jack_gmod_ezheatrocket"] = {
		mdl = "models/jmod/explosives/missile/missile_patriot.mdl",
		siz = .7,
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0),
		mat = 2
	},
	["ent_jack_gmod_ezherocket"] = {
		mdl = "models/jmod/explosives/missile/missile_patriot.mdl",
		siz = .7,
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0),
		mat = 1
	}
}
---
if SERVER then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 40
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.SetEZowner(ent, ply, true)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/jmod/rocket_pod/rocket_pod01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		local phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(phys) then
				phys:SetMass(150)
				phys:Wake()
				phys:EnableDrag(false)
				phys:SetBuoyancyRatio(self.EZbuoyancy)
			end
		end)
		self.Rockets = self.Rockets or {}
		---
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Launch [NORMAL]", "Unload [NORMAL]"}, {"Fires the specified rocket, input -1 to fire them all", "Unloads rocket"})
			self.Outputs = WireLib.CreateOutputs(self, {"LastRocket [STRING]", "Amount [NORMAL]"}, {"The last loaded rocket", "How many rockets are contained in the launcher"})
		end
	end

	function ENT:UpdateWireOutputs()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "Amount", #self.Rockets)
			if #self.Rockets > 0 then
				WireLib.TriggerOutput(self, "LastRocket", tostring(self.Rockets[#self.Rockets]))
			else
				WireLib.TriggerOutput(self, "LastRocket", "")
			end
		end
	end

	function ENT:TriggerInput(iname, value)
		local NumRockets = #self.Rockets
		if iname == "Launch" and value > 0 then
			self:LaunchRocket(value, true)
		elseif iname == "Launch" and value == -1 then
			if NumRockets > 0 then
				for i = 0, NumRockets do
					timer.Simple(.6 * i, function()
						if IsValid(self) then
							self:LaunchRocket(NumRockets - i, true)
						end
					end)
				end
			end
		elseif iname == "Unload" and value > 0 then
			self:LaunchRocket(value, false)
		elseif iname == "Unload" and value == -1 then
			if NumRockets > 0 then
				for i = 1, NumRockets do
					timer.Simple(.2 * i, function()
						if IsValid(self) then
							self:LaunchRocket(i, false)
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

			if ent.EZrocket then
				self:LoadRocket(ent)
			end

			if data.Speed > 2500 and not(ent:IsPlayerHolding()) then
				self:Destroy()
			end
		end
	end

	function ENT:SyncRockets() 
		self.RenderRockets = self.RenderRockets or {}
		net.Start("JMod_MachineSync")
		net.WriteEntity(self)
		net.WriteTable({Rockets = self.Rockets})
		net.Broadcast()
	end

	function ENT:LoadRocket(rocket)
		if not (IsValid(rocket) and rocket:IsPlayerHolding() or JMod.Config.ResourceEconomy.ForceLoadAllResources) then return end
		if rocket.AlreadyLoaded then return end
		local RoomLeft = 6 - #self.Rockets

		if RoomLeft > 0 then
			rocket.AlreadyLoaded = true
			table.insert(self.Rockets, rocket:GetClass())

			self:EmitSound("snd_jack_metallicload.ogg", 65, 90)

			SafeRemoveEntityDelayed(rocket, 0.1)

			self.EZlaunchableWeaponLoadTime = CurTime()
			self:UpdateWireOutputs()
			self:SyncRockets()
		end
	end

	function ENT:LaunchRocket(slotNum, arm, ply)
		local Time = CurTime()
		if self.NextLaunchTime and (self.NextLaunchTime > Time) then return end
		self.NextLaunchTime = Time + .1
		local NumORockets = #self.Rockets
		slotNum = slotNum or NumORockets
		if NumORockets <= 0 then return end
		if (slotNum == 0) or (slotNum > NumORockets) or not(self.Rockets[slotNum]) then return end

		ply = ply or JMod.GetEZowner(self)
		local Up, Ford, Right = self:GetUp(), self:GetForward(), self:GetRight()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		local LaunchedRocket = ents.Create(self.Rockets[slotNum])

		local PodAngle = Ang:GetCopy()
		--PodAngle:RotateAroundAxis(Ford, 30)
		PodAngle:RotateAroundAxis(Ford, 60 * (slotNum - 1))
		PodAngle:RotateAroundAxis(PodAngle:Right(), -LaunchedRocket.JModPreferredCarryAngles.p)
		PodAngle:RotateAroundAxis(PodAngle:Up(), LaunchedRocket.JModPreferredCarryAngles.y)
		LaunchedRocket:SetPos(Pos + PodAngle:Up() * 10 + Ford * 40)
		LaunchedRocket:SetAngles(PodAngle)
		JMod.SetEZowner(LaunchedRocket, ply)
		LaunchedRocket:Spawn()
		LaunchedRocket:Activate()
		
		timer.Simple(0, function()
			if IsValid(LaunchedRocket) then
				--LaunchedRocket:GetPhysicsObject():EnableMotion(false)
				LaunchedRocket:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity())
				if arm then
					LaunchedRocket.DropOwner = self
					LaunchedRocket:SetState(1)
					if LaunchedRocket.Launch then
						LaunchedRocket:Launch(ply)
						local Nocollider = constraint.NoCollide(self, LaunchedRocket, 0, 0)
						constraint.RemoveConstraints(LaunchedRocket, "NoCollide")
					end
				else
					LaunchedRocket:SetState(0)
				end
			end
		end)

		self:EmitSound("snd_jack_metallicclick.ogg", 65, 90)

		table.remove(self.Rockets, slotNum)

		if #self.Rockets <= 0 then
			self.EZlaunchableWeaponLoadTime = nil
		end

		self:UpdateWireOutputs()
		self:SyncRockets()
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

		local NumRockets = #self.Rockets
		if NumRockets > 0 then
			for i = 0, NumRockets do
				timer.Simple(0.11 * i, function()
					if IsValid(self) then
						self:LaunchRocket(NumRockets - i, false, self.EZowner)
					end
				end)
			end
		end

		timer.Simple(2, function()
			SafeRemoveEntity(self)
		end)
	end

	function ENT:Use(activator)
		JMod.Hint(activator, "rocket pod")
		if JMod.IsAltUsing(activator) then
			self:LaunchRocket(#self.Rockets, true, activator)
		else
			self:LaunchRocket(#self.Rockets, false)
		end
	end

	function ENT:PreEntityCopy()
		self.DupeRockets = table.FullCopy(self.Rockets)
	end

	function ENT:PostEntityPaste(ply, ent, createdEnts)
		local Time = CurTime()
		ent.NextLaunchTime = Time + 1
		if #ent.DupeRockets > 0 then
			ent.Rockets = table.FullCopy(ent.DupeRockets)
			ent.EZlaunchableWeaponLoadTime = Time
		else
			ent.EZlaunchableWeaponLoadTime = nil
		end
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:SyncRockets()
			end
		end)
		JMod.SetEZowner(ent, ply, true)
	end

elseif CLIENT then

	function ENT:Initialize()
		self:SetModel("models/jmod/rocket_pod/rocket_pod01.mdl")
		self.Rockets = {}
		self.RocketModels = {}
	end

	function ENT:OnMachineSync(newSpecs)
		for k, v in pairs(self.RocketModels) do
			v:Remove()
		end
		self.RocketModels = {}
		for specName, value in pairs(newSpecs) do
			self[specName] = value
		end
		if next(self.Rockets) then
			local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
			for k, rocketClass in pairs(self.Rockets) do
				local DisplaySpecs = self.RocketDisplaySpecs[rocketClass]
				self.RocketModels[k] = JMod.MakeModel(self, DisplaySpecs.mdl, DisplaySpecs.mat, DisplaySpecs.siz, DisplaySpecs.col)
				if DisplaySpecs.bg then
					for group, state in pairs(DisplaySpecs.bg) do
						self.RocketModels[k]:SetBodygroup(group, state)
					end
				end
			end
		end
	end

	function ENT:Draw()
		self:DrawModel()
		if next(self.Rockets) then
			local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
			local Up, Right, Ford = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
			for k, rocketClass in pairs(self.Rockets) do
				if self.RocketModels[k] then
					local DisplaySpecs = self.RocketDisplaySpecs[rocketClass]
					local pos, ang = SelfPos:GetCopy(), SelfAng:GetCopy()
					local rotateAng = ang:GetCopy()
					rotateAng:RotateAroundAxis(Ford, -30)
					rotateAng:RotateAroundAxis(Ford, -60 * k)
					pos = pos + rotateAng:Right() * 10 - Ford
					pos = pos + Ford * DisplaySpecs.pos.y + Right * DisplaySpecs.pos.x + Up * DisplaySpecs.pos.z
					ang:RotateAroundAxis(Up, DisplaySpecs.ang.y)
					ang:RotateAroundAxis(Right, DisplaySpecs.ang.p)
					ang:RotateAroundAxis(Ford, DisplaySpecs.ang.r)
					JMod.RenderModel(self.RocketModels[k], pos, ang, Vector(DisplaySpecs.siz, DisplaySpecs.siz, DisplaySpecs.siz), DisplaySpecs.col, DisplaySpecs.mat)
				end
			end
		end
	end

	function ENT:OnRemove()
		self.RenderRockets = self.RenderRockets or {}
		for num, model in pairs(self.RenderRockets) do
			if IsValid(model) then
				model:Remove()
			end
		end
	end
end
