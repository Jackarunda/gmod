-- Jackarunda 2021
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Ground Scanner"
ENT.Category="JMod - EZ Machines"
ENT.Spawnable=true
ENT.AdminOnly=false
ENT.NoSitAllowed=true
ENT.Base="ent_jack_gmod_ezmachine_base"
---
ENT.Model="models/jmod/machines/groundscanner.mdl"
ENT.Mat="models/mat_jack_gmod_groundscanner"
ENT.Mass=200
---
ENT.JModPreferredCarryAngles=Angle(-90,180,0)
ENT.EZcolorable = true
ENT.EZupgradable= true
ENT.PhysMatDetectionWhitelist={
	"metal",
	"metalvehicle",
	"metalpanel",
	"metal_barrel",
	"floating_metal_barrel",
	"grenade",
	"canister",
	"weapon",
	"slipperymetal",
	"jalopy",
	"roller",
	"metalvent",
	"computer",
	"solidmetal"
}
ENT.StaticPerfSpecs={
	MaxElectricity=100,
	MaxDurability=100,
	Armor=3
}
ENT.DynamicPerfSpecs={
	Armor=.8,
	ScanSpeed=5,
	ScanRange=20
}
function ENT:CustomSetupDataTables()
	self:NetworkVar("Int",2,"Progress")
