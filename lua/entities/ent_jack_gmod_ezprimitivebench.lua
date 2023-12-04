-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.Type = "anim"
ENT.PrintName = "EZ Crafting Table"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Machines"
ENT.Information = "glhfggwpezpznore"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Model = "models/jmod/machines/primitive_bench.mdl"
ENT.Mass = 200
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.WOOD,
	JMod.EZ_RESOURCE_TYPES.COAL,
	JMod.EZ_RESOURCE_TYPES.IRONORE,
	JMod.EZ_RESOURCE_TYPES.LEADORE,
	JMod.EZ_RESOURCE_TYPES.ALUMINUMORE,
	JMod.EZ_RESOURCE_TYPES.COPPERORE,
	JMod.EZ_RESOURCE_TYPES.TUNGSTENORE,
	JMod.EZ_RESOURCE_TYPES.TITANIUMORE,
	JMod.EZ_RESOURCE_TYPES.SILVERORE,
	JMod.EZ_RESOURCE_TYPES.GOLDORE,
	JMod.EZ_RESOURCE_TYPES.URANIUMORE,
	JMod.EZ_RESOURCE_TYPES.PLATINUMORE,
	JMod.EZ_RESOURCE_TYPES.SAND
}
ENT.FlexFuels = {JMod.EZ_RESOURCE_TYPES.WOOD, JMod.EZ_RESOURCE_TYPES.COAL}
ENT.EZcolorable = false
---
ENT.StaticPerfSpecs={
	MaxDurability = 90,
	Armor = .7
}
local STATE_BROKEN, STATE_FINE, STATE_PROCESSING = -1, 0, 1
function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Progress")
	self:NetworkVar("Float", 2, "Ore")
	self:NetworkVar("String", 0, "OreType")
