--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_aidfuel_kerosene")
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
	self.Entity:SetModel("models/props_phx/wheels/magnetic_med_base.mdl")
	self.Entity:SetColor(Color(50,50,50))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(35)
	end
	self.Burning=false
	self.FuelLeft=100
	self.Entity:SetUseType(SIMPLE_USE)
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		self.Entity:EmitSound("Metal_Box.ImpactHard")
		if(self.FuelLeft>0)then
			self.Entity:EmitSound("Wade.StepRight")
			self.Entity:EmitSound("Wade.StepLeft")
		end
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	if(self.FuelLeft<=0)then return end
	JackaGenericUseEffect(activator)
	if not(self.Burning)then
		self:BeginBurnin()
	else
		self:StahpBurnin()
	end
end
function ENT:BeginBurnin()
	if(self.FuelLeft<=0)then return end
	self.Burning=true
	self:EmitSound("snd_jack_littleignite.wav",75,100)
end
function ENT:StahpBurnin()
	self.Burning=false
	self:EmitSound("snd_jack_littleignite.wav",75,100)
end
function ENT:Think()
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	local SelfUp=self:GetUp()
	if(self.Burning)then
		if(self:WaterLevel()>0)then self:StahpBurnin() return end
		local Fft=EffectData()
		Fft:SetOrigin(SelfPos+SelfUp*10)
		Fft:SetScale(1)
		Fft:SetEntity(self)
		util.Effect("eff_jack_lampburn",Fft,true,true)
		self.FuelLeft=self.FuelLeft-.0325
		if(self.FuelLeft<=0)then
			self:StahpBurnin()
			SafeRemoveEntityDelayed(self,10)
		end
	end
	self:NextThink(CurTime()+.1)
	return true
end
function ENT:OnRemove()
	--aw fuck you
end