AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("sv_ai.lua")

function ENT:Initialize()
    self:DefaultVars()
    local d = 7500
    local f = 2500
    local total_hp = self:TotalMobHealth()
    self:SetModel("models/zombie/classic.mdl")
    self:SetHealth(total_hp)
    self:SetMaxHealth(total_hp)
    self.SearchRadius = f
    self.LoseTargetDist = f * 1.25
end

function ENT:OnKilled(dmg)
    -- hook.Call( "OnNPCKilled", GAMEMODE, self, dmg:GetAttacker(), dmg:GetInflictor() )
    print(SERVER, CLIENT)
    -- gamemode.Call( "AddDeathNotice", "Anubis the Enlightened one( Lv.25 )", 69, "weapon_ar2", ply:Nick(), ply:Team() )
    self:EmitSound('npc/zombie/zombie_die' .. math.random(1, 3) .. '.wav')
    self:BecomeRagdoll(dmg)
    self:DefaultKillFunc(dmg)
    -- GAMEMODE:HandlePlayerLV(pl)
end

function ENT:DefaultKillFunc(dmg)
    local pl

    if IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
        pl = dmg:GetAttacker()
    else
        if IsValid(dmg:GetInflictor()) and dmg:GetInflictor():IsPlayer() then
            pl = dmg:GetInflictor()
        end
    end

    if (not pl or not IsValid(pl)) then return end
    local exp = math.random(self.MinEXPFromKill, self.MaxEXPFromKill)
    local mult = hook.Run("ProcessExperienceMultiplier", pl, self, exp)
    pl:SetExperience(pl:GetExperience() + math.ceil(exp * mult))
    hook.Run("HandlePlayerLV", pl)
    hook.Run("HandleProperEnemyDeath", pl, self)
end