-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezweapon"
ENT.PrintName = "EZ Flintlock Pistol"
ENT.Spawnable = false -- disabled until after econ phase 1
ENT.Category = "JMod - EZ Weapons"
ENT.WeaponName = "Flintlock Pistol"

---
if SERVER then
elseif CLIENT then
	--
	language.Add(ENT.ClassName, ENT.PrintName)
end
