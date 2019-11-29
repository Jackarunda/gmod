--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.BatteryCharge=500
ENT.BatteryMaxCharge=500
ENT.HasBattery=true
function ENT:ExternalCharge(amt)
	self.BatteryCharge=self.BatteryCharge+amt
	if(self.BatteryCharge>self.BatteryMaxCharge)then self.BatteryCharge=self.BatteryMaxCharge end
	self:SetDTInt(0,(self.BatteryCharge/self.BatteryMaxCharge)*100)
end
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_terminal")
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end
function ENT:Initialize()
	self.Entity:SetModel("models/jiinkyy/liinkyylaptopclosed.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(35)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Connection=nil
	self.Active=false
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Computer.ImpactHard")
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(activator:IsPlayer())then
		if not(self.BatteryCharge>0)then activator:PrintMessage(HUD_PRINTTALK,"ERROR: battery dead") return end
		if not((self.Controller)or(activator.JackaSentryController))then
			if not((activator:GetShootPos()-self:GetPos()):Length()<75)then return end
			if not(self.Connection)then
				local Turr=self:FindTurret()
				if(not(Turr))then
					activator:PrintMessage(HUD_PRINTTALK,"ERROR: no response from sentry (is there one in range?)")
					self:EmitSound("snd_jack_uiselect.wav",70,100)
				elseif((not(Turr.CurrentTarget==activator))and(not(Turr.IsLocked)))then
					activator:PrintMessage(HUD_PRINTTALK,"Wireless connection established with sentry "..tostring(Turr:EntIndex()))
					self:EmitSound("snd_jack_laptoplatch.wav",70,110)
					self:SetModel("models/jiinkyy/liinkyylaptopopen.mdl")
					JackaGenericUseEffect(activator)
					self.Connection=Turr
				else
					activator:PrintMessage(HUD_PRINTTALK,"ERROR: connection refused")
					Turr:EmitSound("snd_jack_denied.wav",75,100)
				end
			else
				local Turr=self:FindTurret()
				if((Turr)and not(Turr==self.Connection))then
					activator:PrintMessage(HUD_PRINTTALK,"Wireless connection established with sentry "..tostring(Turr:EntIndex()))
					self:EmitSound("snd_jack_uiselect.wav",70,100)
					self.Connection=Turr
				elseif(IsValid(self.Connection))then
					if(not(self.Connection:GetDTInt(0)==0))then
						JackaSentryControl(activator,self,self.Connection)
						self.Connection:EmitSound("snd_jack_dronebeep.wav",70,110)
					elseif(self.Connection:GetDTInt(0)==0)then
						activator:PrintMessage(HUD_PRINTTALK,"ERROR: no response from sentry (is the sentry turned on?)")
						self:EmitSound("snd_jack_uiselect.wav",70,100)
					end
				else
					self.Connection=nil
					activator:PrintMessage(HUD_PRINTTALK,"ERROR: no response from sentry; sentry ID erased")
					self:EmitSound("snd_jack_laptoplatch.wav",70,90)
					self:SetModel("models/jiinkyy/liinkyylaptopclosed.mdl")
					JackaGenericUseEffect(activator)
				end
			end
		end
	end
end
function ENT:FindTurret()
	local Closest=75
	local Ret=nil
	for key,found in pairs(ents.FindInSphere(self:GetPos(),75))do
		local Dist=(found:GetPos()-self:GetPos()):Length()
		local Phys=found:GetPhysicsObject()
		if(((not(found==self))and(not(found==ply))and(Dist<Closest))and(IsValid(Phys))and(not(found:IsWorld()))and(string.find(found:GetClass(),"ent_jack_turret_")))then
			if(self:Visible(found))then
				Ret=found
				Closest=Dist
			end
		end
	end
	return Ret
end
function ENT:Think()
	if(self.Controller)then
		if((self.Controller:GetPos()-self:GetPos()):Length()>75)then
			JackaSentryControlWipe(self.Controller,self,self.Controlled)
		else
			self.BatteryCharge=self.BatteryCharge-.4
			self:SetDTInt(0,(self.BatteryCharge/self.BatteryMaxCharge)*100)
			if(self.BatteryCharge<=0)then
				self.Controller:PrintMessage(HUD_PRINTTALK,"ERROR: terminal battery dying. Shutting down")
				JackaSentryControlWipe(self.Controller,self,self.Controlled)
				self:EmitSound("snd_jack_laptoplatch.wav",70,90)
				self:SetModel("models/jiinkyy/liinkyylaptopclosed.mdl")
			end
		end
	end
	self:NextThink(CurTime()+.5)
	return true
end
function ENT:OnRemove()
	if(self.Controller)then
		JackaSentryControlWipe(self.Controller,self,self.Controlled)
	end
end
local function Reset(...)
	local Args={...}
	local Ply=Args[1]
	if(Ply.JackaSentryControl)then
		Ply:SetViewEntity(Ply.JackaSentryControl)
	end
end
concommand.Add("jacky_reset_terminal_view",Reset)