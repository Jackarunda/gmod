-- Jackarunda, AdventureBoots 2023
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmachine_base"
ENT.PrintName = "EZ Fabricator"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Machines"
ENT.Information = "glhfggwpezpznore"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
---
ENT.Model = "models/jmod/machines/parts_machine.mdl"
ENT.Mass = 1000
ENT.JModPreferredCarryAngles = Angle(0, 180, 0)
ENT.EZcolorable = true
ENT.EZbouyancy = .3
---
ENT.EZconsumes = {
	JMod.EZ_RESOURCE_TYPES.BASICPARTS,
	JMod.EZ_RESOURCE_TYPES.WATER,
	JMod.EZ_RESOURCE_TYPES.GAS,
	JMod.EZ_RESOURCE_TYPES.CHEMICALS,
	JMod.EZ_RESOURCE_TYPES.POWER
}
---
ENT.StaticPerfSpecs={
	MaxDurability = 150,
	Armor = 1,
	MaxElectricity = 300,
	MaxGas = 300,
	MaxChemicals = 100,
	MaxWater = 100
}

local STATE_BROKEN, STATE_FINE = -1, 0

function ENT:CustomSetupDataTables()
	self:NetworkVar("Float", 1, "Gas")
	self:NetworkVar("Float", 2, "Water")
	self:NetworkVar("Float", 3, "Chemicals")
end

