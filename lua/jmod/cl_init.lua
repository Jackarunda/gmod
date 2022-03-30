JMod.NukeFlashEndTime=0
JMod.NukeFlashPos=nil
JMod.NukeFlashRange=0
JMod.NukeFlashIntensity=1
JMod.NukeFlashSmokeEndTime=0
JMod.Wind=JMod.Wind or Vector(0,0,0)

surface.CreateFont("JMod-Display",{
	font="Arial",
	extended=false,
	size=35,
	weight=900,
	blursize=0,
	scanlines=4,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-NumberLCD",{
	font="DS-Digital Bold",
	extended=false,
	size=35,
	weight=100,
	blursize=0,
	scanlines=0,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-Display-S",{
	font="Arial",
	extended=false,
	size=20,
	weight=900,
	blursize=0,
	scanlines=4,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-Display-XS",{
	font="Arial",
	extended=false,
	size=15,
	weight=900,
	blursize=0,
	scanlines=4,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-Stencil",{
	font="Capture it",
	extended=false,
	size=60,
	weight=100,
	blursize=0,
	scanlines=0,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-Stencil-MS",{
	font="Capture it",
	extended=false,
	size=40,
	weight=100,
	blursize=0,
	scanlines=0,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-Stencil-S",{
	font="Capture it",
	extended=false,
	size=20,
	weight=100,
	blursize=0,
	scanlines=0,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-Stencil-XS",{
	font="Capture it",
	extended=false,
	size=10,
	weight=100,
	blursize=0,
	scanlines=0,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})
surface.CreateFont("JMod-SharpieHandwriting",{
	font="Handwriting",
	extended=false,
	size=40,
	weight=900,
	blursize=0,
	scanlines=0,
	antialias=true,
	underline=false,
	italic=false,
	strikeout=false,
	symbol=false,
	rotary=false,
	shadow=false,
	additive=false,
	outline=false
})

local function CreateClientLag(amt)
	local W,H=ScrW(),ScrH()
	for i=0,amt do
		draw.SimpleText("LAG","DermaDefault",math.random(W*.4,W*.6),math.random(H*.8,H*.9),Color(255,0,0,255*math.Rand(0,1)^10),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end

local WindChange,NextThink=Vector(0,0,0),0
local Count,Sum=0,0
hook.Add("Think","JMOD_CLIENT_THINK",function()
	--[[
	local dlight = DynamicLight( LocalPlayer():EntIndex() )
	if ( dlight ) then
		dlight.pos = LocalPlayer():GetShootPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 5
		dlight.Decay = 1000
		dlight.Size = 25600
		dlight.DieTime = CurTime() + 1
	end
	--]]
	local Time=CurTime()
	local ply,DrawNVGlamp=LocalPlayer(),false
	if not(ply:ShouldDrawLocalPlayer())then
		if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.effects))then
			if(ply.EZarmor.effects.nightVision)then
				DrawNVGlamp=true
				if not(IsValid(ply.EZNVGlamp))then
					ply.EZNVGlamp=ProjectedTexture()
					ply.EZNVGlamp:SetTexture("effects/flashlight001")
					ply.EZNVGlamp:SetBrightness(.025)
				else
					local Dir=ply:GetAimVector()
					local Ang=Dir:Angle()
					ply.EZNVGlamp:SetPos(EyePos()+Dir*10)
					ply.EZNVGlamp:SetAngles(Ang)
					ply.EZNVGlamp:SetConstantAttenuation(.2)
					local FoV=ply:GetFOV()
					ply.EZNVGlamp:SetFOV(FoV)
					ply.EZNVGlamp:SetFarZ(150000/FoV)
					ply.EZNVGlamp:Update()
				end
			end
		end
	end
	if not(DrawNVGlamp)then
		if(IsValid(ply.EZNVGlamp))then
			ply.EZNVGlamp:Remove()
		end
	end
	if(NextThink>Time)then return end
	NextThink=Time+5
	JMod.Wind=JMod.Wind+WindChange/10
	if(JMod.Wind:Length()>1)then
		JMod.Wind:Normalize()
		WindChange=-WindChange
	end
	WindChange=WindChange+Vector(math.Rand(-.5,.5),math.Rand(-.5,.5),0)
	if(WindChange:Length()>1)then WindChange:Normalize() end
	--[[
	Sum=Sum+(1/FrameTime())
	Count=Count+1
	if(Count>=100)then
		LocalPlayer():ChatPrint(tostring(math.Round(Sum/100)))
		Count=0
		Sum=0
	end
	--]]
