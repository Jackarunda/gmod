include('shared.lua')

SWEP.PrintName			= "M112 Demolition Block"			// 'Nice' Weapon name (Shown on HUD)	
SWEP.Slot				= 4							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.DrawWeaponInfoBox =false
SWEP.DrawCrosshair	 =false --crosshairs are for big loose pussies
SWEP.SwayScale=4
SWEP.BobScale=4
SWEP.BounceWeaponIcon=false

// Override this in your SWEP to set the icon in the weapon selection
SWEP.WepSelectIcon	= surface.GetTextureID("weapons/wep_jack_detpack_WSI")

/*---------------------------------------------------------
	Name: SWEP:CustomAmmoDisplay()
	Desc: Have to override this so you GET an ammocounter
----------------------------------------------------------*/
function SWEP:CustomAmmoDisplay()
end

function SWEP:ViewModelDrawn()
	self:SCKViewModelDrawn()
end

function SWEP:DrawWorldModel()
	self:SCKDrawWorldModel()
end

/*-----------------------------------------------------------
	for sprinting
	and holding your hand out when you're gonna throw
------------------------------------------------------------*/
local MoveAmount=0
function SWEP:GetViewModelPosition(pos,ang)
	local Up=ang:Up()
	local Right=ang:Right()
	local Forward=ang:Forward()

	if(self.Owner:KeyDown(IN_SPEED))then
		MoveAmount=MoveAmount+0.75
	else
		MoveAmount=MoveAmount-0.75
	end
	if(MoveAmount>15)then
		MoveAmount=15
	elseif(MoveAmount<0)then
		MoveAmount=0
	end
	pos=pos+Right*-MoveAmount
	pos=pos+Up*-MoveAmount
	return pos,ang
end