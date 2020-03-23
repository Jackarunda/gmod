-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Target Designator"
ENT.NoSitAllowed=true
ENT.Spawnable=false -- todo: make spawnable when i figure out the proportional guidance code
ENT.AdminSpawnable=false
---
ENT.JModPreferredCarryAngles=Angle(0,90,0)
ENT.DamageThreshold=60
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
		self.Entity:SetModel("models/saraphines/binoculars/binoculars_sniper/binoculars_sniper.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>100)then
				self.Entity:EmitSound("Drywall.ImpactHard")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>self.DamageThreshold)then
			local Pos=self:GetPos()
			sound.Play("Metal_Box.Break",Pos)
			self:Remove()
		end
	end
	function ENT:Use(activator)
		if(activator:KeyDown(JMOD_CONFIG.AltFunctionKey))then
			activator:PickupObject(self)
		elseif not(activator:HasWeapon("wep_jack_gmod_ezdesignator"))then
			activator:Give("wep_jack_gmod_ezdesignator")
			activator:SelectWeapon("wep_jack_gmod_ezdesignator")
			activator:GetWeapon("wep_jack_gmod_ezdesignator"):SetElectricity(self.Electricity or 10)
			self:Remove()
		else
			activator:PickupObject(self)
		end
	end
	function ENT:Think()
		--
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezbuildkit","EZ Build Kit")
end