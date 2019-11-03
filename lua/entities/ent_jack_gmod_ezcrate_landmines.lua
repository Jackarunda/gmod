-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate_small"
ENT.Type="anim"
ENT.PrintName="EZ Landmine Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.MaxItems=JMod_EZsmallCrateSize
ENT.ChildEntity="ent_jack_gmod_ezlandmine"
ENT.MainTitleWord="MINES"
ENT.ResourceUnit="Count"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end