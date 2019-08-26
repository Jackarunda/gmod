include('shared.lua')
function ENT:Initialize()
	if(self:GetDTBool(0))then
		self.Parachute=ClientsideModel("models/jessev92/rnl/items/parachute_deployed.mdl")
		self.Parachute:SetNoDraw(true)
		self.Parachute:SetParent(self)
	end
	self.InitTime=CurTime()
end
function ENT:Draw()
	if(CurTime()-self.InitTime<.15)then return end
	render.SetBlend(self:GetDTFloat(0))
	if(self:GetDTBool(0))then
		local Vel=self:GetVelocity()
		if(Vel:Length()>0)then
			local Pos=self:GetPos()
			local Dir=Vel:GetNormalized()
			Dir=Dir+Vector(.01,0,0) -- stop the turn spasming
			local Ang=Dir:Angle()
			Ang:RotateAroundAxis(Ang:Right(),90)
			self.Parachute:SetRenderOrigin(Pos+Dir*50)
			self.Parachute:SetRenderAngles(Ang)
			self.Parachute:DrawModel()
		end
	end
	self.Entity:DrawModel()
	render.SetBlend(1)
end
function ENT:OnRemove()
	--fuck you kid you're a dick
end
language.Add("ent_jack_aidbox","J.I. Aid Package")