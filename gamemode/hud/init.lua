if (SERVER) then
    AddCSLuaFile("cl_hitmark.lua")
    include("sv_hitmark.lua")
end

if (CLIENT) then
    include("cl_hitmark.lua")
end