include('shared.lua')

language.Add("ent_jack_fgc_energy_rite", "Energy Cartridge")

function ENT:Initialize()
end

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:Think()
end