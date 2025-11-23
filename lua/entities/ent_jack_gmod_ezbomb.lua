-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Bomb"
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(0, -90, 0)
ENT.EZrackOffset = Vector(0, 0, 20)
ENT.EZrackAngles = Angle(0, -90, 0)
ENT.EZbombBaySize = 12
---
ENT.EZbomb = true
ENT.EZguidable = true
ENT.Model = "models/hunter/blocks/cube025x2x025.mdl"
ENT.Mass = 150
ENT.DetSpeed = 700
ENT.DetType = "impactdet"
ENT.Durability = 150

local STATE_BROKEN, STATE_OFF, STATE_ARMED = -1, 0, 1

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	if self.EZguidable then
		self:NetworkVar("Bool", 0, "Guided")
	end
end

---
if SERVER then
	-- Network string for bomb exit/reentry events
	util.AddNetworkString("JMod_EZBombTrail")
	
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * (self.SpawnHeight or 40)
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(ent.JModPreferredCarryAngles)
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
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)

		if self.Material then
			self:SetMaterial(self.Material)
		end
		if self.Skin then
			self:SetSkin(self.Skin)
		end

		---
		local Phys = self:GetPhysicsObject()
		timer.Simple(.01, function()
			if IsValid(Phys) then
				Phys:SetMass(self.Mass)
				Phys:Wake()
				Phys:EnableDrag(false)
				Phys:SetDamping(0, 0)
				if self.EZbouyancy then
					Phys:SetBuoyancyRatio(self.EZbuoyancy)
				end
			end
		end)

		---
		self:SetState(STATE_OFF)
		self.LastUse = 0
		self.FreefallTicks = 0
		self.LastAreoDragAmount = 0

		self:SetupWire()
	end

	function ENT:SetupWire()
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Drop"}, {"Directly detonates the bomb", "Arms bomb when > 0", "Drop the bomb"})

			self.Outputs = WireLib.CreateOutputs(self, {"State", "Dropped", "Guided"}, {"-1 broken \n 0 off \n 1 armed", "Outputs 1 when dropped", "True when guided"})
		end
	end

	function ENT:TriggerInput(iname, value)
		if (iname == "Detonate") and (value > 0) then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		elseif iname == "Arm" and value == 0 then
			self:SetState(STATE_OFF)
		elseif iname == "Drop" and value > 0 then
			self:Drop()
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not IsValid(self) then return end
		local SelfPos = self:LocalToWorld(self:OBBCenter())

		if data.DeltaTime > 0.2 then
			if data.Speed > 50 then
				self:EmitSound("Canister.ImpactHard")
			end

			local DetTime = 0

			if data.HitEntity == game.GetWorld() then
				local WorldTr = util.TraceLine({
					start = SelfPos,
					endpos = SelfPos + data.OurOldVelocity,
					filter = {self}
				})--]]

				local Constrained = self:IsPlayerHolding() or constraint.FindConstraint(self, "Weld") or not self:GetPhysicsObject():IsMotionEnabled()

				if WorldTr.HitSky and not(Constrained) then
					local NewPos, TravelTime, NewVel = JMod.FindSkyboxEntryPoint(SelfPos, data.OurOldVelocity, self, self.Mass, self.LastAreoDragAmount, 60, 0.1, {self})

					if NewPos then
						-- Network the exit/reentry event to clients
						net.Start("JMod_EZBombTrail")
						net.WriteVector(SelfPos) -- Exit position
						net.WriteVector(data.OurOldVelocity) -- Exit velocity
						net.WriteVector(NewPos) -- Reentry position
						net.WriteFloat(TravelTime) -- Travel time
						net.Broadcast()
						
						timer.Simple(0, function()
							if IsValid(self) then
								self:SetNoDraw(true)
								self:SetNotSolid(true)
								self:GetPhysicsObject():EnableMotion(false)
							end
						end)
						timer.Simple(TravelTime, function()
							if IsValid(self) then
								self:SetNoDraw(false)
								self:SetNotSolid(false)
								self:SetPos(NewPos)
								self:SetAngles(NewVel:Angle())
								self:GetPhysicsObject():EnableMotion(true)
								self:GetPhysicsObject():SetVelocity(NewVel)
							end
						end)
					else
						SafeRemoveEntityDelayed(self, 0)
					end

					return
				end--]]

				--print(data.Speed * physobj:GetMass())
				local OurSpeed = data.OurOldVelocity:Length()
				local Mass = physobj:GetMass()
				local SurfaceData = util.GetSurfaceData(WorldTr.SurfaceProps)
				local Hardness = (SurfaceData and SurfaceData.hardnessFactor) or 1
				local OurNoseDir = -self:GetRight()
				local AngleDiff = (OurNoseDir):Dot(-WorldTr.HitNormal)
				--print("Pen Force Diff:", (OurSpeed * Mass) - (Hardness * 1000000))

				if WorldTr.HitWorld and not(Constrained) and (AngleDiff > .75) and (OurSpeed * Mass > Hardness * 1000000) then
					DetTime = math.Rand(.5, 2)

					local Eff = EffectData()
					Eff:SetOrigin(WorldTr.HitPos)
					Eff:SetScale(10)
					Eff:SetNormal(WorldTr.HitNormal)
					util.Effect("eff_jack_sminebury", Eff, true, true)
					--
					timer.Simple(0.1, function()
						if IsValid(self) then
							local OldAngle = self:GetAngles()
							local BuryAngle = data.OurOldVelocity:Angle()
							BuryAngle:RotateAroundAxis(BuryAngle:Right(), self.JModPreferredCarryAngles.p)
							BuryAngle:RotateAroundAxis(BuryAngle:Up(), self.JModPreferredCarryAngles.y)
							BuryAngle:RotateAroundAxis(BuryAngle:Forward(), self.JModPreferredCarryAngles.r)
							BuryAngle = LerpAngle(Hardness - .2, BuryAngle, OldAngle)
							self:SetAngles(BuryAngle)
							local StickOffSet = self:GetPos() - self:WorldSpaceCenter()
							--print(StickOffSet)
							self:SetPos(WorldTr.HitPos + StickOffSet + WorldTr.HitNormal * 10)
							--
							--[[local EmptySpaceTr = util.QuickTrace(self:LocalToWorld(self:OBBCenter()) + OurNoseDir * 100, -OurNoseDir * 200, {self})
							if not EmptySpaceTr.StartSolid and not EmptySpaceTr.HitSky and EmptySpaceTr.Hit then
								timer.Simple(DetTime + .1, function()
									JMod.Sploom(JMod.GetEZowner(self), WorldTr.HitPos, 100)
								end)
								self:SetPos(EmptySpaceTr.HitPos + EmptySpaceTr.Normal * -EmptySpaceTr.Fraction * 100)
							else
								self:GetPhysicsObject():EnableMotion(false)
							end--]]
							self:GetPhysicsObject():EnableMotion(false)
						end
					end)

					if math.random(1, 1000) == 1 then
						-- A small chance for the bomb to not go off.
						return
					end
				end
			end
			
			if (self:GetState() == STATE_ARMED) and (data.Speed > self.DetSpeed) then
				timer.Simple(DetTime, function()
					if IsValid(self) then 
						self:Detonate()
					end
				end)

			elseif (data.Speed > self.Durability * 10) then
				self:Break()
			end
		end
	end

	function ENT:Break()
		if self:GetState() == STATE_BROKEN then 
			SafeRemoveEntityDelayed(self, 10)
			
			return 
		end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.ogg", 70, math.random(80, 120))

		for i = 1, 20 do
			JMod.DamageSpark(self)
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		if IsValid(self.DropOwner) then
			local Att = dmginfo:GetAttacker()
			if IsValid(Att) and (self.DropOwner == Att) then return end
		end

		self:TakePhysicsDamage(dmginfo)

		if JMod.LinCh(dmginfo:GetDamage(), self.Durability * .75, self.Durability) then
			local Pos, State = self:GetPos(), self:GetState()

			if State == STATE_ARMED and not dmginfo:IsBulletDamage() then
				JMod.SetEZowner(self, dmginfo:GetAttacker())
				self:Detonate()
			else
				self:Break()
			end
		end
	end

	function ENT:Use(activator)
		local State, Time = self:GetState(), CurTime()
		if State < 0 then return end

		if State == STATE_OFF then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:Arm(activator)
				self:EmitSound("snds_jack_gmod/bomb_arm.ogg", 70, 120)
				JMod.Hint(activator, self.DetType)
			else
				JMod.Hint(activator, "double tap to arm")
			end

			self.LastUse = Time
		elseif State == STATE_ARMED then
			JMod.SetEZowner(self, activator)

			if Time - self.LastUse < .2 then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.ogg", 70, 120)
				self.EZdroppableBombArmedTime = nil
			else
				JMod.Hint(activator, "double tap to disarm")
			end

			self.LastUse = Time
		end
	end

	function ENT:Arm(activator)
		if not IsValid(JMod.GetEZowner(self)) then
			JMod.SetEZowner(self, activator)
		end
		self:SetState(STATE_ARMED)
		self.EZdroppableBombArmedTime = CurTime()
	end

	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Att = self:GetPos() + Vector(0, 0, 60), JMod.GetEZowner(self)
		JMod.Sploom(Att, SelfPos, 150)
		---
		util.ScreenShake(SelfPos, 1000, 3, 2, 4000)
		local Eff = "500lb_ground"

		if not util.QuickTrace(SelfPos, Vector(0, 0, -300), {self}).HitWorld then
			Eff = "500lb_air"
		end

		for i = 1, 3 do
			sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", SelfPos + VectorRand() * 1000, 160, math.random(80, 110))
		end

		---
		for k, ply in player.Iterator() do
			local Dist = ply:GetPos():Distance(SelfPos)

			if (Dist > 250) and (Dist < 4000) then
				timer.Simple(Dist / 6000, function()
					ply:EmitSound("snds_jack_gmod/big_bomb_far.ogg", 55, 110)
					sound.Play("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", ply:GetPos(), 60, 70)
					util.ScreenShake(ply:GetPos(), 1000, 3, 1, 100)
				end)
			end
		end

		---
		util.BlastDamage(game.GetWorld(), Att, SelfPos + Vector(0, 0, 300), 800, 130)

		timer.Simple(.25, function()
			util.BlastDamage(game.GetWorld(), Att, SelfPos, 1600, 120)
		end)

		for k, ent in pairs(ents.FindInSphere(SelfPos, 500)) do
			if ent:GetClass() == "npc_helicopter" then
				ent:Fire("selfdestruct", "", math.Rand(0, 2))
			end
		end

		---
		JMod.WreckBuildings(self, SelfPos, 7)
		JMod.BlastDoors(self, SelfPos, 7)

		---
		timer.Simple(.2, function()
			local Tr = util.QuickTrace(SelfPos + Vector(0, 0, 100), Vector(0, 0, -400))

			if Tr.Hit then
				util.Decal("BigScorch", Tr.HitPos + Tr.HitNormal, Tr.HitPos - Tr.HitNormal)
			end
		end)

		---
		JMod.FragSplosion(self, SelfPos, 3000, 200, 8000, JMod.GetEZowner(self), nil, nil, 15)
		---
		self:Remove()

		timer.Simple(.1, function()
			ParticleEffect(Eff, SelfPos, Angle(0, 0, 0))
		end)
	end

	function ENT:OnRemove()
	end

	--
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end

	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			if self.EZguidable then WireLib.TriggerOutput(self, "Guided", self:GetGuided()) end
		end

		local Phys, UseAeroDrag = self:GetPhysicsObject(), true
		--if((self:GetState()==STATE_ARMED)and(self:GetGuided())and not(constraint.HasConstraints(self)))then
		--for k,designator in pairs(ents.FindByClass("wep_jack_gmod_ezdesignator"))do
		--if((designator:GetLasing())and(designator.EZowner)and(JMod.ShouldAllowControl(self,designator.EZowner)))then
		--[[
					local TargPos,SelfPos=ents.FindByClass("npc_*")[1]:GetPos(),self:GetPos()--designator.EZowner:GetEyeTrace().HitPos
					local TargVec=TargPos-SelfPos
					local Dist,Dir,Vel=TargVec:Length(),TargVec:GetNormalized(),Phys:GetVelocity()
					local Speed=Vel:Length()
					if(Speed<=0)then return end
					local ETA=Dist/Speed
					jprint(ETA)
					TargPos=TargPos--Vel*ETA/2
					JMod.Sploom(self,TargPos,1)
					JMod.AeroGuide(self,-self:GetRight(),TargPos,1,1,.2,10)
					--]]
		--end
		--end
		--end

		if self:GetState() == STATE_BROKEN then
			JMod.DamageSpark(self)

			self:NextThink(CurTime() + 2)

			return true
		end

		if self.AeroDragThink then
			return self:AeroDragThink()
		else
			JMod.AeroDrag(self, -self:GetRight(), 4)

			self:NextThink(CurTime() + .1)

			return true
		end
	end

	function ENT:Drop(ply)
		constraint.RemoveAll(self)
		self:GetPhysicsObject():EnableMotion(true)
		self:GetPhysicsObject():Wake()
		self.DropOwner = ply
		if WireLib then
			WireLib.TriggerOutput(self, "Dropped", 1)
		end
	end

