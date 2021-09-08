-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Propellant Bottle"
ENT.Category="JMod - EZ Resources"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies=JMod.EZ_RESOURCE_TYPES.PROPELLANT
ENT.JModPreferredCarryAngles=Angle(0,-90,0)
ENT.Model="models/props_lab/jar01b.mdl"
ENT.Material="models/entities/mat_jack_powderbottle"
ENT.ModelScale=2
ENT.Mass=30
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.DamageThreshold=80
ENT.BreakNoise="Metal_Box.Break"
ENT.Hint=nil
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		if(destructive)then
			if(math.random(1,20)==2)then
				if(math.random(1,2)==1)then
					JMod.Sploom(self.Owner,self:GetPos(),math.random(50,130))
				end
				local Tr=util.QuickTrace(pos,Vector(math.random(-200,200),math.random(-200,200),math.random(0,-200)),{self})
				if(Tr.Hit)then
					local Fiah=ents.Create("env_fire")
					Fiah:SetPos(Tr.HitPos+Tr.HitNormal)
					Fiah:SetKeyValue("health",30)
					Fiah:SetKeyValue("fireattack",1)
					Fiah:SetKeyValue("firesize",math.random(20,200))
					Fiah:SetOwner(self.Owner or game.GetWorld())
					Fiah:Spawn()
					Fiah:Activate()
					Fiah:Fire("StartFire","",0)
					Fiah:Fire("kill","",math.random(3,10))
				end
				for k,ent in pairs(ents.FindInSphere(pos,600))do
					local Vec=(ent:GetPos()-pos):GetNormalized()
					if(self:Visible(ent))then
						if((ent:IsPlayer())or(ent:IsNPC()))then
							ent:SetVelocity(Vec*1000)
						elseif(IsValid(ent:GetPhysicsObject()))then
							ent:GetPhysicsObject():ApplyForceCenter(Vec*50000)
						end
					end
				end
			end
		end
	end
	function ENT:AltUse(ply)
		--
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(.5,0,10.4),Angle(0,0,0),.035,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.PROPELLANT,self:GetResource(),nil,0,0,150,true,"JMod-Stencil-MS")
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end