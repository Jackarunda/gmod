JMod.NukeFlashEndTime = 0
JMod.NukeFlashPos = nil
JMod.NukeFlashRange = 0
JMod.NukeFlashIntensity = 1
JMod.NukeFlashSmokeEndTime = 0
JMod.Wind = JMod.Wind or Vector(0, 0, 0)

surface.CreateFont("JMod-Display", {
	font = "Arial",
	extended = false,
	size = 35,
	weight = 900,
	blursize = 0,
	scanlines = 4,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Display-L", {
	font = "Arial",
	extended = false,
	size = 60,
	weight = 900,
	blursize = 0,
	scanlines = 4,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-NumberLCD", {
	font = "ds-digital bold",
	extended = false,
	size = 35,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Display-S", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 900,
	blursize = 0,
	scanlines = 4,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Display-XS", {
	font = "Arial",
	extended = false,
	size = 15,
	weight = 900,
	blursize = 0,
	scanlines = 4,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Stencil", {
	font = "capture it",
	extended = false,
	size = 60,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Stencil-MS", {
	font = "capture it",
	extended = false,
	size = 40,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Stencil-S", {
	font = "capture it",
	extended = false,
	size = 20,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Stencil-XS", {
	font = "capture it",
	extended = false,
	size = 10,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-SharpieHandwriting", {
	font = "handwriting",
	extended = false,
	size = 40,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Debug", {
	font = "Arial",
	extended = false,
	size = 120,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("JMod-Debug-S", {
	font = "Arial",
	extended = false,
	size = 60,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local function CreateClientLag(amt)
	local W, H = ScrW(), ScrH()

	for i = 0, amt do
		draw.SimpleText("LAG", "DermaDefault", math.random(W * .4, W * .6), math.random(H * .8, H * .9), Color(255, 0, 0, 255 * math.Rand(0, 1) ^ 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local WindChange, NextThink = Vector(0, 0, 0), 0
local Count, Sum = 0, 0

hook.Add("Think", "JMOD_CLIENT_THINK", function()
	--[[
	local dlight=DynamicLight( LocalPlayer():EntIndex() )
	if ( dlight ) then
		dlight.pos=LocalPlayer():GetShootPos()
		dlight.r=255
		dlight.g=255
		dlight.b=255
		dlight.brightness=5
		dlight.Decay=1000
		dlight.Size=25600
		dlight.DieTime=CurTime()+1
	end
	--]]
	local Time = CurTime()
	local ply, DrawNVGlamp = LocalPlayer(), false

	if not ply:ShouldDrawLocalPlayer() then
		if ply:Alive() and JMod.PlyHasArmorEff(ply) then
			local ArmorEffects = ply.EZarmor.effects
			if ArmorEffects.nightVision or ArmorEffects.nightVisionWP then
				DrawNVGlamp = true

				if not IsValid(ply.EZNVGlamp) then
					ply.EZNVGlamp = ProjectedTexture()
					ply.EZNVGlamp:SetTexture("effects/flashlight001")
					ply.EZNVGlamp:SetBrightness(.025)
				else
					local Dir = ply:GetAimVector()
					local Ang = Dir:Angle()
					ply.EZNVGlamp:SetPos(EyePos() + Dir * 10)
					ply.EZNVGlamp:SetAngles(Ang)
					ply.EZNVGlamp:SetConstantAttenuation(.2)
					local FoV = ply:GetFOV()
					ply.EZNVGlamp:SetFOV(FoV)
					ply.EZNVGlamp:SetFarZ(150000 / FoV)
					ply.EZNVGlamp:Update()
				end
			end
		end
	end

	if not DrawNVGlamp then
		if IsValid(ply.EZNVGlamp) then
			ply.EZNVGlamp:Remove()
		end
	end

	if NextThink > Time then return end
	NextThink = Time + 5
	JMod.Wind = GetGlobal2Vector("JMod_Wind", JMod.Wind)
end)

--[[
	Sum=Sum+(1/FrameTime())
	Count=Count+1
	if(Count>=100)then
		LocalPlayer():ChatPrint(tostring(math.Round(Sum/100)))
		Count=0
		Sum=0
	end
	--]]
local BeamMat = CreateMaterial("xeno/beamgauss", "UnlitGeneric", {
	["$basetexture"] = "sprites/spotlight",
	["$additive"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
})

local GlowSprite, KnownSLAMs, NextSlamScan = Material("sprites/mat_jack_basicglow"), {}, 0
local ThermalGlowMat = Material("models/debug/debugwhite")

hook.Add("PostDrawTranslucentRenderables", "JMOD_POSTDRAWTRANSLUCENTRENDERABLES", function()
	local Time = CurTime()
	local ply = LocalPlayer()

	if Time > NextSlamScan then
		NextSlamScan = Time + .5
		KnownSLAMs = ents.FindByClass("ent_jack_gmod_ezslam")
	end

	for k, ent in pairs(KnownSLAMs) do
		if IsValid(ent) then
			local pos = ent:GetAttachment(1).Pos

			if pos then
				local trace = util.QuickTrace(pos, ent:GetUp() * 1000, ent)
				local State, Vary = ent:GetState(), math.sin(CurTime() * 50) / 2 + .5
				local Forward = -ent:GetUp()
				pos = pos - Forward * .5

				if State == JMod.EZ_STATE_ARMING then
					render.SetMaterial(GlowSprite)
					render.DrawSprite(pos, 15, 15, Color(255, 0, 0, 100 * Vary))
					render.DrawSprite(pos, 7, 7, Color(255, 255, 255, 100 * Vary))
					render.DrawQuadEasy(pos, Forward, 15, 15, Color(255, 0, 0, 100 * Vary), 0)
					render.DrawQuadEasy(pos, Forward, 7, 7, Color(255, 255, 255, 100 * Vary), 0)
				elseif State == JMod.EZ_STATE_ARMED then
					render.SetMaterial(BeamMat)
					render.DrawBeam(pos, trace.HitPos, 0.2, 0, 255, Color(255, 0, 0, 30))

					if trace.Hit then
						render.SetMaterial(GlowSprite)
						render.DrawSprite(trace.HitPos, 8, 8, Color(255, 0, 0, 100))
						render.DrawSprite(trace.HitPos, 4, 4, Color(255, 255, 255, 100))
						render.DrawQuadEasy(trace.HitPos, trace.HitNormal, 15, 15, Color(255, 0, 0, 100), 0)
						render.DrawQuadEasy(trace.HitPos, trace.HitNormal, 7, 7, Color(255, 255, 255, 100), 0)
					end
				end
			end
		end
	end
end)

local function IsOnWhiteList(ent)
	local IDwhitelist = JMod.Config.Armor.ScoutIDwhitelist or {}
	local EntClass = ent:GetClass()

	for _, class in pairs(IDwhitelist) do
		if EntClass == class then

			return true
		elseif string.EndsWith(class, "*") and string.find(EntClass, string.TrimRight(class, "*")) then

			return true
		end
	end

	return false
end

JMod.EZscannerDangers = {}
local NextDangerScan, KnownEnts = 0, {}
local ScanDist = 1500

hook.Add("PostDrawTranslucentRenderables", "JMOD_EZDANGERSCANNING", function(bDepth, bSkybox)
	if bSkybox then return end
	if bDepth then return end

	local Time = CurTime()
	local ply = LocalPlayer()

	if not JMod.PlyHasArmorEff(ply, "tacticalVision") then return end

	local SightPos = ply:GetShootPos()

	if Time > NextDangerScan then
		NextDangerScan = Time + .5
		KnownEnts = ents.FindInSphere(SightPos, ScanDist)
	end

	table.Empty(JMod.EZscannerDangers)
	
	local TraceSetup = {
		start = SightPos,
		endpos = SightPos + ply:GetAimVector() * ScanDist,
		mask = MASK_OPAQUE_AND_NPCS,
		filter = {ply}
	}

	if ply:InVehicle() then
		table.insert(TraceSetup.filter, ply:GetVehicle())
		if IsValid(ply:GetVehicle():GetParent()) then
			table.insert(TraceSetup.filter, ply:GetVehicle():GetParent())
		end
	end
	local SightTrace = util.TraceLine(TraceSetup)

	for _, ent in ipairs(KnownEnts) do
		if IsValid(ent) then
			if ent.EZscannerDanger or IsOnWhiteList(ent) then
				local TestPos = ent:LocalToWorld(ent:OBBCenter())
				TraceSetup.endpos = TestPos
				table.insert(TraceSetup.filter, ent)
				local SightTrace = util.TraceLine(TraceSetup)
				if not SightTrace.Hit then
					local DangerInfo = TestPos:ToScreen()
					DangerInfo.text = ent.PrintName or (ent.GetPrintName and language.GetPhrase(ent:GetPrintName())) or "???"
					if ent.GetState and ent:GetState() == JMod.EZ_STATE_ARMED then
						DangerInfo.danger = true
					end
					if DangerInfo.visible then
						table.insert(JMod.EZscannerDangers, DangerInfo)
					end
				end
			elseif ent ~= ply and ent.LookupAttachment and ent:GetAttachment(ent:LookupAttachment("eyes")) then
				local AngPos = ent:GetAttachment(ent:LookupAttachment("eyes")) 
				TraceSetup.endpos = AngPos.Pos
				table.insert(TraceSetup.filter, ent)
				local SightTrace = util.TraceLine(TraceSetup)
				if not SightTrace.Hit then
					local DangerInfo = AngPos.Pos:ToScreen()
					DangerInfo.text = "Head"
					if DangerInfo.visible then
						table.insert(JMod.EZscannerDangers, DangerInfo)
					end
				end
			end
		end
	end 
end)

net.Receive("JMod_LuaConfigSync", function(dataLength)
	local Payload = net.ReadData(dataLength)
	Payload = util.JSONToTable(util.Decompress(Payload))
	JMod.LuaConfig = JMod.LuaConfig or {}
	JMod.LuaConfig.ArmorOffsets = Payload.ArmorOffsets
	JMod.Config = JMod.Config or {}
	JMod.Config.General = {AltFunctionKey = Payload.AltFunctionKey}
	JMod.Config.Machines = {Blackhole = Payload.Blackhole}
	JMod.Config.Weapons = {SwayMult = Payload.WeaponSwayMult}
	JMod.Config.QoL = table.FullCopy(Payload.QoL)
	JMod.Config.ResourceEconomy = {MaxResourceMult = Payload.MaxResourceMult}
	JMod.Config.Explosives = {Flashbang = Payload.Flashbang}
	JMod.Config.Armor = {ScoutIDwhitelist = table.FullCopy(Payload.ScoutIDwhitelist)}

	if tobool(net.ReadBit()) then
		for k, v in player.Iterator() do
			JMod.CopyArmorTableToPlayer(v)
		end
	end
end)

--[[
hook.Add("CalcView", "HD2_TEST", function(ply, pos, ang, fov)
	local view = {
		origin = pos + ang:Forward() * 100 - ang:Up() * 20 + ang:Right() * 15,
		angles = ang,
		fov = fov,
		drawviewer = true
	}
	return view
end)
--]]

function JMod.MakeModel(self, mdl, mat, scale, col)
	local Mdl = ClientsideModel(mdl)

	if mat then
		if isnumber(mat) then
			Mdl:SetSkin(mat)
		else
			Mdl:SetMaterial(mat)
		end
	end

	if scale then
		Mdl:SetModelScale(scale, 0)
	end

	if col then
		Mdl:SetColor(col)
	end

	Mdl:SetPos(self:GetPos())
	Mdl:SetParent(self)
	Mdl:SetNoDraw(true)
	-- store this on a table for cleanup later
	self.CSmodels = self.CSmodels or {}
	table.insert(self.CSmodels, Mdl)

	return Mdl
end

function JMod.RenderModel(mdl, pos, ang, scale, color, mat, fullbright, translucency)
	if not IsValid(mdl) then return end
	--mdl:SetupBones()

	if pos then
		mdl:SetRenderOrigin(pos)
	end

	if ang then
		mdl:SetRenderAngles(ang)
	end

	if scale then
		local Matricks = Matrix()
		Matricks:Scale(scale)
		mdl:EnableMatrix("RenderMultiply", Matricks)
	end

	local R, G, B = render.GetColorModulation()
	local RenderCol = color or Vector(1, 1, 1)
	render.SetColorModulation(RenderCol.x, RenderCol.y, RenderCol.z)

	if mat and not(tonumber(mat)) then
		render.ModelMaterialOverride(mat)
	end

	if fullbright then
		render.SuppressEngineLighting(true)
	end

	if translucenty then
		render.SetBlend(translucency)
	end

	--mdl:SetLOD(8)
	mdl:DrawModel()
	render.SetColorModulation(R, G, B)
	render.ModelMaterialOverride(nil)
	render.SuppressEngineLighting(false)
	render.SetBlend(1)
end

function JMod.SafeRemoveCSModel(ent, mdl, tab)
	if tab and istable(tab) then
		local ModelsToRemove = table.FullCopy(tab)
		timer.Simple(0, function()
			if IsValid(ent) then return end
			for k, v in pairs(ModelsToRemove)do
				if(IsValid(v))then
					v:Remove()
				end
			end
		end)
	end
	if mdl and IsValid(mdl) then
		local ModelToRemove = mdl
		timer.Simple(0, function()
			if IsValid(ent) then return end
			if(IsValid(v))then
				mdl:Remove()
			end
		end)
	end
end

local FRavg, FRcount = 0, 0

function JMod.MeasureFramerate()
	local FR = 1 / FrameTime()
	FRavg = FRavg + FR
	FRcount = FRcount + 1

	if FRcount >= 100 then
		jprint(math.Round(FRavg / 100))
		FRavg = 0
		FRcount = 0
	end
end

local WHOTents, NextWHOTcheck = {}, 0

local function IsWHOT(ent)
	if not(IsValid(ent)) then return end
	local Time = CurTime()
	if ent:IsWorld() then return false end
	if ent:IsPlayer() or ent:IsOnFire() then return true end -- null entity

	if ent:IsNPC() then
		if ent.Health and (ent:Health() > 0) then return true end
	elseif ent:IsRagdoll() then
		if not ent.EZWHOTcoldTime then
			ent.EZWHOTcoldTime = Time + 30
		end
	elseif ent:IsVehicle() then
		-- HL2 vehicles
		if IsValid(ent:GetDriver()) and ent:GetVelocity():Length() >= 200 then
			ent.EZWHOTcoldTime = Time + math.Clamp(ent:GetVelocity():Length() / 20, 10, 40)
		end

		if LocalPlayer() == ent:GetDriver() then return false end
	elseif simfphys and simfphys.IsCar then -- have to check for IsCar because some addons create the 'simfphys' object even if simfphys isn't enabled/installed, weeeee
		-- simfphys vehicles
		if not simfphys.IsCar(ent) then return end
		if IsValid(ent:GetDriver()) and ent:GetVelocity():Length() >= 200 then
			ent.EZWHOTcoldTime = Time + math.Clamp(ent:GetVelocity():Length() / 20, 10, 40)
		end

		if LocalPlayer() == ent:GetDriver() then return false end
	elseif scripted_ents.Get(ent:GetClass()) and scripted_ents.IsBasedOn(ent:GetClass(), "lunasflightschool_basescript") then
		-- LFS planes
		-- Helicopter rotors will look ugly but eh
		if ent:GetEngineActive() then
			ent.EZWHOTcoldTime = Time + 30
		end

		-- Don't highlight the plane the player is in. Otherwise their view will be pure white
		if LocalPlayer():lfsGetPlane() == ent then return false end
	elseif scripted_ents.Get(ent:GetClass()) and scripted_ents.IsBasedOn(ent:GetClass(), "gred_emp_base") then
		-- Gredwich Emplacements
		if ent:GetIsReloading() or ent.NextShot > Time then
			ent.EZWHOTcoldTime = Time + 30
		end
	elseif scripted_ents.Get(ent:GetClass()) and scripted_ents.IsBasedOn(ent:GetClass(), "dronesrewrite_base") then
		-- Drones Rewrite
		if ent:IsDroneEnabled() then
			ent.EZWHOTcoldTime = Time + 30
		end
	end

	return (ent.EZWHOTcoldTime or 0) > Time
end

local thermalmodify = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = .2,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hook.Add("PostDrawOpaqueRenderables", "JMOD_POSTOPAQUERENDERABLES", function()
	local ply, Time = LocalPlayer(), CurTime()

	if ply:Alive() and JMod.PlyHasArmorEff(ply, "thermalVision") and not ply:ShouldDrawLocalPlayer() then
		DrawColorModify(thermalmodify)

		if NextWHOTcheck < Time then
			NextWHOTcheck = Time + .5
			WHOTents = {}

			for k, v in ents.Iterator() do
				if IsWHOT(v) then
					table.insert(WHOTents, v)
				end
			end
		end

		for key, targ in pairs(WHOTents) do
			if IsValid(targ) then
				local Br = .9

				if targ.EZWHOTcoldTime then
					Br = .75 * (targ.EZWHOTcoldTime - Time) / 30
				end

				if Br > .1 then
					render.ModelMaterialOverride(ThermalGlowMat)
					render.SuppressEngineLighting(true)
					render.SetColorModulation(Br, Br, Br)

					if targ:GetRenderMode() == RENDERMODE_NORMAL then
						targ:DrawModel()
					end

					render.SetColorModulation(1, 1, 1)
					render.SuppressEngineLighting(false)
					render.ModelMaterialOverride(nil)
				end
			end
		end
	end
end)

local Translucent = Color(255, 255, 255, 100)
hook.Add("PostDrawTranslucentRenderables", "JMOD_PLAYEREFFECTS", function(bDepth, bSkybox)
	local ply, Time = LocalPlayer(), CurTime()
	
	if ply:Alive() then
		if JMod.PlyHasArmorEff(ply, "thermalVision") and not ply:ShouldDrawLocalPlayer() then
			for key, targ in pairs(WHOTents) do
				if IsValid(targ) then
					local Br = .9

					if targ.EZWHOTcoldTime then
						Br = .75 * (targ.EZWHOTcoldTime - Time) / 30
					end

					if Br > .1 then
						render.ModelMaterialOverride(ThermalGlowMat)
						render.SuppressEngineLighting(true)
						render.SetColorModulation(Br, Br, Br)

						if targ:GetRenderMode() == RENDERMODE_TRANSALPHA then
							targ:DrawModel()
						end

						render.SetColorModulation(1, 1, 1)
						render.SuppressEngineLighting(false)
						render.ModelMaterialOverride(nil)
					end
				end
			end
		end

		if bSkybox then return end -- avoid drawing in the skybox
		local ToolBox = ply:GetActiveWeapon()

		if not IsValid(ToolBox) then return end
		if ToolBox:GetClass() ~= "wep_jack_gmod_eztoolbox" then return end
		
		local ToolboxBuild = ToolBox:GetSelectedBuild()
		local PreviewData = ToolBox.EZpreview
		if PreviewData then
		 	if ToolboxBuild == "EZ Nail" then
		 		local Pos, Vec = ply:GetShootPos(), ply:GetAimVector()

		 		local Tr1 = util.QuickTrace(Pos, Vec * 80, {ply})
		 		local Tr2 = nil
		 		if Tr1.Hit then
		 			local Ent1 = Tr1.Entity

		 			if Tr1.HitSky or Ent1:IsWorld() or Ent1:IsPlayer() or Ent1:IsNPC() then return end

		 			Tr2 = util.QuickTrace(Pos, Vec * 120, {ply, Ent1})

		 			if Tr2.Hit then
		 				local Ent2 = Tr2.Entity
		 				if (Ent1 == Ent2) or Tr2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return end
		 				local Dist = Tr1.HitPos:Distance(Tr2.HitPos)
		 				if Dist > 30 then return end
		 			end
		 		end
		 		-- would've liked to use the existing funcs to find nail location here
		 		-- but they're server-side only
		 		-- and also use ent:GetPhysicsObject() which will return nil 99% of the time on client

		 		if not Tr1.Hit or not Tr2.Hit or not Vec then return end

		 		render.DrawWireframeBox(Tr1.HitPos, Vec:Angle(), Vector(15,.5,.5), Vector(-15,-.5,-.5), color_white, false)

		 	elseif ToolboxBuild == "EZ Bolt" then
		 		local Pos, Vec = ply:GetShootPos(), ply:GetAimVector()

		 		local Tr1 = util.QuickTrace(Pos, Vec * 80, {ply})

		 		if Tr1.Hit then
		 			local Ent1 = Tr1.Entity
		 			if Tr1.HitSky or Ent1:IsWorld() or Ent1:IsPlayer() or Ent1:IsNPC() then return end

		 			local Tr2 = util.QuickTrace(Tr1.HitPos, Tr1.HitNormal * -40, {ply, Ent1})

		 			if Tr2.Hit then
	 					local Ent2 = Tr2.Entity
						if (Ent1 == Ent2) or Tr2.HitSky or Ent2:IsPlayer() or Ent2:IsNPC() then return end
		 				if Ent2:IsWorld() then return end
		 				local Dist = Tr1.HitPos:Distance(Tr2.HitPos)
		 				if Dist > 30 then return end

		 			end

		 			if not Tr1.Hit or not Tr2.Hit or not Vec then return end

		 			local Dir = (Tr1.HitPos - Tr2.HitPos):GetNormalized()

		 			render.DrawWireframeBox(Tr1.HitPos - Dir * 20, Dir:Angle(), Vector(21.5,.5,.5), Vector(-0,-.5,-.5), color_white, true)
		 		end
			elseif PreviewData.Box then
				if ToolboxBuild ~= "" then
				local Ent, Pos, Norm = NULL, nil, nil, nil
				if ToolBox.DetermineBuildPos then
					Ent, Pos, Norm = ToolBox:DetermineBuildPos()
				else
					local Filter = {ply}
					for k, v in pairs(ents.FindByClass("npc_bullseye")) do
						table.insert(Filter, v)
					end
					local Tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 200 * math.Clamp((ToolBox.CurrentBuildSize or 1), .5, 100), Filter)
					Ent, Pos, Norm = Tr.Entity, Tr.HitPos, Tr.HitNormal
					-- this trace code ^ is stolen from the toolbox, had to filter out ply to get a correct trace
				end
																																													--HSVToColor( CurTime() * 50 % 360, 1, 1 ) :troll:
				local DisplayAng = (PreviewData.SpawnAngles or Angle(0, 0, 0)) + Angle(0, ply:EyeAngles().y, 0)
				local FinalPos = Pos
					render.DrawWireframeBox(FinalPos, DisplayAng, PreviewData.Box.mins, PreviewData.Box.maxs, Translucent, true)
				end
			end
		end
	end
end)

-- Test for frag patterens
--[[local Spread = .5
local Fragments = 300
hook.Add( "PostDrawTranslucentRenderables", "JMOD_FRAGPATTERNS", function(bDepth, bSkybox)
	-- If we are drawing in the skybox, bail
	if (bSkybox) then return end
	if true then return end

	local EyeTrace = LocalPlayer():GetEyeTrace()
	local Pos, Norm = EyeTrace.HitPos, EyeTrace.HitNormal
	local DirAng = Norm:Angle()
	--DirAng:RotateAroundAxis(DirAng:Forward(), math.random(-180, 180))
	local FragAng = DirAng:GetCopy()

	local MaxAngle = 180
	local AngleFraction = MaxAngle / Fragments

	for i = 1, Fragments do
		-- Change the angle for the next time around
		FragAng:RotateAroundAxis(FragAng:Up(), AngleFraction * Spread)
		FragAng:RotateAroundAxis(DirAng:Forward(), i)

		-- Draw lines representing the direction the frags are going
		local Dir = FragAng:Forward()
		local End = Pos + Dir * 100
		render.DrawLine(Pos, End, Color(255, 0, 0, 255), true)
	end
end)--]]

local SomeKindOfFog = Material("white_square")

hook.Add("PostDrawSkyBox", "JMOD_POSTSKYBOX", function()
	local Time = CurTime()

	if JMod.NukeFlashSmokeEndTime > Time then
		local Frac = ((JMod.NukeFlashSmokeEndTime - Time) / 30) ^ .15
		local W, H = ScrW(), ScrH()
		cam.Start3D2D(EyePos() + Vector(0, 0, 100), Angle(0, 0, 0), 2)
		surface.SetMaterial(SomeKindOfFog)
		surface.SetDrawColor(100, 100, 100, 230 * Frac)
		surface.DrawRect(-W * 2, -H * 2, W * 4, H * 4)
		cam.End3D2D()
	end
end)

hook.Add("SetupWorldFog", "JMOD_WORLDFOG", function()
	local Time = CurTime()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and JMod.PlyHasArmorEff(ply, "thermalVision") and not ply:ShouldDrawLocalPlayer() then
		render.FogMode(0)

		return true
	end

	if JMod.NukeFlashSmokeEndTime > Time then
		local Frac = ((JMod.NukeFlashSmokeEndTime - Time) / 30) ^ .15
		render.FogMode(1)
		render.FogColor(100, 100, 100)
		render.FogStart(0)
		render.FogEnd(1000)
		render.FogMaxDensity(Frac)

		return true
	end
end)

hook.Add("SetupSkyboxFog", "JMOD_SKYFOG", function(scale)
	local Time = CurTime()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and JMod.PlyHasArmorEff(ply, "thermalVision") and not ply:ShouldDrawLocalPlayer() then
		render.FogMode(0)

		return true
	end

	if JMod.NukeFlashSmokeEndTime > Time then
		local Frac = ((JMod.NukeFlashSmokeEndTime - Time) / 30) ^ .15
		render.FogMode(1)
		render.FogColor(100, 100, 100)
		render.FogStart(1 * scale)
		render.FogEnd(1500 * scale)
		render.FogMaxDensity(Frac)

		return true
	end
end)

hook.Add("ShouldSit", "JMOD_SITANYWHERE_COMPATIBILITY", function(ply)
	-- let it be known for the record that the SitAnywhere addon author is an idiot
	local Tr = ply:GetEyeTrace()
	if Tr.Entity and Tr.Entity.NoSitAllowed then return false end

	for k, v in pairs(ents.FindInSphere(Tr.HitPos, 20)) do
		if v.NoSitAllowed then return false end
	end
end)

local function CommNoise()
	surface.PlaySound("snds_jack_gmod/radio_static" .. math.random(1, 3) .. ".ogg")
end

hook.Add("PlayerStartVoice", "JMOD_PLAYERSTARTVOICE", function(ply)
	if not ply:Alive() then return end
	if not LocalPlayer():Alive() then return end

	if JMod.PlyHasArmorEff(ply, "teamComms") and JMod.PlayersCanComm(LocalPlayer(), ply) then
		surface.PlaySound("snds_jack_gmod/radio_start.ogg")
	end
end)

hook.Add("OnPlayerChat", "JMOD_ONPLAYERCHAT", function(ply, text, isTeam, isDead)
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
	if not LocalPlayer():Alive() then return end

	if JMod.PlyHasArmorEff(ply, "teamComms") and JMod.PlayersCanComm(LocalPlayer(), ply) then
		CommNoise()

		if not isTeam and not isDead then
			local tab = {}
			table.insert(tab, Color(30, 40, 200))
			table.insert(tab, "(HEADSET) ")
			table.insert(tab, ply)
			table.insert(tab, Color(255, 255, 255))
			table.insert(tab, ": " .. text)
			chat.AddText(unpack(tab))

			return true
		end
	end
end)

hook.Add("PlayerEndVoice", "JMOD_PLAYERENDVOICE", function(ply)
	if not ply:Alive() then return end
	if not LocalPlayer():Alive() then return end

	if JMod.PlyHasArmorEff(ply, "teamComms") and JMod.PlayersCanComm(LocalPlayer(), ply) then
		CommNoise()
	end
end)

hook.Add("CalcVehicleView", "JMOD_VEHICLEVIEWCORRECTION", function(veh, ply, view) 
	local PodParent = veh:GetParent()
	if IsValid(PodParent) and ((PodParent:GetClass() == "ent_jack_sleepingbag") or (PodParent:GetClass() == "ent_jack_gmod_ezfieldhospital")) then
		
		local ViewOrigin = veh:GetPos() + veh:GetUp() * 64
		--local LerpedViewAng = LerpAngle(FrameTime() * 100, view.angles, veh:GetAngles())
		--local ViewAng = LerpedViewAng--veh:GetAttachment(veh:LookupAttachment("vehicle_driver_eyes")).Ang
		view.origin = ViewOrigin
		--view.angles = ViewAng
		
		return view
	end
end)

--[[
hook.Add("ScalePlayerDamage","JMOD_SCALEPLAYERDAMGE_CLIENT",function(ply, hitgroup, dmg)
	return true
end)
--]]
concommand.Add("jacky_supershadows", function(ply, cmd, args)
	if (tonumber(args[1]) == 1) then
		RunConsoleCommand("r_projectedtexture_filter", .1)
		RunConsoleCommand("r_flashlightdepthres", 16384)
		RunConsoleCommand("mat_depthbias_shadowmap", .0000005)
		RunConsoleCommand("mat_slopescaledepthbias_shadowmap", 2)
		print("super shadows enabled, have fun with the lag")
	elseif (tonumber(args[1]) == 0) then
		RunConsoleCommand("r_projectedtexture_filter", 1)
		RunConsoleCommand("r_flashlightdepthres", 1024)
		RunConsoleCommand("mat_depthbias_shadowmap", .0001)
		RunConsoleCommand("mat_slopescaledepthbias_shadowmap", 2)
		print("default shadow settings restored")
	end
end, nil, "Enables higher detailed shadows; great for photography.")

concommand.Add("jmod_debug_showgasparticles", function(ply, cmd, args)
	if not IsValid(ply) and GetConVar("sv_cheats"):GetBool() then return end
	ply.EZshowGasParticles = not (ply.EZshowGasParticles or false)
	print("gas particle display: " .. tostring(ply.EZshowGasParticles))
end, nil, JMod.Lang("command jmod_debug_showgasparticles"), nil)

net.Receive("JMod_NuclearBlast", function()
	local pos, renj, intens = net.ReadVector(), net.ReadFloat(), net.ReadFloat()
	JMod.NukeFlashEndTime = CurTime() + 8
	JMod.NukeFlashPos = pos
	JMod.NukeFlashRange = renj
	JMod.NukeFlashIntensity = intens

	if intens > 1 then
		JMod.NukeFlashSmokeEndTime = CurTime() + 30
	end

	local maxRange = renj
	local maxImmolateRange = renj * .3

	for k, ent in pairs(ents.FindInSphere(pos, maxRange)) do
		if IsValid(ent) and ent.GetClass then
			local Class = ent:GetClass()

			if (Class == "class C_ClientRagdoll") or (Class == "class C_HL2MPRagdoll") then
				local Vec = ent:GetPos() - pos
				local Dir = Vec:GetNormalized()

				for i = 1, math.min(ent:GetPhysicsObjectCount(), 50) do
					local Phys = ent:GetPhysicsObjectNum(i - 1)

					if Phys then
						Phys:ApplyForceCenter(Dir * 1e10)
					end

					if Vec:Length() < maxImmolateRange then
						local HeadID = ent:LookupBone("ValveBiped.Bip01_Head1")

						-- if it has a Head ID then it's probably a humanoid ragdoll
						if HeadID then
							ent:SetModel("models/Humans/Charple0" .. math.random(1, 4) .. ".mdl")
						else
							ent:SetColor(Color(20, 20, 20))
						end
					end
				end
			end
		end
	end
end)

net.Receive("JMod_VisionBlur", function()
	local ply = LocalPlayer()
	ply.EZvisionBlur = math.Clamp((ply.EZvisionBlur or 0) + net.ReadFloat(), 0, 75)
	ply.EZvisionBlurFadeAmt = net.ReadFloat()
	ply.JMod_RequiredWakeAmount = (tobool(net.ReadBit()) and 100) or 0
end)

net.Receive("JMod_Bleeding", function()
	LocalPlayer().EZbleeding = net.ReadInt(8)
end)

net.Receive("JMod_SFX", function()
	surface.PlaySound(net.ReadString())
end)

net.Receive("JMod_VisualGunRecoil", function()
	local Ent = net.ReadEntity()
	local Amt = net.ReadFloat()

	if IsValid(Ent) and Ent.AddVisualRecoil then
		Ent:AddVisualRecoil(Amt)
	end
end)

net.Receive("JMod_Ravebreak", function()
	-- fucking HELL YES HERE WE GO
	surface.PlaySound("snds_jack_gmod/ravebreak.ogg")
	LocalPlayer().JMod_RavebreakStartTime = CurTime() + 2.325
	LocalPlayer().JMod_RavebreakEndTime = CurTime() + 25.5
end)
-- note that the song's beat is about .35 seconds

-- Liquid Effects
local WaterSprite, FireSprite = Material("effects/jmod/splash2"), Material("effects/fire_cloud1")
local RainbowSprite, RainbowCol = Material("effects/mat_jack_gmod_rainbow"), Color(255, 255, 255, 20)

JMod.ParticleSpecs = {
	[1] = { -- jellied fuel
		launchSize = 2,
		lifeTime = 1.5,
		finalSize = 200,
		airResist = .15,
		mat = Material("effects/mat_jack_gmod_liquidstream"),
		colorFunc = function(self)
			local AmbiLight = (render.GetLightColor(self.pos) or Vector(1, 1, 1))
			AmbiLight.x = math.Clamp(AmbiLight.x + .2, 0, 1)
			AmbiLight.y = math.Clamp(AmbiLight.y + .2, 0, 1)
			AmbiLight.z = math.Clamp(AmbiLight.z + .2, 0, 1)
			return Color(200 * AmbiLight.x, 220 * AmbiLight.y, 255 * AmbiLight.z, 100 * (1 - self.lifeProgress))
		end,
		particleDrawFunc = function(self, size, col)
			render.SetMaterial(WaterSprite)
			render.DrawSprite(self.pos, size * 2, size * 2, col)
		end,
		impactFunc = function(self, normal)
			if math.random(1, 2) == 1 then
				local Splach = EffectData()
				Splach:SetOrigin(self.pos - normal * .5)
				Splach:SetNormal(normal)
				Splach:SetScale(math.Rand(1, 3))
				util.Effect("eff_jack_gmod_tinysplash", Splach)
			end
			self.dieTime = self.dieTime - .2
		end
	},
	[2] = { -- flamethrower
		launchSize = 2,
		lifeTime = 1,
		finalSize = 250,
		airResist = .1,
		mat = Material("effects/mat_jack_gmod_liquidstream"),
		colorFunc = function(self)
			--[[local AmbiLight = (render.GetLightColor(self.pos) or Vector(1, 1, 1))
			AmbiLight.x = math.Clamp(AmbiLight.x + .2, 0, 1)
			AmbiLight.y = math.Clamp(AmbiLight.y + .2, 0, 1)
			AmbiLight.z = math.Clamp(AmbiLight.z + .2, 0, 1)--]]
			local InverseLife = (1 - self.lifeProgress)
			local R = 255
			local G = Lerp(self.lifeProgress, 255, 230)
			local B = Lerp(self.lifeProgress, 255, 50)
			return Color(R, G, B, 200 * InverseLife)
		end,
		particleDrawFunc = function(self, size, col)
			render.SetMaterial(FireSprite)
			render.DrawSprite(self.pos + Vector(0, 0, self.lifeProgress * size * .5), size * 1.5, size * 1.5, Color(255, 255, 255, 100 * (1 - self.lifeProgress)))
		end,
		impactFunc = function(self, normal)
			self.dieTime = self.dieTime - .1
		end,
		gravity = 200
	},
	[3] = { -- SprinklerWater
		launchSize = 1,
		lifeTime = 1.5,
		finalSize = 200,
		airResist = 1,
		mat = Material("effects/mat_jack_gmod_liquidstream"),
		colorFunc = function(self)
			local AmbiLight = (render.GetLightColor(self.pos) or Vector(1, 1, 1))
			AmbiLight.x = math.Clamp(AmbiLight.x + .2, 0, 1)
			AmbiLight.y = math.Clamp(AmbiLight.y + .2, 0, 1)
			AmbiLight.z = math.Clamp(AmbiLight.z + .2, 0, 1)
			return Color(200 * AmbiLight.x, 220 * AmbiLight.y, 255 * AmbiLight.z, 100 * (1 - self.lifeProgress))
		end,
		particleDrawFunc = function(self, size, col)
			render.SetMaterial(WaterSprite)
			render.DrawSprite(self.pos + Vector(0, 0, -size * .5), size * 2, size * 2, col)
		end,
		impactFunc = function(self, normal)
			local Splach = EffectData()
			Splach:SetOrigin(self.pos - normal * .5)
			Splach:SetNormal(normal)
			Splach:SetScale(math.Rand(1, 3))
			util.Effect("eff_jack_gmod_tinysplash", Splach)
			self.dieTime = self.dieTime - .2
		end,
		stencilTest = true
	},
}

JMod.LiquidParticles = {}

net.Receive("JMod_LiquidParticle", function()
	local Pos = net.ReadVector()
	local Dir = net.ReadVector()
	local Amt = net.ReadInt(8)
	local Group = net.ReadInt(8)
	local Type = net.ReadInt(8)
	JMod.LiquidSpray(Pos, Dir, Amt, Group, Type)
end)

-- Liquid Think
hook.Add("Think", "JMod_LiquidStreams", function()
	local FT, Time = FrameTime(), CurTime()
	for groupID, group in pairs(JMod.LiquidParticles) do
		for k, particle in pairs(group) do
			local Specs = JMod.ParticleSpecs[particle.typ]
			local Travel = particle.vel * FT
			local Tr = util.TraceLine({
				start = particle.pos,
				endpos = particle.pos + Travel,
				mask = MASK_SHOT
			})
			if (Tr.Hit) then
				particle.pos = Tr.HitPos + Tr.HitNormal
				-- deflect when hitting a surface
				particle.vel = Tr.HitNormal * 70 + VectorRand() * 70
				particle.dieTime = particle.dieTime - FT * 30 -- disperse quickly
				if (Specs.impactFunc) then
					Specs.impactFunc(particle, Tr.HitNormal)
				end
			else
				particle.pos = particle.pos + Travel
			end
			particle.vel = particle.vel - Vector(0, 0, (Specs.gravity or 600) * FT)
			local AirLoss = FT * Specs.airResist
			particle.vel = particle.vel * (1 - AirLoss)
			vel = particle.vel + JMod.Wind * FT * 200
			if (particle.dieTime < Time) then
				table.remove(JMod.LiquidParticles[groupID], k)
			else
				local TimeLeft = particle.dieTime - Time
				particle.lifeProgress = 1 - (TimeLeft / Specs.lifeTime)
			end
		end
	end
end)

-- Liquid Render
local GlowSprite = Material("sprites/mat_jack_basicglow")
hook.Add("PostDrawTranslucentRenderables", "JMod_DrawLiquidStreams", function( bDrawingDepth, bDrawingSkybox, isDraw3DSkybox )
	if bDrawingSkybox then return end
	local SunInfo = util.GetSunInfo()
	local ViewPos = EyePos()
	local ViewDir = EyeAngles()
	--local ScreenWidth, ScreenHeight = ScrW(), ScrH()
	--local FoV = 1 / (LocalPlayer():GetFOV() / 90)
	for groupID, group in pairs(JMod.LiquidParticles) do
		local NumberOfParticles = #group
		local LastPos = nil
		for k, particle in ipairs(group) do
			local Specs = JMod.ParticleSpecs[particle.typ]
			local Size = Specs.launchSize + (Specs.finalSize - Specs.launchSize) * particle.lifeProgress
			local Col = Specs.colorFunc(particle, Size)
			if (Specs.particleDrawFunc) then
				Specs.particleDrawFunc(particle, Size, Col)
			end
			if (LastPos) then
				-- God's promise to not flood the earth with water
				if Specs.stencilTest and SunInfo then
					-- STENCIL TEST
					render.SetStencilEnable( true )
					render.ClearStencil()
					--
					render.SetStencilTestMask( 255 )
					render.SetStencilWriteMask( 255 )
					render.SetStencilReferenceValue( 1 )
					--
					render.SetStencilFailOperation( STENCILOPERATION_KEEP )
					render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
					render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
					--
					render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
					-- RENDER NORMAL STUFF HERE
				end
				render.SetMaterial(Specs.mat)
				render.DrawBeam(LastPos, particle.pos, Size, 1, 0, Col)
				if Specs.stencilTest and SunInfo then
					-- RAINBOW WILL BE RENDERED BEHIND
					render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
					render.SetStencilPassOperation( STENCILOPERATION_KEEP )

					--START REAL RAINBOW DRAW
					render.SetMaterial(RainbowSprite)
					render.DrawSprite(ViewPos - SunInfo.direction * 250 + ViewDir:Up() * 200, 200, 100, RainbowCol)
					--END
					render.SetStencilEnable( false )
					-- STENCIL TEST
				end
			end
			LastPos = particle.pos
		end
	end
end)

--[[
ValveBiped.Bip01_Pelvis
ValveBiped.Bip01_Spine
ValveBiped.Bip01_Spine1
ValveBiped.Bip01_Spine2
ValveBiped.Bip01_Spine4
ValveBiped.Bip01_Neck1
ValveBiped.Bip01_Head1
ValveBiped.forward
ValveBiped.Bip01_R_Clavicle
ValveBiped.Bip01_R_UpperArm
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Hand
ValveBiped.Anim_Attachment_RH
ValveBiped.Bip01_L_Clavicle
ValveBiped.Bip01_L_UpperArm
ValveBiped.Bip01_L_Forearm
ValveBiped.Bip01_L_Hand
ValveBiped.Anim_Attachment_LH
ValveBiped.Bip01_R_Thigh
ValveBiped.Bip01_R_Calf
ValveBiped.Bip01_R_Foot
ValveBiped.Bip01_R_Toe0
ValveBiped.Bip01_L_Thigh
ValveBiped.Bip01_L_Calf
ValveBiped.Bip01_L_Foot
ValveBiped.Bip01_L_Toe0
ValveBiped.Bip01_L_Finger4
ValveBiped.Bip01_L_Finger41
ValveBiped.Bip01_L_Finger42
ValveBiped.Bip01_L_Finger3
ValveBiped.Bip01_L_Finger31
ValveBiped.Bip01_L_Finger32
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger22
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger12
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_L_Finger02
ValveBiped.Bip01_R_Finger4
ValveBiped.Bip01_R_Finger41
ValveBiped.Bip01_R_Finger42
ValveBiped.Bip01_R_Finger3
ValveBiped.Bip01_R_Finger31
ValveBiped.Bip01_R_Finger32
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger22
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger12
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01
ValveBiped.Bip01_R_Finger02
ValveBiped.Bip01_L_Elbow
ValveBiped.Bip01_L_Ulna
ValveBiped.Bip01_R_Ulna
ValveBiped.Bip01_R_Shoulder
ValveBiped.Bip01_L_Shoulder
ValveBiped.Bip01_R_Trapezius
ValveBiped.Bip01_R_Wrist
ValveBiped.Bip01_R_Bicep
ValveBiped.Bip01_L_Bicep
ValveBiped.Bip01_L_Trapezius
ValveBiped.Bip01_L_Wrist
ValveBiped.Bip01_R_Elbow
--]]
