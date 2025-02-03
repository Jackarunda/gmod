function JMod.DamageSpark(ent)
	local effectdata = EffectData()
	effectdata:SetOrigin(ent:GetPos() + ent:GetUp() * 10 + VectorRand() * math.random(0, 10))
	effectdata:SetNormal(VectorRand())
	effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
	effectdata:SetScale(math.Rand(.5, 1.5)) --length of strands
	effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
	util.Effect("Sparks", effectdata, true, true)
	ent:EmitSound("snd_jack_turretfizzle.ogg", 70, 100)
end

function JMod.EMP(pos, range)
	--debugoverlay.Sphere(pos, range, 5, Color(0, 0, 255), true)
	for k, ent in pairs(ents.FindInSphere(pos, range)) do
		if ent.IsJackyEZmachine and ent.SetState and ent.GetState and (ent:GetState() > 0) then
			if ent.TurnOff then 
				ent:TurnOff() 
			else
				ent:SetState(JMod.EZ_STATE_OFF)
			end
			ent.EZstayOn = nil
		end
		if ent.LVS and ent.StopEngine then
			ent:StopEngine()
			ent.EZengineNextStartTime = CurTime() + 30
		end
	end
end

hook.Add( "LVS.IsEngineStartAllowed", "JMod_DisableEMPedEngines", function(veh)
	if veh.EZengineNextStartTime and (veh.EZengineNextStartTime > CurTime()) then
		return false
	else
		veh.EZengineNextStartTime = nil 
	end
end)

function JMod.EZinstallMachine(machine, install)
	if not(IsValid(machine)) then return end
	if ((machine.EZinstalled or false) == install) then return end
	if (install == nil) then install = true end
	local Phys = machine:GetPhysicsObject()
	if not(IsValid(Phys)) then return end

	machine.EZinstalled = install
	Phys:EnableMotion(not install)
end

function JMod.StartResourceConnection(machine, ply)
	if not(IsValid(machine)) then return end
	if IsValid(machine.EZconnectorPlug) then 
		if machine.EZconnectorPlug:IsPlayerHolding() then return end
		SafeRemoveEntity(machine.EZconnectorPlug)
	end
	if not(JMod.ShouldAllowControl(machine, ply, true)) then return end
	if not IsValid(ply) then return end

	local Plugy = ents.Create("ent_jack_gmod_ezhook")
	if not IsValid(Plugy) then return end
	Plugy:SetPos(machine:GetPos() + Vector(0, 0, 50)) -- Adjust the position as needed
	Plugy:SetAngles(machine:GetAngles())
	Plugy.Model = "models/props_lab/tpplug.mdl"
	Plugy.EZhookType = "Plugin"
	Plugy.EZconnector = machine
	Plugy:Spawn()
	Plugy:Activate()
	machine.EZconnectorPlug = Plugy

	local ropeLength = machine.MaxConnectionRange or 1000
	local Rope = constraint.Rope(machine, Plugy, 0, 0, machine.EZpowerSocket or Vector(0,0,0), Vector(10,0,0), ropeLength, 0, 1000, 2, "cable/cable2", false)
	Plugy.Chain = Rope

	ply:DropObject()
	ply:PickupObject(Plugy)
end

function JModResourceCable(Ent1, Ent2, resType, plugPos, dist, newCable)
	if not(IsValid(Ent1) and IsValid(Ent2)) then return false end
	if Ent1 == Ent2 then return false end
	if not resType then return false end
	if not plugPos then
		plugPos = Vector(0, 0, 0)
	end

	local LengthConstraint, Rope = constraint.Rope(Ent1, Ent2, 0, 0, Ent1.EZpowerSocket or Vector(0, 0, 0), plugPos, dist + 20, 10, 100, 2, "cable/cable2")
	if IsValid(newCable) then
		LengthConstraint:Remove()
		LengthConstraint = newCable
	end

	if not IsValid(LengthConstraint) then return false end

	local newCableTable = LengthConstraint:GetTable()

	newCableTable.Type = "JModResourceCable"
	newCableTable.resType = resType
	newCableTable.plugPos = plugPos
	newCableTable.dist = dist

	LengthConstraint:SetTable(newCableTable)

	return LengthConstraint
