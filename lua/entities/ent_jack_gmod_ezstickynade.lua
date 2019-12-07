-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Sticky Bomb"
ENT.Spawnable=true

ENT.Model = "models/grenades/sticky_grenade.mdl"
ENT.SpoonModel = "models/codww2/equipment/no, 74 st grenade_pin.mdl"
ENT.ModelScale = 1.5
ENT.HardThrowStr = 400
ENT.SoftThrowStr = 200

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
		self:SetBodygroup(3,1)
	end

	function ENT:Arm()
		self:SetBodygroup(2,1)
		self:SetState(JMOD_EZ_STATE_ARMED)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end

	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>30)then
			self:EmitSound("Grenade.ImpactHard")
		end
		if self:GetState() == JMOD_EZ_STATE_ARMED and !self.StickObj and data.HitEntity:GetClass() != "ent_jack_spoon" then
			self.StickObj = data.HitEntity
			self.Weld = nil
			if data.HitEntity:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then self.StickObj = data.HitEntity:GetBaseEnt() end
			if self.StickObj:IsPlayer() or self.StickObj:IsNPC() then
				self:SetParent(self.StickObj)
			else
				timer.Simple(0, function() self.Weld = constraint.Weld(self, data.HitEntity, 0, data.HitEntity:TranslateBoneToPhysBone(0)) end)
				timer.Simple(0.1, function() if !IsValid(self.Weld) then self.StickObj = nil end end)
			end
		end
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		local Sploom=ents.Create("env_explosion")
		Sploom:SetPos(SelfPos)
		Sploom:SetOwner(self.Owner or game.GetWorld())
		Sploom:SetKeyValue("iMagnitude",math.random(10,20))
		Sploom:Spawn()
		Sploom:Activate()
		Sploom:Fire("explode","",0)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Blam=EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(0.5)
		util.Effect("eff_jack_plastisplosion",Blam,true,true)
		util.ScreenShake(SelfPos,20,20,1,1000)
		util.BlastDamage(self,self.Owner or game.GetWorld(),SelfPos,175,100)
		--util.BlastDamage(self,self.Owner or game.GetWorld(),SelfPos,50,1000)
		JMod_WreckBuildings(self,SelfPos,0.5)
		JMod_BlastDoors(self,SelfPos,0.5)
		
		if IsValid(self.StickObj) and !self.StickObj:IsWorld() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage((self.StickObj:GetClass() == "gmod_sent_vehicle_fphysics_base" and 3000) or 300)
			dmginfo:SetDamageType((self.StickObj:GetClass() == "gmod_sent_vehicle_fphysics_base" and DMG_GENERIC) or DMG_BLAST)
			dmginfo:SetInflictor(self)
			dmginfo:SetAttacker(self.Owner)
			dmginfo:SetDamagePosition(SelfPos)
			dmginfo:SetDamageForce((self.StickObj:GetPos()-self:GetPos()):GetNormalized()*1000)
			self.StickObj:TakeDamageInfo(dmginfo)
		end
		
		self:Remove()
	end
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezstickynade","EZ Sticky Bomb")
end