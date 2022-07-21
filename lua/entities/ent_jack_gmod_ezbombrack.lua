--Jackarunda 2022
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda, AdventureBoots"
ENT.Category="JMod - EZ Misc."
ENT.Information="EZ method for loading bombs"
ENT.PrintName="EZ Bomb Rack"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.JModPreferredCarryAngles=Angle(0, -90, 0)
---
ENT.Bomb = nil
ENT.Weld = nil
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
		self.Entity:SetModel("models/props_phx/gears/rack9.mdl")
		self.Entity:PhysicsInit(SOLID_VPHYSICS)
		self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:DrawShadow(true)
		self.Entity:SetUseType(SIMPLE_USE)
		---
		timer.Simple(.01, function()
			self:GetPhysicsObject():SetMass(30)
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
                if(ent.EZRackOffset)then
                    self:AttachBomb()
                else
                    print("Ent does not contain EZRackOffset")
                end
            end
		end
	end
    function ENT:AttachBomb(ent)
        local Forward, Right, Up = self:GetForward(), self:GetRight(), self:GetUp()
        timer.Simple(0.1, function() 
            ent:SetPos(ent.EZRackOffset)
            ent:SetAngles(ent.EZRackAngles)
            local stick = constraint.Weld(self, ent, 0, 0, 50000, true, false)
            if(stick)then 
                self.Weld = stick 
                self.Bomb = ent
                print("Stuck")
                return true 
            else
                print("Failed to stick")
                return false
            end

        end)
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
        activator:PickupObject(self)
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