-- Jackarunda 2021
AddCSLuaFile()
ENT.Base = "ent_jack_gmod_ezgrenade"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.PrintName = "EZ Flashbang"
ENT.Category = "JMod - EZ Misc."
ENT.Spawnable = true
ENT.JModPreferredCarryAngles = Angle(0, 140, 0)
ENT.Model = "models/jmod/explosives/grenades/flashbang/flashbang.mdl"
--ENT.ModelScale=1.5
ENT.SpoonScale = 2
ENT.PinBodygroup = {1, 1}
ENT.SpoonBodygroup = {2, 1}
ENT.DetDelay = 2

if SERVER then
	function ENT:Detonate()
		if self.Exploded then return end
		self.Exploded = true
		local SelfPos, Time = self:GetPos() + Vector(0, 0, 10), CurTime()
		JMod.Sploom(self.EZowner, self:GetPos(), 20)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 140)
		self:EmitSound("snd_jack_fragsplodeclose.ogg", 90, 140)
		local plooie = EffectData()
		plooie:SetOrigin(SelfPos)
		plooie:SetScale(1)
		util.Effect("eff_jack_gmod_flashbang", plooie, true, true)
		util.ScreenShake(SelfPos, 20, 20, .2, 1000)

		local BlastDist = 500
		for k, v in pairs(ents.FindInSphere(SelfPos, BlastDist)) do
			if v:IsNPC() then
				v.EZNPCincapacitate = Time + math.Rand(3, 6)
			end
			if v:IsPlayer() and v:Alive() and JMod.ClearLoS(self, v, false, 10) then
				local AlreadyBLasted = v:GetNW2Float("EZblastShock", 0)
				local BlastAmount = 200
				if JMod.PlyHasArmorEff(v, "earPro") then
					BlastAmount = BlastAmount * .5
				end
				v:SetNW2Float("EZblastShock", math.Clamp(AlreadyBLasted + BlastAmount * (1 - SelfPos:Distance(v:GetPos()) / BlastDist), 0, 100))
			end
		end

		self:SetColor(Color(0, 0, 0))

		timer.Simple(.1, function()
			if not IsValid(self) then return end
			util.BlastDamage(self, JMod.GetEZowner(self), SelfPos, 1000, 2)
		end)

		SafeRemoveEntityDelayed(self, 10)
	end
	
elseif CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	language.Add("ent_jack_gmod_ezflashbang", "EZ Flashbang Grenade")
end

hook.Add("SetupMove", "JMOD_FLASHBANG", function(ply, mvd, cmd)
	local BlastShock = ply:GetNW2Float("EZblastShock", nil)
	if BlastShock then
		-- Slow player's movement
		local CurrentSpeed = mvd:GetMaxClientSpeed()
		local CurrentSlow = (1 - (BlastShock or 0) / 100) ^ 2
		if CurrentSpeed > 10 then
			mvd:SetMaxClientSpeed(math.max(CurrentSpeed * CurrentSlow, 10))
			mvd:SetMaxSpeed(math.max(CurrentSpeed * CurrentSlow, 10))
		end

		if IsFirstTimePredicted() then
			local WearoffMult = 1 / (JMod.Config.Explosives.Flashbang.StunDurationMult or 1)
			BlastShock = math.Clamp(BlastShock - 10 * WearoffMult * FrameTime(), 0, 100)
			if (BlastShock <= 0) then
				BlastShock = nil
			end
			ply:SetNW2Float("EZblastShock", BlastShock)
		end
	end
end)