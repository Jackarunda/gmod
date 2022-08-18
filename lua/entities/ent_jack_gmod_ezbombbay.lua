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
---
ENT.Bombs = {}
---

local STATE_BROKEN,STATE_EMPTY,STATE_HOLDING=-1, 0, 1
function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
end

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
		self:SetState(STATE_EMPTY)
		if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Drop","DropDud"}, {"Drops the specified bomb, input 0 to drop them all","Drops bomb unarmed"})
			self.Outputs=WireLib.CreateOutputs(self, {"Bombs","LastBomb","RoomLeft"}, {"Table of bombs contained","The last loaded bomb","How much room there is left inside"})
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
			if(data.Speed > 2000)then
				self:Break()
			end
			if(self:GetState() == STATE_BROKEN)then return end
            if(IsValid(ent))then
                if(ent.EZbombBaySize)then
                    self:LoadBomb(ent)
                end
            end
		end
	end
    function ENT:LoadBomb(bomb)
		local RoomLeft = 100
		for k, bombInfo in pairs(self.Bombs) do
			RoomLeft = RoomLeft - bombInfo[2]
		end
		local BombClass = bomb:GetClass()
		if (RoomLeft >= bomb.EZbombBaySize)then
			table.insert(self.Bombs, {BombClass, bomb.EZbombBaySize})
			timer.Simple(0.1, function()
				SafeRemoveEntity(bomb)
			end)
		end
		if (istable(WireLib)) then
			WireLib.TriggerOutput(self, "RoomLeft", RoomLeft)
			WireLib.TriggerOutput(self, "LastBomb", BombClass)
		end
    end
	function ENT:BombRelease(slotNum, arm, ply)
		slotNum = slotNum or #self.Bombs
		arm = arm or true
		ply = ply or self.Owner or game.GetWorld()
		if (#self.Bombs == 0)then return end
		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		--print(tostring(self.Bombs[slotNum][1]))
		local droppedBomb = ents.Create(self.Bombs[slotNum][1])
		droppedBomb:SetPos(Pos + Up*-50 + Forward*-6 + Right*6)
		droppedBomb:SetAngles(Ang + Angle(0, -90, 0))
		droppedBomb:SetVelocity(self:GetVelocity())
		JMod.Owner(droppedBomb, ply)
		droppedBomb:Spawn()
		droppedBomb:Activate()
		if(arm)then
			droppedBomb:SetState(1)
		else
			droppedBomb:SetState(0)
		end
		table.remove(self.Bombs, slotNum)
	end
	function ENT:Break()
		if(self:GetState() == STATE_BROKEN)then return end
		self:SetState(STATE_BROKEN)
		self:EmitSound("snd_jack_turretbreak.wav", 70, math.random(80, 120))
		for i= 1, 20 do
			self:DamageSpark()
		end
		if(#self.Bombs > 0)then
			for i = 0, #self.Bombs do
				timer.Simple(0.1*i, function()
					if(IsValid(self))then
						self:BombRelease(i, false)
					end
				end)
			end
		end
		SafeRemoveEntityDelayed(self, 10)
	end
	function ENT:DamageSpark()
		local effectdata=EffectData()
		effectdata:SetOrigin(self:GetPos()+self:GetUp()*10+VectorRand()*math.random(0, 10))
		effectdata:SetNormal(VectorRand())
		effectdata:SetMagnitude(math.Rand(2, 4)) --amount and shoot hardness
		effectdata:SetScale(math.Rand(.5, 1.5)) --length of strands
		effectdata:SetRadius(math.Rand(2, 4)) --thickness of strands
		util.Effect("Sparks", effectdata, true, true)
		self:EmitSound("snd_jack_turretfizzle.wav", 70, 100)
	end
	function ENT:Use(activator)
		local Alt = activator:KeyDown(JMod.Config.AltFunctionKey)
		if(Alt)then
			self:BombRelease(#self.Bombs, false)
		else
			self:BombRelease(#self.Bombs, true)
		end
	end
	function ENT:OnRemove()
		--
	end
	function ENT:EZdetonateOverride(detonator)
		self:Detonate()
	end
	function ENT:Think()
        self:NextThink(0.1)
	end
elseif(CLIENT)then
 --
end