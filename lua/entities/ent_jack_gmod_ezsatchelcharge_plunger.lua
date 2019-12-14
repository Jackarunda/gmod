-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="TheOnly8Z"
ENT.PrintName="EZ Satchel Charge Plunger"
ENT.Spawnable=false

ENT.JModPreferredCarryAngles=Angle(0,0,0)

if(SERVER)then

	function ENT:Initialize()
		self:SetModel("models/grenades/satchel_charge_plunger.mdl")
		self:SetModelScale(1.5,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		
		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():Wake()
		end
	end
	
	function ENT:Use(activator, caller)
		if !IsValid(activator) then return end
		self.Owner = activator
		if activator:KeyDown(IN_WALK) then
			self:EmitSound("snds_jack_gmod/plunger.wav")
			timer.Simple(0.8, function()
				if IsValid(self.Satchel) then
					self.Satchel:Detonate()
				end
			end)
			self:SetBodygroup(2, 1)
			SafeRemoveEntityDelayed(self, 10)
		else
			activator:PickupObject(self)
		end
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezsatchelcharge_plunger","EZ Satchel Charge Plunger")
end