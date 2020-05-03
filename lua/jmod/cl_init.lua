JMOD_NUKEFLASH_ENDTIME=0
JMOD_NUKEFLASH_POS=nil
JMOD_NUKEFLASH_RANGE=0
JMOD_NUKEFLASH_INTENSITY=1
JMOD_NUKEFLASH_SMOKE_ENDTIME=0
JMOD_WIND=JMOD_WIND or Vector(0,0,0)

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
    local Time=CurTime()
    local ply,DrawNVGlamp=LocalPlayer(),false
    if not(ply:ShouldDrawLocalPlayer())then
        if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.Effects))then
            if(ply.EZarmor.Effects.nightVision)then
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
    JMOD_WIND=JMOD_WIND+WindChange/10
    if(JMOD_WIND:Length()>1)then
        JMOD_WIND:Normalize()
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
    [ "$basetexture" ]    = "sprites/spotlight",
    [ "$additive" ]        = "1",
    [ "$vertexcolor" ]    = "1",
    [ "$vertexalpha" ]    = "1",
})
local GlowSprite=Material("sprites/mat_jack_basicglow")
hook.Add("PostDrawTranslucentRenderables","JMOD_POSTDRAWTRANSLUCENTRENDERABLES",function() -- cache this
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

net.Receive("JMod_LuaConfigSync",function()
    JMOD_LUA_CONFIG=JMOD_LUA_CONFIG or {}
    JMOD_LUA_CONFIG.ArmorOffsets=net.ReadTable()
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

net.Receive("JMod_EZarmorSync",function()
    local ply=net.ReadEntity()
    local tbl=net.ReadTable()
    local spd=net.ReadFloat()
    if not(IsValid(ply))then return end
    ply.EZarmor=tbl
    ply.EZarmorModels=ply.EZarmorModels or {}
end)

local FRavg,FRcount=0,0
function JMod_MeasureFramerate()
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
    if(ent:IsWorld())then return false end
    if((ent:IsPlayer())or(ent:IsOnFire()))then return true end
    if(ent:IsNPC())then
        if((ent.Health)and(ent:Health()>0))then return true end
    elseif(ent:IsRagdoll())then
        local Time=CurTime()
        if not(ent.EZWHOTcoldTime)then ent.EZWHOTcoldTime=Time+30 end
        return ent.EZWHOTcoldTime>Time
    elseif(ent:IsVehicle())then
        return ent:GetVelocity():Length()>=400
    end
    return false
end

hook.Add("PostDrawOpaqueRenderables","JMOD_POSTOPAQUERENDERABLES",function()
    local ply,Time=LocalPlayer(),CurTime()
    if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.Effects)and(ply.EZarmor.Effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
        DrawColorModify({
            ["$pp_colour_addr"]=0,
            ["$pp_colour_addg"]=0,
            ["$pp_colour_addb"]=0,
            ["$pp_colour_brightness"]=0,
            ["$pp_colour_contrast"]=.2,
            ["$pp_colour_colour"]=1,
            ["$pp_colour_mulr"]=0,
            ["$pp_colour_mulg"]=0,
            ["$pp_colour_mulb"]=0
        })
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
                    targ:DrawModel()
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
    if(JMOD_NUKEFLASH_SMOKE_ENDTIME>Time)then
        local Frac=((JMOD_NUKEFLASH_SMOKE_ENDTIME-Time)/30)^.15
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
    if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.Effects)and(ply.EZarmor.Effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
        render.FogMode(0)
        return true
    end
    if(JMOD_NUKEFLASH_SMOKE_ENDTIME>Time)then
        local Frac=((JMOD_NUKEFLASH_SMOKE_ENDTIME-Time)/30)^.15
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
    if((ply:Alive())and(ply.EZarmor)and(ply.EZarmor.Effects)and(ply.EZarmor.Effects.thermalVision)and not(ply:ShouldDrawLocalPlayer()))then
        render.FogMode(0)
        return true
    end
    if(JMOD_NUKEFLASH_SMOKE_ENDTIME>Time)then
        local Frac=((JMOD_NUKEFLASH_SMOKE_ENDTIME-Time)/30)^.15
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
    if((ply.EZarmor)and(ply.EZarmor.Effects.teamComms)and(JMod_PlayersCanComm(LocalPlayer(),ply)))then
        surface.PlaySound("snds_jack_gmod/radio_start.wav")
    end
end)

hook.Add("OnPlayerChat","JMOD_ONPLAYERCHAT",function(ply, text, isTeam, isDead)
    if not(IsValid(ply))then return end
    if not(ply:Alive())then return end
    if not(LocalPlayer():Alive())then return end
    if((ply.EZarmor)and(ply.EZarmor.Effects.teamComms)and(JMod_PlayersCanComm(LocalPlayer(),ply)))then
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
    if((ply.EZarmor)and(ply.EZarmor.Effects.teamComms)and(JMod_PlayersCanComm(LocalPlayer(),ply)))then
        CommNoise()
    end
end)

concommand.Add("jacky_supershadows",function(ply,cmd,args)
	RunConsoleCommand("r_projectedtexture_filter",0)
	RunConsoleCommand("r_flashlightdepthres",16384)
	RunConsoleCommand("mat_depthbias_shadowmap",.0000005)
	RunConsoleCommand("mat_slopescaledepthbias_shadowmap",2)
	print("super shadows enabled, have fun with the lag")
end)

concommand.Add("jmod_showgasparticles",function(ply,cmd,args)
    if((IsValid(ply))and not(ply:IsSuperAdmin()))then return end
    ply.EZshowGasParticles=not (ply.EZshowGasParticles or false)
    print("gas particle display: "..tostring(ply.EZshowGasParticles))
end)

net.Receive("JMod_NuclearBlast",function()
    local pos,renj,intens=net.ReadVector(),net.ReadFloat(),net.ReadFloat()
    JMOD_NUKEFLASH_ENDTIME=CurTime()+10
    JMOD_NUKEFLASH_POS=pos
    JMOD_NUKEFLASH_RANGE=renj
    JMOD_NUKEFLASH_INTENSITY=intens
    if(intens>1)then JMOD_NUKEFLASH_SMOKE_ENDTIME=CurTime()+30 end
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
