-- this causes an object to rotate to point forward while moving, like a dart
function JMod.AeroDrag(ent, forward, mult, spdReq)
	--if constraint.HasConstraints(ent) then return end
	if constraint.FindConstraint(ent, "Weld") then return end
	if ent:IsPlayerHolding() then return end
	local Phys = ent:GetPhysicsObject()
	if not IsValid(Phys) then return end
	local Vel = Phys:GetVelocity()
	local Spd = Vel:Length()

	if not spdReq then
		spdReq = 300
	end

	if Spd < spdReq then return end
	mult = mult or 1
	local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	Phys:ApplyForceOffset(Vel * Mass / 6 * mult, Pos + forward)
	Phys:ApplyForceOffset(-Vel * Mass / 6 * mult, Pos - forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * Mass / 1000)
end

-- this causes an object to rotate to point and fly to a point you give it
function JMod.AeroGuide(ent, forward, targetPos, turnMult, thrustMult, angleDragMult, spdReq)
	--if(constraint.HasConstraints(ent))then return end
	--if(ent:IsPlayerHolding())then return end
	local Phys = ent:GetPhysicsObject()
	if not IsValid(Phys) then return end
	local Vel = Phys:GetVelocity()
	local Spd = Vel:Length()
	--if(Spd<spdReq)then return end
	local Pos, Mass = Phys:LocalToWorld(Phys:GetMassCenter()), Phys:GetMass()
	local TargetVec = targetPos - ent:GetPos()
	local TargetDir = TargetVec:GetNormalized()
	---
	Phys:ApplyForceOffset(TargetDir * Mass * turnMult * 5000, Pos + forward)
	Phys:ApplyForceOffset(-TargetDir * Mass * turnMult * 5000, Pos - forward)
	Phys:AddAngleVelocity(-Phys:GetAngleVelocity() * angleDragMult * 3)
	--- todo: fuck
	Phys:ApplyForceCenter(forward * 20000 * thrustMult) -- todo: make this function fucking work ARGH
end

-- https://developer.valvesoftware.com/wiki/Ai_sound
function JMod.EmitAIsound(pos, vol, dur, typ)
	local snd = ents.Create("ai_sound")
	snd:SetPos(pos)
	snd:SetKeyValue("volume", tostring(vol))
	snd:SetKeyValue("duration", tostring(dur))
	snd:SetKeyValue("soundtype", tostring(typ))
	snd:Spawn()
	snd:Activate()
	snd:Fire("EmitAISound")
	SafeRemoveEntityDelayed(snd, dur + .5)
end

function JMod.GetEZowner(ent)
	if not IsValid(ent) then return game.GetWorld() end

	if ent.EZowner and IsValid(ent.EZowner) then

		return ent.EZowner
	elseif ent:IsPlayer() then
			
		return ent	
	else
		
		return game.GetWorld()
	end
end

function JMod.SetEZowner(ent, newOwner, setColor)
	if not IsValid(ent) then return end
	if not (newOwner and IsValid(newOwner)) then newOwner = game.GetWorld() end

	if JMod.GetEZowner(ent) == newOwner then
		if setColor == true then
			JMod.Colorify(ent)
		end

		return 
	end

	ent.EZowner = newOwner
	if newOwner:IsPlayer() then
		ent.EZownerID = newOwner:SteamID64()
		ent.EZownerTeam = newOwner:Team()
	else
		ent.EZownerID = nil
		ent.EZownerTeam = nil
	end

	if setColor == true then
		JMod.Colorify(ent)
	end

	if CPPI and isfunction(ent.CPPISetOwner) then
		ent:CPPISetOwner(newOwner)
	end
end

function JMod.Colorify(ent)
	if not (ent.EZcolorable and ent.EZcolorable == true) then return end
	if IsValid(JMod.GetEZowner(ent)) then
		if engine.ActiveGamemode() == "sandbox" and ent.EZowner:Team() == TEAM_UNASSIGNED then
			local Col = ent.EZowner:GetPlayerColor()
			ent:SetColor(Color(Col.x * 255, Col.y * 255, Col.z * 255))
		else
			local Tem = ent.EZowner:Team()

			if Tem then
				local Col = team.GetColor(Tem)

				if Col then
					ent:SetColor(Col)
				end
			end
		end
	else
		ent:SetColor(Color(255, 255, 255))
	end
end