end
if(SERVER)then
	function ENT:CustomInit()
		self:SetProgress(0)
		self.Snd1=CreateSound(self,"snds_jack_gmod/40hz_sine1.wav")
		self.Snd2=CreateSound(self,"snds_jack_gmod/40hz_sine2.wav")
		self.Snd3=CreateSound(self,"snds_jack_gmod/40hz_sine3.wav")
		self.Snd1:SetSoundLevel(100)
		self.Snd2:SetSoundLevel(100)
		self.Snd3:SetSoundLevel(100)
	end

	function ENT:TurnOn(activator)
		if self:GetState() > JMod.EZ_STATE_OFF then return end
		if self:GetElectricity() > 0 then
			if IsValid(activator) then self.EZstayOn = true end
			self:SetState(JMod.EZ_STATE_ON)
			self:SFX("snd_jack_metallicclick.ogg")
		else
			JMod.Hint(activator,"nopower")
		end
	end

	function ENT:TurnOff(activator)
		if (self:GetState() <= JMod.EZ_STATE_OFF) then return end
		if IsValid(activator) then self.EZstayOn = nil end
		self:SetState(JMod.EZ_STATE_OFF)
		self:EmitSound("snd_jack_metallicclick.ogg",50,100)
		self.Snd1:Stop()
		self.Snd2:Stop()
		self.Snd3:Stop()
		self:SetProgress(0)
	end

	function ENT:Use(activator)
		local State = self:GetState()
		JMod.Hint(activator, "ground scanner")
		local OldOwner = self.EZowner
		JMod.SetEZowner(self, activator)
		local Alt = JMod.IsAltUsing(activator)
		if (Alt) then
			if (IsValid(self.EZowner)) then
				if (OldOwner ~= self.EZowner) then -- if owner changed then reset team color
					JMod.Colorify(self)
				end
			end
			if (State == JMod.EZ_STATE_BROKEN) then
				JMod.Hint(activator, "destroyed", self)
				return
			elseif (State == JMod.EZ_STATE_OFF) then
				self:TurnOn(activator)
			elseif (State == JMod.EZ_STATE_ON) then
				self:TurnOff(activator)
			end
		else
			activator:PickupObject(self)
		end
	end

	local function FindNaturalResourcesInRange(pos, rng, tbl)
		local Res = {}
		for k, v in pairs(tbl) do
			local DiffVec = pos - v.pos
			if (math.abs(DiffVec.x) - v.siz*.5 <= rng) and (math.abs(DiffVec.y) - v.siz*.5 <= rng) then
				table.insert(Res, {
					typ = v.typ,
					pos = v.pos,
					siz = v.siz,
					rate = v.rate,
					amt = v.amt
				})
			end
		end
		return Res
	end

	function ENT:CanScan()
		if (self:GetVelocity():Length() < 10) then
			local Tr = util.TraceLine({
				start = self:GetPos(),
				endpos = self:GetPos() + Vector(0, 0, -60),
				filter = {self}
			})
			if ((Tr.Hit) and (Tr.HitWorld)) then return true end
		end
		return false
	end

	function ENT:Think()
		local State = self:GetState()

		self:UpdateWireOutputs()

		if (State == JMod.EZ_STATE_BROKEN) then
			self.Snd1:Stop()
			self.Snd2:Stop()
			self.Snd3:Stop()
			if (self:GetElectricity() > 0) then
				if (math.random(1, 4) == 2) then JMod.DamageSpark(self) end
			end

			return
		elseif(State == JMod.EZ_STATE_ON)then
			self:ConsumeElectricity(.3)
			if(self:CanScan())then
				self:SetProgress(math.Clamp(self:GetProgress() + self.ScanSpeed^1.5/3, 0, 100))
				JMod.EmitAIsound(self:GetPos(), 300, .5, 256)
				if(self:GetProgress() >= 100)then
					self:FinishScan()
					self:SetProgress(0)
				end
			else
				self:SetProgress(0)
			end
		end
		self:NextThink(CurTime() + .5)
		return true
	end

	function ENT:SFX(snd)
		self.Snd1:Stop()
		self.Snd2:Stop()
		self.Snd3:Stop()
		self:EmitSound(snd, 60, 100)
		timer.Simple(1,function()
			if(IsValid(self)) and (self:GetState() == JMod.EZ_STATE_ON) and (self:GetGrade() ~= 5) then
				self.Snd1:PlayEx(1, 80)
				self.Snd2:PlayEx(1, 80)
				self.Snd3:PlayEx(1, 80)
			end
		end)
	end

	function ENT:FinishScan()
		local Pos, Results, Grade = self:GetPos(), {}, self:GetGrade()
		local ScanRangeSourceUnits = self.ScanRange * 52.493 -- meters to source units
		table.Add(Results,FindNaturalResourcesInRange(Pos, ScanRangeSourceUnits, JMod.NaturalResourceTable))
		--if Grade > 1 then
			for k, v in pairs(ents.FindInSphere(Pos, ScanRangeSourceUnits))do
				if v == self then continue end
				if IsValid(v) then
					local AnomalyPos = v:LocalToWorld(v:OBBCenter())
					if (Pos.z + 64) >= AnomalyPos.z then
						local Phys = v:GetPhysicsObject()
						if(v.EZscannerDanger)then
							table.insert(Results, {
								typ = "DANGER",
								pos = AnomalyPos,
								siz = 20
							})
						elseif IsValid(Phys) then
							local Mat = Phys:GetMaterial()
							if table.HasValue(self.PhysMatDetectionWhitelist, Mat) and (Phys:GetMass() >= 20) then
								local Class = v:GetClass()
								if not(string.find(Class,"prop_door") or string.find(Class,"prop_dynamic"))then
									if math.Round(math.random(1, 3000)) >= 3000 then
										table.insert(Results, {
											typ = "SMILEY",
											pos = AnomalyPos,
											siz = 30
										})
									else
										table.insert(Results, {
											typ = "ANOMALY",
											pos = AnomalyPos,
											siz = 180
										})
									end
								end
							elseif v:IsPlayer() then
								if ((v.EZarmor) and (v.EZarmor.totalWeight >= 100 / Grade)) then
									table.insert(Results, {
										typ = "ANOMALY",
										pos = AnomalyPos,
										siz = 180
									})
								end
							end
						end
					end
				end
			end
		--end
		if (#Results > 0) then
			self:SFX("snds_jack_gmod/tone_good.ogg")
			-- need to convert all the positions to local coordinates
			local Pos, Ang = self:GetPos(), self:GetAngles()
			Ang:RotateAroundAxis(Ang:Right(), -90)
			Ang:RotateAroundAxis(Ang:Up(), 90)
			for k,v in pairs(Results)do
				local NewPos, NewAng = WorldToLocal(v.pos, Angle(0, 0, 0), Pos, Ang)
				v.pos = NewPos
			end
			table.sort(Results,function(a,b)
				return a.siz > b.siz
			end)
		else
			self:SFX("snds_jack_gmod/tone_meh.ogg")
		end
		net.Start("JMod_ResourceScanner")
		net.WriteEntity(self)
		net.WriteTable(Results)
		net.Broadcast()
	end

	function ENT:OnRemove()
		self.Snd1:Stop()
		self.Snd2:Stop()
		self.Snd3:Stop()
	end

elseif(CLIENT)then
	ENT.DSU=0 -- Display Start Up, a float that increases over time to allow UI elements to appear in sequence
	ENT.LastState=0
	net.Receive("JMod_ResourceScanner",function()
		local Ent=net.ReadEntity()
		if(IsValid(Ent))then
			Ent.ScanResults=net.ReadTable()
			if Ent.LastScanTime then
				Ent.LastScanTime = CurTime()
			end
		end
	end)
	function ENT:CustomInit()
		self.Tank = JMod.MakeModel(self, "models/props_wasteland/horizontalcoolingtank04.mdl")
		self.ScanResults = {}
	end
	function ENT:Think()
		local FT=FrameTime()
		self.DSU=math.Clamp(self.DSU+FT*.7,0,1)
	end
	local SourceUnitsToMeters,MetersToPixels=.0192,7.5
	local Circol,SourceUnitsToPixels=Material("mat_jack_gmod_blurrycirclefull"),SourceUnitsToMeters*MetersToPixels
	local WarningIcon=Material("ez_misc_icons/warning.png")
	local SmileyIcon=Material("ez_misc_icons/smiley.png")
	function ENT:Draw()
		local Time,SelfPos,SelfAng,State,Grade=CurTime(),self:GetPos(),self:GetAngles(),self:GetState(),self:GetGrade()
		if((State==JMod.EZ_STATE_ON)and(self.LastState~=State))then self.DSU=0 end
		self.LastState=State
		local Up,Right,Forward=SelfAng:Up(),SelfAng:Right(),SelfAng:Forward()
		--
		self:DrawModel()
		--
		local BasePos=SelfPos+Forward*2
		local Obscured=util.TraceLine({start=EyePos(),endpos=BasePos,filter={LocalPlayer(),self},mask=MASK_OPAQUE}).Hit
		local Closeness=LocalPlayer():GetFOV()*(EyePos():Distance(SelfPos))
		local DetailDraw=Closeness<36000 -- cutoff point is 400 units when the fov is 90 degrees
		if((not(DetailDraw))and(Obscured))then return end -- if player is far and sentry is obscured, draw nothing
		if(Obscured)then DetailDraw=false end -- if obscured, at least disable details
		if(State==JMod.EZ_STATE_BROKEN)then DetailDraw=false end -- look incomplete to indicate damage, save on gpu comp too
		if(DetailDraw)then
			local TankAng=SelfAng:GetCopy()
			TankAng:RotateAroundAxis(Right,-90)
			JMod.RenderModel(self.Tank, BasePos,TankAng, Vector(.12, .12, .12), nil, JMod.EZ_GRADE_MATS[Grade])
			if((Closeness<30000)and(State==JMod.EZ_STATE_ON))then
				local DisplayAng,Vary=SelfAng:GetCopy(),(math.sin(CurTime()*5)/2+.5)^.25
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),180)
				DisplayAng:RotateAroundAxis(DisplayAng:Up(),-90)
				DisplayAng:RotateAroundAxis(DisplayAng:Forward(),-45)
				local Opacity=math.random(75,150)
				cam.Start3D2D(SelfPos-Up*35-Forward*5,DisplayAng,.08)
				surface.SetDrawColor(20,50,20,180)
				surface.SetMaterial(Circol)
				surface.DrawTexturedRect(-50*MetersToPixels,-95*MetersToPixels,100*MetersToPixels,100*MetersToPixels)
				local CenterY=-45*MetersToPixels
				if(self.DSU>.6)then 
					surface.DrawCircle(0,CenterY,40*MetersToPixels,255,255,255,Opacity)
					draw.SimpleText("40m","JMod-Display-XS",40*MetersToPixels-20,-45*MetersToPixels,Color(200,200,200,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				end
				if(self.DSU>.5)then 
					surface.DrawCircle(0,CenterY,30*MetersToPixels,255,255,255,Opacity)
					draw.SimpleText("30m","JMod-Display-XS",30*MetersToPixels-20,-45*MetersToPixels,Color(200,200,200,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				end
				if(self.DSU>.4)then 
					surface.DrawCircle(0,CenterY,20*MetersToPixels,255,255,255,Opacity)
					draw.SimpleText("20m","JMod-Display-XS",20*MetersToPixels-20,-45*MetersToPixels,Color(200,200,200,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				end
				if(self.DSU>.3)then 
					surface.DrawCircle(0,CenterY,10*MetersToPixels,255,255,255,Opacity)
					draw.SimpleText("10m","JMod-Display-XS",10*MetersToPixels-20,-45*MetersToPixels,Color(200,200,200,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
				end
				if(self.DSU>.2)then 
					surface.DrawLine(0,CenterY,0,-85*MetersToPixels)
					draw.SimpleText("?=metallic object","JMod-Display-XS",0,-15*MetersToPixels+56,Color(200,200,200,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
					local Renj=JMod.EZ_GRADE_BUFFS[Grade]*20*MetersToPixels
					surface.DrawCircle(0,CenterY,Renj+2,255,0,0,Opacity)
				end
				--
				for k,v in pairs(self.ScanResults)do
					local X,Y,Radius=v.pos.x*SourceUnitsToPixels,v.pos.y*SourceUnitsToPixels,v.siz*SourceUnitsToPixels
					if(v.typ=="ANOMALY")then
						if(self.DSU>.9)then draw.SimpleText("?","JMod-Display",X,-Y-45*MetersToPixels-18,Color(255,255,255,(Opacity+150*Vary)),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP) end
					elseif(v.typ=="DANGER")then
						if(self.DSU>.9)then 
						    surface.SetDrawColor(255,255,255,Opacity+150*Vary)
    						surface.SetMaterial(WarningIcon)
							surface.DrawTexturedRect(X-v.siz/2,(-Y-v.siz/2)-45*MetersToPixels-18,v.siz,v.siz)
						end
					elseif(v.typ=="SMILEY")then
						if(self.DSU>.8)then 
							surface.SetDrawColor(255,255,255,Opacity+150*Vary)
    						surface.SetMaterial(SmileyIcon)
							surface.DrawTexturedRect(X-v.siz/2,(-Y-v.siz/2)-45*MetersToPixels-18,v.siz,v.siz)
						end
					else
						if(self.DSU>.7)then JMod.StandardResourceDisplay(v.typ,(v.amt or v.rate),nil,X,-Y-45*MetersToPixels,Radius*2,true,"JMod-Display-S",200,v.rate) end
					end
				end
				--
				if(self.DSU>.1)then 
					draw.SimpleTextOutlined("POWER","JMod-Display",-200,-60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					local ElecFrac=self:GetElectricity()/self.MaxElectricity
					local R,G,B=JMod.GoodBadColor(ElecFrac)
					draw.SimpleTextOutlined(tostring(math.Round(ElecFrac*100)).."%","JMod-Display",-200,-30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				end
				if(self.DSU>.8)then 
					draw.SimpleTextOutlined("SCANNING:","JMod-Display",200,-60,Color(255,255,255,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
					local ProgFrac=self:GetProgress()/100
					local R,G,B=JMod.GoodBadColor(ProgFrac)
					draw.SimpleTextOutlined(tostring(math.Round(ProgFrac*100)).."%","JMod-Display",200,-30,Color(R,G,B,Opacity),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,3,Color(0,0,0,Opacity))
				end
				cam.End3D2D()
			end
		end
	end
	language.Add("ent_jack_gmod_ezgroundscanner","EZ Ground Scanner")
end
