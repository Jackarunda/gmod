-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Machine"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.Spawnable=false
ENT.AdminSpawnable=false
----
ENT.Model = "models/props_lab/reciever01d.mdl"
----
ENT.PropModels={
	"models/props_lab/reciever01d.mdl",
	"models/props/cs_office/computer_caseb_p2a.mdl",
	"models/props/cs_office/computer_caseb_p3a.mdl",
	"models/props/cs_office/computer_caseb_p4a.mdl",
	"models/props/cs_office/computer_caseb_p5a.mdl",
	"models/props/cs_office/computer_caseb_p5b.mdl",
	"models/props/cs_office/computer_caseb_p6a.mdl",
	"models/props/cs_office/computer_caseb_p6b.mdl",
	"models/props/cs_office/computer_caseb_p7a.mdl",
	"models/props/cs_office/computer_caseb_p8a.mdl",
	"models/props/cs_office/computer_caseb_p9a.mdl",
	"models/gibs/helicopter_brokenpiece_02.mdl",
	"models/gibs/manhack_gib03.mdl",
	"models/gibs/manhack_gib04.mdl",
	"models/gibs/manhack_gib05.mdl",
	"models/gibs/manhack_gib06.mdl",
	"models/gibs/metal_gib1.mdl",
	"models/gibs/metal_gib2.mdl",
	"models/gibs/metal_gib3.mdl",
	"models/gibs/metal_gib4.mdl",
	"models/gibs/metal_gib5.mdl",
	"models/gibs/scanner_gib01.mdl",
	"models/gibs/scanner_gib02.mdl",
	"models/props_c17/canisterchunk01d.mdl",
	"models/props_c17/canisterchunk01b.mdl",
	"models/props_c17/canisterchunk01l.mdl",
	"models/props_c17/canisterchunk01m.mdl",
	"models/props_c17/canisterchunk02b.mdl",
	"models/props_c17/canisterchunk02c.mdl",
	"models/props_c17/canisterchunk02d.mdl",
	"models/props_c17/canisterchunk02e.mdl",
	"models/props_c17/canisterchunk02f.mdl",
	"models/props_c17/canisterchunk01a.mdl",
	"models/props_c17/canisterchunk01h.mdl",
	"models/props_c17/oildrumchunk01a.mdl",
	"models/props_c17/oildrumchunk01b.mdl",
	"models/props_c17/oildrumchunk01c.mdl",
	"models/props_c17/oildrumchunk01d.mdl",
	"models/props_c17/oildrumchunk01e.mdl",
	"models/props_c17/oildrumchunk01a.mdl",
	"models/props_c17/oildrumchunk01b.mdl",
	"models/props_c17/oildrumchunk01c.mdl",
	"models/props_c17/oildrumchunk01d.mdl",
	"models/props_c17/oildrumchunk01e.mdl",
	"models/props_canal/boat001a_chunk010.mdl",
	"models/props_canal/boat001a_chunk06.mdl",
	"models/props_debris/concrete_chunk04a.mdl",
	"models/props_debris/concrete_chunk05g.mdl",
	"models/props_debris/prison_wallchunk001f.mdl",
	"models/props_debris/wood_chunk04a.mdl",
	"models/props_debris/wood_chunk06b.mdl",
	"models/props_junk/glassjug01_chunk01.mdl",
	"models/props_junk/glassjug01_chunk03.mdl",
	"models/props_junk/vent001_chunk1.mdl",
	"models/props_junk/vent001_chunk2.mdl",
	"models/props_junk/vent001_chunk3.mdl",
	"models/props_junk/vent001_chunk4.mdl",
	"models/props_junk/vent001_chunk5.mdl",
	"models/props_junk/vent001_chunk6.mdl",
	"models/props_junk/vent001_chunk7.mdl",
	"models/props_junk/vent001_chunk8.mdl",
	"models/props_junk/wood_crate001a_chunk03.mdl",
	"models/props_wasteland/prison_toiletchunk01g.mdl",
	"models/props_wasteland/prison_toiletchunk01h.mdl",
	"models/props_wasteland/prison_toiletchunk01i.mdl",
	"models/props_wasteland/prison_toiletchunk01j.mdl",
	"models/props_wasteland/prison_toiletchunk01k.mdl",
	"models/props_wasteland/prison_toiletchunk01l.mdl",
	"models/props_wasteland/prison_toiletchunk01m.mdl",
	"models/props_wasteland/prison_toiletchunk01e.mdl",
	"models/props_wasteland/prison_toiletchunk01c.mdl",
	"models/props_wasteland/prison_sinkchunk001b.mdl",
	"models/props_wasteland/prison_sinkchunk001c.mdl",
	"models/props_wasteland/prison_sinkchunk001d.mdl",
	"models/props_wasteland/prison_sinkchunk001e.mdl",
	"models/props_wasteland/prison_sinkchunk001g.mdl",
	"models/props_wasteland/prison_sinkchunk001h.mdl",
	"models/Mechanics/gears/gear12x6_small.mdl",
	"models/Mechanics/gears/gear12x12.mdl",
	"models/props_phx/gears/bevel12.mdl",
	"models/props_phx/gears/bevel9.mdl",
	"models/Mechanics/gears2/gear_12t2.mdl",
	"models/Mechanics/gears/gear12x6_small.mdl",
	"models/Mechanics/gears/gear12x12.mdl",
	"models/props_phx/gears/bevel12.mdl",
	"models/props_phx/gears/bevel9.mdl",
	"models/Mechanics/gears2/gear_12t2.mdl"
}
ENT.EZconsumes={JMod.EZ_RESOURCE_TYPES.BASICPARTS}
--[[
ENT.EZconsumes={"ammo","power","parts","coolant"}
ENT.StaticPerfSpecs={
	MaxElectricity=100,
	SearchTime=7,
	SpecialTargetingHeights={["npc_rollermine"]=15},
	ShotCount=1,
	BarrelLength=29
}
ENT.DynamicPerfSpecs={
	MaxAmmo=300,
	SearchSpeed=.5,
	Cooling=1
}
--]]
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	if(self.CustomSetupDataTables)then
		self:CustomSetupDataTables()
	end