function JMod.AddFriend(ply, friend)
	if not (IsValid(ply) and ply:IsPlayer() and IsValid(friend) and friend:IsPlayer()) then return end
	ply.JModFriends = ply.JModFriends or {}

	table.insert(ply.JModFriends, friend)

	net.Start("JMod_Friends")
		net.WriteBit(true)
		net.WriteEntity(ply)
		net.WriteTable(ply.JModFriends)
	net.Broadcast()
end

function JMod.RemoveFriend(ply, friend)
	if not (IsValid(ply) and ply:IsPlayer() and IsValid(friend) and friend:IsPlayer()) then return end
	ply.JModFriends = ply.JModFriends or {}
	
	table.RemoveByValue(ply.JModFriends, friend)

	net.Start("JMod_Friends")
		net.WriteBit(true)
		net.WriteEntity(ply)
		net.WriteTable(ply.JModFriends)
	net.Broadcast()
end

function JMod.ShouldAllowControl(self, ply, neutral)
	neutral = neutral or false
	if not IsValid(ply) then return false end
	if (ply.EZkillme) then return false end
	local EZowner = JMod.GetEZowner(self)
	if not IsValid(EZowner) then return neutral end
	if ply == EZowner then return true end
	local Allies = EZowner.JModFriends or {}
	if table.HasValue(Allies, ply) then return true end

	return (engine.ActiveGamemode() ~= "sandbox" or ply:Team() ~= TEAM_UNASSIGNED) and ply:Team() == EZowner:Team()
end

function JMod.ShouldAttack(self, ent, vehiclesOnly, peaceWasNeverAnOption)
	if not IsValid(ent) then return false end
	if ent:IsWorld() then return false end
	local SelfOwner = JMod.GetEZowner(self)

	local Override = hook.Run("JMod_ShouldAttack", self, ent, vehiclesOnly, peaceWasNeverAnOption)
	if (Override ~= nil) then return Override end

	local Gaymode, PlayerToCheck, InVehicle = engine.ActiveGamemode(), nil, false

	if ent:IsPlayer() then
		PlayerToCheck = ent
	elseif ent:IsNextBot() then
		-- our hands are really tied with nextbots, they lack all the NPC methods
		-- so just attack all of them
		if ent.Health and (type(ent.Health) == "function") then
			local Helf = ent:Health()
			if (type(Helf) == "number") and (Helf > 0) then return true end
		elseif ent.Health and (type(ent.Health) == "number") then
			if ent.Health > 0 then return true end
		end
	elseif ent:IsNPC() then
		local Class = ent:GetClass()
		if self.WhitelistedNPCs and table.HasValue(self.WhitelistedNPCs, Class) then return true end
		if self.BlacklistedNPCs and table.HasValue(self.BlacklistedNPCs, Class) then return false end
		if not IsValid(self.EZowner) then return ent:Health() > 0 end

		if ent.Disposition and (ent:Disposition(self.EZowner) == D_HT) and ent.GetMaxHealth and ent.Health then
			if vehiclesOnly then
				return ent:GetMaxHealth() > 100 and ent:Health() > 0
			else
				return ent:GetMaxHealth() > 0 and ent:Health() > 0
			end
		else
			return peaceWasNeverAnOption or false
		end
	elseif ent:IsVehicle() then
		PlayerToCheck = ent:GetDriver()
		InVehicle = true
	elseif (ent.LVS and not(ent.ExplodedAlready)) then
		if ent.GetDriver and IsValid(ent:GetDriver()) then
			PlayerToCheck = ent:GetDriver()
			InVehicle = true
		elseif SelfOwner.lvsGetAITeam then --and ((ent.GetEngineActive and ent:GetEngineActive()))
			local OurTeam = SelfOwner:lvsGetAITeam()
			if ent.GetAITEAM and ent.GetAI and ent:GetAI() then
				local TheirTeam = ent:GetAITEAM()
				if ((OurTeam ~= 0) and (TheirTeam ~= 0) and TheirTeam ~= OurTeam) or (TheirTeam == 3) then
					return true
				end
			end
		else
			return peaceWasNeverAnOption or false
		end
	elseif ent.IS_DRONE and IsValid(JMod.GetEZowner(ent)) then
		-- Drones Rewrite compatibility
		if ent.GetHealth and ent:GetHealth() > 0 then
			PlayerToCheck = ent.EZowner
		end
	end

	if IsValid(PlayerToCheck) and PlayerToCheck.Alive then
		if vehiclesOnly and not InVehicle then return false end
		if PlayerToCheck.EZkillme then return true end -- for testing
		if PlayerToCheck:GetObserverMode() ~= 0 then return false end
		if (SelfOwner) and (PlayerToCheck == SelfOwner) then return false end
		local Allies = (SelfOwner and SelfOwner.JModFriends) or {}
		if table.HasValue(Allies, PlayerToCheck) then return false end
		local OurTeam = nil

		if IsValid(SelfOwner) then
			OurTeam = SelfOwner:Team()
			if Gaymode == "basewars" and SelfOwner.IsAlly then return not SelfOwner:IsAlly(PlayerToCheck) end
		end

		if Gaymode == "sandbox" and OurTeam == TEAM_UNASSIGNED then return PlayerToCheck:Alive() end
		if OurTeam then return PlayerToCheck:Alive() and PlayerToCheck:Team() ~= OurTeam end

		return PlayerToCheck:Alive()
	end

	return (peaceWasNeverAnOption or false)
