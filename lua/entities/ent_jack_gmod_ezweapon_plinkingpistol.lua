-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezweapon"
ENT.PrintName = "EZ Plinking Pistol"
ENT.Spawnable = true
ENT.Category = "JMod - EZ Weapons"
ENT.WeaponName = "Plinking Pistol"

---
if SERVER then
elseif CLIENT then
	--
	language.Add(ENT.ClassName, ENT.PrintName)
end
