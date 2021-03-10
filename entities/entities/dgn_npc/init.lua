AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Humans/Group03/Male_04.mdl")
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()
        self:SetNPCState(NPC_STATE_SCRIPT)
        self:SetSolid(SOLID_BBOX)
        self:SetMoveType(MOVETYPE_STEP)
        self:SetUseType(SIMPLE_USE)
        self:CapabilitiesAdd(bit.bor(bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD), CAP_AIM_GUN))
        self:SetMaxYawSpeed(5000)
    end

    self:PostInit()
end

function ENT:PostInit()
    print(self, "PostInit")
end

ENT.LastUse = {}

function ENT:AcceptInput(name, activator, caller)
    if name == "Use" and IsValid(caller) and caller:IsPlayer() then
        local dist = activator:GetPos():DistToSqr(self:GetPos())

        if dist <= 4000 then
            if not self.LastUse[activator] then
                self.LastUse[activator] = SysTime()
            else
                if SysTime() < self.LastUse[activator] + 1 then return end
            end

            if self.UseFunction then
                self:UseFunction(activator)
            end

            --Say hi
            local snds = self.VoiceLines[self:GetGender()]

            if not snds then
                print(self, ": no sounds exist, not playing sound")
            else
                self:EmitSound(snds.talk[math.random(1, #snds.talk)])
            end

            self.LastUse[activator] = SysTime()
        end
    end
end

local _DIST = 2000 ^ 2

function ENT:OnTakeDamage(dmg)
    dmg:SetDamage(0)
    local atk = dmg:GetAttacker()

    if atk:GetPos():DistToSqr(self:GetPos()) > _DIST then
        atk.DoneMessedUp = nil

        return
    end

    if not atk.DoneMessedUp then
        atk.DoneMessedUp = true
    else
        return
    end

    local snds = self.VoiceLines[self:GetGender()]

    if not snds then
        print(self, ": no sounds exist, not playing sound")
    else
        self:EmitSound(snds.hurt[math.random(1, #snds.hurt)])
    end

    timer.Simple(1, function()
        if IsValid(atk) and atk:IsPlayer() and atk:Health() > 0 then
            atk:Kill()
            atk.DoneMessedUp = nil

            if IsValid(atk:GetRagdollEntity()) then
                atk:GetRagdollEntity():SetName("ragdoll_" .. atk:EntIndex())
            end

            atk:EmitSound(self.Sounds.explode[math.random(1, #self.Sounds.explode)])
            --create lightning effect
            local effect = EffectData()
            effect:SetOrigin(atk:GetPos())
            effect:SetStart(self:GetPos())
            effect:SetEntity(atk)
            effect:SetMagnitude(100)
            util.Effect("TeslaHitBoxes", effect, true, true)
            --dissolve ragdoll
            local dissolve = ents.Create("env_entity_dissolver")
            dissolve:SetPos(atk:GetPos())
            dissolve:SetKeyValue("magnitude", 1000)
            dissolve:SetKeyValue("dissolveType", 0)
            dissolve:Spawn()
            dissolve:Fire("Dissolve", atk:GetRagdollEntity():GetName(), 0)
            dissolve:Fire("Kill", "", 0.1)

            timer.Simple(1, function()
                if IsValid(dissolve) then
                    dissolve:Remove()
                end
            end)
        end
    end)
end