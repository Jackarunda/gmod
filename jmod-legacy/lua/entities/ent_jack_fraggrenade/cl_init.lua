include('shared.lua')

language.Add("ent_jack_fraggrenade","Frag Grenade")

function ENT:Initialize()
	if(self:GetDTBool(0))then
		local NiceModel=ClientsideModel("models/weapons/w_fragjade.mdl")
		NiceModel:SetMaterial("modes/weapons/w_models/gjj")
		NiceModel:SetPos(self:GetPos()+self:GetUp()*2)
		NiceModel:SetParent(self)
		NiceModel:Spawn()
		NiceModel:Activate()
		self.NiceModel=NiceModel
	else
		local NiceModel=ClientsideModel("models/weapons/w_fragjade.mdl")
		NiceModel:SetMaterial("models/weapons/w_models/gnd")
		NiceModel:SetPos(self:GetPos()+self:GetUp()*2)
		NiceModel:SetParent(self)
		NiceModel:Spawn()
		NiceModel:Activate()
		self.NiceModel=NiceModel
	end
end

/*---------------------------------------------------------
   Name: ENT:Draw()
---------------------------------------------------------*/
function ENT:Draw()
	//nothin
end

function ENT:OnRemove()
	self.NiceModel:Remove()
end

killicon.Add("ent_jack_fraggrenade","vgui/killicons/ent_jack_fraggrenade_KI",Color(255,255,255,255))