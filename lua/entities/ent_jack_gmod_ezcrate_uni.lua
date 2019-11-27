-- Jackarunda 2019
AddCSLuaFile()
ENT.Type = "anim"
ENT.Author = "Jackarunda, TheOnly8Z"
ENT.Category = "JMod - EZ"
ENT.Information = ""
ENT.PrintName = "EZ Universal Crate"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.JModPreferredCarryAngles = Angle(0, 0, 0)
ENT.DamageThreshold = 120
ENT.MaxItems = JMod_EZsmallCrateSize or 100
---
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ItemCount")
end

---
if (SERVER) then

	util.AddNetworkString("JModUniCrate")
	
	net.Receive("JModUniCrate", function(len, ply)
	
		local box = net.ReadEntity()
		local class = net.ReadString()
		
		if !IsValid(box) or (box:GetPos() - ply:GetPos()):Length() > 100 or !box.Items[class] or box.Items[class] <= 0 then return end
		
		box.Items[class] = (box.Items[class] > 1) and (box.Items[class] - 1) or nil
		
		local ent = ents.Create(class)
		ent:SetPos(box:GetPos())
		ent:SetAngles(box:GetAngles())
		ent:Spawn()
		ply:PickupObject(ent)
		timer.Simple(0, function() box:SetItemCount(box:GetItemCount() - math.max(ent:GetPhysicsObject():GetVolume()/1000, 1)) end)
		
		box.NextLoad=CurTime()+2
		box:EmitSound("Ammo_Crate.Close")
		box:CalcWeight()
		
	end)

    function ENT:SpawnFunction(ply, tr)
        local SpawnPos = tr.HitPos + tr.HitNormal * 40
        local ent = ents.Create(self.ClassName)
        ent:SetAngles(Angle(0, 0, 0))
        ent:SetPos(SpawnPos)
        ent.Owner = ply
        ent:Spawn()
        ent:Activate()
        return ent
    end

    function ENT:Initialize()
        self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:SetModelScale(1.5)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)

        self:SetItemCount(0)
        self.EZconsumes = {self.ItemType}
        self.NextLoad = 0
        self.Items = {}
		
        timer.Simple(.01, function()
            self:CalcWeight()
        end)
    end

    function ENT:CalcWeight()
        self:GetPhysicsObject():SetMass(50 + (self:GetItemCount() / self.MaxItems) * 250)
    end

    function ENT:PhysicsCollide(data, physobj)
        if (data.DeltaTime > 0.2) and (data.Speed > 100) then
                self:EmitSound("Wood_Crate.ImpactHard")
                self:EmitSound("Wood_Box.ImpactHard")
        end

        if (self.NextLoad > CurTime()) then return end
        local ent = data.HitEntity

        if ent.JModEZstorable and ent:IsPlayerHolding() 
				and self:GetItemCount() + math.max(ent:GetPhysicsObject():GetVolume()/1000, 1) <= self.MaxItems then
            self.NextLoad = CurTime() + 0.5
            self.Items[ent:GetClass()] = (self.Items[ent:GetClass()] or 0) + 1
            self:SetItemCount(self:GetItemCount() + math.max(ent:GetPhysicsObject():GetVolume()/1000, 1))
            timer.Simple(0, function() SafeRemoveEntity(ent) end)
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)

        if (dmginfo:GetDamage() > self.DamageThreshold) then
            local Pos = self:GetPos()
            sound.Play("Wood_Crate.Break", Pos)
            sound.Play("Wood_Box.Break", Pos)
            
			for class, num in pairs(self.Items) do
				for i = 1, num do
				
					local ent = ents.Create(class)
					ent:SetPos(self:GetPos() + VectorRand() * 10)
					ent:SetAngles(AngleRand())
					ent:Spawn()
					ent:Activate()
				
				end
			end
			
            self:Remove()
        end
    end

    function ENT:Use(activator)
        JMod_Hint(activator, "item crate")
        if (self:GetItemCount() <= 0) then return end

		net.Start("JModUniCrate")
			net.WriteEntity(self)
			net.WriteTable(self.Items)
		net.Send(activator)
    end

    function ENT:Think()
        --pfahahaha
    end

    function ENT:OnRemove()
        --aw fuck you
    end
elseif (CLIENT) then

	local frame
	net.Receive("JModUniCrate", function()
	
		local box = net.ReadEntity()
		local items = net.ReadTable()
		
		if frame then frame:Close() end
		
		frame = vgui.Create("DFrame")
		frame:SetSize(200, 300)
		frame:SetTitle("G.P. Crate")
		frame:Center()
		frame:MakePopup()
		frame.OnClose = function() frame = nil end
		
		local scrollPanel = vgui.Create("DScrollPanel", frame)
		scrollPanel:SetSize(190, 270)
		scrollPanel:SetPos(5, 30)
		
		local layout = vgui.Create("DIconLayout", scrollPanel)
		layout:SetSize(190, 270)
		layout:SetPos(0, 0)
		layout:SetSpaceY(5)
		
		for class, count in pairs(items) do
		
			local sent = scripted_ents.Get(class)
			
			local button = vgui.Create("DButton", layout)
			button:SetSize(190, 25)
			button:SetText(sent.PrintName .. " x" .. count)
			button.DoClick = function()
				net.Start("JModUniCrate")
					net.WriteEntity(box)
					net.WriteString(class)
				net.SendToServer()
				frame:Close()
			end
			
		end
		
	end)

    local TxtCol = Color(10, 10, 10, 220)
    function ENT:Draw()
        local Ang, Pos = self:GetAngles(), self:GetPos()
        local Closeness = LocalPlayer():GetFOV() * (EyePos():Distance(Pos))
        local DetailDraw = Closeness < 45000 -- cutoff point is 500 units when the fov is 90 degrees
        self:DrawModel()

        if (DetailDraw) then
            local Up, Right, Forward, Resource = Ang:Up(), Ang:Right(), Ang:Forward(), tostring(self:GetItemCount())
            Ang:RotateAroundAxis(Ang:Right(), 90)
            Ang:RotateAroundAxis(Ang:Up(), -90)
            cam.Start3D2D(Pos + Up * 18 - Forward * 29.8 + Right, Ang, .2)
            draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil-S", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText("G.P. CRATE", "JMod-Stencil", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText("Capacity: " .. Resource .. "/" .. self.MaxItems, "JMod-Stencil-S", 0, 70, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            cam.End3D2D()
            ---
            Ang:RotateAroundAxis(Ang:Right(), 180)
            cam.Start3D2D(Pos + Up * 18 + Forward * 30.1 - Right, Ang, .2)
            draw.SimpleText("JACKARUNDA INDUSTRIES", "JMod-Stencil-S", 0, 0, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText("G.P. CRATE", "JMod-Stencil", 0, 15, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            draw.SimpleText("Capacity: " .. Resource .. "/" .. self.MaxItems, "JMod-Stencil-S", 0, 70, TxtCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            cam.End3D2D()
        end
    end
end