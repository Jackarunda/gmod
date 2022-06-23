AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, TheOnly8Z"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Time Bomb"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(-90, 0, 0)
ENT.JModEZstorable=true
---
local STATE_BROKEN, STATE_OFF, STATE_ARMED=-1, 0, 1
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	self:NetworkVar("Int", 1, "Timer")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*20
		local ent=ents.Create(self.ClassName)
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
		self.Entity:SetModel("models/jmodels/explosives/bombs/c4/w_c4_planted.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)	
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(25)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(STATE_OFF)
		self.NextStick=0
		self.DisarmProgress=0
		self.DisarmNeeded=20
		self.NextDisarmFail=0
		self.NextDisarm=0
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Detonate", "Arm", "Time"}, {"Directly detonates the bomb", "Value > 0 arms bomb", "Set this BEFORE arming."})
			self.Outputs=WireLib.CreateOutputs(self, {"State", "TimeLeft", "DisarmProgress"}, {"-1 broken \n 0 off \n 1 armed", "Time left on \n the bomb", "How far the disarmament has got."})
		end
	end
	function ENT:TriggerInput(iname, value)
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
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("snd_jack_claythunk.wav",55,math.random(80,120))
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(dmginfo:GetInflictor()==self)then return end
		self.Entity:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(JMod.LinCh(Dmg,60,120))then
			local Pos,State=self:GetPos(),self:GetState()
			if(State==STATE_ARMED)then
				self:Detonate()
			elseif(not(State==STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude,Time=activator or activatorAgain,CurTime()
		JMod.Owner(self,Dude)
		
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State < 0)then return end
			local Alt=Dude:KeyDown(JMod.Config.AltFunctionKey)
			if(State == STATE_OFF)then
				if(Alt)then
					if(self.NextDisarmFail < Time)then
						net.Start("JMod_EZtimeBomb")
						net.WriteEntity(self)
						net.Send(Dude)
						JMod.Hint(Dude, "timebomb")
					end
				else
					constraint.RemoveAll(self)
					self.StuckStick=nil
					self.StuckTo=nil
					Dude:PickupObject(self)
					self.NextStick=Time+.5
					JMod.Hint(Dude, "sticky")
				end
			else
				if(Alt)then
					if(self.NextDisarm < Time)then
						self.NextDisarm=Time+.2
						
						self.DisarmProgress=self.DisarmProgress+JMod.Config.BombDisarmSpeed
						self.NextDisarmFail=Time+1
						Dude:PrintMessage(HUD_PRINTCENTER,"disarming: "..self.DisarmProgress.."/"..math.ceil(self.DisarmNeeded))
						if(self.DisarmProgress >= self.DisarmNeeded)then
							self:SetState(STATE_OFF)
							self:EmitSound("weapons/c4/c4_disarm.wav", 60, 120)
							self.DisarmProgress=0
						end
						JMod.Hint(Dude, "defuse")
					end
				else
					constraint.RemoveAll(self)
					self.StuckStick=nil
					self.StuckTo=nil
					Dude:PickupObject(self)
					self.NextStick=Time+.5
				end
			end
		else -- player just released the USE key
			if((self:IsPlayerHolding())and(self.NextStick < Time))then
				local Tr=util.QuickTrace(Dude:GetShootPos(), Dude:GetAimVector()*80,{self,Dude})
				if(Tr.Hit)then
					if((IsValid(Tr.Entity:GetPhysicsObject()))and not(Tr.Entity:IsNPC())and not(Tr.Entity:IsPlayer()))then
						self.NextStick=Time+.5
						local Ang=Tr.HitNormal:Angle()
						Ang:RotateAroundAxis(Ang:Right(),-90)
						Ang:RotateAroundAxis(Ang:Up(),180)
						self:SetAngles(Ang)
						self:SetPos(Tr.HitPos)
						if(Tr.Entity:GetClass()=="func_breakable")then -- crash prevention
							timer.Simple(0,function() self:GetPhysicsObject():Sleep() end)
						else
							local Weld=constraint.Weld(self,Tr.Entity,0,Tr.PhysicsBone,3000,false,false)
							self.StuckTo=Tr.Entity
							self.StuckStick=Weld
						end
						self.Entity:EmitSound("snd_jack_claythunk.wav",65,math.random(80,120))
						Dude:DropObject()
					end
				end
			end
		end
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Detonate()
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
	end
	function ENT:Think()
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
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	local function GetTimeString(seconds)
		local Minutes,Seconds=math.floor(seconds/60),math.floor(seconds%60)
		if(Minutes<10)then Minutes="0"..Minutes end
		if(Seconds<10)then Seconds="0"..Seconds end
		return Minutes..":"..Seconds
	end
	function ENT:Draw()
		self:DrawModel()
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
	end
	language.Add("ent_jack_gmod_eztimebomb","EZ Time Bomb")
end