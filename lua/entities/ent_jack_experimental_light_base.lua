
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable =		false
ENT.DisableDuplicator =	true
ENT.Editable =		false

ENT.RenderGroup =	RENDERGROUP_TRANSLUCENT

util.PrecacheModel( "models/error.mdl" )

function ENT:ColorC( val )

	return math.Clamp( math.Round( val ), 0, 255 )

end

function ENT:ColorToString( rgb )

	return tostring( self:ColorC( rgb.r ) ).." "..tostring( self:ColorC( rgb.g ) ).." "..tostring( self:ColorC( rgb.b ) )

end

function ENT:ColorIntensityToString( rgb, i )

	local i_int=math.Round( i )

	if ( i_int < 1 ) then return "0 0 0 0" end

	return self:ColorToString( rgb ).." "..tostring( i_int )

end

function ENT:BoolToString( b )

	if ( b ) then

		return "1"

	else

		return "0"

	end

end

function ENT:VectorToColor( vec )

	return Color( self:ColorC( vec.x ), self:ColorC( vec.y ), self:ColorC( vec.z ) )

end

if ( SERVER ) then

	function ENT:Initialize()

		self:SetModel( "models/error.mdl" )
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
		self:DrawShadow( false )

		local min, max=Vector( -2, -2, -2 ), Vector( 2, 2, 2 )

		self:PhysicsInitBox( min, max )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:SetCollisionBounds( min, max )

		local physobj=self:GetPhysicsObject()

		if ( IsValid( physobj ) ) then

			physobj:EnableGravity( false )
			physobj:Wake()

		end

	end

end

if ( CLIENT ) then

	--

end
