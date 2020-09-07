local MskSndLops,MaskMats={},{}
hook.Add("HUDPaintBackground","JMOD_HUDBG",function()
	local ply,Play=LocalPlayer(),false
	if(ply.EZarmor)then
		local Alive,ThirdPerson=ply:Alive(),ply:ShouldDrawLocalPlayer()
		if((ply.EZarmor.mskmat)and(Alive)and not(ThirdPerson))then
			local Mat=MaskMats[ply.EZarmor.mskmat]
			if not(Mat)then
				Mat=Material(ply.EZarmor.mskmat)
				MaskMats[ply.EZarmor.mskmat]=Mat
			end
			local Col=render.GetLightColor(EyePos())
			surface.SetMaterial(Mat)
			surface.SetDrawColor(Col.r*255,Col.g*255,Col.b*255,255)
			surface.DrawTexturedRect(-1,-1,ScrW()+2,ScrH()+2)
			surface.DrawTexturedRect(-1,-1,ScrW()+2,ScrH()+2)
			surface.DrawTexturedRect(-1,-1,ScrW()+2,ScrH()+2)
		end
		Play=(Alive)and(ply.EZarmor.sndlop)and not(ThirdPerson)
		if(Play)then
			if not(MskSndLops[ply.EZarmor.sndlop])then
				MskSndLops[ply.EZarmor.sndlop]=CreateSound(ply,ply.EZarmor.sndlop)
				MskSndLops[ply.EZarmor.sndlop]:Play()
			elseif(not(MskSndLops[ply.EZarmor.sndlop]:IsPlaying()))then
				MskSndLops[ply.EZarmor.sndlop]:Play()
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

local function DrawNoise(amt,alpha)
	local W,H=ScrW(),ScrH()
	for i=0,amt do
		local Bright=math.random(0,255)
		surface.SetDrawColor(Bright,Bright,Bright,alpha)
		local X,Y=math.random(0,W),math.random(0,H)
		surface.DrawRect(X,Y,1,1)
	end
end

local blurMat2,Dynamic2=Material("pp/blurscreen"),0
local function BlurScreen()
	local layers,density,alpha=1,.4,255
	surface.SetDrawColor(255,255,255,alpha)
	surface.SetMaterial(blurMat2)
	local FrameRate,Num,Dark=1/FrameTime(),3,150
	for i=1,Num do
		blurMat2:SetFloat("$blur",(i/layers)*density*Dynamic2)
		blurMat2:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0,0,ScrW(),ScrH())
	end
	Dynamic2=math.Clamp(Dynamic2+(1/FrameRate)*7,0,1)
end

