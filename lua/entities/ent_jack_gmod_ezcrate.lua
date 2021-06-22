-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.PrintName="EZ Resource Crate"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Misc."
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.DamageThreshold=120
---
ENT.MaxResource=1
ENT.ChildEntity=""
ENT.ChildEntityResourceAmount=0
ENT.MainTitleWord="RESOURCES"
ENT.ResourceUnit="Units"
---
ENT.SupplyTypes={ -- A list of all possible resources, excl. mines and detpacks
	["generic"]={
		MaxResource=1,
		ChildEntity="",
		ChildEntityResourceAmount=0,
		MainTitleWord="RESOURCES",
		ResourceUnit="Units",
	},
	["advparts"]={
		MaxResource=JMod.EZadvPartBoxSize*JMod.EZpartsCrateSize,
		ChildEntity="ent_jack_gmod_ezadvparts",
		ChildEntityResourceAmount=JMod.EZadvPartBoxSize,
		MainTitleWord="ADV.PARTS",
		ResourceUnit="Units"
	},
	["advtextiles"]={
		MaxResource=JMod.EZadvPartBoxSize*JMod.EZpartsCrateSize,
		ChildEntity="ent_jack_gmod_ezadvtextiles",
		ChildEntityResourceAmount=JMod.EZadvPartBoxSize,
		MainTitleWord="ADV.TEXTILES",
		ResourceUnit="Units"
	},
	["ammo"]={
		MaxResource=JMod.EZammoBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezammo",
		ChildEntityResourceAmount=JMod.EZammoBoxSize,
		MainTitleWord="AMMO",
		ResourceUnit="Count"
	},
	["munitions"]={
		MaxResource=JMod.EZammoBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezmunitions",
		ChildEntityResourceAmount=JMod.EZammoBoxSize,
		MainTitleWord="MUNITIONS",
		ResourceUnit="Count"
	},
	["chemicals"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezchemicals",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="CHEMICALS",
		ResourceUnit="Units"
	},
	["explosives"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezexplosives",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="EXPLOSIVES",
		ResourceUnit="Units"
	},
	["fuel"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezfuel",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="FUEL",
		ResourceUnit="Units"
	},
	["propellant"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezpropellant",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="PROPELLANT",
		ResourceUnit="Units"
	},
	["gas"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezgas",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="GAS",
		ResourceUnit="Units"
	},
	["medsupplies"]={
		MaxResource=JMod.EZmedSupplyBoxSize*JMod.EZpartsCrateSize,
		ChildEntity="ent_jack_gmod_ezmedsupplies",
		ChildEntityResourceAmount=JMod.EZmedSupplyBoxSize,
		MainTitleWord="MED.SUPPLIES",
		ResourceUnit="Units"
	},
	["parts"]={ 
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZpartsCrateSize,
		ChildEntity="ent_jack_gmod_ezparts",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="PARTS",
		ResourceUnit="Units"
	},
	["power"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezbattery",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="BATTERIES",
		ResourceUnit="Charge"
	},
	["nutrients"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_eznutrients",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="RATIONS",
		ResourceUnit="Units"
	},
	["coolant"]={
		MaxResource=JMod.EZbasicResourceBoxSize*JMod.EZcrateSize,
		ChildEntity="ent_jack_gmod_ezcoolant",
		ChildEntityResourceAmount=JMod.EZbasicResourceBoxSize,
		MainTitleWord="COOLANT",
		ResourceUnit="Units"
	}
}
---
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"Resource")
	self:NetworkVar("String",0,"ResourceType")
