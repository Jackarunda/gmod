//local Shit=Material("models/entities/mat_jack_apersbomb")
include('shared.lua')
function ENT:Initialize()
	--herp
end
function ENT:Draw()
	self.Entity:DrawModel()
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_terminal","Sentry Terminal")
--[[---------------------------------------
--	 Super Special Secret w00tzorz	 --
---------------------------------------]]--
local Strobe=surface.GetTextureID("sprites/mat_jack_strobe")
local White=Material("sprites/mat_jack_thermalglow")
local ModeNames={[0]="VISL",[1]="LOWL",[2]="WHOT"}
local Shine=Material("models/debug/debugwhite")
local NVTab={
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=0,
	["$pp_colour_contrast"]=10,
	["$pp_colour_colour"]=0,
	["$pp_colour_mulr"]=2,
	["$pp_colour_mulg"]=2,
	["$pp_colour_mulb"]=2
}
local WHOTBackTab={
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=-.4,
	["$pp_colour_contrast"]=.5,
	["$pp_colour_colour"]=0,
	["$pp_colour_mulr"]=0,
	["$pp_colour_mulg"]=0,
	["$pp_colour_mulb"]=0
}
local AnotherTab={
	["$pp_colour_addr"]=0,
	["$pp_colour_addg"]=0,
	["$pp_colour_addb"]=0,
	["$pp_colour_brightness"]=0,
	["$pp_colour_contrast"]=1,
	["$pp_colour_colour"]=0,
	["$pp_colour_mulr"]=0,
	["$pp_colour_mulg"]=0,
	["$pp_colour_mulb"]=0
}
local function CalcDatView(ply,pos,ang,fov,nearZ,farZ)
	if(IsValid(ply.JackaSentryControl))then
		local Self=ply:GetViewEntity()
		if(Self==ply)then ply:ConCommand("jacky_reset_terminal_view") end
		local AngPos=Self:GetAttachment(1)
		if(AngPos)then
			local Origin=AngPos.Pos+AngPos.Ang:Right()+AngPos.Ang:Up()*5
			return GAMEMODE:CalcView(ply,Origin,AngPos.Ang,fov)
		end
	end
end
hook.Add("CalcView","JackaSentryCalcView",CalcDatView)
local function ShowDatPly(ply)
	if(ply.JackaSentryControl)then return true end
end
hook.Add("ShouldDrawLocalPlayer","JackaSentryShowPlayer",ShowDatPly)
local function Hud()
	if(LocalPlayer().JackaSentryControl)then return false end
