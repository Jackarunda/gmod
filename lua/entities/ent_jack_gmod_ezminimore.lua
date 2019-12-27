-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Mini Claymore"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(0,180,0)
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
		ent.Owner=ply
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self.Entity:SetModelScale(.7,0)
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
		JMod_Colorify(self)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				if((self:GetState()==STATE_ARMED)and(math.random(1,5)==3))then
					self:Detonate()
				else
					self.Entity:EmitSound("Drywall.ImpactHard")
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
		JMod_Hint(activator,"arm","friends")
		local Alt=activator:KeyDown(IN_WALK)
		self.Owner=activator
		JMod_Colorify(self)
		if(State==STATE_OFF)then
			if(Alt)then
				self:Arm(activator)
			else
				activator:PickupObject(self)
			end
		else
			self:EmitSound("snd_jack_minearm.wav",60,70)
			self:SetState(STATE_OFF)
			self:DrawShadow(true)
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos=self:LocalToWorld(self:OBBCenter())
		local Up=(-self:GetForward()+self:GetUp()*.2):GetNormalized()
		local plooie=EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(.75)
		plooie:SetRadius(2)
		plooie:SetNormal(Up)
		util.Effect("eff_jack_minesplode",plooie,true,true)
		util.ScreenShake(SelfPos,99999,99999,1,500)
		self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
		JMod_Sploom(self.Owner,SelfPos,math.random(10,20))
		for i=1,500 do
			timer.Simple(i/5000,function()
				if not(IsValid(self))then return end
				local Dir=(Up+VectorRand()*.9):GetNormalized()
				Dir.z=Dir.z/4
				self:FireBullets({
					Attacker=self.Owner or game.GetWorld(),
					Damage=math.random(20,30)*JMOD_CONFIG.MinePower,
					Force=math.random(1,10),
					Num=1,
					Src=SelfPos,
					Tracer=1,
					Dir=Dir:GetNormalized(),
					Spread=Vector(0,0,0)
				})
				if(i==100)then util.BlastDamage(self,self.Owner or self,SelfPos,20*JMOD_CONFIG.MinePower,30*JMOD_CONFIG.MinePower) end
				if(i==500)then self:Remove() end
			end)
		end
	end
	function ENT:Arm(armer)
		local State=self:GetState()
		if(State~=STATE_OFF)then return end
		self.Owner=armer
		self:SetState(STATE_ARMING)
		self:EmitSound("snd_jack_minearm.wav",60,110)
		timer.Simple(3,function()
			if(IsValid(self))then
				if(self:GetState()==STATE_ARMING)then
					self:SetState(STATE_ARMED)
					self:DrawShadow(false)
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
	function ENT:Think()
		local State,Time,Dir=self:GetState(),CurTime(),(-self:GetForward()+self:GetUp()*.2):GetNormalized()
		if(State==STATE_ARMED)then
			for k,targ in pairs(ents.FindInSphere(self:GetPos()+Dir*200,150))do
				if(not(targ==self)and((targ:IsPlayer())or(targ:IsNPC())or(targ:IsVehicle())))then
					if((self:ShouldAttack(targ))and(self:CanSee(targ)))then
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
		self.Mdl=ClientsideModel("models/Weapons/w_clayjore.mdl")
		self.Mdl:SetMaterial("models/mat_jack_claymore")
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetModelScale(.8,0)
		self.Mdl:SetParent(false)
		self.Mdl:SetNoDraw(true)
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		--self:DrawModel()
		local Pos,Up,Right,Forward,Ang=self:GetPos(),self:GetUp(),self:GetRight(),self:GetForward(),self:GetAngles()
		self.Mdl:SetRenderOrigin(Pos-Up*5)
		Ang:RotateAroundAxis(Right,-15)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
		local State,Vary,Pos=self:GetState(),math.sin(CurTime()*50)/2+.5,self:GetPos()+Vector(0,0,4)+self:GetForward()*2
		if(State==STATE_ARMING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(Pos,20,20,Color(255,0,0))
			render.DrawSprite(Pos,10,10,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(Pos,30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(Pos,15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_ezminimore","EZ Mini Claymore")
end