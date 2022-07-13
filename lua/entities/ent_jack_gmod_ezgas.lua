-- Jackarunda 2021
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezresource"
ENT.PrintName="EZ Gas Tank"
ENT.Category="JMod - EZ Resources"
ENT.IconOverride="materials/ez_resource_icons/gas.png"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies = JMod.EZ_RESOURCE_TYPES.GAS
ENT.JModPreferredCarryAngles = Angle(0,180,0)
ENT.Model = "models/jmodels/explosives/props_explosive/explosive_butane_can.mdl"
ENT.Material = "models/shiny"
ENT.Color = Color(100,100,100)
ENT.ModelScale = 1
ENT.Mass = 20
ENT.ImpactNoise1 = "Canister.ImpactHard"
ENT.DamageThreshold = 80
ENT.BreakNoise = "Metal_Box.Break"
ENT.Hint = nil
---
if(SERVER)then
	function ENT:UseEffect(pos,ent,destructive)
		if(destructive)then
			if(math.random(1,20)==2)then
				if(math.random(1,2)==1)then
					JMod.Sploom(self.Owner,self:GetPos(),math.random(50,130))
				end
				for k,ent in pairs(ents.FindInSphere(pos,600))do
					local Vec=(ent:GetPos()-pos):GetNormalized()
					if(self:Visible(ent))then
						if( (ent:IsPlayer()) or (ent:IsNPC()) or (ent.IsDrGNextbot))then
							ent:SetVelocity(Vec*1000)
						elseif(IsValid(ent:GetPhysicsObject()))then
							ent:GetPhysicsObject():ApplyForceCenter(Vec*50000)
						end
					end
				end
			end
		end
		if vFireInstalled and math.random() <= 0.05 then
			CreateVFireBall(math.random(3, 5), math.random(3, 5), pos, VectorRand() * math.random(300, 500))
		end
	end
	function ENT:AltUse(ply)
		--
	end
elseif(CLIENT)then
	function ENT:Draw()
		self:DrawModel()
		JMod.HoloGraphicDisplay(self,Vector(0,8.15,15),Angle(-90,0,90),.03,300,function()
			JMod.StandardResourceDisplay(JMod.EZ_RESOURCE_TYPES.GAS,self:GetResource(),nil,0,0,200,true)
		end)
	end
	language.Add(ENT.ClassName,ENT.PrintName)
end