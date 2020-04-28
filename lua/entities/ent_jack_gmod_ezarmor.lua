-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Armor"
ENT.NoSitAllowed=true
ENT.Spawnable=false
ENT.AdminSpawnable=false
---
ENT.JModEZstorable=true
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod_Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Specs=JMod_ArmorTable[self.Slot][self.ArmorName]
		self.Entity:SetModel(self.Specs.mdl)
		self.Entity:SetMaterial(self.Specs.mat or "")
		--self.Entity:PhysicsInitBox(Vector(-10,-10,-10),Vector(10,10,10))
		if((self.ModelScale)and not(self.Specs.gayPhysics))then self:SetModelScale(self.ModelScale) end
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(10)
		self.Durability=self.Durability or self.Specs.dur
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("Body.ImpactSoft")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=5)then
			self.Durability=self.Durability-dmginfo:GetDamage()/2
			if(self.Durability<=0)then self:Remove() end
		end
	end
	function ENT:Use(activator)
		
		local Alt=activator:KeyDown(JMOD_CONFIG.AltFunctionKey)
		if(Alt)then
			if((activator.JackyArmor)and(#table.GetKeys(activator.JackyArmor)>0))then return end
			net.Start("JMod_ArmorColor")
			net.WriteEntity(self)
			net.Send(activator)
            if self.ArmorName == "Headset" then
                JMod_Hint(activator, "armor friends", self)
            end
		else
			activator:PickupObject(self)
            JMod_Hint(activator, "armor wear", self)
		end
		--activator:EmitSound("snd_jack_clothequip.wav",70,100)
		--activator:EmitSound("snd_jack_gmod/armorstep1.wav",70,100)--5
		--activator:EmitSound("snd_jack_gear1.wav",70,100)--6
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezarmor","EZ Armor")
end