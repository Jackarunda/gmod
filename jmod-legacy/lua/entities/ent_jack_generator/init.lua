--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
ENT.PlugPosition=Vector(0,0,0)
local FuelsTable={
	"models/props_explosive/explosive_butane_can.mdl",
	"models/props_explosive/explosive_butane_can02.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_junk/propane_tank001a.mdl"
}
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_generator")
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
	self.Entity:SetModel("models/props_outland/generator_static01a.mdl")
	self.Entity:SetMaterial("models/props_silo/generator_jtatic01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(750)
	end
	self.Entity:SetUseType(SIMPLE_USE)
	self.Remaining=0
	self.NextUseTime=0
	self.NextSoundTime=0
	self.State="Off"
	self.Dependents={}
	self.Connections={}
	self.FuelTank=nil
	self.NextWorkTime=0
	self:SetDTBool(0,self.State=="Running")
	self.Entity:SetColor(Color(150,150,150))
end
function ENT:PhysicsCollide(data,physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("SolidMetal.ImpactHard")
	end
	if not(data.HitEntity:IsWorld())then
		if((not(data.HitEntity:GetClass()=="ent_jack_generator"))and(data.HitEntity.ExternalCharge)and(data.HitEntity.HasBattery))then
			if((data.HitEntity:GetClass()=="ent_jack_powernode")and(data.HitEntity.Generator==self))then return end
			if not(table.HasValue(self.Dependents,data.HitEntity))then
				table.ForceInsert(self.Dependents,data.HitEntity)
				if(data.HitEntity:GetClass()=="ent_jack_powernode")then data.HitEntity.Generator=self end
				timer.Simple(.01,function()
					if((IsValid(self))and(IsValid(data.HitEntity)))then
						if(data.HitEntity.PlugPosition)then
							local Cable=constraint.Rope(self,data.HitEntity,0,0,Vector(0,0,0),data.HitEntity.PlugPosition,1,499,1500,2,"cable/cable2",false)
							self.Connections[data.HitEntity]=Cable
							if(data.HitEntity:GetClass()=="ent_jack_powernode")then data.HitEntity.GeneratorConn=Cable end
						elseif(self.State=="Running")then
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
								self.Remaining=self.Remaining-1
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
	if(activator:IsPlayer())then
		if(self.NextUseTime>CurTime())then return end
		if(self.State=="Off")then
			self:Start()
		elseif(self.State=="Running")then
			self:ShutOff()
			self.NextUseTime=CurTime()+10
		end
	end
end
function ENT:Start()
	if(self.Remaining>0)then
		self:EmitSound("snd_jack_genstart.mp3")
		self.State="Running"
		self:SetDTBool(0,self.State=="Running")
		self.NextSoundTime=CurTime()+8
		self.NextUseTime=CurTime()+10
		self.NextWorkTime=CurTime()+10
	else
		self:Refuel()
	end
end
function ENT:ShutOff()
	self:EmitSound("snd_jack_genstop.mp3")
	self.State="Off"
	self:SetDTBool(0,self.State=="Running")
end
function ENT:Think()
	local Time=CurTime()
	if(self.NextWorkTime<Time)then
		for key,ent in pairs(self.Dependents)do
			if not((IsValid(ent))and(IsValid(self.Connections[ent]))and(ent.HasBattery))then
				if(IsValid(self.Connections[ent]))then self.Connections[ent]:Remove() end
				if(self.Connections[ent])then self.Connections[ent]=nil end
				table.RemoveByValue(self.Dependents,ent)
			end
		end
	end
	if(self.State=="Running")then
		if not(IsValid(self.FuelTank))then
			self.FuelTank=nil
			self.Remaining=0
		end
		if(self.Remaining<=0)then
			if(IsValid(self.FuelTank))then self.FuelTank:Remove() end
			self.FuelTank=nil
			self.Remaining=0
			self:ShutOff()
			return
		end
		if(self.NextWorkTime<Time)then
			self.NextWorkTime=Time+1
			for key,ent in pairs(self.Dependents)do
				if((IsValid(ent))and(IsValid(self.Connections[ent]))and(ent.HasBattery))then
					ent:ExternalCharge(100)
				end
			end
			self.Remaining=self.Remaining-1
		end
		if(self.NextSoundTime<CurTime())then
			self.NextSoundTime=CurTime()+3.5
			self:EmitSound("snd_jack_genrun.mp3")
		end
		if(self:WaterLevel()>0)then self:ShutOff() end
		self:GetPhysicsObject():ApplyForceCenter(VectorRand()*1500)
		--local Poof=EffectData()
		--Poof:SetOrigin(self:GetPos()+self:GetUp()*50+self:GetForward()*10-self:GetRight()*25)
		--Poof:SetNormal(self:GetUp())
		--Poof:SetScale(1)
		--util.Effect("eff_jack_genrun",Poof,true,true)
		self:NextThink(CurTime()+.1)
		return true
	end
end
function ENT:Refuel()
	for key,found in pairs(ents.FindInSphere(self:GetPos(),125))do
		if((string.find(found:GetClass(),"ent_jack_aidfuel_"))or((found:GetClass()=="prop_physics")and(table.HasValue(FuelsTable,found:GetModel()))))then
			if(found.FuelLeft)then
				if not(found.FuelLeft<=0)then
					self:FuelWith(found)
					break
				end
			else
				self:FuelWith(found)
				break
			end
		end
	end
end
function ENT:FuelWith(ent)
	if(string.find(ent:GetClass(),"ent_jack_aidfuel_"))then
		self.Remaining=700
	else
		self.Remaining=350
	end
	self.FuelTank=ent
	ent:SetPos(self:GetPos()+self:GetUp()*68-self:GetForward()*15)
	local Ang=self:GetAngles()
	Ang:RotateAroundAxis(Ang:Right(),-90)
	ent:SetAngles(Ang)
	ent:SetParent(self)
	ent:SetNotSolid(true)
	self:EmitSound("snd_jack_metallicload.wav")
end
function ENT:OnRemove()
	if(IsValid(self.FuelTank))then self.FuelTank:Remove() end
end