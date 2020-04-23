--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_paintcan")
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
	self.Entity:SetModel("models/props_phx/wheels/magnetic_small_base.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	self.Entity:SetUseType(SIMPLE_USE)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(10)
	end
	self.MenuOpen=false
	self:SetNetworkedInt("JackIndex",self:EntIndex())
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
	if not(self.MenuOpen)then
		self.MenuOpen=true
		umsg.Start("JackaSprayPaintOpenMenu",activator)
		umsg.Entity(self)
		umsg.End()
	end
end
function ENT:PaintObject(ply,col)
	local SelfPos=self:GetPos()
	local Closest=100
	local Obj=nil
	for key,found in pairs(ents.FindInSphere(SelfPos,100))do
		local Dist=(found:GetPos()-SelfPos):Length()
		local Phys=found:GetPhysicsObject()
		if(((not(found==self))and(not(found==ply))and(Dist<Closest))and(IsValid(Phys))and(not(found:IsWorld()))and(not(found:GetClass()=="ent_jack_paintcan")))then
			if((Phys:GetVolume()<650000)or(found.JackyArmoredPanel))then
				local Kol=found:GetColor()
				if not((Kol.r==col.r)and(Kol.g==col.g)and(Kol.b==col.b))then
					Closest=Dist
					Obj=found
				end
			end
		end
	end
	if(IsValid(Obj))then
		self:EmitSound("snd_jack_spraypaint.wav")
		timer.Simple(.2,function()
			if(IsValid(Obj))then
				Obj:SetColor(col)
			end
		end)
		Obj:EmitSound("snd_jack_spraypaint.wav")
		local Poof=EffectData()
		Poof:SetOrigin(Obj:LocalToWorld(Obj:OBBCenter()))
		Poof:SetScale(5)
		Poof:SetStart(Vector(col.r,col.g,col.b))
		util.Effect("eff_jack_spraypaint",Poof,true,true)
		self:Remove()
	end
end
function ENT:Think()
	--naw
end
function ENT:OnRemove()
	--aw fuck you
end
local function MenuClosePaint(...)
	local args={...}
	local ply=args[1]
	local self=Entity(tonumber(args[3][1]))
	local R=tonumber(args[3][2])
	local G=tonumber(args[3][3])
	local B=tonumber(args[3][4])
	self.MenuOpen=false
	self:PaintObject(ply,Color(R,G,B))
end
concommand.Add("JackaSprayPaintGo",MenuClosePaint)
local function MenuClose(...)
	local args={...}
	local self=Entity(tonumber(args[3][1]))
	self.MenuOpen=false
end
concommand.Add("JackaSprayPaintClose",MenuClose)