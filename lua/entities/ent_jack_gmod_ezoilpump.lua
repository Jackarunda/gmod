-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Oil Pump"
ENT.Category="JMod - EZ Misc."
ENT.Spawnable=true
ENT.AdminOnly=false
local STATE_BROKEN,STATE_OFF,STATE_RUNNING=-1,0,1
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Float",0,"Progress")
	self:NetworkVar("Float",1,"Electricity")
end
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/hunter/blocks/cube4x4x1.mdl")
		--self:SetModelScale(math.Rand(1.5,3),0)
		--self:SetMaterial("models/debug/debugwhite")
		--self:SetColor(Color(math.random(190,210),math.random(140,160),0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(1000)
			self:GetPhysicsObject():Wake()
			-- attach us to the ground
			self:TryPlant()
		end)
		self:SetProgress(0)
		self:SetElectricity(100)
		self:SetState(STATE_OFF)
	end
	function ENT:TryPlant()
		local Tr=util.QuickTrace(self:GetPos()+Vector(0,0,50),Vector(0,0,-500),self)
		if((Tr.Hit)and(Tr.HitWorld))then
			self:SetAngles(Angle(0,0,-90))
			self:SetPos(Tr.HitPos+Tr.HitNormal*95)
			self.Weld=constraint.Weld(self,Tr.Entity,0,0,10000,false,false)
			--
		end
		if not(IsValid(self.Weld))then
			for k,v in pairs(ents.FindInSphere(self:GetPos(),300))do
				if(v:IsPlayer())then v:PrintMessage(HUD_PRINTCENTER,"oil pump broken due to not being planted on solid ground") end
			end
			self:Break()
		end
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>100)then
			self:EmitSound("SolidMetal.ImpactHard")
		end
	end
	function ENT:TurnOn()
		if(self:GetElectricity()>0)then
			self:SetState(STATE_RUNNING)
		end
	end
	function ENT:TurnOff()
		self:SetState(STATE_OFF)
	end
	function ENT:Use(activator)
		local State=self:GetState()
		if(State==STATE_OFF)then
			self:TurnOn()
		elseif(State==STATE_RUNNING)then
			self:TurnOff()
		end
	end
	function ENT:FlingProp(mdl,force)
		local Prop=ents.Create("prop_physics")
		Prop:SetPos(self:GetPos()+self:GetUp()*25+VectorRand()*math.Rand(1,25))
		Prop:SetAngles(VectorRand():Angle())
		Prop:SetModel(mdl)
		Prop:Spawn()
		Prop:Activate()
		Prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		constraint.NoCollide(Prop,self,0,0)
		local Phys=Prop:GetPhysicsObject()
		Phys:SetVelocity(self:GetPhysicsObject():GetVelocity()+VectorRand()*math.Rand(1,300)+self:GetUp()*100)
		Phys:AddAngleVelocity(VectorRand()*math.Rand(1,10000))
		if(force)then Phys:ApplyForceCenter(force/7) end
		SafeRemoveEntityDelayed(Prop,math.random(10,20))
	end
	function ENT:Break(dmginfo)
		if(self:GetState()==STATE_BROKEN)then return end
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(60,100))
		for i=1,10 do self:DamageSpark() end
		self.Durability=0
		self:SetState(STATE_BROKEN)
		local Force=(dmginfo and dmginfo:GetDamageForce()) or Vector(0,0,0)
		for i=1,4 do
			self:FlingProp("models/mechanics/gears/gear12x6_small.mdl",Force)
		end
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*30+VectorRand()*math.random(0,10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2,4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5,1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2,4)) --thickness of strands
		util.Effect("Sparks",effectdata,true,true)
		self:EmitSound("snd_jack_turretfizzle.wav",70,100)
		self:ConsumeElectricity(.2)
	end
	function ENT:Think()
		if not(IsValid(self.Weld))then self:Break() end
	end
	function ENT:ConsumeElectricity(amt)
		amt=(amt or .04)
		local NewAmt=math.Clamp(self:GetElectricity()-amt,0,100)
		self:SetElectricity(NewAmt)
		if(NewAmt<=0)then self:TurnOff() end
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Mdl=ClientsideModel("models/tsbb/pump_jack.mdl")
		self.Mdl:SetPos(self:GetPos()-self:GetRight()*100)
		local Ang=self:GetAngles()
		Ang:RotateAroundAxis(self:GetForward(),90)
		self.Mdl:SetAngles(Ang)
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
	end
	--[[
	0	Base
	1	WalkingBeam
	2	CounterWeight
	--]]
	function ENT:Draw()
		local Time=CurTime()
		if(self:GetState()==STATE_RUNNING)then
			local CounterweightDrive=(Time*120)%360--30
			local WalkingBeamDrive=math.sin((CounterweightDrive/360)*math.pi*2-math.pi)*20
			self.Mdl:ManipulateBoneAngles(1,Angle(0,0,WalkingBeamDrive))
			self.Mdl:ManipulateBoneAngles(2,Angle(0,0,CounterweightDrive))
		end
		--render.SetBlend(.5)
		--self:DrawModel()
		--render.SetBlend(1)
		self.Mdl:DrawModel()
	end
	language.Add("ent_jack_gmod_ezoilpump","EZ Oil Pump")
end