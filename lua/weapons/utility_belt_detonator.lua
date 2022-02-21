AddCSLuaFile()

SWEP.PrintName	= "Belt Detonator"

SWEP.Author		= "8Z"
SWEP.Purpose	= "Detonates all explosives you have on your belt"
SWEP.Instructions = "Left click: Toggle Dead Man's Switch (explode on death)\nRight click: Detonate instantly\nReload + Right click: Drop and trigger"

SWEP.Spawnable	= true
SWEP.UseHands	= true
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair= false

SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= "models/weapons/w_defuser.mdl"

SWEP.DrawWorldModel = false

SWEP.ViewModelFOV	= 70
SWEP.Slot			= 4
SWEP.SlotPos		= 1

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DeadManSwitch = false

function SWEP:Initialize()
	self:SetHoldType("slam")
end

function SWEP:Holster()
    --[[
    if self.DeadManSwitch then -- The timer ensures it doesn't run on player death
        local ply = self.Owner
        timer.Simple(0, function()
            if ply:Alive() and IsValid(self) then
                self.DeadManSwitch = false
                self.Owner:PrintMessage(HUD_PRINTCENTER, "You put away the dead man's switch.")
                self:EmitSound("weapons/pistol/pistol_empty.wav")
            end
        end)
    end
    ]]
    return self:GetNextSecondaryFire() < CurTime()
end

function SWEP:PrimaryAttack()

    if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
    self:SetNextPrimaryFire(CurTime() + 0.5)
    
    local wep = self.Owner:GetWeapon("utility_belt")
    if not IsValid(wep) then
        self.Owner:PrintMessage(HUD_PRINTCENTER, "You don't have an utility belt, and can't use the detonator.")
        return
    end
    
    if self.DeadManSwitch then
        self.DeadManSwitch = false
        if SERVER then  
            self.Owner:PrintMessage(HUD_PRINTCENTER, "The dead man's switch is disabled.")
            self:EmitSound("weapons/pistol/pistol_empty.wav")
        end
    else
        self.DeadManSwitch = true
        if SERVER then
            self.Owner:PrintMessage(HUD_PRINTCENTER, "The dead man's switch is enabled.")
            self:EmitSound("buttons/button1.wav") 
        end
    end
    
    if game.SinglePlayer() then -- God damn singleplayer shit
        self.Owner:SendLua("LocalPlayer():GetWeapon('utility_belt_detonator').DeadManSwitch = " .. (self.DeadManSwitch and "true" or "false"))
    end
    
end

function SWEP:SecondaryAttack()
    if self:GetNextPrimaryFire() > CurTime() or self:GetNextSecondaryFire() > CurTime() then return end
    self:SetNextSecondaryFire(CurTime() + 1.5)

    local wep = self.Owner:GetWeapon("utility_belt")
    if not IsValid(wep) then
        self.Owner:PrintMessage(HUD_PRINTCENTER, "You don't have an utility belt, and can't use the detonator.")
        return
    end
    self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
    if game.SinglePlayer() then
        self.Owner:SendLua("LocalPlayer():AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)")
    end
    local instant = not self.Owner:KeyDown(IN_RELOAD)
    if SERVER then
        self:EmitSound("snd_jack_hmcd_jihad" .. math.random(1,3) .. ".wav")
        
        timer.Simple(1, function()
            if IsValid(self) and IsValid(wep) and IsValid(self.Owner) and self.Owner:GetActiveWeapon() == self then
                wep:ScatterItems(true, instant)
            end
        end)
    end
    
end