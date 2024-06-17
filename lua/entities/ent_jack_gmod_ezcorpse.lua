--AdventureBoots 2023
AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "JMod Corpse"
ENT.Author = "Jackarunda, AdventureBoots"
ENT.Category = "JMod - EZ Misc."
ENT.Information = "Momento Mori"
ENT.Spawnable = false -- This is not meant to be spawned seperate from a player

if SERVER then
	function ENT:Initialize()
		if not self.DeadPlayer then self:Remove() return end
		self.EZoverDamage = self.EZoverDamage or 0
		self.TimeTillRemoval = JMod.Config.QoL.JModCorpseStayTime * 60

		self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)	
		self:SetSolid(SOLID_VPHYSICS)
		self:SetNoDraw(true)

		local Ply = self.DeadPlayer
		local Ragdoll = ents.Create("prop_ragdoll")
		Ragdoll:SetModel(Ply:GetModel())
		Ragdoll:SetSkin(self.DeadPlayer:GetSkin())
		Ragdoll:SetBodyGroups(self.BodyGroupValues)
		Ragdoll:SetPos(Ply:GetPos())
		Ragdoll:SetAngles(Ply:GetAngles())
		Ragdoll:Spawn()
		Ragdoll:Activate()
		----------------------Kycea contribution Begin----------------------
		timer.Simple(0, function()
			if IsValid(Ragdoll) then
				for i = 1, Ragdoll:GetPhysicsObjectCount() do
					local Phys = Ragdoll:GetPhysicsObjectNum(i - 1)
					if (Phys) and IsValid(Phys)then
						local pos, ang = Ply:GetBonePosition(Ply:TranslatePhysBoneToBone(i - 1))
						Phys:SetPos(pos)
						Phys:SetVelocity(Ply:GetVelocity())
						Phys:SetAngles(ang)
					end
				end
			end
		end)
		----------------------Kycea contribution end------------------------
		if (Ply.EZarmor and Ply.EZarmor.items) and IsValid(Ragdoll) then
			Ragdoll.EZarmorP = {}
			local Parachute = false
			for k, v in pairs(Ply.EZarmor.items) do
				local ArmorInfo = JMod.ArmorTable[v.name]
				if not ArmorInfo.plymdl then
					local Index = Ragdoll:LookupBone(ArmorInfo.bon)
					local Pos, Ang = Ragdoll:GetBonePosition(Index)
					
					if Pos and Ang then
						-- Pos it
						local Right, Forward, Up = Ang:Right(), Ang:Forward(), Ang:Up()
						Pos = Pos + Right * ArmorInfo.pos.x + Forward * ArmorInfo.pos.y + Up * ArmorInfo.pos.z
						Ang:RotateAroundAxis(Right, ArmorInfo.ang.p)
						Ang:RotateAroundAxis(Up, ArmorInfo.ang.y)
						Ang:RotateAroundAxis(Forward, ArmorInfo.ang.r)
						-- Spawn it
						local ArmorPiece = ents.Create(ArmorInfo.ent)
						ArmorPiece:SetPos(Pos)
						ArmorPiece:SetAngles(Ang)
						ArmorPiece:SetOwner(self)
						ArmorPiece:ManipulateBoneScale(0, ArmorInfo.siz)
						ArmorPiece:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
						ArmorPiece:Spawn()
						ArmorPiece:Activate()

						Ragdoll.EZarmorP[v.name] = ArmorPiece
						if ArmorInfo.eff and ArmorInfo.eff.parachute then
							Parachute = v.name
							local BonePhys = Ragdoll:GetPhysicsObjectNum(Index)
							ArmorPiece:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, -100))
						end
						-- Attach it
						local Weld = constraint.Weld(ArmorPiece, Ragdoll, 0, Ragdoll:TranslateBoneToPhysBone(Index), 0, true)
						if Weld then
							Weld:Activate()
						end
					end
				end
			end

			if IsValid(Ply.EZparachute) and Parachute then
				Ply.EZparachute:SetNW2Entity("Owner", Ragdoll.EZarmorP[Parachute])
				ParachuteEnt = Ragdoll.EZarmorP[Parachute]
				ParachuteEnt:SetNW2Bool("EZparachuting", true)
				ParachuteEnt.EZparachute = Ply.EZparachute
				ParachuteEnt.EZparachute.AttachBone = 0
				ParachuteEnt.EZparachute.Drag = ParachuteEnt.EZparachute.Drag * 5
			end
			Ply:SetNW2Bool("EZparachuting", true)
			Ply.EZparachute = nil
		end
		Ragdoll.IsEZcorpse = true
		self.EZragdoll = Ragdoll
		timer.Simple(0, function()
			if IsValid(self) and IsValid(self.EZragdoll) then
				self:SetParent(self.EZragdoll)
				self:SetPos(Vector(0, 0, 0))
			else
				SafeRemoveEntity(self)
			end
		end)
		self:NextThink(CurTime() + 1)
	end

	function ENT:Think()
		local Time = CurTime()

		--[[if not(IsValid(self.DeadPlayer)) or self.DeadPlayer:Alive() then
			self.VeryDead = true
		end]]--

		if self.EZoverDamage >= 100 then
			self.VeryDead = true
		else
			self.EZoverDamage = math.Clamp(self.EZoverDamage + 2, 0, 100)
		end

		if self.VeryDead then
			self.TimeTillRemoval = math.Clamp(self.TimeTillRemoval - 1, 0, JMod.Config.QoL.JModCorpseStayTime * 60)
			if self.TimeTillRemoval <= 0 then
				self:Remove()
			end
		end

		if IsValid(self.Eater) then
			if (self.Eater:GetPos():Distance(self:GetPos()) < 100) then
				self.Eater:SetActivity(ACT_MELEE_ATTACK1)
			else
				self.Eater:SetLastPosition(self:GetPos())
				self.Eater:SetSchedule(SCHED_FORCED_GO)
			end
		elseif not IsValid(self.Eater) then
			for k, npc in pairs(ents.FindByClass("npc_antlion")) do
				if (npc:GetPos():Distance(self:GetPos()) < 1000) and (npc:GetActivity() == ACT_IDLE) then
					self.Eater = npc

					break
				end
			end
		end--]]

		self:NextThink(Time + 1)

		return true
	end

	function ENT:OnRemove() 
		if IsValid(self.EZragdoll) then
			if istable(self.EZragdoll.EZarmorP) then
				for _, v in pairs(self.EZragdoll.EZarmorP) do
					local Con = constraint.FindConstraintEntity(v, "Weld")
					if IsValid(Con) then
						local Ent1, Ent2 = Con:GetConstrainedEntities()
						if (IsValid(Ent1) and Ent1 == self.EZragdoll) or (IsValid(Ent2) and Ent2 == self.EZragdoll) then
							SafeRemoveEntity(v)
						end
					end
				end
			end
			local Bone = self.EZragdoll:LookupBone("ValveBiped.Bip01_Head1")
			if Bone then
				local Matty = self.EZragdoll:GetBoneMatrix(Bone)
				if Matty then
					local Skull = ents.Create("prop_physics")
					Skull:SetModel("models/gibs/hgibs.mdl")
					Skull:SetPos(Matty:GetTranslation())
					Skull:SetAngles(Matty:GetAngles())
					Skull:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					Skull:Spawn()
					Skull:Activate()
					SafeRemoveEntityDelayed(Skull, 10)
				end
			end
			SafeRemoveEntity(self.EZragdoll)
		end
	end
end