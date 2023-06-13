﻿-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Base="ent_jack_gmod_ezmachine_base"
ENT.PrintName="EZ Aid Radio"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Machines"
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.NoSitAllowed=true
ENT.Model="models/props_phx/oildrum001_explosive.mdl"
ENT.Mat="models/mat_jack_gmod_ezradio"
ENT.Mass=150
----
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.SpawnHeight=20
----
ENT.StaticPerfSpecs={
	MaxDurability=100,
	Armor=.8
}
----
local STATE_BROKEN,STATE_OFF,STATE_CONNECTING=-1,0,1
function ENT:CustomSetupDataTables()
	self:NetworkVar("Int",2,"OutpostID")
end
if(SERVER)then
	function ENT:CustomInit()
		local phys = self:GetPhysicsObject()
		if phys:IsValid()then
			phys:SetBuoyancyRatio(.3)
		end

		---
		self.ThinkSpeed=1
		self.ElectricalEfficiency=2
		---
		self.NextWhine=0
		self.NextRealThink=0
		self.NextUseTime=0
		self:SetOutpostID(0)
		self.HaveCheckedForSky = false
		self.ConnectionAttempts = 0
		self.ConnectionlessThinks = 0
		---
		local Path = "/npc/combine_soldier/vo/"
		local Files, Folders = file.Find("sound" .. Path .. "*.wav", "GAME")
		self.Voices = Files
	end

	function ENT:Use(activator)
		local Time = CurTime()
		if self.NextUseTime > Time then return end
		self.NextUseTime = Time + .25

		if activator:IsPlayer() then
			local State = self:GetState()

			if State == STATE_BROKEN then
				JMod.Hint(self.EZowner, "destroyed")

				return
			end

			local Alt = activator:KeyDown(JMod.Config.General.AltFunctionKey)

			if State > 0 then
				if Alt and State == JMod.EZ_STATION_STATE_READY then
					net.Start("JMod_EZradio")
					net.WriteBool(false)
					net.WriteEntity(self)
					net.WriteTable(JMod.Config.RadioSpecs.AvailablePackages)
					net.Send(activator)
				else
					self:TurnOff()
					JMod.Hint(activator, "toggle")
				end
			else
				if self:GetElectricity() > 0 then
					self:TurnOn(activator)
					JMod.Hint(activator, "aid help")
				else
					JMod.Hint(self.EZowner, "nopower")
				end
			end
		end
	end

	function ENT:TurnOff()
		if (self:GetState() <= 0) then return end
		self:SetState(STATE_OFF)
		self:EmitSound("snds_jack_gmod/ezsentry_shutdown.wav", 65, 100)
	end

	function ENT:Speak(msg, parrot)
		if self:GetState() < 1 then return end
		self:ConsumeElectricity()

		if parrot then
			for _, ply in pairs(player.GetAll()) do
				if ply:Alive() and (ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 or (self:UserIsAuthorized(ply) and ply.EZarmor and ply.EZarmor.effects.teamComms)) then
					net.Start("JMod_EZradio")
					net.WriteBool(true)
					net.WriteBool(true)
					net.WriteString(parrot)
					net.WriteEntity(self)
					net.Send(ply)
				end
			end
		end

		local MsgLength = string.len(msg)

		for i = 1, math.Round(MsgLength / 15) do
			timer.Simple(i * .75, function()
				if IsValid(self) and (self:GetState() > 0) then
					self:EmitSound("/npc/combine_soldier/vo/" .. self.Voices[math.random(1, #self.Voices)], 65, 120)
				end
			end)
		end

		timer.Simple(.5, function()
			if IsValid(self) then
				for _, ply in pairs(player.GetAll()) do
					if ply:Alive() and (ply:GetPos():DistToSqr(self:GetPos()) <= 200 * 200 or (self:UserIsAuthorized(ply) and ply.EZarmor and ply.EZarmor.effects.teamComms)) then
						net.Start("JMod_EZradio")
						net.WriteBool(true)
						net.WriteBool(false)
						net.WriteString(msg)
						net.WriteEntity(self)
						net.Send(ply)
					end
				end
			end
		end)
	end

	function ENT:TurnOn(activator)
		local OldOwner = self.EZowner
		JMod.SetEZowner(self, activator)

		if IsValid(self.EZowner) then
			-- if owner changed then reset team color
			if OldOwner ~= self.EZowner then
				JMod.Colorify(self)
			end
		end

		self:SetState(STATE_CONNECTING)
		self:EmitSound("snds_jack_gmod/ezsentry_startup.wav", 65, 100)
		self.ConnectionAttempts = 0
	end

	function ENT:Connect(ply)
		if not ply then return end
		local Team = 0

		if engine.ActiveGamemode() == "sandbox" and ply:Team() == TEAM_UNASSIGNED then
			Team = ply:AccountID()
		else
			Team = ply:Team()
		end

		JMod.EZradioEstablish(self, tostring(Team)) -- we store team indices as strings because they might be huge (if it's a player's acct id)
		local OutpostID = self:GetOutpostID()
		local Station = JMod.EZ_RADIO_STATIONS[OutpostID]
		self:SetState(Station.state)

		timer.Simple(1, function()
			if IsValid(self) then
				self:Speak("Comm line established with J.I. Radio Outpost " .. OutpostID)
			end
		end)
	end

	function ENT:Think()
		local State, Time = self:GetState(), CurTime()

		if self.NextRealThink < Time then
			local Electricity = self:GetElectricity()
			self.NextRealThink = Time + 4 / self.ThinkSpeed

			if State == STATE_CONNECTING then
				self:ConsumeElectricity()

				if self:TryFindSky() then
					self:Speak("Broadcast received, establishing comm line...")
					self:Connect(self.EZowner)
				else
					JMod.Hint(self.EZowner, "aid sky")
					self.ConnectionAttempts = self.ConnectionAttempts + 1

					if self.ConnectionAttempts > 5 then
						self:Speak("Can not establish connection to any outpost. Shutting down.")

						timer.Simple(1, function()
							if IsValid(self) then
								self:TurnOff()
							end
						end)
					end
				end
			elseif State > 0 then
				self:ConsumeElectricity(0.3)

				if not self:TryFindSky() then
					self.ConnectionlessThinks = self.ConnectionlessThinks + 1

					if self.ConnectionlessThinks > 5 then
						self:Speak("Connection to outpost lost. Shutting down.")

						timer.Simple(1, function()
							if IsValid(self) then
								self:TurnOff()
							end
						end)
					end
				else
					self.ConnectionlessThinks = 0
				end

				if Electricity < self.MaxElectricity * .1 then
					self:Whine()
				end

				if Electricity <= 0 then
					self:TurnOff()
				end
			end
		end

		self:NextThink(Time + .05)

		return true
	end

	function ENT:TryFindSky()
		local SelfPos = self:LocalToWorld(Vector(10, 0, 45))

		for i = 1, 3 do
			local Dir = self:LocalToWorldAngles(Angle(-50 + i * 5, 0, 0)):Forward()

			local HitSky = util.TraceLine({
				start = SelfPos,
				endpos = SelfPos + Dir * 9e9,
				filter = {self},
				mask = MASK_OPAQUE
			}).HitSky

			if HitSky then return true end
		end

		return false
	end

	function ENT:Whine(serious)
		local Time = CurTime()

		if self.NextWhine < Time then
			self.NextWhine = Time + 4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.wav", 70, 100)
			self:ConsumeElectricity(.02)
		end
	end
	function ENT:UserIsAuthorized(ply)
		if not ply then return false end
		if not ply:IsPlayer() then return false end
		if self.EZowner and (ply == self.EZowner) then return true end
		local Allies = (self.EZowner and self.EZowner.JModFriends) or {}
		if table.HasValue(Allies, ply) then return true end

		if not (engine.ActiveGamemode() == "sandbox" and ply:Team() == TEAM_UNASSIGNED) then
			local OurTeam = nil

			if IsValid(self.EZowner) then
				OurTeam = self.EZowner:Team()
			end

			return (OurTeam and ply:Team() == OurTeam) or false
		end

		return false
	end

	function ENT:EZreceiveSpeech(ply, txt)
		local State = self:GetState()
		if State < 2 then return end

		if not self:TryFindSky() then
			JMod.Hint(self.EZowner, "aid sky")
			self:Speak("Can not establish connection to any outpost. Shutting down.")

			timer.Simple(1, function()
				if IsValid(self) then
					self:TurnOff()
				end
			end)

			return
		end

		if not self:UserIsAuthorized(ply) then return end
		txt = string.lower(txt)
		local NormalReq, BFFreq = string.sub(txt, 1, 14) == "supply radio: ", string.sub(txt, 1, 6) == "heyo: "

		if NormalReq or BFFreq then
			local Name, ParrotPhrase = string.sub(txt, 15), txt

			if BFFreq then
				Name = string.sub(txt, 7)
			end

			if Name == "help" then
				if State == 2 then
					--local Msg,Num='stand near radio\nsay in chat: "status", or "supply radio: [package]"\navailable packages are:\n',1
					local Msg, Num = 'stand near radio and say in chat "supply radio: status", or "supply radio: [package]". available packages are:', 1
					self:Speak(Msg, ParrotPhrase)
					local str = ""

					for name, items in pairs(JMod.Config.RadioSpecs.AvailablePackages) do
						str = str .. name

						if Num > 0 and Num % 10 == 0 then
							local newStr = str

							timer.Simple(Num / 10, function()
								if IsValid(self) then
									self:Speak(newStr)
								end
							end)

							str = ""
						else
							str = str .. ", "
						end

						Num = Num + 1
					end

					timer.Simple(Num / 10, function()
						if IsValid(self) then
							self:Speak(str)
						end
					end)

					JMod.Hint(self.EZowner, "aid package")

					return true
				end
			elseif Name == "status" then
				self:Speak(JMod.EZradioStatus(self, self:GetOutpostID(), ply, BFFreq), ParrotPhrase)

				return true
			elseif JMod.Config.RadioSpecs.AvailablePackages[Name] then
				self:Speak(JMod.EZradioRequest(self, self:GetOutpostID(), ply, Name, BFFreq), ParrotPhrase)

				return true
			end
		end

		return false
	end
	function ENT:PostEntityPaste(ply, ent, createdEntities)
		local Time = CurTime()
		JMod.SetEZowner(self, ply, true)
		ent.NextRefillTime = Time + math.Rand(0, 3)
		ent.NextWhine = Time + math.Rand(0, 3)
		ent.NextRealThink = Time + math.Rand(0, 3)
		ent.NextUseTime = Time + math.Rand(0, 3)
	end
elseif(CLIENT)then
	function ENT:CustomInit()
		self.Dish=JMod.MakeModel(self,"models/props_rooftop/satellitedish02.mdl")
		self.Panel=JMod.MakeModel(self,"models/props_lab/reciever01a.mdl",nil,.8)
		self.Headset=JMod.MakeModel(self,"models/lt_c/sci_fi/headset_2.mdl")
		self.LeftHandle=JMod.MakeModel(self,"models/props_wasteland/panel_leverhandle001a.mdl","phoenix_storms/metal")
		self.RightHandle=JMod.MakeModel(self,"models/props_wasteland/panel_leverhandle001a.mdl","phoenix_storms/metal")
		self.MaxElectricity=100
		local Files,Folders=file.Find("sound/npc/combine_soldier/vo/*.wav","GAME")
		self.Voices=Files
	end

	local function ColorToVector(col)
		return Vector(col.r / 255, col.g / 255, col.b / 255)
	end

	local GlowSprite, StateMsgs = Material("sprites/mat_jack_basicglow"), {
		[STATE_CONNECTING] = "Connecting...",
		[JMod.EZ_STATION_STATE_READY] = "Ready",
		[JMod.EZ_STATION_STATE_DELIVERING] = "Delivering",
		[JMod.EZ_STATION_STATE_BUSY] = "Busy"
	}

	function ENT:Draw()
		local SelfPos, SelfAng, State = self:GetPos(), self:GetAngles(), self:GetState()
		local Up, Right, Forward, FT = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward(), FrameTime()
		---
		local BasePos = SelfPos + Up * 32

		local Obscured = util.TraceLine({
			start = EyePos(),
			endpos = BasePos,
			filter = {LocalPlayer(), self},
			mask = MASK_OPAQUE
		}).Hit

		local Closeness = LocalPlayer():GetFOV() * EyePos():Distance(SelfPos)
		local DetailDraw = Closeness < 36000 -- cutoff point is 400 units when the fov is 90 degrees
		if (not DetailDraw) and Obscured then return end -- if player is far and sentry is obscured, draw nothing

		-- if obscured, at least disable details
		if Obscured then
			DetailDraw = false
		end

		-- look incomplete to indicate damage, save on gpu comp too
		if State == STATE_BROKEN then
			DetailDraw = false
		end

		---
		local Matricks = Matrix()
		Matricks:Scale(Vector(1, 1, .5))
		self:EnableMatrix("RenderMultiply", Matricks)
		self:DrawModel()
		---
		local DishAng = SelfAng:GetCopy()
		DishAng:RotateAroundAxis(Right, 20)
		JMod.RenderModel(self.Dish, BasePos + Up * 8 + Forward * 8, DishAng, nil, Vector(.7, .7, .7))

		---
		if DetailDraw then
			local PanelAng = SelfAng:GetCopy()
			PanelAng:RotateAroundAxis(Right, 90)
			JMod.RenderModel(self.Panel, BasePos - Up * 15 - Forward * 6, PanelAng, nil, Vector(.7, .7, .7))
			---
			local HeadsetAng = SelfAng:GetCopy()
			HeadsetAng:RotateAroundAxis(Right, -110)
			JMod.RenderModel(self.Headset, BasePos - Up * 4, HeadsetAng, nil, ColorToVector(self:GetColor()))
			---
			local LeftHandleAng = SelfAng:GetCopy()
			LeftHandleAng:RotateAroundAxis(LeftHandleAng:Up(), 90)
			LeftHandleAng:RotateAroundAxis(LeftHandleAng:Right(), 173)
			JMod.RenderModel(self.LeftHandle, SelfPos + Up * 20 + Right * 13.7, LeftHandleAng)
			---
			local RightHandleAng = SelfAng:GetCopy()
			RightHandleAng:RotateAroundAxis(RightHandleAng:Up(), -90)
			RightHandleAng:RotateAroundAxis(RightHandleAng:Right(), 173)
			JMod.RenderModel(self.RightHandle, SelfPos + Up * 20 - Right * 13.7, RightHandleAng)

			if (Closeness < 20000) and (State > 0) then
				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(), 80)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(), -90)
				local Opacity = math.random(50, 150)
				cam.Start3D2D(SelfPos + Up * 38 - Forward * 5, DisplayAng, .075)

				if State > 1 then
					draw.SimpleTextOutlined("Connected to:", "JMod-Display", 0, 0, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, Opacity))
					draw.SimpleTextOutlined("J.I. Radio Outpost " .. self:GetOutpostID(), "JMod-Display", 0, 40, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, Opacity))
				end

				local ElecFrac = self:GetElectricity() / self.MaxElectricity
				local R, G, B = JMod.GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined("Power: " .. math.Round(ElecFrac * 100) .. "%", "JMod-Display", 0, 70, Color(R, G, B, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, Opacity))
				draw.SimpleTextOutlined(StateMsgs[State], "JMod-Display", 0, 100, Color(255, 255, 255, Opacity), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, Opacity))

				if State == JMod.EZ_STATION_STATE_READY then
					draw.SimpleTextOutlined('say "supply radio: help"', "JMod-Display-S", 0, 140, Color(255, 255, 255, Opacity / 2), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, Opacity / 2))
				end

				cam.End3D2D()
			end
		end
	end

	language.Add("ent_jack_gmod_ezaidradio", "EZ Aid Radio")
end
