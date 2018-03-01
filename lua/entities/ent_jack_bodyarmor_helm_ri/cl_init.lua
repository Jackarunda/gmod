include('shared.lua')
function ENT:Initialize()
	self.Visor=ClientsideModel("models/props_phx/construct/glass/glass_curve180x2.mdl")
	self.Visor:SetPos(self:GetPos())
	self.Visor:SetParent(self)
	self.Visor:SetNoDraw(true)
	self.Visor:SetModelScale(.08,0)
end
function ENT:Draw()
	local Ang=self:GetAngles()
	local Pos=self:GetPos()
	Ang:RotateAroundAxis(Ang:Up(),180)
	self.Visor:SetRenderAngles(Ang)
	Pos=Pos-Ang:Up()*5+Ang:Right()*2.6-Ang:Forward()*4.5
	self.Visor:SetRenderOrigin(Pos)
	self.Entity:DrawModel()
	self.Visor:DrawModel()
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_bodyarmor_helm_ri","Helmet")
--[[-------------------------
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
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01
ValveBiped.Bip01_R_Shoulder
ValveBiped.Bip01_L_Shoulder
ValveBiped.Bip01_R_Trapezius
ValveBiped.Bip01_L_Trapezius
----------------------------------------]]