end
duplicator.RegisterConstraint("JModResourceCable", JModResourceCable, "Ent1", "Ent2", "resType", "plugPos", "dist", "newCable")

function JMod.CreateResourceConnection(machine, ent, resType, plugPos, dist, newCable)
	dist = dist or 1000
	if not (IsValid(machine) and IsValid(ent) and resType) then return false end
	if not IsValid(ent) or (ent == machine) then return false end
	if not (ent.EZconsumes and table.HasValue(ent.EZconsumes, resType)) and not (resType == JMod.EZ_RESOURCE_TYPES.POWER and (ent.EZpowerProducer and not machine.EZpowerProducer)) then return false end
	if ent.IsJackyEZcrate and ent.GetResourceType and not(ent:GetResourceType() == resType or ent:GetResourceType() == "generic") then return false end
	if not JMod.ShouldAllowControl(ent, JMod.GetEZowner(machine), true) then return false end
	local PluginPos = ent.EZpowerSocket or plugPos or ent:OBBCenter()
	if not IsValid(newCable) then
		local DistanceBetween = (machine:GetPos() - ent:LocalToWorld(PluginPos)):Length()
		if (DistanceBetween > (dist + 50)) then return false end
	end
	local EntConnections = constraint.FindConstraints(ent, "JModResourceCable")

	if (#EntConnections > 0) then
		for _, cable in pairs(EntConnections) do
			if IsValid(cable.Ent1) then
				if cable.Ent1 == machine then
					return false
				end
			elseif IsValid(cable.Ent2) then
				if cable.Ent2 == machine then
					return false
				end
			end
		end
	end

	local Cable = constraint.JModResourceCable(machine, ent, resType, plugPos, dist, newCable)

	return Cable and IsValid(Cable)
end

function JMod.RemoveResourceConnection(machine, connected)
	if not IsValid(machine) then return false end

	if type(connected) == "number" then
		-- Check if it is connected
		connected = Entity(connected)
	end

	for _, cable in pairs(constraint.FindConstraints(machine, "JModResourceCable")) do
		if not(IsValid(connected)) then
			if JMod.ConnectionValid(machine, cable.Ent1, cable) then
				cable.Constraint:Remove()
			elseif JMod.ConnectionValid(machine, cable.Ent2, cable) then
				cable.Constraint:Remove()
			else
				for key, con in pairs(machine.Constraints) do
					if (con.Type == "JModResourceCable") and (con.Ent1 == cable.Ent1) or (con.Ent2 == cable.Ent1) then
						machine.Constraints[key] = nil
					end
				end
			end
		end

		if (connected == cable.Ent1) or (connected == cable.Ent2) then 
			if JMod.ConnectionValid(machine, connected, cable) then
				cable.Constraint:Remove()

				return true
			else
				for key, con in pairs(machine.Constraints) do
					if (con.Type == "JModResourceCable") and (con.Ent1 == connected) or (con.Ent2 == connected) then
						machine.Constraints[key] = nil

						return true
					end
				end
			end 
		end
	end

	return IsValid(connected) and false or true
end

function JMod.ConnectionValid(machine, otherMachine, cable)
	if not(IsValid(machine) and IsValid(otherMachine)) then return false end
	if IsValid(cable) then
		if (cable.Ent1 == machine) and (cable.Ent2 == otherMachine) then return true end
		if (cable.Ent2 == machine) and (cable.Ent1 == otherMachine) then return true end
	else
		local ConnectionList = constraint.FindConstraints(machine, "JModResourceCable")
		for _, cable in pairs(ConnectionList) do
			if cable.Ent1 == otherMachine and cable.Ent2 == machine then return true end
			if cable.Ent2 == otherMachine and cable.Ent1 == machine then return true end
		end
	end

	return false
end

function JMod.DistributePower(self)
	for _, cable in pairs(constraint.FindConstraints(self, "JModResourceCable")) do
		local SelfPower = self:GetElectricity()
		local SelfPowerPercent = SelfPower / self.MaxElectricity
		local Ent = cable.Ent1 ~= self and cable.Ent1 or cable.Ent2

		if Ent.EZpowerProducer then
			if SelfPower <= (self.MaxElectricity * .5) then
				Ent:TurnOn(nil, true)
			end
		elseif (SelfPower >= 1) and Ent.EZpowerBank then
			local EntPower = Ent:GetElectricity()
			local PowerDiff = SelfPower - EntPower
			local TheirPowerPercent = EntPower / Ent.MaxElectricity
			local RelativeChargeDiff = SelfPowerPercent - TheirPowerPercent

			if (RelativeChargeDiff >= .02) then
				local PowerTaken = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, PowerDiff / 2), SelfPower)
				Ent.NextRefillTime = 0
				self:SetElectricity(SelfPower - PowerTaken)
			end
		elseif Ent.IsJackyEZcrate and (Ent.GetResourceType and ((Ent:GetResourceType() == JMod.EZ_RESOURCE_TYPES.POWER) or (Ent:GetResourceType() == "generic"))) then
			local EntPower = Ent:GetEZsupplies(JMod.EZ_RESOURCE_TYPES.POWER) or 0

			if SelfPower > (self.MaxElectricity * .9) then
				local PowerGiven = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, SelfPower - (self.MaxElectricity * .9)), SelfPower)
				Ent.NextRefillTime = 0
				self:SetElectricity(SelfPower - PowerGiven)
			elseif SelfPower <= (self.MaxElectricity * .5) and (EntPower >= 1) then
				local PowerTaken = self:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, math.min(EntPower, self.MaxElectricity))
				Ent:SetEZsupplies(JMod.EZ_RESOURCE_TYPES.POWER, EntPower - PowerTaken)
			end
		elseif (SelfPower >= 1) and not(Ent.IsJackyEZcrate) and Ent.EZconsumes and table.HasValue(Ent.EZconsumes, JMod.EZ_RESOURCE_TYPES.POWER) then
			local EntPower = (Ent.GetEZsupplies and Ent:GetEZsupplies(JMod.EZ_RESOURCE_TYPES.POWER)) or (Ent.GetElectricity and Ent:GetElectricity()) or Ent.Electricity or 0
			local MaxElec = Ent.MaxElectricity or Ent.MaxResource or 100

			if (MaxElec - EntPower) > MaxElec * .1 then
				local PowerTaken = math.min(Ent:TryLoadResource(JMod.EZ_RESOURCE_TYPES.POWER, SelfPower), SelfPower)
				Ent.NextRefillTime = 0
				self:SetElectricity(SelfPower - PowerTaken)
			end
			if (EntPower >= 1) and Ent.EZstayOn and Ent:GetState() == JMod.EZ_STATE_OFF then
				Ent:TurnOn()
			end
		elseif SelfPower >= 1 then
			JMod.RemoveResourceConnection(self, entID)
		end
	end
	if self:GetElectricity() > self.MaxElectricity then
		self:ProduceResource()
	end
	self.PowerFlow = self:GetElectricity()
