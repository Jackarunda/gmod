-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Battery Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="power"
ENT.MaxResource=JMod_EZbatterySize*JMod_EZcrateSize
ENT.ChildEntity="ent_jack_gmod_ezbattery"
ENT.ChildEntityResourceAmount=JMod_EZbatterySize
ENT.MainTitleWord="BATTERIES"
ENT.ResourceUnit="Charge"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end