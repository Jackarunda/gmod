AddCSLuaFile()
include("JI_DS_Shared.lua")
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
		return -1
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
	end
	hook.Add("PostPlayerDraw","JackyArmorPlayerDraw",JackyArmorPlayerDraw)
end