end

function JMod.MachineSpawnResource(machine, resourceType, amount, relativeSpawnPos, relativeSpawnAngle, ejectionVector, findCrateRange)
	amount = math.Round(amount)
	if not(amount) or (amount < 1) then return end --print("[JMOD] " .. tostring(machine) .. " tried to produce a resource with 0 value") return end
	machine.NextRefillTime = CurTime() + 1
	local SpawnPos, SpawnAngle, MachineOwner = machine:LocalToWorld(relativeSpawnPos), relativeSpawnAngle and machine:LocalToWorldAngles(relativeSpawnAngle), JMod.GetEZowner(machine)
	local MachineCenter = machine:LocalToWorld(machine:OBBCenter())
	if (resourceType == JMod.EZ_RESOURCE_TYPES.POWER) and (machine.GetState and machine:GetState() == JMod.EZ_STATE_ON) then
		local PowerToGive = amount
		for _, cable in pairs(constraint.FindConstraints(machine, "JModResourceCable")) do
			local EntToPower = cable.Ent1 == machine and cable.Ent2 or cable.Ent1
			if not IsValid(EntToPower) or not(EntToPower.EZconsumes and table.HasValue(EntToPower.EZconsumes, JMod.EZ_RESOURCE_TYPES.POWER)) then
				cable:Remove()
			else
				local Accepted = EntToPower:TryLoadResource(resourceType, PowerToGive)
				EntToPower.NextRefillTime = 0
				amount = math.Clamp(amount - Accepted, 0, 100)
			end
		end
	end
	if amount <= 0 then return end
	for i = 1, math.ceil(amount/100*JMod.Config.ResourceEconomy.MaxResourceMult) do
		if findCrateRange then
			findCrateRange = findCrateRange * findCrateRange -- Sqr root stuff
			local BestCrate = nil
			local IsGenericCrate = true

			for _, ent in pairs(ents.FindInSphere(machine:LocalToWorld(ejectionVector or machine:OBBCenter()), findCrateRange)) do
				if (ent.IsJackyEZcrate and table.HasValue(ent.EZconsumes, resourceType)) or (ent.IsJackyEZresource and (ent.EZsupplies == resourceType)) then
					local Dist = MachineCenter:DistToSqr(ent:LocalToWorld(ent:OBBCenter()))
					if (Dist <= findCrateRange) and (ent:GetResource() < ent.MaxResource) then
						local EntSupplies = ent:GetEZsupplies()
						if (EntSupplies[resourceType] ~= nil) then
							BestCrate = ent
							findCrateRange = Dist
							IsGenericCrate = false
						elseif (EntSupplies["generic"] == 0) and (IsGenericCrate == true) then
							BestCrate = ent
							findCrateRange = Dist
							IsGenericCrate = true
						end
					end
				end
			end
			
			if IsValid(BestCrate) then
				local Remaining = amount
				if BestCrate.TryLoadResource then
					Remaining = BestCrate:TryLoadResource(resourceType, amount, true)
				else
					local SuppliesContained = BestCrate:GetEZsupplies(resourceType)
					if not SuppliesContained then SuppliesContained = 0 end -- To fix weird bugs
					Remaining = math.min(BestCrate.MaxResource - SuppliesContained, Remaining)
					BestCrate:SetEZsupplies(resourceType, SuppliesContained + Remaining)
				end
				
				if Remaining > 0 then
					local entPos = BestCrate:LocalToWorld(BestCrate:OBBCenter())
					JMod.ResourceEffect(resourceType, machine:LocalToWorld(ejectionVector or machine:OBBCenter()), entPos, amount * 0.01, 0.1, 1)
					amount = amount - Remaining
					if amount <= 0 then 
					
						return
					end
				end
			end
		end

		local SpawnTr = util.TraceLine({
			start = MachineCenter,
			endpos = SpawnPos,
			filter = {machine},
			mask = MASK_SOLID
		})

		if SpawnTr.Hit then
			local SpawnPos = SpawnTr.HitPos + (SpawnTr.HitNormal * 40)
		end
		-- TODO: Figure out how to optimize the resource effects
		local SpawnAmount = math.min(amount, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
		if ejectionVector then
			JMod.ResourceEffect(resourceType, machine:LocalToWorld(ejectionVector), SpawnPos, SpawnAmount * 0.01, 1, 1)
		end
		timer.Simple(.3 * math.ceil(amount/(100 * JMod.Config.ResourceEconomy.MaxResourceMult)), function()
			local Resource = ents.Create(JMod.EZ_RESOURCE_ENTITIES[resourceType])
			Resource:SetPos(SpawnPos)
			Resource:SetAngles(SpawnAngle or Resource.JModPreferredCarryAngles or Angle(0, 0, 0))
			Resource:Spawn()
			JMod.SetEZowner(Resource, MachineOwner)
			Resource:SetEZsupplies(resourceType, SpawnAmount)
			Resource:Activate()
		end)

		amount = amount - SpawnAmount

		if amount <= 0 then
			
			if (resourceType == JMod.EZ_RESOURCE_TYPES.POWER) and not(machine.EZstayOn) and machine.TurnOff then
				machine:TurnOff()
			end
			return
		end
	end
end

function JMod.FindBoltPos(ply, origin, dir)
	local Pos, Vec = origin or ply:GetShootPos(), dir or ply:GetAimVector()

	local HitTest = util.QuickTrace(Pos, Vec * 80, {ply})

	if HitTest.Hit then
		local Ent1 = HitTest.Entity
		if HitTest.HitSky or Ent1:IsPlayer() or Ent1:IsNPC() then return nil end
		if not IsValid(Ent1:GetPhysicsObject()) then return nil end
		local HitPos1 = HitTest.HitPos

		local HitTest2 = util.QuickTrace(HitPos1, HitTest.HitNormal * -30, {ply, Ent1})
		if not(HitTest2.Hit) then 
			HitTest2 = util.QuickTrace(HitPos1, HitTest.HitNormal * 30, {ply, Ent1})
		end

		if HitTest2.Hit then
			local Ent2 = HitTest2.Entity
			if (Ent1 == Ent2) or HitTest2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return nil end
			if not Ent2:IsWorld() and not IsValid(Ent2:GetPhysicsObject()) then return nil end
			local Dist = HitPos1:Distance(HitTest.HitPos)
			if Dist > 30 then return nil end

			return true, HitPos1, HitTest2.HitPos, Ent1, Ent2
		end
	end
end

function JMod.Bolt(ply)
	local Success, Pos, Vec, Ent1, Ent2 = JMod.FindBoltPos(ply)
	if not Success then return end
	
	local Axis = constraint.Axis(Ent1, Ent2, 0, 0, Ent1:WorldToLocal(Pos), Ent2:WorldToLocal(Vec), 50000, 0, 1, false)
	
	local Dir = (Pos - Vec):GetNormalized()
	local Bolt = ents.Create("prop_dynamic")
	Bolt:SetModel("models/crossbow_bolt.mdl")
	Bolt:SetMaterial("models/shiny")
	Bolt:SetColor(Color(50, 50, 50))
	Bolt:SetPos(Pos - Dir * 20)
	Bolt:SetAngles(Dir:Angle())
	Bolt:Spawn()
	Bolt:Activate()
	Bolt:SetParent(Ent1)
	Ent1.EZnails = Ent1.EZnails or {}
	table.insert(Ent1.EZnails, Bolt)
	sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".ogg", Pos, 60, math.random(80, 120))
