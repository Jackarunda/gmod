-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Chemical Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="chemicals"
ENT.MaxResource=JMod_EZchemicalsSize*JMod_EZcrateSize
ENT.ChildEntity="ent_jack_gmod_ezchemicals"
ENT.ChildEntityResourceAmount=JMod_EZchemicalsSize
ENT.MainTitleWord="CHEMICALS"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end