GM.Name = "Garry's Mod Dungeon"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

if SERVER then
    include("logging.lua")
end

AddCSLuaFile("sh_indicators.lua")
include("sh_indicators.lua")
AddCSLuaFile("charcreate/init.lua")
include("charcreate/init.lua")
AddCSLuaFile("hud/init.lua")
include("hud/init.lua")
team.SetUp(420, "Loading", Color(90, 90, 90))
team.SetUp(1, "Players", Color(255, 169, 42))
team.SetUp(2, "Enemy", Color(255, 152, 152))
team.SetUp(69, "World Boss", Color(200, 52, 142))
DUNGEON = DUNGEON or {}
-- I need to move this to sh_meta or something like that.
local PLY = FindMetaTable("Player")

local function NetworkedAccessor(tab, plymeta, key, method, default_get, default_set)
    if not default_get then
        default_get = 0
    end

    if not default_set then
        default_set = 0
    end

    tab["Get" .. (method or "Something")] = function(self) return self["GetNW" .. plymeta](self, key, default_get) end

    if SERVER then
        tab["Set" .. (method or "Something")] = function(self, value)
            value = value or default_set -- tonumber(value) or default_set
            self["SetNW" .. plymeta](self, key, value)
        end
    end
end

-- eventually other accessor funcs may be used
local function NetworkedAccessorNum(tab, key, method, default_get, default_set)
    NetworkedAccessor(tab, "Int", key, method, default_get, default_set)
end

NetworkedAccessorNum(PLY, "m_iManaAmount", "Mana")
NetworkedAccessorNum(PLY, "m_iMaxManaAmount", "MaxMana")
NetworkedAccessorNum(PLY, "m_iDef", "Defense")
NetworkedAccessorNum(PLY, "m_iSpareSkillPoints", "SpareSkillPoints")
NetworkedAccessorNum(PLY, "m_iStr", "Strength")
NetworkedAccessorNum(PLY, "m_iCritChance", "CritChance")
NetworkedAccessorNum(PLY, "m_iCritDmg", "CritDamage")
NetworkedAccessorNum(PLY, "m_iLv", "PLevel", 0, 0)
NetworkedAccessorNum(PLY, "m_iExp", "Experience", 0, 0)
NetworkedAccessorNum(PLY, "m_iNextLevelExp", "NeededExp", 100, 0)
--
NetworkedAccessorNum(PLY, "m_iClassID", "DClassID", 0, 0)
NetworkedAccessorNum(PLY, "m_iCharID", "DCharID", 0, 0)
local BASE_EXP = 25
local FACTOR = 2.5

function DUNGEON.GetNeededExperience(lv)
    return math.floor(BASE_EXP + (math.pow(lv, FACTOR) - 1) * 4)
end