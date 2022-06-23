-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Misc."
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Glow Stick"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminSpawnable=true
ENT.JModGUIcolorable=true
---
ENT.JModEZstorable=true
ENT.JModPreferredCarryAngles=Angle(0,0,0)
---
local STATE_OFF,STATE_BURNIN,STATE_BURNT=0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Fuel")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent,ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self.Entity:SetModel("models/props/army/glowstick.mdl")
		self.Entity:SetMaterial("models/props/army/jlowstick_off")
		self.Entity:SetModelScale(1.5,0)
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self:SetUseType(ONOFF_USE)
		self.Entity:SetColor(Color(130,200,120))
		self:GetPhysicsObject():SetMass(6)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(6)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.NextStick=0
		self.LastUse=0
		self:SetState(STATE_OFF)
		self:SetFuel(math.random(540,660))
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Light"}, {"Lights glowstick"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if(iname == "Light" and value > 0) then
			self:Light()
		end
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2)then
			if(data.Speed>25)then
				self.Entity:EmitSound("Drywall.ImpactHard")
			end
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(JMod.LinCh(dmginfo:GetDamage(),1,50))then
			local Pos,State=self:GetPos(),self:GetState()
			if(math.random(1,2)==1)then
				self:Light()
			else
				sound.Play("Metal_Box.Break",Pos)
				self:Remove()
			end
		end
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local State=self:GetState()
		if(State==STATE_BURNT)then return end
		local Dude=activator or activatorAgain
		local Alt=Dude:KeyDown(JMod.Config.AltFunctionKey)
		JMod.Owner(self, Dude)
		local Time=CurTime()
		if(State==STATE_OFF)then
			if(tobool(onOff))then
				if(Alt)then
					JMod.Owner(self,activator)
					net.Start("JMod_ColorAndArm")
					net.WriteEntity(self)
					net.Send(activator)
				else
					activator:PickupObject(self)
					JMod.Hint(activator, "arm")
				end
			end
		elseif(State==STATE_BURNIN)then
			if((Alt)&&(Dude:KeyDown(IN_SPEED))&&(tobool(onOff)))then
				if(Dude.EZequippables && Dude.EZequippables["glowsticks"])then -- double sticks, it's rave time
					JMod.SetEquippable(Dude,"glowsticks","rave_glowsticks",self:GetColor(),Time+self:GetFuel())
				else
					JMod.SetEquippable(Dude,"glowsticks","one_glowstick",self:GetColor(),Time+self:GetFuel())
				end
				self:Remove()
			else
				if(tobool(onOff))then
					constraint.RemoveAll(self)
					self.StuckStick=nil
					self.StuckTo=nil
					Dude:PickupObject(self)
					self.NextStick=Time+.5
					JMod.Hint(Dude, "sticky")
				elseif((Time-self.LastUse)>.1)then
					if((self:IsPlayerHolding())and(self.NextStick<Time))then
						local Tr=util.QuickTrace(Dude:GetShootPos(),Dude:GetAimVector()*80,{self,Dude})
						if Tr.Hit and (IsValid(Tr.Entity:GetPhysicsObject()))and not(Tr.Entity:IsNPC())and not(Tr.Entity:IsPlayer())then
							self.NextStick=Time+.5
							local Ang=Tr.HitNormal:Angle()
							--Ang:RotateAroundAxis(Ang:Right(), -90)
							--Ang:RotateAroundAxis(Ang:Up(), 90)
							self:SetAngles(Ang)
							self:SetPos(Tr.HitPos+Tr.HitNormal*.5)
							-- crash prevention
							if(Tr.Entity:GetClass()=="func_breakable")then
								timer.Simple(0,function()
									self:GetPhysicsObject():Sleep()
								end)
							else
								local Weld=constraint.Weld(self,Tr.Entity,0,Tr.PhysicsBone,5000,false,false)
								self.StuckTo=Tr.Entity
								self.StuckStick=Weld
							end
							self:EmitSound("snd_jack_claythunk.wav",65,math.random(80,120))
							Dude:DropObject()
							JMod.Hint(Dude, "stick to self")
						end
					end
				end
				self.LastUse=Time
			end
		end
	end
	function ENT:Light()
		if(self:GetState()==STATE_BURNT)then return end
		self:SetState(STATE_BURNIN)
		self:SetMaterial("models/props/army/jlowstick_on")
		self:DrawShadow(false)
		self:EmitSound("snds_jack_gmod/glowstick_start.wav",60,math.random(90,110))
	end
	ENT.Arm=ENT.Light -- for compatibility with the ColorAndArm feature
	function ENT:Burnout()
		if(self:GetState()==STATE_BURNT)then return end
		self:SetState(STATE_BURNT)
		self:SetMaterial("models/props/army/jlowstick_off")
		SafeRemoveEntityDelayed(self,20)
		self:DrawShadow(true)
	end
	function ENT:Think()
		if(self:GetState()==STATE_BURNT)then return end
		local State,Fuel,Time,Pos=self:GetState(),self:GetFuel(),CurTime(),self:GetPos()
		local Up,Right,Forward=self:GetUp(),self:GetRight(),self:GetForward()
		if(State==STATE_BURNIN)then
			if(Fuel<=0)then self:Burnout() return end
			self:SetFuel(Fuel-1)
			self:NextThink(Time+1)
			return true
		end
	end
	function ENT:OnRemove()
		--
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Think()
		local State,Fuel,Pos,Ang=self:GetState(),self:GetFuel(),self:GetPos(),self:GetAngles()
		if(State==STATE_BURNIN)then
			local Up,Right,Forward,Mult,Col=Ang:Up(),Ang:Right(),Ang:Forward(),(Fuel>30 and 1) or .5,self:GetColor()
			local R,G,B=math.Clamp(Col.r+20,0,255),math.Clamp(Col.g+20,0,255),math.Clamp(Col.b+20,0,255)
			local DLight=DynamicLight(self:EntIndex())
			if(DLight)then
				DLight.Pos=Pos+Up*10+Vector(0,0,10)
				DLight.r=R
				DLight.g=G
				DLight.b=B
				DLight.Brightness=.8*Mult^2
				DLight.Size=180*Mult^2
				DLight.Decay=15000
				DLight.DieTime=CurTime()+.3
				DLight.Style=0
			end
		end
	end
	local GlowSprite=Material("sprites/mat_jack_basicglow")
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezglowstick","EZ Glow Stick")
end