end

function JMod.FindNailPos(ply, origin, dir)
	local Pos, Vec = origin or ply:GetShootPos(), dir or ply:GetAimVector()

	local Tr1 = util.QuickTrace(Pos, Vec * 80, {ply})

	if Tr1.Hit then
		local Ent1 = Tr1.Entity
		if Tr1.HitSky or Ent1:IsWorld() or Ent1:IsPlayer() or Ent1:IsNPC() then return nil end
		if not IsValid(Ent1:GetPhysicsObject()) then return nil end

		local Tr2 = util.QuickTrace(Pos, Vec * 120, {ply, Ent1})

		if Tr2.Hit then
			local Ent2 = Tr2.Entity
			if (Ent1 == Ent2) or Tr2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return nil end
			if not Ent2:IsWorld() and not IsValid(Ent2:GetPhysicsObject()) then return nil end
			local Dist = Tr1.HitPos:Distance(Tr2.HitPos)
			if Dist > 30 then return nil end

			return true, Tr1.HitPos, Vec, Ent1, Ent2
		end
	end
end

function JMod.Nail(ply)
	local Success, Pos, Vec, Ent1, Ent2 = JMod.FindNailPos(ply)
	if not Success then return end
	local Weld = constraint.Find(Ent1, Ent2, "Weld", 0, 0)
	local DistMult = 1

	Ent1.EZnails = Ent1.EZnails or {}
	if Ent1.EZnails[1] then
		local Size, LocalPos, Barycenter = (Ent1:OBBMaxs() - Ent1:OBBMins()):Length(), Ent1:WorldToLocal(Pos), Vector(0, 0, 0)
		
		for k, nail in pairs(Ent1.EZnails) do
			if IsValid(nail) then
				local EZnailPos = Ent1:WorldToLocal(nail:GetPos())
				Barycenter = Barycenter + EZnailPos
			end
		end

		Barycenter = Barycenter / #Ent1.EZnails
		DistMult = (LocalPos:Distance(Barycenter) * 5) / Size -- The multiplier by 5 is the most the strength will be multiplied by
	end

	if Weld then
		local Strength = Weld:GetTable().forcelimit + (5000 * DistMult)
		Weld:Remove()

		timer.Simple(.01, function()
			Weld = constraint.Weld(Ent1, Ent2, 0, 0, Strength, false, false)
		end)
	else
		for k, v in pairs(Ent1.EZnails) do
			if IsValid(v) then
				v:Remove()
			end
		end
		Weld = constraint.Weld(Ent1, Ent2, 0, 0, 5000, false, false)
	end

	local Nail = ents.Create("prop_dynamic")
	Nail:SetModel("models/crossbow_bolt.mdl")
	Nail:SetMaterial("models/shiny")
	Nail:SetColor(Color(50, 50, 50))
	Nail:SetPos(Pos - Vec * 2)
	Nail:SetAngles(Vec:Angle())
	Nail:Spawn()
	Nail:Activate()
	Nail:SetParent(Ent1)

	table.insert(Ent1.EZnails, Nail)

	sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".ogg", Pos, 60, math.random(80, 120))