end)


local BeamMat=CreateMaterial("xeno/beamgauss", "UnlitGeneric",{
	[ "$basetexture" ]	= "sprites/spotlight",
	[ "$additive" ]		= "1",
	[ "$vertexcolor" ]	= "1",
	[ "$vertexalpha" ]	= "1",
})
local GlowSprite,KnownSLAMs,NextSlamScan=Material("sprites/mat_jack_basicglow"),{},0
local ThermalGlowMat=Material("models/debug/debugwhite")
hook.Add("PostDrawTranslucentRenderables","JMOD_POSTDRAWTRANSLUCENTRENDERABLES",function()
	local Time=CurTime()
	if(Time>NextSlamScan)then
		NextSlamScan=Time+.5
		KnownSlams=ents.FindByClass("ent_jack_gmod_ezslam")
	end
	for k,ent in pairs(KnownSlams)do
		if(IsValid(ent))then
			local pos=ent:GetAttachment(1).Pos
			if(pos)then
				local trace=util.QuickTrace(pos,ent:GetUp()*1000,ent)
				local State,Vary=ent:GetState(),math.sin(CurTime()*50)/2+.5
				local Forward=-ent:GetUp()
				pos=pos-Forward*.5
				if(State==JMod.EZ_STATE_ARMING)then
					render.SetMaterial(GlowSprite)
					render.DrawSprite(pos,15,15,Color(255,0,0,100*Vary))
					render.DrawSprite(pos,7,7,Color(255,255,255,100*Vary))
					render.DrawQuadEasy(pos,Forward,15,15,Color(255,0,0,100*Vary),0)
					render.DrawQuadEasy(pos,Forward,7,7,Color(255,255,255,100*Vary),0)
				elseif State==JMod.EZ_STATE_ARMED then
					render.SetMaterial(BeamMat)
					render.DrawBeam(pos, trace.HitPos, 0.2, 0, 255, Color(255,0,0, 30))
					if trace.Hit then
						render.SetMaterial(GlowSprite)
						render.DrawSprite(trace.HitPos,8,8,Color(255,0,0,100))
						render.DrawSprite(trace.HitPos,4,4,Color(255,255,255,100))
						render.DrawQuadEasy(trace.HitPos,trace.HitNormal,15,15,Color(255,0,0,100),0)
						render.DrawQuadEasy(trace.HitPos,trace.HitNormal,7,7,Color(255,255,255,100),0)
					end
				end
			end
		end
	end
end)

net.Receive("JMod_LuaConfigSync",function()
	JMod.LuaConfig=JMod.LuaConfig or {}
	JMod.LuaConfig.ArmorOffsets=net.ReadTable()
	JMod.Config=JMod.Config or {}
	JMod.Config.AltFunctionKey=net.ReadInt(32)
	JMod.Config.WeaponSwayMult=net.ReadFloat()
	if(tobool(net.ReadBit()))then
		for k,v in pairs(player.GetAll())do
			JMod.CopyArmorTableToPlayer(v)
		end
	end
end)

function JMod.MakeModel(self,mdl,mat,scale,col)
	local Mdl=ClientsideModel(mdl)
	if(mat)then Mdl:SetMaterial(mat) end
	if(scale)then Mdl:SetModelScale(scale,0) end
	if(col)then Mdl:SetColor(col) end
	Mdl:SetPos(self:GetPos())
	Mdl:SetParent(self)
	Mdl:SetNoDraw(true)
	return Mdl
end

function JMod.RenderModel(mdl,pos,ang,scale,color,mat,fullbright,translucency)
	if(pos)then mdl:SetRenderOrigin(pos) end
	if(ang)then mdl:SetRenderAngles(ang) end
	if(scale)then
		local Matricks=Matrix()
		Matricks:Scale(scale)
		mdl:EnableMatrix("RenderMultiply",Matricks)
	end
	local R,G,B=render.GetColorModulation()
	local RenderCol=color or Vector(1,1,1)
	render.SetColorModulation(RenderCol.x,RenderCol.y,RenderCol.z)
	if(mat)then render.ModelMaterialOverride(mat) end
	if(fullbright)then render.SuppressEngineLighting(true) end
	if(translucenty)then render.SetBlend(translucency) end
	--mdl:SetLOD(8)
	mdl:DrawModel()
	render.SetColorModulation(R,G,B)
	render.ModelMaterialOverride(nil)
	render.SuppressEngineLighting(false)
	render.SetBlend(1)
