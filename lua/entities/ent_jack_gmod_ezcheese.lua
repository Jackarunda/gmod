-- Jackarunda 2019
AddCSLuaFile()
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Information="glhfggwpezpznore"
ENT.PrintName="EZ Cheese"
ENT.Spawnable=false
ENT.AdminSpawnable=false
if(SERVER)then
	function ENT:Initialize()
		self:SetModel("models/props_c17/playgroundTick-tack-toe_block01a.mdl")
		self:SetModelScale(math.Rand(1.5,3),0)
		self:SetMaterial("models/debug/debugwhite")
		self:SetColor(Color(math.random(190,210),math.random(140,160),0))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:DrawShadow(true)
		self:SetUseType(CONTINUOUS_USE)
		---
		timer.Simple(.01,function()
			self:GetPhysicsObject():SetMass(10)
			self:GetPhysicsObject():Wake()
		end)
	end
	function ENT:PhysicsCollide(data,physobj)
		if(data.DeltaTime>0.2 and data.Speed>50)then
			self:EmitSound("physics/body/body_medium_impact_soft7.wav",60,math.random(70,130))
		end
	end
	function ENT:Use(activator)
		sound.Play("snds_jack_gmod/nom"..math.random(1,5)..".wav",self:GetPos(),60,math.random(90,110))
		activator:SetHealth(activator:Health()+5)
		self:Remove()
	end
elseif(CLIENT)then
	function ENT:Initialize()
		--
	end
	function ENT:Draw()
		self:DrawModel()
	end
	language.Add("ent_jack_gmod_ezcheese","EZ Cheese")
end