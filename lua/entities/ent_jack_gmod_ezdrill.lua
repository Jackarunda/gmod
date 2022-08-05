-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="orejfmdogzznag"
ENT.PrintName="EZ Drill"
ENT.Category="JMod - EZ Misc."
ENT.Spawnable=true -- temporary, until Phase 2 of the econ update
ENT.AdminOnly=false
ENT.Base="ent_jack_gmod_ezmachine_base"
ENT.EZconsumes={"power","parts"}
--ENT.WhitelistedResources = {}
ENT.BlacklistedResources = {"water", "oil", "geothermal", "geo"}
ENT.DepositKey = 0
ENT.MaxElectricity = 200
local STATE_BROKEN,STATE_OFF,STATE_INOPERABLE,STATE_RUNNING=-1,0,1,2
function ENT:SetupDataTables()
	self:NetworkVar("Int",0,"State")
	self:NetworkVar("Int",1,"Grade")
	self:NetworkVar("Float",0,"Progress")
	self:NetworkVar("Float",1,"Electricity")
end
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/trilogynetworks_jackdrill/drill.mdl")
		--self:SetModelScale(math.Rand(1.5,3),0)
		--self:SetMaterial("models/debug/debugwhite")
		--self:SetColor(Color(math.random(190,210),math.random(140,160),0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(SIMPLE_USE)
		--self:SetPos(self:GetPos()+Vector(0,0,100)) -- Don't ask why
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(3000)
			self:GetPhysicsObject():Wake()
			-- attach us to the ground
			self:TryPlant()
		end)
		self:SetGrade(1)
		self:SetProgress(0)
		self:SetElectricity(200)
		self:SetState(STATE_OFF)
		self.Durability=300
		-- TODO: make upgradable
	end
	function ENT:UpdateDepositKey()
		local SelfPos=self:GetPos()
		-- first, figure out which deposits we are inside of, if any
		local DepositsInRange={}
		for k,v in pairs(JMod.NaturalResourceTable)do
			-- Make sure the resource is on the whitelist
			local Dist=SelfPos:Distance(v.pos)
				-- store they desposit's key if we're inside of it
			if(Dist<=v.siz) and (not(table.HasValue(self.BlacklistedResources, v.typ)))then 
				if not(v.rate) and (v.amt < 0)then break end
				table.insert(DepositsInRange,k)
			end
		end
		-- now, among all the deposits we are inside of, let's find the closest one
		local ClosestDeposit,ClosestRange=nil,9e9
		if(#DepositsInRange>0)then
			for k,v in pairs(DepositsInRange)do
				local DepositInfo=JMod.NaturalResourceTable[v]
				local Dist=SelfPos:Distance(DepositInfo.pos)
				if(Dist<ClosestRange)then
					ClosestDeposit=v
					ClosestRange=Dist
				end
			end
		end
		if(ClosestDeposit)then 
			self.DepositKey = ClosestDeposit 
			print("Our deposit is "..self.DepositKey) --DEBUG
		else 
			self.DepositKey = 0 
			print("No valid deposit") --DEBUG
		end
	end
	function ENT:TryPlant()
		local Tr=util.QuickTrace(self:GetPos()+Vector(0,0,100),Vector(0,0,-500),self)
		if((Tr.Hit)and(Tr.HitWorld))then
			local Yaw=self:GetAngles().y
			self:SetAngles(Angle(0,Yaw,0))
			self:SetPos(Tr.HitPos+Tr.HitNormal*0.1)
			--
			local GroundIsSolid=true
			for i=1,50 do
				local Contents=util.PointContents(Tr.HitPos-Vector(0,0,10*i))
				if(bit.band(util.PointContents(self:GetPos()),CONTENTS_SOLID)==CONTENTS_SOLID)then GroundIsSolid=false break end
			end
			self:UpdateDepositKey()
			if(GroundIsSolid) and (self.DepositKey > 0)then
				self.Weld=constraint.Weld(self,Tr.Entity,0,0,10000,false,false)
				self:SetState(STATE_OFF)
				self:SetProgress(0)
			else
				self:SetState(STATE_INOPERABLE)
			end
		end
	end
	function ENT:TurnOn(activator)
		if(self:GetElectricity()>0)then
			self:SetState(STATE_RUNNING)
			timer.Simple(.5,function()
				if(IsValid(self))then
					self:SetSequence("active")
					self.SoundLoop=CreateSound(self,"snd_jack_betterdrill1.wav")
					self.SoundLoop:Play()
					self.SoundLoop:SetSoundLevel(0)
				end
			end)
		else
			JMod.Hint(activator,"nopower")
		end
	end
	function ENT:TurnOff()
		self:SetSequence("idle")
		self:SetState(STATE_OFF)
	end
	function ENT:Use(activator)
		local State=self:GetState()
		JMod.Hint(activator,"oil derrick")
		local OldOwner=self.Owner
		JMod.Owner(self,activator)
		if(IsValid(self.Owner))then
			if(OldOwner~=self.Owner)then -- if owner changed then reset team color
				JMod.Colorify(self)
			end
		end
		if(State==STATE_BROKEN)then
			JMod.Hint(activator,"destroyed",self)
			return
		elseif(State==STATE_INOPERABLE)then
			self:TryPlant()
		elseif(State==STATE_OFF)then
			self:TurnOn(activator)
		elseif(State==STATE_RUNNING)then
			self:TurnOff()
		end
	end
	function ENT:OnRemove()
		if(self.SoundLoop)then self.SoundLoop:Stop() end
	end
	function ENT:Think()
		if not(IsValid(self.Weld))then
			if(self:GetState()>0)then self:SetState(STATE_INOPERABLE) end
		end
		local State=self:GetState()
		if(State==STATE_BROKEN)then
			if(self.SoundLoop)then self.SoundLoop:Stop() end
			if(self:GetElectricity()>0)then
				if(math.random(1,4)==2)then self:DamageSpark() end
			end
			return
		elseif(State==STATE_INOPERABLE)then
			if(self.SoundLoop)then self.SoundLoop:Stop() end
			return
		elseif(State==STATE_RUNNING)then
			if(self:GetElectricity()<=0)then self:TurnOff() return end
			self:ConsumeElectricity()
			-- This is just the rate at which we drill
			local drillRate = JMod.EZ_GRADE_BUFFS[self:GetGrade()]
			-- Here's where we do the rescource deduction, and ore production
			-- If it's a flow (i.e. water)
			if(JMod.NaturalResourceTable[self.DepositKey].rate)then
				-- We get the rate
				local flowRate = JMod.NaturalResourceTable[self.DepositKey].rate
				-- and set the progress to what it was last tick + our ability * the flowrate
				self:SetProgress(self:GetProgress() + drillRate*flowRate)
				-- If the progress exceeds 100
				if(self:GetProgress() >= 100)then
					-- Spawn ore
					self:SpawnOre(100, self.DepositKey)
					-- And subtract 100 from the progress (so as to not lose any overflow)
					self:SetProgress(self:GetProgress() - 100)
				end
			else 
				-- Get the amount of resouces left in the ground
				local amtLeft = JMod.NaturalResourceTable[self.DepositKey].amt
				--print("Amount left: "..amtLeft) --DEBUG
				-- If there's nothing left, we shouldn't do anything
				if(amtLeft <= 0)then self:SetState(STATE_INOPERABLE) return end
				-- While progress is less than 100
				self:SetProgress(self:GetProgress() + drillRate)
				amtLeft = amtLeft - drillRate
				if(self:GetProgress() >= 100)then
					local amtToDrill = math.min(amtLeft, 100)
					self:SpawnOre(amtToDrill, self.DepositKey)
					self:SetProgress(self:GetProgress() - 100)
					JMod.NaturalResourceTable[self.DepositKey].amt = amtLeft - amtToDrill
				end
			end
		end
		self:NextThink(CurTime()+1)
		return true
	end
	function ENT:SpawnOre(amt, deposit)
		local SelfPos,Up,Forward,Right=self:GetPos(),self:GetUp(),self:GetForward(),self:GetRight()
		local RandomArea = Vector(math.random(-20, 20), math.random(-20, 20), 15)
		local Ore=ents.Create(JMod.EZ_RESOURCE_ENTITIES[JMod.NaturalResourceTable[deposit].typ])
		Ore:SetPos(SelfPos+Forward*100 + RandomArea)
		Ore:Spawn()
		JMod.Owner(self.Owner)
		Ore:SetResource(amt)
		Ore:Activate()
		
	end

elseif(CLIENT)then
	function ENT:Initialize()
	--
	end
	function ENT:Draw()
		self:DrawModel()
		local Up,Right,Forward = self:GetUp(),self:GetRight(),self:GetForward()
		local SelfPos = self:GetPos()
		--
		local BasePos=SelfPos+Up*32
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		if(DetailDraw)then
			if((Closeness<20000)and(State==STATE_INOPERABLE or State==STATE_RUNNING))then
				local DisplayAng=SelfAng:GetCopy()
				DisplayAng:RotateAroundAxis(DisplayAng:Right(),90)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),180)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),-50)
				local Opacity=math.random(50,150)
				cam.Start3D2D(SelfPos+Up*25-Right*50-Forward*80,DisplayAng,.1)
				draw.SimpleTextOutlined("POWER","JMod-Display",250,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ElecFrac=self:GetElectricity()/200
				local R,G,B=JMod.GoodBadColor(ElecFrac)
				draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",250,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				draw.SimpleTextOutlined("PROGRESS","JMod-Display",250,60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				local ProgressFrac=self:GetProgress()/100
				draw.SimpleTextOutlined(tostring(math.Round(ProgressFrac*100)).."%","JMod-Display",250,90,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				--local CoolFrac=self:GetCoolant()/100
				--draw.SimpleTextOutlined("COOLANT","JMod-Display",90,0,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				--local R,G,B=JMod.GoodBadColor(CoolFrac)
				--draw.SimpleTextOutlined(tostring(math.Round(CoolFrac*100)).."%","JMod-Display",90,30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezdrill","EZ Dill")
end