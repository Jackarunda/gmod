-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Explosives"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Small Bomb"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0,-90,0)
ENT.EZRackOffset = Vector(0, 0, 10)
ENT.EZRackAngles = Angle(0, -90, 0)
ENT.EZbombBaySize = 8
---
local STATE_BROKEN,STATE_OFF,STATE_ARMED=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Bool",0,"Snakeye")
end
---
if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
		local ent=ents.Create(self.ClassName)
		ent:SetAngles(Angle(180,0,0))
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
		self.Entity:SetModel("models/hunter/blocks/cube025x125x025.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(80)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		self:SetState(STATE_OFF)
		self.LastUse=0
		self.FreefallTicks=0
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"This will directly detonate the bomb", "Arms bomb when > 0"})
			self.Outputs=WireLib.CreateOutputs(self, {"State", "Snakeye"}, {"-1 broken \n 0 off \n 1 armed", "Outputs 1 when fins are deployed"})
		end
	end
	function ENT:TriggerInput(iname, value)
		if(iname == "Detonate") and (self:GetState() == STATE_ARMED) and (value ~= 0) then
			self:Detonate()
		elseif iname == "Arm" and value > 0 then
			self:SetState(STATE_ARMED)
		end
	end
	function ENT:PhysicsCollide(data,physobj)
		if not(IsValid(self))then return end
		if(data.DeltaTime>0.2)then
			if(data.Speed>50)then
				self:EmitSound("Canister.ImpactHard")
			end
			local DetSpd=500
			if(self:GetSnakeye())then DetSpd=300 end
			if((data.Speed>DetSpd)and(self:GetState()==STATE_ARMED))then
				self:Detonate()
				return
			end
			if(data.Speed>2000)then
				self:Break()
			end
		end
	end
	function ENT:Break()
		if(self:GetState()==STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do
			self:DamageSpark()
		end
		SafeRemoveEntityDelayed(self,10)
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*10+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
	end
	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(JMod.LinCh(dmginfo:GetDamage(),60,120))then
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
	function ENT:Use(activator)
		local State,Time=self:GetState(),CurTime()
		if(State<0)then return end
		
		if(State==STATE_OFF)then
			JMod.Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_ARMED)
				self:EmitSound("snds_jack_gmod/bomb_arm.wav",70,120)
				self.EZdroppableBombArmedTime=CurTime()
				JMod.Hint(activator, "impactdet")
			else
				JMod.Hint(activator,"double tap to arm")
			end
			self.LastUse=Time
		elseif(State==STATE_ARMED)then
			JMod.Owner(self,activator)
			if(Time-self.LastUse<.2)then
				self:SetState(STATE_OFF)
				self:EmitSound("snds_jack_gmod/bomb_disarm.wav",70,120)
				self.EZdroppableBombArmedTime=nil
			else
				JMod.Hint(activator,"double tap to disarm")
			end
			self.LastUse=Time
		end
	end
	function ENT:Detonate()
		if(self.Exploded)then return end
		self.Exploded=true
		local SelfPos,Att=self:GetPos()+Vector(0,0,30),self.Owner or game.GetWorld()
		JMod.Sploom(Att,SelfPos,100)
		---
		util.ScreenShake(SelfPos,1000,3,2,2000)
		local Eff="100lb_ground"
		if not(util.QuickTrace(SelfPos,Vector(0,0,-300),{self}).HitWorld)then Eff="100lb_air" end
		for i=1,2 do
			sound.Play("ambient/explosions/explode_"..math.random(1,9)..".wav",SelfPos+VectorRand()*1000,160,math.random(80,110))
		end
		---
		util.BlastDamage(game.GetWorld(),Att,SelfPos+Vector(0,0,300),500,80)
		timer.Simple(.25,function() util.BlastDamage(game.GetWorld(),Att,SelfPos,1000,80) end)
		for k,ent in pairs(ents.FindInSphere(SelfPos,200))do
			if(ent:GetClass()=="npc_helicopter")then ent:Fire("selfdestruct","",math.Rand(0,2)) end
		end
		---
		JMod.WreckBuildings(self,SelfPos,4)
		JMod.BlastDoors(self,SelfPos,4)
		---
		timer.Simple(.2,function()
			local Tr=util.QuickTrace(SelfPos+Vector(0,0,100),Vector(0,0,-400))
			if(Tr.Hit)then util.Decal("BigScorch",Tr.HitPos+Tr.HitNormal,Tr.HitPos-Tr.HitNormal) end
		end)
		---
		JMod.FragSplosion(self,SelfPos,10000,200,8000,self.Owner or game.GetWorld())
		---
		self:Remove()
		timer.Simple(.1,function() ParticleEffect(Eff,SelfPos,Angle(0,0,0)) end)
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
		local Phys=self:GetPhysicsObject()
		if((self:GetState()==STATE_ARMED)and(Phys:GetVelocity():Length()>400)and not(self:IsPlayerHolding())and not(constraint.HasConstraints(self)))then
			self.FreefallTicks=self.FreefallTicks+1
			if((self.FreefallTicks>=10)and not(self:GetSnakeye()))then
				self:SetSnakeye(true)
				Phys:EnableDrag(true)
				Phys:SetDragCoefficient(20)
				self:EmitSound("buttons/lever6.wav",70,120)
			end
		else
			self.FreefallTicks=0
		end
		if istable(WireLib) then
			WireLib.TriggerOutput(self, "State", self:GetState())
			WireLib.TriggerOutput(self, "Snakeye", tonumber(self:GetSnakeye(), 10))
		end
		--if((self:GetState()==STATE_ARMED)and(self:GetGuided())and not(constraint.HasConstraints(self)))then
			--for k,designator in pairs(ents.FindByClass("wep_jack_gmod_ezdesignator"))do
				--if((designator:GetLasing())and(designator.Owner)and(JMod.ShouldAllowControl(self,designator.Owner)))then
					--[[
					local TargPos,SelfPos=ents.FindByClass("npc_*")[1]:GetPos(),self:GetPos()--designator.Owner:GetEyeTrace().HitPos
					local TargVec=TargPos-SelfPos
					local Dist,Dir,Vel=TargVec:Length(),TargVec:GetNormalized(),Phys:GetVelocity()
					local Speed=Vel:Length()
					if(Speed<=0)then return end
					local ETA=Dist/Speed
					jprint(ETA)
					TargPos=TargPos--Vel*ETA/2
					JMod.Sploom(self,TargPos,1)
					JMod.AeroGuide(self,-self:GetRight(),TargPos,1,1,.2,10)
					--]]
				--end
			--end
		--end
		local AeroDragMult=.5
		if(self:GetSnakeye())then AeroDragMult=4 end
		JMod.AeroDrag(self,-self:GetRight(),AeroDragMult)
		self:NextThink(CurTime()+.1)
		return true
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/jmod/mk82.mdl")
		self.Mdl:SetModelScale(.9,0)
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.Snakeye=false
	end
	function ENT:Think()
		if((not(self.Snakeye))and(self:GetSnakeye()))then
			self.Snakeye=true
			self.Mdl:SetBodygroup(0,1)
		end
	end
	function ENT:Draw()
		local Pos,Ang=self:GetPos(),self:GetAngles()
		Ang:RotateAroundAxis(Ang:Up(),90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos+Ang:Up()*6-Ang:Right()*6-Ang:Forward()*20)
		self.Mdl:SetRenderAngles(Ang)
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_ezsmallbomb","EZ Small Bomb")
end
