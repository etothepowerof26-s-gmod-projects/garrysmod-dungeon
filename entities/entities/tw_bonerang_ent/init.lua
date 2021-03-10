AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/gibs/hgibs_spine.mdl")
    self:PhysicsInit(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetAngles(Angle(90, 90, 0))
    self:SetModelScale(2)

    timer.Simple(0.05, function()
        local thrower = self:GetBoneThrower()
        self:SetPos(thrower:GetShootPos() + thrower:GetAimVector() * 100)
        self:SetWant(thrower:GetShootPos() + thrower:GetAimVector() * 1150)
        -- self.WantedPos = thrower:GetShootPos() + thrower:GetAimVector() * 1000
        local a = (self:GetPos() - self:GetWant()):Angle()
        --a:RotateAroundAxis(Vector(0,1,0),90)
        --a:RotateAroundAxis(Vector(1,0,0),90)
        self:SetAngles(a)
        self.Damageds = {}
    end)
end

local c = 300 ^ 2

function ENT:Think()
    --if (!self.WantedPos) then return end
    --local a = self:GetAngles()
    --a.y = (a.y + 35) % 360
    --self:SetAngles(a)
    if not self.InitialLerp then
        self.InitialLerp = self:GetWant()
    end

    if not self.LastSound then
        self.LastSound = SysTime()
    end

    if SysTime() > self.LastSound + 0.25 then
        self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, 110)
        self.LastSound = SysTime()
    end

    local dist = self:GetPos():DistToSqr(self.InitialLerp)

    if (dist < c and not self.Override) or (not self:IsInWorld()) then
        self.Override = true
        self.Damageds = {}
    end

    if self.Override then
        local thrower = self:GetBoneThrower()
        -- self:SetPos(thrower:GetShootPos() + thrower:GetAimVector() * 100)
        self:SetWant(thrower:GetShootPos())
        self:SetPos(LerpVector(0.35, self:GetPos(), self:GetWant()))
        local newdist = self:GetPos():DistToSqr(self:GetWant())

        if newdist < c / 2 then
            self:Remove()

            if (thrower:HasWeapon("tw_bonerang")) then
                local wep = thrower:GetWeapon("tw_bonerang")
                wep:OnRetreiveRang()
                wep:CallOnClient("OnRetreiveRang")
            end
        end
    else
        self:SetPos(LerpVector(0.15, self:GetPos(), self:GetWant()))
    end

    local ent_sphere = ents.FindInSphere(self:GetPos(), 42)

    for i = 1, #ent_sphere do
        local ent = ent_sphere[i]

        -- todo not hardcode
        if ent:GetClass() == "tw_zombie" or ent:GetClass() == "drhax" or ent.Base == "tw_zombie" or ent.Type == "nextbot" then
            if not self.Damageds[ent] and ent:Health() > 0 then
                self.Damageds[ent] = true
                local num = 45 * (self.Override and 2 or 1)
                local dmg = DamageInfo()
                dmg:SetDamage(num)
                dmg:SetAttacker(self:GetBoneThrower())
                dmg:SetInflictor(self:GetBoneThrower():GetWeapon("tw_bonerang"))
                dmg:SetDamageType(DMG_CRUSH)
                hook.Run("ScaleNPCDamage", ent, HITGROUP_GENERIC, dmg) -- ScaleNPCDamage( NPC npc, number hitgroup, CTakeDamageInfo dmginfo )
                ent:TakeDamageInfo(dmg)
                ent:EmitSound(self.Override and "physics/flesh/flesh_impact_hard4.wav" or "physics/flesh/flesh_impact_hard3.wav", 100, math.random(95, 135))
                --[[
	function Hitmark(ent, dmg, pos, crt, filter)
		ent = ent or NULL
		dmg = dmg or 0
		pos = pos or ent:EyePos()
		filter = filter or player.GetAll()

		net.Start("hitmark")
			net.WriteEntity(ent)
			net.WriteFloat(dmg)
			net.WriteVector(pos)
			net.WriteBit(crt)
			net.WriteFloat(ent.ACF and ent.ACF.Health or ent.ee_cur_hp or ent:Health())
			net.WriteFloat(ent.ACF and ent.ACF.MaxHealth or ent.ee_max_hp or ent:GetMaxHealth())
		net.Send(filter)
	end
]]
                --Hitmark(ent, -num, ent:EyePos(), self.Override and true or false, ents.FindInPVS(self:GetPos()))
            end
        end
    end
end