local GoggleDarkness,GogglesWereOn,OldLightPos=0,false,Vector(0,0,0)
local ThermalGlowMat=Material("models/debug/debugwhite")
local blurMaterial = Material ('pp/bokehblur')
hook.Add("RenderScreenspaceEffects","JMOD_SCREENSPACE",function()
	local ply,FT,SelfPos,Time,W,H=LocalPlayer(),FrameTime(),EyePos(),CurTime(),ScrW(),ScrH()
	local AimVec=ply:GetAimVector()
	--CreateClientLag(10000) -- for debugging the effect at low framerates
	--JMod_MeasureFramerate()
	if not(ply:ShouldDrawLocalPlayer())then
		if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.effects))then
			if(ply.EZarmor.blackvision)then
				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect(-1,-1,W+2,H+2)
				draw.SimpleText("vision device is dead; please recharge","JMod-Display",W/2,H*.8,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				--GoggleDarkness=100
			elseif(ply.EZarmor.effects.nightVision)then
				if not(GogglesWereOn)then GogglesWereOn=true;GoggleDarkness=100 end
				DrawColorModify({
					["$pp_colour_addr"]=0,
					["$pp_colour_addg"]=0,
					["$pp_colour_addb"]=0,
					["$pp_colour_brightness"]=.01,
					["$pp_colour_contrast"]=7,
					["$pp_colour_colour"]=0,
					["$pp_colour_mulr"]=0,
					["$pp_colour_mulg"]=0,
					["$pp_colour_mulb"]=0
				})
				DrawColorModify({
					["$pp_colour_addr"]=0,
					["$pp_colour_addg"]=.1,
					["$pp_colour_addb"]=0,
					["$pp_colour_brightness"]=0,
					["$pp_colour_contrast"]=1,
					["$pp_colour_colour"]=1,
					["$pp_colour_mulr"]=0,
					["$pp_colour_mulg"]=0,
					["$pp_colour_mulb"]=0
				})
				if not(ply.EZflashbanged)then DrawMotionBlur(FT*50,.8,.01) end
				--DrawNoise(1000,255)
				--[[
				local Pos=SelfPos-AimVec*20
				local Tr,TwoLights=util.QuickTrace(SelfPos,AimVec*10000,ply),false
				if(Tr.Hit)then
					local Dist=Tr.HitPos:Distance(SelfPos)
					if(Dist>500)then
						TwoLights=true
						Pos=Tr.HitPos+Tr.HitNormal*100
					end
				end
				OldLightPos=LerpVector(FT*20,OldLightPos,Pos)
				local Light=DynamicLight(ply:EntIndex())
				if(Light)then
					Light.Pos=OldLightPos
					Light.r=1
					Light.g=1
					Light.b=1
					Light.Brightness=.001
					Light.Size=5000
					Light.Decay=500
					Light.DieTime=CurTime()+FT*10
					Light.Style=0
				end
				if(TwoLights)then
					local Light2=DynamicLight(ply:EntIndex()+1)
					if(Light2)then
						Light2.Pos=SelfPos-AimVec*20
						Light2.r=1
						Light2.g=1
						Light2.b=1
						Light2.Brightness=.001
						Light2.Size=5000
						Light2.Decay=500
						Light2.DieTime=CurTime()+FT*10
						Light2.Style=0
					end
				end
				--]]
			elseif(ply.EZarmor.effects.thermalVision)then
				if not(GogglesWereOn)then GogglesWereOn=true;GoggleDarkness=100 end
				DrawColorModify({
					["$pp_colour_addr"]=0,
					["$pp_colour_addg"]=0,
					["$pp_colour_addb"]=0,
					["$pp_colour_brightness"]=0,
					["$pp_colour_contrast"]=1,
					["$pp_colour_colour"]=0,
					["$pp_colour_mulr"]=0,
					["$pp_colour_mulg"]=0,
					["$pp_colour_mulb"]=0
				})
				if not(ply.EZflashbanged)then BlurScreen() end
			else
				if(GogglesWereOn)then GogglesWereOn=false;GoggleDarkness=100 end
			end
		else
			if(GogglesWereOn)then GogglesWereOn=false;GoggleDarkness=100 end
		end
		if(GoggleDarkness>0)then
			local Alpha=255*(GoggleDarkness/100)^.5
			surface.SetDrawColor(0,0,0,Alpha)
			surface.DrawRect(-1,-1,W+2,H+2)
			surface.DrawRect(-1,-1,W+2,H+2)
			surface.DrawRect(-1,-1,W+2,H+2)
			GoggleDarkness=math.Clamp(GoggleDarkness-FT*100,0,100)
		end
		if(ply.EZflashbanged)then
			if(ply:Alive())then
				DrawMotionBlur(.001,math.Clamp(ply.EZflashbanged/20,0,1),.01)
				ply.EZflashbanged=ply.EZflashbanged-7*FT
			else
				ply.EZflashbanged=0
			end
			if(ply.EZflashbanged<=0)then ply.EZflashbanged=nil end
		end
	end
	if(JMOD_NUKEFLASH_ENDTIME>Time)then
		local Dist=EyePos():Distance(JMOD_NUKEFLASH_POS)
		if(Dist<JMOD_NUKEFLASH_RANGE)then
			local TimeFrac,DistFrac=(JMOD_NUKEFLASH_ENDTIME-Time)/10,1-Dist/JMOD_NUKEFLASH_RANGE
			local Frac=TimeFrac*DistFrac
			DrawColorModify({
				["$pp_colour_addr"]=Frac*.5*JMOD_NUKEFLASH_INTENSITY,
				["$pp_colour_addg"]=0,
				["$pp_colour_addb"]=0,
				["$pp_colour_brightness"]=Frac*.5*JMOD_NUKEFLASH_INTENSITY,
				["$pp_colour_contrast"]=1+Frac*.5,
				["$pp_colour_colour"]=1,
				["$pp_colour_mulr"]=0,
				["$pp_colour_mulg"]=0,
				["$pp_colour_mulb"]=0
			})
		end
	end
	if(ply.activeBlindness)then
		if(ply.activeBlindness > 0) then
			DrawColorModify({
				["$pp_colour_addr"]=0,
				["$pp_colour_addg"]=0,
				["$pp_colour_addb"]=0,
				["$pp_colour_brightness"]=math.Clamp(-(ply.activeBlindness/111.11),-.9,0),
				["$pp_colour_contrast"]=1,
				["$pp_colour_colour"]=1,
				["$pp_colour_mulr"]=0,
				["$pp_colour_mulg"]=0,
				["$pp_colour_mulb"]=0
			})
			render.UpdateScreenEffectTexture()
			blurMaterial:SetTexture("$BASETEXTURE", render.GetScreenEffectTexture())
			blurMaterial:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
			
			blurMaterial:SetFloat("$size", math.Clamp(ply.activeBlindness/10,0,10))
			blurMaterial:SetFloat("$focus", 1)
			blurMaterial:SetFloat("$focusradius", 2)
			
			render.SetMaterial(blurMaterial)
			render.DrawScreenQuad()
		end
	end
	ply.blindnessChange = ply.differenceBlindness * FrameTime()
	ply.activeBlindness = ply.activeBlindness + ply.blindnessChange
	if (ply.differenceBlindness < 0) then
		if (ply.activeBlindness < ply.targetBlindness) then
			ply.activeBlindness = ply.targetBlindness
		end
	elseif (ply.differenceBlindness > 0) then
		if (ply.activeBlindness > ply.targetBlindness) then
			ply.activeBlindness = ply.targetBlindness
		end
	end
	ply.activeBlindness = math.Clamp(ply.activeBlindness,0,100)
end)
