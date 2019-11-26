-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Grenade - Proximity"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.JModEZproximityNade=true
ENT.BlacklistedNPCs={"bullseye_strider_focus","npc_turret_floor","npc_turret_ceiling","npc_turret_ground"}
ENT.WhitelistedNPCs={"npc_rollermine"}
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED,STATE_WARNING=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
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
		self.Entity:SetModel("models/weapons/w_grenade.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>30)then
			self:GetPhysicsObject():ApplyForceCenter(-data.HitNormal*math.Clamp(data.Speed*2, 50, 150))
			self.Entity:EmitSound("weapons/flashbang/grenade_hit1.wav",65,math.random(80,120))
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(Dmg>=4)then
			local Pos,State,DetChance=self:GetPos(),self:GetState(),0
			if(State==STATE_ARMED)then DetChance=DetChance+.3 end
			if(dmginfo:IsDamageType(DMG_BLAST))then DetChance=DetChance+Dmg/150 end
			if(math.Rand(0,1)<DetChance)then self:Detonate() end
			if((math.random(1,10)==3)and not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		self.Owner=Dude
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(IN_WALK)
			if(State==STATE_OFF and Alt)then
				timer.Create("ProxNadeBeep_"..self:EntIndex(), 1, 5, function() self:EmitSound("weapons/c4/c4_beep1.wav", 65, 150) end)
				timer.Simple(6, function() if IsValid(self) then self:EmitSound("snd_jack_minearm.wav",60,110) self:SetState(STATE_ARMED) end end)
				self:EmitSound("weapons/pinpull.wav",70,100)
			end
			JMod_Hint(activator,"grenade","grenade proximity","friends")
			Dude:PickupObject(self)
			if Dude:GetActiveWeapon() != "weapon_physcannon" then
				hook.Add("KeyPress", "GrenadeThrow_" .. self:EntIndex(), function(ply, key)
					if !IsValid(self) or !IsValid(Dude) or !self:IsPlayerHolding() then hook.Remove("GrenadeThrow_" .. self:EntIndex()) return end
					if ply == Dude then
						if key == IN_ATTACK then
							local dir = Dude:EyeAngles():Forward()
							self:GetPhysicsObject():SetVelocity(ply:GetVelocity() + dir * 800 + Vector(0, 0, 1) * 200)
						elseif key == IN_ATTACK2 then
							local dir = Dude:EyeAngles():Forward()
							self:GetPhysicsObject():SetVelocity(ply:GetVelocity() + dir * 500)
						end
						if table.HasValue({IN_ATTACK, IN_USE, IN_ATTACK2}, key) then hook.Remove("GrenadeThrow_" .. self:EntIndex()) return end
					end
				end)
			end
		end
	end
	function ENT:CanSee(ent)
		if not(IsValid(ent))then return false end
		local TargPos,SelfPos=ent:LocalToWorld(ent:OBBCenter()),self:LocalToWorld(self:OBBCenter())
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
		local State,Time=self:GetState(),CurTime()
		if(State==STATE_ARMED)then
			for k,targ in pairs(ents.FindInSphere(self:GetPos(),100))do
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
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(math.Rand(0,.1),function()
			if(IsValid(self))then
				local SelfPos,PowerMult=self:GetPos(), 1
				PowerMult=(PowerMult^.75)*JMOD_CONFIG.DetpackPowerMult
				--
				local Blam=EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult)
				util.Effect("eff_jack_plastisplosion",Blam,true,true)
				util.ScreenShake(SelfPos,20,20,1,500)
				sound.Play("BaseExplosionEffect.Sound",SelfPos,100,math.random(90,110))
				--sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,140,math.random(90,110))
				self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
				timer.Simple(.1,function()
					for i=1,5 do
						local Tr=util.QuickTrace(SelfPos,VectorRand()*20)
						if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
					end
				end)
				timer.Simple(0,function()
					local ZaWarudo=game.GetWorld()
					local Infl,Att=(IsValid(self) and self) or ZaWarudo,(IsValid(self) and IsValid(self.Owner) and self.Owner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl,Att,SelfPos,200,100)
					self:Remove()
				end)
			end
		end)
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
		local State,Vary=self:GetState(),math.sin(CurTime()*50)/2+.5
		if(State==STATE_ARMED)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+self:GetUp() * 8,20,20,Color(255,0,0))
			render.DrawSprite(self:GetPos()+self:GetUp() * 8,10,10,Color(255,255,255))
		elseif(State==STATE_WARNING)then
			render.SetMaterial(GlowSprite)
			render.DrawSprite(self:GetPos()+self:GetUp() * 8,30*Vary,30*Vary,Color(255,0,0))
			render.DrawSprite(self:GetPos()+self:GetUp() * 8,15*Vary,15*Vary,Color(255,255,255))
		end
	end
	language.Add("ent_jack_gmod_eznade_proximity","EZ Grenade - Proximity")
end