end

function JMod.GetPackagableObject(packager, origin, dir)
	local PackageBlacklist = {"func_"}
	local Tr = util.QuickTrace(origin or packager:GetShootPos(), (dir or packager:GetAimVector()) * 80, {packager})

	local Ent = Tr.Entity

	if IsValid(Ent) and not Ent:IsWorld() then
		if Ent.EZunpackagable then

			return nil, "No."
		end

		if Ent:IsPlayer() or Ent:IsNPC() then return nil end
		if Ent:IsRagdoll() then return nil end
		local Constraints, Constrained = constraint.GetTable(Ent), false

		for k, v in pairs(Constraints) do
			if v.Type ~= "NoCollide" then
				Constrained = true
				break
			end
		end

		if Constrained then

			return nil, "object must be loosened first"
		end

		for k, v in pairs(PackageBlacklist) do
			if string.find(Ent:GetClass(), v) then

				return nil, "can't package this"
			end
		end

		if Ent.IsJackyEZmachine and Ent.GetState and Ent:GetState() ~= 0 then
			return nil, "device must be turned off to package"
		end

		return Ent
	end

	return nil
end

function JMod.Package(packager)
	local Ent, Message = JMod.GetPackagableObject(packager)

	if Ent then
		JMod.PackageObject(Ent)
		sound.Play("snds_jack_gmod/packagify.ogg", packager:GetPos(), 60, math.random(90, 110))

		for i = 1, 3 do
			timer.Simple(i / 3, function()
				if IsValid(packager) then
					sound.Play("snds_jack_gmod/ez_tools/" .. math.random(1, 27) .. ".ogg", packager:GetPos(), 60, math.random(80, 120))
				end
			end)
		end
	elseif isstring(Message) then
		packager:PrintMessage(HUD_PRINTCENTER, Message)
	end
