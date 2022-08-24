--Jackarunda 2022
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, AdventureBoots"
ENT.Category="JMod - EZ Misc."
ENT.Information="EZ method for loading bombs"
ENT.PrintName="EZ Bomb Bay"
ENT.Spawnable=true
ENT.AdminSpawnable=false
---
ENT.JModPreferredCarryAngles=Angle(0, -90, 0)
ENT.EZlowFragPlease=true
---
ENT.Bombs = {}
ENT.RoomLeft = 100

if(SERVER)then
	function ENT:SpawnFunction(ply, tr)
		local SpawnPos=tr.HitPos+tr.HitNormal*40
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
		self.Entity:SetModel("models/jmod/bomb_bay/bomb_bay_exterior.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(300)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Drop [NORMAL]","DropDud [NORMAL]"}, {"Drops the specified bomb, input 0 to drop them all","Drops bomb unarmed"})
			self.Outputs=WireLib.CreateOutputs(self, {"LastBomb [STRING]","RoomLeft [NORMAL]"}, {"The last loaded bomb","How much room there is left inside"})
		end
	end

	function ENT:UpdateWireOutputs()
		if (istable(WireLib))then
				WireLib.TriggerOutput(self, "RoomLeft", self.RoomLeft)
			if(#self.Bombs > 0)then
				WireLib.TriggerOutput(self, "LastBomb", tostring(self.Bombs[#self.Bombs][1]))
			else
				WireLib.TriggerOutput(self, "LastBomb", "")
			end
		end
	end

	function ENT:TriggerInput(iname, value)
		if(iname == "Drop" and value > 0) then
			self:BombRelease(value, true)
		elseif(iname == "Drop" and value == 0) then
			if(#self.Bombs > 0)then
				for i = 1, #self.Bombs do
					timer.Simple(1*i, function()
						if(IsValid(self))then
							self:BombRelease(i, true)
						end
					end)
				end
			end
		elseif(iname == "DropDud" and value > 0) then
			self:BombRelease(value, false)
		elseif(iname == "DropDud" and value == 0) then
			if(#self.Bombs > 0)then
				for i = 1, #self.Bombs do
					timer.Simple(1*i, function()
						if(IsValid(self))then
							self:BombRelease(i, false)
						end
					end)
				end
			end
		end
	end

	function ENT:PhysicsCollide(data, physobj)
		if not(IsValid(self))then return end
        local ent = data.HitEntity
		if(data.DeltaTime > 0.2)then
			if(data.Speed > 50)then
				self:EmitSound("Metal_Box.ImpactHard")
			end
			if(self.Destroyed)then return end
			if(data.Speed > 1500)then
				self:Destroy()
			end
            if(IsValid(ent))then
                if(ent.EZbombBaySize)then
                    self:LoadBomb(ent)
                end
            end
		end
	end

    function ENT:LoadBomb(bomb)
		if not((IsValid(bomb)and(bomb:IsPlayerHolding()))or(self:IsPlayerHolding()))then return end
		self.RoomLeft = 100
		for k, bombInfo in pairs(self.Bombs) do
			self.RoomLeft = self.RoomLeft - bombInfo[2]
		end
		local BombClass = bomb:GetClass()
		if (self.RoomLeft >= bomb.EZbombBaySize)then
			table.insert(self.Bombs, {BombClass, bomb.EZbombBaySize})
			self:EmitSound("snd_jack_metallicload.wav",65,90)
			timer.Simple(0.1, function()
				SafeRemoveEntity(bomb)
			end)
		end
		self.EZdroppableBombLoadTime=CurTime()
		self:UpdateWireOutputs()
    end

	function ENT:BombRelease(slotNum, arm, ply)
		local NumOBombs = #self.Bombs
		slotNum = slotNum or NumOBombs
		ply = ply or self.Owner or game.GetWorld()

		if (NumOBombs <= 0)then return end
		if (slotNum == 0 or slotNum > NumOBombs)then return end

		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		local droppedBomb = ents.Create(self.Bombs[slotNum][1])
		droppedBomb:SetPos(Pos + Up*-50 + Forward*-6 + Right*6)
		droppedBomb:SetAngles(Ang + Angle(0, -90, 0))
		droppedBomb:SetVelocity(self:GetVelocity())
		JMod.Owner(droppedBomb, ply)
		if(arm)then droppedBomb.DropOwner=ply end
		droppedBomb:Spawn()
		droppedBomb:Activate()
		if(arm)then
			droppedBomb:SetState(1)
		else
			droppedBomb:SetState(0)
		end
		table.remove(self.Bombs, slotNum)
		if(#self.Bombs <= 0)then self.EZdroppableBombLoadTime=nil end
		self:UpdateWireOutputs()
	end

	function ENT:OnTakeDamage(dmginfo)
		self.Entity:TakePhysicsDamage(dmginfo)
		if(JMod.LinCh(dmginfo:GetDamage(),80,160))then
			self:Destroy(dmginfo)
		end
	end

	function ENT:Destroy(dmginfo)
		if(self.Destroyed)then return end
		self.Destroyed=true
		self:EmitSound("snd_jack_turretbreak.wav",70,math.random(80,120))
		for i=1,20 do JMod.DamageSpark(self) end
		for i = 1, #self.Bombs do
			timer.Simple(0.2, function()
				if(IsValid(self))then
					self:BombRelease(i, false, self.Owner)
				end
			end)
		end
		timer.Simple(2, function()
			SafeRemoveEntity(self)
		end)
	end

	function ENT:Use(activator)
		JMod.Hint(activator,"bomb bay")
		self:BombRelease(#self.Bombs, false)
	end

elseif(CLIENT)then
 --
end