if(SERVER)then
	function ENT:CustomInit()
		if not(self.EZowner)then self:SetColor(Color(45, 101, 153)) end
		self:UpdateConfig()
		---
		if self.SpawnFull then
			self:SetGas(self.MaxGas)
			self:SetChemicals(self.MaxChemicals)
			self:SetWater(self.MaxWater)
		else
			self:SetGas(0)
			self:SetChemicals(0)
			self:SetWater(0)
		end
	end

	function ENT:UpdateConfig()
		self.Craftables = {}
		for name, info in pairs(JMod.Config.Craftables)do
			if (istable(info.craftingType) and table.HasValue(info.craftingType,"fabricator")) or (info.craftingType=="fabricator")then
				-- we store this here for client transmission later
				-- because we can't rely on the client having the config
				local infoCopy = table.FullCopy(info)
				infoCopy.name = name
				self.Craftables[name] = info
			end
		end
	end

	function ENT:Use(activator)
		if(self:GetState() == STATE_FINE)then
			if(self:GetElectricity() >= 10) and (self:GetGas() >= 8) and (self:GetWater() >= 4) and (self:GetChemicals() >= 4) then
				net.Start("JMod_EZworkbench")
				net.WriteEntity(self)
				net.WriteString("fabricator")
				net.WriteFloat(1)
				net.Send(activator)
			else
				JMod.Hint(activator, "refillfab")
			end
		else
			JMod.Hint(activator, "destroyed")
		end
	end

	function ENT:TryBuild(itemName, ply)
		local ItemInfo = self.Craftables[itemName]

		if not(self:GetElectricity() >= 10) or not(self:GetGas() >= 8) or not(self:GetWater() >= 4) or not(self:GetChemicals() >= 4) then
			JMod.Hint(ply, "refill")
			return
		end

		if(JMod.HaveResourcesToPerformTask(nil, nil, ItemInfo.craftingReqs, self))then
			local override, msg = hook.Run("JMod_CanWorkbenchBuild", ply, self, itemName)
			if override == false then
				ply:PrintMessage(HUD_PRINTCENTER, msg or "cannot build")
				return
			end

			local Pos, Ang, BuildSteps = self:GetPos() + self:GetUp()*75 - self:GetForward()*10 - self:GetRight()*5, self:GetAngles(), 10
			JMod.ConsumeResourcesInRange(ItemInfo.craftingReqs, Pos, nil, self, true)

			timer.Simple(1,function()
				if (IsValid(self)) then
					for i=1,BuildSteps do
						timer.Simple(i/100,function()
							if(IsValid(self))then
								if(i<BuildSteps)then
									sound.Play("snds_jack_gmod/ez_tools/"..math.random(1,27)..".ogg",Pos,60,math.random(80,120))
								else
									JMod.BuildRecipe(ItemInfo.results, self, ply, Pos, Ang, ItemInfo.skin)
									JMod.BuildEffect(Pos)
									self:SetElectricity(math.Clamp(self:GetElectricity() - 15, 0.0, self.MaxElectricity))
									self:SetGas(math.Clamp(self:GetGas() - 10, 0.0, self.MaxGas))
									self:SetWater(math.Clamp(self:GetWater() - 5, 0.0, self.MaxWater))
									self:SetChemicals(math.Clamp(self:GetChemicals() - 5, 0.0, self.MaxChemicals))
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

elseif(CLIENT)then

	function ENT:CustomInit()
		self.ZipZoop = JMod.MakeModel(self, "models/props_combine/combinetrain01a.mdl", "phoenix_storms/chrome", .05)
	end

	local ScreenOneMat = Material("models/jmod/machines/parts_machine/screen1_on")
	local ScreenTwoMat = Material("models/jmod/machines/parts_machine/screen2_on")
	local ScreenThreeMat = Material("models/jmod/machines/parts_machine/screen3_on")
	local ScreenFourMat = Material("models/jmod/machines/parts_machine/screen4_on")
	function ENT:DrawTranslucent()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		---
		local BasePos = SelfPos + Up * 60
		local Obscured = false--[[util.TraceLine({
			start = EyePos(),
			endpos = BasePos,
			filter = {LocalPlayer(), self},
			mask = MASK_OPAQUE
		}).Hit--]]

		local Closeness = LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw = Closeness < 36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(self:GetState()<0)then DetailDraw=false end
		---
		self:DrawModel()
		---
		if(DetailDraw)then
			if(self:GetElectricity() > 0)then
				local Opacity = math.random(50, 200)
				local ElecFrac, GasFrac, ChemFrac, WaterFrac = self:GetElectricity()/self.MaxElectricity, self:GetGas()/self.MaxGas, self:GetChemicals()/self.MaxChemicals, self:GetWater()/self.MaxWater

				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Forward, 90)
				cam.Start3D2D(BasePos + Right * 15.8 + Forward * 11.5 + Up * -13, DisplayAng, .033)
					draw.SimpleTextOutlined("POWER "..math.Round(ElecFrac*100).."%","JMod-Display",0,60,JMod.GoodBadColor(ElecFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("GAS "..math.Round(GasFrac*100).."%","JMod-Display",0,100,JMod.GoodBadColor(GasFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("CHEMICALS "..math.Round(ChemFrac*100).."%","JMod-Display",0,140,JMod.GoodBadColor(ChemFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("WATER "..math.Round(WaterFrac*100).."%","JMod-Display",0,180,JMod.GoodBadColor(WaterFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()

				local DisplayAng = SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Forward, 90)
				DisplayAng:RotateAroundAxis(Up, 180)
				cam.Start3D2D(BasePos + Right * -53.4 + Forward * 8 + Up * -30, DisplayAng, .1)
					draw.SimpleTextOutlined("POWER "..math.Round(ElecFrac*100).."%","JMod-Display",-550,10,JMod.GoodBadColor(ElecFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("GAS "..math.Round(GasFrac*100).."%","JMod-Display",-335,10,JMod.GoodBadColor(GasFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("CHEMICALS "..math.Round(ChemFrac*100).."%","JMod-Display",-80,10,JMod.GoodBadColor(ChemFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					draw.SimpleTextOutlined("WATER "..math.Round(WaterFrac*100).."%","JMod-Display",190,10,JMod.GoodBadColor(WaterFrac, true, Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()

				-- because Source 2007 is impossibly stupid with its use of $selfillum and color tinting, we have to manually draw the screens as quads
				DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Up, -90)
				DisplayAng:RotateAroundAxis(Right, 180)
				DisplayAng:RotateAroundAxis(Forward, -4.5)
				render.SetMaterial((math.random(1, 18000) == 1 and ScreenFourMat) or ScreenOneMat)
				render.DrawQuadEasy(BasePos + Forward * 26.2 + Right * 16 - Up * 17.5, DisplayAng:Forward(), 12.5, 7, Color(255, 255, 255, 255), DisplayAng.r)
				--
				DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Up, -90)
				DisplayAng:RotateAroundAxis(Right, 180)
				DisplayAng:RotateAroundAxis(Forward, -19)
				render.SetMaterial(ScreenTwoMat)
				render.DrawQuadEasy(BasePos - Forward * 13.4 + Right * 22.1 - Up * 31.2, DisplayAng:Forward(), 9.5, 4.5, Color(255, 255, 255, 255), DisplayAng.r)
				--
				DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(Up, -90)
				DisplayAng:RotateAroundAxis(Right, 180)
				DisplayAng:RotateAroundAxis(Forward, -36)
				render.SetMaterial(ScreenThreeMat)
				render.DrawQuadEasy(BasePos + Forward * 53.8 + Right * 25 - Up * 28, DisplayAng:Forward(), 11.2, 5.7, Color(170, 170, 170, 255), DisplayAng.r)
			end

			local DisplayAng=SelfAng:GetCopy()
			DisplayAng:RotateAroundAxis(Up, 0)
			DisplayAng:RotateAroundAxis(Right, 180)
			DisplayAng:RotateAroundAxis(Forward, -89)
			JMod.RenderModel(self.ZipZoop, BasePos - Forward * 15 - Right * 9 - Up * 21, DisplayAng)
		end
	end
	language.Add("ent_jack_gmod_ezfabricator","EZ Fabricator")
end
