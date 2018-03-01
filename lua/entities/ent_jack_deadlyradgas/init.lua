AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local OrganicTable={"player","npc_citizen","npc_combine_s","npc_zombie","npc_fastzombie","npc_fastzombie_torso","npc_zombie_torso","npc_zombine","npc_alyx","npc_barney","npc_kleiner","npc_magnusson","npc_mossman","npc_gman","npc_eli","npc_headcrab","npc_headcrab_black","npc_headcrab_poison","npc_headcrab_fast","npc_poisonzombie","npc_antlion","npc_antlionguard","npc_antlion_worker"}
local SynthTable={"npc_hunter","npc_clawscanner","npc_strider","npc_combinegunship","npc_combinedropship"}

function ENT:Initialize()	
	self.Entity:SetModel("models/Items/AR2_Grenade.mdl")
	self.Entity:PhysicsInit(SOLID_BBOX)	
	self.Entity:SetMoveType(MOVETYPE_FLY)	
	self.Entity:SetSolid(SOLID_BBOX)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
	self.Entity:DrawShadow(false)
	
	self.Age=1
	self.Stuck=false
	self.LifeTime=math.random(50,70)/.3
	self:SetDTInt(1,self.LifeTime)
	
	self.Active=false
	timer.Simple(.2,function()
		if(IsValid(self))then
			self.Active=true
		end
	end)
end

function ENT:Think()
	self.Age=self.Age+1
	if(self.Age>self.LifeTime)then self:Remove() return end
	self:SetDTInt(0,self.Age)
	
	local SelfPos=self:GetPos()
	local Range=self.Age
	local Damg=(self.LifeTime/self.Age)*.075
	
	local Par=self:GetParent()

	if(self.Active)then
		for key,found in pairs(ents.FindInSphere(SelfPos,Range))do
			local Class=found:GetClass()
			if not(Class=="ent_jack_deadlyradgas")then
				if(table.HasValue(OrganicTable,Class))then
				
					local Ouch=DamageInfo()
					if(math.random(1,2)==1)then Ouch:SetDamageType(DMG_RADIATION) else Ouch:SetDamage(DMG_NERVEGAS) end
					Ouch:SetDamage(Damg)
					Ouch:SetDamagePosition(found:GetPos())
					Ouch:SetDamageForce(Vector(0,0,0))
					if(IsValid(self.Owner))then Ouch:SetAttacker(self.Owner) else Ouch:SetAttacker(self.Entity) end
					if(IsValid(self.Weapon))then Ouch:SetInflictor(self.Weapon) else Ouch:SetInflictor(self.Entity) end
					found:TakeDamageInfo(Ouch)
					
					if(math.random(1,5)==1)then
						if not(self.Stuck)then
							self.Stuck=true
							self:SetPos(found:GetPos())
							self:SetVelocity(-self:GetVelocity())
							if not(IsValid(Par))then
								self:SetParent(found)
							end
							self:SetMoveType(MOVETYPE_NONE)
							self.LifeTime=self.LifeTime*1.5
						end
					end
				elseif(table.HasValue(SynthTable,Class))then
				
					local Ouch=DamageInfo()
					if(math.random(1,2)==1)then Ouch:SetDamageType(DMG_RADIATION) else Ouch:SetDamage(DMG_NERVEGAS) end
					Ouch:SetDamage(Damg*.5)
					Ouch:SetDamagePosition(found:GetPos())
					Ouch:SetDamageForce(Vector(0,0,0))
					if(IsValid(self.Owner))then Ouch:SetAttacker(self.Owner) else Ouch:SetAttacker(self.Entity) end
					if(IsValid(self.Weapon))then Ouch:SetInflictor(self.Weapon) else Ouch:SetInflictor(self.Entity) end
					found:TakeDamageInfo(Ouch)
					
					if(math.random(1,6)==1)then
						if not(self.Stuck)then
							self.Stuck=true
							self:SetPos(found:GetPos())
							self:SetVelocity(-self:GetVelocity())
							if not(IsValid(Par))then
								self:SetParent(found)
							end
							self:SetMoveType(MOVETYPE_NONE)
							self.LifeTime=self.LifeTime*1.25
						end
					end
				end
			else
				if(math.random(1,2)==2)then
					local Vec=(found:GetPos()-SelfPos):GetNormalized()
					self:SetVelocity(-Vec*200)
					found:SetVelocity(Vec*200)
				end
			end
		end
		for key,detector in pairs(ents.FindInSphere(SelfPos,Range*1.25))do
			if(detector:GetClass()=="wep_jack_fungun_eta")then
				if(IsValid(detector.Owner))then
					if(detector.Owner==Par)then
						//herp
					else
						detector:EmitSound("snd_jack_radgunwarn.wav")
					end
				else
					detector:EmitSound("snd_jack_radgunwarn.wav")
				end
			end
		end
	end
	
	if not(self.Stuck)then
		local SelfVel=self:GetVelocity()
		self:SetVelocity(-SelfVel*.3+Vector(0,0,-4)+VectorRand()*math.Rand(0,15))
	end
	
	if(IsValid(Par))then
		if not(Par:Health()>0)then
			self:SetParent(nil)
		end
	end
	
	self:NextThink(CurTime()+math.Rand(.4,.6))
	return true
end

function ENT:PhysicsCollide(ent,physobj)
	//nothin
end

function ENT:StartTouch(ent)
	//nothin
end

function ENT:Touch(ent)
	if(ent:IsWorld())then
		timer.Simple(.01,function()
			self:SetVelocity(-self:GetVelocity()*math.Rand(.01,.99))
		end)
	else
		if not(self.Stuck)then
			if not(ent:GetClass()=="ent_jack_deadlyradgas")then
				self.Stuck=true
				self:SetPos(ent:GetPos())
				self:SetVelocity(-self:GetVelocity())
				if not(IsValid(self:GetParent()))then
					self:SetParent(ent)
				end
				self:SetMoveType(MOVETYPE_NONE)
			end
		end
	end
end

function ENT:EndTouch(ent)
	//nothin
end