AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("sv_ai.lua")

function ENT:Initialize()
    local d = 7500
    local f = 2500
    self:SetModel("models/player/skeleton.mdl")
    self:SetHealth(100)
    self:SetMaxHealth(100)
    self.SearchRadius = f
    self.LoseTargetDist = f * 1.25
end