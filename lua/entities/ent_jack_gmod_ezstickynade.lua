-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Sticky Bomb"
ENT.Spawnable=true

ENT.Model = "models/grenades/sticky_grenade.mdl"
ENT.ModelScale = 2.25

ENT.SpoonModel = "models/grenades/sticky_grenade_pin.mdl"
ENT.SpoonSound = "physics/cardboard/cardboard_box_impact_soft2.wav"

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:SetBodygroup(2,1)
		self:EmitSound("weapons/pinpull.wav",60,100)
	end

	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMED)
		self:SpoonEffect()
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
			self.GotParented=true
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
	
	function ENT:CustomThink()
		if(self.GotParented)then
			if not(IsValid(self.StickObj))then self:SetParent(nil);return end
			if((self.StickObj.Health)and not(self.StickObj:Health()>0))then self:SetParent(nil);return end
		end
	end

	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()
		JMod_Sploom(self.Owner or game.GetWorld(),SelfPos,160)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		local Blam=EffectData()
		Blam:SetOrigin(SelfPos)
		Blam:SetScale(0.5)
		util.Effect("eff_jack_plastisplosion",Blam,true,true)
		util.ScreenShake(SelfPos,20,20,1,1000)
		JMod_WreckBuildings(self,SelfPos,0.5)
		JMod_BlastDoors(self,SelfPos,0.5)
		
		if IsValid(self.StickObj) and !self.StickObj:IsWorld() then
			local dmginfo = DamageInfo()
			local Helf=(self.StickObj.GetMaxHealth and self.StickObj:GetMaxHealth()) or 100
			dmginfo:SetDamage((Helf>2000 and 1500) or 200)
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