AddCSLuaFile()
include("jmod_shared.lua")
if(CLIENT)then
	local ArmorAppearances={
		--vests
		["Ballistic Nylon"]="models/mat_jack_bodyarmor_bn",
		["Stab Vest"]="models/mat_jack_bodyarmor_sv",
		["Soft Kevlar"]="models/mat_jack_bodyarmor_sk",
		["Kevlar SAPI"]="models/mat_jack_bodyarmor_ks",
		["Impact Vest"]="models/mat_jack_bodyarmor_im",
		--helmets
		["Steel"]="models/mat_jack_helmetmetal",
		["Kevlar Resin"]="models/mat_jack_monotone_acu_flat",
		["Polyethylene"]="models/mat_jack_monotone_abu_flat",
		["Riot"]="models/mat_jack_bodyarmor_riothelm",
		["Impact"]="models/mat_jack_motorcyclehelmet",
		--suits
		["Hazardous Material"]="models/dpfilms/jetropolice/playermodels/pm_police_bt.mdl",
		["Fire-Faraday"]="models/dpfilms/jetropolice/playermodels/pm_policetrench.mdl",
		["EOD"]="models/juggerjaut_player.mdl"
	}
	local ArmorDisadvantages={
		--vests
		["Ballistic Nylon"]=.99,
		["Stab Vest"]=.95,
		["Soft Kevlar"]=.95,
		["Kevlar SAPI"]=.75,
		["Impact Vest"]=.7,
		--helmets
		["Steel"]="sprites/mat_jack_helmoverlay_h",
		["Kevlar Resin"]="sprites/mat_jack_helmoverlay_l",
		["Polyethylene"]="sprites/mat_jack_helmoverlay_n",
		["Riot"]="sprites/mat_jack_helmoverlay_r",
		["Impact"]="sprites/mat_jack_helmoverlay_i",
		--suits
		["Hazardous Material"]={"sprites/mat_jack_hazmatoverlay",.75},
		["Fire-Faraday"]={"sprites/mat_jack_firesuitoverlay",.75},
		["EOD"]={"sprites/mat_jack_helmoverlay_e",.5}
	}
	hook.Add("Initialize","JMOD_INIT",function()
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
	end)
	local function JackSentCont(data)
		local ply=data:ReadEntity()
		local term=data:ReadEntity()
		local sent=data:ReadEntity()
		ply.JackaSentryControl=sent
		ply.JackaSentryTerminal=term
		term.Controller=ply
		term.Controlled=sent
		sent.ControllingPly=ply
		sent.ControllingTerminal=term
	end
	usermessage.Hook("JackaSentryControl",JackSentCont)
	local function JackSentContWipe(data)
		local ply=data:ReadEntity()
		local term=data:ReadEntity()
		local sent=data:ReadEntity()
		ply.JackaSentryControl=nil
		ply.JackaSentryTerminal=nil
		term.Controller=nil
		term.Controlled=nil
		sent.ControllingPly=nil
		sent.ControllingTerminal=nil
	end
	usermessage.Hook("JackaSentryControlWipe",JackSentContWipe)
	local function Hinder(default)
		local Ply=LocalPlayer()
		if(Ply.JackyArmor)then
			if(Ply.JackyArmor.Vest)then
				return ArmorDisadvantages[Ply.JackyArmor.Vest.Type]
			elseif(Ply.JackyArmor.Suit)then
				return ArmorDisadvantages[Ply.JackyArmor.Suit.Type][2]
			end
		end
		if(Ply.JackaSentryControl)then
			return .001
		end
	end
	hook.Add("AdjustMouseSensitivity","JackyArmorHindrance",Hinder)
	local function ScreenSpaceEffects()
		local Ply=LocalPlayer()
		if(Ply.JackyArmor)then
			if(Ply.JackyArmor.Helmet)then
				if not(Ply:ShouldDrawLocalPlayer())then DrawMaterialOverlay(ArmorDisadvantages[Ply.JackyArmor.Helmet.Type],1) end
			elseif(Ply.JackyArmor.Suit)then
				if not(Ply:ShouldDrawLocalPlayer())then
					DrawMaterialOverlay(ArmorDisadvantages[Ply.JackyArmor.Suit.Type][1],1)
				end
			end
		end
	end
	hook.Add("RenderScreenspaceEffects","JackyArmorSpaceEffects",ScreenSpaceEffects)
	local MskSndLops={}
	hook.Add("HUDPaintBackground","JMOD_HUDBG",function()
		local ply,Play=LocalPlayer(),false
		if(ply.EZarmor)then
			local MaskType,Alive,ThirdPerson=ply.EZarmor.slots["Face"] and ply.EZarmor.slots["Face"][1],ply:Alive(),ply:ShouldDrawLocalPlayer()
			if(MaskType)then
				local Specs=JMod_ArmorTable["Face"][MaskType]
				if((Specs.mskmat)and(Alive)and not(ThirdPerson)and(ply.EZarmor.maskOn))then
					surface.SetMaterial(Specs.mskmat)
					surface.SetDrawColor(255,255,255,255)
					surface.DrawTexturedRect(0,0,ScrW(),ScrH())
					surface.DrawTexturedRect(0,0,ScrW(),ScrH())
					surface.DrawTexturedRect(0,0,ScrW(),ScrH())
				end
				Play=(Alive)and(Specs.sndlop)and not(ThirdPerson)and(ply.EZarmor.maskOn)
				if(Play)then
					if not(MskSndLops[MaskType])then
						MskSndLops[MaskType]=CreateSound(ply,Specs.sndlop)
						MskSndLops[MaskType]:Play()
					elseif(not(MskSndLops[MaskType]:IsPlaying()))then
						MskSndLops[MaskType]:Play()
					end
				end
			end
		end
		if not(Play)then
			for k,v in pairs(MskSndLops)do
				v:Stop()
				MskSndLops[k]=nil
			end
		end
	end)
	local function JackyArmorUpdate(data)
		local Ply=data:ReadEntity()
		local Slot=data:ReadString()
		local Item=data:ReadString()
		local R=data:ReadShort()
		local G=data:ReadShort()
		local B=data:ReadShort()
		if not(Ply.JackyArmor)then Ply.JackyArmor={} end
		local Colr=Color(R,G,B)
		if not(Item=="nil")then
			Ply.JackyArmor[Slot]={}
			Ply.JackyArmor[Slot].Type=Item
			Ply.JackyArmor[Slot].Colr=Colr
		else
			if(Ply.JackyArmor)then
				Ply.JackyArmor[Slot]=nil
			end
		end
	end
	usermessage.Hook("JackaBodyArmorUpdateClient",JackyArmorUpdate)
	local EZarmorBoneTable={
		Torso="ValveBiped.Bip01_Spine2",
		Head="ValveBiped.Bip01_Head1",
		LeftShoulder="ValveBiped.Bip01_L_UpperArm",
		RightShoulder="ValveBiped.Bip01_R_UpperArm",
		LeftForearm="ValveBiped.Bip01_L_Forearm",
		RightForearm="ValveBiped.Bip01_R_Forearm",
		LeftThigh="ValveBiped.Bip01_L_Thigh",
		RightThigh="ValveBiped.Bip01_R_Thigh",
		LeftCalf="ValveBiped.Bip01_L_Calf",
		RightCalf="ValveBiped.Bip01_R_Calf",
		Pelvis="ValveBiped.Bip01_Pelvis",
		Face="ValveBiped.Bip01_Head1"
	}
	local function JackyArmorPlayerDraw(ply)
		if not(IsValid(ply))then return end
		if(ply.JackyArmor)then
			if(ply.JackyArmor.Vest)then
				if(ply.JackyArmor.Vest.VisualModel)then
					local Bone=ply:LookupBone("ValveBiped.Bip01_Spine2")
					if not(Bone)then Bone=0 end
					local Pos,Ang=ply:GetBonePosition(Bone)
					Ang:RotateAroundAxis(Ang:Forward(),90)
					Ang:RotateAroundAxis(Ang:Right(),-90)
					ply.JackyArmor.Vest.VisualModel:SetRenderAngles(Ang)
					Pos=Pos-Ang:Up()*8+Ang:Forward()*3
					ply.JackyArmor.Vest.VisualModel:SetRenderOrigin(Pos)
					local R,G,B=render.GetColorModulation()
					render.SetColorModulation(ply.JackyArmor.Vest.Colr.r/255,ply.JackyArmor.Vest.Colr.g/255,ply.JackyArmor.Vest.Colr.b/255)
					ply.JackyArmor.Vest.VisualModel:DrawModel()
					render.SetColorModulation(R,G,B)
				else
					ply.JackyArmor.Vest.VisualModel=ClientsideModel("models/combine_vests/bluevest.mdl")
					ply.JackyArmor.Vest.VisualModel:SetPos(ply:GetPos())
					ply.JackyArmor.Vest.VisualModel:SetParent(ply)
					ply.JackyArmor.Vest.VisualModel:SetNoDraw(true)
					if((ply.JackyArmor.Vest.Type=="Kevlar SAPI")or(ply.JackyArmor.Vest.Type=="Impact Vest"))then
						ply.JackyArmor.Vest.VisualModel:SetModelScale(.9,0)
					else
						ply.JackyArmor.Vest.VisualModel:SetModelScale(.875,0)
					end
					ply.JackyArmor.Vest.VisualModel:SetMaterial(ArmorAppearances[ply.JackyArmor.Vest.Type])
				end
			end
			if(ply.JackyArmor.Helmet)then
				if(ply.JackyArmor.Helmet.VisualModel)then
					local Bone=ply:LookupBone("ValveBiped.Bip01_Head1")
					if not(Bone)then Bone=0 end
					local Pos,Ang=ply:GetBonePosition(Bone)
					if(ply.JackyArmor.Helmet.Type=="Steel")then
						Ang:RotateAroundAxis(Ang:Up(),-85)
						Ang:RotateAroundAxis(Ang:Right(),-90)
						Pos=Pos-Ang:Right()*1.25
					elseif(ply.JackyArmor.Helmet.Type=="Impact")then
						Ang:RotateAroundAxis(Ang:Up(),-75)
						Ang:RotateAroundAxis(Ang:Forward(),-90)
						Pos=Pos+Ang:Forward()*1+Ang:Up()*2.75
					else
						Ang:RotateAroundAxis(Ang:Up(),-75)
						Ang:RotateAroundAxis(Ang:Forward(),-90)
						Pos=Pos+Ang:Forward()*1.5+Ang:Up()
					end
					ply.JackyArmor.Helmet.VisualModel:SetRenderAngles(Ang)
					ply.JackyArmor.Helmet.VisualModel:SetRenderOrigin(Pos)
					local R,G,B=render.GetColorModulation()
					render.SetColorModulation(ply.JackyArmor.Helmet.Colr.r/255,ply.JackyArmor.Helmet.Colr.g/255,ply.JackyArmor.Helmet.Colr.b/255)
					ply.JackyArmor.Helmet.VisualModel:DrawModel()
					render.SetColorModulation(R,G,B)
					if(ply.JackyArmor.Helmet.Type=="Riot")then
						if(ply.JackyArmor.Helmet.VisualModel.Visor)then
							Ang:RotateAroundAxis(Ang:Up(),180)
							ply.JackyArmor.Helmet.VisualModel.Visor:SetRenderAngles(Ang)
							Pos=Pos-Ang:Up()*5+Ang:Right()*2.6-Ang:Forward()*4.5
							ply.JackyArmor.Helmet.VisualModel.Visor:SetRenderOrigin(Pos)
							render.SetColorModulation(0,0,0)
							ply.JackyArmor.Helmet.VisualModel.Visor:DrawModel()
							render.SetColorModulation(R,G,B)
						else
							ply.JackyArmor.Helmet.VisualModel.Visor=ClientsideModel("models/props_phx/construct/glass/glass_curve180x2.mdl")
							ply.JackyArmor.Helmet.VisualModel.Visor:SetPos(ply:GetPos())
							ply.JackyArmor.Helmet.VisualModel.Visor:SetParent(ply)
							ply.JackyArmor.Helmet.VisualModel.Visor:SetNoDraw(true)
							ply.JackyArmor.Helmet.VisualModel.Visor:SetModelScale(.08,0)
						end
					end
				else
					if(ply.JackyArmor.Helmet.Type=="Steel")then
						ply.JackyArmor.Helmet.VisualModel=ClientsideModel("models/player/items/scout/scout_bils.mdl")
					elseif(ply.JackyArmor.Helmet.Type=="Impact")then
						ply.JackyArmor.Helmet.VisualModel=ClientsideModel("models/dean/gtaiv/helmet.mdl")
					else
						ply.JackyArmor.Helmet.VisualModel=ClientsideModel("models/barney_helmet.mdl")
					end
					ply.JackyArmor.Helmet.VisualModel:SetPos(ply:GetPos())
					ply.JackyArmor.Helmet.VisualModel:SetParent(ply)
					ply.JackyArmor.Helmet.VisualModel:SetNoDraw(true)
					ply.JackyArmor.Helmet.VisualModel:SetMaterial(ArmorAppearances[ply.JackyArmor.Helmet.Type])
				end
			end
		end
		if((ply.EZarmor)and(ply.EZarmorModels))then
			for slot,info in pairs(ply.EZarmor.slots)do
				local Name,Durability,Colr,Render=info[1],info[2],info[3],true
				if((slot=="Face")and not(ply.EZarmor.maskOn))then Render=false end
				if((slot=="Ears")and not(ply.EZarmor.headsetOn))then Render=false end
				local Specs=JMod_ArmorTable[slot][Name]
				if(Render)then
					if(ply.EZarmorModels[slot])then
						local Mdl=ply.EZarmorModels[slot]
						local MdlName=Mdl:GetModel()
						if(MdlName==Specs.mdl)then
							-- render it
							local Index=ply:LookupBone(EZarmorBoneTable[slot])
							if(Index)then
								local Pos,Ang=ply:GetBonePosition(Index)
								if((Pos)and(Ang))then
									local Right,Forward,Up=Ang:Right(),Ang:Forward(),Ang:Up()
									Pos=Pos+Right*Specs.pos.x+Forward*Specs.pos.y+Up*Specs.pos.z
									Ang:RotateAroundAxis(Right,Specs.ang.p)
									Ang:RotateAroundAxis(Up,Specs.ang.y)
									Ang:RotateAroundAxis(Forward,Specs.ang.r)
									Mdl:SetRenderOrigin(Pos)
									Mdl:SetRenderAngles(Ang)
									local Mat=Matrix()
									Mat:Scale(Specs.siz)
									Mdl:EnableMatrix("RenderMultiply",Mat)
									local OldR,OldG,OldB=render.GetColorModulation()
									render.SetColorModulation(Colr.r/255,Colr.g/255,Colr.b/255)
									Mdl:DrawModel()
									render.SetColorModulation(OldR,OldG,OldB)
								end
							end
						else
							-- remove it
							ply.EZarmorModels[slot]:Remove()
							ply.EZarmorModels[slot]=nil
						end
					else
						-- create it
						local Mdl=ClientsideModel(Specs.mdl)
						Mdl:SetModel(Specs.mdl) -- what the FUCK garry
						Mdl:SetPos(ply:GetPos())
						Mdl:SetMaterial(Specs.mat or "")
						Mdl:SetParent(ply)
						Mdl:SetNoDraw(true)
						ply.EZarmorModels[slot]=Mdl
					end
				end
			end
		end
	end
	hook.Add("PostPlayerDraw","JackyArmorPlayerDraw",JackyArmorPlayerDraw)
	--- OLD OPSQUADS CODE ---
	function JPrint(msg)
		LocalPlayer():ChatPrint("["..tostring(math.Round(CurTime(),1)).."] "..tostring(msg))
	end
	local function JackyOpSquadGiveHelmet(data)
		local Helm=ClientsideModel("models/haloreach/jarinehelmet.mdl")
		local Ent=data:ReadEntity()
		Helm:SetBodygroup(2,math.random(1,2))
		--Helm:SetBodygroup(1,math.random(0,1)) --their face-models vary too much for this to work
		if not(Ent)then return end
		Helm:SetPos(Ent:GetPos())
		Helm.Wearer=Ent
		Helm.IsJackyOpSquadHelmet=true
		Ent.Helmet=Helm
		local Mat=Matrix()
		Mat:Scale(Vector(1.15,1,1))
		Helm:EnableMatrix("RenderMultiply",Mat)
		Helm:SetParent(Ent)
		--Helm:SetColor(Color(200,200,200))
		Helm:SetNoDraw(true)
		Helm:FollowBone(Ent,6)
	end
	usermessage.Hook("JackyOpSquadGiveHelmet",JackyOpSquadGiveHelmet)
	local function JackyOpSquadCreateRagdollClientHook(ent,ragdoll)
		if not(ent.JackyOpSquadNPC)then return end
		ragdoll:SetMaterial(ent:GetMaterial())
	end
	hook.Add("CreateClientsideRagdoll","JackyOpSquadCreateRagdollClientHook",JackyOpSquadCreateRagdollClientHook)
	local function JackySetClientBoolean(data)
		local Ent=data:ReadEntity()
		local Key=data:ReadString()
		local Value=data:ReadBool()
		Ent[Key]=Value
	end
	usermessage.Hook("JackySetClientBoolean",JackySetClientBoolean)
	local function JackyClientHeadcrabRemoval(data)
		local Pos=data:ReadVector()
		timer.Simple(.01,function()
			for key,rag in pairs(ents.FindInSphere(Pos,90))do
				if(rag:GetClass()=="class C_ClientRagdoll")then
					local Moddel=rag:GetModel()
					if((Moddel=="models/headcrabclassic.mdl")or(Moddel=="models/headcrab.mdl"))then
						SafeRemoveEntity(rag)
					end
				end
			end
		end)
	end
	usermessage.Hook("JackyClientHeadcrabRemoval",JackyClientHeadcrabRemoval)
	local function JackyClientRagdollRemoval(data)
		local Pos=data:ReadVector()
		timer.Simple(.01,function()
			for key,rag in pairs(ents.FindInSphere(Pos,90))do
				if(rag:GetClass()=="class C_ClientRagdoll")then
					SafeRemoveEntity(rag)
				end
			end
		end)
	end
	usermessage.Hook("JackyOpSquadNoRagdoll",JackyClientRagdollRemoval)
	local function JackyOpSquadRemoveHelmet(data)
		SafeRemoveEntity(data:ReadEntity().Helmet)
	end
	usermessage.Hook("JackyOpSquadRemoveHelmet",JackyOpSquadRemoveHelmet)
	--local Avg=0
	--local Count=0
	local function JackyOpSquadOpaqueDrawFunc(bDrawingDepth,bDrawingSkybox)
		--Avg=Avg+FrameTime()
		--Count=Count+1
		--if(Count>=300)then
		--	Count=0
		--	JPrint(Avg/300)
		--	Avg=0
		--end
		for key,helm in pairs(ents.FindByClass("class C_BaseFlex"))do
			if(helm.IsJackyOpSquadHelmet)then
				if not(IsValid(helm.Wearer))then
					SafeRemoveEntity(helm)
					return
				end
				local Pos,Ang=helm.Wearer:GetBonePosition(6) --head
				local Right=Ang:Right()
				local Up=Ang:Up()
				local Forward=Ang:Forward()
				helm:SetRenderOrigin(Pos-Forward*59+Right*29.7-Up*1.8)
				Ang:RotateAroundAxis(Up,-190)
				Ang:RotateAroundAxis(Right,-95)
				Ang:RotateAroundAxis(Forward,102)
				Ang:RotateAroundAxis(Ang:Right(),20)
				helm:SetAngles(Ang)
				local PosTwo=Pos+Vector(0,0,40) -- all this shit could be avoided if the damn model just had a proper origin
				local Col=render.GetLightColor(PosTwo)
				render.SuppressEngineLighting(true)
				render.SetModelLighting(BOX_TOP,Col.r*1.5,Col.g*1.5,Col.b*1.5)
				render.SetModelLighting(BOX_BOTTOM,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_RIGHT,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_LEFT,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_FRONT,Col.r*.25,Col.g*.25,Col.b*.25)
				render.SetModelLighting(BOX_BACK,Col.r*.25,Col.g*.25,Col.b*.25)
				helm:DrawModel()
				render.ResetModelLighting(1,1,1)
				render.SuppressEngineLighting(false)
			end
		end
	end
	hook.Add("PostDrawOpaqueRenderables","JackyOpSquadOpaqueDrawFunc",JackyOpSquadOpaqueDrawFunc)
	--- END OLD OPSQUADS CODE ---
	--- no u ---
	local BeamMat=CreateMaterial("xeno/beamgauss", "UnlitGeneric",{
		[ "$basetexture" ]    = "sprites/spotlight",
		[ "$additive" ]        = "1",
		[ "$vertexcolor" ]    = "1",
		[ "$vertexalpha" ]    = "1",
	})
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	hook.Add("PostDrawTranslucentRenderables","JMOD_POSTDRAWTRANSLUCENTRENDERABLES",function()
		for k,ent in pairs(ents.FindByClass("ent_jack_gmod_ezslam"))do
			local pos=ent:GetAttachment(1).Pos
			if(pos)then
				local trace=util.QuickTrace(pos,ent:GetUp()*1000,ent)
				local State,Vary=ent:GetState(),math.sin(CurTime()*50)/2+.5
				local Forward=-ent:GetUp()
				pos=pos-Forward*.5
				if(State==JMOD_EZ_STATE_ARMING)then
					render.SetMaterial(GlowSprite)
					render.DrawSprite(pos,15,15,Color(255,0,0,100*Vary))
					render.DrawSprite(pos,7,7,Color(255,255,255,100*Vary))
					render.DrawQuadEasy(pos,Forward,15,15,Color(255,0,0,100*Vary),0)
					render.DrawQuadEasy(pos,Forward,7,7,Color(255,255,255,100*Vary),0)
				elseif State==JMOD_EZ_STATE_ARMED then
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
	end)
	local blurMat,Dynamic,MenuOpen,YesMat,NoMat=Material("pp/blurscreen"),0,false,Material("icon16/accept.png"),Material("icon16/cancel.png")
	local function BlurBackground(panel)
		if not((IsValid(panel))and(panel:IsVisible()))then return end
		local layers,density,alpha=1,1,255
		local x,y=panel:LocalToScreen(0,0)
		surface.SetDrawColor(255,255,255,alpha)
		surface.SetMaterial(blurMat)
		local FrameRate,Num,Dark=1/FrameTime(),5,150
		for i=1,Num do
			blurMat:SetFloat("$blur",(i/layers)*density*Dynamic)
			blurMat:Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(-x,-y,ScrW(),ScrH())
		end
		surface.SetDrawColor(0,0,0,Dark*Dynamic)
		surface.DrawRect(0,0,panel:GetWide(),panel:GetTall())
		Dynamic=math.Clamp(Dynamic+(1/FrameRate)*7,0,1)
	end
	local function PopulateList(parent,friendList,myself,W,H)
		parent:Clear()
		local Y=0
		for k,playa in pairs(player.GetAll())do
			if(playa~=myself)then
				local Panel=parent:Add("DPanel")
				Panel:SetSize(W-35,20)
				Panel:SetPos(0,Y)
				function Panel:Paint(w,h)
					surface.SetDrawColor(0,0,0,100)
					surface.DrawRect(0,0,w,h)
					draw.SimpleText(playa:Nick(),"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
				end
				local Buttaloney=vgui.Create("DButton",Panel)
				Buttaloney:SetPos(Panel:GetWide()-25,0)
				Buttaloney:SetSize(20,20)
				Buttaloney:SetText("")
				local InLikeFlynn=table.HasValue(friendList,playa)
				function Buttaloney:Paint(w,h)
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial((InLikeFlynn and YesMat)or NoMat)
					surface.DrawTexturedRect(2,2,16,16)
				end
				function Buttaloney:DoClick()
					surface.PlaySound("garrysmod/ui_click.wav")
					if(InLikeFlynn)then
						table.RemoveByValue(friendList,playa)
					else
						table.insert(friendList,playa)
					end
					PopulateList(parent,friendList,myself,W,H)
				end
				Y=Y+25
			end
		end
	end
	net.Receive("JMod_Friends",function()
		if(MenuOpen)then return end
		MenuOpen=true
		local Frame,W,H,Myself,FriendList=vgui.Create("DFrame"),300,400,LocalPlayer(),net.ReadTable()
		Frame:SetPos(40,80)
		Frame:SetSize(W,H)
		Frame:SetTitle("Select Allies")
		Frame:SetVisible(true)
		Frame:SetDraggable(true)
		Frame:ShowCloseButton(true)
		Frame:MakePopup()
		Frame:Center()
		Frame.OnClose=function()
			MenuOpen=false
			net.Start("JMod_Friends")
			net.WriteTable(FriendList)
			net.SendToServer()
		end
		function Frame:OnKeyCodePressed(key)
			if((key==KEY_Q)or(key==KEY_ESCAPE))then self:Close() end
		end
		function Frame:Paint()
			BlurBackground(self)
		end
		local Scroll=vgui.Create("DScrollPanel",Frame)
		Scroll:SetSize(W-15,H)
		Scroll:SetPos(10,30)
		PopulateList(Scroll,FriendList,Myself,W,H)
	end)
	function JMod_MakeModel(self,mdl,mat,scale,col)
		local Mdl=ClientsideModel(mdl)
		if(mat)then Mdl:SetMaterial(mat) end
		if(scale)then Mdl:SetModelScale(scale,0) end
		if(col)then Mdl:SetColor(col) end
		Mdl:SetPos(self:GetPos())
		Mdl:SetParent(self)
		Mdl:SetNoDraw(true)
		return Mdl
	end
	function JMod_RenderModel(mdl,pos,ang,scale,color,mat,fullbright,translucency)
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
		if(fullbright)then render.SuppressEngingLighting(true) end
		if(translucenty)then render.SetBlend(translucency) end
		--mdl:SetLOD(8)
		mdl:DrawModel()
		render.SetColorModulation(R,G,B)
		render.ModelMaterialOverride(nil)
		render.SuppressEngineLighting(false)
		render.SetBlend(1)
	end
	net.Receive("JMod_MineColor",function()
		local Ent,NextColorCheck=net.ReadEntity(),0
		if not(IsValid(Ent))then return end
		local Frame=vgui.Create("DFrame")
		Frame:SetSize(200,200)
		Frame:SetPos(ScrW()*.4-200,ScrH()*.5)
		Frame:SetDraggable(true)
		Frame:ShowCloseButton(true)
		Frame:SetTitle("EZ Landmine")
		Frame:MakePopup()
		local Picker
		function Frame:Paint()
			BlurBackground(self)
			local Time=CurTime()
			if(NextColorCheck<Time)then
				if not(IsValid(Ent))then Frame:Close();return end
				NextColorCheck=Time+.25
				local Col=Picker:GetColor()
				net.Start("JMod_MineColor")
				net.WriteEntity(Ent)
				net.WriteColor(Color(Col.r,Col.g,Col.b))
				net.WriteBit(false)
				net.SendToServer()
			end
		end
		Picker=vgui.Create("DColorMixer",Frame)
		Picker:SetPos(5,25)
		Picker:SetSize(190,115)
		Picker:SetAlphaBar(false)
		Picker:SetPalette(false)
		Picker:SetWangs(false)
		Picker:SetColor(Ent:GetColor())
		local Butt=vgui.Create("DButton",Frame)
		Butt:SetPos(5,145)
		Butt:SetSize(190,50)
		Butt:SetText("ARM")
		function Butt:DoClick()
			local Col=Picker:GetColor()
			net.Start("JMod_MineColor")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r,Col.g,Col.b))
			net.WriteBit(true)
			net.SendToServer()
			Frame:Close()
		end
	end)
	net.Receive("JMod_ArmorColor",function()
		local Ent,NextColorCheck=net.ReadEntity(),0
		if not(IsValid(Ent))then return end
		local Frame=vgui.Create("DFrame")
		Frame:SetSize(200,300)
		Frame:SetPos(ScrW()*.4-200,ScrH()*.5)
		Frame:SetDraggable(true)
		Frame:ShowCloseButton(true)
		Frame:SetTitle("EZ Armor")
		Frame:MakePopup()
		local Picker
		function Frame:Paint()
			BlurBackground(self)
			local Time=CurTime()
			if(NextColorCheck<Time)then
				if not(IsValid(Ent))then Frame:Close();return end
				NextColorCheck=Time+.25
				local Col=Picker:GetColor()
				net.Start("JMod_ArmorColor")
				net.WriteEntity(Ent)
				net.WriteColor(Color(Col.r,Col.g,Col.b))
				net.WriteBit(false)
				net.SendToServer()
			end
		end
		Picker=vgui.Create("DColorMixer",Frame)
		Picker:SetPos(5,25)
		Picker:SetSize(190,215)
		Picker:SetAlphaBar(false)
		Picker:SetPalette(false)
		Picker:SetWangs(false)
		Picker:SetPalette(true)
		Picker:SetColor(Ent:GetColor())
		local Butt=vgui.Create("DButton",Frame)
		Butt:SetPos(5,245)
		Butt:SetSize(190,50)
		Butt:SetText("EQUIP")
		function Butt:DoClick()
			local Col=Picker:GetColor()
			net.Start("JMod_ArmorColor")
			net.WriteEntity(Ent)
			net.WriteColor(Color(Col.r,Col.g,Col.b))
			net.WriteBit(true)
			net.SendToServer()
			Frame:Close()
		end
	end)
	net.Receive("JMod_EZbuildKit",function()
		local Buildables=net.ReadTable()
		local Kit=net.ReadEntity()
		local Frame,W,H,Myself=vgui.Create("DFrame"),300,300,LocalPlayer()
		Frame:SetPos(40,80)
		Frame:SetSize(W,H)
		Frame:SetTitle("Select Item")
		Frame:SetVisible(true)
		Frame:SetDraggable(true)
		Frame:ShowCloseButton(true)
		Frame:MakePopup()
		Frame:Center()
		Frame.OnClose=function()
			--
		end
		function Frame:OnKeyCodePressed(key)
			if((key==KEY_Q)or(key==KEY_ESCAPE))then self:Close() end
		end
		function Frame:Paint()
			BlurBackground(self)
		end
		local Scroll=vgui.Create("DScrollPanel",Frame)
		Scroll:SetSize(W-15,H-35)
		Scroll:SetPos(10,30)
		---
		local Y=0
		for k,itemInfo in pairs(Buildables)do
			local Butt=Scroll:Add("DButton")
			Butt:SetSize(W-35,25)
			Butt:SetPos(0,Y)
			Butt:SetText("")
			function Butt:Paint(w,h)
				surface.SetDrawColor(0,0,0,100)
				surface.DrawRect(0,0,w,h)
				draw.SimpleText(itemInfo[1],"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
			end
			function Butt:DoClick()
				net.Start("JMod_EZbuildKit")
				net.WriteInt(k,8)
				net.SendToServer()
				Frame:Close()
			end
			Y=Y+30
		end
	end)
	net.Receive("JMod_EZworkbench",function()
		local Bench=net.ReadEntity()
		local Buildables=net.ReadTable()
		local Frame,W,H,Myself=vgui.Create("DFrame"),500,300,LocalPlayer()
		Frame:SetPos(40,80)
		Frame:SetSize(W,H)
		Frame:SetTitle("Select Item")
		Frame:SetVisible(true)
		Frame:SetDraggable(true)
		Frame:ShowCloseButton(true)
		Frame:MakePopup()
		Frame:Center()
		Frame.OnClose=function()
			--
		end
		function Frame:OnKeyCodePressed(key)
			if((key==KEY_Q)or(key==KEY_ESCAPE))then self:Close() end
		end
		function Frame:Paint()
			BlurBackground(self)
		end
		local Scroll=vgui.Create("DScrollPanel",Frame)
		Scroll:SetSize(W-15,H-35)
		Scroll:SetPos(10,30)
		---
		local Y=0
		for k,itemInfo in pairs(Buildables)do
			local Butt=Scroll:Add("DButton")
			Butt:SetSize(W-35,25)
			Butt:SetPos(0,Y)
			Butt:SetText("")
			function Butt:Paint(w,h)
				surface.SetDrawColor(0,0,0,100)
				surface.DrawRect(0,0,w,h)
				local msg=k..": "
				for nam,amt in pairs(itemInfo[2])do
					msg=msg..amt.." "..nam..", "
				end
				draw.SimpleText(msg,"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
			end
			function Butt:DoClick()
				net.Start("JMod_EZworkbench")
				net.WriteEntity(Bench)
				net.WriteString(k)
				net.SendToServer()
				Frame:Close()
			end
			Y=Y+30
		end
	end)
	net.Receive("JMod_Hint",function()
		notification.AddLegacy(net.ReadString(),NOTIFY_HINT,5)
	end)
	net.Receive("JMod_UniCrate",function()
		local box=net.ReadEntity()
		local items=net.ReadTable()
		local frame=vgui.Create("DFrame")
		frame:SetSize(200, 300)
		frame:SetTitle("G.P. Crate")
		frame:Center()
		frame:MakePopup()
		frame.OnClose=function() frame=nil end
		frame.Paint=function(self, w, h) BlurBackground(self) end
		local scrollPanel=vgui.Create("DScrollPanel", frame)
		scrollPanel:SetSize(190, 270)
		scrollPanel:SetPos(5, 30)
		local layout=vgui.Create("DIconLayout", scrollPanel)
		layout:SetSize(190, 270)
		layout:SetPos(0, 0)
		layout:SetSpaceY(5)
		for class, count in pairs(items) do
			local sent=scripted_ents.Get(class)
			local button=vgui.Create("DButton", layout)
			button:SetSize(190, 25)
			button:SetText("")
			function button:Paint(w,h)
				surface.SetDrawColor(0,0,0,100)
				surface.DrawRect(0,0,w,h)
				local msg=sent.PrintName .. " x" .. count
				draw.SimpleText(msg,"DermaDefault",5,3,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
			end
			button.DoClick=function()
				net.Start("JMod_UniCrate")
					net.WriteEntity(box)
					net.WriteString(class)
				net.SendToServer()
				frame:Close()
			end
		end
	end)
	net.Receive("JMod_EZtimeBomb",function()
		local ent=net.ReadEntity()
		local frame=vgui.Create("DFrame")
		frame:SetSize(300,120)
		frame:SetTitle("Time Bomb")
		frame:SetDraggable(true)
		frame:Center()
		frame:MakePopup()
		function frame:Paint()
			BlurBackground(self)
		end
		local bg=vgui.Create("DPanel",frame)
		bg:SetPos(90,30)
		bg:SetSize(200,25)
		function bg:Paint(w,h)
			surface.SetDrawColor(Color(255,255,255,100))
			surface.DrawRect(0,0,w,h)
		end
		local tim=vgui.Create("DNumSlider",frame)
		tim:SetText("Set Time")
		tim:SetSize(280,20)
		tim:SetPos(10,30)
		tim:SetMin(10)
		tim:SetMax(600)
		tim:SetValue(10)
		tim:SetDecimals(0)
		local apply=vgui.Create("DButton",frame)
		apply:SetSize(100, 30)
		apply:SetPos(100, 75)
		apply:SetText("ARM")
		apply.DoClick=function()
			net.Start("JMod_EZtimeBomb")
			net.WriteEntity(ent)
			net.WriteInt(tim:GetValue(),16)
			net.SendToServer()
			frame:Close()
		end
	end)
	net.Receive("JMod_EZarmorSync",function()
		local ply=net.ReadEntity()
		local tbl=net.ReadTable()
		local spd=net.ReadFloat()
		if not(IsValid(ply))then return end
		ply.EZarmor=tbl
		ply.EZarmorModels=ply.EZarmorModels or {}
	end)
end
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