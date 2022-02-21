	AddCSLuaFile()

	SWEP.PrintName	= "Utility Belt"

	SWEP.Author		= "8Z"
	SWEP.Purpose	= "Hang some grenades or other items on yourself"
	SWEP.Instructions = "Left Click: Take out active item\nE + Left click: Take out & prime\nRight click: Pick up item\nReload: cycle slots"

	SWEP.Spawnable	= true
	SWEP.UseHands	= true
	SWEP.DrawAmmo	= false
	SWEP.DrawCrosshair= true

	SWEP.ViewModel	= "models/weapons/c_arms_citizen.mdl"
	SWEP.WorldModel	= "models/weapons/w_defuser.mdl"

	--SWEP.DrawViewModel = false
	SWEP.DrawWorldModel = false

	SWEP.ViewModelFOV	= 70
	SWEP.Slot			= 4
	SWEP.SlotPos		= 1

	SWEP.Primary.ClipSize		= -1
	SWEP.Primary.DefaultClip	= -1
	SWEP.Primary.Automatic		= true
	SWEP.Primary.Ammo			= "none"

	SWEP.Secondary.ClipSize		= -1
	SWEP.Secondary.DefaultClip	= -1
	SWEP.Secondary.Automatic	= true
	SWEP.Secondary.Ammo			= "none"

	-- Refactored to be on the player
	--Swep.Owner.BeltSlots = {}
	SWEP.SlotCount = 4

	-- in Singleplayer, these are maintained serverside and sent to client
	-- in Listen/Dedicated servers, these are clientside
	-- Why? Because predictable hooks don't like to run on client in SP for some reason
	-- and syncing is a headache
	--SWEP.ActiveSlot = 0
	--SWEP.NextSlot = 0

	local function lookup(slot)
		local tbl = UTILITY_BELT_ITEMS[slot.class]
		if not tbl then
			tbl = {
				bone = "ValveBiped.Bip01_Spine",
				model = slot.model,
				mat = slot.mat,
				color = slot.color,
				pos = Vector(0,0,0),
				primable = nil,
				ang = Angle(-90,0,90)
			}
		end
		return tbl
	end

	local function can_pickup(ent)
		local class = ent:GetClass()
		
		-- Must be in explicit whitelist (doubles as model info)
		if not UTILITY_BELT_ITEMS[class] then return false end
		
		-- JMod: Grenades / explosives that are primed/armed/broken can't be picked up
		if ent.GetState and ent:GetState() != 0 then return false end

		return true
	end

	function SWEP:Initialize()
		self:SetHoldType("normal")
		self.Owner.BeltSlots = {}
		self.ActiveSlot = 0
		self.NextSlot = 0
	end

	function SWEP:PrimaryAttack()
		if CLIENT then
			self:ReleaseActive()
		elseif SERVER and game.SinglePlayer() then
			self:ReleaseItem(self.ActiveSlot, true, self.Owner:KeyDown(IN_USE))
		end
	end

	function SWEP:SecondaryAttack()
		if self:GetNextSecondaryFire() > CurTime() then return end
		self:SetNextSecondaryFire(CurTime() + 0.1)

		-- Look for something to pick up
		local ent = self.Owner:GetEyeTrace().Entity
		if (IsValid(ent) and !ent.TAKEN and ent:GetPos():DistToSqr(self.Owner:GetPos()) <= 100 * 100 and can_pickup(ent)) then
			for i = 1, self.SlotCount do
				if self.Owner.BeltSlots[i] == nil then
					-- Add the item to the slot
					ent.TAKEN = true
					
					self.Owner.BeltSlots[i] = {
						class = ent:GetClass(),
						model = ent:GetModel(),
						mat = ent:GetMaterial(),
						color = ent:GetColor(),
						primable = nil
					}
					if game.SinglePlayer() then
						-- Predicted hooks aren't called on client in singleplayer
						net.Start("utility_belt")
							net.WriteEntity(self.Owner)
							net.WriteBool(true)
							net.WriteUInt(i, 4)
							net.WriteString(ent:GetClass())
							net.WriteString(ent:GetModel())
							net.WriteString(ent:GetMaterial() or "")
							net.WriteColor(Color(ent:GetColor().r,ent:GetColor().g,ent:GetColor().b,ent:GetColor().a or 255))
						net.Broadcast()
						self:FindSlots(false)
					end
					if SERVER then self.Owner:EmitSound("items/ammo_pickup.wav") end
					SafeRemoveEntity(ent)
					break
				end
			end
		end
	end

	local pressed = false
	function SWEP:Think()
		
		if not pressed and self.Owner:KeyDown(IN_RELOAD) then
			pressed = true
			if (SERVER and game.SinglePlayer()) or (CLIENT and not game.SinglePlayer()) then
				self:FindSlots(true)
			end
			if CLIENT then surface.PlaySound("ui/buttonrollover.wav") end
		elseif pressed and not self.Owner:KeyDown(IN_RELOAD) then
			pressed = false
		end
	end

	UTILITY_BELT_OFFSET = {
		["ValveBiped.Bip01_Spine"] = {
			[1] = {pos = Vector(-6,0,4), ang = Angle(0,-10,15)},
			[2] = {pos = Vector(-6,0,-4), ang = Angle(0,-10,-15)},
			[3] = {pos = Vector(-2,0,8), ang = Angle(0,-10,60)},
			[4] = {pos = Vector(-2,0,-8), ang = Angle(0,-10,-60)}
		},
		["ValveBiped.Bip01_Spine1"] = {
			[1] = {pos = Vector(-3,-4,6), ang = Angle(0,0,70)},
			[2] = {pos = Vector(-3,-4,-6), ang = Angle(0,0,-70)},
			[3] = {pos = Vector(4,-4,4), ang = Angle(180,180,-30)},
			[4] = {pos = Vector(4,-4,-4), ang = Angle(180,180,30)},
		},
	}

	UTILITY_BELT_ITEMS = {

		-- HL2
		["item_healthvial"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/healthvial.mdl",
			mat = "",
			color = Color(255,255,255),
			scale = Vector(1,1,1),
			pos = Vector(0,0,0),
			ang = Angle(90,0,-90)
		},
		["item_healthkit"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/items/healthkit.mdl",
			mat = "",
			color = Color(255,255,255),
			scale = Vector(0.7,0.7,0.7),
			pos = Vector(0,0,0),
			ang = Angle(0,180,-90)
		},
		["item_battery"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/items/battery.mdl",
			mat = "",
			color = Color(255,255,255),
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(0,0,0),
			ang = Angle(90,0,-90)
		},
		
		-- JMod grenades
		["ent_jack_gmod_ezfragnade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/weapons/w_fragjade.mdl",
			mat = "",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1.2,1.2,1.2),
			pos = Vector(-2,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezfirenade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/incendiary_grenade.mdl",
			mat = "",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezimpactnade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/impact_grenade.mdl",
			mat = "",
			primable = true,
			color = Color(255,255,255),
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezflashbang"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/conviction/flashbang.mdl",
			mat = "",
			primable = true,
			color = Color(255,255,255),
			scale = Vector(1,1,1),
			pos = Vector(-1,-5,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezgasnade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/gas_grenade.mdl",
			mat = "",
			primable = true,
			color = Color(255,255,255),
			scale = Vector(1,1,1),
			pos = Vector(-1,-5,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezsticknade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/stick_grenade.mdl",
			mat = "models/mats_jack_nades/stick_grenade",
			color = Color(255,255,255),
			scale = Vector(0.9,0.9,0.9),
			pos = Vector(-1,-1,0),
			ang = Angle(80,0,90)
		},
		["ent_jack_gmod_ezsticknadebundle"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/grenades/bundle_grenade.mdl",
			mat = "models/mats_jack_nades/stick_grenade",
			color = Color(255,255,255),
			scale = Vector(0.9,0.9,0.9),
			pos = Vector(-2,-3,0),
			ang = Angle(90,0,90)
		},
		["ent_jack_gmod_ezsmokenade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/incendiary_grenade.mdl",
			mat = "models/mats_jack_nades/smokescreen",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezsignalnade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/incendiary_grenade.mdl",
			mat = "models/mats_jack_nades/smokesignal",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_ezstickynade"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/grenades/sticky_grenade.mdl",
			mat = "",
			primable = true,
			color = Color(255,255,255),
			scale = Vector(1,1,1),
			pos = Vector(-1,-3,0),
			ang = Angle(90,0,90)
		},
		["ent_jack_gmod_eznade_impact"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/weapons/w_fragjade.mdl",
			mat = "models/mats_jack_nades/gnd_blk",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_eznade_proximity"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/weapons/w_fragjade.mdl",
			mat = "models/mats_jack_nades/gnd_red",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_eznade_remote"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/weapons/w_fragjade.mdl",
			mat = "models/mats_jack_nades/gnd_blu",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_eznade_timed"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/weapons/w_fragjade.mdl",
			mat = "models/mats_jack_nades/gnd_ylw",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-1,-4,0),
			ang = Angle(-90,0,90)
		},
		
		
		
		
		-- JMod explosives
		["ent_jack_gmod_ezboundingmine"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/grenades/bounding_mine.mdl",
			mat = "",
			color = Color(255,255,255),
			primable = false,
			scale = Vector(1,1,1),
			pos = Vector(-2,-4,0),
			ang = Angle(-90,0,90)
		},
		["ent_jack_gmod_eztnt"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/weapons/w_jnt.mdl",
			mat = "",
			color = Color(255,255,255),
			primable = false,
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-4,0),
			ang = Angle(0,0,90)
		},
		["ent_jack_gmod_ezminimore"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/weapons/w_clayjore.mdl",
			mat = "models/mat_jack_claymore",
			color = Color(255,255,255),
			primable = false,
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-8,0),
			ang = Angle(-90,0,-90)
		},
		["ent_jack_gmod_ezlandmine"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/props_pipes/pipe02_connector01.mdl",
			mat = "models/jacky_camouflage/digi2",
			color = Color(255,255,255),
			primable = false,
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-6,0),
			ang = Angle(-90,0,-90)
		},
		["ent_jack_gmod_ezatmine"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/thedoctor/mines/clustermine_1.mdl",
			mat = "models/jacky_camouflage/digi2",
			color = Color(255,255,255),
			primable = false,
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-6,0),
			ang = Angle(0,0,-90)
		},
		["ent_jack_gmod_eztimebomb"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/weapons/w_c4_planted.mdl",
			mat = nil,
			primable = false,
			color = Color(255,255,255),
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-6,0),
			ang = Angle(0,0,-90)
		},
		["ent_jack_gmod_ezdetpack"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/props_misc/tobacco_box-1.mdl",
			mat = "models/entities/mat_jack_c4",
			primable = true,
			color = Color(255,255,255),
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-2,0),
			ang = Angle(90,-90,0)
		},
		["ent_jack_gmod_ezdynamite"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/mechanics/robotics/a2.mdl",
			mat = "models/entities/mat_jack_dynamite",
			color = Color(255,255,255),
			scale = Vector(0.2,0.2,0.2),
			primable = true,
			pos = Vector(-2,-2,0),
			ang = Angle(0,0,0)
		},
		["ent_jack_gmod_ezslam"] = {
			bone = "ValveBiped.Bip01_Spine",
			model = "models/weapons/w_jlam.mdl",
			mat = "",
			color = Color(255,255,255),
			primable = true,
			scale = Vector(1,1,1),
			pos = Vector(-2,-2,0),
			ang = Angle(-90,90,0)
		},
		["ent_jack_gmod_ezsatchelcharge"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/grenades/satchel_charge.mdl",
			mat = "",
			primable = false,
			color = Color(255,255,255),
			scale = Vector(1.4,1.4,1.4),
			pos = Vector(-1,-2,0),
			ang = Angle(-90,0,0)
		},
		["ent_jack_gmod_ezfougasse"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/props_c17/oildrum001.mdl",
			mat = "models/mat_jack_gmod_ezfougasse",
			primable = false,
			color = Color(255,255,255),
			scale = Vector(0.6,0.6,0.6),
			pos = Vector(15,-10,-10),
			ang = Angle(-90,5,-45)
		},
		-- On second thought, let's not allow players to lug four nuclear bombs around
		["ent_jack_gmod_eznuke_small"] = {
			bone = "ValveBiped.Bip01_Spine1",
			model = "models/chappi/mininuq.mdl",
			mat = "",
			primable = false,
			color = Color(255,255,255),
			scale = Vector(0.8,0.8,0.8),
			pos = Vector(-2,-2,0),
			ang = Angle(0,-90,0)
		},
		
	}

	-- This is run serverside in singleplayer and clientside on servers, see comment on ActiveSlot
	function SWEP:FindSlots(increment)

		local cur = self.ActiveSlot - 1

		self.ActiveSlot = 0
		self.NextSlot = 0
		
		--print("looking for ActiveSlot")
		for i = (increment and 1 or 0), 4 do
			local slot = (cur + i) % 4 + 1
			--print("i = " .. i .. " (" .. slot .. ")")
			if self.Owner.BeltSlots[slot] then
				--print("found")
				self.ActiveSlot = slot
				break
			end
		end
		
		if self.ActiveSlot == 0 then return end
		cur = self.ActiveSlot - 1
		--print("looking for NextSlot")
		for i = 1, 3 do
			local slot = (cur + i) % 4 + 1
			--print("i = " .. i .. " (" .. slot .. ")")
			if self.Owner.BeltSlots[slot] then
				--print("found")
				self.NextSlot = slot
				break
			end
		end
		
		if SERVER and game.SinglePlayer() then
			net.Start("utility_belt_slot")
				net.WriteUInt(self.ActiveSlot, 4)
				net.WriteUInt(self.NextSlot, 4)
			net.Send(self.Owner)
		end
	end


	hook.Add("PlayerButtonDown", "utility_belt_key", function(ply, key)

		local wep = ply:GetWeapon("utility_belt")
		if not IsValid(wep) or not wep.Owner.BeltSlots or table.Count(wep.Owner.BeltSlots) <= 0 or wep.Owner.BeltSlots[wep.ActiveSlot] == nil then return end

		if key == KEY_G and ply:KeyDown(IN_USE) then
			if (SERVER and game.SinglePlayer()) or (CLIENT and not game.SinglePlayer()) then
				wep:FindSlots(true)
			end
			if CLIENT then surface.PlaySound("ui/buttonrollover.wav") end
			if SERVER and game.SinglePlayer() then
				ply:SendLua('surface.PlaySound("ui/buttonrollover.wav")')
			end
		elseif key == KEY_G and not ply:KeyDown(IN_USE) then
			if game.SinglePlayer() then
				wep:ReleaseItem(wep.ActiveSlot, not ply:KeyDown(IN_WALK), not ply:KeyDown(IN_WALK))
				wep:FindSlots(false)
			elseif CLIENT then
				net.Start("utility_belt")
					net.WriteUInt(wep.ActiveSlot, 4)
				net.SendToServer()
				timer.Simple(0, function() wep:FindSlots(false) end)
			end
		end
	end)


	hook.Add("StartCommand", "utility_belt_hack", function(ply, cmd)
		-- Since IN_ATTACK is pressed to release object and also to throw object, this causes the object to be instantly thrown (bad!)
		-- This blocks IN_ATTACK for a bit so that the player can release IN_ATTACK (or not, I guess) to hold it
		if cmd:KeyDown(IN_ATTACK) and ply.UTILITY_BELT_HACK then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_ATTACK)))
		end
	end)

	if SERVER then
		-- SERVER -> CLIENT: Updates slot information (only used in singleplayer)
		-- CLIENT -> SERVER: Release item of specified index
		util.AddNetworkString("utility_belt")
		
		-- SERVER -> CLIENT: Updates activeslot and nextslot (only in singleplayer)
		util.AddNetworkString("utility_belt_slot")
		
		net.Receive("utility_belt", function(len, ply)
			local wep = ply:GetWeapon("utility_belt")
			if not IsValid(wep) or not IsValid(ply) then return end
			local i = net.ReadUInt(4)
			wep:ReleaseItem(i)
		end)
		
		function SWEP:ReleaseItem(i, pickup, prime)

			if self:GetNextPrimaryFire() > CurTime() then return end
			self:SetNextPrimaryFire(CurTime() + 0.5)
			if self.Owner.BeltSlots[i] == nil or (IsValid(self.LastThrow) and self.LastThrow:IsPlayerHolding()) then return end
			if self.Owner:GetEyeTrace().HitPos:DistToSqr(self.Owner:EyePos()) < 60 * 60
					or self.Owner:GetEyeTrace().Entity and self.Owner:GetEyeTrace().Entity:GetPos():DistToSqr(self.Owner:EyePos()) < 100 * 100 then return end
			self:SetNextPrimaryFire(CurTime() + 1)
			self.LastThrow = nil

			local ent = ents.Create(self.Owner.BeltSlots[i].class)
			ent:SetModel(self.Owner.BeltSlots[i].model)
			ent:SetPos(self.Owner:EyePos() + self.Owner:GetAimVector() * 30)
			ent:SetAngles(self.Owner:GetAngles())
			ent:Spawn()
			ent:SetColor(self.Owner.BeltSlots[i].color)
			self.Owner.UTILITY_BELT_HACK = true
			if ent.Base == "ent_jack_gmod_ezgrenade" then
				if pickup then JMod.ThrowablePickup(self.Owner,ent,ent.HardThrowStr,ent.SoftThrowStr) end
				if prime and isfunction(ent.Prime) then ent:Prime() end
				JMod.Owner(ent, self.Owner)
			else
				if pickup then self.Owner:PickupObject(ent) end
				ent.Owner = self.Owner
			end
			timer.Simple(0.25, function() if IsValid(self.Owner) then self.Owner.UTILITY_BELT_HACK = false end end)
			
			if prime then
				self.Owner:EmitSound("items/flashlight1.wav")
			else
				self.Owner:EmitSound("weapons/zoom.wav")
			end
			
			self.LastThrow = ent

			self.Owner.BeltSlots[i] = nil
			if game.SinglePlayer() then
				self:FindSlots(false)
			end            
			net.Start("utility_belt")
				net.WriteEntity(self.Owner)
				net.WriteBool(false)
				net.WriteUInt(i, 4)
			net.Broadcast()
		end
		
		function SWEP:ScatterItems(detonate, instant)
			local j = 0
			for i = 1, 4 do
				local slot = self.Owner.BeltSlots[i]
				if slot ~= nil then
				
					local tbl = lookup(slot)
					local bIndex = self.Owner:LookupBone(tbl.bone)
					local bPos, bAng = self.Owner:GetBonePosition(bIndex)
					local off = UTILITY_BELT_OFFSET[tbl.bone][i]
					local vel = self.Owner:GetPhysicsObject():GetVelocity()
			
					local ent = ents.Create(slot.class)
					ent:SetModel(tbl.model)
					ent:SetMaterial(slot.mat or tbl.mat or "")
					
					if bIndex and bPos and bAng and off then
						local r,f,u = bAng:Right(), bAng:Forward(), bAng:Up()
						bPos = bPos + r * tbl.pos.x + f * tbl.pos.y + u * tbl.pos.z
						bPos = bPos + r * off.pos.x + f * off.pos.y + u * off.pos.z
						
						bAng:RotateAroundAxis(r, tbl.ang.p)
						bAng:RotateAroundAxis(u, tbl.ang.y)
						bAng:RotateAroundAxis(f, tbl.ang.r)
						bAng:RotateAroundAxis(r, off.ang.p)
						bAng:RotateAroundAxis(u, off.ang.y)
						bAng:RotateAroundAxis(f, off.ang.r)
						
						ent:SetPos(bPos)
						ent:SetAngles(bAng)
					else
						ent:SetPos(self.Owner:GetPos())
					end
					JMod.Owner(ent, self.Owner)
				
					if detonate then
						ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
						timer.Simple(j * 0.1, function()
							ent:Spawn()
							ent:SetColor(slot.color)
							ent:GetPhysicsObject():SetVelocity(vel)
							timer.Simple(0, function() -- This workaround mostly exists for the satchel charge
								if IsValid(ent) then
									if instant and ent.Detonate then
										ent:Detonate()
									elseif not instant then
										if ent:GetClass() == "ent_jack_gmod_ezsatchelcharge" then
											ent:Detonate()
										elseif ent.Prime then 
											ent:Prime()
										elseif ent.Arm then 
											ent:Arm()
										--elseif ent.Detonate then
										--    timer.Simple(math.random() + 1, function()
										--        if IsValid(ent) then ent:Detonate() end
										--    end)
										end
									end
								end
							end)
						end)
						j = j + 1
					else
						ent:Spawn()
						ent:GetPhysicsObject():SetVelocity(vel)
					end
				end
			end
			self.Owner.BeltSlots = {}
			net.Start("utility_belt")
				net.WriteEntity(self.Owner)
				net.WriteBool(false)
				net.WriteUInt(0, 4)
			net.Broadcast()
		end
		
		hook.Add("PlayerSpawn", "utility_belt_spawn", function(ply)
			ply.BeltSlots = {}
			net.Start("utility_belt")
				net.WriteEntity(ply)
				net.WriteBool(false)
				net.WriteUInt(0, 4)
			net.Broadcast()
		end)
		
		hook.Add("PlayerDeath", "utility_belt_drop", function(ply)
		
			local wep = ply:GetWeapon("utility_belt")
			if not IsValid(wep) or not wep.Owner.BeltSlots or table.Count(wep.Owner.BeltSlots) <= 0 then return end
			
			local det = ply:GetWeapon("utility_belt_detonator")
			if IsValid(det) and det.DeadManSwitch then
				wep:ScatterItems(true)
			else
				wep:ScatterItems(false)
			end
		
		end)
	end

	if CLIENT then
		
		
		function SWEP:ReleaseActive()
			if self.Owner.BeltSlots[self.ActiveSlot] == nil then return end
			net.Start("utility_belt")
				net.WriteUInt(self.ActiveSlot, 4)
			net.SendToServer()
			timer.Simple(0, function() self:FindSlots(false) end)
		end
		
		function SWEP:ShouldDrawViewModel()
			return false
		end
		
		function SWEP:DrawWorldModel()
			if not IsValid(self.Owner) then
				self:DrawModel() -- Show the world model when nobody is holding it
			end
		end
		
		net.Receive("utility_belt", function()
			local ply = net.ReadEntity()
			local write = net.ReadBool()
			local index = net.ReadUInt(4)
			if write == false then
				if index == 0 then
					ply.BeltSlots = {}
				else
					ply.BeltSlots[index] = nil
				end
			else
				local class = net.ReadString()
				local mdl = net.ReadString()
				local mat = net.ReadString()
				local primable = net.ReadBool()
				local color = net.ReadColor()
				ply.BeltSlots[index] = {
					class = class,
					model = mdl,
					mat = mat,
					color = color,
					primable = primable
				}
			end
			if not game.SinglePlayer() and ply:GetWeapon("utility_belt") then ply:GetWeapon("utility_belt"):FindSlots(false) end
		end)
		
		net.Receive("utility_belt_slot", function()
			local wep = LocalPlayer():GetWeapon("utility_belt")
			if not IsValid(wep) then return end
			wep.ActiveSlot = net.ReadUInt(4)
			wep.NextSlot = net.ReadUInt(4)
		end)
		
		local matOverlay_Normal = Material( "gui/ContentIcon-normal.png" )
		local matOverlay_Hovered = Material( "gui/ContentIcon-hovered.png" )
		local mat_Detonator = Material("sprites/mat_jack_clacker")
		local curmat = nil
		local nextmat = nil
		local ubposx = CreateClientConVar("jmod_cl_utilitybelt_pos_x", 0.01, FCVAR_USERINFO, "Adjusts the Utility Belt HUD's X coordinate relative to the player's screen.", nil, nil)
		local ubposy = CreateClientConVar("jmod_cl_utilitybelt_pos_y", 250, FCVAR_USERINFO, "Adjusts the Utility Belt HUD's Y coordinate relative to the player's screen.", nil, nil)
		
	hook.Add("HUDPaint", "utility_belt_quickhud", function()
	local xinfo = LocalPlayer():GetInfo("jmod_cl_utilitybelt_pos_x")
	local yinfo = LocalPlayer():GetInfo("jmod_cl_utilitybelt_pos_y")
    local wep = LocalPlayer():GetWeapon("utility_belt")
    if not LocalPlayer():Alive() or not IsValid(wep) then return end
    local x = ScrW() * xinfo
    local y = ScrH() - yinfo
    local scale = 1
    local font = "DermaDefault"
    surface.SetDrawColor(255, 255, 255, 255)

    if wep.ActiveSlot ~= 0 and LocalPlayer().BeltSlots[wep.ActiveSlot] ~= nil then
        local path = "entities/" .. LocalPlayer().BeltSlots[wep.ActiveSlot].class

        if not curmat or curmat:GetName() ~= path then
            curmat = Material(path .. ".png")
        end

        surface.SetMaterial(curmat)
        surface.DrawTexturedRect(x + 3, y + 3, (128 - 6) * scale, (128 - 6) * scale)
    else
        draw.SimpleTextOutlined("N/A", font, x + 64 * scale, y + 64 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(50, 50, 50))
    end

    surface.SetMaterial(matOverlay_Normal)
    surface.DrawTexturedRect(x, y, 128 * scale, 128 * scale)
    draw.SimpleTextOutlined("ACTIVE QUICKBELT", font, x + 64 * scale, y + 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(50, 50, 50))
    draw.SimpleTextOutlined(table.Count(LocalPlayer().BeltSlots) .. " / 4 ITEMS", font, x + 64 * scale, y + (128 - 16) * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(50, 50, 50))
    local x2 = x + 128 * scale
    local y2 = y + 64 * scale

    if wep.NextSlot ~= 0 and LocalPlayer().BeltSlots[wep.NextSlot] ~= nil then
        local path = "entities/" .. LocalPlayer().BeltSlots[wep.NextSlot].class

        if not nextmat or nextmat:GetName() ~= path then
            nextmat = Material(path .. ".png")
        end

        surface.SetMaterial(nextmat)
        surface.DrawTexturedRect(x2 + 1.5, y2 + 1.5, (64 - 3) * scale, (64 - 3) * scale)
    else
        draw.SimpleTextOutlined("N/A", font, x2 + 32 * scale, y2 + 32 * scale, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(50, 50, 50))
    end

    surface.SetMaterial(matOverlay_Hovered)
    surface.DrawTexturedRect(x2, y2, 64 * scale, 64 * scale)
    draw.SimpleTextOutlined("NEXT", font, x2 + 32 * scale, y2 + 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(50, 50, 50))
    local det = LocalPlayer():GetWeapon("utility_belt_detonator")

    if IsValid(det) then
        local x3 = x + (128 - 4) * scale
        local y3 = y + 4 * scale
        local s = det.DeadManSwitch
        surface.SetDrawColor(255, 255, 255, s and 255 or 100)
        surface.SetMaterial(mat_Detonator)
        surface.DrawTexturedRect(x3, y3, 48 * scale, 48 * scale)
        draw.SimpleTextOutlined("DMS " .. (s and "ON" or "OFF"), font, x3 + 24 * scale, y3 + 36 * scale, Color(255, 255, 255, s and 255 or 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(50, 50, 50, s and 255 or 100))
    end
end)
		-- Draw models on player
		hook.Add("PostPlayerDraw", "utility_belt_render", function(ply)
			
			ply.BeltModels = ply.BeltModels or {}
			local wep = ply:GetWeapon("utility_belt")
			
			if not LocalPlayer().BeltSlots or table.Count(LocalPlayer().BeltSlots) <= 0 then 
				-- Clean up any models if they exist
				if IsValid(ply.BeltModels) and istable(ply.BeltModels) and table.Count(wep.Owner.BeltSlots) > 0 then 
					for _, mdl in pairs(ply.BeltModels) do mdl:Remove() end 
				end
				return 
			end

			for i = 1, 4 do
			
				local slot = wep.Owner.BeltSlots[i]
				
				if not slot then
					if IsValid(ply.BeltModels[i]) then 
						ply.BeltModels[i]:Remove() 
						ply.BeltModels[i] = nil 
					end
				else
				
					local tbl = lookup(slot)
					local mdl = ply.BeltModels[i]
					
					if IsValid(mdl) and mdl:GetModel() ~= tbl.model then
						mdl:Remove()
					end
					
					if not IsValid(mdl) then 
						mdl = ClientsideModel(tbl.model) 
						mdl:SetModel(tbl.model)
						mdl:SetPos(ply:GetPos())
						mdl:SetMaterial(tbl.mat or "")
						mdl:SetParent(ply)
						mdl:SetNoDraw(true)
						ply.BeltModels[i] = mdl
					end
					
					local bIndex = ply:LookupBone(tbl.bone)
					local bPos,bAng = ply:GetBonePosition(bIndex)
					local off = UTILITY_BELT_OFFSET[tbl.bone][i]
					
					if IsValid(mdl) and bIndex and bPos and bAng and off then
					
						local r,f,u = bAng:Right(), bAng:Forward(), bAng:Up()
						
						bPos = bPos + r * tbl.pos.x + f * tbl.pos.y + u * tbl.pos.z
						bPos = bPos + r * off.pos.x + f * off.pos.y + u * off.pos.z
						
						bAng:RotateAroundAxis(r, tbl.ang.p)
						bAng:RotateAroundAxis(u, tbl.ang.y)
						bAng:RotateAroundAxis(f, tbl.ang.r)
						bAng:RotateAroundAxis(r, off.ang.p)
						bAng:RotateAroundAxis(u, off.ang.y)
						bAng:RotateAroundAxis(f, off.ang.r)
						
						mdl:SetRenderOrigin(bPos)
						mdl:SetRenderAngles(bAng)
						
						if tbl.scale then 
							local m = Matrix()
							m:Scale(tbl.scale)
							mdl:EnableMatrix("RenderMultiply",m)
						end
						
						local color = slot.color or tbl.color
						if color then
							local r,g,b=render.GetColorModulation()
							render.SetColorModulation(color.r/255,color.g/255,color.b/255)
							mdl:DrawModel()
							render.SetColorModulation(r,g,b)
						end
					end
				end
			end
		end)
	end