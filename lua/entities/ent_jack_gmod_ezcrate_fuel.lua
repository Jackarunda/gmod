-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Fuel Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="fuel"
ENT.MaxResource=JMod_EZfuelCanSize*JMod_EZcrateSize
ENT.ChildEntity="ent_jack_gmod_ezfuel"
ENT.ChildEntityResourceAmount=JMod_EZfuelCanSize
ENT.MainTitleWord="FUEL"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end