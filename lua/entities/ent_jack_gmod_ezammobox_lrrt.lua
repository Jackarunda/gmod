-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezammobox"
ENT.PrintName = "EZ Light Rifle Round-Tracer"
ENT.Spawnable = false -- soon(tm)
ENT.Category = "JMod - EZ Special Ammo"
ENT.EZammo = "Light Rifle Round-Tracer"

---
if SERVER then
elseif CLIENT then
	--
	language.Add(ENT.ClassName, ENT.PrintName)
end
