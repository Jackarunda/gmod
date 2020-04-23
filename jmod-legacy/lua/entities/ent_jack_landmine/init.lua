--LayundMahn
--By Jackarunda

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local CamoTable={["Digi"]=1,["Grass"]=2,["Dirt"]=3,["Sand"]=4,["Snow"]=5,["Wood"]=6,["Concrete"]=7,["Asphalt"]=8,["Brick"]=9,["Black"]=10}

function ENT:SpawnFunction(ply, tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*20
	local ent=ents.Create("ent_jack_landmine")
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(SpawnPos)
	ent:SetNetworkedEntity("Owenur",ply)
	ent.ArmMode="None"
	ent.Camo="Digi"
	ent:Spawn()
	ent:Activate()
	
	local effectdata=EffectData()
	effectdata:SetEntity(ent)
	util.Effect("propspawn",effectdata)
	
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_pipes/pipe02_connector01.mdl")
	self.Entity:SetMaterial("models/jacky_camouflage/"..self.Camo)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	
	self.Exploded=false

	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(20)
	end
	
	self:SetUseType(SIMPLE_USE)
	
	self.Armed=false
	
	self.NextArmTime=CurTime()+3
	
	self.NextBounceNoiseTime=CurTime()
	
	self.UpDiraction=Vector(0,0,0)
	
	self.WarningLightOne=ents.Create("env_sprite")
	self.WarningLightOne:SetKeyValue("model","sprites/light_glow01.spr")
	self.WarningLightOne:SetKeyValue("scale",0.3)
	self.WarningLightOne:SetKeyValue("rendermode",9)
	self.WarningLightOne:SetKeyValue("renderfx",0)
	self.WarningLightOne:SetKeyValue("renderamt",255)
	self.WarningLightOne:SetKeyValue("rendercolor","255 100 100")
	self.WarningLightOne:SetPos(self:GetPos()+self:GetForward())
	self.WarningLightOne:Spawn()
	self.WarningLightOne:SetParent(self)
	
	self.WarningLightTwo=ents.Create("env_sprite")
	self.WarningLightTwo:SetKeyValue("model","sprites/light_glow01.spr")
	self.WarningLightTwo:SetKeyValue("scale",0.3)
	self.WarningLightTwo:SetKeyValue("rendermode",9)
	self.WarningLightTwo:SetKeyValue("renderfx",0)
	self.WarningLightTwo:SetKeyValue("renderamt",255)
	self.WarningLightTwo:SetKeyValue("rendercolor","255 100 100")
	self.WarningLightTwo:SetPos(self:GetPos()-self:GetForward())
	self.WarningLightTwo:Spawn()
	self.WarningLightTwo:SetParent(self)
	
	if(self.ArmMode=="Instant")then
		self.Armed=true
		self.WarningLightOne:Remove()
		self.WarningLightTwo:Remove()
		self:EmitSound("snd_jack_minearm.wav",80,100)
		self.Entity:DrawShadow(false)
	end
end

function ENT:Detonate(toucher)

	// OH SHI-
	
	if(self.Exploded)then return end
	self.Exploded=true
	
	local SelfPos=self:LocalToWorld(self:OBBCenter())
	
	for key,found in pairs(ents.FindInSphere(SelfPos,50))do
		if(IsValid(found:GetPhysicsObject()))then
			if(found:GetPhysicsObject():GetMass()<1000)then
				constraint.RemoveAll(found)
				found:Fire("enablemotion",0,0)
			end
		end
	end

	local OneDirection=SelfPos+self:GetForward()
	local AnotherDirection=SelfPos-self:GetForward()
	if(OneDirection.z>AnotherDirection.z)then
		self.UpDiraction=(self:GetForward())
	elseif(AnotherDirection.z>OneDirection.z)then
		self.UpDiraction=(-self:GetForward())
	else
		self.UpDiraction=Vector(0,0,1)
	end
	
	local EffectType=1
	local Traec=util.QuickTrace(self:GetPos(),Vector(0,0,-5),self.Entity)
	if(Traec.Hit)then
		if((Traec.MatType==MAT_DIRT)or(Traec.MatType==MAT_SAND))then
			EffectType=1
		elseif((Traec.MatType==MAT_CONCRETE)or(Traec.MatType==MAT_TILE))then
			EffectType=2
		elseif((Traec.MatType==MAT_METAL)or(Traec.MatType==MAT_GRATE))then
			EffectType=3
		elseif(Traec.MatType==MAT_WOOD)then
			EffectType=4
		end
	else
		EffectType=5
	end
	
	local plooie=EffectData()
	plooie:SetOrigin(SelfPos)
	plooie:SetScale(1)
	plooie:SetRadius(EffectType)
	plooie:SetNormal(self.UpDiraction)
	util.Effect("eff_jack_minesplode",plooie,true,true)
	
	for key,playa in pairs(ents.FindInSphere(SelfPos,50))do
		local Clayus=playa:GetClass()
		if((playa:IsPlayer())or(playa:IsNPC())or(Clayuss=="prop_vehicle_jeep")or(Clayuss=="prop_vehicle_jeep")or(Clayus=="prop_vehicle_airboat"))then
			playa:SetVelocity(playa:GetVelocity()+self.UpDiraction*500)
		end
	end

	util.BlastDamage(self,self,SelfPos,120,100)
	util.BlastDamage(self,self,SelfPos+self.UpDiraction*100,70,80)
	
	util.ScreenShake(SelfPos,99999,99999,1.5,500)
	
	for key,object in pairs(ents.FindInSphere(SelfPos,100))do
		local Clayuss=object:GetClass()
		if not(Clayuss=="ent_jack_landmine")then
			if(IsValid(object:GetPhysicsObject()))then
				local PhysObj=object:GetPhysicsObject()
				PhysObj:ApplyForceCenter(self.UpDiraction*15000)
				PhysObj:AddAngleVelocity(VectorRand()*math.Rand(500,3000))
			end
		end
	end
	
	self.Entity:EmitSound("BaseExplosionEffect.Sound")
	
	self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
	
	if(self)then self:Remove() end
end

function ENT:PhysicsCollide(data, physobj)
	if(data.HitEntity:IsWorld())then self:StartTouch(data.HitEntity) end
end

function ENT:StartTouch(ent)
	if(self.Armed)then
		self:Detonate(ent)
		local Tr=util.QuickTrace(self:GetPos(),Vector(0,0,-5),self.Entity)
		if(Tr.Hit)then
			util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
		end
	else
		if(self.NextBounceNoiseTime<CurTime())then
			self.Entity:EmitSound("SolidMetal.ImpactSoft")
			self.NextBounceNoiseTime=CurTime()+0.4
		end
	end
end

function ENT:EndTouch(ent)
	if(self.Armed)then
		self:Detonate(ent)
		local Tr=util.QuickTrace(self:GetPos(),Vector(0,0,-5),self.Entity)
		if(Tr.Hit)then
			util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if(self)then self:TakePhysicsDamage(dmginfo) end
end

function ENT:Use(activator, caller)
	if not((self.Armed)or(self.ArmMode=="OnRest"))then
		if(activator:IsPlayer())then
			if not(activator:HasWeapon("wep_jack_landmine"))then
				activator:Give("wep_jack_landmine")
				activator:SelectWeapon("wep_jack_landmine")
				local Wap=activator:GetWeapon("wep_jack_landmine")
				local Camo=CamoTable[self.Camo]
				Wap.dt.Camo=Camo
				timer.Simple(.01,function()
					if(IsValid(Wap))then
						umsg.Start("JackysLandmineCamoChangeUMSG")
						umsg.Entity(Wap)
						umsg.End()
					end
				end)
				self:Remove()
			end
		end
	end
end

local LastVel=Vector(0,0,0)
function ENT:Think()
	if(self.ArmMode=="OnRest")then
		if not(self.Armed)then
			local Vel=self:GetPhysicsObject():GetVelocity()
			if not(LastVel==Vel)then
				self.NextArmTime=CurTime()+4
				LastVel=Vel
			end
			if(self.NextArmTime<CurTime())then
				self.Armed=true
				self:Fire("disableshadow","",0) -- :3
				if(IsValid(self.WarningLightOne))then self.WarningLightOne:Remove() end
				if(IsValid(self.WarningLightTwo))then self.WarningLightTwo:Remove() end
				self:EmitSound("snd_jack_minearm.wav",80,100)
				self:WeldToSurface()
			end
		end
	end
	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:OnRemove()
end

function ENT:WeldToSurface()
	local SelfPos=self:GetPos()
	local Uupp=Vector(0,0,1)
	local OneDirection=SelfPos+self:GetForward()
	local AnotherDirection=SelfPos-self:GetForward()
	if(OneDirection.z>AnotherDirection.z)then
		Uupp=(self:GetForward())
	elseif(AnotherDirection.z>OneDirection.z)then
		Uupp=(-self:GetForward())
	else
		Upp=Vector(0,0,1)
	end
	local Trayuss=util.QuickTrace(SelfPos+Uupp*5,-Uupp*10,self.Entity)
	if(Trayuss.Hit)then
		constraint.Weld(self.Entity,Trayuss.Entity,0,0,12000,true)
	end
end