end
function ENT:InitPerfSpecs()
	local Grade=self:GetGrade()
	for specName,value in pairs(self.StaticPerfSpecs)do self[specName]=value end
	for specName,value in pairs(self.DynamicPerfSpecs)do
		local NewValue=value*JMod.EZ_GRADE_BUFFS[Grade]
		if(NewValue>2)then
			self[specName]=math.ceil(NewValue)
		else
			self[specName]=NewValue
		end
	end
end
function ENT:Upgrade(level)
	if not(level)then level=self:GetGrade()+1 end
	if(level>5)then return end
	self:SetGrade(level)
	self:InitPerfSpecs()
	self.UpgradeProgress={}
end
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*(self.SpawnHeight or 60)
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		JMod.Hint(ply, self.ClassName)
		return ent
	end
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)	
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:SetMass(200)
        end
		if(self.CustomInit)then
			self:CustomInit()
		end
		self.Durability = self.MaxDurability
		--
		if(self.EZupgradable)then
			self:SetGrade(1)
			self.UpgradeProgress={}
			self.UpgradeCosts=JMod.CalculateUpgradeCosts(JMod.Config.Craftables[self.PrintName] and JMod.Config.Craftables[self.PrintName].craftingReqs)
		end
	end
	function ENT:PhysicsCollide(data,physobj)
		if((data.Speed>80)and(data.DeltaTime>0.2))then
			self.Entity:EmitSound("Metal_Box.ImpactHard")
			if(data.Speed>800 and not self:IsPlayerHolding() and not (data.HitEntity and data.HitEntity.IsPlayerHolding and data.HitEntity:IsPlayerHolding()))then
				local Dam,World=DamageInfo(),game.GetWorld()
				Dam:SetDamage(data.Speed/3)
				Dam:SetAttacker(data.HitEntity or World)
				Dam:SetInflictor(data.HitEntity or World)
				Dam:SetDamageType(DMG_CRUSH)
				Dam:SetDamagePosition(data.HitPos)
				Dam:SetDamageForce(data.TheirOldVelocity)
				JMod.DamageSpark(self)
				self:TakeDamageInfo(Dam)
			end
		end
	end
	function ENT:ConsumeElectricity(amt)
		if not(self.GetElectricity)then return end
		amt=((amt or .2)/(self.ElectricalEfficiency or 1)^.5)/2
		local NewAmt=math.Clamp(self:GetElectricity()-amt,0,self.MaxElectricity)
		self:SetElectricity(NewAmt)
		if(NewAmt<=0 and self:GetState()>0)then self:TurnOff() end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self)then
			self:TakePhysicsDamage(dmginfo)
			self.Durability=self.Durability-dmginfo:GetDamage()/2
			if(self.Durability<=0)then self:Break(dmginfo) end
			if(self.Durability<=-100)then self:Destroy(dmginfo) end
		end
	end
	function ENT:FlingProp(mdl,force)
		if not(util.IsValidModel(mdl))then
			return
		end
		local Prop=ents.Create("prop_physics")
		local Size=(self:OBBMaxs()-self:OBBMins()):Length()
		Prop:SetPos(self:LocalToWorld(self:OBBCenter())+VectorRand()*math.random(1,Size/2))
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:Spawn()
		Prop:Activate()
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self,0,0)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*math.Rand(1,300)+self:GetUp()*100)
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
		if(force)then Phys:ApplyForceCenter(force/7) end
		SafeRemoveEntityDelayed(Prop,math.random(10,20))
	end
	function ENT:Break(dmginfo)
		if(self:GetState()==JMod.EZ_STATE_BROKEN)then return end
		self:SetState(JMod.EZ_STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do JMod.DamageSpark(self) end
		self.Durability=0
		local Force,GibNum=dmginfo:GetDamageForce(),math.min(JMod.Config.SupplyEffectMult*self:GetPhysicsObject():GetMass()/20,50)
		for i=1,GibNum do
			self:FlingProp(table.Random(self.PropModels),Force)
		end
		if(self.Pod)then -- machines with seats
			if(IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
			end
			self.Pod:Fire("lock","",0)
		end
		if(self.OnBreak)then self:OnBreak() end
	end
	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed=true
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do JMod.DamageSpark(self) end
		local Force,GibNum=dmginfo:GetDamageForce(),math.min(JMod.Config.SupplyEffectMult*self:GetPhysicsObject():GetMass()/10,100)
		for j=1,GibNum do
			self:FlingProp(table.Random(self.PropModels),Force)
		end
		if(self.Pod)then -- machines with seats
			if(IsValid(self.Pod:GetDriver()))then
				self.Pod:GetDriver():ExitVehicle()
			end
		end
		if(self.OnDestroy)then self:OnDestroy(dmginfo) end
		SafeRemoveEntityDelayed(self, 0.1)
	end
	function ENT:SFX(str,absPath)
		if(absPath)then
			sound.Play(str,self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,math.random(90,110))
		else
			sound.Play("snds_jack_gmod/"..str..".wav",self:GetPos()+Vector(0,0,20)+VectorRand()*10,60,100)
		end
	end
	function ENT:Whine(serious)
		local Time=CurTime()
		if(self.NextWhine<Time)then
			self.NextWhine=Time+4
			self:EmitSound("snds_jack_gmod/ezsentry_whine.wav",70,100)
			self:ConsumeElectricity(.05)
		end
	end
	function ENT:OnRemove()
		--
	end
	function ENT:TryLoadResource(typ,amt)
		if(amt<=0)then return 0 end
		for k,v in pairs(self.EZconsumes)do
			if(typ==v)then
				if(typ==JMod.EZ_RESOURCE_TYPES.POWER)then
					local Powa=self:GetElectricity()
					local Missing=self.MaxElectricity-Powa
					if(Missing<=0)then return 0 end
					if(Missing<self.MaxElectricity*.1)then return 0 end
					local Accepted=math.min(Missing,amt)
					self:SetElectricity(Powa+Accepted)
					self:EmitSound("snd_jack_turretbatteryload.wav",65,math.random(90,110))
					return math.ceil(Accepted)
				elseif(typ==JMod.EZ_RESOURCE_TYPES.MEDICALSUPPLIES)then
					local Supps=self:GetSupplies()
					local Missing=self.MaxSupplies-Supps
					if(Missing<=0)then return 0 end
					if(Missing<self.MaxSupplies*.1)then return 0 end
					local Accepted=math.min(Missing,amt)
					self:SetSupplies(Supps+Accepted)
					self:EmitSound("snd_jack_turretbatteryload.wav",65,math.random(90,110)) -- TODO: new sound here
					return math.ceil(Accepted)
				elseif(typ==JMod.EZ_RESOURCE_TYPES.BASICPARTS)then
					local Missing=self.MaxDurability-self.Durability
					if(Missing<=self.MaxDurability*.25)then return 0 end
					local Accepted=math.min(Missing,amt)
					self.Durability=self.Durability+Accepted
					if(self.Durability>=self.MaxDurability)then self:RemoveAllDecals() end
					self:EmitSound("snd_jack_turretrepair.wav",65,math.random(90,110))
					if(self.Durability>0)then
						if(self:GetState()==JMod.EZ_STATE_BROKEN)then self:SetState(JMod.EZ_STATE_OFF) end
					end
					return math.ceil(Accepted)
				elseif(typ==JMod.EZ_RESOURCE_TYPES.GAS)then
					local Fool=self:GetGas()
					local Missing=self.MaxGas-Fool
					if(Missing<=0)then return 0 end
					if(Missing<self.MaxGas*.1)then return 0 end
					local Accepted=math.min(Missing,amt)
					self:SetGas(Fool+Accepted)
					self:EmitSound("snds_jack_gmod/gas_load.wav",65,math.random(90,110))
					return math.ceil(Accepted)
				elseif(typ==JMod.EZ_RESOURCE_TYPES.AMMO)then
					local Ammo=self:GetAmmo()
					local Missing=self.MaxAmmo-Ammo
					if(Missing<=1)then return 0 end
					local Accepted=math.min(Missing,amt)
					self:SetAmmo(Ammo+Accepted)
					self:EmitSound("snd_jack_turretammoload.wav",65,math.random(90,110))
					return Accepted
				elseif(typ==JMod.EZ_RESOURCE_TYPES.MUNITIONS)then
					local Ammo=self:GetAmmo()
					local Missing=self.MaxAmmo-Ammo
					if(Missing<=1)then return 0 end
					local Accepted=math.min(Missing,amt)
					self:SetAmmo(Ammo+Accepted)
					self:EmitSound("snd_jack_turretammoload.wav",65,math.random(90,110))
					return Accepted
				elseif(typ==JMod.EZ_RESOURCE_TYPES.COOLANT)then
					local Kewl=self:GetCoolant()
					local Missing=100-Kewl
					if(Missing<10)then return 0 end
					local Accepted=math.min(Missing,amt)
					self:SetCoolant(Kewl+Accepted)
					self:EmitSound("snds_jack_gmod/liquid_load.wav",65,math.random(90,110))
					return math.ceil(Accepted)
				end
			end
		end
		return 0
	end
elseif(CLIENT)then
	--
end