end

local FRavg,FRcount=0,0
function JMod.MeasureFramerate()
	local FR=1/FrameTime()
	FRavg=FRavg+FR
	FRcount=FRcount+1
	if(FRcount>=100)then
		jprint(math.Round(FRavg/100))
		FRavg=0
		FRcount=0
	end
end

local WHOTents,NextWHOTcheck={},0
local function IsWHOT(ent)
	local Time=CurTime()
	if(ent:IsWorld())then return false end
	if((ent:IsPlayer())or(ent:IsOnFire()))then return true end
	if(ent:IsNPC())then
		if((ent.Health)and(ent:Health()>0))then return true end
	elseif(ent:IsRagdoll())then
		if not(ent.EZWHOTcoldTime)then ent.EZWHOTcoldTime=Time+30 end
	elseif(ent:IsVehicle() or (simfphys and simfphys.IsCar(ent)))then
		-- HL2/Simfphys vehicles
		if IsValid(ent:GetDriver()) and ent:GetVelocity():Length()>=200 then
			ent.EZWHOTcoldTime=Time+math.Clamp(ent:GetVelocity():Length()/20,10,40)
		end
		if LocalPlayer() == ent:GetDriver() then return false end
	elseif scripted_ents.Get(ent:GetClass()) and scripted_ents.IsBasedOn(ent:GetClass(), "lunasflightschool_basescript") then
		-- LFS planes
		-- Helicopter rotors will look ugly but eh
		if ent:GetEngineActive() then
			ent.EZWHOTcoldTime=Time+30
		end
		-- Don't highlight the plane the player is in. Otherwise their view will be pure white
		if LocalPlayer():lfsGetPlane() == ent then return false end
	elseif scripted_ents.Get(ent:GetClass()) and scripted_ents.IsBasedOn(ent:GetClass(), "gred_emp_base") then
		-- Gredwich Emplacements
		if ent:GetIsReloading() or ent.NextShot > Time then
			ent.EZWHOTcoldTime=Time+30
		end
	elseif scripted_ents.Get(ent:GetClass()) and scripted_ents.IsBasedOn(ent:GetClass(), "dronesrewrite_base") then
		-- Drones Rewrite
		if ent:IsDroneEnabled() then
			ent.EZWHOTcoldTime=Time+30
		end

	end
	return (ent.EZWHOTcoldTime or 0)>Time
end

local thermalmodify = {
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=0,
	["$pp_colour_contrast"]=.2,
	["$pp_colour_colour"]=1,
	["$pp_colour_mulr"]=0,
	["$pp_colour_mulg"]=0,
	["$pp_colour_mulb"]=0
}
hook.Add("PostDrawOpaqueRenderables","JMOD_POSTOPAQUERENDERABLES",function()
	local ply,Time=LocalPlayer(),CurTime()
	if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.effects)and(ply.EZarmor.effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
		DrawColorModify(thermalmodify)
		if(NextWHOTcheck<Time)then
			NextWHOTcheck=Time+.5
			WHOTents={}
			for k,v in pairs(ents.GetAll())do
				if(IsWHOT(v))then table.insert(WHOTents,v) end
			end
		end
		for key,targ in pairs(WHOTents)do
			if(IsValid(targ))then
				local Br=.9
				if(targ.EZWHOTcoldTime)then
					Br=.75*(targ.EZWHOTcoldTime-Time)/30
				end
				if(Br>.1)then
					render.ModelMaterialOverride(ThermalGlowMat)
					render.SuppressEngineLighting(true)
					render.SetColorModulation(Br,Br,Br)
					if targ:GetRenderMode() == RENDERMODE_NORMAL then
						targ:DrawModel()
					end
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.ModelMaterialOverride(nil)
				end
			end
		end
	end
end)

