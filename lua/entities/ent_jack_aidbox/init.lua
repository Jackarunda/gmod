--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/wood_crate001a.mdl")
	self.Entity:SetMaterial("models/mat_jack_aidbox")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Entity:SetUseType(SIMPLE_USE)
	local Phys=self.Entity:GetPhysicsObject()
	if(IsValid(Phys))then
		Phys:Wake()
		Phys:SetMass(200)
		Phys:EnableDrag(false)
		Phys:SetMaterial("metal")
	end
	timer.Simple(.1,function()
		if(IsValid(self))then
			self:GetPhysicsObject():SetVelocity(self.InitialVel+VectorRand()*math.Rand(0,200))
			self:GetPhysicsObject():AddAngleVelocity(VectorRand()*math.Rand(0,3000))
		end
	end)
	self.Opacity=0
	self:SetDTFloat(0,self.Opacity)
end
function ENT:PhysicsCollide(data,physobj)
	if((data.Speed>2000)and(data.DeltaTime>.2))then
		self.Entity:EmitSound("Boulder.ImpactHard")
		self.Entity:EmitSound("Canister.ImpactHard")
		self.Entity:EmitSound("Boulder.ImpactHard")
		self.Entity:EmitSound("Canister.ImpactHard")
		self.Entity:EmitSound("Boulder.ImpactHard")
		util.ScreenShake(data.HitPos,99999,99999,.5,500)
		local Poof=EffectData()
		Poof:SetOrigin(data.HitPos)
		Poof:SetScale(5)
		Poof:SetNormal(data.HitNormal)
		util.Effect("eff_jack_aidimpact",Poof,true,true)
		local Tr=util.QuickTrace(data.HitPos-data.OurOldVelocity,data.OurOldVelocity*50,{self})
		if(Tr.Hit)then
			util.Decal("Rollermine.Crater",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal)
		end
	elseif((data.Speed>80)and(data.DeltaTime>.2))then
		self.Entity:EmitSound("Canister.ImpactHard")
	end
	if(data.DeltaTime>.1)then
		local Phys=self:GetPhysicsObject()
		Phys:SetVelocity(Phys:GetVelocity()/1.5)
		Phys:AddAngleVelocity(-Phys:GetAngleVelocity()/1.30)
	end
end
function ENT:OnTakeDamage(dmginfo)
	self.Entity:TakePhysicsDamage(dmginfo)
end
function ENT:Use(activator,caller)
	local Pos=self:LocalToWorld(self:OBBCenter())
	local Up=self:GetUp()
	local Right=self:GetRight()
	local Forward=self:GetForward()
	local Ang=self:GetAngles()
	local AngLat=self:GetAngles()
	AngLat:RotateAroundAxis(AngLat:Forward(),90)
	local AngLin=self:GetAngles()
	AngLin:RotateAroundAxis(AngLin:Right(),90)
	self:MakeSide(Pos+Up*15,Ang,Up)
	self:MakeSide(Pos-Up*15,Ang,-Up)
	self:MakeSide(Pos+Right*15,AngLat,Right)
	self:MakeSide(Pos-Right*15,AngLat,-Right)
	self:MakeSide(Pos+Forward*15,AngLin,Forward)
	self:MakeSide(Pos-Forward*15,AngLin,-Forward)
	local Poof=EffectData()
	Poof:SetOrigin(Pos)
	Poof:SetScale(2)
	util.Effect("eff_jack_aidopen",Poof,true,true)
	self:EmitSound("snd_jack_aidboxopen.wav",75,100)
	self:EmitSound("snd_jack_aidboxopen.wav",75,100)
	self:EmitSound("snd_jack_aidboxopen.wav",75,100)
	self:EmitSound("snd_jack_aidboxopen.wav",75,100)
	for key,item in pairs(self.Contents)do
		local Yay=ents.Create(item)
		Yay:SetPos(Pos+VectorRand()*math.Rand(0,30))
		Yay:SetAngles(VectorRand():Angle())
		Yay:Spawn()
		Yay:Activate()
		Yay:SetUseType(SIMPLE_USE)
	end
	JackaGenericUseEffect(activator)
	timer.Simple(2,function()
		sound.Play("snd_jack_itemsget.wav",Pos,75,100)
	end)
	self:Remove()
end
function ENT:MakeSide(pos,ang,dir)
	local Side=ents.Create("prop_physics")
	Side:SetModel("models/hunter/plates/plate1x1.mdl")
	Side:SetMaterial("models/mat_jack_aidboxside")
	Side:SetColor(Color(200,200,200,255))
	Side:SetPos(pos)
	Side:SetAngles(ang)
	Side:Spawn()
	Side:Activate()
	Side:GetPhysicsObject():SetMaterial("gmod_silent")
	Side:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity())
	Side:GetPhysicsObject():ApplyForceCenter(dir*2000)
	Side:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	SafeRemoveEntityDelayed(Side,math.random(8,16))
end
function ENT:Think()
	self.Opacity=self.Opacity+.01
	if(self.Opacity>1)then self.Opacity=1 end
	self:SetDTFloat(0,self.Opacity)
	self:NextThink(CurTime()+.01)
	return true
end
function ENT:OnRemove()
	--aw fuck you
end