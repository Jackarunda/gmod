include("shared.lua")
AddCSLuaFile()
local Mat=Material("models/shiny")
function ENT:Initialize()
	self.PrettyModel=ClientsideModel("models/Weapons/w_bullet.mdl")
	self.PrettyModel:SetPos(self:GetPos()+self:GetUp()*1.25)
	self.PrettyModel:SetAngles(self:GetAngles())
	self.PrettyModel:SetParent(self)
	self.PrettyModel:SetNoDraw(true)
	self.PrettyModel:SetModelScale(2,0)
end
function ENT:Draw()
	render.SetColorModulation(0.3,0.2,0.1)
	render.MaterialOverride(Mat)
	self.PrettyModel:SetRenderOrigin(self:GetPos()+self:GetUp()*1.25)
	self.PrettyModel:SetAngles(self:GetAngles())
	self.PrettyModel:DrawModel()
	render.MaterialOverride(0)
	render.SetColorModulation(1,1,1)
end
function ENT:OnRemove()
	--eat a dick
end
language.Add("ent_jack_40mmgrenade","40mm Grenade")