-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.PrintName="EZ Flashbang"
ENT.Category="JMod - EZ Explosives"
ENT.Spawnable=true
ENT.JModPreferredCarryAngles=Angle(0,140,0)
ENT.Model = "models/conviction/flashbang.mdl"
ENT.ModelScale = 1.5
ENT.SpoonScale = 2
if(SERVER)then
	function ENT:Arm()
		self:SetBodygroup(2,1)
		self:SetState(JMOD_EZ_STATE_ARMED)
		self:SpoonEffect()
		timer.Simple(2,function()
			if(IsValid(self))then self:Detonate() end
		end)
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())+vector_up*10
		local Tr=util.TraceLine({
			start=SelfPos,
			endpos=TargPos,
			filter={self,ent},
			mask=MASK_SHOT+MASK_WATER
		})
		return not Tr.Hit
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:GetPos()+Vector(0,0,10)
		JMod_Sploom(self.Owner,self:GetPos(),20)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,140)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,140)
		local plooie=EffectData()
		plooie:SetOrigin(SelfPos)
		util.Effect("eff_jack_gmod_flashbang",plooie,true,true)
		util.ScreenShake(SelfPos,20,20,.2,1000)
		self:SetColor(Color(0,0,0))
		timer.Simple(.1,function()
			if not(IsValid(self))then return end
			util.BlastDamage(self,self.Owner or self,SelfPos,1000,2)
			local Time=CurTime()
			for k,v in pairs(ents.FindInSphere(SelfPos,500))do
				if((v:IsNPC())and(self:CanSee(v))and(v.SetNPCState))then
					v:SetNPCState(NPC_STATE_PLAYDEAD)
					timer.Simple(math.Rand(3,5),function()
						if(IsValid(v))then v:SetNPCState(NPC_STATE_ALERT) end
					end)
				end
			end
		end)
		SafeRemoveEntityDelayed(self,10)
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezflashbang","EZ Flashbang Grenade")
end