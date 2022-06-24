AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Criticality Weapon"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminOnly=true
---
ENT.JModPreferredCarryAngles=Angle(0,0,0)
ENT.JModEZstorable=true
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
---
local STATE_BROKEN,STATE_OFF,STATE_TICKING,STATE_IRRADIATING=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Timer")
	self:NetworkVar("Int",2,"Power")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		--local effectdata=EffectData()
		--effectdata:SetEntity(ent)
		--util.Effect("propspawn",effectdata)
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self.Entity:SetMaterial("phoenix_storms/glass")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.LastUse=0
		self:SetState(STATE_OFF)
		if istable(WireLib) then
			--self.Inputs=WireLib.CreateInputs(self, {"Detonate", "Arm", "Time"}, {"Directly detonates the bomb", "Value > 0 arms bomb", "Set this BEFORE arming."})
			--self.Outputs=WireLib.CreateOutputs(self, {"State", "TimeLeft", "DisarmProgress"}, {"-1 broken \n 0 off \n 1 armed", "Time left on \n the bomb", "How far the disarmament has got."})
		end
	end
	function ENT:TriggerInput(iname, value)
		--[[
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			if self:GetTimer() < 10 then
				self:SetTimer(10)
			end
			self:SetState(STATE_ARMED)
		elseif iname == "Time" and value >= 10 and self:GetState() == STATE_OFF then
			self:SetTimer(value)
		end
		--]]
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("Canister.ImpactHard",60,math.random(80,120))
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(JMod.LinCh(Dmg,20,90))then
			JMod.Owner(self,dmginfo:GetAttacker() or self.Owner)
			local Pos=self:GetPos()
			self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
			local Owner,Count=self.Owner,50
			timer.Simple(.5,function()
				for k=1,JMod.Config.NuclearRadiationMult*Count*20 do
					local Gas=ents.Create("ent_jack_gmod_ezfalloutparticle")
					Gas.Range=500
					Gas:SetPos(Pos)
					JMod.Owner(Gas,Owner or game.GetWorld())
					Gas:Spawn()
					Gas:Activate()
					Gas:GetPhysicsObject():SetVelocity(VectorRand()*math.random(1,500)+Vector(0,0,10*JMod.Config.NuclearRadiationMult))
				end
			end)
			self:Remove()
		end
	end
	function ENT:Use(activator)
		local State,Alt=self:GetState(),activator:KeyDown(JMod.Config.AltFunctionKey)
		if(State==STATE_OFF)then
			if(Alt)then
				JMod.Owner(self,activator)
				self:EmitSound("snd_jack_pinpull.wav",60,100)
				self:EmitSound("snd_jack_spoonfling.wav",60,100)
				self:SetState(STATE_TICKING)
				JMod.Hint(activator, "neutron radiation")
				timer.Simple(3,function()
					if(IsValid(self))then self:Detonate() end
				end)
			else
				activator:PickupObject(self)
				JMod.Hint(activator, "arm")
			end
		else
			activator:PickupObject(self)
		end
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Detonate()
		local State=self:GetState()
		if((State~=STATE_BROKEN)and(State!=STATE_IRRADIATING))then
			self:EmitSound("snds_jack_gmod/criticality_weapon_engage.wav",60,100)
			self:SetState(STATE_IRRADIATING)
			timer.Simple(.5,function()
				if(IsValid(self))then
					self.SoundLoop=CreateSound(self,"snds_jack_gmod/criticality_weapon_hum.wav")
					self.SoundLoop:Play()
					self.SoundLoop:SetSoundLevel(40)
				end
			end)
		end
	end
	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end
	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self,"State",self:GetState())
		end
		local State,Time,SelfPos=self:GetState(),CurTime(),self:GetPos()+Vector(0,0,15)
		if(State==STATE_TICKING)then
			self:EmitSound("snd_jack_metallicclick.wav",50,100)
			self:NextThink(Time+1)
			return true
		elseif(State==STATE_IRRADIATING)then
			local Range=1500
			for k,v in pairs(ents.FindInSphere(SelfPos,Range))do
				local DmgAmt=math.Rand(.1,1)*JMod.Config.NuclearRadiationMult
				if((v:IsPlayer())or(v:IsNPC()))then
					if(v:WaterLevel()>=3)then DmgAmt=DmgAmt/4 end
					---
					local Dmg,Helf=DamageInfo(),v:Health()
					Dmg:SetDamageType(DMG_GENERIC) -- neutron radiation, can't be blocked by a hazmat suit or gas mask
					Dmg:SetDamage(DmgAmt)
					Dmg:SetInflictor(self)
					Dmg:SetAttacker(self.Owner or self)
					Dmg:SetDamagePosition(v:GetPos())
					v:TakeDamageInfo(Dmg)
					---
					local Dmg2=DamageInfo()
					Dmg2:SetDamageType(DMG_RADIATION)
					Dmg2:SetDamage(DmgAmt)
					Dmg2:SetInflictor(self)
					Dmg2:SetAttacker(self.Owner or self)
					Dmg2:SetDamagePosition(v:GetPos())
					v:TakeDamageInfo(Dmg2)
					---
					if(v:IsPlayer())then
						v:EmitSound("player/geiger"..math.random(1,3)..".wav",55,math.random(90,110))
						---
						local DmgTaken=Helf-v:Health()
						if((DmgTaken>0)and(JMod.Config.NuclearRadiationSickness))then
							v.EZirradiated=(v.EZirradiated or 0)+DmgTaken*4
							JMod.Hint(v,"rad damage")
						end
					end
				end
			end
			self:NextThink(Time+.1)
			return true
		end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		-- (self,mdl,mat,scale,col)
		self.Frame=JMod.MakeModel(self,"models/props_phx/construct/metal_wire1x1x1.mdl","models/props_canal/metalwall005b",.28,nil)
		self.Base=JMod.MakeModel(self,"models/props_phx/construct/metal_plate_curve360.mdl","models/props_canal/metalwall005b",.1,nil)
		self.Core=JMod.MakeModel(self,"models/hunter/misc/sphere025x025.mdl","debug/env_cubemap_model",.3,nil)
		self.Cap1=JMod.MakeModel(self,"models/props_phx/construct/metal_dome360.mdl","phoenix_storms/fender_chrome",.09,nil)
		self.Cap2=JMod.MakeModel(self,"models/props_phx/construct/metal_dome360.mdl","phoenix_storms/fender_chrome",.09,nil)
		self.Glass=JMod.MakeModel(self,"models/hunter/blocks/cube025x025x025.mdl","phoenix_storms/glass",1,nil)
	end
	local function GetTimeString(seconds)
		local Minutes,Seconds=math.floor(seconds/60),math.floor(seconds%60)
		if(Minutes<10)then Minutes="0"..Minutes end
		if(Seconds<10)then Seconds="0"..Seconds end
		return Minutes..":"..Seconds
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:DrawTranslucent()
		local Irradiatin=self:GetState()==STATE_IRRADIATING
		--self:DrawModel()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		local Up,Right,Forward=self:GetUp(),self:GetForward(),self:GetRight()
		--(mdl,pos,ang,scale,color,mat,fullbright,translucency)
		local UpAmt=(Irradiatin and -.5) or 1.5
		JMod.RenderModel(self.Frame,Pos+Right*7,Ang)
		JMod.RenderModel(self.Base,Pos+Right*1-Up*6,Ang)
		JMod.RenderModel(self.Core,Pos+Right*1-Up*0,Ang)
		JMod.RenderModel(self.Cap1,Pos+Right*1+Up*UpAmt,Ang)
		local Cap2Ang=Ang:GetCopy()
		Cap2Ang:RotateAroundAxis(Right,180)
		JMod.RenderModel(self.Cap2,Pos+Right*1-Up*.5,Cap2Ang)
		JMod.RenderModel(self.Glass,Pos,Ang)
		if(Irradiatin)then
			local Vec=(EyePos()-Pos):GetNormalized()
			local SpritePos=Pos+Vec*10
			local QuadPos=Pos-Vector(0,0,6.2)
			render.SetMaterial(GlowSprite)
			render.DrawSprite(SpritePos,500,500,Color(0,20,255,30))
			render.DrawQuadEasy(QuadPos,Vector(0,0,1),500,500,Color(0,20,255,50))
			render.DrawSprite(SpritePos+Vec*10,100,100,Color(255,255,255,30))
			render.DrawQuadEasy(QuadPos,Vector(0,0,1),500,500,Color(255,255,255,30))
		end
	end
	language.Add("ent_jack_gmod_ezcriticalityweapon","EZ Criticality Weapon")
end
