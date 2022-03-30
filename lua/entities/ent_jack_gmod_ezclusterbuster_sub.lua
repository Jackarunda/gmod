-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "The smart skeet submunition for the BLU 108"
ENT.PrintName = "Cluster Buster submunition"
ENT.NoSitAllowed = true
ENT.Spawnable = true
ENT.AdminSpawnable = true
---
ENT.JModPreferredCarryAngles = Angle(90, 0, 180)
ENT.JModEZstorable = true
---
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end
---

if(SERVER)then
	function ENT:SpawnFunction(ply,tr)
		local SpawnPos = tr.HitPos+tr.HitNormal*15
		local ent = ents.Create(self.ClassName)
		ent:SetAngles(Angle(0, 0, 0))
		ent:SetPos(SpawnPos)
		JMod.Owner(ent, ply)
		ent:Spawn()
		ent:Activate()
		return ent
	end
	function ENT:Initialize()
		self:SetModel("models/XQM/cylinderx1.mdl")
		--self:SetModelScale(1.25,0)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(ONOFF_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(15)
			self:GetPhysicsObject():Wake()
		end)
		---
		self:SetState(JMod.EZ_STATE_OFF)
		self.NextStick=0
		self.Damage=500
		---
		JMod.Colorify(self)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>25)then
			self:EmitSound("DryWall.ImpactHard")
		end
	end
	function ENT:OnTakeDamage(dmginfo)
		if(self.Exploded)then return end
		if(dmginfo:GetInflictor() == self)then return end
		self:TakePhysicsDamage(dmginfo)
		local Dmg = dmginfo:GetDamage()
		if(JMod.LinCh(Dmg, 20, 100))then
			local Pos, State = self:GetPos(), self:GetState()
			if(State == JMod.EZ_STATE_ARMED)then
				self:Detonate()
			elseif(not(State == JMod.EZ_STATE_BROKEN))then
				sound.Play("Metal_Box.Break", Pos)
				self:SetState(JMod.EZ_STATE_BROKEN)
				SafeRemoveEntityDelayed(self, 10)
			end
		end
	end
	function ENT:Use(activator, activatorAgain, onOff)
		local Dude = activator or activatorAgain
		JMod.Owner(self, Dude)
		if(IsValid(self.Owner))then
			JMod.Colorify(self)
		end
		
		local Time=CurTime()
		if(tobool(onOff))then
			local State = self:GetState()
			if(State < 0)then return end
			local Alt = Dude:KeyDown(JMod.Config.AltFunctionKey)
			if(State == JMod.EZ_STATE_OFF)then
				if(Alt)then
					self:SetState(JMod.EZ_STATE_ARMED)
					self:EmitSound("snd_jack_minearm.wav", 60, 100)
					if(IsValid(self))then
						local pos = self:GetPos() + Vector(0, 0, 20)
						local trace = util.QuickTrace(pos, self:GetUp() * 1000, selfg)
						self.BeamFrac = trace.Fraction
					end
				end
			else
				self:EmitSound("snd_jack_minearm.wav", 60, 70)
				self:SetState(JMod.EZ_STATE_OFF)
			end
		end
	end
	function ENT:Detonate(delay, dmg)
		if(self.Exploded)then return end
		self.Exploded = true

		timer.Simple(delay or 0,function()
			if(IsValid(self))then
				local SelfPos = self:GetPos() - self:GetUp()
				JMod.Sploom(self.Owner, SelfPos, math.random(50,80))
				util.ScreenShake(SelfPos, 99999, 99999,.3, 500)
				local Dir = (self:GetUp() + VectorRand()*.01):GetNormalized()
				JMod.RicPenBullet(self, SelfPos, Dir,(dmg or 600)*JMod.Config.MinePower, true, true)
				self:Remove()
			end
		end)
	end
	function ENT:Think()
		local Time = CurTime()
		local state = self:GetState()
	end
	function ENT:OnRemove()
		
	end
elseif(CLIENT)then
	function ENT:Initialize()
		self.Scanner = JMod.MakeModel(self, "models/maxofs2d/lamp_flashlight.mdl", nil, 0.90, Color(200, 200, 200))
	end
	function ENT:DrawTranslucent()
		local SelfPos, SelfAng = self:GetPos(), self:GetAngles()
		local Up, Right, Forward = SelfAng:Up(), SelfAng:Right(), SelfAng:Forward()
		---
		local BasePos = SelfPos
		local Obscured = util.TraceLine({start=EyePos(), endpos = BasePos, filter = {LocalPlayer(), self}, mask = MASK_OPAQUE}).Hit
		local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if ((not(DetailDraw)) and (Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if (Obscured) then DetailDraw = false end -- if obscured, at least disable details
		if (self:GetState() < 0)then DetailDraw = false end

		if (DetailDraw) then
			ScannerAng = SelfAng:GetCopy()
			JMod.RenderModel(self.Scanner, BasePos, ScannerAng)
		end
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_blusub","EZ Cluster Buster")
end