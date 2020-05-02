-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="TheOnly8Z"
ENT.PrintName="EZ Satchel Charge Plunger"
ENT.Spawnable=false
ENT.NoSitAllowed=true

ENT.JModPreferredCarryAngles=Angle(0,0,0)

function ENT:SetupDataTables()
	self:NetworkVar("Bool",0,"Fired")
end

if(SERVER)then

	function ENT:Initialize()
		--self:SetModel("models/grenades/satchel_charge_plunger.mdl")
		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		
		self.DieTime = nil
		self:SetFired(false)
		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end
	end
	
	function ENT:Use(activator,caller,typ,val)
		if !IsValid(activator) then return end
		if(IsValid(self:GetParent()))then
			self:GetParent():Use(activator,caller,typ,val)
			return
		end
		
		self.Owner = activator
		if activator:KeyDown(JMOD_CONFIG.AltFunctionKey) then
			self:EmitSound("snds_jack_gmod/plunger.wav")
			self:SetFired(true)
			timer.Simple(.5, function()
				if IsValid(self.Satchel) then
					self.Satchel:Detonate()
				end
			end)
			self.DieTime = CurTime() + 10
		else
			activator:PickupObject(self)
		end
	end
	
	function ENT:Think()
		if !IsValid(self.Satchel) and self.DieTime == nil then
			self:Remove()
		elseif self.DieTime != nil and self.DieTime < CurTime() then
			self:Remove()
		end
	end
	
	function ENT:OnRemove()
		if IsValid(self.Satchel) then
			SafeRemoveEntity(self.Satchel)
		end
	end
	
elseif(CLIENT)then
	function ENT:Initialize()
		--self:SetBodygroup(2,1)
		self.Mdl=ClientsideModel("models/grenades/satchel_charge_plunger.mdl")
		self.Mdl:SetModelScale(3,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	function ENT:Draw()
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(self:GetPos()+self:GetForward()*30+self:GetUp()*1.5)
		self.Mdl:SetRenderAngles(self:GetAngles())
		if(self:GetFired())then self.Mdl:SetBodygroup(2,1) end
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_ezsatchelcharge_plunger","EZ Satchel Charge Plunger")
end