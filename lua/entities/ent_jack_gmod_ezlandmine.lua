-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Land Mine"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.BlacklistedNPCs={"bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground"}
ENT.WhitelistedNPCs={"npc_rollermine"}
---
local STATE_BROKEN,STATE_OFF,STATE_ARMING,STATE_ARMED,STATE_WARNING=-1,0,1,2,3
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
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
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props_pipes/pipe02_connector01.mdl")
		self.Entity:SetMaterial("models/jacky_camouflage/digi2")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		self:GetPhysicsObject():SetMass(10)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				if((self:GetState()==STATE_ARMED)and(math.random(1,5)==3))then
					self:Detonate()
				else
					self.Entity:EmitSound("Weapon.ImpactHard")
				end
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(dmginfo:GetDamage()>=5)then
			local Pos,State=self:GetPos(),self:GetState()
			if((State==STATE_ARMED)and(math.random(1,6)==3))then
				self:Detonate()
			elseif((math.random(1,6)==3)and not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator)
		local State=self:GetState()
		if(State<0)then return end
		
		local Alt=activator:KeyDown(JMOD_CONFIG.AltFunctionKey)
		if(State==STATE_OFF)then
			if(Alt)then
				JMod_Owner(self,activator)
				net.Start("JMod_MineColor")
                    net.WriteEntity(self)
				net.Send(activator)
			else
				activator:PickupObject(self)
                JMod_Hint(activator, "arm", self)
			end
		else
			self:EmitSound("snd_jack_minearm.wav",60,70)
			self:SetState(STATE_OFF)
			JMod_Owner(self,activator)
			self:DrawShadow(true)
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:LocalToWorld(self:OBBCenter())
		local Up=Vector(0,0,1)
		local EffectType=1
		local Traec=util.QuickTrace(self:GetPos(),Vector(0,0,-5),self.Entity)
		if(Traec.Hit)then
			if((Traec.MatType==MAT_DIRT)or(Traec.MatType==MAT_SAND))then
				EffectType=1
			elseif((Traec.MatType==MAT_CONCRETE)or(Traec.MatType==MAT_TILE))then
				EffectType=2
			elseif((Traec.MatType==MAT_METAL)or(Traec.MatType==MAT_GRATE))then
				EffectType=3
			elseif(Traec.MatType==MAT_WOOD)then
				EffectType=4
			end
		else
			EffectType=5
		end
		local plooie=EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(1)
		plooie:SetRadius(EffectType)
		plooie:SetNormal(Up)
		util.Effect("eff_jack_minesplode",plooie,true,true)
		util.ScreenShake(SelfPos,99999,99999,1,500)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		JMod_Sploom(self.Owner,SelfPos,math.random(10,20))
		JMod_FragSplosion(self,SelfPos,1000,20*JMOD_CONFIG.MinePower,3000,self.Owner,Up,1.2,3)
		self:Remove()
	end
	function ENT:Arm(armer)
		local State=self:GetState()
		if(State~=STATE_OFF)then return end
        JMod_Hint(armer, "friends", self)
		JMod_Owner(self,armer)
		self:SetState(STATE_ARMING)
		self:EmitSound("snd_jack_minearm.wav",60,110)
		timer.Simple(3,function()
			if(IsValid(self))then
				if(self:GetState()==STATE_ARMING)then
					self:SetState(STATE_ARMED)
					self:DrawShadow(false)
					local Tr=util.QuickTrace(self:GetPos()+Vector(0,0,20),Vector(0,0,-40),self)
					if(Tr.Hit)then
						constraint.Weld(Tr.Entity,self,0,0,20000,false,false)
					end
				end
			end
		end)
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())+vector_up
		local Tr=util.TraceLine({
			start=SelfPos,
			endpos=TargPos,
			filter={self,ent},
			mask=MASK_SHOT+MASK_WATER
		})
		return not Tr.Hit
	end
	function ENT:Think()
		local State,Time=self:GetState(),CurTime()
		if(State==STATE_ARMED)then
			for k,targ in pairs(ents.FindInSphere(self:GetPos(),100))do
				if(not(targ==self)and((targ:IsPlayer())or(targ:IsNPC())or(targ:IsVehicle())))then
					if((JMod_ShouldAttack(self,targ))and(self:CanSee(targ)))then
						self:SetState(STATE_WARNING)
						sound.Play("snds_jack_gmod/mine_warn.wav",self:GetPos()+Vector(0,0,30),60,100)
						timer.Simple(math.Rand(.15,.4)*JMOD_CONFIG.MineDelay,function()
							if(IsValid(self))then
								if(self:GetState()==STATE_WARNING)then self:Detonate() end
							end
						end)
					end
				end
			end
			self:NextThink(Time+.3)
			return true
		end
	end
	function ENT:OnRemove()
		--aw fuck you
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),20,20,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),10,10,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+Vector(0,0,4),30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(self:GetPos()+Vector(0,0,4),15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezlandmine","EZ Landmine")
end