elseif CLIENT then
	-- Table to store bomb trail data
	local BombTrails = {}
	
	-- Material for rendering trails
	local TrailMat = Material("cable/xbeam")
	-- Material for bomb position indicator
	local BombGlowMat = Material("sprites/light_glow02_add")
	
	-- Trail decay time after reentry (in seconds)
	local TRAIL_DECAY_TIME = 2
	
	-- Constant trail color (RGB values)
	local TRAIL_COLOR = Color(200, 200, 200, 255)
	-- Bomb indicator color (yellow)
	local BOMB_INDICATOR_COLOR = Color(255, 230, 0)
	
	-- Texture repeat factor (how many times the texture repeats along the trail)
	local TRAIL_TEX_REPEAT = 4
	-- Bomb indicator base size and strobe settings
	local BOMB_INDICATOR_BASE_SIZE = 1000
	local BOMB_INDICATOR_STROBE_SPEED = 1 -- Strobes per second
	
	-- Receive bomb exit/reentry events
	net.Receive("JMod_EZBombTrail", function()
		local exitPos = net.ReadVector()
		local exitVel = net.ReadVector()
		local reentryPos = net.ReadVector()
		local travelTime = net.ReadFloat()
		
		local grav = physenv.GetGravity()
		local gravZ = grav.z
		local exitVelZ = exitVel.z
		
		-- Pre-calculate apex of trajectory
		local tApex = 0
		if gravZ ~= 0 and exitVelZ > 0 then
			tApex = math.max(0, math.min(-exitVelZ / gravZ, travelTime))
		end
		
		-- Pre-calculate trail start/end times and positions
		local tStart = 0 -- Start at exit point
		local tEnd = tApex + (travelTime - tApex) * 0.75 -- End halfway between apex and reentry
		local startPos = exitPos + exitVel * tStart + grav * tStart * tStart * 0.5
		local endPos = exitPos + exitVel * tEnd + grav * tEnd * tEnd * 0.5
		local effectiveTravelTime = tEnd - tStart
		
		table.insert(BombTrails, {
			exitPos = exitPos,
			exitVel = exitVel,
			reentryPos = reentryPos,
			travelTime = travelTime,
			startTime = CurTime(),
			-- Pre-calculated values
			tStart = tStart,
			tEnd = tEnd,
			startPos = startPos,
			endPos = endPos,
			effectiveTravelTime = effectiveTravelTime
		})
	end)
	
	-- Hook to render trails
	hook.Add("PostDrawTranslucentRenderables", "JMod_EZBombTrailRender", function(bDrawingDepth, bDrawingSkybox)
		if bDrawingSkybox or #BombTrails == 0 then return end -- Don't draw in skybox or if no trails
		
		local currentTime = CurTime()
		local grav = physenv.GetGravity()
		local numSegments = 50
		local invNumSegments = 1 / numSegments
		
		-- Clean up expired trails and render active ones
		for i = #BombTrails, 1, -1 do
			local trail = BombTrails[i]
			local elapsed = currentTime - trail.startTime
			local totalLifetime = trail.travelTime + TRAIL_DECAY_TIME
			
			-- Remove trail only when fully decayed
			if elapsed >= totalLifetime then
				table.remove(BombTrails, i)
			else
				-- Check if trail is complete (bomb has reentered)
				local isComplete = elapsed >= trail.travelTime
				
				-- Calculate overall fade (for decay after reentry)
				local decayProgress = isComplete and ((elapsed - trail.travelTime) / TRAIL_DECAY_TIME) or 0
				local baseWidth = 100 * (1 - decayProgress)
				
				-- Use pre-calculated values
				local tStart = trail.tStart
				local tEnd = trail.tEnd
				local startPos = trail.startPos
				local endPos = trail.endPos
				local effectiveTravelTime = trail.effectiveTravelTime
				
				-- Calculate effective progress for the trail
				local effectiveProgress = math.Clamp((elapsed - tStart) / effectiveTravelTime, 0, 1)
				local isTrailComplete = elapsed >= tEnd
				local maxSegment = isTrailComplete and numSegments or math.floor(numSegments * effectiveProgress)
				
				-- Render trail if we have segments to render
				if maxSegment >= 1 then
					render.SetMaterial(TrailMat)
					
					-- Build list of beam points
					local beamPoints = {}
					local widthScaleStart = math.Clamp(1 - (effectiveProgress * 1.5), 0, 1)
					
					-- Add start position as first point (oldest, should pinch to 0)
					beamPoints[1] = {
						pos = startPos,
						width = baseWidth * widthScaleStart,
						texCoord = 0,
						color = TRAIL_COLOR
					}
					
					-- Add intermediate segments
					for seg = 1, maxSegment do
						local t = seg * invNumSegments
						local segTime = tStart + t * effectiveTravelTime
						
						-- Approximate trajectory with gravity (simplified physics)
						local segPos = trail.exitPos + trail.exitVel * segTime + grav * segTime * segTime * 0.5
						
						-- Calculate width pinch: older parts get thinner
						local segmentAge = math.max(0, effectiveProgress - t)
						local widthScale = math.Clamp(1 - (segmentAge * 1.5), 0, 1)
						
						beamPoints[seg + 1] = {
							pos = segPos,
							width = baseWidth * widthScale,
							texCoord = t * TRAIL_TEX_REPEAT,
							color = TRAIL_COLOR
						}
					end
					
					-- Add current position if trail is still growing (newest, full width)
					if not isTrailComplete and effectiveProgress > 0 and maxSegment < numSegments then
						local currentPos = (elapsed > tEnd) and endPos or (trail.exitPos + trail.exitVel * elapsed + grav * elapsed * elapsed * 0.5)
						
						beamPoints[#beamPoints + 1] = {
							pos = currentPos,
							width = baseWidth,
							texCoord = effectiveProgress * TRAIL_TEX_REPEAT,
							color = TRAIL_COLOR
						}
					end
					
					-- Render the beam if we have at least 2 points
					local numPoints = #beamPoints
					if numPoints >= 2 then
						render.StartBeam(numPoints)
						for j = 1, numPoints do
							local point = beamPoints[j]
							render.AddBeam(point.pos, point.width, point.texCoord, point.color)
						end
						render.EndBeam()
					end
					
					-- Render strobing yellow spot at bomb's current position
					-- Only render while trail is still progressing (not at end point) and bomb hasn't reentered
					if not isTrailComplete and not isComplete and elapsed <= trail.travelTime then
						-- Calculate strobe size using sine wave (oscillates between 70% and 100% of base size)
						local strobePhase = currentTime * BOMB_INDICATOR_STROBE_SPEED * 2 * math.pi
						local sizeMod = 0.7 + 0.3 * math.sin(strobePhase) -- Oscillates between 0.7 and 1.0
						local indicatorSize = BOMB_INDICATOR_BASE_SIZE * sizeMod
						
						-- Render the glow sprite
						render.SetMaterial(BombGlowMat)
						render.DrawSprite(beamPoints[numPoints].pos, indicatorSize, indicatorSize, BOMB_INDICATOR_COLOR)
					end
				end
			end
		end
	end)
	
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/jmod/mk82_gbu.mdl")
		self.Mdl:SetModelScale(.9, 0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.Guided = false
	end

	function ENT:Think()
		if self.EZguidable and (not self.Guided) and self:GetGuided() then
			self.Guided = true
			self.Mdl:SetBodygroup(0, 1)
		end
	end

	function ENT:Draw()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos - Ang:Up() * 3 - Ang:Right() * 6)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end

	language.Add("ent_jack_gmod_ezbomb", "EZ Bomb")
end
