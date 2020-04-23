
include('shared.lua')

language.Add("npc_bullseye","Target")
language.Add("worldspawn","World")
language.Add("ent_jack_target","Target")

local matBall=Material( "sprites/mat_jack_circle" )

function ENT:Initialize()
end

function ENT:Draw()

	local pos=self.Entity:GetPos()

	render.SetMaterial( matBall )

	local lcolor=render.GetLightColor( self:LocalToWorld(self:OBBCenter()) )*2

	local white=Vector(0,0,0)
	white.x=255*math.Clamp( lcolor.x, 0, 1 )
	white.y=255*math.Clamp( lcolor.y, 0, 1 )
	white.z=255*math.Clamp( lcolor.z, 0, 1 )
	
	local red=Vector(0,0,0)
	red.x=255* math.Clamp( lcolor.x, 0, 1 )
	red.y=0*math.Clamp( lcolor.y, 0, 1 )
	red.z=0*math.Clamp( lcolor.z, 0, 1 )

	render.DrawSprite( pos, 12, 12, Color( red.x, red.y, red.z, 255 ) )
	render.DrawSprite( pos, 8, 8, Color( white.x, white.y, white.z, 255 ) )
	render.DrawSprite( pos, 4, 4, Color( red.x, red.y, red.z, 255 ) )

end

function ENT:OnRemove()
end

//killicon.Add("ent_jack_geigercounter","vgui/killicons/jack_explosion_KI",Color(255,255,255,255))



