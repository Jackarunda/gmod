-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ TNT"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(-90, 0, 0)
ENT.JModEZstorable = true
ENT.EZpowderIgnitable = true
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end
---

if(SERVER)then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos = tr.HitPos + tr.HitNormal*15
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
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
		self:SetModel("models/jmodels/explosives/grenades/tnt/w_jnt.mdl")
		self:SetBodygroup(0, 0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(false)
		self:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
		---
		self.Fuze=100
		self:SetState(JMod.EZ_STATE_OFF)
		if istable(WireLib) then
			self.Inputs = WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})
			self.Outputs = WireLib.CreateOutputs(self, {"State"}, {"1 is armed \n 0 is not \n -1 is broken"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if(iname == "Detonate") and (value ~= 0) then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(JMod.EZ_STATE_ARMED)
		end
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor()==self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg=dmginfo:GetDamage()
		if(JMod.LinCh(Dmg,30,80))then
			local Pos,State=self:GetPos(),self:GetState()
			if(State==STATE_ARMED)then
				self:Detonate()
			elseif(not(State==JMod.EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break",Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self,10)
			end
		end
	end
	function ENT:Arm()
		if(self:GetState()==JMod.EZ_STATE_ARMED)then return end
		self:EmitSound("snds_jack_gmod/ignite.wav",60,100)
		timer.Simple(.5,function()
			if(IsValid(self))then self:SetState(JMod.EZ_STATE_ARMED) end
		end)
	end
	function ENT:Use(activator,activatorAgain,onOff)
		local Dude=activator or activatorAgain
		
		JMod.Owner(self,Dude)
		local Time=CurTime()
		if(tobool(onOff))then
			local State=self:GetState()
			if(State<0)then return end
			local Alt=Dude:KeyDown(JMod.Config.AltFunctionKey)
			if(State==JMod.EZ_STATE_OFF and Alt)then
				self:Arm()
				JMod.Hint(Dude, "fuse")
			end
			Dude:PickupObject(self)
			if not Alt then JMod.Hint(Dude, "arm") end
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		timer.Simple(0,function()
			if(IsValid(self))then
				local SelfPos,PowerMult=self:GetPos(),4
				--
				local Blam=EffectData()
				Blam:SetOrigin(SelfPos)
				Blam:SetScale(PowerMult/1.5)
				util.Effect("eff_jack_plastisplosion",Blam,true,true)
				util.ScreenShake(SelfPos,99999,99999,1,750*PowerMult)
				for i=1,2 do sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,140,math.random(80,110)) end
				for i=1,PowerMult do sound.Play("BaseExplosionEffect.Sound",SelfPos,120,math.random(90,110)) end
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
					util.BlastDamage(Infl,Att,SelfPos,120*PowerMult,180*PowerMult)
					self:Remove()
				end)
			end
		end)
	end
	function ENT:Think()
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
		end
		local Time=CurTime()
		local state = self:GetState()
		if(state==JMod.EZ_STATE_ARMED)then
			local Fsh=EffectData()
			Fsh:SetOrigin(self:GetPos()+self:GetForward()*18-self:GetRight()*5)
			Fsh:SetScale(1)
			local Ang=self:GetForward():Angle()
			Ang:RotateAroundAxis(self:GetUp(),45)
			Fsh:SetNormal(Ang:Forward())
			util.Effect("eff_jack_fuzeburn",Fsh,true,true)
			self.Entity:EmitSound("snd_jack_sss.wav",65,math.Rand(90,110))
			self.Fuze=self.Fuze-.5
			if(self.Fuze<=0)then self:Detonate();return end
			self:NextThink(Time+.05)
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
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezdynamite","EZ Dynamite")
end