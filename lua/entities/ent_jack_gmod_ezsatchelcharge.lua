-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.PrintName="EZ Satchel Charge"
ENT.Spawnable=true

ENT.Model = "models/grenades/satchel_charge.mdl"
ENT.SpoonEnt = nil
ENT.ModelScale = 2
ENT.Mass = 20
ENT.HardThrowStr = 400
ENT.SoftThrowStr = 200

DEFINE_BASECLASS(ENT.Base)

if(SERVER)then

	function ENT:Initialize()
		BaseClass.Initialize(self)
		
		local plunger = ents.Create("ent_jack_gmod_ezsatchelcharge_plunger")
		plunger:SetPos(self:GetPos()+self:GetForward()*10)
		plunger:SetAngles(self:GetAngles())
		plunger:Spawn()
		plunger.Satchel = self
		plunger.Owner = self.Owner
		self.Plunger = plunger
		timer.Simple(0, function() plunger:SetParent(self) end)
	end

	function ENT:Prime()
		self:EmitSound("weapons/c4/c4_plant.wav")
		self:SetState(JMOD_EZ_STATE_PRIMED)
		self.Plunger:SetParent(nil)
		constraint.NoCollide(self, self.Plunger, 0, 0)
	end

	function ENT:Arm()
		self:EmitSound("buttons/button5.wav", 80, 110)
		self:SetState(JMOD_EZ_STATE_ARMED)
	end
	
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(0,function()
			if(IsValid(self))then
				local SelfPos,PowerMult=self:GetPos(), 1.2
				--
				local Blam=EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult)
				util.Effect("eff_jack_plastisplosion",Blam,true,true)
				util.ScreenShake(SelfPos,99999,99999,1,750*PowerMult)
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
					util.BlastDamage(Infl,Att,SelfPos,300*PowerMult,300*PowerMult)
					if((IsValid(self.StuckTo))and(IsValid(self.StuckStick)))then
						util.BlastDamage(Infl,Att,SelfPos,50*PowerMult,600*PowerMult)
					end
					self:Remove()
				end)
			end
		end)
	end
	
	function ENT:OnRemove()
		if IsValid(self.Plunger) then
			SafeRemoveEntityDelayed(self.Plunger, 3)
		end
	end
	
elseif(CLIENT)then

	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local State=self:GetState()
		local pos = self:GetPos() + self:GetUp() * 2.8 + self:GetRight() * (-2.6) + self:GetForward() * (-3)
		if(State==JMOD_EZ_STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos,10,10,Color(255,0,0))
			render.DrawSprite(pos,5,5,Color(255,255,255))
		elseif State == JMOD_EZ_STATE_ARMED then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(pos,5,5,Color(255,100,0))
			render.DrawSprite(pos,2,2,Color(255,255,255))
		end
	end

	language.Add("ent_jack_gmod_ezsatchelcharge","EZ Satchel Charge")
end