--box
--By Jackarunda
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
function ENT:SpawnFunction(ply,tr)
	local SpawnPos=tr.HitPos+tr.HitNormal*16
	local ent=ents.Create("ent_jack_armorpanel_small")
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
	self.Entity:SetModel("models/props_phx/construct/metal_plate2x2.mdl")
	self.Entity:SetMaterial("models/mat_jack_scratchedmetal")
	self.Entity:SetColor(Color(100,100,100))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(true)
	local phys=self.Entity:GetPhysicsObject()
	if phys:IsValid()then
		phys:Wake()
		phys:SetMass(500)
		phys:SetMaterial("metal")
	end
	self.JackyArmoredPanel=true
	if not((self.AmHelper)or(self.AmReinforcer))then
		self.Helper=ents.Create("ent_jack_armorpanel_small")
		self.Helper:SetPos(self:GetPos())
		self.Helper:SetAngles(self:GetAngles())
		self.Helper.AmHelper=true
		self.Helper:SetParent(self)
		self.Helper:Spawn()
		self.Helper:Activate()
		self.Helper:SetNotSolid(true)
		self.Helper:SetNoDraw(true)
		self.Helper:SetTrigger(true)
		--[[
		self.Reinforcer1=ents.Create("ent_jack_armorpanel_small")
		self.Reinforcer1:SetPos(self:GetPos()+self:GetUp()*3.25)
		self.Reinforcer1:SetAngles(self:GetAngles())
		self.Reinforcer1.AmReinforcer=true
		self.Reinforcer1:Spawn()
		self.Reinforcer1:Activate()
		constraint.Weld(self.Reinforcer1,self,0,0,0,true)
		constraint.Weld(self.Reinforcer1,self,0,0,1e10,true)
		constraint.Weld(self.Reinforcer1,self,0,0,1e20,true)
		--]]
	end
end
function ENT:PhysicsCollide(data, physobj)
	if((data.Speed>80)and(data.DeltaTime>0.2))then
		if(self.Entity)then self.Entity:EmitSound("SolidMetal.ImpactHard") end
	end
end
function ENT:OnTakeDamage(dmginfo)
	dmginfo:SetDamageForce(dmginfo:GetDamageForce()/10)
	self.Entity:TakePhysicsDamage(dmginfo)
	if((dmginfo:IsDamageType(DMG_BULLET))or(dmginfo:IsDamageType(DMG_BUCKSHOT)))then
		local Attacker=dmginfo:GetAttacker()
		if(IsValid(Attacker))then
			if((Attacker:GetPos()-dmginfo:GetDamagePosition()):Length()<200)then
				if(math.random(1,4)==2)then
					dmginfo:ScaleDamage(.5)
					Attacker:TakeDamageInfo(dmginfo)
				end
			end
		end
	end
end
function ENT:Use(activator,caller)
	--no
end
function ENT:Think()
	--ass muffins
end
function ENT:StartTouch(ent)
	self:FuckEmUp(ent)
end
function ENT:EndTouch(ent)
	self:FuckEmUp(ent)
end
function ENT:Touch(ent)
	self:FuckEmUp(ent)
end
function ENT:FuckEmUp(ent)
	if((self.AmHelper)and(ent:IsPlayer()))then
		if(ent:GetMoveType()==MOVETYPE_NOCLIP)then
			local Vel=ent:GetVelocity()
			ent:SetPos(ent:GetPos()-Vel/10)
			ent:SetMoveType(MOVETYPE_WALK)
			ent:SetVelocity(-Vel:GetNormalized()*500)
		end
	end
end
function ENT:OnRemove()
	if(IsValid(self.Reinforcer1))then self.Reinforcer1:Remove() end
	if(IsValid(self.Reinforcer2))then self.Reinforcer2:Remove() end
end
--[[
local function ShouldCollide(ent1,ent2)
	if(ent1.JackyArmoredPanel)then
		if(ent2:IsPlayer())then
			if(ent2:GetMoveType()==MOVETYPE_NOCLIP)then
				ent2:KillSilent()
			end
		end
	elseif(ent2.JackyArmoredPanel)then
		if(ent1:IsPlayer())then
			if(ent1:GetMoveType()==MOVETYPE_NOCLIP)then
				ent1:KillSilent()
			end
		end
	end
end
hook.Add("ShouldCollide","JackyArmoredPanels",ShouldCollide)
--]]