end

function JMod.PackageObject(ent, pos, ang, ply)
	if pos then
		ent = ents.Create(ent)
		ent:SetPos(pos)
		ent:SetAngles(ang)

		if ply then
			JMod.SetEZowner(ent, ply)
		end

		ent:Spawn()
		ent:Activate()
	end

	local Bocks = ents.Create("ent_jack_gmod_ezcompactbox")
	Bocks:SetPos(ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, 20))
	Bocks:SetAngles(ent:GetAngles())
	Bocks:SetContents(ent)

	if ply then
		JMod.SetEZowner(Bocks, ply)
	end

	Bocks:Spawn()
	Bocks:Activate()
	return Bocks
end

function JMod.Rope(ply, origin, dir, width, strength, mat)
	local RopeStartData = ply and ply.EZropeData
	if not(RopeStartData) or not IsValid(RopeStartData.Ent) then
		if origin and dir then
			local RopeStartTr = util.QuickTrace(origin, dir * 80)
			if not(RopeStartTr.Hit) then return end
			RopeStartData = {Pos = RopeStartTr.Entity:WorldToLocal(RopeStartTr.HitPos), Ent = RopeStartTr.Entity}
		else

			return
		end
	end

	local RopeTr = util.QuickTrace(origin or ply:GetShootPos(), (dir or ply:GetAimVector()) * 80, {ply})
	local LropePos1, LropePos2 = ply.EZropeData.Pos, RopeTr.Entity:WorldToLocal(RopeTr.HitPos)
	local Dist = ply.EZropeData.Ent:LocalToWorld(RopeStartData.Pos):Distance(RopeTr.HitPos)

	local Rope, Vrope = constraint.Rope(ply.EZropeData.Ent, RopeTr.Entity, 0, 0, LropePos1, LropePos2, Dist, 0, strength or 5000, width or 2, mat or "cable/cable2", false)
	
	local RopeTable = Rope:GetTable()
	RopeTable.KeyframeRope = Vrope
	Rope:SetTable(RopeTable)
	
	return Rope, RopeTr.Entity, Vrope