hook.Add("PostDrawTranslucentRenderables","JMOD_POSTTRANSLUCENTRENDERABLES",function()
	local ply,Time=LocalPlayer(),CurTime()
	if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.effects)and(ply.EZarmor.effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
		for key,targ in pairs(WHOTents)do
			if(IsValid(targ))then
				local Br=.9
				if(targ.EZWHOTcoldTime)then
					Br=.75*(targ.EZWHOTcoldTime-Time)/30
				end
				if(Br>.1)then
					render.ModelMaterialOverride(ThermalGlowMat)
					render.SuppressEngineLighting(true)
					render.SetColorModulation(Br,Br,Br)
					if targ:GetRenderMode() == RENDERMODE_TRANSALPHA then
						targ:DrawModel()
					end
					render.SetColorModulation(1,1,1)
					render.SuppressEngineLighting(false)
					render.ModelMaterialOverride(nil)
				end
			end
		end
	end
end)

local SomeKindOfFog=Material("white_square")
hook.Add("PostDrawSkyBox","JMOD_POSTSKYBOX",function()
	local Time=CurTime()
	if(JMod.NukeFlashSmokeEndTime>Time)then
		local Frac=((JMod.NukeFlashSmokeEndTime-Time)/30)^.15
		local W,H=ScrW(),ScrH()
		cam.Start3D2D(EyePos()+Vector(0,0,100),Angle(0,0,0),2)
		surface.SetMaterial(SomeKindOfFog)
		surface.SetDrawColor(100,100,100,230*Frac)
		surface.DrawRect(-W*2,-H*2,W*4,H*4)
		cam.End3D2D()
	end
end)

hook.Add("SetupWorldFog","JMOD_WORLDFOG",function()
	local Time=CurTime()
	local ply=LocalPlayer()
	if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.effects)and(ply.EZarmor.effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
		render.FogMode(0)
		return true
	end
	if(JMod.NukeFlashSmokeEndTime>Time)then
		local Frac=((JMod.NukeFlashSmokeEndTime-Time)/30)^.15
		render.FogMode(1)
		render.FogColor(100,100,100)
		render.FogStart(0)
		render.FogEnd(1000)
		render.FogMaxDensity(Frac)
		return true
	end
end)

hook.Add("SetupSkyboxFog","JMOD_SKYFOG",function(scale)
	local Time=CurTime()
	local ply=LocalPlayer()
	if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.effects)and(ply.EZarmor.effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
		render.FogMode(0)
		return true
	end
	if(JMod.NukeFlashSmokeEndTime>Time)then
		local Frac=((JMod.NukeFlashSmokeEndTime-Time)/30)^.15
		render.FogMode(1)
		render.FogColor(100,100,100)
		render.FogStart(1*scale)
		render.FogEnd(1500*scale)
		render.FogMaxDensity(Frac)
		return true
	end
end)

hook.Add("ShouldSit","JMOD_SITANYWHERE_COMPATIBILITY",function(ply)
	-- let it be known for the record that the SitAnywhere addon author is an idiot
	local Tr=ply:GetEyeTrace()
	if((Tr.Entity)and(Tr.Entity.NoSitAllowed))then return false end
	for k,v in pairs(ents.FindInSphere(Tr.HitPos,20))do
		if(v.NoSitAllowed)then return false end
	end
end)

local function CommNoise()
	surface.PlaySound("snds_jack_gmod/radio_static"..math.random(1,3)..".wav")
end

hook.Add("PlayerStartVoice","JMOD_PLAYERSTARTVOICE",function(ply)
	if not(ply:Alive())then return end
	if not(LocalPlayer():Alive())then return end
	if((ply.EZarmor)and(ply.EZarmor.effects.teamComms)and(JMod.PlayersCanComm(LocalPlayer(),ply)))then
		surface.PlaySound("snds_jack_gmod/radio_start.wav")
	end
end)

hook.Add("OnPlayerChat","JMOD_ONPLAYERCHAT",function(ply, text, isTeam, isDead)
	if not(IsValid(ply))then return end
	if not(ply:Alive())then return end
	if not(LocalPlayer():Alive())then return end
	if((ply.EZarmor)and(ply.EZarmor.effects.teamComms)and(JMod.PlayersCanComm(LocalPlayer(),ply)))then
		CommNoise()
		if not isTeam and not isDead then
			local tab = {}
			table.insert( tab, Color( 30, 40, 200 ) )
			table.insert( tab, "(HEADSET) " )
			table.insert( tab, ply )
			table.insert( tab, Color( 255, 255, 255 ) )
			table.insert( tab, ": ".. text )
			chat.AddText( unpack(tab) )
			return true
		end
	end
end)

