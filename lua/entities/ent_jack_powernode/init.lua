--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.BatteryMaxCharge=1
ENT.BatteryCharge=1
ENT.HasBattery=true
ENT.PlugPosition=Vector(0,0,0)
function ENT:ExternalCharge(amt)
	for key,ent in pairs(self.Dependents)do
		if((IsValid(ent))and(IsValid(self.Connections[ent]))and(ent.HasBattery))then
			ent:ExternalCharge(100)
		else
			if(IsValid(self.Connections[ent]))then self.Connections[ent]:Remove() end
			if(self.Connections[ent])then self.Connections[ent]=nil end
			table.RemoveByValue(self.Dependents,ent)
		end
	end
end
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_powernode")
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
	self.Entity:SetModel("models/props_lab/powerbox02d.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(50)
	end
	self.Generator=nil
	self.GeneratorConn=nil
	self.Dependents={}
	self.Connections={}
	self.Entity:SetColor(Color(150,150,150))
	self.Entity:SetUseType(SIMPLE_USE)
end
function ENT:PhysicsCollide(data,physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("SolidMetal.ImpactHard")
	end
	if not(data.HitEntity:IsWorld())then
		if(data.HitEntity:GetClass()=="ent_jack_generator")then
			-- let the genny do the connecting
		elseif(data.HitEntity:GetClass()=="ent_jack_powernode")then
			if((self.Generator)and(IsValid(self.Generator))and not(self.Generator==data.HitEntity.Generator)and not(table.HasValue(self.Dependents,data.HitEntity)))then
				table.ForceInsert(self.Dependents,data.HitEntity)
				data.HitEntity.Generator=self.Generator
				timer.Simple(.01,function()
					if((IsValid(self))and(IsValid(data.HitEntity)))then
						if(data.HitEntity.PlugPosition)then
							local Cable=constraint.Rope(self,data.HitEntity,0,0,Vector(0,0,0),data.HitEntity.PlugPosition,1,999,1500,2,"cable/cable2",false)
							self.Connections[data.HitEntity]=Cable
							data.HitEntity.GeneratorConn=Cable
						end
					end
				end)
			end
		elseif((data.HitEntity.ExternalCharge)and(data.HitEntity.HasBattery))then
			if not(table.HasValue(self.Dependents,data.HitEntity))then
				table.ForceInsert(self.Dependents,data.HitEntity)
				timer.Simple(.01,function()
					if((IsValid(self))and(IsValid(data.HitEntity)))then
						if(data.HitEntity.PlugPosition)then
							self.Connections[data.HitEntity]=constraint.Rope(self,data.HitEntity,0,0,Vector(0,0,0),data.HitEntity.PlugPosition,1,999,1500,2,"cable/cable2",false)
						elseif((IsValid(self.Generator))and(self.Generator.State=="Running"))then
							if(data.HitEntity.BatteryCharge<data.HitEntity.BatteryMaxCharge)then
								data.HitEntity:ExternalCharge(1000)
								local effectdata=EffectData()
								effectdata:SetOrigin(data.HitEntity:GetPos())
								effectdata:SetNormal(VectorRand())
								effectdata:SetMagnitude(1) --amount and shoot hardness
								effectdata:SetScale(1) --length of strands
								effectdata:SetRadius(1) --thickness of strands
								util.Effect("Sparks",effectdata,true,true)
								data.HitEntity:EmitSound("snd_jack_niceding.wav")
								self.Generator.Remaining=self.Generator.Remaining-1
							end
						end
					end
				end)
			end
		end
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	activator:PickupObject(self)
end
function ENT:Think()
	local Time=CurTime()
	if not(IsValid(self))then return end
	if not(IsValid(self.Generator))then self.Generator=nil return end
	if not(IsValid(self.GeneratorConn))then self.GeneratorConn=nil;self.Generator=nil return end
	for key,thing in pairs(self.Dependents)do
		if((IsValid(thing))and(IsValid(self.Connections[thing]))and(thing.HasBattery))then
			--lol
		else
			if(IsValid(self.Connections[ent]))then self.Connections[ent]:Remove() end
			if(self.Connections[ent])then self.Connections[ent]=nil end
			table.RemoveByValue(self.Dependents,ent)
		end
	end
	self:NextThink(CurTime()+1)
	return true
end