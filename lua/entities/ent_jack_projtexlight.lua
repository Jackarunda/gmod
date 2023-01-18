
AddCSLuaFile()

DEFINE_BASECLASS( "ent_jack_experimental_light_base" )

ENT.Spawnable =	false
ENT.AdminOnly =	true

ENT.PrintName =	"ProjectedTexture Light"

function ENT:SetupDataTables()

	self:NetworkVar( "Bool",	0,	"ActiveState")
	self:NetworkVar( "Bool",	2,	"DrawSprite")
	self:NetworkVar( "Bool",	3,	"Shadows")
	self:NetworkVar( "Float",	0,	"Brightness")
	self:NetworkVar( "Float",	1,	"FarZ")
	self:NetworkVar( "Float",	2,	"NearZ")
	self:NetworkVar( "Vector",	0,	"LightColor")
	self:NetworkVar( "Bool", 1, "Flicker")

	if ( SERVER ) then

		self:SetActiveState( true )
		self:SetDrawSprite( true )
		self:SetShadows( true )
		self:SetBrightness( 2000 )
		self:SetFarZ( 20000 )
		self:SetNearZ( 4 )
		self:SetLightColor( Vector( 255, 255, 255 ) )

	end

end

if ( SERVER ) then

	function ENT:Initialize()

		BaseClass.Initialize( self )

	end

end

if ( CLIENT ) then

	local fov=math.deg( math.atan( 512/511 ) )*2
	local lx="effects/lx"

	function ENT:UpdateProjectedTexture( L, pos, ang, Shadows, FarZ, NearZ, LightColor, Brightness )

		L:SetPos( pos )
		L:SetAngles( ang )
		L:SetEnableShadows( Shadows )
		L:SetFarZ( FarZ )
		L:SetNearZ( NearZ )
		L:SetFOV( fov )
		L:SetOrthographic( false )
		L:SetColor( LightColor )
		L:SetBrightness( Brightness )
		L:SetTexture( lx )

		-- performance parameters
		--L:SetShadowDepthBias(.001)
		--L:SetShadowFilter(0)
		--L:SetShadowSlopeScaleDepthBias(2)

		L:Update()
	end

	local EMPTY_ANG=Angle( 0, 0, 0 )

	function ENT:CreateAllProjectedTextures()

		local Shadows=self:BoolToString( self:GetShadows() )
		local FarZ=self:GetFarZ()
		local NearZ=self:GetNearZ()
		local LightColor=self:VectorToColor( self:GetLightColor() )
		local Brightness=self:GetBrightness()

		local pos=self:GetPos() + Vector(0, 0, 10)
		local ang=self:GetAngles()

		local L=ProjectedTexture()

		if ( IsValid( L ) ) then

			self.FR=L

			self:UpdateProjectedTexture( L, pos, ang, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		local up=ang:Up()

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( up, 180 )

		L=ProjectedTexture()

		if ( IsValid( L ) ) then

			self.BK=L

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( up, 90 )

		L=ProjectedTexture()

		if ( IsValid( L ) ) then

			self.RI=L

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( up, 270 )

		L=ProjectedTexture()

		if ( IsValid( L ) ) then

			self.LF=L

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		local ri=ang:Right()

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( ri, 90 )

		L=ProjectedTexture()

		if ( IsValid( L ) ) then

			self.UP=L

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( ri, 270 )

		L=ProjectedTexture()

		if ( IsValid( L ) ) then

			self.DN=L

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

	end

	ENT.NextUpdate = 0
	function ENT:UpdateAllProjectedTextures()
		local Time = CurTime()
		if (self.NextUpdate > Time) then return end
		self.NextUpdate = Time + .01

		local Shadows=self:GetShadows()
		local FarZ=self:GetFarZ()
		local NearZ=self:GetNearZ()
		local LightColor=self:VectorToColor( self:GetLightColor() )
		local Brightness=self:GetBrightness()
		if (self:GetFlicker()) then Brightness = Brightness * math.Rand(.9, 1.1) end

		local pos=self:GetPos()
		local ang=self:GetAngles()

		local L=self.FR

		if ( IsValid( L ) ) then

			self:UpdateProjectedTexture( L, pos, ang, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		local up=ang:Up()

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( up, 180 )

		L=self.BK

		if ( IsValid( L ) ) then

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( up, 90 )

		L=self.RI

		if ( IsValid( L ) ) then

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( up, 270 )

		L=self.LF

		if ( IsValid( L ) ) then

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		local ri=ang:Right()

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( ri, 90 )

		L=self.UP

		if ( IsValid( L ) ) then

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

		EMPTY_ANG:Set( ang )
		EMPTY_ANG:RotateAroundAxis( ri, 270 )

		L=self.DN

		if ( IsValid( L ) ) then

			self:UpdateProjectedTexture( L, pos, EMPTY_ANG, Shadows, FarZ, NearZ, LightColor, Brightness )

		end

	end

	function ENT:RemoveAllProjectedTextures()

		local L=self.FR

		if ( IsValid( L ) ) then

			L:Remove()

			self.FR=NULL

		end

		L=self.BK

		if ( IsValid( L ) ) then

			L:Remove()

			self.BK=NULL

		end

		L=self.RI

		if ( IsValid( L ) ) then

			L:Remove()

			self.RI=NULL

		end

		L=self.LF

		if ( IsValid( L ) ) then

			L:Remove()

			self.LF=NULL

		end

		L=self.UP

		if ( IsValid( L ) ) then

			L:Remove()

			self.UP=NULL

		end

		L=self.DN

		if ( IsValid( L ) ) then

			L:Remove()

			self.DN=NULL

		end

	end

	function ENT:Initialize()

		self.PixVis=util.GetPixelVisibleHandle()

		if ( self:GetActiveState() ) then

			self.WasActive=true

			self:CreateAllProjectedTextures()

		else

			self.WasActive=false

		end

	end

	function ENT:Think()

		if ( self:GetActiveState() ) then

			if ( self.WasActive ) then

				self:UpdateAllProjectedTextures()

			else

				self.WasActive=true

				self:CreateAllProjectedTextures()

			end

		elseif ( self.WasActive ) then

			self.WasActive=false

			self:RemoveAllProjectedTextures()

		end
	end

	function ENT:OnRemove()

		self:RemoveAllProjectedTextures()

	end

	local spritemat=Material( "sprites/light_ignorez" )

	function ENT:Draw()

		if ( ( halo.RenderedEntity() ~= self ) and self:GetActiveState() and self:GetDrawSprite() ) then

			local pos=self:GetPos()

			local Visible=util.PixelVisible( pos, 4, self.PixVis )

			if ( ( Visible ) and ( Visible > 0.1 ) ) then

				local c=self:GetLightColor()
				local i=self:GetBrightness()

				local s=( i/0.25 ) ^ 0.5*8
				s=s*Visible

				if (self:GetFlicker()) then s = s * math.Rand(.5, 1.5) end

				render.SetMaterial( spritemat )
				render.DrawSprite( pos, s, s, Color( self:ColorC( c.x ), self:ColorC( c.y ), self:ColorC( c.z ), math.Round( Visible*255 ) ) )

			end

		end

	end

end
