-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezcrate"
ENT.Type="anim"
ENT.PrintName="EZ Advanced Parts Crate"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ"
ENT.Spawnable=true
ENT.AdminSpawnable=true
---
ENT.EZsupplies="advparts"
ENT.MaxResource=JMod_EZadvPartBoxSize*JMod_EZpartsCrateSize
ENT.ChildEntity="ent_jack_gmod_ezadvparts"
ENT.ChildEntityResourceAmount=JMod_EZadvPartBoxSize
ENT.MainTitleWord="ADV.PARTS"
ENT.ResourceUnit="Units"
---
if(SERVER)then
	-- lol
elseif(CLIENT)then
	language.Add(ENT.ClassName,ENT.PrintName)
end