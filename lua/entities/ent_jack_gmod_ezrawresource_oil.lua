-- Jackarunda 2019
AddCSLuaFile()
ENT.Base="ent_jack_gmod_ezrawresource"
ENT.Type="anim"
ENT.Author="Jackarunda"
ENT.Category="JMod - EZ Resources"
ENT.Information="glhfggwpezpznore"
ENT.NoSitAllowed=true
ENT.Spawnable=true
ENT.AdminOnly=false
---
ENT.IsJackyEZresource=true
---
ENT.EZsupplies="raw_metal"
ENT.Model="models/props_c17/oildrum001.mdl"
ENT.Material="models/shiny"
ENT.Color=Color(40,40,40)
ENT.ModelScale=.75
ENT.Mass=50
ENT.ImpactNoise1="Canister.ImpactHard"
ENT.DamageThreshold=100
ENT.BreakNoise="Metal_Box.Break"
---
if(SERVER)then
	-- pootis
else
	-- bepis
end