end
hook.Add("HUDShouldDraw","JackyHUDDraw",Hud)
local function JackaDraw()
	local Ply=LocalPlayer()
	if((Ply.JackaSentryControl)and(Ply:GetViewEntity()==Ply.JackaSentryControl))then
		local ViewMode=Ply.JackaSentryControl:GetDTInt(3)
		if(ViewMode==1)then
			DrawColorModify(NVTab)
			DrawMotionBlur(.1,1,0)
		elseif(ViewMode==2)then
			DrawColorModify(AnotherTab)
			DrawToyTown(2,ScrH())
		end
		DrawMaterialOverlay("models/props_c17/fisheyelens",.03)
		local W=ScrW()
		local H=ScrH()
		DrawMaterialOverlay("sprites/mat_jack_turretaim",1)
		local Dist="N/A"
		local InitialPos=Ply.JackaSentryControl:GetPos()+Ply.JackaSentryControl:GetUp()*30
		local Tr=util.QuickTrace(InitialPos,Ply.JackaSentryControl:GetAttachment(1).Ang:Forward()*30000,{Ply.JackaSentryControl})
		if(Tr.Hit)then
			Dist=tostring(math.Round((InitialPos-Tr.HitPos):Length()*.01905))
		end
		draw.DrawText(Dist,"CloseCaption_Normal",W/2+100,H/2,Color(0,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText(tostring(Ply.JackaSentryControl:GetDTInt(2)),"CloseCaption_Normal",W-100,H-60,Color(0,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText(tostring(Ply.JackaSentryTerminal:GetDTInt(0)),"CloseCaption_Normal",W-100,H-80,Color(0,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText(ModeNames[ViewMode],"CloseCaption_Normal",W-100,50,Color(0,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText(Ply.JackaSentryControl.LabelText,"CloseCaption_Normal",60,H-60,Color(0,255,255),TEXT_ALIGN_LEFT)
		draw.DrawText(tostring(Ply.JackaSentryControl:GetDTInt(4)),"CloseCaption_Normal",W/2-100,H/2,Color(0,255,255),TEXT_ALIGN_CENTER)
		surface.SetDrawColor(Color(255,255,255,255))
		for key,playa in pairs(player.GetAll())do
			local Tag=playa:GetNetworkedInt("JackyIFFTag")
			if((Tag)and(not(Tag==0))and(Ply.JackaSentryControl.IFFTags)and(table.HasValue(Ply.JackaSentryControl.IFFTags,Tag)))then
				local FotPos=playa:GetPos():ToScreen()
				local HedPos=(playa:GetPos()+vector_up*80):ToScreen()
				local Siz=FotPos.y-HedPos.y
				surface.SetTexture(Strobe)
				surface.SetDrawColor(Color(0,255,255,(math.sin(CurTime()*20)*127)+127))
				surface.DrawTexturedRect(FotPos.x-Siz/2,FotPos.y-Siz,Siz,Siz)
			end
		end
		for i=1,H do
			surface.SetDrawColor(Color(127,127,127,math.random(1,50)))
			surface.DrawLine(0,i,W,i)
		end
	end
end
hook.Add("RenderScreenspaceEffects","JackaSentryScreenspace",JackaDraw)
local function JackaRender()
	local Ply=LocalPlayer()
	if((Ply.JackaSentryControl)and(Ply:GetViewEntity()==Ply.JackaSentryControl))then
		local Mode=Ply.JackaSentryControl:GetDTInt(3)
		if(Mode==2)then
			DrawColorModify(WHOTBackTab)
			for key,targ in pairs(ents.GetAll())do
				local Ja=(targ:IsPlayer())or(targ:IsNPC())
				if((Ja)or(targ:IsVehicle())or(targ:IsOnFire())or(string.find(string.lower(targ:GetClass()),"ragdoll"))or(targ:GetClass()=="ent_jack_generator"))then
					if((Ja)and(targ:IsEffectActive(EF_NODRAW)))then
						--nope
					else
						render.ModelMaterialOverride(Shine)
						render.SuppressEngineLighting(true)
						render.SetColorModulation(.8,.8,.8)
						targ:DrawModel()
						render.SetColorModulation(1,1,1)
						render.SuppressEngineLighting(false)
						render.ModelMaterialOverride(nil)
					end
				end
			end
			--[[ --ill keep this code since stencils are really damn cool
			render.ClearStencil()
			render.SetStencilEnable(true)
			render.SuppressEngineLighting(true)
			render.SetStencilWriteMask(255)
			render.SetStencilTestMask(255)
			render.SetStencilReferenceValue(15)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetBlend(0)
			-- draw the things you want
			render.SetBlend(1)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetMaterial(White)
			render.DrawScreenQuad()
			render.SuppressEngineLighting(false)
			render.SetStencilEnable(false)
			--]]
		elseif(Mode==1)then
			local PosAng=Ply.JackaSentryControl:GetAttachment(1)
			--[[
			local Tr=util.QuickTrace(PosAng.Pos,PosAng.Ang:Forward()*40000,{Ply.JackaSentryControl})
			if(Tr.Hit)then
				local Light=DynamicLight(Ply:EntIndex())
				if(Light)then
					Light.Pos=Tr.HitPos+Tr.HitNormal*100
					Light.Size=100000
					Light.b=1
					Light.g=1
					Light.r=1
					Light.Decay=100
					Light.Brightness=.01
					Light.DieTime=CurTime()+.1
				end
			end
			--]]
			local Light=DynamicLight(Ply.JackaSentryControl:EntIndex())
			if(Light)then
				Light.Pos=PosAng.Pos
				Light.Dir=PosAng.Ang:Forward()
				Light.Size=100000
				Light.b=1
				Light.g=1
				Light.r=1
				Light.Decay=100
				Light.Brightness=.01
				Light.DieTime=CurTime()+.1
			end
		end
	end
end
hook.Add("PostDrawOpaqueRenderables","JackaPostOpaque",JackaRender)