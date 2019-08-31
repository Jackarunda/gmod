-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Ration Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.ResourceType="nutrients"
ENT.MaxResource=JMod_EZnutrientBoxSize*JMod_EZnutrientsCrateSize
ENT.ChildEntity="ent_jack_gmod_eznutrients"
ENT.ChildEntityResourceAmount=JMod_EZnutrientBoxSize
ENT.MainTitleWord="RATIONS"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end