end

function JMod.EnemiesNearPoint(ent, pos, range, vehiclesOnly)
	for k, v in pairs(ents.FindInSphere(pos, range)) do
		if JMod.ShouldAttack(ent, v, vehiclesOnly) then return true end
	end

	return false
end

local TriggerKeys = {IN_ATTACK, IN_USE, IN_ATTACK2}

function JMod.ThrowablePickup(playa, item, hardstr, softstr)
	playa:DropObject()
	playa:PickupObject(item)
	local HookName = "EZthrowable_" .. item:EntIndex()

	hook.Add("KeyPress", HookName, function(ply, key)
		if not IsValid(playa) then
			hook.Remove("KeyPress", HookName)

			return
		end

		if ply ~= playa then return end

		if IsValid(item) and ply:Alive() then
			local Phys = item:GetPhysicsObject()

			if key == IN_ATTACK then
				timer.Simple(0, function()
					if IsValid(Phys) then
						Phys:ApplyForceCenter(ply:GetAimVector() * (hardstr or 600) * Phys:GetMass() * JMod.GetPlayerStrength(playa))

						if item.EZspinThrow then
							Phys:ApplyForceOffset(ply:GetAimVector() * Phys:GetMass() * 50, Phys:GetMassCenter() + Vector(0, 0, 10))
							Phys:ApplyForceOffset(-ply:GetAimVector() * Phys:GetMass() * 50, Phys:GetMassCenter() - Vector(0, 0, 10))
						end
					end
				end)
			elseif key == IN_ATTACK2 then
				local vec = ply:GetAimVector()
				vec.z = vec.z + 0.3

				timer.Simple(0, function()
					if IsValid(Phys) then
						Phys:ApplyForceCenter(vec * (softstr or 400) * Phys:GetMass() * JMod.GetPlayerStrength(playa))
					end
				end)
			elseif key == IN_USE then
				if item.GetState and item:GetState() == JMod.EZ_STATE_PRIMED then
					JMod.Hint(playa, "grenade drop", item)
				end
			end
		end

		if table.HasValue(TriggerKeys, key) then
			hook.Remove("KeyPress", HookName)
		end
	end)
end

function JMod.BlockPhysgunPickup(ent, isblock)
	if isblock == false then
		isblock = nil
	end

	ent.block_pickup = isblock
end

local LiquidResourceTypes = {JMod.EZ_RESOURCE_TYPES.WATER, JMod.EZ_RESOURCE_TYPES.COOLANT, JMod.EZ_RESOURCE_TYPES.OIL, JMod.EZ_RESOURCE_TYPES.CHEMICALS, JMod.EZ_RESOURCE_TYPES.FUEL}

local SpriteResourceTypes = {JMod.EZ_RESOURCE_TYPES.GAS, JMod.EZ_RESOURCE_TYPES.SAND, JMod.EZ_RESOURCE_TYPES.PAPER, JMod.EZ_RESOURCE_TYPES.ANTIMATTER, JMod.EZ_RESOURCE_TYPES.PROPELLANT, JMod.EZ_RESOURCE_TYPES.CLOTH, JMod.EZ_RESOURCE_TYPES.POWER}

