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
		self.Entity:SetModel("models/hunter/blocks/cube1x3x1.mdl")
		self.Entity:SetMaterial("phoenix_storms/metal")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(100)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():EnableDrag(false)
		end)
		---
		self:SetState(STATE_EMPTY)
		--[[if istable(WireLib) then
			self.Inputs=WireLib.CreateInputs(self, {"Detonate", "Arm"}, {"Directly detonates the bomb", "Arms bomb when > 0"})
			self.Outputs=WireLib.CreateOutputs(self, {"State", "Guided"}, {"-1 broken \n 0 off \n 1 armed", "True when guided"})
		end]]--
	end
	--[[function ENT:TriggerInput(iname, value)
		if(iname == "Detonate" and value > 0) then
			self:Detonate()
		elseif (iname == "Arm" and value > 0) then
			self:SetState(STATE_ARMED)
		elseif (iname == "Arm" and value == 0) then
			self:SetState(STATE_OFF)
		end
	end]]--
	function ENT:PhysicsCollide(data, physobj)
		if not(IsValid(self))then return end
        local ent = data.HitEntity
		if(data.DeltaTime > 0.2)then
			if(data.Speed > 50)then
				self:EmitSound("Metal_Box.ImpactHard")
			end
			--[[if(data.Speed > 2000)then
				self:Break()
			end]]--
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
		if (RoomLeft >= bomb.EZbombBaySize)then
			table.insert(self.Bombs, {bomb:GetClass(), bomb.EZbombBaySize})
			timer.Simple(0.1, function()
				SafeRemoveEntity(bomb)
			end)
		end
    end
	function ENT:BombRelease(slotNum, arm, ply)
		slotNum = slotNum or #self.Bombs
		arm = arm or true
		ply = ply or self.Owner
		if (#self.Bombs == 0)then return end
		local Up, Forward, Right = self:GetUp(), self:GetForward(), self:GetRight()
		local Pos, Ang = self:GetPos(), self:GetAngles()
		--print(tostring(self.Bombs[slotNum][1]))
		local droppedBomb = ents.Create(self.Bombs[slotNum][1])
		droppedBomb:SetPos(Pos + Up * -50)
		droppedBomb:SetAngles(Ang)
		droppedBomb:SetVelocity(self:GetVelocity())
		JMod.Owner(droppedBomb, ply)
		droppedBomb:Spawn()
		droppedBomb:Activate()
		if(arm == true)then
			droppedBomb:SetState(1)
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
		SafeRemoveEntityDelayed(self, 10)
	end
	function ENT:OnTakeDamage(dmginfo)
		--
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