hook.Add("PlayerEndVoice","JMOD_PLAYERENDVOICE",function(ply)
	if not(ply:Alive())then return end
	if not(LocalPlayer():Alive())then return end
	if((ply.EZarmor)and(ply.EZarmor.effects.teamComms)and(JMod.PlayersCanComm(LocalPlayer(),ply)))then
		CommNoise()
	end
end)

concommand.Add("jacky_supershadows",function(ply,cmd,args)
	RunConsoleCommand("r_projectedtexture_filter",.1)
	RunConsoleCommand("r_flashlightdepthres",16384)
	RunConsoleCommand("mat_depthbias_shadowmap",.0000005)
	RunConsoleCommand("mat_slopescaledepthbias_shadowmap",2)
	print("super shadows enabled, have fun with the lag")
end, nil, "Enables higher detailed shadows; great for photography.")

concommand.Add("jmod_debug_showgasparticles",function(ply,cmd,args)
	if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
	ply.EZshowGasParticles=not (ply.EZshowGasParticles or false)
	print("gas particle display: "..tostring(ply.EZshowGasParticles))
end,nil,JMod.Lang("command jmod_debug_showgasparticles"))

net.Receive("JMod_NuclearBlast",function()
	local pos,renj,intens=net.ReadVector(),net.ReadFloat(),net.ReadFloat()
	JMod.NukeFlashEndTime=CurTime()+8
	JMod.NukeFlashPos=pos
	JMod.NukeFlashRange=renj
	JMod.NukeFlashIntensity=intens
	if(intens>1)then JMod.NukeFlashSmokeEndTime=CurTime()+30 end
	local maxRange=renj
	local maxImmolateRange=renj*.3
	for k,ent in pairs(ents.FindInSphere(pos,maxRange))do
		if((IsValid(ent))and(ent.GetClass))then
			local Class=ent:GetClass()
			if((Class=="class C_ClientRagdoll")or(Class=="class C_HL2MPRagdoll"))then
				local Vec=(ent:GetPos()-pos)
				local Dir=Vec:GetNormalized()
				for i=0,100 do
					local Phys=ent:GetPhysicsObjectNum(i)
					if(Phys)then
						Phys:ApplyForceCenter(Dir*1e10)
					end
					if(Vec:Length()<maxImmolateRange)then
						local HeadID=ent:LookupBone("ValveBiped.Bip01_Head1")
						if(HeadID)then -- if it has a Head ID then it's probably a humanoid ragdoll
							ent:SetModel("models/Humans/Charple0"..math.random(1,4)..".mdl")
						else
							ent:SetColor(Color(20,20,20))
						end
					end
				end
			end
		end
	end
end)
net.Receive("JMod_VisionBlur",function()
	local ply = LocalPlayer()
	ply.EZvisionBlur = math.Clamp((ply.EZvisionBlur or 0)+net.ReadFloat(),0,75)
end)

net.Receive("JMod_Bleeding",function()
	LocalPlayer().EZbleeding=net.ReadInt(8)
end)

net.Receive("JMod_SFX",function()
	surface.PlaySound(net.ReadString())
end)

net.Receive("JMod_VisualGunRecoil",function()
	local Ent=net.ReadEntity()
	local Amt=net.ReadFloat()
	if((IsValid(Ent))and(Ent.AddVisualRecoil))then
		Ent:AddVisualRecoil(Amt)
	end
end)

net.Receive("JMod_Ravebreak",function()
	-- fucking HELL YES HERE WE GO
	surface.PlaySound("snds_jack_gmod/ravebreak.mp3")
	LocalPlayer().JMod_RavebreakStartTime=CurTime()+2.325
	LocalPlayer().JMod_RavebreakEndTime=CurTime()+25.5
	-- note that the song's beat is about .35 seconds
end)

hook.Add("RenderScene","JMod_RenderScene",function(origin,angs,fov)
	render.SetAmbientLight(1,1,1)
	render.SetLightingOrigin(Vector(-3400,5300,400))
end)
--hook.Add("PostRender","JMod_PostRender",function()
--	engine.LightStyle(0,"m")
--end)

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