function JMod.ResourceEffect(typ, fromPoint, toPoint, amt, spread, scale, upSpeed)
	--print("Type: " .. tostring(typ) .. " From point: " .. tostring(fromPoint) .. " Amount: " .. amt)
	amt = (amt and math.Clamp(amt, 0, 1)) or 1
	spread = spread or 1
	scale = scale or 1
	upSpeed = upSpeed or 0

	amt = math.Clamp(amt, 0.5, 5)

	local UseSprites = table.HasValue(SpriteResourceTypes, typ)

	if (UseSprites) then amt = amt * 2 end

	for j = 0, 2 * amt do
		timer.Simple(j / 20, function()
			for i = 1, math.ceil(amt * JMod.Config.Machines.SupplyEffectMult) do
				local whee = EffectData()
				whee:SetOrigin(fromPoint)
				if toPoint then
					whee:SetStart(toPoint)
				end
				whee:SetFlags(JMod.ResourceToIndex[typ])
				whee:SetMagnitude(spread)
				whee:SetRadius(upSpeed)
				whee:SetScale(scale)

				if toPoint then
					whee:SetSurfaceProp(1) -- we have somewhere to go
				else
					whee:SetSurfaceProp(0) -- just do a directionless explosion of particles
				end

				if table.HasValue(LiquidResourceTypes, typ) then
					util.Effect("eff_jack_gmod_resource_liquid", whee, true, true)
				elseif UseSprites then
					util.Effect("eff_jack_gmod_resource_sprites", whee, true, true)
				else
					util.Effect("eff_jack_gmod_resource_props", whee, true, true)
				end
			end
		end)
	end
end

