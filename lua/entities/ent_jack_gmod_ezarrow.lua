-- Jackarunda 2021
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda"
ENT.Category = "JMod - EZ Explosives"
ENT.Information = "glhfggwpezpznore"
ENT.PrintName = "EZ Arrow"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.StickMats = {MAT_GRASS, MAT_DIRT, MAT_SAND, MAT_FOLIAGE, MAT_FLESH, MAT_ANTLION, MAT_BLOODYFLESH, MAT_ALIENFLESH, MAT_SNOW, MAT_PLASTIC, MAT_SLOSH, MAT_WOOD}

ENT.BreakMats = {MAT_CONCRETE, MAT_EGGSHELL, MAT_GRATE, MAT_CLIP, MAT_METAL, MAT_COMPUTER, MAT_TILE, MAT_VENT, MAT_DEFAULT, MAT_GLASS, MAT_WARPSHIELD}

ENT.EZammo = "Arrow"
ENT.CollisionGroup = COLLISION_GROUP_NONE
ENT.NoPhys = true
local ThinkRate = 22 --Hz

---
if SERVER then
	function ENT:Initialize()
		self.Entity:SetMoveType(MOVETYPE_NONE)
		self.Entity:DrawShadow(false)
		self.Entity:SetCollisionBounds(Vector(-20, -20, -10), Vector(20, 20, 10))
		self.Entity:PhysicsInitBox(Vector(-20, -20, -10), Vector(20, 20, 10))
		local phys = self.Entity:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableCollisions(false)
		end

		self.Entity:SetNotSolid(true)
		self.Entity:SetUseType(SIMPLE_USE)
		self.Entity:SetTrigger(true)
		self.DieTime = CurTime() + 120
	end

	function ENT:Impact(tr)
		if self.Impacted then return end
		self.Impacted = true
		local SelfPos, Att, Dir = (tr and tr.HitPos + tr.HitNormal * 5) or self:GetPos() + Vector(0, 0, 30), self.Owner or self, self.CurVel:GetNormalized()

		self:FireBullets({
			Damage = self.Damage * .66,
			Force = self.Damage * .33,
			Num = 1,
			Tracer = 0,
			Spread = Vector(0, 0, 0),
			Src = self:GetPos(),
			Dir = Dir,
			Attacker = self.Owner or game.GetWorld(),
			AmmoType = self.AmmoType
		})

		local Slash = DamageInfo()
		Slash:SetDamagePosition(tr.HitPos)
		Slash:SetDamageType(DMG_SLASH)
		Slash:SetAttacker(self.Owner or game.GetWorld())
		Slash:SetInflictor(self)
		Slash:SetDamageForce(Dir * self.Damage * .33)
		Slash:SetDamage(self.Damage * .33)
		tr.Entity:TakeDamageInfo(Slash)

		if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
			self:SetPos(tr.HitPos + Dir * 5 - self:GetUp() * 2)

			if (tr.Entity.Alive and tr.Entity:Alive()) or (tr.Entity.Health and (tr.Entity:Health() > 0)) then
				self:SetParent(tr.Entity)
				self.StuckIn = tr.Entity
			else
				self:DropToGround()
			end

			return
		elseif table.HasValue(self.StickMats, tr.MatType) then
			self:SetPos(tr.HitPos + Dir * 5 - self:GetUp() * 2)

			if not tr.Entity:IsWorld() then
				self:SetParent(tr.Entity)
				self.StuckIn = tr.Entity
			end

			return
		end

		self:Remove()
	end

	function ENT:OnRemove()
	end

	--
	function ENT:UseEffect()
	end

	-- stub
	function ENT:SetCount(num)
		if num <= 0 then
			self:Remove()
		end
	end

	function ENT:StartTouch(toucher)
		if self.Impacted and toucher:IsPlayer() and not (self.StuckIn and (self.StuckIn == toucher)) then
			self:Use(toucher)
		end
	end

	function ENT:Use(activator)
		JMod.GiveAmmo(activator, self)
	end

	function ENT:GetCount()
		return 1 -- stub
	end

	local LastTime = 0

	function ENT:Think()
		if self.Impacted then
			if self.StuckIn then
				local StaySticked = true

				if IsValid(self.StuckIn) then
					if self.StuckIn:IsPlayer() and not self.StuckIn:Alive() then
						StaySticked = false
					elseif self.StuckIn:IsNPC() and self.StuckIn.Health and self.StuckIn:Health() <= 0 then
						StaySticked = false
					end
				end

				if not StaySticked then
					self:DropToGround()
				end
			end

			if self.DieTime < CurTime() then
				self:Remove()

				return
			end

			self:NextThink(CurTime() + 1)

			return true
		end

		local Time, Pos, Dir, Speed = CurTime(), self:GetPos(), self.CurVel:GetNormalized(), self.CurVel:Length()
		local Tr

		if self.InitialTrace then
			Tr = self.InitialTrace
			self.InitialTrace = nil
		else
			local Filter = {self}

			table.insert(Filter, self.Owner)
			--Tr=util.TraceLine({start=Pos,endpos=Pos+self.CurVel/ThinkRate,filter=Filter})
			local Mask = MASK_SHOT

			Tr = util.TraceLine({
				start = Pos,
				endpos = Pos + self.CurVel / ThinkRate,
				filter = Filter,
				mask = Mask
			})
		end

		if Tr.Hit then
			if Tr.HitSky then
				self:Remove()

				return
			end

			self:Impact(Tr)
		else
			self:SetPos(Pos + self.CurVel / ThinkRate)
			self.CurVel = self.CurVel + physenv.GetGravity() / ThinkRate * 2
		end

		if IsValid(self) then
			if self.DieTime < Time then
				self:Remove()

				return
			end

			self:NextThink(Time + (1 / ThinkRate))
		end

		LastTime = Time

		return true
	end

	function ENT:DropToGround()
		local Tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -600), {self, self.Owner, self.StuckIn})

		self:SetParent(nil)
		self.StuckIn = nil

		if Tr.Hit then
			self:SetPos(Tr.HitPos + Tr.HitNormal * .1)
			self:SetAngles(Angle(0, math.random(0, 360), 0))
		end
	end
elseif CLIENT then
	function ENT:Initialize()
		self.Mdl = ClientsideModel("models/weapons/w_jmod_crossbow_bolt.mdl")
		self.Mdl:SetPos(self:GetPos())
		self.Mdl:SetParent(self)
		self.Mdl:SetNoDraw(true)
		self.RenderPos = self:GetPos()
		self.NextRender = CurTime() + .5
	end

	function ENT:Think()
	end

	--
	function ENT:Draw()
		if self.NextRender > CurTime() then
			self.RenderPos = LerpVector(FrameTime() * 30, self.RenderPos, self:GetPos())

			return
		end

		local Pos, Ang, Dir = self.RenderPos, self:GetAngles(), self:GetRight()
		Ang:RotateAroundAxis(Ang:Up(), 90)
		--self:DrawModel()
		self.Mdl:SetRenderOrigin(Pos + Ang:Up() * 1.5 - Ang:Right() * 0 - Ang:Forward() * 1)
		self.Mdl:SetRenderAngles(Ang)
		local Matricks = Matrix()
		Matricks:Scale(Vector(2, 2, 2))
		self.Mdl:EnableMatrix("RenderMultiply", Matricks)
		self.Mdl:DrawModel()
		self.RenderPos = LerpVector(FrameTime() * 30, self.RenderPos, self:GetPos())
	end
end
