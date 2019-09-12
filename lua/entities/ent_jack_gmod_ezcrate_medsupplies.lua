-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Medical Supplies Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="medsupplies"
ENT.MaxResource=JMod_EZmedSupplyBoxSize*JMod_EZpartsCrateSize
ENT.ChildEntity="ent_jack_gmod_ezmedsupplies"
ENT.ChildEntityResourceAmount=JMod_EZmedSupplyBoxSize
ENT.MainTitleWord="MED.SUPPLIES"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end