-- Jackarunda 2019
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezmininade"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.PrintName="EZminiNade-Proximity"
ENT.Spawnable=true

ENT.Material = "models/mats_jack_nades/gnd_red"
ENT.MiniNadeDamageMin = 60
ENT.MiniNadeDamageMax = 100
ENT.Hints = {"grenade", "mininade", "friends"}

ENT.BlacklistedNPCs={"bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground"}
ENT.WhitelistedNPCs={"npc_rollermine"}

local BaseClass = baseclass.Get(ENT.Base)

if(SERVER)then

	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())+vector_up
		local Tr=util.TraceLine({
			start=SelfPos,
			endpos=TargPos,
			filter={self,ent,self.AttachedBomb},
			mask=MASK_SHOT+MASK_WATER
		})
		print(Tr.Entity)
		return not Tr.Hit
	end
	
	function ENT:ShouldAttack(ent)
		if not(IsValid(ent))then return false end
		if(ent:IsWorld())then return false end
		local Gaymode,PlayerToCheck=engine.ActiveGamemode(),nil
		if(ent:IsPlayer())then
			PlayerToCheck=ent
		elseif(ent:IsNPC())then
			local Class=ent:GetClass()
			if(table.HasValue(self.WhitelistedNPCs,Class))then return true end
			if(table.HasValue(self.BlacklistedNPCs,Class))then return false end
			return ent:Health()>0
		elseif(ent:IsVehicle())then
			PlayerToCheck=ent:GetDriver()
		end
		if(IsValid(PlayerToCheck))then
			if(PlayerToCheck.EZkillme)then return true end -- for testing
			if((self.Owner)and(PlayerToCheck==self.Owner))then return false end
			local Allies=(self.Owner and self.Owner.JModFriends)or {}
			if(table.HasValue(Allies,PlayerToCheck))then return false end
			local OurTeam=nil
			if(IsValid(self.Owner))then OurTeam=self.Owner:Team() end
			if(Gaymode=="sandbox")then return PlayerToCheck:Alive() end
			if(OurTeam)then return PlayerToCheck:Alive() and PlayerToCheck:Team()~=OurTeam end
			return PlayerToCheck:Alive()
		end
		return false
	end
	
	function ENT:Arm()
		self:SetState(JMOD_EZ_STATE_ARMING)
		self:SetBodygroup(2,1)
		timer.Simple(1, function()
			if IsValid(self) then
				self:EmitSound("snd_jack_minearm.wav",60,110)
				self:SetState(JMOD_EZ_STATE_ARMED)
			end
		end)
	end
	
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		
		if State==JMOD_EZ_STATE_ARMED then
			local Range=80
			if(IsValid(self.AttachedBomb))then Range=120 end
			for k,targ in pairs(ents.FindInSphere(self:GetPos(),Range))do
				if(not(targ==self)and((targ:IsPlayer())or(targ:IsNPC())or(targ:IsVehicle())))then
					if((self:ShouldAttack(targ))and(self:CanSee(targ)))then
						self:SetState(JMOD_EZ_STATE_WARNING)
						sound.Play("snds_jack_gmod/mine_warn.wav",self:GetPos()+Vector(0,0,30),60,100)
						timer.Simple(math.Rand(.15,.4)*JMOD_CONFIG.MineDelay,function()
							if(IsValid(self))then
								if(self:GetState()==JMOD_EZ_STATE_WARNING)then self:Detonate() end
							end
						end)
					end
				end
			end
			self:NextThink(Time+.3)
			return true
		else
			BaseClass.Think(self)
		end
	end

elseif(CLIENT)then

	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==JMOD_EZ_STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+self:GetUp()*2,10,10,Color(255,0,0))
			render.DrawSprite(self:GetPos()+self:GetUp()*2,5,5,Color(255,255,255))
		elseif(State==JMOD_EZ_STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+self:GetUp()*2,15*Vary,15*Vary,Color(255,0,0))
			render.DrawSprite(self:GetPos()+self:GetUp()*2,7*Vary,7*Vary,Color(255,255,255))
		end
	end
	
	language.Add("ent_jack_gmod_eznade_proximity","EZminiNade-Proximity")
end