AddCSLuaFile()
ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "RPG"
ENT.Author			= "JMod - LEGACY NPCs"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/weapons/w_missile.mdl")
		self:PhysicsInitBox(Vector(5,5,5),Vector(-5,-5,-5))
		self:SetMoveType(MOVETYPE_FLY)
		self:SetHealth(1)

		local phys=self.Entity:GetPhysicsObject()
		if(phys:IsValid())then
			phys:Wake()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
		end
		
		self.ai_sound=ents.Create("ai_sound")
		self.ai_sound:SetPos(self:GetPos())
		self.ai_sound:SetKeyValue("volume","100")
		self.ai_sound:SetKeyValue("duration","8")
		self.ai_sound:SetKeyValue("soundtype","8")
		self.ai_sound:SetParent(self)
		self.ai_sound:Spawn()
		self.ai_sound:Activate()
		self.ai_sound:Fire("EmitAISound","",1)
		
		self.Sound=CreateSound(self,"weapons/rpg/rocket1.wav")
		self.Sound:Play()
		
		self.Asploded=false
		
		self.LaunchTime=CurTime()
		
		SafeRemoveEntityDelayed(self,15)
	end

	function ENT:OnRemove()
		self.Sound:Stop()
		self.ai_sound:Remove()
	end

	function ENT:OnTakeDamage( dmg )
		self:Explode()
	end

	function ENT:Think()
		//local FirstNoseTrace=util.QuickTrace(self:GetPos(),self:GetForward()*50,{self,self.Owner})
		//local SecondNoseTrace=util.QuickTrace(self:GetPos()*VectorRand()*20,self:GetForward()*50+VectorRand()*20,{self,self.Owner})
		//if((FirstNoseTrace.Hit)or(SecondNoseTrace.Hit))then
		//	self:Explode()
		//end
		local Ayngul=self:GetAngles()
		self:SetAngles(Angle(Ayngul.p+0.1,Ayngul.y,Ayngul.r))
		local Speed=(CurTime()-self.LaunchTime)*7500
		self:SetLocalVelocity(self:GetForward()*Speed)
		local Smewk=EffectData()
		Smewk:SetOrigin(self:GetPos())
		Smewk:SetNormal(-self:GetForward())
		local darp=math.Rand(155,255)
		Smewk:SetAngles(Angle(darp,darp,darp))
		util.Effect("eff_jack_gmod_npcrocketsmoke",Smewk)
		self:NextThink(CurTime()+0.02)
		return true
	end

	function ENT:Touch(ent)
		if(ent:GetClass()=="npc_helicopter")then
			ent.Damage=ent.Damage+200
			if(ent.Damage>500)then
				self:KillHelicopter(ent)
			end
		end
		if not(ent==self.Owner)then self:Explode() end
	end

	function ENT:Explode()
		if(self.Asploded)then return end
		self.Asploded=true
		local explo=EffectData()
		explo:SetOrigin(self:GetPos())
		util.Effect("explosion",explo)
		if(IsValid(self.Owner))then
			util.BlastDamage(self,self.Owner,self:GetPos(),250,90)
		else
			util.BlastDamage(self,game.GetWorld(),self:GetPos(),250,90)
		end
		self:Remove()
	end

	function ENT:KillHelicopter(heli)
		local Vel=heli:GetVelocity()

		local Piece=ents.Create("prop_physics")
		Piece:SetModel("models/Gibs/helicopter_brokenpiece_01.mdl")
		Piece:SetPos(heli:GetPos())
		Piece:Spawn()
		Piece:Activate()
		Piece:GetPhysicsObject():SetMass(100)
		Piece:GetPhysicsObject():SetVelocity(Vel)
		SafeRemoveEntityDelayed(Piece,20)
		
		Piece=ents.Create("prop_physics")
		Piece:SetModel("models/Gibs/helicopter_brokenpiece_02.mdl")
		Piece:SetPos(heli:GetPos())
		Piece:Spawn()
		Piece:Activate()
		Piece:GetPhysicsObject():SetMass(100)
		Piece:GetPhysicsObject():SetVelocity(Vel)
		SafeRemoveEntityDelayed(Piece,20)
		
		Piece=ents.Create("prop_physics")
		Piece:SetModel("models/Gibs/helicopter_brokenpiece_03.mdl")
		Piece:SetPos(heli:GetPos())
		Piece:Spawn()
		Piece:Activate()
		Piece:GetPhysicsObject():SetMass(100)
		Piece:GetPhysicsObject():SetVelocity(Vel)
		SafeRemoveEntityDelayed(Piece,20)
		
		Piece=ents.Create("prop_physics")
		Piece:SetModel("models/Gibs/helicopter_brokenpiece_04_cockpit.mdl")
		Piece:SetPos(heli:GetPos())
		Piece:Spawn()
		Piece:Activate()
		Piece:GetPhysicsObject():SetMass(100)
		Piece:GetPhysicsObject():SetVelocity(Vel)
		SafeRemoveEntityDelayed(Piece,20)
		
		Piece=ents.Create("prop_physics")
		Piece:SetModel("models/Gibs/helicopter_brokenpiece_05_tailfan.mdl")
		Piece:SetPos(heli:GetPos())
		Piece:Spawn()
		Piece:Activate()
		Piece:GetPhysicsObject():SetMass(100)
		Piece:GetPhysicsObject():SetVelocity(Vel)
		SafeRemoveEntityDelayed(Piece,20)
		
		Piece=ents.Create("prop_physics")
		Piece:SetModel("models/Gibs/helicopter_brokenpiece_06_body.mdl")
		Piece:SetPos(heli:GetPos())
		Piece:Spawn()
		Piece:Activate()
		Piece:GetPhysicsObject():SetMass(100)
		Piece:GetPhysicsObject():SetVelocity(Vel)
		SafeRemoveEntityDelayed(Piece,20)
		
		WorldSound("npc/combine_gunship/gunship_explode2.wav",heli:GetPos(),100,120)
		
		heli:Remove()
	end
elseif(CLIENT)then
	--killicon.Add("ent_jack_rocket","HUD/killicons/weapon_rpg",Color(255,80,0,255))

	function ENT:Initialize()
	end

	function ENT:Draw()
		self.Entity:DrawModel()
	end
end