end
if(SERVER)then
	function ENT:CustomInit()
		local phys = self.Entity:GetPhysicsObject()
		if phys:IsValid()then
			phys:SetBuoyancyRatio(.3)
		end
		if not(self.EZowner)then self:SetColor(Color(255, 255, 255)) end
		self:UpdateConfig()
		self:SetProgress(0)
		self:SetOre(0)
		self:SetOreType("generic")
		self.MaxOre = 30
		self.NextEffThink = 0
		self.NextSmeltThink = 0
		self.NextEnvThink = 0
	end

	function ENT:UpdateConfig()
		self.Craftables={}
		for name,info in pairs(JMod.Config.Craftables)do
			if (istable(info.craftingType) and table.HasValue(info.craftingType,"craftingtable")) or (info.craftingType=="craftingtable")then
				-- we store this here for client transmission later
				-- because we can't rely on the client having the config
				local infoCopy=table.FullCopy(info)
				infoCopy.name=name
				self.Craftables[name]=info
			end
		end
	end

	function ENT:SetupWire()
		if not(istable(WireLib)) then return end
		---
		local WireOutputs = {"State [NORMAL]"}
		local WireOutputDesc = {"The state of the machine \n-1 is broken \n0 is fine"}
		for _, typ in ipairs(self.EZconsumes) do
			if typ == JMod.EZ_RESOURCE_TYPES.BASICPARTS then typ = "Durability" end
			local ResourceName = string.Replace(typ, " ", "")
			local ResourceDesc = "Amount of "..ResourceName.." left"
			--
			local OutResourceName = string.gsub(ResourceName, "^%l", string.upper).." [NORMAL]"
			table.insert(WireOutputs, OutResourceName)
			table.insert(WireOutputDesc, ResourceDesc)
		end
		self.Outputs = WireLib.CreateOutputs(self, WireOutputs, WireOutputDesc)
	end

	function ENT:Use(activator)
		local Alt = activator and activator:KeyDown(JMod.Config.General.AltFunctionKey)
		local State = self:GetState()
		if(State == STATE_FINE) then
			if (self:GetElectricity() > 0) then
				if Alt then
					self:TurnOn(activator)
				else
					net.Start("JMod_EZworkbench")
					net.WriteEntity(self)
					net.WriteTable(self.Craftables)
					net.WriteFloat(1.3)
					net.Send(activator)
					JMod.Hint(activator, "craft")
				end
			else
				JMod.Hint(activator, "refill")
			end
		elseif (State == STATE_PROCESSING) then
			self:TurnOff(activator)
		else
			JMod.Hint(activator, "destroyed")
		end
	end

	function ENT:TurnOn(activator)
		if (self:GetState() == STATE_PROCESSING) then return end
		if (self:GetElectricity() <= 0) then JMod.Hint(activator, "refill") return end
		self:SetState(STATE_PROCESSING)
		self:EmitSound("snd_jack_littleignite.wav")
		timer.Simple(0.1, function()
			if(self.SoundLoop)then self.SoundLoop:Stop() end
			self.SoundLoop = CreateSound(self, "snds_jack_gmod/intense_fire_loop.wav")
			self.SoundLoop:SetSoundLevel(50)
			self.SoundLoop:Play()
		end)
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= STATE_FINE) then return end
		self:SetState(STATE_FINE)
		self:ProduceResource()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end

	function ENT:Think()
		local State, Time, OreTyp = self:GetState(), CurTime(), self:GetOreType()
		local FirePos = self:GetPos() + self:GetUp() * -8 + self:GetRight() * 50 + self:GetForward() * -8

		if (State == STATE_PROCESSING) then
			if (self.NextSmeltThink < Time) then
				self.NextSmeltThink = Time + 1
				if (self:WaterLevel() > 0) then 
					self:TurnOff() 
					local Foof = EffectData()
					Foof:SetOrigin(FirePos)
					Foof:SetNormal(Vector(0, 0, 1))
					Foof:SetScale(10)
					Foof:SetStart(self:GetPhysicsObject():GetVelocity())
					util.Effect("eff_jack_gmod_ezsteam", Foof, true, true)
					self:EmitSound("snds_jack_gmod/hiss.wav", 120, 90)
					return 
				end
				--if not OreTyp then self:TurnOff() return end

				self:ConsumeElectricity(.2)

				if OreTyp and not(self:GetOre() <= 0) then
					local OreConsumeAmt = .5
					local MetalProduceAmt = .8 * JMod.SmeltingTable[OreTyp][2]
					self:SetOre(self:GetOre() - OreConsumeAmt)
					self:SetProgress(self:GetProgress() + MetalProduceAmt)
					self:ConsumeElectricity(1)
					if self:GetProgress() >= 100 then
						self:ProduceResource()
					end
				else
					self:ProduceResource()
				end
			end
			if (self.NextEffThink < Time) then
				self.NextEffThink = Time + .1
				local Eff = EffectData()
				Eff:SetOrigin(FirePos)
				Eff:SetNormal(self:GetUp())
				Eff:SetScale(.05)
				util.Effect("eff_jack_gmod_ezoilfiresmoke", Eff, true)
			end
			if (self.NextEnvThink < Time) then
				self.NextEnvThink = Time + 5

				local Tr = util.QuickTrace(FirePos, Vector(0, 0, 9e9), self)
				if not (Tr.HitSky) then
					for i = 1, 1 do
						local Gas = ents.Create("ent_jack_gmod_ezgasparticle")
						Gas:SetPos(Tr.HitPos)
						JMod.SetEZowner(Gas, self.EZowner)
						Gas:SetDTBool(0, true)
						Gas:Spawn()
						Gas:Activate()
						Gas.CurVel = (VectorRand() * math.random(1, 100))
					end
				end
			end
		end
		self:NextThink(Time + .1)
	end

	function ENT:PhysicsCollide(data, physobj)
		if (data.Speed>80) and (data.DeltaTime>0.2) then
			self:EmitSound("Wood.ImpactSoft")
			local Ent = data.HitEntity
			local Held = false
			local Pos = data.HitPos
			if self:IsPlayerHolding() or (IsValid(Ent) and Ent:IsPlayerHolding()) then Held = true end
			if (data.Speed > 150) then
				if (Ent:GetClass() == "prop_physics") and Held then
					DropEntityIfHeld(Ent)
					timer.Simple(0.1, function()
						local Yield, Message = JMod.GetSalvageYield(Ent)

						if #table.GetKeys(Yield) <= 0 then
							JMod.GetEZowner(self):PrintMessage(HUD_PRINTCENTER, Message)
						elseif Ent:GetPhysicsObject():GetMass() <= 35 then
							sound.Play("snds_jack_gmod/ez_tools/hit.wav", Pos + VectorRand(), 70, math.random(50, 60))
							JMod.BuildEffect(Pos)

							local i = 0
							for k, v in pairs(Yield) do
								JMod.MachineSpawnResource(self, k, v, self:WorldToLocal(Pos + data.HitNormal * 20 + VectorRand() * 40), Angle(0, 0, 0), Vector(0, 0, 100), true, 200)
								i = i + 1
							end
							if Ent.JModInv then
								for _, v in ipairs(Ent.JModInv.items) do
									JMod.RemoveFromInventory(Ent, v.ent, Pos + VectorRand() * 50)
								end
							end
							SafeRemoveEntity(Ent)
						end
					end)
				end
				self:EmitSound("Wood.ImpactHard")
				if (data.Speed > 500) then
					local World = game.GetWorld()
					local CollisionDir = data.OurOldVelocity - data.TheirOldVelocity
					local TheirForce = (.5 * data.HitObject:GetMass() * ((CollisionDir:Length()/16)*0.3048)^2)
					if Ent == World then
						TheirForce = (.5 * physobj:GetMass() * ((CollisionDir:Length()/16)*0.3048)^2)
					end
					local ForceThreshold = physobj:GetMass() * (self.EZanchorage or 1000)
					local PhysDamage = TheirForce/(physobj:GetMass())

					if self.EZinstalled and not(physobj:IsMotionEnabled()) and (TheirForce >= ForceThreshold) then
						physobj:EnableMotion(true)
					end
					if PhysDamage >= 1 and not(Held) then
						local CrushDamage = DamageInfo()
						CrushDamage:SetDamage(math.floor(PhysDamage))
						CrushDamage:SetDamageType(DMG_CRUSH)
						CrushDamage:SetDamageForce(data.TheirOldVelocity / 1000)
						CrushDamage:SetDamagePosition(data.HitPos)
						CrushDamage:SetAttacker(Ent or World)
						CrushDamage:SetInflictor(Ent or World)
						self:TakeDamageInfo(CrushDamage)
						self:EmitSound("Metal_Box.Break")
						JMod.DamageSpark(self)
					end
				end
			end
		end
	end

	function ENT:ProduceResource()
		local SelfPos, Forward, Up, Right, OreType = self:GetPos(), self:GetForward(), self:GetUp(), self:GetRight(), self:GetOreType()
		local amt = math.Clamp(math.floor(self:GetProgress()), 0, 100)

		local spawnVec = self:WorldToLocal(SelfPos + Forward * 10 + Up * 50)
		local spawnAng = self:GetAngles()
		local ejectVec = Up * 50

		if amt > 0 or OreType ~= "generic" then
			local RefinedType = JMod.SmeltingTable[OreType][1]
			timer.Simple(0.3, function()
				if IsValid(self) then
					JMod.MachineSpawnResource(self, RefinedType, amt, spawnVec, spawnAng, ejectVec, true, 200)
					if (OreType == JMod.EZ_RESOURCE_TYPES.SAND) and (amt >= 25) and math.random(0, 100) then
						JMod.MachineSpawnResource(self, JMod.EZ_RESOURCE_TYPES.DIAMOND, 1, spawnVec + Up * 4, spawnAng, ejectVec, false)
					end
				end
			end)
			self:SetProgress(0)
			self:EmitSound("snds_jack_gmod/ding.wav", 80, 120)
		end

		if self:GetOre() <= 0 then
			self:SetOreType("generic")
		elseif OreType ~= "generic" then
			JMod.MachineSpawnResource(self, OreType, self:GetOre(), spawnVec + Up * 4 + Right * 20, spawnAng, ejectVec, false)
			self:SetOreType("generic")
			self:SetOre(0)
		end
	end

	function ENT:TryBuild(itemName,ply)
		local ItemInfo=self.Craftables[itemName]

		if(JMod.HaveResourcesToPerformTask(nil,nil,ItemInfo.craftingReqs,self,nil,1.3))then
			local override, msg=hook.Run("JMod_CanWorkbenchBuild", ply, workbench, itemName)
			if override == false then
				ply:PrintMessage(HUD_PRINTCENTER,msg or "cannot build")
				return
			end
			local Pos,Ang,BuildSteps=self:GetPos()+self:GetUp()*55+self:GetForward()*0-self:GetRight()*5,self:GetAngles(),10
			JMod.ConsumeResourcesInRange(ItemInfo.craftingReqs,Pos,nil,self,true,nil,1.3)
			timer.Simple(1,function()
				if(IsValid(self))then
					for i=1,BuildSteps do
						timer.Simple(i/100,function()
							if(IsValid(self))then
								if(i<BuildSteps)then
									sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".wav",Pos,60,math.random(80,120))
								else
									JMod.BuildRecipe(ItemInfo.results, ply, Pos, Ang, ItemInfo.skin)
									JMod.BuildEffect(Pos)
									self:ConsumeElectricity(8)
									self:UpdateWireOutputs()
								end
							end
						end)
					end
				end
			end)
		else
			JMod.Hint(ply,"missing supplies")
		end
	end

	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end