end
function ENT:ApplySupplyType(typ) 
	if not(self.SupplyTypes[typ])then return end
	self:SetResourceType(typ)
	self.EZsupplies=typ
	self.MaxResource=self.SupplyTypes[typ].MaxResource
	self.ChildEntity=self.SupplyTypes[typ].ChildEntity
	self.ChildEntityResourceAmount=self.SupplyTypes[typ].ChildEntityResourceAmount
	self.MainTitleWord=self.SupplyTypes[typ].MainTitleWord
	self.ResourceUnit=self.SupplyTypes[typ].ResourceUnit
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_junk/wood_crate002a.mdl")
		--self:SetModelScale(1.5,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		self:SetResource(0)
		self:ApplySupplyType("generic")
		self.EZconsumes={}
		for k,v in pairs(self.SupplyTypes) do table.insert(self.EZconsumes,k) end
		self.NextLoad=0
		---
		timer.Simple(.01,function() self:CalcWeight() end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>100)then
				self.Entity:EmitSound("Wood_Crate.ImpactHard")
				self.Entity:EmitSound("Wood_Box.ImpactHard")
			end
		end
	end
	function ENT:CalcWeight()
		local Frac=self:GetResource()/self.MaxResource
		self:GetPhysicsObject():SetMass(100+Frac*300)
		self:GetPhysicsObject():Wake()
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>self.DamageThreshold)then
			local Pos=self:GetPos()
			sound.Play("Wood_Crate.Break",Pos)
			sound.Play("Wood_Box.Break",Pos)
			if(self.ChildEntity != "" and self:GetResource()>0)then 
				for i=1,math.floor(self:GetResource()/self.ChildEntityResourceAmount) do
					local Box=ents.Create(self.ChildEntity)
					Box:SetPos(Pos+self:GetUp()*20)
					Box:SetAngles(self:GetAngles())
					Box:Spawn()
					Box:Activate()
				end
			end
			self:Remove()
		end
	end
	function ENT:Use(activator)
		JMod.Hint(activator, "crate", self)
		local Resource=self:GetResource()
		if(Resource<=0)then return end
		local Box,Given=ents.Create(self.ChildEntity),math.min(Resource,self.ChildEntityResourceAmount)
		Box:SetPos(self:GetPos()+self:GetUp()*5)
		Box:SetAngles(self:GetAngles())
		Box:Spawn()
		Box:Activate()
		Box:SetResource(Given)
		activator:PickupObject(Box)
		Box.NextLoad=CurTime()+2
		self:SetResource(Resource-Given)
		self:EmitSound("Ammo_Crate.Close")
		self:CalcWeight()
		if(self:GetResource()<=0)then self:ApplySupplyType("generic") end
	end
	function ENT:Think()
		--pfahahaha
	end
	function ENT:OnRemove()
		--aw fuck you
	end
	function ENT:TryLoadResource(typ,amt)
		local Time=CurTime()
		if(self.NextLoad>Time)then return 0 end
		if(amt<=0)then return 0 end
		-- If unloaded, we set our type to the item type
		if(self:GetResource()<=0 and self:GetResourceType()=="generic" and self.SupplyTypes[typ])then 
			self:ApplySupplyType(typ)
		end
		-- Consider the loaded type
		if(typ==self:GetResourceType())then
			local Resource=self:GetResource()
			local Missing=self.MaxResource-Resource
			if(Missing<=0)then return 0 end
			local Accepted=math.min(Missing,amt)
			self:SetResource(Resource+Accepted)
			self:CalcWeight()
			self.NextLoad=Time+.5
			return Accepted
		end
		return 0
	end
elseif(CLIENT)then
	local TxtCol=Color(10,10,10,220)
	function ENT:Draw()
		local Ang,Pos=self:GetAngles(),self:GetPos()
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(Pos))
		local DetailDraw=Closeness<45000 -- cutoff point is 500 units when the fov is 90 degrees
		local i=self:GetResourceType()
		self:DrawModel()
		if(DetailDraw)then
			local Up,Right,Forward,Resource=Ang:Up(),Ang:Right(),Ang:Forward(),tostring(self:GetResource())
			Ang:RotateAroundAxis(Ang:Right(),90)
			Ang:RotateAroundAxis(Ang:Up(),-90)
			cam.Start3D2D(Pos+Up*10-Forward*20+Right,Ang,.15)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-S",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(self.SupplyTypes[i].MainTitleWord,"JMod-Stencil",0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Resource.." "..self.SupplyTypes[i].ResourceUnit,"JMod-Stencil-S",0,70,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
			---
			Ang:RotateAroundAxis(Ang:Right(),180)
			cam.Start3D2D(Pos+Up*10+Forward*20-Right,Ang,.15)
			draw.SimpleText("JACKARUNDA INDUSTRIES","JMod-Stencil-S",0,0,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(self.SupplyTypes[i].MainTitleWord,"JMod-Stencil",0,15,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			draw.SimpleText(Resource.." "..self.SupplyTypes[i].ResourceUnit,"JMod-Stencil-S",0,70,TxtCol,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
			cam.End3D2D()
		end
	end
	language.Add("ent_jack_gmod_ezcrate","EZ Resource Crate")
end
