-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Gas Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="gas"
ENT.MaxResource=JMod_EZfuelCanSize*JMod_EZcrateSize
ENT.ChildEntity="ent_jack_gmod_ezgas"
ENT.ChildEntityResourceAmount=JMod_EZfuelCanSize
ENT.MainTitleWord="GAS"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end