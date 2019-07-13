-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Parts Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="parts"
ENT.MaxResource=JMod_EZpartBoxSize*JMod_EZpartsCrateSize
ENT.ChildEntity="ent_jack_gmod_ezparts"
ENT.ChildEntityResourceAmount=JMod_EZpartBoxSize
ENT.MainTitleWord="PARTS"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end