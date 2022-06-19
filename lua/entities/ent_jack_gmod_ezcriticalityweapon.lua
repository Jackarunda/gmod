AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Criticality Weapon"
ENT.NoSitAllowed = true
ENT.Spawnable = false
ENT.AdminSpawnable = false
---
ENT.JModPreferredCarryAngles=Angle(-90,0,0)
ENT.JModEZstorable=true
ENT.RenderGroup=RENDERGROUP_TRANSLUCENT
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED,STATE_IRRADIATING=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Timer")
	self:NetworkVar("Int",2,"Power")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal * 20
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
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
			self:GetPhysicsObject():SetMass(50)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.LastUse=0
		self:SetState(STATE_OFF)
		if istable(WireLib) then
			--self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm", "Time"}, {"Directly detonates the bomb", "Value > 0 arms bomb", "Set this BEFORE arming."})
			--self.Outputs = WireLib.CreateOutputs(self, {"State", "TimeLeft", "DisarmProgress"}, {"-1 broken \n 0 off \n 1 armed", "Time left on \n the bomb", "How far the disarmament has got."})
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
				for k=1,JMod.Config.NuclearRadiationMult*Count*10 do
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
		local Dude,Time=activator,CurTime()
		JMod.Owner(self,Dude)
		local Time = CurTime()
		local State = self:GetState()
		if(State < 0)then return end
		local Alt = Dude:KeyDown(JMod.Config.AltFunctionKey)
		if(State == STATE_OFF)then
			if(Alt)then
				if(self.NextDisarmFail < Time)then
					net.Start("JMod_EZtimeBomb")
					net.WriteEntity(self)
					net.Send(Dude)
					JMod.Hint(Dude,"timebomb")
				end
			else
				Dude:PickupObject(self)
			end
		else
			if(Alt)then
				if(self.NextDisarm<Time)then
					self.NextDisarm=Time+.2
					self.DisarmProgress=self.DisarmProgress+JMod.Config.BombDisarmSpeed
					self.NextDisarmFail=Time+1
					Dude:PrintMessage(HUD_PRINTCENTER,"disarming: "..self.DisarmProgress.."/"..math.ceil(self.DisarmNeeded))
					if(self.DisarmProgress>=self.DisarmNeeded)then
						self:SetState(STATE_OFF)
						self:EmitSound("weapons/c4/c4_disarm.wav",60,120)
						self.DisarmProgress=0
					end
					JMod.Hint(Dude,"defuse")
				end
			else
				Dude:PickupObject(self)
			end
		end
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Detonate()
		--[[
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(math.Rand(0,.1),function()
			if(IsValid(self))then
				if(self.SympatheticDetonated)then return end
				local SelfPos,PowerMult=self:LocalToWorld(self:OBBCenter()),6
				--
				ParticleEffect("pcf_jack_groundsplode_large",SelfPos,vector_up:Angle())
				util.ScreenShake(SelfPos,99999,99999,1,3000)
				sound.Play("BaseExplosionEffect.Sound",SelfPos,120,math.random(90,110))
				for i=1,4 do sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,140,math.random(80,110)) end
				self:EmitSound("snd_jack_fragsplodeclose.wav",90,100)
				timer.Simple(.1,function()
					for i=1,5 do
						local Tr=util.QuickTrace(SelfPos,VectorRand()*20)
						if(Tr.Hit)then util.Decal("Scorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
					end
				end)
				JMod.WreckBuildings(self,SelfPos,PowerMult)
				JMod.BlastDoors(self,SelfPos,PowerMult)
				timer.Simple(0,function()
					local ZaWarudo=game.GetWorld()
					local Infl,Att=(IsValid(self) and self) or ZaWarudo,(IsValid(self) and IsValid(self.Owner) and self.Owner) or (IsValid(self) and self) or ZaWarudo
					util.BlastDamage(Infl,Att,SelfPos,120*PowerMult,120*PowerMult)
					-- do a lot of damage point blank, mostly for breaching
					util.BlastDamage(Infl,Att,SelfPos,20*PowerMult,1000*PowerMult)
					self:Remove()
				end)
			end
		end)
		--]]
	end
	function ENT:Think()
		--[[
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "TimeLeft", self:GetTimer())
			WireLib.TriggerOutput(self, "DisarmProgress", self.DisarmProgress)
		end
		if(self.NextDisarmFail<CurTime())then self.DisarmProgress=0 end
		if(self:GetState()==STATE_ARMED)then
			self:EmitSound("weapons/c4/c4_beep1.wav",50,100)
			self:SetTimer(self:GetTimer()-1)
			if(self:GetTimer()<=0)then self:Detonate() return end
			self:NextThink(CurTime()+1)
			return true
		end
		--]]
	end
elseif(CLIENT)then
	function ENT:Initialize()
		-- (self,mdl,mat,scale,col)
		self.Frame=JMod.MakeModel(self,"models/props_phx/construct/metal_wire1x1x1.mdl",nil,.28,nil)
		self.Base=JMod.MakeModel(self,"models/props_phx/construct/metal_plate_curve360.mdl",nil,.1,nil)
		self.Core=JMod.MakeModel(self,"models/hunter/misc/sphere025x025.mdl","debug/env_cubemap_model",.3,nil)
		self.Cap1=JMod.MakeModel(self,"models/props_phx/construct/metal_dome360.mdl","phoenix_storms/fender_chrome",.09,nil)
		self.Cap2=JMod.MakeModel(self,"models/props_phx/construct/metal_dome360.mdl","phoenix_storms/fender_chrome",.09,nil)
	end
	local function GetTimeString(seconds)
		local Minutes,Seconds=math.floor(seconds/60),math.floor(seconds%60)
		if(Minutes<10)then Minutes="0"..Minutes end
		if(Seconds<10)then Seconds="0"..Seconds end
		return Minutes..":"..Seconds
	end
	function ENT:DrawTranslucent()
		self:DrawModel()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		local Up,Right,Forward=self:GetUp(),self:GetForward(),self:GetRight()
		--(mdl,pos,ang,scale,color,mat,fullbright,translucency)
		JMod.RenderModel(self.Frame,Pos+Right*7,Ang)
		JMod.RenderModel(self.Base,Pos+Right*1-Up*6,Ang)
		JMod.RenderModel(self.Core,Pos+Right*1-Up*0,Ang)
		JMod.RenderModel(self.Cap1,Pos+Right*1+Up*1.5,Ang)
		local Cap2Ang=Ang:GetCopy()
		Cap2Ang:RotateAroundAxis(Right,180)
		JMod.RenderModel(self.Cap2,Pos+Right*1-Up*.5,Cap2Ang)
		--[[
		if(self:GetState()==STATE_ARMED)then
			local ang,SelfPos=self:GetAngles(),self:GetPos()
			ang:RotateAroundAxis(ang:Up(),-90)
			local Up,Right,Forward,FT=ang:Up(),ang:Right(),ang:Forward(),FrameTime()
			local Amb=render.GetLightColor(SelfPos)
			local Brightness=((Amb.x+Amb.y+Amb.z)/3)
			local Opacity=math.random(50,255)*Brightness
			cam.Start3D2D(SelfPos+Up*13.3-Right*6-Forward*-6.8,ang,.1)
				draw.SimpleTextOutlined(GetTimeString(self:GetTimer()),"JMod-NumberLCD",0,0,Color(255,200,200,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(200,0,0,Opacity))
			cam.End3D2D()
		end
		--]]
	end
	language.Add("ent_jack_gmod_ezcriticalityweapon","EZ Criticality Weapon")
end