function JMod.EZprogressTask(ent, pos, deconstructor, task, mult)
	mult = mult or 1
	local Time = CurTime()

	if not IsValid(ent) then return "Invalid Ent" end

	if task == "mining" then
		local DepositKey = JMod.GetDepositAtPos(ent, pos)
		local DepositInfo = JMod.NaturalResourceTable[DepositKey]
		if DepositInfo and ent.SetResourceType then
			local NewType = DepositInfo.typ
			if ent.GetResourceType and (ent:GetResourceType() ~= NewType) then
				ent:SetNW2Float("EZminingProgress", 0) -- No you don't
			end 
			ent:SetResourceType(NewType)
		end
		
		if ent.EZpreviousMiningPos and ent.EZpreviousMiningPos:Distance(pos) > 200 then
			ent:SetNW2Float("EZminingProgress", 0)
			ent.EZpreviousMiningPos = nil
		end
		if ent:GetNW2Float("EZcancelminingTime", 0) <= Time then
			ent:SetNW2Float("EZminingProgress", 0)
			ent.EZpreviousMiningPos = nil
		end
		ent:SetNW2Float("EZcancelminingTime", Time + 5)
		ent.EZpreviousMiningPos = pos

		local Prog = ent:GetNW2Float("EZminingProgress", 0)
		local AddAmt = math.random(15, 25) * mult * JMod.Config.ResourceEconomy.ExtractionSpeed

		ent:SetNW2Float("EZminingProgress", math.Clamp(Prog + AddAmt, 0, 100))

		if (Prog >= 10) and not(DepositInfo) then
			ent:SetNW2Float("EZminingProgress", 0)
			ent.EZpreviousMiningPos = nil
			local NearestGoodDeposit = JMod.GetDepositAtPos(ent, pos, 3)
			local NearestGoodDepositInfo = JMod.NaturalResourceTable[NearestGoodDeposit]
			if NearestGoodDepositInfo then
				net.Start("JMod_ResourceScanner")
					net.WriteEntity(ent)
					net.WriteTable({NearestGoodDepositInfo})
				net.Broadcast()
				return NearestGoodDepositInfo.typ .. " nearby"
			else
				return "nothing of value nearby"
			end
		elseif Prog >= 100 then
			local AmtToProduce

			if DepositInfo.rate then
				local Rate = DepositInfo.rate
				AmtToProduce = Rate * Prog
			else
				local AmtLeft = DepositInfo.amt
				AmtToProduce = math.min(AmtLeft, math.random(5, 20))
				if (DepositInfo.typ == JMod.EZ_RESOURCE_TYPES.DIAMOND) then
					AmtToProduce = math.min(AmtLeft, math.random(1, 2))
				end
				JMod.DepleteNaturalResource(DepositKey, AmtToProduce)
			end

			local SpawnPos = ent:WorldToLocal(pos + Vector(0, 0, 8))
			JMod.MachineSpawnResource(ent, DepositInfo.typ, AmtToProduce, SpawnPos, Angle(0, 0, 0), SpawnPos, 100)
			ent:SetNW2Float("EZminingProgress", 0)
			ent.EZpreviousMiningPos = nil
			JMod.ResourceEffect(DepositInfo.typ, pos, nil, 1, 1, 1, 5)
			util.Decal("EZgroundHole", pos + Vector(0, 0, 10), pos + Vector(0, 0, -10))
			--
			net.Start("JMod_ResourceScanner")
				net.WriteEntity(ent)
				net.WriteTable({DepositInfo})
			net.Broadcast()

			ent:SetResourceType("")
			
			return nil
		end

		return nil
	end

	if ent:GetNW2Float("EZcancel"..task.."Time", 0) <= Time then
		ent:SetNW2Float("EZ"..task.."Progress", 0)
	end
	ent:SetNW2Float("EZcancel"..task.."Time", Time + 3)
	
	local Prog = ent:GetNW2Float("EZ"..task.."Progress", 0)
	local Phys = ent:GetPhysicsObject()
	
	if IsValid(Phys) then
		local WorkSpreadMult = JMod.CalcWorkSpreadMult(ent, pos)

		if task == "loosen" then
			if constraint.HasConstraints(ent) or not Phys:IsMotionEnabled() then
				local Mass = Phys:GetMass() ^ .8
				local AddAmt = 300 / Mass * WorkSpreadMult * JMod.Config.Tools.Toolbox.DeconstructSpeedMult
				ent:SetNW2Float("EZ"..task.."Progress", math.Clamp(Prog + AddAmt, 0, 100))

				if Prog >= 100 then
					sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 70, math.random(50, 60))
					constraint.RemoveAll(ent)
					Phys:EnableMotion(true)
					Phys:Wake()
					ent:SetNW2Float("EZ"..task.."Progress", 0)
					if ent.EZnails then
						for _, v in ipairs(ent.EZnails) do
							if IsValid(v) then
								v:Remove()
							end
						end
						ent.EZnails = {}
					end
				end
			else
				return "object is already unconstrained"
			end
		elseif task == "salvage" then
			if constraint.HasConstraints(ent) or not Phys:IsMotionEnabled() then
				return "object is constrained"
			else
				local Mass = (Phys:GetMass() * ent:GetPhysicsObjectCount()) ^ .8
				ent:ForcePlayerDrop()
				local Yield, Message = JMod.GetSalvageYield(ent)

				if #table.GetKeys(Yield) <= 0 then
					return Message
				else
					local AddAmt = 250 / Mass * WorkSpreadMult * JMod.Config.Tools.Toolbox.DeconstructSpeedMult
					ent:SetNW2Float("EZ"..task.."Progress", math.Clamp(Prog + AddAmt, 0, 100))
					
					if Prog >= 100 then
						sound.Play("snds_jack_gmod/ez_tools/hit.ogg", pos + VectorRand(), 70, math.random(50, 60))

						for k, v in pairs(Yield) do
							local AmtLeft = v

							while AmtLeft > 0 do
								local Remove = math.min(AmtLeft, 100 * JMod.Config.ResourceEconomy.MaxResourceMult)
								local Ent = ents.Create(JMod.EZ_RESOURCE_ENTITIES[k])
								Ent:SetPos(pos + VectorRand() * 40 + Vector(0, 0, 30))
								Ent:SetAngles(AngleRand())
								Ent:Spawn()
								Ent:Activate()
								Ent:SetEZsupplies(k, Remove)
								JMod.SetEZowner(Ent, deconstructor)
								timer.Simple(.1, function()
									if (IsValid(Ent) and IsValid(Ent:GetPhysicsObject())) then 
										Ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0)) --- This is so jank
									end
								end)
								AmtLeft = AmtLeft - Remove
							end
						end
						--[[if ent.JModInv then
							for _, v in ipairs(ent.JModInv.items) do
								JMod.RemoveFromInventory(ent, v.ent, pos + VectorRand() * 50)
							end
						end--]]
						SafeRemoveEntity(ent)
					end
				end
			end
		end
	end
end

function JMod.ConsumeNutrients(ply, amt)
	if not IsValid(ply) or not ply:Alive() then return false end
	local Time = CurTime()
	amt = math.Round(amt)
	--
	ply.EZnutrition = ply.EZnutrition or {
		NextEat = 0,
		Nutrients = 0
	}
	if (ply.EZnutrition.NextEat or 0) > Time then JMod.Hint(activator, "can not eat") return false end
	if (ply.EZnutrition.Nutrients or 0) >= 100 then JMod.Hint(ply, "nutrition filled") return false end
	--
	ply.EZnutrition.NextEat = Time + amt / JMod.Config.FoodSpecs.EatSpeed
	ply.EZnutrition.Nutrients = math.Round(ply.EZnutrition.Nutrients + amt * JMod.Config.FoodSpecs.ConversionEfficiency)

	local result = hook.Run("JMod_ConsumeNutrients", ply, amt)

	ply:PrintMessage(HUD_PRINTCENTER, "nutrition: " .. ply.EZnutrition.Nutrients .. "/100")
	return true
