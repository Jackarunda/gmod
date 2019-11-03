-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Explosives Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="explosives"
ENT.MaxResource=JMod_EZexplosivesBoxSize*JMod_EZcrateSize
ENT.ChildEntity="ent_jack_gmod_ezexplosives"
ENT.ChildEntityResourceAmount=JMod_EZexplosivesBoxSize
ENT.MainTitleWord="EXPLOSIVES"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end