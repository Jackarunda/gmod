-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Gebalte Ladung"
ENT.Spawnable=true

ENT.Model = "models/grenades/bundle_grenade.mdl"
ENT.Material="models/mats_jack_nades/stick_grenade"
ENT.ModelScale = 1.25
ENT.SpoonModel = "models/grenades/stick_grenade_cap.mdl"
ENT.HardThrowStr = 200
ENT.SoftThrowStr = 100
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.EZspinThrow=true
--ENT.EZstorageVolumeOverride=2

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	function ENT:Prime()
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self:EmitSound("weapons/pinpull.wav",60,100)
	end

	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMED)
		self:SetBodygroup(4,1)
		timer.Simple(4,function()
			if(IsValid(self))then self:Detonate() end
		end)
		self:SetBodygroup(3,1)
		self:SpoonEffect()
	end
	
	function ENT:ShiftAltUse(activator,onOff)
		if not(onOff)then return end
		self.Splitterring=not self.Splitterring
		if(self.Splitterring)then
			self:SetMaterial("models/mats_jack_nades/stick_grenade_frag")
			self:EmitSound("snds_jack_gmod/metal_shf.wav",60,120)
		else
			self:SetMaterial("models/mats_jack_nades/stick_grenade")
			self:EmitSound("snds_jack_gmod/metal_shf.wav",60,80)
		end
	end
	
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(0,function()
			if(IsValid(self))then
				local SelfPos,PowerMult=self:GetPos(),3
				--
				local Blam=EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult/1.5)
				util.Effect("eff_jack_plastisplosion",Blam,true,true)
				util.ScreenShake(SelfPos,99999,99999,1,750*PowerMult)
				for i=1,2 do sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,140,math.random(80,110)) end
				for i=1,PowerMult do sound.Play("BaseExplosionEffect.Sound",SelfPos,120,math.random(90,110)) end
				self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
				timer.Simple(.1,function()
					for i=1,5 do
						local Tr=util.QuickTrace(SelfPos,VectorRand()*20)
						if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
					end
				end)
				JMod_WreckBuildings(self,SelfPos,PowerMult)
				JMod_BlastDoors(self,SelfPos,PowerMult)
				timer.Simple(0,function()
					local ZaWarudo=game.GetWorld()
					local Infl,Att=(IsValid(self) and self) or ZaWarudo,(IsValid(self) and IsValid(self.Owner) and self.Owner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl,Att,SelfPos,125*PowerMult,180*PowerMult)
					self:Remove()
				end)
			end
		end)
	end
	
elseif(CLIENT)then
	language.Add("ent_jack_gmod_ezsticknadebundle","EZ Gebalte Ladung")
end