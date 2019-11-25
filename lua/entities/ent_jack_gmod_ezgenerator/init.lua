AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local STATE_OFF, STATE_STARTING, STATE_ON = 0, -1, 1

function ENT:SpawnFunction(ply,tr,ClassName)
	local ent=ents.Create(ClassName)
	ent:SetPos(tr.HitPos + tr.HitNormal*16)
	ent:Spawn()
	ent:Activate()
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_outland/generator_static01a.mdl")
	self.Entity:SetMaterial("models/props_silo/generator_jtatic01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(750)
	end
	self.Entity:SetUseType(SIMPLE_USE)

	self.NextLoad = 0
	self.NextUse = 0
	self.NextSound = 0
	self.NextWork = 0
	
	self:SetState(STATE_OFF)
	self:SetFuel(0)
	self:SetPower(0)
	--self.Entity:SetColor(Color(150,150,150))
end

function ENT:PhysicsCollide(data,physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("SolidMetal.ImpactHard")
	end
	-- TODO Accept fuel
end

function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end

function ENT:Use(activator,caller)

	if(activator:IsPlayer())then
	
		local alt = activator:KeyDown(IN_WALK)
		
		if (self.NextUse>CurTime()) then return end
		self.NextUse = CurTime() + 1
		
		if (self:GetState() == STATE_OFF and alt) then
			self:Start()
		elseif (self:GetState() == STATE_ON and alt) then
			self:ShutOff()
		elseif (!alt) then
			self:ProducePower(activator)
		end
		JMod_Hint(activator, "generator")
	end
	
end

function ENT:ProducePower(ply)

	local amt = math.min(self:GetPower(), JMod_EZbatterySize)
	if amt <= 0 then return end
	
	local battery = ents.Create(self.BatteryEnt)
	battery:SetPos(self:GetPos()+self:GetUp()*20)
	battery:SetAngles(self:GetAngles())
	battery:Spawn()
	battery:Activate()
	battery:SetResource(amt)
	battery.NextLoad=CurTime()+2
	
	ply:PickupObject(battery)
	self:SetPower(self:GetPower() - amt)
	self:EmitSound("Ammo_Crate.Close")
	
end

function ENT:TryLoadResource(typ,amt)

	if self.NextLoad > CurTime() then return 0 end
	if amt <= 0 or self:GetFuel() >= self.MaxPower then return 0 end
	
	local takeAmt = math.min(amt, self.MaxFuel - self:GetFuel())
	self:SetFuel(self:GetFuel() + takeAmt)
	self.NextLoad = CurTime() + 1
	return takeAmt

end

function ENT:Start()
	if self:GetFuel() > 0 then
		self:EmitSound("snd_jack_genstart.mp3")
		self:SetState(STATE_STARTING)
		self.NextSound=CurTime()+8
		self.NextUse=CurTime()+10
		self.NextWork=CurTime()+10
	else
		self:EmitSound("buttons/button8.wav")
	end
end

function ENT:ShutOff()
	self:EmitSound("snd_jack_genstop.mp3")
	self:SetState(STATE_OFF)
	self.NextUse=CurTime()+5
	self.NextWork=CurTime()+5
end

function ENT:Think()
	
	if(self:GetState() == STATE_ON)then

		if(self:GetFuel() <= 0)then
			self:ShutOff()
			return
		else
			local drain = math.min(self:GetFuel(), 1) -- TODO make this configurable?
			self:SetFuel(self:GetFuel() - drain)
			self:SetPower(math.min(self:GetPower() + drain, self.MaxPower))
		end
		
		if(self.NextSound <= CurTime() )then
			self.NextSound = CurTime() + 3.5
			self:EmitSound("snd_jack_genrun.mp3")
		end
		
		if(self:WaterLevel()>0)then self:ShutOff() end
		
		self:GetPhysicsObject():ApplyForceCenter(VectorRand()*1500)
		
		--local Poof=EffectData()
		--Poof:SetOrigin(self:GetPos()+self:GetUp()*50+self:GetForward()*10-self:GetRight()*25)
		--Poof:SetNormal(self:GetUp())
		--Poof:SetScale(1)
		--util.Effect("eff_jack_genrun",Poof,true,true)
		
		self:NextThink(CurTime()+0.5)
		return true
		
	elseif self:GetState() == STATE_STARTING then
		
		if self.NextWork < CurTime() then self:SetState(STATE_ON) end
		self:NextThink(CurTime()+0.5)
		return true
		
	end
	
end
