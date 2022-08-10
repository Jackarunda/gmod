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
ENT.JModDontIrradiate=true
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
---
local STATE_BROKEN,STATE_OFF,STATE_TICKING,STATE_IRRADIATING,STATE_MELTED=-1,0,1,2,3
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
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(150)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.LastUse=0
		self:SetState(STATE_OFF)
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Detonate"}, {"Directly activates the weapon"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if iname == "Detonate" and value > 0 then
			self:Detonate()
		end
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
		if(JMod.LinCh(Dmg,50,120))then
			JMod.Owner(self,dmginfo:GetAttacker() or self.Owner)
			local Pos=self:GetPos()
			self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
			local Owner,Count=self.Owner,50
			timer.Simple(.5,function()
				for k=1,JMod.Config.NuclearRadiationMult*Count do
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
				timer.Simple(3,function() -- todo: 30 seconds
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
			-- Well, that does it.
		end
	end
	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end
	local function CanSee(ent1,ent2)
		local Tr=util.TraceLine({
			start=ent1:GetPos(),
			endpos=ent2:GetPos(),
			filter={ent1,ent2},
			mask=MASK_SHOT
		})
		return not Tr.Hit
	end
	local function ReEmitRadiation(ent)
		local self=ent -- copied from the fallout particle
		for key,obj in pairs(ents.FindInSphere(self:LocalToWorld(self:OBBCenter()),200))do
			if(not(obj==self)and(CanSee(self,obj)))then
				if(JMod.ShouldDamageBiologically(obj))then
					local DmgAmt=self.DmgAmt or math.random(2,10)*JMod.Config.NuclearRadiationMult
					if(obj:WaterLevel()>=3)then DmgAmt=DmgAmt/3 end
					---
					local Dmg,Helf=DamageInfo(),obj:Health()
					Dmg:SetDamageType(DMG_RADIATION)
					Dmg:SetDamage(DmgAmt)
					Dmg:SetInflictor(self)
					Dmg:SetAttacker(self.Owner or self)
					Dmg:SetDamagePosition(obj:GetPos())
					if(obj:IsPlayer())then
						DmgAmt=DmgAmt/4
						Dmg:SetDamage(DmgAmt)
						obj:TakeDamageInfo(Dmg)
						---
						JMod.GeigerCounterSound(obj,math.Rand(.1,.5))
						JMod.Hint(v,"radioactive fallout")
						timer.Simple(math.Rand(.1,2),function()
							if(IsValid(obj))then JMod.GeigerCounterSound(obj,math.Rand(.1,.5)) end
						end)
						---
						local DmgTaken=Helf-obj:Health()
						if((DmgTaken>0)and(JMod.Config.NuclearRadiationSickness))then
							obj.EZirradiated=(obj.EZirradiated or 0)+DmgTaken*3
							timer.Simple(10,function()
								if(IsValid(obj) and obj:Alive())then JMod.Hint(obj,"radiation sickness") end
							end)
						end
					else
						obj:TakeDamageInfo(Dmg)
					end
				end
			end
		end
	end
	local function DetermineShieldingFactor(startPos,endPos,source,victim,vec,dist)
		-- you may ask why we pass vec and dist into this function when we already have the positions
		-- and the answer is f*** you
		-- just kidding, the answer is efficiency
		-- vector math and roots are expensive ops; we wanna reuse the results as much as we can
		local TraceOne=util.TraceLine({
			start=startPos,
			endpos=endPos,
			filter={source,victim},
			mask=MASK_SHOT
		})
		if not(TraceOne.Hit)then return 0 end
		local TraceTwo=util.TraceLine({
			start=endPos,
			endpos=startPos
			filter={source,victim},
			mask=MASK_SHOT
		})
		if not(TraceTwo.Hit)then return 0 end
		local StartCheckDist=TraceOne.HitPos:Distance(startPos)
		local EndCheckDist=TraceTwo.HitPos:Distance(endPos)
		local CheckResults={}
		for i=StartCheckDist,EndCheckDist do
			-- whee
		end
		return 1
	end
	function ENT:Think()
		local State,Time,SelfPos=self:GetState(),CurTime(),self:GetPos()+Vector(0,0,15)
		if(State==STATE_TICKING)then
			self:EmitSound("snd_jack_metallicclick.wav",50,100)
			self:NextThink(Time+1)
			return true
		elseif(State==STATE_IRRADIATING)then
			local Range,SelfPos,SelfInWater=2000,self:GetPos()+Vector(0,0,10),self:WaterLevel()>=3
			for k,v in pairs(ents.FindInSphere(SelfPos,Range))do
				if not(v.JModDontIrradiate)then
					local TargPos,Playa,NPC=v:LocalToWorld(v:OBBCenter()),v:IsPlayer(),v:IsNPC()
					local Vec=TargPos-SelfPos
					local Dir,Dist=Vec:GetNormalized(),math.Clamp(Vec:Length(),0,Range)
					local DistFrac=1-(Dist/Range)
					local DmgAmt=math.Rand(.1,1)*JMod.Config.NuclearRadiationMult*DistFrac^2
					if((Playa and v:Alive())or(NPC))then
						if(v:WaterLevel()>=3 or SelfInWater)then DmgAmt=DmgAmt/4 end
						---
						local Shielding=DetermineShieldingFactor(SelfPos,TargPos,self,v,Vec,Dist) -- shielding calcs are spensive, only run them for players/NPCs
						DmgAmt=DmgAmt*(1-Shielding)
						---
						if(DmgAmt<.1)then return end
						---
						local Dmg,Helf=DamageInfo(),v:Health()
						Dmg:SetDamageType(DMG_GENERIC) -- neutron radiation, can't be blocked by a hazmat suit or gas mask
						Dmg:SetDamage(DmgAmt/3)
						Dmg:SetInflictor(self)
						Dmg:SetAttacker(self.Owner or self)
						Dmg:SetDamagePosition(TargPos)
						v:TakeDamageInfo(Dmg)
						---
						local Dmg2=DamageInfo()
						Dmg2:SetDamageType(DMG_RADIATION)
						Dmg2:SetDamage(DmgAmt/4)
						Dmg2:SetInflictor(self)
						Dmg2:SetAttacker(self.Owner or self)
						Dmg2:SetDamagePosition(TargPos)
						v:TakeDamageInfo(Dmg2)
						---
						if(Playa)then
							JMod.GeigerCounterSound(v,DmgAmt)
							JMod.Hint(v,"neutron radiation")
							---
							local DmgTaken=Helf-v:Health()
							if((DmgTaken>0)and(JMod.Config.NuclearRadiationSickness))then
								v.EZirradiated=(v.EZirradiated or 0)+DmgTaken*5 -- fuckin ouch
								timer.Simple(10,function()
									if(IsValid(v) and v:Alive())then JMod.Hint(v,"radiation sickness") end
								end)
							end
						end
					else
						local Dmg2=DamageInfo()
						Dmg2:SetDamageType(DMG_RADIATION)
						Dmg2:SetDamage(DmgAmt/3)
						Dmg2:SetInflictor(self)
						Dmg2:SetAttacker(self.Owner or self)
						Dmg2:SetDamagePosition(TargPos)
						v:TakeDamageInfo(Dmg2)
						-- neutron activation
						local Phys=v:GetPhysicsObject()
						if(IsValid(Phys) and Phys:GetMass()>=10)then
							if(math.Rand(0,3)<DmgAmt)then
								-- todo
							end
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
		JMod.RenderModel(self.Frame,Pos+Right*7,Ang,nil,Vector(.5,.5,.5))
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
			local QuadPos=Pos-Vector(0,0,5.5)
			render.SetMaterial(GlowSprite)
			render.DrawSprite(SpritePos,500,500,Color(0,20,255,30))
			render.DrawQuadEasy(QuadPos,Vector(0,0,1),500,500,Color(0,20,255,50))
			render.DrawSprite(SpritePos+Vec*10,100,100,Color(255,255,255,50))
			render.DrawQuadEasy(QuadPos,Vector(0,0,1),100,100,Color(255,255,255,50))
			DLight=DynamicLight(self:EntIndex())
			if(DLight)then
				DLight.Brightness=1
				DLight.Decay=7500
				DLight.DieTime=CurTime()+.1
				DLight.Pos=self:GetPos()+Vector(1,1,-20)
				DLight.Size=300
				DLight.r=0
				DLight.g=20
				DLight.b=255
			end
		end
	end
	language.Add("ent_jack_gmod_ezcriticalityweapon","EZ Criticality Weapon")
end