elseif(CLIENT)then
	function ENT:CustomInit()
		--self.Camera=JMod.MakeModel(self,"models/props_combine/combinecamera001.mdl")
		self.MaxOre = 30
	end

	function ENT:DrawTranslucent()
		local State = self:GetState()
		local SelfPos,SelfAng,FT=self:GetPos(),self:GetAngles(),FrameTime()
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		---
		local BasePos = SelfPos + Up*30
		local Obscured = false--util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw = false end -- if obscured, at least disable details
		if(self:GetState()<0)then DetailDraw = false end
		---
		self:DrawModel()
		---
		if(DetailDraw)then
			if(self:GetElectricity() > 0) then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Forward, 90)
				DisplayAng:RotateAroundAxis(Up, 90)
				local Opacity = math.random(50, 200)
				cam.Start3D2D(BasePos - Up * 38 + Right * 50 + Forward * 1.8, DisplayAng, .04)
				--draw.SimpleTextOutlined("JMOD","JMod-Display",0,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ProFrac = self:GetProgress() / 100
				local OreFrac = self:GetOre() / self.MaxOre
				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local R, G, B = JMod.GoodBadColor(ProFrac)
				local OR, OG, OB = JMod.GoodBadColor(OreFrac)
				local ER, EG, EB = JMod.GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined("FUEL "..math.Round(ElecFrac * 100).."%","JMod-Display",0,0,Color(ER, EG, EB, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				if (State == STATE_PROCESSING) then
					draw.SimpleTextOutlined("PROGRESS", "JMod-Display", 0, 30, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(ProFrac * 100)) .. "%", "JMod-Display", 0, 60, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(string.upper(self:GetOreType()), "JMod-Display", 0, 90, Color(228, 215, 101, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("REMAINING", "JMod-Display", 0, 120,Color(228, 215, 101, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined(tostring(math.Round(OreFrac * self.MaxOre)), "JMod-Display", 0, 150, Color(OR, OG, OB, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, Color(0, 0, 0, Opacity))
				end
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezprimitivebench","EZ Crafting Table")
end