end

function JMod.BuildRecipe(results, ply, Pos, Ang, skinNum)
	if istable(results) then
		for n = 1, (results[2] or 1) do
			local Ent = ents.Create(results[1])
			Ent:SetPos(Pos)
			Ent:SetAngles(Ang)
			JMod.SetEZowner(Ent, ply)
			Ent:SetCreator(ply)
			Ent:Spawn()
			Ent:Activate()
			if (results[3]) then
				Ent:SetEZsupplies(Ent.EZsupplies, results[3])
			end
		end
	else
		local StringParts=string.Explode(" ", results)
		if((StringParts[1])and(StringParts[1] == "FUNC"))then
			local FuncName = StringParts[2]
			if((JMod.LuaConfig) and (JMod.LuaConfig.BuildFuncs) and (JMod.LuaConfig.BuildFuncs[FuncName]))then
				local Ent = JMod.LuaConfig.BuildFuncs[FuncName](ply, Pos, Ang)
			else
				print("JMOD WORKBENCH ERROR: JMod.LuaConfig is missing, corrupt, or doesn't have an entry for that build function")
			end
		elseif string.Right(results, 4) == ".mdl" then
			local Ent = ents.Create("prop_physics")
			Ent:SetModel(results)
			Ent:SetPos(Pos)
			Ent:SetAngles(Ang)
			JMod.SetEZowner(Ent, ply)
			Ent:SetCreator(ply)
			Ent:Spawn()
			Ent:Activate()
			if skinNum then
				if istable(skinNum) then
					Ent:SetSkin(table.Random(skinNum))
				else
					Ent:SetSkin(skinNum)
				end
			end
		else
			local Ent = ents.Create(results)
			Ent:SetPos(Pos)
			Ent:SetAngles(Ang)
			JMod.SetEZowner(Ent, ply)
			Ent:SetCreator(ply)
			Ent:Spawn()
			Ent:Activate()
			JMod.Hint(ply, results)
		end
	end
end

function JMod.BuildEffect(pos)
	local Scale = .5
	local effectdata = EffectData()
	effectdata:SetOrigin(pos + VectorRand())
	effectdata:SetNormal((VectorRand() + Vector(0, 0, 1)):GetNormalized())
	effectdata:SetMagnitude(math.Rand(1, 2) * Scale) --amount and shoot hardness
	effectdata:SetScale(math.Rand(.5, 1.5) * Scale) --length of strands
	effectdata:SetRadius(math.Rand(2, 4) * Scale) --thickness of strands
	util.Effect("Sparks", effectdata,true,true)
	sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 60, math.random(80, 120))
	sound.Play("snds_jack_gmod/ez_tools/"..math.random(1, 27)..".ogg", pos, 60, math.random(80, 120))
	local eff = EffectData()
	eff:SetOrigin(pos + VectorRand())
	eff:SetScale(Scale)
	util.Effect("eff_jack_gmod_ezbuildsmoke", eff, true, true)
	-- todo: useEffects
end

concommand.Add("jmod_debug_destroy", function(ply, cmd, args)
	if not GetConVar("sv_cheats"):GetBool() then return end
	if not ply:IsSuperAdmin() then return end
	local Tr = ply:GetEyeTrace()

	if not Tr.Entity then
		print("No Entity to destroy")

		return
	end

	local ent = Tr.Entity

	if ent.Destroy then
		print("Destroying ent: " .. tostring(ent))
		ent:Destroy(DamageInfo())
	else
		print("Entity does not have a destroy function")
	end
end, nil, "Destroys the current JMod thing you are looking at")