end

hook.Add("JMod_ConsumeNutrients", "DarkRP_EnergyCompat", function(ply, amt)
	if ply.getDarkRPVar and ply.setDarkRPVar and ply:getDarkRPVar("energy") then
		local Old = ply:getDarkRPVar("energy")
		ply:setDarkRPVar("energy", math.Clamp(Old + amt * JMod.Config.FoodSpecs.ConversionEfficiency, 0, 100))
	end
end)

function JMod.GetPlayerStrength(ply)
	if not(IsValid(ply) and ply:IsPlayer() and ply:Alive()) then return 1 end
	local PlyHealth = ply:Health()
	local PlyMaxHealth = ply:GetMaxHealth()

	--jprint(1 + (math.max(PlyHealth - PlyMaxHealth, 0) ^ 1.2 / (PlyMaxHealth)) * JMod.Config.General.HandGrabStrength)
	return 1 + (math.max(PlyHealth - PlyMaxHealth, 0) ^ 1.2 / (PlyMaxHealth)) * JMod.Config.General.HandGrabStrength
end

function JMod.DebugArrangeEveryone(ply, mult)
	local Origin, Dist, Ang = ply:GetPos(), 50, Angle(0, 0, 0)
	local Beings = player.GetAll()
	table.Add(Beings, ents.FindByClass("npc_*"))
	for k, playa in pairs(Beings) do
		if (playa ~= ply) then
			local Target = Origin + Ang:Forward() * Dist
			local Tr = util.QuickTrace(Target + Vector(0, 0, 300), Vector(0, 0, -600), playa)
			playa:SetPos(Tr.HitPos)
			playa:SetHealth(playa:GetMaxHealth())
			Ang:RotateAroundAxis(vector_up, 25)
			Dist = Dist + 120 * mult
		end
	end
	ply:SetPos(Origin + Vector(0, 0, 200))
	ply:SetMoveType(MOVETYPE_NOCLIP)
	ply:SetHealth(999)
	RunConsoleCommand("r_cleardecals")
end

function JMod.EZimmobilize(victim, timeToImmobilize, immobilizer)
	if not IsValid(victim) then return end
	victim.EZimmobilizers = victim.EZimmobilizers or {}
	if not(IsValid(immobilizer)) then immobilizer = victim end
	victim.EZimmobilizers[immobilizer] = (victim.EZimmobilizers[immobilizer] or CurTime()) + timeToImmobilize
	victim.EZImmobilizationTime = timeToImmobilize
end

hook.Add("PhysgunPickup", "EZPhysgunBlock", function(ply, ent)
	if ent.block_pickup then
		JMod.Hint(ply, "blockphysgun")

		return false
	end
end)

concommand.Add("jacky_sandbox", function(ply, cmd, args)
	if not (IsValid(ply) and ply:IsSuperAdmin()) then return end
	if not GetConVar("sv_cheats"):GetBool() then return end

	for k, v in pairs({
		{"impulse 101", 10},
		"sbox_maxballoons 9e9", "sbox_maxbuttons 9e9", "sbox_maxdynamite 9e9", "sbox_maxeffects 9e9", "sbox_maxemitters 9e9", "sbox_maxhoverballs 9e9", "sbox_maxlamps 9e9", "sbox_maxlights 9e9", "sbox_maxnpcs 9e9", "sbox_maxprops 9e9", "sbox_maxragdolls 9e9", "sbox_maxsents 9e9", "sbox_maxthrusters 9e9", "sbox_maxturrets 9e9", "sbox_maxvehicles 9e9", "sbox_maxwheels 9e9", "sbox_noclip 1", "sbox_weapons 1"
	}) do
		if type(v) == "string" then
			ply:ConCommand(v)
		else
			for i = 1, v[2] do
				ply:ConCommand(v[1])
			end
		end
	end

	for k, v in pairs(JMod.AmmoTable) do
		ply:GiveAmmo(150, k)
	end

	local Helf = ply:Health()

	if Helf < 999 then
		ply:SetHealth(999)
	else
		ply:SetHealth(Helf + 1000)
	end
end, nil, "Sets us to Sandbox god mode thing.")